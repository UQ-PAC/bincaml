open Bincaml_util.Common
open Containers
open Lang
open Lattice_collections
open Lattice_types
open Idessi

(** Highest Live Bit analysis utilizing the IDESSI solver to determine the
    highest live bit that all variables in a procedure ever use. Allows for
    bitvectors that are unnecessarily large to be reduced by a further
    transform.

    Examines the inner-most expression that operates directly on a variable, and
    determines the highest accessed bit of said variable. Mainly checks whether
    shifts and extracts are performed on a variable. *)

(*
  KNOWN ISSUE: A variable that is given to a call as a formal-in parameter is either not being detected in the analysis, or is given
               BOT instead of TOP
*)

(* Should run ide_live before this *)

module HighestLiveBitLattice = struct
  let name = "highestLiveBit"

  (* Highest bit is inclusive, i.e. 63 means bits [..63] are used*)
  (* lo_lb can also be called offset *)
  (* I think that in this simple implementation, lo_lb is redundant, but it is being left here for potential future use *)
  type t = Bot | HighBit of { hi_lb : int; lo_lb : int; is_var : bool } | Top
  [@@deriving eq, ord, show { with_path = false }]

  let highbit a b c = HighBit { hi_lb = a; lo_lb = b; is_var = c }
  let top = Top
  let bottom = Bot
  let pretty t = Containers_pp.text (show t)

  let show = function
    | Top -> "⊤"
    | Bot -> "⊥"
    | HighBit { hi_lb = hi; lo_lb = lo; is_var = iv } ->
        "(" ^ string_of_int hi ^ ", " ^ string_of_int lo ^ ", "
        ^ string_of_bool iv ^ ")"

  let join a b =
    match (a, b) with
    | Top, _ | _, Top -> Top
    | Bot, a | a, Bot -> a
    | HighBit { hi_lb = ha; lo_lb = la }, HighBit { hi_lb = hb; lo_lb = lb } ->
        let max_hi_lb = max ha hb in
        let min_lo_lb = min la lb in
        highbit max_hi_lb min_lo_lb false (* TODO: check if true or false *)

  let leq a b =
    match (a, b) with
    | a, b when equal a b -> true
    | HighBit { hi_lb = ha; lo_lb = la }, HighBit { hi_lb = hb; lo_lb = lb } ->
        ha <= hb && la >= lb
    | Bot, _ | _, Top -> true
    | _, Bot | Top, _ -> false

  let widening a b = join a b
  let narrowing a b = a

  let get_hi a =
    match a with HighBit { hi_lb = hi; lo_lb; is_var } -> Some hi | _ -> None
end

(* IDESSI Lattice Backwards*)
module IDESSI_LB = struct
  let direction = `Backwards

  module Value = HighestLiveBitLattice

  module DL = struct
    type t = Lambda | Label of Var.t
    [@@deriving eq, ord, show { with_path = false }]

    let show = function Lambda -> "Λ" | Label v -> Var.name v
  end

  type t =
    | BotEdge
    | IdEdge
    | NumEdge of int (* The index of the highest live bit *)
    | TopEdge
  [@@deriving eq, ord]

  let show e =
    let open Bincaml_util.Unicode in
    match e with
    | BotEdge -> bot_char
    | IdEdge -> "IdEdge"
    | TopEdge -> top_char
    | NumEdge a -> "NumEdge " ^ string_of_int a

  let pp fmt x = Format.pp_print_string fmt (show x)
  let bottom = BotEdge
  let identity = IdEdge
  let top = TopEdge

  let compose a b =
    match (a, b) with
    | IdEdge, b -> b
    | a, IdEdge -> a
    | BotEdge, _ | _, BotEdge -> BotEdge
    | TopEdge, _ | _, TopEdge -> TopEdge
    | NumEdge v, NumEdge v' -> NumEdge v

  let join a b =
    match (a, b) with
    | TopEdge, _ | _, TopEdge -> TopEdge
    | BotEdge, b -> b
    | a, BotEdge -> a
    | NumEdge v, NumEdge v' -> NumEdge (max v v')
    | IdEdge, b -> b
    | a, IdEdge -> a

  let eval x f =
    match (f, x) with
    | BotEdge, _ -> Value.bottom
    | IdEdge, x -> x
    | TopEdge, _ -> Top
    | NumEdge v, _ -> Value.highbit v 0 true

  module Extract = struct
    (* Returns a HighestLiveBitLattice t *)
    (* This does the math that determines the highbit tuple *)
    let extract_alg readv e =
      let open Expr.AbstractExpr in
      match e with
      | RVar { id } -> readv id
      | UnaryExpr
          {
            op = `Extract (hi, lo);
            arg = Value.HighBit { hi_lb; lo_lb; is_var }, _;
          } ->
          if is_var then Value.highbit (hi - 1 + lo_lb) lo_lb false
          else Value.highbit hi_lb lo_lb false
      | BinaryExpr { op = `BVASHR; arg1; arg2 } -> Value.top
      | BinaryExpr
          {
            op = `BVLSHR;
            arg1 = Value.HighBit { hi_lb; lo_lb; is_var }, _;
            arg2 = _, Some (`Bitvector bv);
          } ->
          let shift = Bitvec.to_signed_bigint bv |> Z.to_int in
          if is_var then
            if shift > hi_lb then Value.bottom
            else Value.highbit hi_lb (shift + lo_lb) false
          else Value.highbit hi_lb lo_lb false
      | BinaryExpr
          {
            op = `BVSHL;
            arg1 = Value.HighBit { hi_lb; lo_lb; is_var }, _;
            arg2 = _, Some (`Bitvector bv);
          } ->
          let shift = Bitvec.to_signed_bigint bv |> Z.to_int in
          if is_var then
            if shift > hi_lb then Value.bottom
            else Value.highbit (hi_lb - shift) (lo_lb - shift) false
          else Value.highbit hi_lb lo_lb false
      | BinaryExpr { arg1 = v1, _; arg2 = v2, _ } -> Value.join v1 v2
      | ApplyIntrin { args = (v1, _) :: rest } ->
          List.fold_left (fun v1 (v2, _) -> Value.join v1 v2) v1 rest
      | UnaryExpr { op; arg = a, _ } -> a
      | _ -> Value.bottom

    (* Converts HighestLiveBitLattice t to IDESSI_LB t*)
    let extract_expr readv e =
      match
        Expr.BasilExpr.zygo_l Expr_eval.eval_expr_alg (extract_alg readv) e
      with
      | Value.Bot -> BotEdge
      | Value.Top -> TopEdge
      | Value.HighBit { hi_lb; lo_lb } -> NumEdge hi_lb

    (* find number of live bits for a single
    variable [var] in an expression ; read function returns the width for
    this variable, and bot for everything else*)
    let eval_wrt_var var expr =
      let readv v =
        if Var.equal v var then
          match Types.bit_width (Var.typ var) with
          | Some w -> Value.highbit (w - 1) 0 true
          | None -> Value.bottom
        else Value.bottom
      in
      extract_expr readv expr

    let eval_stmt stmt =
      Stmt.iter_rexpr stmt (* take every expr on the rhs of stmt *)
      |> Iter.map (function `Expr e -> e | `Var v -> Expr.BasilExpr.rvar v)
        (* iterate each variable in each of these *)
      |> Iter.flat_map (fun rhs_expr ->
          Expr.BasilExpr.free_vars_iter rhs_expr
          |> Iter.map (fun rhs_var -> (rhs_var, eval_wrt_var rhs_var rhs_expr)))
    (* for each variable, return an edge with the number of live bits*)
  end
end

module HighestLiveBitIDE = struct
  include IDESSI_LB

  type state_update = (DL.t * t) Iter.t

  let init_data (proc : Program.proc) =
    Procedure.formal_out_params proc |> StringMap.values

  open DL

  let transfer_call call param d =
    match d with
    | Lambda ->
        (* TODO: This lambda never seems to trigger, which is... odd *)
        StringMap.to_iter call
        |> Iter.flat_map (fun (_, e) -> Expr.BasilExpr.free_vars_iter e)
        |> Iter.map (fun v -> (Label v, TopEdge))
        (* (StringMap.to_iter call |> Iter.flat_map (snd %> Expr.BasilExpr.free_vars_iter)) *)
        (* StringMap.to_iter param |> Iter.map (fun (name, var) -> Label var, TopEdge)  *)
        (* Iter.singleton (Lambda, TopEdge) *)
    | Label v ->
        StringMap.to_iter call
        |> Iter.flat_map (fun (_, e) -> Expr.BasilExpr.free_vars_iter e)
        |> Iter.map (fun v -> (Label v, TopEdge))

  (* StringMap.to_iter call
        |> Iter.filter (fun (s, e) -> VarSet.mem v (Expr.BasilExpr.free_vars e))
        |> Iter.map (fun (s, e) ->
            let v' = StringMap.find s param in
            let edge = IDESSI_LB.Extract.eval_wrt_var v' e in
            (Label v', edge)) *)

  let transfer stmt d =
    let open Stmt in
    match d with
    | Lambda -> (
        match stmt with
        | Instr_Assign _ ->
            Iter.empty (* If run after ide_live, this line shouldn't matter *)
        | _ ->
            IDESSI_LB.Extract.eval_stmt stmt
            |> Iter.map (fun (rhs_var, edge) -> (Label rhs_var, edge)))
    | Label v -> (
        match stmt with
        | Instr_Assign { al } ->
            Iter.of_list al
            |> Iter.flat_map (fun (lhs_var, rhs_expr) ->
                if Var.equal v lhs_var then
                  Expr.BasilExpr.free_vars_iter rhs_expr
                  |> Iter.map (fun rhs_var ->
                      let edge =
                        IDESSI_LB.Extract.eval_wrt_var rhs_var rhs_expr
                      in
                      (Label rhs_var, edge))
                else Iter.empty)
        | Instr_IndirectCall c -> failwith "unreachable"
        | _ -> Iter.empty)
  (* | _ -> IDESSI_LB.Extract.eval_stmt stmt
            |> Iter.map (fun (rhs_var, edge) -> (Label rhs_var, edge))) *)

  let transfer_phi lhs rhs d =
    match d with
    | Lambda -> Iter.empty
    | _ -> Iter.of_list rhs |> Iter.map (fun v -> (Label v, IdEdge))

  let init_p2 (proc : Program.proc) =
    Procedure.formal_out_params proc
    |> StringMap.values
    |> Iter.map (fun v -> (v, Value.Top))
end

module IDELiveBitSSIAnalysis = IDESSI (HighestLiveBitIDE)

let%expect_test "test1_basic_shifts" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
prog entry @main;

proc @main() -> (out1:bv64)
[
    block %main_entry [
      var v1:bv64 := 99:bv64;

      var a:bv64 := bvashr(v1, 2:bv64);

      return (a);
    ];
];

proc @f() -> (f_out:bv32)
[
    block %f_entry [
      var v1:bv64 := 99:bv64;

      var f_a:bv32 := extract(32,0,v1);

      return (f_a);
    ];
];

proc @g() -> (g_out:bv1)
[
    block %g_entry [
      var v1:bv64 := 99:bv64;

      var g_a:bv1 := extract(1,0,extract(32,0,v1));

      return (g_a);
    ];

    block %g_entry_2 [
      var v1:bv32 := 99:bv32;

      var g_a:bv1 := extract(1,0,v1);

      return (g_a);
    ];
];

proc @h() -> (h_out:bv1)
[
    block %h_entry [
      var v1:bv64 := 99:bv64;

      var h_a:bv32 := extract(32,0,v1);
      var h_b:bv1 := extract(1,0,h_a);

      return (h_b);
    ];
];

proc @shift() -> (left_out:bv64, right_out:bv64)
[
    block %shift_entry [
      var v1:bv64 := 999:bv64;

      var left:bv64 := bvshl(v1:bv64, 32:bv32);
      var right:bv64 := bvlshr(v1:bv64, 32:bv64);

      return (left, right);
    ];
];

proc @shift2() -> (left_out:bv64, right_out:bv64)
[
    block %shift_entry [
      var v1:bv64 := 999:bv64;

      var left:bv64 := bvlshr(bvshl(v1:bv64, 32:bv64),32:bv64);
      var right:bv64 := bvshl(bvlshr(v1:bv64, 32:bv64), 32:bv64);

      return (left, right);
    ];
];

proc @trans(b:bv64) -> (out:bv32) {}
[
    block %trans [
      (var v1:bv64=out1) := call @binary_expr(0xffffffff:bv64);
      var v2:bv32 := extract(32, 0, v1:bv64);
      return (v2);
    ];
];

proc @binary_expr(c:bv64) -> (out1:bv64) {}
[
    block %binary_expr [
      var v1:bv64 := c:bv64;
      var v2:bv8 := extract(8, 0, v1:bv64);
      var v3:bv8 := extract(16, 8, v1:bv64);
      var v4:bv64 := zero_extend(56, bvand(v2:bv8, v3:bv8));
      return (v4);
    ];
];
    |}
  in
  let program = lst.prog in
  let results, p2_results = IDELiveBitSSIAnalysis.solve program in
  IDMap.iter
    (fun id vars ->
      Printf.printf "ID: %s\n" (ID.show id);

      VarMap.iter
        (fun var value ->
          Printf.printf "  %s -> %s\n" (Var.show var)
            (IDESSI_LB.Value.show value))
        vars)
    p2_results;
  [%expect
    {|
    ID: ("@main", 0)
      { Var.V.name = "out1"; typ = bv64; scope = Var.LocalVar } -> ⊤
      { Var.V.name = "v1"; typ = bv64; scope = Var.LocalVar } -> ⊤
      { Var.V.name = "a"; typ = bv64; scope = Var.LocalVar } -> (63, 0, true)
    ID: ("@f", 1)
      { Var.V.name = "f_out"; typ = bv32; scope = Var.LocalVar } -> ⊤
      { Var.V.name = "v1"; typ = bv64; scope = Var.LocalVar } -> (31, 0, true)
      { Var.V.name = "f_a"; typ = bv32; scope = Var.LocalVar } -> (31, 0, true)
    ID: ("@g", 2)
      { Var.V.name = "g_out"; typ = bv1; scope = Var.LocalVar } -> ⊤
      { Var.V.name = "v1"; typ = bv64; scope = Var.LocalVar } -> (31, 0, true)
      { Var.V.name = "g_a"; typ = bv1; scope = Var.LocalVar } -> (0, 0, true)
    ID: ("@h", 3)
      { Var.V.name = "h_out"; typ = bv1; scope = Var.LocalVar } -> ⊤
      { Var.V.name = "v1"; typ = bv64; scope = Var.LocalVar } -> (31, 0, true)
      { Var.V.name = "h_a"; typ = bv32; scope = Var.LocalVar } -> (0, 0, true)
      { Var.V.name = "h_b"; typ = bv1; scope = Var.LocalVar } -> (0, 0, true)
    ID: ("@shift", 4)
      { Var.V.name = "left_out"; typ = bv64; scope = Var.LocalVar } -> ⊤
      { Var.V.name = "right_out"; typ = bv64; scope = Var.LocalVar } -> ⊤
      { Var.V.name = "v1"; typ = bv64; scope = Var.LocalVar } -> (63, 0, false)
      { Var.V.name = "left"; typ = bv64; scope = Var.LocalVar } -> (63, 0, true)
      { Var.V.name = "right"; typ = bv64; scope = Var.LocalVar } -> (63, 0, true)
    ID: ("@shift2", 5)
      { Var.V.name = "left_out"; typ = bv64; scope = Var.LocalVar } -> ⊤
      { Var.V.name = "right_out"; typ = bv64; scope = Var.LocalVar } -> ⊤
      { Var.V.name = "v1"; typ = bv64; scope = Var.LocalVar } -> (63, 0, false)
      { Var.V.name = "left"; typ = bv64; scope = Var.LocalVar } -> (63, 0, true)
      { Var.V.name = "right"; typ = bv64; scope = Var.LocalVar } -> (63, 0, true)
    ID: ("@trans", 6)
      { Var.V.name = "out"; typ = bv32; scope = Var.LocalVar } -> ⊤
      { Var.V.name = "v1"; typ = bv64; scope = Var.LocalVar } -> (31, 0, true)
      { Var.V.name = "v2"; typ = bv32; scope = Var.LocalVar } -> (31, 0, true)
    ID: ("@binary_expr", 7)
      { Var.V.name = "out1"; typ = bv64; scope = Var.LocalVar } -> ⊤
      { Var.V.name = "c"; typ = bv64; scope = Var.LocalVar } -> (63, 0, true)
      { Var.V.name = "v1"; typ = bv64; scope = Var.LocalVar } -> (15, 0, true)
      { Var.V.name = "v2"; typ = bv8; scope = Var.LocalVar } -> (7, 0, true)
      { Var.V.name = "v3"; typ = bv8; scope = Var.LocalVar } -> (7, 0, true)
      { Var.V.name = "v4"; typ = bv64; scope = Var.LocalVar } -> (63, 0, true)
    |}]

let%expect_test "sqrt" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
var $stack:(bv64->bv8);
prog entry @Sqrt_4196228;
proc @Sqrt_4196228(R0_in:bv64, R31_in:bv64)  -> (R0_out:bv64, R1_out:bv64) { .address = 4196228;
    .name = "Sqrt"; .returnBlock = "Sqrt_return" }
  modifies $stack:(bv64->bv8)
  captures $stack:(bv64->bv8)

[
   block %Sqrt_entry [
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xffffffffffffffd8:bv64) R0_in:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xfffffffffffffff8:bv64) 0x0:bv64 64;
      var var1_4196240_bv64_2:bv64 := load le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xffffffffffffffd8:bv64) 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xfffffffffffffff0:bv64) bvadd(var1_4196240_bv64_2:bv64, 0x1:bv64) 64;
      goto (%Sqrt_loop1_18);
   ];
   block %Sqrt_loop1_18 [
      var var1_4196328_bv64_2:bv64 := load le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xfffffffffffffff8:bv64) 64;
      var var1_4196336_bv64_2:bv64 := load le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xfffffffffffffff0:bv64) 64;
      goto (%phi_3,%phi_2);
   ];
   block %phi_2 [
      guard boolnot(eq(var1_4196336_bv64_2:bv64,
        bvadd(var1_4196328_bv64_2:bv64, 0x1:bv64)));
      var var1_4196256_bv64_2:bv64 := load le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xfffffffffffffff8:bv64) 64;
      var var1_4196260_bv64_2:bv64 := load le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xfffffffffffffff0:bv64) 64;
      var R0_9:bv64 := bvadd(var1_4196256_bv64_2:bv64, var1_4196260_bv64_2:bv64);
      var R1_7:bv64 := bvand(bvor(bvlshr(R0_9:bv64, 0x3f:bv64),
        bvshl(R0_9:bv64, 0x1:bv64)), 0x1:bv64);
      var R0_10:bv64 := bvadd(R1_7:bv64, R0_9:bv64);
      var R0_11:bv64 := bvor(bvand(sign_extend(63, extract(64,63, R0_10:bv64)),
        0x8000000000000000:bv64),
       bvand(bvor(bvlshr(R0_10:bv64, 0x1:bv64), bvshl(R0_10:bv64, 0x3f:bv64)),
        0x7fffffffffffffff:bv64));
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xffffffffffffffec:bv64) extract(32,0, R0_11:bv64) 32;
      var var1_4196284_bv32_2:bv32 := load le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xffffffffffffffec:bv64) 32;
      var R0_13:bv64 := zero_extend(32,
      bvmul(var1_4196284_bv32_2:bv32, var1_4196284_bv32_2:bv32));
      var R0_14:bv64 := bvor(bvand(sign_extend(63, extract(32,31, R0_13:bv64)),
        0xffffffff00000000:bv64),
       bvand(bvand(R0_13:bv64, 0xffffffff:bv64), 0xffffffff:bv64));
      var var1_4196296_bv64_2:bv64 := load le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xffffffffffffffd8:bv64) 64;
      goto (%phi_6,%phi_5);
   ];
   block %phi_5 [
      guard bvslt(var1_4196296_bv64_2:bv64, R0_14:bv64);
      var var1_4196320_bv32_2:bv32 := load le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xffffffffffffffec:bv64) 32;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xfffffffffffffff0:bv64) sign_extend(32, var1_4196320_bv32_2:bv32) 64;
      goto (%Sqrt_loop1_18);
   ];
   block %phi_6 [
      guard boolnot(bvslt(var1_4196296_bv64_2:bv64, R0_14:bv64));
      var var1_4196308_bv32_2:bv32 := load le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xffffffffffffffec:bv64) 32;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xfffffffffffffff8:bv64) sign_extend(32, var1_4196308_bv32_2:bv32) 64;
      goto (%Sqrt_loop1_18);
   ];
   block %phi_3 [
      guard eq(var1_4196336_bv64_2:bv64, bvadd(var1_4196328_bv64_2:bv64, 0x1:bv64));
      var var1_4196348_bv64_2:bv64 := load le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xfffffffffffffff8:bv64) 64;
      goto (%Sqrt_return);
   ];
   block %Sqrt_return [
      (var R0_out:bv64 := var1_4196348_bv64_2:bv64,
       var R1_out:bv64 := var1_4196336_bv64_2:bv64);
      return;
   ]
];
    |}
  in
  let program = lst.prog in
  let results, p2_results = IDELiveBitSSIAnalysis.solve program in
  Hashtbl.iter
    (fun pid summary ->
      print_endline @@ ID.name pid;
      print_endline @@ IDELiveBitSSIAnalysis.show_summary summary;
      print_endline
      @@ Iter.to_string (fun (v, r) -> Var.name v)
      @@ VarMap.to_iter
      @@ IDMap.get_or pid p2_results ~default:VarMap.empty)
    results;
  [%expect
    {|
    @Sqrt_4196228
    (Λ,Λ->IdEdge), (Λ,R31_in->NumEdge 63), (Λ,R0_in->NumEdge 63), (Λ,var1_4196240_bv64_2->NumEdge 63), (Λ,var1_4196328_bv64_2->NumEdge 63), (Λ,var1_4196336_bv64_2->NumEdge 63), (Λ,var1_4196256_bv64_2->NumEdge 63), (Λ,var1_4196260_bv64_2->NumEdge 63), (Λ,R0_9->NumEdge 63), (Λ,R1_7->NumEdge 63), (Λ,R0_10->NumEdge 63), (Λ,R0_11->NumEdge 31), (Λ,var1_4196284_bv32_2->NumEdge 31), (Λ,R0_13->NumEdge 63), (Λ,R0_14->NumEdge 63), (Λ,var1_4196296_bv64_2->NumEdge 63), (Λ,var1_4196320_bv32_2->NumEdge 31), (Λ,var1_4196308_bv32_2->NumEdge 31), (R0_out,R0_out->IdEdge), (R0_out,var1_4196348_bv64_2->NumEdge 63), (R1_out,R1_out->IdEdge)
    R31_in, R0_in, R0_out, R1_out, var1_4196240_bv64_2, var1_4196328_bv64_2, var1_4196336_bv64_2, var1_4196256_bv64_2, var1_4196260_bv64_2, R0_9, R1_7, R0_10, R0_11, var1_4196284_bv32_2, R0_13, R0_14, var1_4196296_bv64_2, var1_4196320_bv32_2, var1_4196308_bv32_2, var1_4196348_bv64_2
    |}]

open Bincaml_util.Common
open Containers
open Lang
open Lattice_collections
open Lattice_types
open Idessi

(* Note: this doesn't work *)

module HighestLiveBitLattice = struct
  let name = "highestLiveBit"

  (* Highest bit is inclusive, i.e. 63 means bits [..63] are used*)
  (* lo_lb is only used in eval: for IDE, return just hi_lb *)
  (* lo_lb can also be called offset *)
  type hb = { vhi : int ; vlo : int ; ehi : int ; elo : int ; width : int}
  [@@deriving eq, ord, show { with_path = false}]

  type t = Bot | HighBit of hb list | Top
  [@@deriving eq, ord, show { with_path = false}]

  let highbit a b c d e =
    HighBit [{ vhi = a ; vlo = b ; ehi = c ; elo = d ; width = e}]  

  let top = Top
  let bottom = Bot
  let pretty t = Containers_pp.text (show t)

  let show = function
    | Top -> "⊤"
    | Bot -> "⊥"
    | HighBit hbs -> "[(" ^ String.concat "); (" (List.map (fun (x: hb) -> string_of_int x.vhi
                                                                      ^ ", " ^ string_of_int x.vlo
                                                                      ^ ", " ^ string_of_int x.ehi
                                                                      ^ ", " ^ string_of_int x.elo
                                                                      ^ ", " ^ string_of_int x.width) hbs) ^ ")]"
  
  let join a b = 
    match (a, b) with
    | Top, _ | _, Top -> Top
    | Bot, a | a, Bot -> a
    | HighBit hba, HighBit hbb -> HighBit (List.sort_uniq ~cmp:compare_hb (hba @ hbb))

  let widening a b = join a b
  let narrowing a b = a
  (* Can use this to get the final vhi *)
  let get_hi hbs = match hbs with | HighBit (hb :: hbs) -> Some (List.fold_left (fun max_vhi hbb -> max max_vhi hbb.vhi) hb.vhi hbs) | _ -> None
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
    | NumEdge of Value.t (* The index of the highest live bit *)
    | TopEdge
  [@@deriving eq,ord]

  let show e =
    let open Bincaml_util.Unicode in 
    match e with
    | BotEdge -> bot_char
    | IdEdge -> "IdEdge"
    | TopEdge -> top_char
    (* | NumEdge a -> "NumEdge " ^ string_of_int a *)
    | NumEdge hbs -> "NumEdge " ^ Value.show hbs

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
    | NumEdge (HighBit hba), NumEdge (HighBit hbb) -> NumEdge (HighBit (List.sort_uniq ~cmp:Value.compare_hb (hba @ hbb)))
    | NumEdge _, NumEdge _ -> BotEdge
    | IdEdge, b -> b
    | a, IdEdge -> a

  let eval x f =
    match (f, x) with
    | BotEdge, _ -> Value.bottom
    | IdEdge, x -> x
    | TopEdge, _ -> Top
    | NumEdge v, _ -> v

  module Extract = struct

   
    let highbit_extract hi lo vhi vlo ehi elo width =
      let w = (hi - lo) in
      (if (hi - 1 < elo || lo > ehi) then Value.bottom
      else if (hi - 1 <= ehi && lo >= elo) then (Value.highbit (hi - 1 + vlo) (vlo + lo) (hi - lo - 1) 0 w)
      else if (hi - 1 <= ehi && lo < elo) then (Value.highbit (hi - 1 + vlo - elo) vlo (hi - lo - 1) (elo - lo) w)
      else if (hi - 1 > ehi && lo >= elo) then (Value.highbit vhi (vlo + lo - elo) (ehi - lo) 0 w)
      else if (hi - 1 > ehi && lo < elo) then (Value.highbit vhi vlo (ehi - lo) (elo - lo) w)
      else Value.bottom)

    let highbit_bvashr bv vhi vlo ehi elo width =
      let shift = ((Bitvec.to_signed_bigint bv) |> Z.to_int) in
          if shift > ehi then 
            if ehi = width - 1 then Value.highbit (vhi) (width - 1) (width - 1) (width - 1) (width) 
            else Value.bottom
          else Value.highbit (vhi) (vlo + (max 0 (shift - elo))) (if ehi = width - 1 then ehi else ehi - shift) (max 0 (elo - shift)) width

    let highbit_bvlshr bv vhi vlo ehi elo width =
      let shift = ((Bitvec.to_signed_bigint bv) |> Z.to_int) in
        if shift > ehi then Value.bottom
        else Value.highbit vhi (vlo + (max 0 (shift - elo))) (ehi - shift) (max 0 (elo - shift)) width

    let highbit_bvshl bv vhi vlo ehi elo width =
      let shift = ((Bitvec.to_signed_bigint bv) |> Z.to_int) in
        if shift >= width - elo then Value.bottom
        else Value.highbit (vhi - (max 0 (ehi + shift - width + 1))) vlo (min (width - 1) (ehi + 1)) (elo + shift) width

    (* Returns a HighestLiveBitLattice t *)
    (* This does the math that determines the highbit tuple seen in the comments at the bottom *)
    let extract_alg readv e =
      let open Expr.AbstractExpr in
      let eval_shifts f bv hb_list = Value.HighBit (
        List.concat_map (fun (h: Value.hb) ->
          match f bv h.vhi h.vlo h.ehi h.elo h.width with
          | Value.HighBit hbs -> hbs | _ -> []) hb_list
      ) in
      match e with
      | RVar { id } -> readv id 
      | UnaryExpr { op = `Extract (hi, lo) ; arg = (Value.HighBit hb_list, _) } -> Value.HighBit (
        List.concat_map (fun (h : Value.hb) -> 
          match highbit_extract hi lo h.vhi h.vlo h.ehi h.elo h.width with
          | Value.HighBit hbs -> hbs | _ -> []) hb_list)
      | BinaryExpr { op = `BVASHR ; arg1 = (HighBit hb_list, _) ; arg2 = (_, Some (`Bitvector bv)) } -> 
        eval_shifts highbit_bvashr bv hb_list
      | BinaryExpr { op = `BVLSHR ; arg1 = (HighBit hb_list, _) ; arg2 = (_, Some (`Bitvector bv)) } -> 
        eval_shifts highbit_bvlshr bv hb_list
      | BinaryExpr { op = `BVSHL ; arg1 = (HighBit hb_list, _) ; arg2 = (_, Some (`Bitvector bv)) } -> 
        eval_shifts highbit_bvshl bv hb_list
      | BinaryExpr { arg1 = (v1, _) ; arg2 = (v2, _) } -> Value.join v1 v2
      | ApplyIntrin { args = (v1, _) :: rest } -> List.fold_left (fun v1 (v2,_) -> Value.join v1 v2) v1 rest
      | UnaryExpr { op = _ ; arg = (nam_waz_here, _) } -> nam_waz_here
      | _ -> Value.bottom

    (* Converts HighestLiveBitLattice t to IDESSI_LB t*)
    let extract_expr readv e =
      match Expr.BasilExpr.zygo_l Expr_eval.eval_expr_alg (extract_alg readv) e with
      | Value.Bot -> BotEdge
      | Value.Top -> TopEdge
      (* If e_hi_lb < 0 then BotEdge*)
      (* | Value.HighBit { vhi ; vlo ; ehi ; elo ; width } -> NumEdge vhi *)
      | Value.HighBit v when List.is_empty v -> BotEdge
      | Value.HighBit v -> NumEdge (HighBit v)

        (* find number of live bits for a single
    variable [var] in an expression ; read function returns the width for
    this variable, and bot for everything else*)
    let eval_wrt_var var expr = 
      let readv v = 
        if Var.equal v var
          then (
            match Types.bit_width (Var.typ var) with 
            | Some w -> Value.highbit (w-1) 0 (w-1) 0 w
            | None -> Value.bottom
          ) 
        else Value.bottom
      in extract_expr readv expr

    let eval_stmt stmt =
      Stmt.iter_rexpr stmt (* take every expr on the rhs of stmt *)
      |> Iter.map (function `Expr e -> e | `Var v -> Expr.BasilExpr.rvar v) (* iterate each variable in each of these *)
      |> Iter.flat_map (fun rhs_expr -> Expr.BasilExpr.free_vars_iter rhs_expr
        |> Iter.map (fun rhs_var -> rhs_var, (eval_wrt_var rhs_var rhs_expr)))
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
    | Lambda -> Iter.singleton (Lambda, IdEdge)
    | Label v ->
        StringMap.to_iter call
        |> Iter.filter (fun (s, e) -> VarSet.mem v (Expr.BasilExpr.free_vars e))
        |> Iter.map (fun (s, e) ->
          let v' = StringMap.find s param in
          let edge = IDESSI_LB.Extract.eval_wrt_var v' e in
          (Label v', edge))

    let transfer stmt d =
      let open Stmt in
      match d with
      | Lambda -> (
        match stmt with
        | Instr_Assign _ -> Iter.empty 
        (* TODO: Check if it's ok to delete this line *)
        | _ ->
            (* Stmt.free_vars_iter stmt
            |> Iter.map (fun v -> (Label v, TopEdge))) *)
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
                        let edge = IDESSI_LB.Extract.eval_wrt_var rhs_var rhs_expr in
                        Label rhs_var, edge)
                  else Iter.empty)
          | Instr_IndirectCall c -> failwith "unreachable"
          | _ -> Iter.empty)
          (* |_ -> IDESSI_LB.Extract.eval_stmt stmt |> Iter.map (fun (rhs_var, edge) -> (Label rhs_var, edge))) *)

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

proc @main() -> (out1:bv64, out2:bv64, out3:bv1, out4:bv64)
[
    block %main_entry [
      var v1:bv64 := 99:bv64;

      var a:bv64 := extract(1, 0, bvlshr(extract(5, 0, v1), zero_extend(62, 0x3:bv2)));

      var x:bv5 := extract(5, 0, v1);
      var y:bv5 := bvlshr(x, 3:bv64);
      var b:bv64 := extract(1, 0, y);

      var c:bv2 := extract(2, 0, bvlshr(bvshl(extract(5, 0, v1), 10:bv64), 4:bv64));

      var d:bv64 := bvor(bvand(extract(10,5,v1), bvadd(extract(13,8,v1), extract(5,0,v1))), extract(5,0,bvlshr(extract(11,6,v1), 20:bv64)));

      return (a,b,c,d);
    ];
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
    @main
    (Λ,Λ->IdEdge), (out1,out1->IdEdge), (out1,v1->NumEdge [(3, 3, 0, 0, 1)]), (out1,a->NumEdge [(63, 0, 63, 0, 64)]), (out2,out2->IdEdge), (out2,v1->NumEdge [(4, 0, 4, 0, 5)]), (out2,x->NumEdge [(4, 3, 1, 0, 5)]), (out2,y->NumEdge [(0, 0, 0, 0, 1)]), (out2,b->NumEdge [(63, 0, 63, 0, 64)]), (out3,out3->IdEdge), (out3,c->NumEdge [(1, 0, 1, 0, 2)]), (out4,out4->IdEdge), (out4,v1->NumEdge [(4, 0, 4, 0, 5); (9, 5, 4, 0, 5); (12, 8, 4, 0, 5)]), (out4,d->NumEdge [(63, 0, 63, 0, 64)])
    out1, out2, out3, out4, v1, a, x, y, b, c, d
    |}]

let%expect_test "test2_basic_call" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
prog entry @main;

proc @main(a:bv64, b:bool) -> (out:bv64)
[
    block %main [
        (var c:bv64) := call @f(a:bv64);
        return (c);
    ];
];

proc @f(x:bv64) -> (o:bv64)
[
    block %f_entry [
      goto (%f_a);
    ];

    block %f_a [
      var d:bv64 := x;
      var e:bv64 := bvlshr(d, 3:bv64);
      goto (%f_return);
    ];

    block %f_return [
        var w:bv64 := extract(5, 2, bvlshr(bvshl(extract(5, 0, d), 1:bv64), 2:bv64));
        return (w:bv64);
      ];
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
    @main
    (Λ,Λ->IdEdge), (out,out->IdEdge), (out,c->NumEdge [(63, 0, 63, 0, 64)])
    out, c
    @f
    (Λ,Λ->IdEdge), (o,d->NumEdge [(3, 3, 0, 0, 3)]), (o,x->NumEdge [(63, 0, 63, 0, 64)]), (o,o->IdEdge), (o,w->NumEdge [(63, 0, 63, 0, 64)])
    d, x, o, w
    |}]
 
let%expect_test "test3_basic_call_phi" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
prog entry @main;

proc @main(a:bv64) -> (out:bv64)
[
    block %main [
      (var b:bv64) := call @f(a:bv64);
      return (b);
    ];
];

proc @f(x:bv64) -> (f_o:bv64)
[
    block %f_entry [
      goto (%f_a, %f_b);
    ];

    block %f_a[
      var y_1:bv64 := extract(5,0,x);
      goto (%f_c);
    ];

    block %f_b[
      var y_2:bv64 := extract(20,15,x);
      goto (%f_c);
    ];

    block %f_c (
      var y_3:bv64 := phi(%f_a -> y_1:bv64, %f_b -> y_2:bv64)
    ) [
      goto (%f_return);  
    ];

    block %f_return [
      return (y_3);
    ];
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
    @main
    (Λ,Λ->IdEdge), (out,b->NumEdge [(63, 0, 63, 0, 64)]), (out,out->IdEdge)
    b, out
    @f
    (Λ,Λ->IdEdge), (f_o,x->NumEdge [(4, 0, 4, 0, 5); (19, 15, 4, 0, 5)]), (f_o,f_o->IdEdge), (f_o,y_1->NumEdge [(63, 0, 63, 0, 64)]), (f_o,y_2->NumEdge [(63, 0, 63, 0, 64)]), (f_o,y_3->NumEdge [(63, 0, 63, 0, 64)])
    x, f_o, y_1, y_2, y_3
    |}]

let%expect_test "test4_dead_var_c" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
prog entry @main;
proc @main(global_in:bv64) -> (out:bv64)
[
    block %main [
      var v1:bv64 := 0xffffffffffffffff:bv64;

      var a:bv32 := extract(40,8, v1);
      assert eq(a, 0xffffffff:bv32);

      var b:bv32 := extract(50,18,v1);

      var c:bv32 := extract(64,32, v1);
      return(b);
    ];
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
    @main
    (Λ,Λ->IdEdge), (Λ,v1->NumEdge [(39, 8, 31, 0, 32)]), (Λ,a->NumEdge [(31, 0, 31, 0, 32)]), (out,v1->NumEdge [(49, 18, 31, 0, 32)]), (out,out->IdEdge), (out,b->NumEdge [(31, 0, 31, 0, 32)])
    v1, out, a, b
    |}]

let%expect_test "test5_basic_load_store" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
prog entry @main;

var $mem: (bv64 -> bv8);
var $i: bv64;

proc @main() -> (out:bv64)
[
  block %entry [
    $i := 0x0:bv64;
    goto(%loop);
  ];
  block %loop [
    goto(%loop_body, %loop_exit);
  ];
  block %loop_body [
    guard (bvult($i, 0xa:bv64));
    $mem := store le $mem 0x100:bv64 $i 64;
    $i := bvadd($i, 0x1:bv64);
    goto(%loop);
  ];
  block %loop_exit [
    guard (bvuge($i, 0xa:bv64));
    var x:bv64 := load le $mem 0x100:bv64 64;
    assert bvule($i, 0x14:bv64);
    return (x);
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
    @main
    (Λ,Λ->IdEdge), (Λ,$i->NumEdge [(63, 0, 63, 0, 64)]), (out,out->IdEdge), (out,x->NumEdge [(63, 0, 63, 0, 64)])
    out, x, $i
    |}]

let%expect_test "test6_extract_out_of_bounds_after_shift" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
prog entry @main;

proc @main() -> (one_liner:bv64, multi_liner:bv64)
[
    block %main_entry [
      var v1:bv64 := 99:bv64;

      var a:bv64 := extract(5,0,(bvashr(extract(11,6,v1), 2:bv64)));

      var b:bv64 := bvashr(extract(11,6,v1), 2:bv64);
      return (a,b);
    ];
];
    |}
 (* var mid:bv5 := extract(11,6,v1);
      var b:bv64 := extract(1,0,bvshl(mid, 2:bv64)); *)
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
    @main
    (Λ,Λ->IdEdge), (one_liner,v1->NumEdge [(12, 8, 4, 0, 5)]), (one_liner,a->NumEdge [(63, 0, 63, 0, 64)]), (one_liner,one_liner->IdEdge), (multi_liner,v1->NumEdge [(10, 8, 4, 0, 5)]), (multi_liner,b->NumEdge [(63, 0, 63, 0, 64)]), (multi_liner,multi_liner->IdEdge)
    v1, a, b, one_liner, multi_liner
    |}]

let%expect_test "test7_shifts" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
prog entry @main;

proc @main() -> (out1:bv64, out2:bv64)
[
    block %main_entry [
      var v:bv64 := 99:bv64;

      var a:bv64 := extract(4, 0, bvshl(extract(5, 0, v), zero_extend(62, 0x3:bv2)));

      var x:bv5 := extract(5, 0, v);
      var y:bv5 := bvshl(x, 3:bv64);
      var b:bv64 := extract(4, 0, y);

      return (a,b);
    ];
];

proc @f_msb_used() -> (f_out1:bv64, f_out2:bv64)
[
    block %f_entry [
      var v:bv64 := 99:bv64;

      var c:bv64 := bvashr(v, 3:bv64);
      var d:bv32 := (bvashr(extract(32,0,v), 3:bv64));
      
      return (c,d);
    ];
];

proc @g_msb_of_extract_5_0_is_used() -> (g_out1:bv64)
[
    block %g_entry [
      var v:bv64 := 99:bv64;

      var e:bv5 := extract(5,0,(bvashr(extract(5,0,v), 300:bv64)));
      
      return (e);
    ];
];

proc @h_v_is_unused() -> (h_out1:bv64)
[
    block %h_entry [
      var v:bv64 := 99:bv64;

      var h_a:bv5 := extract(5, 0, (bvashr(bvlshr(extract(5,0,v), 1:bv64), 300:bv64)));
      var h_b:bv5 := extract(5, 0, (bvashr(bvlshr(extract(5,0,v), 300:bv64), 1:bv64)));
      assert neq(h_a, h_b);

      return (h_a);
    ];
];

proc @i_v_is_unused() -> (i_out1:bv64)
[
    block %i_entry [
      var v:bv64 := 99:bv64;

      var i_a:bv5 := extract(5, 0, bvlshr(extract(11,6,v), 20:bv64));

      return (i_a);
    ];
];

proc @j_boolean_comparison_shenanigans() -> (j_out1:bv64, j_out2:bv64)
[
    block %j_entry [
      var v:bv64 := 99:bv64;

      var j_a:bv5 := bvor(bvshl(extract(5,0,v), 3:bv64), bvlshr(extract(5,0,v), 3:bv64));
      
      var j_b:bv2 := extract(2,0,bvor(bvshl(extract(5,0,v), 3:bv64), bvlshr(extract(5,0,v), 3:bv64)));

      return (j_a, j_b);
    ];
];

proc @k() -> (out1:bv64)
[
    block %k_entry [
      var v:bv64 := 99:bv32;

      var k_a:bv32 := extract(32,0, v);

      var k_b:bv8 := extract(1,0,extract(32,31, v));

      var j:bv8 := k_a;
      var i:bv8 := k_b;

      return (k_b);
    ];
];

proc @shift() -> (left_out:bv64, right_out:bv64)
[
    block %shift_entry [
      var v1:bv64 := 999:bv64;

      var left:bv64 := bvshl(v1, 32:bv64);
      var right:bv64 := bvlshr(v1, 32:bv64);

      return (left, right);
    ];
];

proc @shift2() -> (left_out:bv64, right_out:bv64)
[
    block %shift_entry [
      var v1:bv64 := 999:bv64;

      var left:bv64 := bvlshr(bvshl(v1, 32:bv64),32:bv64);
      var right:bv64 := bvshl(bvlshr(v1, 32:bv64), 32:bv64);

      return (left, right);
    ];
];

proc @dead_bits_in_middle() -> (dbout:bv5)
[
    block %dead_bits_in_middle_entry [
      var v1:bv5 := 0x1f:bv5;
      var dbout:bv5 := extract(4,3,bvand(bvshl(3,v1), bvlshr(3,v1)));
      return;
    ];
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
    @f_msb_used
    (Λ,Λ->IdEdge), (f_out1,c->NumEdge [(63, 0, 63, 0, 64)]), (f_out1,f_out1->IdEdge), (f_out1,v->NumEdge [(63, 3, 63, 0, 64)]), (f_out2,f_out2->IdEdge), (f_out2,v->NumEdge [(31, 3, 31, 0, 32)]), (f_out2,d->NumEdge [(31, 0, 31, 0, 32)])
    c, f_out1, f_out2, v, d
    @h_v_is_unused
    (Λ,Λ->IdEdge), (Λ,h_a->NumEdge [(4, 0, 4, 0, 5)]), (Λ,h_b->NumEdge [(4, 0, 4, 0, 5)]), (h_out1,h_out1->IdEdge)
    h_out1, h_a, h_b
    @g_msb_of_extract_5_0_is_used
    (Λ,Λ->IdEdge), (g_out1,g_out1->IdEdge), (g_out1,v->NumEdge [(4, 4, 4, 4, 5)]), (g_out1,e->NumEdge [(4, 0, 4, 0, 5)])
    g_out1, v, e
    @j_boolean_comparison_shenanigans
    (Λ,Λ->IdEdge), (j_out1,j_out1->IdEdge), (j_out1,v->NumEdge [(1, 0, 4, 3, 5); (4, 3, 1, 0, 5)]), (j_out1,j_a->NumEdge [(4, 0, 4, 0, 5)]), (j_out2,j_out2->IdEdge), (j_out2,v->NumEdge [(4, 3, 1, 0, 2)]), (j_out2,j_b->NumEdge [(1, 0, 1, 0, 2)])
    j_out1, j_out2, v, j_a, j_b
    @dead_bits_in_middle
    (Λ,Λ->IdEdge), (dbout,dbout->IdEdge), (dbout,v1->NumEdge [(3, 3, 0, 0, 1)])
    dbout, v1
    @main
    (Λ,Λ->IdEdge), (out1,out1->IdEdge), (out1,a->NumEdge [(63, 0, 63, 0, 64)]), (out1,v->NumEdge [(0, 0, 3, 3, 4)]), (out2,out2->IdEdge), (out2,x->NumEdge [(1, 0, 4, 3, 5)]), (out2,y->NumEdge [(3, 0, 3, 0, 4)]), (out2,b->NumEdge [(63, 0, 63, 0, 64)]), (out2,v->NumEdge [(4, 0, 4, 0, 5)])
    out1, out2, a, x, y, b, v
    @shift2
    (Λ,Λ->IdEdge), (left_out,v1->NumEdge [(31, 0, 31, 0, 64)]), (left_out,left_out->IdEdge), (left_out,left->NumEdge [(63, 0, 63, 0, 64)]), (right_out,v1->NumEdge [(63, 32, 32, 32, 64)]), (right_out,right_out->IdEdge), (right_out,right->NumEdge [(63, 0, 63, 0, 64)])
    v1, left_out, right_out, left, right
    @i_v_is_unused
    (Λ,Λ->IdEdge), (i_out1,i_out1->IdEdge), (i_out1,i_a->NumEdge [(4, 0, 4, 0, 5)])
    i_out1, i_a
    @shift
    (Λ,Λ->IdEdge), (left_out,v1->NumEdge [(31, 0, 63, 32, 64)]), (left_out,left_out->IdEdge), (left_out,left->NumEdge [(63, 0, 63, 0, 64)]), (right_out,v1->NumEdge [(63, 32, 31, 0, 64)]), (right_out,right_out->IdEdge), (right_out,right->NumEdge [(63, 0, 63, 0, 64)])
    v1, left_out, right_out, left, right
    @k
    (Λ,Λ->IdEdge), (out1,out1->IdEdge), (out1,v->NumEdge [(31, 31, 0, 0, 1)]), (out1,k_b->NumEdge [(7, 0, 7, 0, 8)])
    out1, v, k_b
    |}]
























(*
  HighBit of { hi_lb : int ; lo_lb : int }
  extract 1 0 ((extract 5 0 v1) >> 3)
  543210
  dlllll   hi_lb, lo_lb = 4, 0
  -> >>3
  876543
  ddddll   hi_lb, lo_lb = 4, 3
  -> extract 1 0
  876543
  dddddl   hi_lb, lo_lb = (1-1)+3, 3
                        = 3, 3

  extract 3 0 (((extract 5 0) >> 3) << 2) - extract 5 0, then SHR 3, then SHL 2, then extract 3 0
  543210
  dlllll   hi_lb, lo_lb = 4, 0
  -> >> 3
  876543
  ddddll   hi_lb, lo_lb = 4, 3
  -> << 2
  654321
  ddll??   hi_lb, lo_lb = 4, 1
  -> extract 3 0
  654321
  dddl??   hi_lb, lo_lb = (3-1) + 1, 1
                        = 3, 1
  
  extract 3 0 (((extract 5 0) << 2) >> 3)
  543210
  dlllll   hi_lb, lo_lb = 4, 0
  -> << 2
543210-1-2
dlllll x x hi_lb, lo_lb = 4, -2 
  -> >> 3
  654321
  ddllll  hi_lb, lo_lb = 4, 1
  -> extract 3 0
  654321
  dddlll  hi_lb, lo_lb = (3-1) + 1, 1
                       = 3, 1
  
  extract 5 0
  43210
  lllll   (4,0,4,0)
  -> <<2
  210xx
  lllxx   (2,0,4,2)   // e_hi bounded by index range
  -> >> 3
  xxx21
  xxxll   (2,1,1,0)
  -> extract 3 0
  x21
  xll     (2,1,2,0)


  
  *)


        (* | UnaryExpr { op = `Extract (hi, lo) ; arg = (Value.HighBit { hi_lb ; lo_lb }, value) } -> 
          (Value.highbit (hi - 1 + lo_lb) (lo_lb + lo))  *)
          (* if hi < lo_lb then 'Bot' and if expr_hi > *)

      (*
      (v_hi_lb, v_lo_lb, e_hi_lb, e_lo_lb)
      extract(4, 1, bvlshr(extract(8, 3, var), 2))
      ex 8 3   (7,3,4,0)
      43210
      76543

      >>2      v_lo +2 and e_lo -2
      43210
      xx765    (7,5,2,0)
      xxlll

      ex 4 1

      210
      x76
      xll     (7,6,1,0)

      or 
      extract(4, 1, bvshl(extract(8,3,var), 2))
      ex 8 3 (7,3,4,0)
      43210
      76543

      <<2
      43210
      543xx
      lllxx   (5,3,4,2)

      ex 4 1
      210
      43x
      llx    (4,3,2,1)
------------
      extract 3 0 (((extract 5 0) << 2) >> 3)

      extract 5 0
      43210
      lllll   (4,0,4,0)
      -> <<2
      210xx                       -- extract 4 0 will return (1,0,2,1)
      lllxx   (2,0,4,2)   // e_hi bounded by index range
      -> >> 3
      xxx21
      xxxll   (2,1,1,0)
      -> extract 3 0
      x21
      xll     (2,1,2,0)

      43210
      xxx2x
      xxxlx  (2,2,1,1)
      -> extract 3 0
      210
      x2x
      xlx   (2,2,1,1)

          | hi - 1 <= e_hi_lb && lo >= e_lo_lb -> new_v_hi_lb = hi - 1 + old_v_lo_lb, new_v_lo_lb = old_v_lo_lb + lo, new_e_hi_lb = hi - lo - 1, new_e_lo_lb = 0  // All within range
          | hi - 1 <= e_hi_lb && lo < e_lo_lb  -> new_v_hi_lb = hi - 1 + old_v_lo_lb - old_e_lo_lb, new_v_lo_lb = old_v_lo, new_e_hi_lb = hi - lo - 1, new_e_lo_lb = old_e_lo_lb - lo // lo outside of range
          | hi - 1 >  e_hi_lb && lo >= e_lo_lb -> new_v_hi_lb = old_v_hi_lb, new_v_lo_lb = old_v_lo_lb + lo - old_e_lo_lb, new_e_hi_lb = old_e_hi_lb - lo, new_e_lo_lb = 0 // hi outside of range
          | hi - 1 >  e_hi_lb && lo < e_lo_lb  -> new_v_hi_lb = old_v_hi_lb, new_v_lo_lb = old_v_lo_lb, new_e_hi_lb = old_e_hi_lb - lo, new_e_lo_lb = old_e_lo_lb - lo // Both out of range
          | else Value.bottom
      *)
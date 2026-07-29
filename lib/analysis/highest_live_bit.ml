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
  KNOWN ISSUE: The Lambda case in transfer_call is not triggering
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
        Iter.singleton (Lambda, TopEdge)
    | Label v ->
        StringMap.to_iter call
        |> Iter.flat_map (fun (s, e) -> Expr.BasilExpr.free_vars_iter e)
        |> Iter.map (fun v -> (Label v, TopEdge))
  (* We could use eval_wrt_var here, but it would be slower for the same effect *)

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

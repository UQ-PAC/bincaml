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

  (* Highest bit is inclusive, i.e. 63 means bits [..63] are used *)
  type t =
    | Bot
    | HighBits of int
        (** [Highbits n] : the expression accesses at most n bits of the
            variable *)
    | LowContiguous of int
        (** Contiguous least significant n bits of variable *)
    | Top
  [@@deriving eq, ord, show { with_path = false }]

  let top = Top
  let bottom = Bot
  let pretty t = Containers_pp.text (show t)
  let show = function Top -> "⊤" | Bot -> "⊥" | n -> show n

  let join a b =
    match (a, b) with
    | Top, _ | _, Top -> Top
    | Bot, a | a, Bot -> a
    | LowContiguous ha, LowContiguous hb -> LowContiguous (max ha hb)
    | HighBits ha, LowContiguous hb
    | LowContiguous ha, HighBits hb
    | HighBits ha, HighBits hb ->
        (* always join to non var since we we are always comparing two
        subexpressions with join, the result expr cannot be just a var *)
        HighBits (max ha hb)

  let leq a b =
    match (a, b) with
    | a, b when equal a b -> true
    | HighBits ha, HighBits hb
    | LowContiguous ha, HighBits hb
    | HighBits ha, LowContiguous hb
    | LowContiguous ha, LowContiguous hb ->
        (* this is funny but we just care about leq wrt the number of bits; *)
        ha <= hb
    | Bot, _ | _, Top -> true
    | _, Bot | Top, _ -> false

  let widening a b = join a b
  let narrowing a b = a

  let get_hi = function
    | HighBits i -> Some i
    | LowContiguous i -> Some i
    | _ -> None
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
    | NumEdge v, _ -> Value.LowContiguous v

  module Extract = struct
    (** Collect the maximum width of an access to the variable in an expression
    *)
    let extract_alg readv (e : (Value.t * _) Expr.BasilExpr.abstract_expr) =
      let open Expr.AbstractExpr in
      match e with
      | RVar { id } -> readv id
      | UnaryExpr { op = `Extract (hi, lo); arg = arg, _ } -> (
          match arg with
          | LowContiguous b ->
              if lo = 0 then
                (* we can stack extracts if they all start at zero *)
                Value.LowContiguous (hi - 1)
              else Value.HighBits (hi - 1)
          | i -> i)
      | BinaryExpr
          { op = `BVSHL; arg1 = arg1, _; arg2 = _, Some (`Bitvector bv) } -> (
          let sz = Bitvec.size bv in
          (* should be safe to conv int because shift values are small *)
          let shift = Bitvec.to_signed_bigint bv |> Z.to_int in
          match arg1 with
          (* if we shift off the msb  *)
          | LowContiguous hi -> HighBits (max 0 (hi + shift - sz))
          | i -> i)
      | BinaryExpr
          { op = `BVLSHR; arg1 = arg1, _; arg2 = _, Some (`Bitvector bv) } -> (
          (* should be safe to conv int because shift values are small *)
          let shift = Bitvec.to_signed_bigint bv |> Z.to_int in
          match arg1 with
          | LowContiguous hi when hi >= shift -> HighBits 0
          | i -> i)
      | e ->
          Abstract_expr.AbstractExpr.fold Value.join Value.bottom
            (Abstract_expr.AbstractExpr.map fst e)

    (* Converts HighestLiveBitLattice t to IDESSI_LB t*)
    let extract_expr readv e =
      match
        Expr.BasilExpr.zygo_l Expr_eval.eval_expr_alg (extract_alg readv) e
      with
      | Bot -> BotEdge
      | Top -> TopEdge
      | HighBits v -> NumEdge v
      | LowContiguous v -> NumEdge v

    (* find number of live bits for a single
    variable [var] in an expression ; read function returns the width for
    this variable, and bot for everything else*)
    let eval_wrt_var var expr =
      let readv v =
        (* look at the one var we care about; everything else is bot  *)
        if Var.equal v var then
          match Types.bit_width (Var.typ var) with
          | Some w -> Value.LowContiguous (w - 1)
          | None -> Value.top
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

  let transfer_call call_info arg_info d =
    match d with
    | Lambda -> Iter.singleton (Lambda, IdEdge)
    | Label v ->
        StringMap.to_iter call_info
        |> Iter.filter (fun (s, e) -> VarSet.mem v (Expr.BasilExpr.free_vars e))
        |> Iter.map (fun (s, e) ->
            let v' = StringMap.find s arg_info in
            (Label v', Extract.eval_wrt_var v e))
  (*| Label v ->
        StringMap.to_iter call
        |> Iter.flat_map (fun (s, e) -> Expr.BasilExpr.free_vars_iter e)
        |> Iter.map (fun v -> (Label v, TopEdge))*)
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
        | _ ->
            IDESSI_LB.Extract.eval_stmt stmt
            |> Iter.map (fun (rhs_var, edge) -> (Label rhs_var, edge)))

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

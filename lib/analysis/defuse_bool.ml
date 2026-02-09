(** Example minimal static analysis on ssa dataflow graph graph for truthiness
*)

open Bincaml_util.Common

module IsZeroLattice = struct
  let name = "isZero"

  type t = Top | Zero | NonZero | Bot
  [@@deriving ord, eq, show { with_path = false }]

  let bottom = Bot
  let pretty t = Containers_pp.text (show t)

  let join a b =
    match (a, b) with
    | Top, _ -> Top
    | _, Top -> Top
    | a, b when equal a b -> a
    | a, Bot -> a
    | Bot, a -> a
    | _ -> Top

  let widening a b = join a b
end

module IsZeroValueAbstraction = struct
  include IsZeroLattice

  let eval_const (op : Lang.Ops.AllOps.const) =
    match op with
    | `Bool true -> NonZero
    | `Bool false -> Zero
    | `Integer i -> if Z.equal Z.zero i then Zero else NonZero
    | `Bitvector i ->
        if Bitvec.size i = 0 then Top
        else if Z.equal Z.zero (Bitvec.value i) then Zero
        else NonZero

  let eval_unop (op : Lang.Ops.AllOps.unary) a =
    match op with
    | `BVNEG -> Top
    | `BoolNOT -> ( match a with Zero -> NonZero | NonZero -> Zero | o -> o)
    | `BOOLTOBV1 -> a
    | `INTNEG -> Top
    | `Extract _ -> ( match a with Zero -> Zero | _ -> Top)
    | `SignExtend _ -> ( match a with Zero -> Zero | _ -> Top)
    | `BVNOT -> ( match a with Zero -> NonZero | _ -> Top)
    | `ZeroExtend size -> a
    | `Old -> Top
    | `Exists -> Top
    | `Forall -> Top

  let eval_binop (op : Lang.Ops.AllOps.binary) a b =
    match (op, a, b) with
    | `BVSREM, _, _ -> Top
    | `BVSDIV, _, _ -> Top
    | `BVADD, Zero, Zero -> Zero
    | `BVADD, _, _ -> Top
    | `NEQ, Zero, Zero -> Zero
    | `NEQ, _, _ -> Top
    | `BVASHR, _, _ -> Top
    | `BVMUL, Zero, Zero -> Zero
    | `BVMUL, _, _ -> Top
    | `BVSHL, _, _ -> Top
    | `INTDIV, _, _ -> Top
    | `EQ, Zero, Zero -> NonZero
    | `EQ, _, _ -> Top
    | `INTADD, _, _ -> Top
    | `BVNAND, _, _ -> Top
    | `BVSLE, _, _ -> Top
    | `BVUREM, _, _ -> Top
    | `BVXOR, _, _ -> Top
    | `BVOR, Zero, Zero -> Zero
    | `BVOR, NonZero, _ -> NonZero
    | `BVOR, _, NonZero -> NonZero
    | `BVOR, _, _ -> Top
    | `BVAND, _, Zero -> Zero
    | `BVAND, Zero, _ -> Zero
    | `BVAND, _, _ -> Top
    | `BVSUB, _, _ -> Top
    | `BVUDIV, _, _ -> Top
    | `BVLSHR, _, _ -> Top
    | `INTMOD, _, _ -> Top
    | `INTMUL, _, _ -> Top
    | `BVSMOD, _, _ -> Top
    | `IMPLIES, _, _ -> Top
    | `INTLT, _, _ -> Top
    | `BVULT, _, _ -> Top
    | `INTLE, _, _ -> Top
    | `BVULE, _, _ -> Top
    | `INTSUB, Zero, Zero -> Zero
    | `INTSUB, _, _ -> Top
    | `BVSLT, Zero, Zero -> Zero
    | `BVSLT, _, _ -> Top

  let eval_intrin (op : Lang.Ops.AllOps.intrin) (args : t list) =
    match op with
    | `BVADD -> List.fold_left (eval_binop `BVADD) Bot args
    | `BVOR -> List.fold_left (eval_binop `BVOR) Bot args
    | `BVXOR -> List.fold_left (eval_binop `BVXOR) Bot args
    | `BVAND -> List.fold_left (eval_binop `BVAND) Bot args
    | `BVConcat -> List.fold_left join Bot args
    | `OR ->
        (* boolean or *)
        if List.exists (equal NonZero) args then NonZero
        else if List.for_all (equal Zero) args then Zero
        else if List.for_all (equal Bot) args then Bot
        else Top
    | `AND ->
        (* boolean and*)
        if List.exists (equal Zero) args then Zero
        else if List.for_all (equal NonZero) args then NonZero
        else if List.for_all (equal Bot) args then Bot
        else Top
end

module IsZeroValueAbstractionUntyped = struct
  include IsZeroValueAbstraction
  module E = Lang.Expr.BasilExpr

  (*let eval_const op (rt : ty) = eval_const op
  let eval_unop op arg rt = eval_unop op (fst arg)
  let eval_binop op arg1 arg2 rt = eval_binop op (fst arg1) (fst arg2)
  let eval_intrin op args rt = eval_intrin op (List.map fst args)
  *)
end

module IsZeroValueAbstractionBasil = struct
  include
    Intra_analysis.ValueAbstractionIgnoringTypes (IsZeroValueAbstractionUntyped)

  module E = Lang.Expr.BasilExpr

  let top = IsZeroLattice.Top
end

include Dataflow_graph.EasyForwardAnalysisPack (IsZeroValueAbstractionBasil)

(* Combines Known bit analysis and wrapped interval analysis to get more
    precise values. 
*)

open Bincaml_util.Common
open Bitvec
open Wrapped_intervals
open WrappedIntervalsLattice
open Known_bits
open KnownBitsLattice

open struct
  module WIL = WrappedIntervalsLattice
  module WIVA = WrappedIntervalsValueAbstraction
  module KBL = KnownBitsLattice
  module KBVA = KnownBitsValueAbstraction
end

module TnumWintReducedProductLattice = struct
  let name = "tnumWintReduceProduct"

  type t = { tnum : KBL.t; wint : WIL.t } [@@deriving ord, eq]

  let bottom = { tnum = KBL.bottom; wint = WIL.bottom }
  let top = { tnum = KBL.top; wint = WIL.top }
  let show { tnum; wint } = "(" ^ KBL.show tnum ^ ", " ^ WIL.show wint ^ ")"
  let pretty t = Containers_pp.text (show t)

  let tnum_to_wint tnum =
    match tnum with
    | Bot -> WIL.Bot
    | Top -> WIL.Top
    | TNum { value = v; mask = m } ->
        let lower = bitand v (bitnot m) in
        let upper = bitor v m in
        interval lower upper

  let wint_to_tnum wint =
    match wint with
    | WIL.Bot -> Bot
    | Top -> Top
    | Interval { lower; upper } ->
        let w = size lower in
        if WIL.leq (sp ~width:w) wint then
          TNum { value = zero ~size:w; mask = ones ~size:w }
        else
          let diff = bitxor lower upper in
          let k = Z.numbits @@ to_unsigned_bigint diff in
          if k = 0 then known lower
          else
            let mask = concat (zero ~size:(w - k)) (ones ~size:k) in
            let value = bitand lower @@ bitnot mask in
            tnum value mask

  let leq s t = KBL.leq s.tnum t.tnum && WIL.leq s.wint t.wint

  let reduce_wint wint tnum =
    let mssb x =
      if is_zero x then x
      else
        let w = size x in
        let k = (Z.numbits @@ to_unsigned_bigint x) - 1 in
        create ~size:w @@ Z.(pow (of_int 2) k)
    in
    let lssb x = bitand x (bitnot x) in
    let above p = bitnot (bitor p (sub p (of_int 1 ~size:(size p)))) in
    let below p = sub p (of_int 1 ~size:(size p)) in
    let mergeon a b p = bitor (bitand a (above p)) (bitand b (below p)) in
    let refine_lower_bound a tnum =
      match (tnum, tnum_to_wint tnum) with
      | TNum { value = v; mask = m }, Interval { lower = tmin } ->
          let diff = mssb (bitand (bitxor a v) (bitnot m)) in
          if is_zero diff then a
          else if is_zero (bitand a diff) then bitor diff (mergeon a tmin diff)
          else
            let carry = lssb (bitand (bitand (above diff) (bitnot a)) m) in
            bitor carry (mergeon a tmin carry)
      | _ -> a
    in
    let refine_upper_bound b tnum =
      match (tnum, tnum_to_wint tnum) with
      | TNum { value = v; mask = m }, Interval { upper = tmax } ->
          let diff = mssb (bitand (bitxor b v) (bitnot m)) in
          if is_zero diff then b
          else if not (is_zero (bitand b diff)) then mergeon b tmax diff
          else
            let borrow = lssb (bitand (bitand (above diff) b) m) in
            mergeon b tmax borrow
      | _ -> b
    in
    match tnum with
    | Bot | Top -> wint
    | TNum _ -> (
        match wint with
        | WIL.Bot -> wint
        | Top -> tnum_to_wint tnum
        | Interval { lower; upper } ->
            let refined_lower = refine_lower_bound lower tnum in
            let refined_upper = refine_upper_bound upper tnum in
            interval refined_lower refined_upper)

  let reduce_tnum wint tnum =
    let tnumed_wint = wint_to_tnum wint in
    match (tnumed_wint, tnum) with
    | Bot, _ | _, Bot -> KnownBitsLattice.Bot
    | Top, t | t, Top -> t
    | TNum { value = av; mask = am }, TNum { value = bv; mask = bm } ->
        let int_m = bitnot @@ bitor am bm in
        if is_nonzero (bitxor (bitand av int_m) (bitand bv int_m)) then Bot
        else
          let m = bitand am bm in
          let v = bitand (bitor av bv) (bitnot m) in
          TNum { value = v; mask = m }

  let reduce { wint; tnum } =
    let wint' = reduce_wint wint tnum in
    let tnum' = reduce_tnum wint' tnum in
    { wint = wint'; tnum = tnum' }

  let join s t =
    reduce { tnum = KBL.join s.tnum t.tnum; wint = WIL.join s.wint t.wint }

  let widening s t =
    { tnum = KBL.widening s.tnum t.tnum; wint = WIL.widening s.wint t.wint }
end

module TnumWintValueAbstraction = struct
  include TnumWintReducedProductLattice

  let eval_const (op : Lang.Ops.AllOps.const) rt =
    let tnum = KBVA.eval_const op rt in
    let wint = WIVA.eval_const op rt in
    { tnum; wint }

  let eval_unop (op : Lang.Ops.AllOps.unary) (a, ta) rt =
    let tnum = KBVA.eval_unop op (a.tnum, ta) rt in
    let wint = WIVA.eval_unop op (a.wint, ta) rt in
    reduce { tnum; wint }

  let eval_binop (op : Lang.Ops.AllOps.binary) (a, ta) (b, tb) rt =
    let tnum = KBVA.eval_binop op (a.tnum, ta) (b.tnum, tb) rt in
    let wint = WIVA.eval_binop op (a.wint, ta) (b.wint, tb) rt in
    reduce { tnum; wint }

  let eval_intrin (op : Lang.Ops.AllOps.intrin) (args : (t * Types.t) list) rt =
    let tnum_args = List.map (fun (arg, ty) -> (arg.tnum, ty)) args in
    let wint_args = List.map (fun (arg, ty) -> (arg.wint, ty)) args in

    let tnum = KBVA.eval_intrin op tnum_args rt in
    let wint = WIVA.eval_intrin op wint_args rt in
    reduce { tnum; wint }
end

module TnumWintReducedProductValueAbstractionBasil = struct
  include TnumWintValueAbstraction
  module E = Lang.Expr.BasilExpr
end

module StateAbstraction =
  Intra_analysis.MapState (TnumWintReducedProductValueAbstractionBasil)

module Eval =
  Intra_analysis.EvalStmt
    (TnumWintReducedProductValueAbstractionBasil)
    (StateAbstraction)

module Domain = struct
  include StateAbstraction

  let top_val = TnumWintReducedProductLattice.top

  let init p =
    let vs = Lang.Procedure.formal_in_params p |> StringMap.values in
    vs
    |> Iter.map (fun v -> (v, top_val))
    |> Iter.fold (fun m (v, d) -> update v d m) bottom

  let transfer dom stmt =
    let evald_stmt = Eval.stmt_eval_fwd stmt dom in
    let evald_stmt_wint =
      Lang.Stmt.map ~f_lvar:id ~f_rvar:id
        ~f_expr:(fun (e : TnumWintReducedProductLattice.t) -> e.wint)
        evald_stmt
    in
    let evald_stmt_tnum =
      Lang.Stmt.map ~f_lvar:id ~f_rvar:id
        ~f_expr:(fun (e : TnumWintReducedProductLattice.t) -> e.tnum)
        evald_stmt
    in
    let read_wint v = (read v dom).wint in
    let tnum' = Known_bits.Domain.tf evald_stmt_tnum in
    let wint' =
      Wrapped_intervals.Domain.tf ~read:read_wint stmt evald_stmt_wint
    in
    let updated_tnum =
      Iter.fold
        (fun acc (k, v) -> update k { tnum = v; wint = (read k dom).wint } acc)
        dom tnum'
    in
    let dom =
      Iter.fold
        (fun acc (k, v) ->
          update k { tnum = (read k updated_tnum).tnum; wint = v } acc)
        updated_tnum wint'
    in
    match stmt with
    | Lang.Stmt.Instr_Assert _ | Lang.Stmt.Instr_Assume _ ->
        Iter.append (Iter.map fst tnum') (Iter.map fst wint')
        |> Iter.uniq ~eq:Var.equal
        |> Iter.fold
             (fun acc k ->
               update k (TnumWintReducedProductLattice.reduce @@ read k acc) acc)
             dom
    | _ -> dom
end

module Analysis = Intra_analysis.Forwards (Domain)

let analyse (p : Lang.Program.proc) =
  Analysis.analyse ~widening_set:Graph.ChaoticIteration.FromWto
    ~widening_delay:50 p

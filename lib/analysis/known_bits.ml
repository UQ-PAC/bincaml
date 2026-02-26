(** The tnum representation (value-mask pairs for tracking bitwise uncertainty)
    is based on the tristate numbers domain from the Linux kernel's eBPF
    verifier, as described in: https://arxiv.org/pdf/2105.05398 *)

open Bincaml_util.Common
open Bitvec

module KnownBitsLattice = struct
  let name = "tnum"

  type t = Bot | TNum of { value : Bitvec.t; mask : Bitvec.t } | Top
  [@@deriving ord, eq]

  let tnum v m =
    assert (is_zero (bitand v m));
    size_is_equal v m;
    TNum { value = v; mask = m }

  let known v = tnum v (zero ~size:(size v))
  let unknown ~width = tnum (zero ~size:width) (ones ~size:width)

  let show = function
    | Top -> "⊤"
    | Bot -> "⊥"
    | TNum { value = v; mask = m } ->
        let tnum_size = size v in
        let rec result acc i v m =
          if i >= tnum_size then acc
          else
            let one = of_int ~size:(size v) 1 in
            let mask_bit = is_nonzero @@ bitand m one in
            let value_bit = is_nonzero @@ bitand v one in

            let bit_str =
              if mask_bit then "μ" else if value_bit then "1" else "0"
            in

            let new_acc = bit_str ^ acc in
            result new_acc (i + 1) (lshr v one) (lshr m one)
        in
        result "" 0 v m

  let leq a b =
    if equal a b then true
    else
      match (a, b) with
      | TNum { value = av; mask = am }, TNum { value = bv; mask = bm } ->
          let shared_known = bitor am (bitnot bm) in
          (is_zero @@ bitand am (bitnot bm))
          && Bitvec.equal (bitand av shared_known) (bitand bv shared_known)
      | Bot, _ | _, Top -> true
      | _, Bot | Top, _ -> false

  let bottom = Bot
  let top = Top
  let pretty t = Containers_pp.text (show t)

  let join a b =
    match (a, b) with
    | Top, _ | _, Top -> Top
    | Bot, x | x, Bot -> x
    | TNum { value = av; mask = am }, TNum { value = bv; mask = bm } ->
        let mask = bitxor av bv |> bitor am |> bitor bm in
        let value = bitnot mask |> bitand @@ bitand av bv in
        tnum value mask

  let widening a b = join a b
end

module KnownBitsOps = struct
  include KnownBitsLattice

  let bind1 f a =
    match a with TNum { value; mask } -> f (value, mask) | _ -> a

  let bind2 f a b =
    match (a, b) with
    | Bot, _ | _, Bot -> Bot
    | Top, _ | _, Top -> Top
    | TNum { value = av; mask = am }, TNum { value = bv; mask = bm } ->
        f (av, am) (bv, bm)

  let tnum_zero_extend k =
    bind1 (fun (v, m) ->
        tnum (zero_extend ~extension:k v) (zero_extend ~extension:k m))

  let tnum_sign_extend k =
    bind1 (fun (v, m) ->
        tnum (sign_extend ~extension:k v) (sign_extend ~extension:k m))

  let tnum_extract (hi, lo) =
    bind1 (fun (v, m) -> tnum (extract ~hi ~lo v) (extract ~hi ~lo m))

  let tnum_bitnot = bind1 (fun (v, m) -> tnum (bitnot @@ bitor v m) m)

  let tnum_bitand =
    bind2 (fun (av, am) (bv, bm) ->
        let v = bitand av bv in
        let alpha = bitor av am in
        let beta = bitor bv bm in
        let m = bitand (bitnot v) @@ bitand alpha beta in
        tnum v m)

  let tnum_bitor =
    bind2 (fun (av, am) (bv, bm) ->
        let v = bitor av bv in
        let m = bitand (bitor am bm) (bitnot v) in
        tnum v m)

  let tnum_bitxor =
    bind2 (fun (av, am) (bv, bm) ->
        let v = bitand (bitxor av bv) (bitnot @@ bitor am bm) in
        tnum v (bitor am bm))

  let tnum_shl =
    bind2 (fun (av, am) (bv, bm) ->
        if is_nonzero bm then unknown ~width:(size av)
        else tnum (shl av bv) (shl am bv))

  let tnum_lshr =
    bind2 (fun (av, am) (bv, bm) ->
        if is_nonzero bm then unknown ~width:(size av)
        else tnum (lshr av bv) (lshr am bv))

  let tnum_ashr =
    bind2 (fun (av, am) (bv, bm) ->
        if is_nonzero bm then unknown ~width:(size av)
        else tnum (ashr av bv) (ashr am bv))

  let tnum_add =
    bind2 (fun (av, am) (bv, bm) ->
        let sm = add am bm in
        let sv = add av bv in
        let sigma = add sv sm in
        let chi = bitxor sigma sv in
        let mu = bitor chi (bitor am bm) in
        tnum (bitand sv (bitnot mu)) mu)

  let tnum_sub =
    bind2 (fun (av, am) (bv, bm) ->
        let dv = sub av bv in
        let alpha = add dv am in
        let beta = sub dv bm in
        let xi = bitxor alpha beta in
        let last = bitor xi (bitor am bm) in
        tnum (bitand dv (bitnot last)) last)

  let tnum_neg =
    bind1 (fun (v, m) ->
        let zero = zero ~size:(size v) in
        tnum_sub (known zero) (tnum v m))

  (* This implementation is based on the soundness reasoning given in https://arxiv.org/pdf/2105.05398.
     The value-mask decomposition separates certain and uncertain bit contributions,
     using tnum_add and join operations to compute the final result recursively.
     The paper contrasts multiple algorithms; the final implementation in the kernel differs slightly.

     At each step, we take the LSB of a and multiply it by b, adding the result to the accumulator:
       - If LSB(a) is a known 0: keep the current accumulator
       - If LSB(a) is a known 1: add b to the current accumulator
       - If LSB(a) is unknown: join the previous and sum of previous acc and tnum b

     We iterate through the bits to build the certain-bit product incrementally
     via recursive additions and joins. An early termination condition fires when
     (is_zero @@ bitor av am); at each stage the arguments are shifted to compute
     each step of the multiplication process.

     The OCaml implementation closely follows the kernel implementation as of February 2026:
     https://github.com/torvalds/linux/blob/master/kernel/bpf/tnum.c
     It has been adapted to be easier to reason about in a functional context.
  *)

  let tnum_mul =
    bind2 (fun (av, am) (bv, bm) ->
        let t_zero = known (of_int ~size:(size av) 0) in
        let one = of_int ~size:(size av) 1 in
        let rec tnum_mul_aux acc a b =
          let av, am = a in
          let bv, bm = b in

          if is_zero @@ bitor av am then acc
          else
            let acc' =
              if is_nonzero (bitand av one) then tnum_add acc (tnum bv bm)
              else if is_nonzero (bitand am one) then
                join acc (tnum_add acc (tnum bv bm))
              else acc
            in
            let a_next = tnum_lshr (tnum av am) (known one) in
            let b_next = tnum_shl (tnum bv bm) (known one) in
            bind2 (tnum_mul_aux acc') a_next b_next
        in
        tnum_mul_aux t_zero (av, am) (bv, bm))

  let tnum_concat a b =
    match (a, b) with
    | Bot, t | t, Bot -> t
    | Top, _ | _, Top -> Top
    | TNum { value = av; mask = am }, TNum { value = bv; mask = bm } ->
        tnum (concat av bv) (concat am bm)
end

module KnownBitsValueAbstraction = struct
  include KnownBitsOps

  let eval_const (op : Lang.Ops.AllOps.const) _ =
    match op with
    | `Bitvector a -> known a
    | `Bool true -> known @@ ones ~size:1
    | `Bool false -> known @@ zero ~size:1
    | _ -> Top

  let eval_unop (op : Lang.Ops.AllOps.unary) (a, _) rt =
    match op with
    | `BVNOT -> tnum_bitnot a
    | `ZeroExtend k -> tnum_zero_extend k a
    | `SignExtend k -> tnum_sign_extend k a
    | `Extract (hi, lo) -> tnum_extract (hi, lo) a
    | `BVNEG -> tnum_neg a
    | _ -> ( match rt with Types.Bitvector width -> unknown ~width | _ -> Top)

  let eval_binop (op : Lang.Ops.AllOps.binary) (a, _) (b, _) rt =
    match op with
    | `BVADD -> tnum_add a b
    | `BVSUB -> tnum_sub a b
    | `BVAND -> tnum_bitand a b
    | `BVNAND -> tnum_bitnot (tnum_bitand a b)
    | `BVOR -> tnum_bitor a b
    | `BVXOR -> tnum_bitxor a b
    | `BVSHL -> tnum_shl a b
    | `BVLSHR -> tnum_lshr a b
    | `BVASHR -> tnum_ashr a b
    | `BVMUL -> tnum_mul a b
    | _ -> ( match rt with Types.Bitvector width -> unknown ~width | _ -> Top)

  let eval_intrin (op : Lang.Ops.AllOps.intrin) (args : (t * Types.t) list) rt =
    let op a b =
      match op with
      | `BVADD -> (eval_binop `BVADD a b rt, rt)
      | `BVOR -> (eval_binop `BVOR a b rt, rt)
      | `BVXOR -> (eval_binop `BVXOR a b rt, rt)
      | `BVAND -> (eval_binop `BVAND a b rt, rt)
      | `BVConcat -> (tnum_concat (fst a) (fst b), rt)
      | _ -> (
          match rt with
          | Types.Bitvector width -> (unknown ~width, rt)
          | _ -> (Top, rt))
    in
    match args with
    | h :: b :: tl -> fst @@ List.fold_left op (op h b) tl
    | _ -> failwith "operators must have two operands"
end

module KnownValueAbstractionBasil = struct
  include KnownBitsValueAbstraction
  module E = Lang.Expr.BasilExpr
end

module StateAbstraction = Intra_analysis.MapState (KnownValueAbstractionBasil)

module Eval =
  Intra_analysis.EvalStmt (KnownValueAbstractionBasil) (StateAbstraction)

module Domain = struct
  let top_val = KnownBitsLattice.top

  include StateAbstraction

  let init p =
    let vs = Lang.Procedure.formal_in_params p |> StringMap.values in
    vs
    |> Iter.map (fun v -> (v, top_val))
    |> Iter.fold (fun m (v, d) -> update v d m) bottom

  let tf evald_stmt =
    match evald_stmt with
    | Lang.Stmt.Instr_Assign ls -> List.to_iter ls
    | Lang.Stmt.Instr_Assert _ -> Iter.empty
    | Lang.Stmt.Instr_Assume _ -> Iter.empty
    | Lang.Stmt.Instr_Load { lhs } -> Iter.singleton (lhs, top_val)
    | Lang.Stmt.Instr_Store { lhs } -> Iter.singleton (lhs, top_val)
    | Lang.Stmt.Instr_IntrinCall { lhs } ->
        StringMap.values lhs |> Iter.map (fun v -> (v, top_val))
    | Lang.Stmt.Instr_Call { lhs } ->
        StringMap.values lhs |> Iter.map (fun v -> (v, top_val))
    | Lang.Stmt.Instr_IndirectCall _ -> Iter.empty

  let transfer dom stmt =
    let updates = tf @@ Eval.stmt_eval_fwd stmt dom in
    Iter.fold (fun a (k, v) -> update k v a) dom updates
end

module Analysis = Dataflow_graph.AnalysisFwd (Domain)

let analyse (p : Lang.Program.proc) =
  let g = Dataflow_graph.create p in
  Analysis.analyse
    ~widen_set:(Graph.ChaoticIteration.Predicate (fun _ -> false))
    ~delay_widen:0 g

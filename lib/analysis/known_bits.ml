(** The tnum representation (value-mask pairs for tracking bitwise uncertainty)
    is based on the tristate numbers domain from the Linux kernel's eBPF
    verifier, as described in: https://arxiv.org/pdf/2105.05398 *)

open Bincaml_util.Common
open Bitvec

module IsKnownLattice = struct
  let name = "tnum"

  type t = Bot | TNum of { value : Bitvec.t; mask : Bitvec.t } | Top
  [@@deriving ord, eq]

  let tnum v m =
    assert (is_zero (bitand v m));
    size_is_equal v m;
    TNum { value = v; mask = m }

  let known v = tnum v (zero ~size:(size v))

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
          if
            (is_zero @@ bitand am (bitnot bm))
            && Bitvec.equal (bitand av (bitnot am)) (bitand bv (bitnot bm))
          then true
          else false
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

module IsKnownBitsOps = struct
  include IsKnownLattice

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
        tnum (sign_extend ~extension:k v) (zero_extend ~extension:k m))

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

  let tnum_shl =
    bind2 (fun (av, am) (bv, bm) ->
        if is_nonzero bm then Top else tnum (shl av bv) (shl am bv))

  let tnum_lshr =
    bind2 (fun (av, am) (bv, bm) ->
        if is_nonzero bm then Top else tnum (lshr av bv) (lshr am bv))

  let tnum_ashr =
    bind2 (fun (av, am) (bv, bm) ->
        if is_nonzero bm then Top else tnum (ashr av bv) (ashr am bv))

  (* This implementation resembles Listing 3 (our_mul_simplified) from https://arxiv.org/pdf/2105.05398.
   The value-mask decomposition (accv, accm) allows separating certain and 
   uncertain bit contributions, postponing the addition of uncertain bits 
   until the final step, making it easier to reason about in a functional context.
   
   The key optimization from Listing 4 (our_mul) that is incorporated here is
   the early termination condition: if (is_zero @@ bitor av am), which checks 
   if both av and am are zero. This stops iterating when there are no more bits 
   to process in P, rather than always running for exactly bitwidth iterations 
   like Listing 3.
   
   Unlike Listing 4, the OCaml implementation avoids the direct multiplication 
   optimization (ACCv := P.v * Q.v) and instead builds the certain-bit product 
   incrementally through recursive additions. *)
  let tnum_mul =
    bind2 (fun (av, am) (bv, bm) ->
        let t_zero = known (of_int ~size:(size av) 0) in
        let one = of_int ~size:(size av) 1 in

        let rec tnum_mul_aux accv accm a b =
          let av, am = a in
          let bv, bm = b in

          if is_zero @@ bitor av am then tnum_add accv accm
          else
            let a_lsb = bitand av one in
            let a_mask_lsb = bitand am one in
            let b_tnum = tnum bv bm in
            let recurse accv accm =
              let a_next =
                bind1
                  (fun (v, m) -> tnum (lshr v one) (lshr m one))
                  (tnum av am)
              in
              let b_next =
                bind1 (fun (v, m) -> tnum (shl v one) (shl m one)) b_tnum
              in
              bind2 (tnum_mul_aux accv accm) a_next b_next
            in

            if is_nonzero a_lsb then
              let accv' = tnum_add accv (known bv) in
              recurse accv' accm
            else if is_nonzero a_mask_lsb then
              let accm' = tnum_add accm (tnum (of_int ~size:(size bm) 0) bm) in
              recurse accv accm'
            else recurse accv accm
        in

        tnum_mul_aux t_zero t_zero (av, am) (bv, bm))

  let tnum_concat a b =
    match (a, b) with
    | Bot, t | t, Bot -> t
    | Top, _ | _, Top -> Top
    | TNum { value = av; mask = am }, TNum { value = bv; mask = bm } ->
        tnum (concat av bv) (concat am bm)
end

module IsKnownBitsValueAbstraction = struct
  include IsKnownBitsOps

  let eval_const (op : Lang.Ops.AllOps.const) =
    match op with
    | `Bitvector a -> known a
    | `Bool true -> known @@ ones ~size:1
    | `Bool false -> known @@ zero ~size:1
    | _ -> Top

  let eval_unop (op : Lang.Ops.AllOps.unary) a =
    match op with
    | `BVNOT -> tnum_bitnot a
    | `ZeroExtend k -> tnum_zero_extend k a
    | `SignExtend k -> tnum_sign_extend k a
    | `Extract (hi, lo) -> tnum_extract (hi, lo) a
    | `BVNEG -> tnum_neg a
    | _ -> Top

  let eval_binop (op : Lang.Ops.AllOps.binary) a b =
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
    | _ -> Top

  let eval_intrin (op : Lang.Ops.AllOps.intrin) (args : t list) =
    let fold f args =
      List.map Option.some args
      |> List.fold_left
           (fun acc t ->
             match acc with None -> t | Some a -> Option.map (f a) t)
           None
      |> function
      | Some t -> t
      | None -> Top
    in
    let f =
      match op with
      | `BVADD -> eval_binop `BVADD
      | `BVOR -> eval_binop `BVOR
      | `BVXOR -> eval_binop `BVXOR
      | `BVAND -> eval_binop `BVAND
      | `BVConcat -> tnum_concat
      | _ -> fun _ _ -> Top
    in
    fold f args
end

module IsKnownValueAbstractionBasil = struct
  include Intra_analysis.ValueAbstractionIgnoringTypes (struct
    include IsKnownBitsValueAbstraction
    module E = Lang.Expr.BasilExpr
  end)

  let top = IsKnownLattice.Top

  module E = Lang.Expr.BasilExpr
end

include Dataflow_graph.EasyForwardAnalysisPack (IsKnownValueAbstractionBasil)

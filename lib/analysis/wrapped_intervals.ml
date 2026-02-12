(** Wrapped Intervals model a range of values on a circle, allowing both
    unsigned and signed interpretation whilst maintaining precision in
    intermediate steps.

    Based on the APLAS12 paper "Signedness-Agnostic Program Analysis: Precise
    Integer Bounds for Low-Level Code" by Navas, Schachte, Søndergaard, and
    Stuckey (doi: 10.1007/978-3-642-35182-2_9).

    Implementation in the Crab Static Analyser used as a general reference and
    for the unsigned and signed division functions.
    https://github.com/seahorn/crab/blob/418b63c66b91f04bf36ae59d5eecb936c48836ee/include/crab/domains/wrapped_interval_impl.hpp

    Algorithms for bitwise operations on unsigned intervals used for building
    signedness agnostic versions were adapted from Chapter 4.3 of Hacker's
    Delight (Second Edition) by Henry S. Warren.

    Further details about implementation can be found in
    docs/dev/wrapped_intervals.pdf *)

open Bincaml_util.Common
open Bitvec

module WrappedIntervalsLattice = struct
  let name = "wrappedIntervals"

  type l = Top | Interval of { lower : Bitvec.t; upper : Bitvec.t } | Bot
  [@@deriving eq]

  type t = { w : int option; v : l }

  let show_l l =
    match l with
    | Bot -> "⊥"
    | Top -> "⊤"
    | Interval { lower; upper } -> "⟦" ^ show lower ^ ", " ^ show upper ^ "⟧"

  let show t =
    let value = show_l t.v in
    let width = match t.w with Some w -> Int.to_string w | None -> "?" in
    value ^ ":w" ^ width

  let equal s t = equal_l s.v t.v

  let interval lower upper =
    size_is_equal lower upper;
    {
      w = Some (size lower);
      v =
        (if Bitvec.(equal lower (add upper (of_int ~size:(size upper) 1))) then
           Top
         else Interval { lower; upper });
    }

  let infer a b =
    let w =
      match (a.w, b.w) with
      | Some a, Some b ->
          assert (a = b);
          Some a
      | Some a, None | None, Some a -> Some a
      | None, None -> None
    in
    ({ a with w }, { b with w })

  let umin width = zero ~size:width
  let umax width = ones ~size:width
  let smin width = concat (ones ~size:1) (zero ~size:(width - 1))
  let smax width = zero_extend ~extension:1 (ones ~size:(width - 1))
  let sp width = interval (umax width) (umin width)
  let np width = interval (smax width) (smin width)
  let top = { w = None; v = Top }
  let bottom = { w = None; v = Bot }
  let pretty t = Containers_pp.text (show t)

  let cardinality { w; v } =
    match v with
    | Bot -> Z.of_int 0
    | Top -> (
        match w with
        | Some w -> Z.pow (Z.of_int 2) w
        | None -> failwith "Cannot determine cardinality for Top without width")
    | Interval { lower; upper } ->
        sub upper lower |> to_unsigned_bigint |> Z.add (Z.of_int 1)

  let is_singleton { w; v } =
    match v with
    | Bot | Top -> None
    | Interval { lower; upper } ->
        if Bitvec.equal lower upper then Some lower else None

  let compare_size s t = Z.compare (cardinality s) (cardinality t)

  let complement { w; v } =
    match v with
    | Bot -> { w; v = Top }
    | Top -> { w; v = Bot }
    | Interval { lower; upper } ->
        let new_lower = add upper (of_int ~size:(size upper) 1) in
        let new_upper = sub lower (of_int ~size:(size lower) 1) in
        interval new_lower new_upper

  let member t e =
    match t with
    | Bot -> false
    | Top -> true
    | Interval { lower; upper } ->
        size_is_equal lower e;
        size_is_equal upper e;
        ule (sub e lower) (sub upper lower)

  let compare_l a b =
    match (a, b) with
    | a, b when equal_l a b -> 0
    | Top, _ -> 1
    | Bot, _ -> -1
    | _, Top -> -1
    | _, Bot -> 1
    | Interval { lower = al; upper = au }, Interval { lower = bl; upper = bu }
      ->
        if
          member b al && member b au
          && ((not (member a bl)) || not (member a bu))
        then -1
        else 1

  let compare s t = compare_l s.v t.v

  let join s t =
    let s, t = infer s t in
    let { v = a; _ } = s in
    let { v = b; _ } = t in
    if compare s t <= 0 then t
    else if compare t s <= 0 then s
    else
      match (a, b) with
      | Interval { lower = al; upper = au }, Interval { lower = bl; upper = bu }
        ->
          let al_mem = member b al in
          let au_mem = member b au in
          let bl_mem = member a bl in
          let bu_mem = member a bu in
          if al_mem && au_mem && bl_mem && bu_mem then
            { w = Some (size al); v = Top }
          else if au_mem && bl_mem then interval al bu
          else if al_mem && bu_mem then interval bl au
          else
            let inner_span = cardinality (interval au bl) in
            let outer_span = cardinality (interval bu al) in
            if
              Z.lt inner_span outer_span
              || (Z.equal inner_span outer_span && ule al bl)
            then interval al bu
            else interval bl au
      | _, _ -> failwith "unreachable"

  (* Join for multiple intervals to increase precision (join is not monotone) *)
  let lub (ints : t list) =
    let bigger a b =
      match (a.v, b.v) with
      | x, y when equal_l x y -> a
      | Bot, _ -> b
      | _, Bot -> a
      | Top, _ -> a
      | _, Top -> b
      | _ -> if compare_size a b < 0 then b else a
    in
    let gap a b =
      let a, b = infer a b in
      match (a.v, b.v) with
      | Interval { upper = au; _ }, Interval { lower = bl; _ }
        when (not (member b.v au)) && not (member a.v bl) ->
          complement (interval bl au)
      | _, _ -> infer a bottom |> snd
    in
    (*
      Paper mentions last cases of join are omitted for extend, but does not specify which cases.
      In practice, just using join as is works.
    *)
    let extend = join in
    let sorted =
      List.sort
        (fun s t ->
          match (s.v, t.v) with
          | Interval { lower = al; _ }, Interval { lower = bl; _ } ->
              Bitvec.compare al bl
          | _, _ -> compare_l s.v t.v)
        ints
    in
    let f1 =
      List.fold_left
        (fun acc t ->
          match t.v with
          | Interval { lower; upper } when ule upper lower -> extend acc t
          | _ -> acc)
        bottom sorted
    in
    let g, f =
      List.fold_left
        (fun (g, f) t -> (bigger g (gap f t), extend f t))
        (bottom, f1) sorted
    in
    complement (bigger g (complement f))

  let widening s t =
    let s, t = infer s t in
    let { v = a; _ } = s in
    let { v = b; _ } = t in
    match (a, b) with
    | _, Bot -> s
    | Bot, _ -> t
    | _, Top -> t
    | Top, _ -> s
    | Interval { lower = al; upper = au }, Interval { lower = bl; upper = bu }
      ->
        size_is_equal al bl;
        size_is_equal au bu;
        let width = size al in
        if compare t s <= 0 then s
        else if Z.geq (cardinality s) (Z.pow (Z.of_int 2) width) then
          { w = Some width; v = Top }
        else
          let joined = join s t in
          if equal joined (interval al bu) then
            join joined
              (interval al
                 (sub (mul au (of_int ~size:width 2)) al
                 |> add (of_int ~size:width 1)))
          else if equal joined (interval bl au) then
            join joined
              (interval
                 (sub
                    (sub (mul al (of_int ~size:width 2)) au)
                    (of_int ~size:width 1))
                 au)
          else if member b al && member b au then
            join t
              (interval bl
                 (sub
                    (bl
                    |> add (mul au (of_int ~size:width 2))
                    |> add (of_int ~size:width 1))
                    (mul al (of_int ~size:width 2))))
          else { w = Some width; v = Top }

  let intersect s t =
    let s, t = infer s t in
    let { v = a; _ } = s in
    let { v = b; _ } = t in
    match (a, b) with
    | Bot, _ -> []
    | _, Bot -> []
    | Top, _ -> [ t ]
    | a, b when equal_l a b -> [ t ]
    | _, Top -> [ s ]
    | Interval { lower = al; upper = au }, Interval { lower = bl; upper = bu }
      ->
        let al_mem = member b al in
        let au_mem = member b au in
        let bl_mem = member a bl in
        let bu_mem = member a bu in
        let a_in_b = al_mem && au_mem in
        let b_in_a = bl_mem && bu_mem in
        if a_in_b && b_in_a then [ interval al bu; interval bl au ]
        else if a_in_b then [ s ]
        else if b_in_a then [ t ]
        else if al_mem && (not au_mem) && (not bl_mem) && bu_mem then
          [ interval al bu ]
        else if (not al_mem) && au_mem && bl_mem && not bu_mem then
          [ interval bl au ]
        else []

  let nsplit t =
    match t.v with
    | Bot -> []
    | Top -> (
        match t.w with
        | Some w -> [ interval (umin w) (smax w); interval (smin w) (umax w) ]
        | None -> failwith "Cannot determine nsplit for Top without width")
    | Interval { lower; upper } ->
        let width = size lower in
        let np = np width in
        if compare np t <= 0 then
          [ interval lower (smax width); interval (smin width) upper ]
        else [ t ]

  let ssplit t =
    match t.v with
    | Bot -> []
    | Top -> (
        match t.w with
        | Some w -> [ interval (umin w) (smax w); interval (smin w) (umax w) ]
        | None -> failwith "Cannot determine ssplit for Top without width")
    | Interval { lower; upper } ->
        let width = size lower in
        let sp = sp width in
        if compare sp t <= 0 then
          [ interval lower (umax width); interval (umin width) upper ]
        else [ t ]

  let cut t = List.concat_map ssplit (nsplit t)
end

module WrappedIntervalsLatticeOps = struct
  include WrappedIntervalsLattice

  let bind1 f t =
    {
      w = t.w;
      v =
        (match t.v with
        | Bot -> Bot
        | Top -> Top
        | Interval { lower; upper } -> f lower upper);
    }

  let neg = bind1 (fun l u -> Interval { lower = neg u; upper = neg l })

  let bitnot =
    bind1 (fun l u -> Interval { lower = bitnot u; upper = bitnot l })

  let sign_extend t k =
    if Option.equal Int.equal t.w (Some 0) then { w = Some k; v = Top }
    else
      List.filter_map
        (fun t ->
          match t.v with
          | Interval { lower; upper } ->
              Some
                (interval
                   (sign_extend ~extension:k lower)
                   (sign_extend ~extension:k upper))
          | _ -> None)
        (nsplit t)
      |> lub
      |> fun s ->
      {
        v = s.v;
        w =
          (match s.w with Some _ -> s.w | None -> Option.map (Int.add k) t.w);
      }

  let zero_extend t k =
    if Option.equal Int.equal t.w (Some 0) then
      let zeros = zero ~size:k in
      interval zeros zeros
    else
      List.filter_map
        (fun t ->
          match t.v with
          | Interval { lower; upper } ->
              Some
                (interval
                   (zero_extend ~extension:k lower)
                   (zero_extend ~extension:k upper))
          | _ -> None)
        (ssplit t)
      |> lub
      |> fun s ->
      {
        v = s.v;
        w =
          (match s.w with Some _ -> s.w | None -> Option.map (Int.add k) t.w);
      }

  let add s t =
    let top = infer s top |> snd in
    match (s.v, t.v) with
    | Bot, _ -> s
    | _, Bot -> t
    | Interval { lower = al; upper = au }, Interval { lower = bl; upper = bu }
      ->
        if Z.(leq (add (cardinality s) (cardinality t)) (cardinality top)) then
          interval (add al bl) (add au bu)
        else top
    | _, _ -> top

  let sub s t =
    let top = infer s top |> snd in
    match (s.v, t.v) with
    | Bot, _ -> s
    | _, Bot -> t
    | Interval { lower = al; upper = au }, Interval { lower = bl; upper = bu }
      ->
        if Z.(leq (add (cardinality s) (cardinality t)) (cardinality top)) then
          interval (sub al bu) (sub au bl)
        else top
    | _, _ -> top

  let mul s t =
    let rusmul s t =
      let top = infer s top |> snd in
      let w =
        match s.w with
        | Some w -> w
        | None -> failwith "Cannot multiply without known width"
      in
      let umul =
        match (s.v, t.v) with
        | ( Interval { lower = al; upper = au },
            Interval { lower = bl; upper = bu } ) ->
            let cond =
              let al = to_unsigned_bigint al in
              let au = to_unsigned_bigint au in
              let bl = to_unsigned_bigint bl in
              let bu = to_unsigned_bigint bu in
              Z.(lt (sub (mul au bu) (mul al bl)) (pow (of_int 2) w))
            in
            if cond then interval (mul al bl) (mul au bu) else top
        | _, _ -> top
      in
      let smul =
        match (s.v, t.v) with
        | ( Interval { lower = al; upper = au },
            Interval { lower = bl; upper = bu } ) ->
            let msb_hi b =
              Bitvec.(equal (extract ~hi:w ~lo:(w - 1) b) (ones ~size:1))
            in
            let cond (a, b) (c, d) =
              let a = to_unsigned_bigint a in
              let b = to_unsigned_bigint b in
              let c = to_unsigned_bigint c in
              let d = to_unsigned_bigint d in
              let res = Z.(sub (mul a b) (mul c d)) in
              Z.(lt res (pow (of_int 2) w))
              && Z.(lt (neg (pow (of_int 2) w)) res)
            in
            let all_hi = msb_hi al && msb_hi au && msb_hi bl && msb_hi bu in
            let all_lo =
              (not @@ msb_hi al)
              && (not @@ msb_hi au)
              && (not @@ msb_hi bl)
              && (not @@ msb_hi bu)
            in
            if (all_hi || all_lo) && cond (au, bu) (al, bl) then
              interval (mul al bl) (mul au bu)
            else if
              msb_hi al && msb_hi au
              && (not (msb_hi bl))
              && (not (msb_hi bu))
              && cond (au, bl) (al, bu)
            then interval (mul al bu) (mul au bl)
            else if
              (not (msb_hi al))
              && (not (msb_hi au))
              && msb_hi bl && msb_hi bu
              && cond (al, bu) (au, bl)
            then interval (mul au bl) (mul al bu)
            else top
        | _, _ -> top
      in
      intersect umul smul
    in
    infer s
    @@ lub
         (List.concat_map
            (fun a -> List.concat_map (fun b -> rusmul a b) (cut t))
            (cut s))
    |> snd

  (* 
    Division implementation derived from Crab
    https://github.com/seahorn/crab/blob/418b63c66b91f04bf36ae59d5eecb936c48836ee/include/crab/domains/wrapped_interval_impl.hpp#L1034-L1091
    https://github.com/seahorn/crab/blob/418b63c66b91f04bf36ae59d5eecb936c48836ee/include/crab/domains/wrapped_interval_impl.hpp#L210-L297
  *)
  let trim_zeroes t =
    let w =
      match t.w with
      | Some w -> w
      | None -> failwith "Cannot trim zeroes without known width"
    in
    let zero = zero ~size:w in
    match t.v with
    | Bot -> []
    | Top -> [ interval (of_int ~size:w 1) (umax w) ]
    | Interval { lower; upper } ->
        let equal = Bitvec.equal in
        if equal lower zero && equal upper zero then []
        else if equal lower zero then [ interval (of_int ~size:w 1) upper ]
        else if equal upper zero then [ interval lower (umax w) ]
        else if member t.v zero then
          [ interval lower (umax w); interval (of_int ~size:w 1) upper ]
        else [ t ]

  let udiv s t =
    let divide s t =
      let top = infer s top |> snd in
      match (s.v, t.v) with
      | Interval { lower = al; upper = au }, Interval { lower = bl; upper = bu }
        ->
          interval (udiv al bu) (udiv au bl)
      | _, _ -> top
    in
    infer s
    @@ lub
         (List.concat_map
            (fun a ->
              List.concat_map
                (fun bs -> List.map (fun b -> divide a b) (trim_zeroes bs))
                (ssplit t))
            (ssplit s))
    |> snd

  let sdiv s t =
    let divide s t =
      let top = infer s top |> snd in

      match (s.v, t.v) with
      | Interval { lower = al; upper = au }, Interval { lower = bl; upper = bu }
        -> (
          let w =
            match s.w with
            | Some w -> w
            | None -> failwith "Cannot signed divide without known width"
          in
          let msb_hi b =
            Bitvec.(equal (extract ~hi:w ~lo:(w - 1) b) (ones ~size:1))
          in
          let ( = ) = Bitvec.equal in
          let smin, neg1 = (smin w, umax w) in
          match (msb_hi al, msb_hi bl) with
          | true, true
            when not ((au = smin && bl = neg1) || (al = smin && bu = neg1)) ->
              interval (sdiv au bl) (sdiv al bu)
          | false, false
            when not ((al = smin && bu = neg1) || (au = smin && bl = neg1)) ->
              interval (sdiv al bu) (sdiv au bl)
          | true, false
            when not ((al = smin && bl = neg1) || (au = smin && bu = neg1)) ->
              interval (sdiv al bl) (sdiv au bu)
          | false, true
            when not ((au = smin && bu = neg1) && al = smin && bl = neg1) ->
              interval (sdiv au bu) (sdiv al bl)
          | _, _ -> top)
      | _, _ -> top
    in
    infer s
    @@ lub
         (List.concat_map
            (fun a ->
              List.concat_map
                (fun bs -> List.map (fun b -> divide a b) (trim_zeroes bs))
                (cut t))
            (cut s))
    |> snd

  let bitlogop min max s t =
    let pre s t =
      match (s.v, t.v) with
      | Interval { lower = al; upper = au }, Interval { lower = bl; upper = bu }
        ->
          interval (min (al, au) (bl, bu)) (max (al, au) (bl, bu))
      | _, _ -> infer s top |> snd
    in
    infer s
    @@ lub
         (List.concat_map
            (fun a -> List.map (fun b -> pre a b) (ssplit t))
            (ssplit s))
    |> snd

  let bitor =
    let min_or (al, au) (bl, bu) =
      let rec min_or_aux m =
        (* Lazy evaluation trick *)
        let recurse _ = min_or_aux (lshr m (of_int ~size:(size m) 1)) in
        let open Bitvec in
        if is_zero m then bitor al bl
        else if is_nonzero (bitand (bitnot al) bl |> bitand m) then
          let temp = bitor al m |> bitand (neg m) in
          if ule temp au then bitor temp bl else recurse ()
        else if is_nonzero (bitand al (bitnot bl) |> bitand m) then
          let temp = bitor bl m |> bitand (neg m) in
          if ule temp bu then bitor al temp else recurse ()
        else recurse ()
      in
      let init = smin (size al) in
      min_or_aux init
    in

    let max_or (al, au) (bl, bu) =
      let rec max_or_aux m =
        let one = of_int ~size:(size m) 1 in
        let recurse _ = max_or_aux (lshr m one) in
        let open Bitvec in
        if is_zero m then bitor au bu
        else if is_nonzero (bitand au bu |> bitand m) then
          let tempau = bitor (sub au m) (sub m one) in
          let tempbu = bitor (sub bu m) (sub m one) in
          if uge tempau al then bitor tempau bu
          else if uge tempbu bl then bitor au tempbu
          else recurse ()
        else recurse ()
      in
      let init = smin (size al) in
      max_or_aux init
    in
    bitlogop min_or max_or

  let bitand =
    let min_and (al, au) (bl, bu) =
      let rec min_and_aux m =
        let recurse _ = min_and_aux (lshr m (of_int ~size:(size m) 1)) in
        let open Bitvec in
        if is_zero m then bitand al bl
        else if is_nonzero (bitand (bitnot al) (bitnot bl) |> bitand m) then
          let tempal = bitand (bitor al m) (neg m) in
          let tempbl = bitand (bitor bl m) (neg m) in
          if ule tempal au then bitand tempal bl
          else if ule tempbl bu then bitand al tempbl
          else recurse ()
        else recurse ()
      in
      let init = smin (size al) in
      min_and_aux init
    in

    let max_and (al, au) (bl, bu) =
      let rec max_and_aux m =
        let one = of_int ~size:(size m) 1 in
        let recurse _ = max_and_aux (lshr m (of_int ~size:(size m) 1)) in
        let open Bitvec in
        if is_zero m then bitand au bu
        else if is_nonzero (bitand au (bitnot bu) |> bitand m) then
          let temp = bitor (bitand au (bitnot m)) (sub m one) in
          if uge temp al then bitand temp bu else recurse ()
        else if is_nonzero (bitand (bitnot au) bu |> bitand m) then
          let temp = bitor (bitand bu (bitnot m)) (sub m one) in
          if uge temp bl then bitand au temp else recurse ()
        else recurse ()
      in
      let init = smin (size al) in
      max_and_aux init
    in
    bitlogop min_and max_and

  let bitxor =
    let min_xor (al, au) (bl, bu) =
      let rec min_xor_aux m (al, au) (bl, bu) =
        let recurse = min_xor_aux (lshr m (of_int ~size:(size m) 1)) in
        let open Bitvec in
        if is_zero m then bitxor al bl
        else if is_nonzero (bitand (bitnot al) bl |> bitand m) then
          let temp = bitor al m |> bitand (neg m) in
          let al = if ule temp au then bitor temp bl else al in
          recurse (al, au) (bl, bu)
        else if is_nonzero (bitand al (bitnot bl) |> bitand m) then
          let temp = bitor bl m |> bitand (neg m) in
          let bl = if ule temp bu then bitor al temp else bl in
          recurse (al, au) (bl, bu)
        else recurse (al, au) (bl, bu)
      in
      let init = smin (size al) in
      min_xor_aux init (al, au) (bl, bu)
    in

    let max_xor (al, au) (bl, bu) =
      let rec max_xor_aux m (al, au) (bl, bu) =
        let one = of_int ~size:(size m) 1 in
        let recurse = max_xor_aux (lshr m one) in
        let open Bitvec in
        if is_zero m then bitxor au bu
        else if is_nonzero (bitand au bu |> bitand m) then
          let tempau = bitor (sub au m) (sub m one) in
          let tempbu = bitor (sub bu m) (sub m one) in
          let au, bu =
            if uge tempau al then (tempau, bu)
            else if uge tempbu bl then (au, tempbu)
            else (au, bu)
          in
          recurse (al, au) (bl, bu)
        else recurse (al, au) (bl, bu)
      in
      let init = smin (size al) in
      max_xor_aux init (al, au) (bl, bu)
    in
    bitlogop min_xor max_xor

  let truncate t k =
    match t.v with
    | Bot -> { w = Some k; v = Bot }
    | Top -> { w = Some k; v = Top }
    | Interval { lower; upper } ->
        let w =
          match t.w with
          | Some w -> w
          | None -> failwith "Cannot truncate without known width"
        in
        if w < k then interval (zero ~size:0) (zero ~size:0)
        else
          let truncl = extract ~hi:k ~lo:0 lower in
          let truncu = extract ~hi:k ~lo:0 upper in
          let shiftl = ashr lower (of_int ~size:w k) in
          let shiftu = ashr upper (of_int ~size:w k) in
          if
            Bitvec.(
              (equal shiftl shiftu && ule truncl truncu)
              || equal (add shiftl (of_int ~size:w 1)) shiftu
                 && ugt truncl truncu)
          then interval truncl truncu
          else { w = Some k; v = Top }

  let shl t k =
    let shl_const t k =
      if equal_l t.v Bot then t
      else
        let w =
          match t.w with
          | Some w -> w
          | None -> failwith "Cannot shift left without known width"
        in
        let k = if w < k then w else k in
        match (truncate t (w - k)).v with
        | Interval { lower; upper } ->
            let lower = Bitvec.zero_extend ~extension:k lower in
            let upper = Bitvec.zero_extend ~extension:k upper in
            interval
              (shl lower (of_int ~size:w k))
              (shl upper (of_int ~size:w k))
        | _ ->
            interval (zero ~size:w) (concat (ones ~size:(w - k)) (zero ~size:k))
    in
    match is_singleton k with
    | Some k ->
        shl_const t
          ( to_unsigned_bigint k |> fun k ->
            if Z.fits_int k then Z.to_int k
            else
              match t.w with
              | Some w -> w + 1
              | None -> failwith "Cannot shift left without known width" )
    | None -> { w = t.w; v = Top }

  let lshr t k =
    let lshr_const t k =
      if equal_l t.v Bot then t
      else
        let w =
          match t.w with
          | Some w -> w
          | None -> failwith "Cannot logical shift right without known width"
        in
        let fallback =
          interval (zero ~size:w) (concat (zero ~size:k) (ones ~size:(w - k)))
        in
        if compare (sp w) t <= 0 then fallback
        else
          match t.v with
          | Interval { lower; upper } ->
              interval
                (lshr lower (of_int ~size:w k))
                (lshr upper (of_int ~size:w k))
          | _ -> fallback
    in
    match is_singleton k with
    | Some k ->
        lshr_const t
          ( to_unsigned_bigint k |> fun k ->
            if Z.fits_int k then Z.to_int k
            else
              match t.w with
              | Some w -> w + 1
              | None ->
                  failwith "Cannot logical shift right without known width" )
    | None -> { w = t.w; v = Top }

  let ashr t k =
    let ashr_const t k =
      if equal_l t.v Bot then t
      else
        let w =
          match t.w with
          | Some w -> w
          | None -> failwith "Cannot arithmetic shift right without known width"
        in
        let fallback =
          let k = min k w in
          interval
            (concat (ones ~size:k) (zero ~size:(w - k)))
            (concat (zero ~size:k) (ones ~size:(w - k)))
        in
        if compare (np w) t <= 0 then fallback
        else
          match t.v with
          | Interval { lower; upper } ->
              interval
                (ashr lower (of_int ~size:w k))
                (ashr upper (of_int ~size:w k))
          | _ -> fallback
    in
    match is_singleton k with
    | Some k ->
        ashr_const t
          ( to_unsigned_bigint k |> fun k ->
            if Z.fits_int k then Z.to_int k
            else
              match t.w with
              | Some w -> w + 1
              | None ->
                  failwith "Cannot arithmetic shift right without known width"
          )
    | None -> { w = t.w; v = Top }

  let extract ~hi ~lo t =
    assert (0 <= lo);
    assert (lo <= hi);
    if hi <= lo then { w = Some 0; v = Bot }
    else
      let w =
        match t.w with
        | Some w -> w
        | None -> failwith "Cannot extract without known width"
      in
      let k = of_int ~size:w lo in
      assert (hi <= w);
      truncate (lshr t (interval k k)) (hi - lo)

  let concat s t =
    match t.w with
    | None -> top
    | Some tw -> (
        let t = if compare (sp tw) t <= 0 then { w = t.w; v = Top } else t in
        match (s.v, t.v) with
        | Bot, _ | _, Bot ->
            {
              w = Option.bind s.w (fun u -> Option.map (Int.add u) t.w);
              v = Bot;
            }
        | Top, Top ->
            {
              w = Option.bind s.w (fun u -> Option.map (Int.add u) t.w);
              v = Top;
            }
        | ( Interval { lower = al; upper = au },
            Interval { lower = bl; upper = bu } ) ->
            interval (concat al bl) (concat au bu)
        | Interval { lower = al; upper = au }, Top ->
            interval (concat al (zero ~size:tw)) (concat au (ones ~size:tw))
        | Top, Interval { lower = bl; upper = bu } -> (
            match s.w with
            | None -> top
            | Some sw ->
                interval (concat (zero ~size:sw) bl) (concat (ones ~size:sw) bu)
            ))
end

module WrappedIntervalsValueAbstraction = struct
  include WrappedIntervalsLatticeOps

  let eval_const (op : Lang.Ops.AllOps.const) rt =
    match op with
    | `Bool _ -> { w = Some 1; v = Top }
    | `Integer _ -> { w = Some 0; v = Top }
    | `Bitvector bv ->
        if size bv = 0 then { w = Some 0; v = Top } else interval bv bv

  let eval_unop (op : Lang.Ops.AllOps.unary) (a, t) rt =
    if Option.is_none a.w then top
    else
      match op with
      | `BVNEG -> neg a
      | `BVNOT -> bitnot a
      | `ZeroExtend k -> zero_extend a k
      | `SignExtend k -> sign_extend a k
      | `Extract (hi, lo) -> extract ~hi ~lo a
      | `BOOLTOBV1 -> { w = Some 1; v = Top }
      | _ -> infer a top |> snd

  let eval_binop (op : Lang.Ops.AllOps.binary) (a, ta) (b, tb) rt =
    let a, b = infer a b in
    if Option.is_none a.w then top
    else
      match op with
      | `BVADD -> add a b
      | `BVSUB -> sub a b
      | `BVMUL -> mul a b
      | `BVUDIV -> udiv a b
      | `BVSDIV -> sdiv a b
      | `BVOR -> bitor a b
      | `BVAND -> bitand a b
      | `BVNAND -> bitand a b |> bitnot
      | `BVXOR -> bitxor a b
      | `BVASHR -> ashr a b
      | `BVLSHR -> lshr a b
      | `BVSHL -> shl a b
      | _ -> infer a top |> snd

  let eval_intrin (op : Lang.Ops.AllOps.intrin) (args : (t * Types.t) list) rt =
    let op a b =
      match op with
      | `BVADD -> (eval_binop `BVADD a b rt, rt)
      | `BVOR -> (eval_binop `BVOR a b rt, rt)
      | `BVXOR -> (eval_binop `BVXOR a b rt, rt)
      | `BVAND -> (eval_binop `BVAND a b rt, rt)
      | `BVConcat -> (concat (fst a) (fst b), rt)
      | _ -> (top, rt)
    in
    match args with
    | h :: b :: tl -> fst @@ List.fold_left op (op h b) tl
    | _ -> failwith "operators must have two operands"
end

module WrappedIntervalsValueAbstractionBasil = struct
  include WrappedIntervalsValueAbstraction
  module E = Lang.Expr.BasilExpr
end

module StateAbstraction =
  Intra_analysis.MapState (WrappedIntervalsValueAbstractionBasil)

module Eval =
  Intra_analysis.EvalStmt
    (WrappedIntervalsValueAbstractionBasil)
    (StateAbstraction)

module Domain = struct
  include StateAbstraction

  let top_val = WrappedIntervalsLattice.top

  let init p =
    let vs = Lang.Procedure.formal_in_params p |> StringMap.values in
    vs
    |> Iter.map (fun v -> (v, top_val))
    |> Iter.fold (fun m (v, d) -> update v d m) bottom

  let transfer dom stmt =
    let stmt = Eval.stmt_eval_fwd stmt dom in
    let updates =
      match stmt with
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
    in
    Iter.fold (fun a (k, v) -> update k v a) dom updates
end

module Analysis = Dataflow_graph.AnalysisFwd (Domain)

let analyse (p : Lang.Program.proc) =
  let g = Dataflow_graph.create p in
  Analysis.analyse ~widen_set:Graph.ChaoticIteration.FromWto ~delay_widen:50 g

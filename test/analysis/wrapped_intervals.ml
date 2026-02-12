open Bincaml_util.Common
open Analysis.Wrapped_intervals
open WrappedIntervalsLattice

let dbg x =
  print_endline (show x);
  x

let dbg_list = List.map dbg

let%test_unit "cardinality" =
  let ( = ) a b = Z.equal a (Z.of_int b) in
  let iv a b = interval (Bitvec.of_int ~size:4 a) (Bitvec.of_int ~size:4 b) in
  assert (cardinality bottom = 0);
  assert (cardinality { w = Some 4; v = Top } = 16);
  assert (cardinality (iv 0 15) = 16);
  assert (cardinality (iv 3 12) = 10);
  assert (cardinality (iv 15 0) = 2);
  assert (cardinality (iv 13 13) = 1)

let%test_unit "member" =
  let iv a b =
    Interval
      { lower = Bitvec.of_int ~size:4 a; upper = Bitvec.of_int ~size:4 b }
  in
  let member t e = member t (Bitvec.of_int ~size:4 e) in
  assert (member Top 0);
  assert (not (member Bot 0));
  assert (member (iv 2 6) 4);
  assert (member (iv 2 6) 6);
  assert (member (iv 2 6) 2);
  assert (not (member (iv 2 6) 7));
  assert (not (member (iv 6 2) 4));
  assert (member (iv 6 2) 6);
  assert (member (iv 6 2) 2);
  assert (member (iv 6 2) 7)

let%test_unit "partial_order" =
  let ( <= ) a b = compare a b <= 0 in
  let ( > ) a b = compare a b > 0 in
  let iv a b = interval (Bitvec.of_int ~size:4 a) (Bitvec.of_int ~size:4 b) in
  assert (top <= top);
  assert (bottom <= top);
  assert (bottom <= bottom);
  (* Fig 2.a *)
  assert (iv 0 8 <= iv 0 9);
  assert (iv 3 5 <= iv 0 8);
  (* Fig 2.b *)
  assert (iv 0 9 > iv 8 1);
  assert (iv 8 1 > iv 0 9);
  (* Fig 2.c *)
  assert (iv 0 9 > iv 4 10);
  assert (iv 4 10 > iv 0 9);
  (* Fig 2.d *)
  assert (iv 0 4 > iv 5 6);
  assert (iv 5 6 > iv 0 4)

let%test_unit "join" =
  let ( = ) = equal in
  let iv a b = interval (Bitvec.of_int ~size:4 a) (Bitvec.of_int ~size:4 b) in
  assert (join bottom top = top);
  assert (join (iv 1 4) bottom = iv 1 4);
  (* Fig 2.a *)
  assert (join (iv 1 4) (iv 0 5) = iv 0 5);
  (* Fig 2.b *)
  assert (join (iv 0 9) (iv 8 1) = top);
  assert (join (iv 6 5) (iv 3 0) = top);
  (* Fig 2.c *)
  assert (join (iv 0 9) (iv 4 10) = iv 0 10);
  (* Fig 2.d *)
  assert (join (iv 0 4) (iv 5 6) = iv 0 6)

let%test_unit "lub" =
  let ( = ) = equal in
  let iv a b = interval (Bitvec.of_int ~size:4 a) (Bitvec.of_int ~size:4 b) in
  assert (lub [ bottom; top; bottom ] = top);
  assert (lub [ bottom; iv 0 9; top ] = top);
  assert (lub [ iv 0 3; iv 3 5; iv 4 6 ] = iv 0 6);
  assert (lub [ iv 0 3; iv 6 10; iv 14 15 ] = iv 14 10)

let%test_unit "intersect" =
  let ( = ) = List.equal equal in
  let iv a b = interval (Bitvec.of_int ~size:4 a) (Bitvec.of_int ~size:4 b) in
  assert (List.is_empty (intersect bottom bottom));
  assert (List.is_empty (intersect top bottom));
  assert (intersect top (iv 1 2) = [ iv 1 2 ]);
  assert (List.mem (iv 0 1) (intersect (iv 0 4) (iv 3 1)));
  assert (List.mem (iv 3 4) (intersect (iv 0 4) (iv 3 1)));
  assert (intersect (iv 0 8) (iv 3 6) = [ iv 3 6 ]);
  assert (intersect (iv 3 7) (iv 6 11) = [ iv 6 7 ])

open WrappedIntervalsValueAbstraction

let%test_unit "mul" =
  let ( = ) = equal in
  let iv a b = interval (Bitvec.of_int ~size:4 a) (Bitvec.of_int ~size:4 b) in
  assert (mul (iv 15 9) (iv 0 1) = iv 15 9)

let%test_unit "truncate" =
  let ( = ) = equal in
  let iv ~w a b =
    interval (Bitvec.of_int ~size:w a) (Bitvec.of_int ~size:w b)
  in
  assert (truncate (iv ~w:4 7 15) 2 = { w = Some 2; v = Top });
  assert (truncate (iv ~w:4 4 5) 2 = iv ~w:2 0 1)

let%test_unit "shl" =
  let ( = ) = equal in
  let iv a b = interval (Bitvec.of_int ~size:4 a) (Bitvec.of_int ~size:4 b) in
  assert (shl (iv 2 4) (iv 1 1) = iv 4 8);
  assert (shl (iv 4 8) (iv 2 2) = iv 0 12)

let%test_unit "lshr" =
  let ( = ) = equal in
  let iv a b = interval (Bitvec.of_int ~size:4 a) (Bitvec.of_int ~size:4 b) in
  assert (lshr (iv 3 12) (iv 1 1) = iv 1 6);
  assert (lshr (iv 15 5) (iv 2 2) = iv 0 3)

let%test_unit "ashr" =
  let ( = ) = equal in
  let iv a b = interval (Bitvec.of_int ~size:4 a) (Bitvec.of_int ~size:4 b) in
  assert (ashr (iv 15 3) (iv 1 1) = iv 15 1);
  assert (ashr (iv 3 10) (iv 2 2) = iv 12 3)

let%test_unit "extract" =
  let ( = ) = equal in
  let iv ~w a b =
    interval (Bitvec.of_int ~size:w a) (Bitvec.of_int ~size:w b)
  in
  assert (extract ~hi:5 ~lo:2 @@ iv ~w:6 13 63 = { w = Some 3; v = Top });
  assert (extract ~hi:3 ~lo:1 @@ iv ~w:4 4 7 = iv ~w:2 2 3);
  assert (extract ~hi:3 ~lo:0 @@ iv ~w:3 3 3 = iv ~w:3 3 3)

let%test_unit "concat" =
  let ( = ) = equal in
  let iv ~w a b =
    interval (Bitvec.of_int ~size:w a) (Bitvec.of_int ~size:w b)
  in
  assert (concat (iv ~w:2 1 3) (iv ~w:2 0 2) = iv ~w:4 4 14);
  assert (concat (iv ~w:2 3 0) (iv ~w:2 0 2) = iv ~w:4 12 2)

let%test_unit "zero_extend" =
  let ( = ) = equal in
  let iv ~w a b =
    interval (Bitvec.of_int ~size:w a) (Bitvec.of_int ~size:w b)
  in
  assert (zero_extend (iv ~w:3 0 1) 3 = iv ~w:6 0 1)

let%test_unit "sign_extend" =
  let ( = ) = equal in
  let iv ~w a b =
    interval (Bitvec.of_int ~size:w a) (Bitvec.of_int ~size:w b)
  in
  assert (sign_extend (iv ~w:3 0 1) 3 = iv ~w:6 0 1)

let%test "mul2" =
  let iv ~w a b =
    interval (Bitvec.of_int ~size:w a) (Bitvec.of_int ~size:w b)
  in
  let t = Types.Bitvector 43 in
  let abstract =
    eval_binop `BVMUL
      (iv ~w:43 0x48303bae5fb 0x48303bae5fb, t)
      ( eval_intrin `BVConcat
          [
            (iv ~w:26 0 0, Bitvector 26);
            ( eval_binop `BVUREM
                (iv ~w:17 0x1e97e 0x1e97e, Types.Bitvector 17)
                (iv ~w:17 0xdbf3 0xdbf3, Types.Bitvector 17)
                (Types.Bitvector 17),
              Types.Bitvector 17 );
          ]
          t,
        t )
      t
  in
  let concrete = iv ~w:43 0x180fcfd9808 0x180fcfd9808 in
  compare concrete abstract <= 0

let%test "udiv_top_top" =
  let ( = ) = equal in
  let top = { w = Some 4; v = Top } in
  top = udiv top top

open Bincaml_util.Common
open Analysis.Wrapped_intervals
open WrappedIntervalsLattice

open struct
  (** Put all the implementation in a hidden struct so not exported and we get
      unused function warnings if we define a test and dont add it to the suite
  *)

  let ival =
    Alcotest.testable
      (fun f p -> Format.pp_print_string f (WrappedIntervalsLattice.show p))
      WrappedIntervalsLattice.equal

  let z = Alcotest.testable Z.pp Z.equal
  let checkz n i = Alcotest.check z n (Z.of_int i)

  module Eq = struct
    let ( = ) a expected = Alcotest.(check ival) "equal" expected a
    let ( <= ) a b = Alcotest.(check bool "leq" true (leq a b))
    let ( > ) a b = Alcotest.(check bool "gt" true (not @@ leq a b))

    include WrappedIntervalsValueAbstraction
  end

  let cardinality () =
    let iv a b = interval (Bitvec.of_int ~size:4 a) (Bitvec.of_int ~size:4 b) in
    let cardinality = cardinality ~width:4 in
    let c = checkz "cardinality" in
    c 0 (cardinality bottom);
    c 16 (cardinality top);
    c 16 (cardinality (iv 0 15));
    c 10 (cardinality (iv 3 12));
    c 2 (cardinality (iv 15 0));
    c 1 (cardinality (iv 13 13))

  let member () =
    let iv a b =
      Interval
        { lower = Bitvec.of_int ~size:4 a; upper = Bitvec.of_int ~size:4 b }
    in
    let member t e =
     fun b ->
      Alcotest.(check bool "member" b (member t (Bitvec.of_int ~size:4 e)))
    in
    (member Top 0) true;
    (member Bot 0) false;
    (member (iv 2 6) 4) true;
    (member (iv 2 6) 6) true;
    (member (iv 2 6) 2) true;
    (member (iv 2 6) 7) false;
    (member (iv 6 2) 4) false;
    (member (iv 6 2) 6) true;
    (member (iv 6 2) 2) true;
    (member (iv 6 2) 7) true

  let partial_order () =
    let open Eq in
    let iv a b = interval (Bitvec.of_int ~size:4 a) (Bitvec.of_int ~size:4 b) in
    top <= top;
    bottom <= top;
    bottom <= bottom;
    (* Fig 2.a *)
    iv 0 8 <= iv 0 9;
    iv 3 5 <= iv 0 8;
    (* Fig 2.b *)
    iv 0 9 > iv 8 1;
    iv 8 1 > iv 0 9;
    (* Fig 2.c *)
    iv 0 9 > iv 4 10;
    iv 4 10 > iv 0 9;
    (* Fig 2.d *)
    iv 0 4 > iv 5 6;
    iv 5 6 > iv 0 4

  let join () =
    let ( = ) a expect = Alcotest.(check ival) "equal" expect a in
    let iv a b = interval (Bitvec.of_int ~size:4 a) (Bitvec.of_int ~size:4 b) in
    join bottom top = top;
    join (iv 1 4) bottom = iv 1 4;
    (* Fig 2.a *)
    join (iv 1 4) (iv 0 5) = iv 0 5;
    (* Fig 2.b *)
    join (iv 0 9) (iv 8 1) = top;
    join (iv 6 5) (iv 3 0) = top;
    (* Fig 2.c *)
    join (iv 0 9) (iv 4 10) = iv 0 10;
    (* Fig 2.d *)
    join (iv 0 4) (iv 5 6) = iv 0 6

  let lub () =
    let open Eq in
    let iv a b = interval (Bitvec.of_int ~size:4 a) (Bitvec.of_int ~size:4 b) in
    lub [ bottom; top; bottom ] = top;
    lub [ bottom; iv 0 9; top ] = top;
    lub [ iv 0 3; iv 3 5; iv 4 6 ] = iv 0 6;
    lub [ iv 0 3; iv 6 10; iv 14 15 ] = iv 14 10;
    lub [ top; iv 8 15; iv 10 0; iv 0 3 ] = top

  let intersect () =
    let ( = ) a b = Alcotest.(check (list ival)) "equal" a b in
    let iv a b = interval (Bitvec.of_int ~size:4 a) (Bitvec.of_int ~size:4 b) in
    intersect bottom bottom = [];
    intersect top bottom = [];
    intersect top (iv 1 2) = [ iv 1 2 ];
    Alcotest.(check bool)
      "contains" true
      (List.mem (iv 0 1) (intersect (iv 0 4) (iv 3 1)));
    Alcotest.(check bool)
      "contains" true
      (List.mem (iv 3 4) (intersect (iv 0 4) (iv 3 1)));
    intersect (iv 0 8) (iv 3 6) = [ iv 3 6 ];
    intersect (iv 3 7) (iv 6 11) = [ iv 6 7 ]

  let mul () =
    let open WrappedIntervalsValueAbstraction in
    let iv a b = interval (Bitvec.of_int ~size:4 a) (Bitvec.of_int ~size:4 b) in
    Alcotest.check ival "mul" (iv 15 9) (mul ~width:4 (iv 15 9) (iv 0 1))

  let truncate () =
    let open Eq in
    let iv ~w a b =
      interval (Bitvec.of_int ~size:w a) (Bitvec.of_int ~size:w b)
    in
    truncate (iv ~w:4 7 15) 2 = top;
    truncate (iv ~w:4 4 5) 2 = iv ~w:2 0 1

  let shl () =
    let open Eq in
    let iv a b = interval (Bitvec.of_int ~size:4 a) (Bitvec.of_int ~size:4 b) in
    shl ~width:4 (iv 2 4) (iv 1 1) = iv 4 8;
    shl ~width:4 (iv 4 8) (iv 2 2) = iv 0 12

  let lshr () =
    let open Eq in
    let iv a b = interval (Bitvec.of_int ~size:4 a) (Bitvec.of_int ~size:4 b) in
    lshr ~width:4 (iv 3 12) (iv 1 1) = iv 1 6;
    lshr ~width:4 (iv 15 5) (iv 2 2) = iv 0 3

  let ashr () =
    let open Eq in
    let iv a b = interval (Bitvec.of_int ~size:4 a) (Bitvec.of_int ~size:4 b) in
    ashr ~width:4 (iv 15 3) (iv 1 1) = iv 15 1;
    ashr ~width:4 (iv 3 10) (iv 2 2) = iv 12 3

  let extract () =
    let open Eq in
    let iv ~w a b =
      interval (Bitvec.of_int ~size:w a) (Bitvec.of_int ~size:w b)
    in
    extract ~width:6 ~hi:5 ~lo:2 @@ iv ~w:6 13 63 = top;
    extract ~width:4 ~hi:3 ~lo:1 @@ iv ~w:4 4 7 = iv ~w:2 2 3;
    extract ~width:3 ~hi:3 ~lo:0 @@ iv ~w:3 3 3 = iv ~w:3 3 3

  let concat () =
    let open Eq in
    let iv ~w a b =
      interval (Bitvec.of_int ~size:w a) (Bitvec.of_int ~size:w b)
    in
    concat (iv ~w:2 1 3, 2) (iv ~w:2 0 2, 2) = iv ~w:4 4 14;
    concat (iv ~w:2 3 0, 2) (iv ~w:2 0 2, 2) = iv ~w:4 12 2

  let zero_extend () =
    let open Eq in
    let iv ~w a b =
      interval (Bitvec.of_int ~size:w a) (Bitvec.of_int ~size:w b)
    in
    zero_extend ~width:3 (iv ~w:3 0 1) 3 = iv ~w:6 0 1

  let sign_extend () =
    let open Eq in
    let iv ~w a b =
      interval (Bitvec.of_int ~size:w a) (Bitvec.of_int ~size:w b)
    in
    sign_extend ~width:3 (iv ~w:3 0 1) 3 = iv ~w:6 0 1

  let mul2 () =
    let open Eq in
    let iv ~w a b =
      interval (Bitvec.of_int ~size:w a) (Bitvec.of_int ~size:w b)
    in
    let t = Types.Bitvector 43 in
    let abstract =
      eval_binary `BVMUL
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
    concrete <= abstract

  let udiv_top_top () =
    let open Eq in
    udiv ~width:4 top top = top
end

let tests =
  [
    ("cardinality", cardinality);
    ("member", member);
    ("partial order", partial_order);
    ("join", join);
    ("lub", lub);
    ("intersect", intersect);
    ("mul", mul);
    ("truncate", truncate);
    ("shl", shl);
    ("lshr", lshr);
    ("ashr", ashr);
    ("extract", extract);
    ("concat", concat);
    ("zero_extend", zero_extend);
    ("sign_extend", sign_extend);
    ("mul2", mul2);
    ("udiv_top_top", udiv_top_top);
  ]
  |> List.map (fun (n, t) -> Alcotest.test_case n `Quick t)
  |> fun cases -> [ ("wrapped_intervals", cases) ]

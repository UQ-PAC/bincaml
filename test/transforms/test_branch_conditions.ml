open Lang
open Common
open Transforms.Branch_conditions

let%expect_test "flag_types" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
var $R0:bv64;
var $R1:bv64;
var $H2:bv64;
var $H3:bv64;
var $PSTATE_N:bv1;
var $PSTATE_Z:bv1;
var $PSTATE_C:bv1;
var $PSTATE_V:bv1;

proc @main() -> ()
[
  block %main [
     $PSTATE_V:bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(extract(32,0, $R0), 0x1:bv32)), bvadd(sign_extend(32, extract(32,0, $R0)), 0x1:bv64))));
     $PSTATE_V:bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32,0, $R0), 0xfffffffd:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32,0, $R0)), 0xfffffffffffffffd:bv64), 0x1:bv64))));
     $PSTATE_V:bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32,0, $R0), bvnot(bvshl(extract(32,0, $R1), zero_extend(20, 0x0:bv12)))), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32,0, $R0)), sign_extend(32, bvnot(bvshl(extract(32,0, $R1), zero_extend(20, 0x0:bv12))))), 0x1:bv64))));
     $PSTATE_V:bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(local_31:bv32, bvshl(local_32:bv32, zero_extend(20, 0x0:bv12)))), bvadd(sign_extend(32, local_31:bv32), sign_extend(32, bvshl(local_32:bv32, zero_extend(20, 0x0:bv12)))))));

     $PSTATE_C:bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(extract(32,0, $R0), 0x1:bv32)), bvadd(zero_extend(32, extract(32,0, $R0)), 0x1:bv64))));
     $PSTATE_C:bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32,0, $R0), 0xfffffffd:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32,0, $R0)), 0xfffffffd:bv64), 0x1:bv64))));
     $PSTATE_C:bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32,0, $R0), bvnot(bvshl(extract(32,0, $R1), zero_extend(20, 0x0:bv12)))), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32,0, $R0)), zero_extend(32, bvnot(bvshl(extract(32,0, $R1), zero_extend(20, 0x0:bv12))))), 0x1:bv64))));
     $PSTATE_C:bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd($H2:bv32, bvshl($H3:bv32, zero_extend(20, 0x0:bv12)))), bvadd(zero_extend(32, $H2:bv32), zero_extend(32, bvshl($H3:bv32, zero_extend(20, 0x0:bv12)))))));

     $PSTATE_Z:bv1 := booltobv1(eq(bvadd($H2:bv32, bvshl($H3:bv32, zero_extend(20, 0x0:bv12))), 0x0:bv32));
     $PSTATE_Z:bv1 := booltobv1(eq(bvadd(extract(32,0, $R0), 0x1:bv32), 0x0:bv32));
     $PSTATE_Z:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R0), bvnot(bvshl(extract(32,0, $R1), zero_extend(20, 0x0:bv12)))), 0x1:bv32), 0x0:bv32));

     $PSTATE_N:bv1 := extract(32,31, bvadd(extract(32,0, $R0), 0x1:bv32));
     $PSTATE_N:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R0), bvnot(bvshl(extract(32,0, $R1), zero_extend(20, 0x0:bv12)))), 0x1:bv32));
     $PSTATE_N:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R0), 0xffffffff:bv32), 0x1:bv32));

     $PSTATE_V:bv1 := 0x0:bv1;
     $PSTATE_C:bv1 := 0x0:bv1;
     $PSTATE_Z:bv1 := 0x1:bv1;
     $PSTATE_N:bv1 := 0x0:bv1;

    goto (%ret);
  ];
  block %ret [ return; ]
];

prog entry @main;
    |}
  in
  let prog =
    lst.prog |> Program.map_procedures (fun _ -> annotate_flag_assign_stmts)
  in
  print_endline
  @@ Containers_pp.Pretty.to_string ~width:800 (Lang.Program.prog_pretty prog);
  [%expect
    {|
    var $R0:bv64;
    var $R1:bv64;
    var $H2:bv64;
    var $H3:bv64;
    var $PSTATE_N:bv1;
    var $PSTATE_Z:bv1;
    var $PSTATE_C:bv1;
    var $PSTATE_V:bv1;
    proc @main()  -> () {  }
      modifies $PSTATE_C:bv1, $PSTATE_N:bv1, $PSTATE_V:bv1, $PSTATE_Z:bv1
      captures $H2:bv64, $H3:bv64, $PSTATE_C:bv1, $PSTATE_N:bv1, $PSTATE_V:bv1, $PSTATE_Z:bv1, $R0:bv64, $R1:bv64

    [
       block %main [
         $PSTATE_V:bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(extract(32,0, $R0), 0x1:bv32)), bvadd(sign_extend(32, extract(32,0, $R0)), 0x1:bv64)))) { .flag_semantics_$PSTATE_V = "(V (Sum (extract(32,0, $R0), 0x1:bv32)))" };
         $PSTATE_V:bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32,0, $R0), 0xfffffffd:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32,0, $R0)), 0xfffffffffffffffd:bv64), 0x1:bv64)))) { .flag_semantics_$PSTATE_V = "(V (Diff (extract(32,0, $R0), 0x2:bv32)))" };
         $PSTATE_V:bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32,0, $R0), bvnot(bvshl(extract(32,0, $R1), zero_extend(20, 0x0:bv12)))), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32,0, $R0)), sign_extend(32, bvnot(bvshl(extract(32,0, $R1), zero_extend(20, 0x0:bv12))))), 0x1:bv64)))) { .flag_semantics_$PSTATE_V = "(V (Diff (extract(32,0, $R0), extract(32,0, $R1))))" };
         $PSTATE_V:bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(local_31:bv32, bvshl(local_32:bv32, zero_extend(20, 0x0:bv12)))), bvadd(sign_extend(32, local_31:bv32), sign_extend(32, bvshl(local_32:bv32, zero_extend(20, 0x0:bv12))))))) { .flag_semantics_$PSTATE_V = "(V (Sum (local_31:bv32, local_32:bv32)))" };
         $PSTATE_C:bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(extract(32,0, $R0), 0x1:bv32)), bvadd(zero_extend(32, extract(32,0, $R0)), 0x1:bv64)))) { .flag_semantics_$PSTATE_C = "(C (Sum (extract(32,0, $R0), 0x1:bv32)))" };
         $PSTATE_C:bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32,0, $R0), 0xfffffffd:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32,0, $R0)), 0xfffffffd:bv64), 0x1:bv64)))) { .flag_semantics_$PSTATE_C = "(C (Diff (extract(32,0, $R0), 0x2:bv32)))" };
         $PSTATE_C:bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32,0, $R0), bvnot(bvshl(extract(32,0, $R1), zero_extend(20, 0x0:bv12)))), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32,0, $R0)), zero_extend(32, bvnot(bvshl(extract(32,0, $R1), zero_extend(20, 0x0:bv12))))), 0x1:bv64)))) { .flag_semantics_$PSTATE_C = "(C (Diff (extract(32,0, $R0), extract(32,0, $R1))))" };
         $PSTATE_C:bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd($H2, bvshl($H3, zero_extend(20, 0x0:bv12)))), bvadd(zero_extend(32, $H2), zero_extend(32, bvshl($H3, zero_extend(20, 0x0:bv12))))))) { .flag_semantics_$PSTATE_C = "(C (Sum ($H2, $H3)))" };
         $PSTATE_Z:bv1 := booltobv1(eq(bvadd($H2, bvshl($H3, zero_extend(20, 0x0:bv12))), 0x0:bv32)) { .flag_semantics_$PSTATE_Z = "(Z (Sum ($H2, $H3)))" };
         $PSTATE_Z:bv1 := booltobv1(eq(bvadd(extract(32,0, $R0), 0x1:bv32), 0x0:bv32)) { .flag_semantics_$PSTATE_Z = "(Z (Sum (extract(32,0, $R0), 0x1:bv32)))" };
         $PSTATE_Z:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R0), bvnot(bvshl(extract(32,0, $R1), zero_extend(20, 0x0:bv12)))), 0x1:bv32), 0x0:bv32)) { .flag_semantics_$PSTATE_Z = "(Z (Diff (extract(32,0, $R0), extract(32,0, $R1))))" };
         $PSTATE_N:bv1 := extract(32,31, bvadd(extract(32,0, $R0), 0x1:bv32)) { .flag_semantics_$PSTATE_N = "(N (Sum (extract(32,0, $R0), 0x1:bv32)))" };
         $PSTATE_N:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R0), bvnot(bvshl(extract(32,0, $R1), zero_extend(20, 0x0:bv12)))), 0x1:bv32)) { .flag_semantics_$PSTATE_N = "(N (Diff (extract(32,0, $R0), extract(32,0, $R1))))" };
         $PSTATE_N:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R0), 0xffffffff:bv32), 0x1:bv32)) { .flag_semantics_$PSTATE_N = "(N (Expr extract(32,0, $R0)))" };
         $PSTATE_V:bv1 := 0x0:bv1 { .flag_semantics_$PSTATE_V = "(Lit Never)" };
         $PSTATE_C:bv1 := 0x0:bv1 { .flag_semantics_$PSTATE_C = "(Lit Never)" };
         $PSTATE_Z:bv1 := 0x1:bv1 { .flag_semantics_$PSTATE_Z = "(Lit Always)" };
         $PSTATE_N:bv1 := 0x0:bv1 { .flag_semantics_$PSTATE_N = "(Lit Never)" };
         goto (%ret);
       ];
       block %ret [ return; ]
    ];
    prog entry @main;
    |}]

let%expect_test "flag_incorrect" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
var $R0:bv64;
var $R1:bv64;
var $H2:bv64;
var $H3:bv64;
var $PSTATE_N:bv1;
var $PSTATE_Z:bv1;
var $PSTATE_C:bv1;
var $PSTATE_V:bv1;

proc @main() -> ()
[
  block %main [
     // N must extract the top bit, this extracts the second top
     $PSTATE_N:bv1 := extract(31,30, bvadd(extract(32,0, $R0), 0x1:bv32));
     $PSTATE_N:bv1 := extract(31,30, bvadd(bvadd(extract(32,0, $R0), bvnot(bvshl(extract(32,0, $R1), zero_extend(20, 0x0:bv12)))), 0x1:bv32));
     $PSTATE_N:bv1 := extract(31,30, bvadd(bvadd(extract(32,0, $R0), 0xffffffff:bv32), 0x1:bv32));
    goto (%ret);
  ];
  block %ret [ return; ]
];

prog entry @main;
    |}
  in
  let prog =
    lst.prog |> Program.map_procedures (fun _ -> annotate_flag_assign_stmts)
  in
  print_endline
  @@ Containers_pp.Pretty.to_string ~width:800 (Lang.Program.prog_pretty prog);
  [%expect
    {|
    var $R0:bv64;
    var $R1:bv64;
    var $H2:bv64;
    var $H3:bv64;
    var $PSTATE_N:bv1;
    var $PSTATE_Z:bv1;
    var $PSTATE_C:bv1;
    var $PSTATE_V:bv1;
    proc @main()  -> () {  }
      modifies $PSTATE_N:bv1
      captures $PSTATE_N:bv1, $R0:bv64, $R1:bv64

    [ block %main [ $PSTATE_N:bv1 := extract(31,30, bvadd(extract(32,0, $R0), 0x1:bv32)); $PSTATE_N:bv1 := extract(31,30, bvadd(bvadd(extract(32,0, $R0), bvnot(bvshl(extract(32,0, $R1), zero_extend(20, 0x0:bv12)))), 0x1:bv32)); $PSTATE_N:bv1 := extract(31,30, bvadd(bvadd(extract(32,0, $R0), 0xffffffff:bv32), 0x1:bv32)); goto (%ret); ]; block %ret [ return; ] ];
    prog entry @main;
    |}]

let%expect_test "flag_tracking" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
var $R0:bv64;
var $PSTATE_N:bv1;
var $PSTATE_Z:bv1;
var $PSTATE_C:bv1;
var $PSTATE_V:bv1;

proc @main() -> ()
[
  block %main [
     $PSTATE_V:bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(extract(32,0, $R0), 0x1:bv32)), bvadd(sign_extend(32, extract(32,0, $R0)), 0x1:bv64))));
     $PSTATE_C:bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(extract(32,0, $R0), 0x1:bv32)), bvadd(zero_extend(32, extract(32,0, $R0)), 0x1:bv64))));
     $PSTATE_Z:bv1 := booltobv1(eq(bvadd(extract(32,0, $R0), 0x1:bv32), 0x0:bv32));
     $PSTATE_N:bv1 := extract(32,31, bvadd(extract(32,0, $R0), 0x1:bv32));
     assume booland(eq($PSTATE_N, $PSTATE_V), eq($PSTATE_Z, 0x0:bv1));
    goto (%ret);
  ];
  block %ret [ return; ]
];

prog entry @main;
    |}
  in
  let prog =
    lst.prog |> Program.map_procedures (fun _ -> annotate_assume_flags)
  in
  print_endline
  @@ Containers_pp.Pretty.to_string ~width:800 (Lang.Program.prog_pretty prog);
  [%expect
    {|
    var $R0:bv64;
    var $PSTATE_N:bv1;
    var $PSTATE_Z:bv1;
    var $PSTATE_C:bv1;
    var $PSTATE_V:bv1;
    proc @main()  -> () {  }
      modifies $PSTATE_C:bv1, $PSTATE_N:bv1, $PSTATE_V:bv1, $PSTATE_Z:bv1
      captures $PSTATE_C:bv1, $PSTATE_N:bv1, $PSTATE_V:bv1, $PSTATE_Z:bv1, $R0:bv64

    [
       block %main [
         $PSTATE_V:bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(extract(32,0, $R0), 0x1:bv32)), bvadd(sign_extend(32, extract(32,0, $R0)), 0x1:bv64))));
         $PSTATE_C:bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(extract(32,0, $R0), 0x1:bv32)), bvadd(zero_extend(32, extract(32,0, $R0)), 0x1:bv64))));
         $PSTATE_Z:bv1 := booltobv1(eq(bvadd(extract(32,0, $R0), 0x1:bv32), 0x0:bv32));
         $PSTATE_N:bv1 := extract(32,31, bvadd(extract(32,0, $R0), 0x1:bv32));
         assume booland(eq($PSTATE_N, $PSTATE_V), eq($PSTATE_Z, 0x0:bv1)) { .flag_semantics_$PSTATE_C = "(C (Sum (extract(32,0, $R0), 0x1:bv32)))"; .flag_semantics_$PSTATE_N = "(N (Sum (extract(32,0, $R0), 0x1:bv32)))"; .flag_semantics_$PSTATE_V = "(V (Sum (extract(32,0, $R0), 0x1:bv32)))"; .flag_semantics_$PSTATE_Z = "(Z (Sum (extract(32,0, $R0), 0x1:bv32)))" };
         goto (%ret);
       ];
       block %ret [ return; ]
    ];
    prog entry @main;
    |}]

let%expect_test "flag_clobbering" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
var $R0:bv64;
var $R1:bv64;
var $PSTATE_Z:bv1;

proc @main() -> ()
[
  block %main [
     $PSTATE_Z:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R0), bvnot(bvshl(extract(32,0, $R1), zero_extend(20, 0x0:bv12)))), 0x1:bv32), 0x0:bv32));
     assume eq($PSTATE_Z, 0x0:bv1);
     $R0:bv64 := bvadd($R0:bv64, 0xdeadbeef:bv64);
     assume eq($PSTATE_Z, 0x0:bv1);

     $PSTATE_Z:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R0), bvnot(bvshl(extract(32,0, $R1), zero_extend(20, 0x0:bv12)))), 0x1:bv32), 0x0:bv32));
     assume eq($PSTATE_Z, 0x0:bv1);
     $R1:bv64 := bvadd($R1:bv64, 0xdeadbeef:bv64);
     assume eq($PSTATE_Z, 0x0:bv1);
    goto (%ret);
  ];
  block %ret [ return; ]
];

prog entry @main;
    |}
  in
  let prog =
    lst.prog |> Program.map_procedures (fun _ -> annotate_assume_flags)
  in
  print_endline
  @@ Containers_pp.Pretty.to_string ~width:200 (Lang.Program.prog_pretty prog);
  [%expect
    {|
    var $R0:bv64;
    var $R1:bv64;
    var $PSTATE_Z:bv1;
    proc @main()  -> () {  }
      modifies $PSTATE_Z:bv1, $R0:bv64, $R1:bv64
      captures $PSTATE_Z:bv1, $R0:bv64, $R1:bv64

    [
       block %main [
         $PSTATE_Z:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R0), bvnot(bvshl(extract(32,0, $R1), zero_extend(20, 0x0:bv12)))), 0x1:bv32), 0x0:bv32));
         assume eq($PSTATE_Z, 0x0:bv1) { .flag_semantics_$PSTATE_Z = "(Z (Diff (extract(32,0, $R0), extract(32,0, $R1))))" };
         $R0:bv64 := bvadd($R0, 0xdeadbeef:bv64);
         assume eq($PSTATE_Z, 0x0:bv1);
         $PSTATE_Z:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R0), bvnot(bvshl(extract(32,0, $R1), zero_extend(20, 0x0:bv12)))), 0x1:bv32), 0x0:bv32));
         assume eq($PSTATE_Z, 0x0:bv1) { .flag_semantics_$PSTATE_Z = "(Z (Diff (extract(32,0, $R0), extract(32,0, $R1))))" };
         $R1:bv64 := bvadd($R1, 0xdeadbeef:bv64);
         assume eq($PSTATE_Z, 0x0:bv1);
         goto (%ret);
       ];
       block %ret [ return; ]
    ];
    prog entry @main;
    |}]

let%expect_test "flag_not_clobbering" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
var $R0:bv64;
var $PSTATE_Z:bv1;

proc @main() -> ()
[
  block %main [
     $PSTATE_Z:bv1 := 0x1:bv1;
     assume eq($PSTATE_Z, 0x0:bv1);
     $R0:bv64 := bvadd($R0:bv64, 0xdeadbeef:bv64);
     assume eq($PSTATE_Z, 0x0:bv1);
    goto (%ret);
  ];
  block %ret [ return; ]
];

prog entry @main;
    |}
  in
  let prog =
    lst.prog |> Program.map_procedures (fun _ -> annotate_assume_flags)
  in
  print_endline
  @@ Containers_pp.Pretty.to_string ~width:80 (Lang.Program.prog_pretty prog);
  [%expect
    {|
    var $R0:bv64;
    var $PSTATE_Z:bv1;
    proc @main()  -> () {  }
      modifies $PSTATE_Z:bv1, $R0:bv64
      captures $PSTATE_Z:bv1, $R0:bv64

    [
       block %main [
         $PSTATE_Z:bv1 := 0x1:bv1;
         assume eq($PSTATE_Z, 0x0:bv1) { .flag_semantics_$PSTATE_Z = "(Lit Always)" };
         $R0:bv64 := bvadd($R0, 0xdeadbeef:bv64);
         assume eq($PSTATE_Z, 0x0:bv1) { .flag_semantics_$PSTATE_Z = "(Lit Always)" };
         goto (%ret);
       ];
       block %ret [ return; ]
    ];
    prog entry @main;
    |}]

let%expect_test "rewrites" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
var $R0:bv64;
var $PSTATE_N:bv1;
var $PSTATE_Z:bv1;
var $PSTATE_C:bv1;
var $PSTATE_V:bv1;

proc @main() -> ()
[
  block %main [
     $PSTATE_V:bv1 := bvnot(booltobv1(eq(sign_extend(64, bvadd(bvadd($R0, 0xfffffffffffffffe:bv64), 0x1:bv64)), bvadd(bvadd(sign_extend(64, $R0), 0xfffffffffffffffffffffffffffffffe:bv128), 0x1:bv128))));
     $PSTATE_C:bv1 := bvnot(booltobv1(eq(zero_extend(64, bvadd(bvadd($R0, 0xfffffffffffffffe:bv64), 0x1:bv64)), bvadd(bvadd(zero_extend(64, $R0), 0xfffffffffffffffe:bv128), 0x1:bv128))));
     $PSTATE_Z:bv1 := booltobv1(eq(bvadd(bvadd($R0, 0xfffffffffffffffe:bv64), 0x1:bv64), 0x0:bv64));
     $PSTATE_N:bv1 := extract(64,63, bvadd(bvadd($R0, 0xfffffffffffffffe:bv64), 0x1:bv64));
     assume booland(eq($PSTATE_N, $PSTATE_V), eq($PSTATE_Z, 0x0:bv1));
    goto (%ret);
  ];
  block %ret [ return; ]
];

prog entry @main;
    |}
  in
  let prog = lst.prog |> Program.map_procedures (fun _ -> rewrite_conditions) in
  print_endline
  @@ Containers_pp.Pretty.to_string ~width:200 (Lang.Program.prog_pretty prog);
  [%expect
    {|
    var $R0:bv64;
    var $PSTATE_N:bv1;
    var $PSTATE_Z:bv1;
    var $PSTATE_C:bv1;
    var $PSTATE_V:bv1;
    proc @main()  -> () {  }
      modifies $PSTATE_C:bv1, $PSTATE_N:bv1, $PSTATE_V:bv1, $PSTATE_Z:bv1
      captures $PSTATE_C:bv1, $PSTATE_N:bv1, $PSTATE_V:bv1, $PSTATE_Z:bv1, $R0:bv64

    [
       block %main [
         $PSTATE_V:bv1 := bvnot(booltobv1(eq(sign_extend(64, bvadd(bvadd($R0, 0xfffffffffffffffe:bv64), 0x1:bv64)), bvadd(bvadd(sign_extend(64, $R0), 0xfffffffffffffffffffffffffffffffe:bv128), 0x1:bv128))));
         $PSTATE_C:bv1 := bvnot(booltobv1(eq(zero_extend(64, bvadd(bvadd($R0, 0xfffffffffffffffe:bv64), 0x1:bv64)), bvadd(bvadd(zero_extend(64, $R0), 0xfffffffffffffffe:bv128), 0x1:bv128))));
         $PSTATE_Z:bv1 := booltobv1(eq(bvadd(bvadd($R0, 0xfffffffffffffffe:bv64), 0x1:bv64), 0x0:bv64));
         $PSTATE_N:bv1 := extract(64,63, bvadd(bvadd($R0, 0xfffffffffffffffe:bv64), 0x1:bv64));
         assume bvslt(0x1:bv64, $R0);
         goto (%ret);
       ];
       block %ret [ return; ]
    ];
    prog entry @main;
    |}]

let%expect_test "pc_ite" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
var $R0:bv64;
var $PC:bv64;

proc @main() -> ()
[
  block %main [
    $PC:bv64 := if boolnot(eq($R0, 0x0:bv64)) then 0xce14:bv64 else 0xce08:bv64;
    goto (%b1);
  ];
  block %b1 [
    assert boolor(eq(0xce08:bv64, $PC), eq(0xce14:bv64, $PC));
    goto (%b2,%b3);
  ];
  block %b2 { .address = 52756 } [
    assume eq(0xce14:bv64, $PC);
    goto (%ret);
  ];
  block %b3 { .address = 52744 } [
    assume eq(0xce08:bv64, $PC);
    goto (%ret);
  ];
  block %ret [ return; ]
];

prog entry @main;
    |}
  in
  let prog = lst.prog |> Program.map_procedures (fun _ -> Pc_ite.transform) in
  print_endline
  @@ Containers_pp.Pretty.to_string ~width:200 (Lang.Program.prog_pretty prog);
  [%expect
    {|
    var $R0:bv64;
    var $PC:bv64;
    proc @main()  -> () {  }
      modifies $PC:bv64
      captures $PC:bv64, $R0:bv64

    [
       block %main [ $PC:bv64 := if boolnot(eq($R0, 0x0:bv64)) then 0xce14:bv64 else 0xce08:bv64; goto (%b1); ];
       block %b1 [ assert boolor(eq(0xce08:bv64, $PC), eq(0xce14:bv64, $PC)); goto (%block_1,%block); ];
       block %block [ guard boolnot(eq($R0, 0x0:bv64)); goto (%b2); ];
       block %b2 { .address = 52756 } [ assume eq(0xce14:bv64, $PC); goto (%ret); ];
       block %block_1 [ guard boolnot(boolnot(eq($R0, 0x0:bv64))); goto (%b3); ];
       block %b3 { .address = 52744 } [ assume eq(0xce08:bv64, $PC); goto (%ret); ];
       block %ret [ return; ]
    ];
    prog entry @main;
    |}]

let%expect_test "pc_ite_same_loc" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
var $R0:bv64;
var $PC:bv64;

proc @main() -> ()
[
  block %main [
    // If the pc location is the same it doesn't make sense to insert guards
    $PC:bv64 := if boolnot(eq($R0, 0x0:bv64)) then 0xce08:bv64 else 0xce08:bv64;
    goto (%b1);
  ];
  block %b1 [
    goto (%b2);
  ];
  block %b2 { .address = 52744 } [
    assume eq(0xce08:bv64, $PC);
    goto (%ret);
  ];
  block %ret [ return; ]
];

prog entry @main;
    |}
  in
  let prog = lst.prog |> Program.map_procedures (fun _ -> Pc_ite.transform) in
  print_endline
  @@ Containers_pp.Pretty.to_string ~width:200 (Lang.Program.prog_pretty prog);
  [%expect
    {|
    var $R0:bv64;
    var $PC:bv64;
    proc @main()  -> () {  }
      modifies $PC:bv64
      captures $PC:bv64, $R0:bv64

    [
       block %main [ $PC:bv64 := if boolnot(eq($R0, 0x0:bv64)) then 0xce08:bv64 else 0xce08:bv64; goto (%b1); ];
       block %b1 [ goto (%b2); ];
       block %b2 { .address = 52744 } [ assume eq(0xce08:bv64, $PC); goto (%ret); ];
       block %ret [ return; ]
    ];
    prog entry @main;
    |}]

let%expect_test "ccmp identification" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
memory shared $mem : (bv64 -> bv8);
var $PC:bv64;
prog entry @main {.invariants = ["GtirbArm"]};

proc @main()  -> () {  }
[
    block %main_code [
    assume eq(0x00:bv64, $PC);
    call @_aarch64_eval(0xeb04007f:bv32, 0x000:bv64) { .asm = "cmp x3, x4" };
    call @_aarch64_eval(0xfa4610a4:bv32, 0x004:bv64) { .asm = "ccmp x5, x6, #4, ne" };
    call @_aarch64_eval(0xfa48c0eb:bv32, 0x008:bv64) { .asm = "ccmp x7, x8, #11, gt" };
    call @_aarch64_eval(0x9a822020:bv32, 0x00c:bv64) { .asm = "csel x0, x1, x2, cs" };

    goto (%ret_1);
  ];
  block %ret_1 [ return; ]
];
    |}
  in
  let prog =
    lst.prog |> Transforms.Aslp.transform_program
    |> Program.map_procedures (fun _ -> annotate_assume_flags)
  in
  print_endline
  @@ Containers_pp.Pretty.to_string ~width:200 (Lang.Program.prog_pretty prog);
  [%expect
    {|
    var $R0:bv64;
    var $R1:bv64;
    var $R2:bv64;
    var $R3:bv64;
    var $R4:bv64;
    var $R5:bv64;
    var $R6:bv64;
    var $R7:bv64;
    var $R8:bv64;
    var $PSTATE_N:bv1;
    var $PSTATE_Z:bv1;
    var $PSTATE_C:bv1;
    var $PSTATE_V:bv1;
    var observable $mem:(bv64->bv8);
    var $PC:bv64;
    proc @main()  -> () {  }
      modifies $PC:bv64, $PSTATE_C:bv1, $PSTATE_N:bv1, $PSTATE_V:bv1, $PSTATE_Z:bv1, $R0:bv64
      captures $PC:bv64, $PSTATE_C:bv1, $PSTATE_N:bv1, $PSTATE_V:bv1, $PSTATE_Z:bv1, $R0:bv64, $R1:bv64, $R2:bv64, $R3:bv64, $R4:bv64, $R5:bv64, $R6:bv64, $R7:bv64, $R8:bv64

    [
       block %main_code [ assume eq(0x0:bv64, $PC); goto (%block); ];
       block %block { .asm = "cmp x3, x4" } [
         var local:bv64 := 0x0:bv64;
         var local_1:bv64 := 0x0:bv64;
         $PSTATE_V:bv1 := bvnot(booltobv1(eq(sign_extend(64, bvadd(bvadd($R3, bvnot(bvshl($R4, zero_extend(52, 0x0:bv12)))), 0x1:bv64)),
            bvadd(bvadd(sign_extend(64, $R3), sign_extend(64, bvnot(bvshl($R4, zero_extend(52, 0x0:bv12))))), 0x1:bv128))));
         $PSTATE_C:bv1 := bvnot(booltobv1(eq(zero_extend(64, bvadd(bvadd($R3, bvnot(bvshl($R4, zero_extend(52, 0x0:bv12)))), 0x1:bv64)),
            bvadd(bvadd(zero_extend(64, $R3), zero_extend(64, bvnot(bvshl($R4, zero_extend(52, 0x0:bv12))))), 0x1:bv128))));
         $PSTATE_Z:bv1 := booltobv1(eq(bvadd(bvadd($R3, bvnot(bvshl($R4, zero_extend(52, 0x0:bv12)))), 0x1:bv64), 0x0:bv64));
         $PSTATE_N:bv1 := extract(64,63, bvadd(bvadd($R3, bvnot(bvshl($R4, zero_extend(52, 0x0:bv12)))), 0x1:bv64));
         (var BranchTaken:bool := false, $PC:bv64 := 0x4:bv64);
         goto (%block_1);
       ];
       block %block_1 { .asm = "ccmp x5, x6, #4, ne" } [ var local_2:bool := false; var local_2:bool := eq($PSTATE_Z, 0x1:bv1); goto (%block_3,%block_2); ];
       block %block_2 [
         assume boolnot(local_2:bool) { .flag_semantics_$PSTATE_C = "(C (Diff ($R3, $R4)))"; .flag_semantics_$PSTATE_N = "(N (Diff ($R3, $R4)))"; .flag_semantics_$PSTATE_V = "(V (Diff ($R3, $R4)))";
             .flag_semantics_$PSTATE_Z = "(Z (Diff ($R3, $R4)))" };
         $PSTATE_V:bv1 := bvnot(booltobv1(eq(sign_extend(64, bvadd(bvadd($R5, bvnot($R6)), 0x1:bv64)), bvadd(bvadd(sign_extend(64, $R5), sign_extend(64, bvnot($R6))), 0x1:bv128))));
         $PSTATE_C:bv1 := bvnot(booltobv1(eq(zero_extend(64, bvadd(bvadd($R5, bvnot($R6)), 0x1:bv64)), bvadd(bvadd(zero_extend(64, $R5), zero_extend(64, bvnot($R6))), 0x1:bv128))));
         $PSTATE_Z:bv1 := booltobv1(eq(bvadd(bvadd($R5, bvnot($R6)), 0x1:bv64), 0x0:bv64));
         $PSTATE_N:bv1 := extract(64,63, bvadd(bvadd($R5, bvnot($R6)), 0x1:bv64));
         goto (%block_4);
       ];
       block %block_3 [
         assume boolnot(boolnot(local_2:bool)) { .flag_semantics_$PSTATE_C = "(C (Diff ($R3, $R4)))"; .flag_semantics_$PSTATE_N = "(N (Diff ($R3, $R4)))"; .flag_semantics_$PSTATE_V = "(V (Diff ($R3, $R4)))";
             .flag_semantics_$PSTATE_Z = "(Z (Diff ($R3, $R4)))" };
         $PSTATE_V:bv1 := 0x0:bv1;
         $PSTATE_C:bv1 := 0x0:bv1;
         $PSTATE_Z:bv1 := 0x1:bv1;
         $PSTATE_N:bv1 := 0x0:bv1;
         goto (%block_4);
       ];
       block %block_4 [ (var BranchTaken:bool := false, $PC:bv64 := 0x8:bv64); goto (%block_5); ];
       block %block_5 { .asm = "ccmp x7, x8, #11, gt" } [ var local_3:bool := false; var local_3:bool := booland(eq($PSTATE_N, $PSTATE_V), eq($PSTATE_Z, 0x0:bv1)); goto (%block_7,%block_6); ];
       block %block_6 [
         assume local_3:bool { .flag_semantics_$PSTATE_C = "(C (Ite (EQ {z = (Diff ($R3, $R4))}, Never, (Diff ($R5, $R6)))))";
             .flag_semantics_$PSTATE_N = "(N (Ite (EQ {z = (Diff ($R3, $R4))}, Never, (Diff ($R5, $R6)))))"; .flag_semantics_$PSTATE_V = "(V (Ite (EQ {z = (Diff ($R3, $R4))}, Never, (Diff ($R5, $R6)))))";
             .flag_semantics_$PSTATE_Z = "(Z (Ite (EQ {z = (Diff ($R3, $R4))}, Always, (Diff ($R5, $R6)))))" };
         $PSTATE_V:bv1 := bvnot(booltobv1(eq(sign_extend(64, bvadd(bvadd($R7, bvnot($R8)), 0x1:bv64)), bvadd(bvadd(sign_extend(64, $R7), sign_extend(64, bvnot($R8))), 0x1:bv128))));
         $PSTATE_C:bv1 := bvnot(booltobv1(eq(zero_extend(64, bvadd(bvadd($R7, bvnot($R8)), 0x1:bv64)), bvadd(bvadd(zero_extend(64, $R7), zero_extend(64, bvnot($R8))), 0x1:bv128))));
         $PSTATE_Z:bv1 := booltobv1(eq(bvadd(bvadd($R7, bvnot($R8)), 0x1:bv64), 0x0:bv64));
         $PSTATE_N:bv1 := extract(64,63, bvadd(bvadd($R7, bvnot($R8)), 0x1:bv64));
         goto (%block_8);
       ];
       block %block_7 [
         assume boolnot(local_3:bool) { .flag_semantics_$PSTATE_C = "(C (Ite (EQ {z = (Diff ($R3, $R4))}, Never, (Diff ($R5, $R6)))))";
             .flag_semantics_$PSTATE_N = "(N (Ite (EQ {z = (Diff ($R3, $R4))}, Never, (Diff ($R5, $R6)))))"; .flag_semantics_$PSTATE_V = "(V (Ite (EQ {z = (Diff ($R3, $R4))}, Never, (Diff ($R5, $R6)))))";
             .flag_semantics_$PSTATE_Z = "(Z (Ite (EQ {z = (Diff ($R3, $R4))}, Always, (Diff ($R5, $R6)))))" };
         $PSTATE_V:bv1 := 0x1:bv1;
         $PSTATE_C:bv1 := 0x1:bv1;
         $PSTATE_Z:bv1 := 0x0:bv1;
         $PSTATE_N:bv1 := 0x1:bv1;
         goto (%block_8);
       ];
       block %block_8 [ (var BranchTaken:bool := false, $PC:bv64 := 0xc:bv64); goto (%block_9); ];
       block %block_9 { .asm = "csel x0, x1, x2, cs" } [ var local_4:bv64 := 0x0:bv64; var local_4:bv64 := $R1; var local_5:bv64 := 0x0:bv64; var local_5:bv64 := $R2; goto (%block_11,%block_10); ];
       block %block_10 [
         assume eq($PSTATE_C, 0x1:bv1) { .flag_semantics_$PSTATE_C = "(C\n   (Ite (\n      GT {n = (Ite (EQ {z = (Diff ($R3, $R4))}, Never, (Diff ($R5, $R6))));\n        v = (Ite (EQ {z = (Diff ($R3, $R4))}, Never, (Diff ($R5, $R6))));\n        z = (Ite (EQ {z = (Diff ($R3, $R4))}, Always, (Diff ($R5, $R6))))},\n      (Diff ($R7, $R8)), Always)))";
             .flag_semantics_$PSTATE_N = "(N\n   (Ite (\n      GT {n = (Ite (EQ {z = (Diff ($R3, $R4))}, Never, (Diff ($R5, $R6))));\n        v = (Ite (EQ {z = (Diff ($R3, $R4))}, Never, (Diff ($R5, $R6))));\n        z = (Ite (EQ {z = (Diff ($R3, $R4))}, Always, (Diff ($R5, $R6))))},\n      (Diff ($R7, $R8)), Always)))";
             .flag_semantics_$PSTATE_V = "(V\n   (Ite (\n      GT {n = (Ite (EQ {z = (Diff ($R3, $R4))}, Never, (Diff ($R5, $R6))));\n        v = (Ite (EQ {z = (Diff ($R3, $R4))}, Never, (Diff ($R5, $R6))));\n        z = (Ite (EQ {z = (Diff ($R3, $R4))}, Always, (Diff ($R5, $R6))))},\n      (Diff ($R7, $R8)), Always)))";
             .flag_semantics_$PSTATE_Z = "(Z\n   (Ite (\n      GT {n = (Ite (EQ {z = (Diff ($R3, $R4))}, Never, (Diff ($R5, $R6))));\n        v = (Ite (EQ {z = (Diff ($R3, $R4))}, Never, (Diff ($R5, $R6))));\n        z = (Ite (EQ {z = (Diff ($R3, $R4))}, Always, (Diff ($R5, $R6))))},\n      (Diff ($R7, $R8)), Never)))" };
         $R0:bv64 := local_4:bv64;
         goto (%block_12);
       ];
       block %block_11 [
         assume boolnot(eq($PSTATE_C, 0x1:bv1)) { .flag_semantics_$PSTATE_C = "(C\n   (Ite (\n      GT {n = (Ite (EQ {z = (Diff ($R3, $R4))}, Never, (Diff ($R5, $R6))));\n        v = (Ite (EQ {z = (Diff ($R3, $R4))}, Never, (Diff ($R5, $R6))));\n        z = (Ite (EQ {z = (Diff ($R3, $R4))}, Always, (Diff ($R5, $R6))))},\n      (Diff ($R7, $R8)), Always)))";
             .flag_semantics_$PSTATE_N = "(N\n   (Ite (\n      GT {n = (Ite (EQ {z = (Diff ($R3, $R4))}, Never, (Diff ($R5, $R6))));\n        v = (Ite (EQ {z = (Diff ($R3, $R4))}, Never, (Diff ($R5, $R6))));\n        z = (Ite (EQ {z = (Diff ($R3, $R4))}, Always, (Diff ($R5, $R6))))},\n      (Diff ($R7, $R8)), Always)))";
             .flag_semantics_$PSTATE_V = "(V\n   (Ite (\n      GT {n = (Ite (EQ {z = (Diff ($R3, $R4))}, Never, (Diff ($R5, $R6))));\n        v = (Ite (EQ {z = (Diff ($R3, $R4))}, Never, (Diff ($R5, $R6))));\n        z = (Ite (EQ {z = (Diff ($R3, $R4))}, Always, (Diff ($R5, $R6))))},\n      (Diff ($R7, $R8)), Always)))";
             .flag_semantics_$PSTATE_Z = "(Z\n   (Ite (\n      GT {n = (Ite (EQ {z = (Diff ($R3, $R4))}, Never, (Diff ($R5, $R6))));\n        v = (Ite (EQ {z = (Diff ($R3, $R4))}, Never, (Diff ($R5, $R6))));\n        z = (Ite (EQ {z = (Diff ($R3, $R4))}, Always, (Diff ($R5, $R6))))},\n      (Diff ($R7, $R8)), Never)))" };
         $R0:bv64 := local_5:bv64;
         goto (%block_12);
       ];
       block %block_12 [ (var BranchTaken:bool := false, $PC:bv64 := 0x10:bv64); goto (%ret_1); ];
       block %ret_1 [ return; ]
    ];
    prog entry @main;
    |}]

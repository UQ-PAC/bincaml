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
         $PSTATE_V:bv1 := 0x0:bv1 { .flag_semantics_$PSTATE_V = "(Const Never)" };
         $PSTATE_C:bv1 := 0x0:bv1 { .flag_semantics_$PSTATE_C = "(Const Never)" };
         $PSTATE_Z:bv1 := 0x1:bv1 { .flag_semantics_$PSTATE_Z = "(Const Always)" };
         $PSTATE_N:bv1 := 0x0:bv1 { .flag_semantics_$PSTATE_N = "(Const Never)" };
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
         assume eq($PSTATE_Z, 0x0:bv1) { .flag_semantics_$PSTATE_Z = "(Const Always)" };
         $R0:bv64 := bvadd($R0, 0xdeadbeef:bv64);
         assume eq($PSTATE_Z, 0x0:bv1) { .flag_semantics_$PSTATE_Z = "(Const Always)" };
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

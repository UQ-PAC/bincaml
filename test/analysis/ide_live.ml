open Analysis.Ide_live
open Bincaml_util.Common

let print_lives r proc =
  print_endline @@ ID.to_string proc;
  r ~proc_id:proc Lang.Procedure.Vert.Entry
  |> Option.get_exn_or "No entry node"
  |> VarMap.iter (fun v _ -> print_endline @@ Var.to_string v)

let%expect_test "intra_checks" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
memory shared $mem : (bv64 -> bv8);

prog entry @main;

proc @main () -> ()
[
    block %main_entry [
        goto(%main_1, %main_2);
    ];
    block %main_1 [
        $x:bv64 := bvadd($x:bv64, a:bv64);
        assert eq($x:bv64,0);
        assume neq(e:bv64,0);
        goto(%main_return);
    ];
    block %main_2 [
        $y:bv64 := load le $mem b:bv64 64;
        $z:bv64 := c:bv64;
        store le $mem $z:bv64 d:bv64 64;
        goto(%main_return);
    ];
    block %main_return [
        return();
    ];
];
    |}
  in
  let program = lst.prog in
  let _, results = IDELiveAnalysis.solve program in
  let main = program.entry_proc |> Option.get_exn_or "No entry proc" in
  print_lives results main;
  [%expect
    {|
    @main
    $mem:(bv64->bv8)
    $x:bv64
    a:bv64
    e:bv64
    b:bv64
    c:bv64
    d:bv64
    |}]

let%expect_test "simple_call" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
prog entry @main;

proc @main () -> ()
[
    block %main_entry [
        var (a:bv64) := call @fun(b:bv64, b: bv64);
        var (x:bv64) := call @fun(a:bv64, b: bv64);
        assert eq(x:bv64, bvadd(b:bv64, b:bv64));
        assert eq(y:bv64, 0);
        return ();
    ];
];

proc @fun (c:bv64, d:bv64) -> (out:bv64)
[
    block %fun_entry [
        return (bvadd(c:bv64, d:bv64));
    ];
];
    |}
  in
  let program = lst.prog in
  let _, results = IDELiveAnalysis.solve program in
  ID.Map.iter (fun id _ -> print_lives results id) program.procs;
  [%expect
    {|
    @main
    b:bv64
    y:bv64
    @fun
    c:bv64
    d:bv64
    |}]

let%expect_test "nested_call" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
prog entry @main;

var $global:bv64;

proc @main () -> ()
[
    block %main_entry [
        var (a:bv64) := call @fun1(b:bv64, b: bv64);
        var (x:bv64) := call @fun1(a:bv64, b: bv64);
        assert eq(x:bv64, bvadd(b:bv64, b:bv64));
        assert eq(y:bv64, 0);
        return ();
    ];
];

proc @fun1 (c:bv64, d:bv64) -> (out:bv64)
[
    block %fun1_entry [
        var (e:bv64) := call @fun2 (d:bv64);
        return (bvadd(c:bv64, e:bv64));
    ];
];

proc @fun2 (f:bv64) -> (out2:bv64)
[
    block %fun2_entry [
        var g:bv64 := $global:bv64;
        return (bvadd(f:bv64, g:bv64));
    ];
];
    |}
  in
  let program = lst.prog in
  let _, results = IDELiveAnalysis.solve program in
  ID.Map.iter (fun id _ -> print_lives results id) program.procs;
  [%expect
    {|
    @main
    b:bv64
    y:bv64
    $global:bv64
    @fun1
    c:bv64
    d:bv64
    $global:bv64
    @fun2
    $global:bv64
    f:bv64
    |}]

let%expect_test "mutually_recursive" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
prog entry @main;

var $global:bv64;

proc @main () -> ()
[
    block %main_entry [
        var (a:bv64) := call @fun2(b:bv64);
        var (x:bv64) := call @fun1(a:bv64, b: bv64);
        assert eq(x:bv64, bvadd(b:bv64, b:bv64));
        assert eq(y:bv64, 0);
        return ();
    ];
];

proc @fun1 (c:bv64, d:bv64) -> (out:bv64)
[
    block %fun1_entry [
        var (e:bv64) := call @fun2 (d:bv64);
        return (bvsub(c:bv64, e:bv64));
    ];
];

proc @fun2 (f:bv64) -> (out2:bv64)
[
    block %fun2_entry [
        goto(%fun2_a, %fun2_b);
    ];
    block %fun2_a [
        guard bvsle(f:bv64, 0);
        var (g:bv64) := call @fun1(f:bv64, 1);
        goto (%fun2_return);
    ];
    block %fun2_b [
        guard bvsgt(f:bv64, 0);
        var g:bv64 := $global:bv64;
        goto (%fun2_return);
    ];
    block %fun2_return [
        return (bvadd(f:bv64, g:bv64));
    ];
];
    |}
  in
  let program = lst.prog in
  let _, results = IDELiveAnalysis.solve program in
  ID.Map.iter (fun id _ -> print_lives results id) program.procs;
  [%expect
    {|
    @main
    b:bv64
    y:bv64
    $global:bv64
    @fun1
    c:bv64
    d:bv64
    $global:bv64
    @fun2
    $global:bv64
    f:bv64
    |}]

let%expect_test "stub" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
memory shared $mem : (bv64 -> bv8);

var $g: bv64;

prog entry @main;

proc @main () -> ()
[
    block %main_entry [
        call @stub();
        return();
    ];
];

proc @stub() -> ();
    |}
  in
  let program = lst.prog in
  let _, results = IDELiveAnalysis.solve program in
  let main = program.entry_proc |> Option.get_exn_or "No entry proc" in
  print_lives results main;
  [%expect {|
    @main
    $mem:(bv64->bv8)
    $g:bv64
    |}]

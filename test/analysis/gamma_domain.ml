open Analysis.Gamma_domain
open Bincaml_util.Common

let intra_results proc = DFGAnalysis.flow_insensitive proc
let inter_results prog = IDEAnalysis.solve prog

let print_intra_results res =
  DFGAnalysis.D.to_iter res
  |> Iter.to_string (fun (v, s) -> Var.name v ^ "->" ^ GammaSet.show s)
  |> print_endline

let print_inter_results =
  ID.Map.iter (fun pid res ->
      print_endline @@ ID.name pid;
      VarMap.to_iter res
      |> Iter.to_string (fun (v, s) ->
          Var.name v ^ "->" ^ IDEDomain.Value.show s)
      |> print_endline)

let%expect_test "loop" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
prog entry @main;
proc @main(a_in:bv64, b_in:bv64, x_in:bv64)  -> (x_out:bv64) {  }


[
   block %inputs [
     (var x_1:bv64 := x_in:bv64, var a_1:bv64 := a_in:bv64,
      var b_1:bv64 := b_in:bv64);
     goto (%main_entry);
   ];
   block %main_entry (
     var x_2:bv64 := phi(%main_2 -> x_3:bv64, %inputs -> x_1:bv64),
     var a_2:bv64 := phi(%main_2 -> a_2:bv64, %inputs -> a_1:bv64),
     var b_2:bv64 := phi(%main_2 -> b_2:bv64, %inputs -> b_1:bv64)
   ) [ goto (%main_2,%main_1); ];
   block %main_1 [
     var x_4:bv64 := bvadd(x_2:bv64, a_2:bv64);
     goto (%main_return);
   ];
   block %main_2 [
     var x_3:bv64 := bvadd(x_2:bv64, b_2:bv64);
     goto (%main_return,%main_entry);
   ];
   block %main_return (
     var x_5:bv64 := phi(%main_2 -> x_3:bv64, %main_2 -> x_3:bv64,
        %main_1 -> x_4:bv64)
   ) [ nop; goto (%returns); ];
   block %returns [ var x_out:bv64 := x_5:bv64; return; ]
];
    |}
  in
  let prog = lst.prog in
  let main =
    prog.entry_proc |> Option.get_exn_or "No entry proc" |> Program.proc prog
  in
  let intra = intra_results main in
  print_intra_results intra;
  let _, results = inter_results prog in
  print_inter_results results;
  [%expect
    {|
    a_in->{a_in}, b_in->{b_in}, x_in->{x_in}, x_out->{a_in,b_in,x_in}, x_1->{x_in}, a_1->{a_in}, b_1->{b_in}, x_3->{b_in,x_in}, x_2->{b_in,x_in}, a_2->{a_in}, b_2->{b_in}, x_4->{a_in,b_in,x_in}, x_5->{a_in,b_in,x_in}
    @main
    a_in->{a_in}, b_in->{b_in}, x_in->{x_in}, x_out->{a_in,b_in,x_in}, x_1->{x_in}, a_1->{a_in}, b_1->{b_in}, x_3->{b_in,x_in}, x_2->{b_in,x_in}, a_2->{a_in}, b_2->{b_in}, x_4->{a_in,b_in,x_in}, x_5->{a_in,b_in,x_in}
    |}]

let%expect_test "loop" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
prog entry @main;
proc @main(b:bv64, global_in:bv64, y:bv64)  -> () {  }


[
   block %inputs [ var global_1:bv64 := global_in:bv64; goto (%main_entry); ];
   block %main_entry [
     (var a:bv64=out2) :=
     call @fun2(f=b:bv64, global_in=global_1:bv64);
     (var x:bv64=out) :=
     call @fun1(c=a:bv64, d=b:bv64, global_in=global_1:bv64);
     (var b_1:bv64 := b:bv64, var x_1:bv64 := x:bv64);
     assert eq(x_1:bv64, bvadd(b_1:bv64, b_1:bv64));
     var y_1:bv64 := y:bv64;
     assert eq(y_1:bv64, 0);
     nop;
     return;
   ]
];
proc @fun1(c:bv64, d:bv64, global_in:bv64)  -> (out:bv64) {  }


[
   block %inputs [ var global_1:bv64 := global_in:bv64; goto (%fun1_entry); ];
   block %fun1_entry [
     (var e:bv64=out2) :=
     call @fun2(f=d:bv64, global_in=global_1:bv64);
     var out:bv64 := bvsub(c:bv64, e:bv64);
     return;
   ]
];
proc @fun2(f:bv64, global_in:bv64)  -> (out2:bv64) {  }


[
   block %inputs [ var global_1:bv64 := global_in:bv64; goto (%fun2_entry); ];
   block %fun2_entry [ goto (%fun2_b,%fun2_a); ];
   block %fun2_a [
     var f_2:bv64 := f:bv64;
     guard bvsle(f_2:bv64, 0);
     (var g_2:bv64=out) :=
     call @fun1(c=f_2:bv64, d=1, global_in=global_1:bv64);
     goto (%fun2_return);
   ];
   block %fun2_b [
     var f_1:bv64 := f:bv64;
     guard boolnot(bvsle(f_1:bv64, 0));
     var g_1:bv64 := global_1:bv64;
     goto (%fun2_return);
   ];
   block %fun2_return (
     var f_3:bv64 := phi(%fun2_b -> f_1:bv64, %fun2_a -> f_2:bv64),
     var g_3:bv64 := phi(%fun2_b -> g_1:bv64, %fun2_a -> g_2:bv64)
   ) [ var out2:bv64 := bvadd(f_3:bv64, g_3:bv64); return; ]
];
      |}
  in
  let prog = lst.prog in
  let main =
    prog.entry_proc |> Option.get_exn_or "No entry proc" |> Program.proc prog
  in
  let intra = intra_results main in
  print_intra_results intra;
  let _, results = inter_results prog in
  print_inter_results results;
  [%expect
    {|
    x_1->⊤, b_1->{b}, b->{b}, global_in->{global_in}, y->{y}, global_1->{global_in}, a->⊤, x->⊤, y_1->{y}
    @main
    x_1->{b,global_in}, b_1->{b}, b->{b}, global_in->{global_in}, y->{y}, global_1->{global_in}, a->{b,global_in}, x->{b,global_in}, y_1->{y}
    @fun1
    global_in->{global_in}, c->{c}, d->{d}, out->{global_in,c,d}, global_1->{global_in}, e->{global_in,d}
    @fun2
    global_in->{global_in}, f->{f}, out2->{global_in,f}, global_1->{global_in}, f_2->{f}, g_2->{global_in,f}, f_1->{f}, g_1->{global_in}, f_3->{f}, g_3->{global_in,f}
    |}]

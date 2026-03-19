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

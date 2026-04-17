open Bincaml_util.Common
module Dsa = Transforms.Dsa

let%expect_test "dsa basic" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
prog entry @main;

proc @main (x: bv64) -> (out: bv64)
[
    block %main_entry [
      goto(%main_1, %main_2);
    ];
    block %main_1 [
      guard(boolnot(eq(x, 0:bv64)));
      var x1:bv64 := 0:bv64;
      goto(%main_return);
    ];
    block %main_2 [
      guard(eq(x, 0:bv64));
      var x2:bv64 := 1:bv64;
      goto(%main_return);
    ];
    block %main_return
    (
      var y:bv64 := phi(%main_1 -> x1:bv64, %main_2 -> x2:bv64)
    )
    [
      return(y);
    ];
];
    |}
  in
  let program = lst.prog in
  let proc = Lang.Program.entry_proc_exn program in
  let graph =
    Option.get_exn_or "expected proc graph" @@ Lang.Procedure.graph proc
  in
  let dsa_blocks = Iter.to_list (Dsa.identify_needed_dsa_blocks graph) in
  List.iter
    (fun dsa_block -> print_endline (Dsa.show_dsa_block dsa_block))
    dsa_blocks;
  [%expect
    {|
    { Dsa.src = ("%main_1", 0); tgt = ("%main_return", 3);
      phi_assignments = [({id=20 ; data=y:bv64}, {id=18 ; data=x1:bv64})];
      assumes =  }
    { Dsa.src = ("%main_2", 1); tgt = ("%main_return", 3);
      phi_assignments = [({id=20 ; data=y:bv64}, {id=19 ; data=x2:bv64})];
      assumes =  }
    |}];

  (* let proc_with_intermediates = Dsa.identify_needed_phi_edges graph |> Dsa.add_phi_edges proc in *)
  (* Lang.Program.output_proc_pretty stdout proc_with_intermediates; *)
  let transformed = Dsa.dsa proc in
  Lang.Program.output_proc_pretty stdout transformed;
  [%expect
    {|
    proc @main(x:bv64)  -> (out:bv64) {  }


    [
       block %main_entry [ goto (%main_2,%main_1); ];
       block %main_1 [
         guard boolnot(eq(x, 0x0:bv64));
         var x1:bv64 := 0x0:bv64;
         goto (%main_return__phi);
       ];
       block %main_return__phi [ var y:bv64 := x1; goto (%main_return); ];
       block %main_2 [
         guard eq(x, 0x0:bv64);
         var x2:bv64 := 0x1:bv64;
         goto (%main_return__phi_1);
       ];
       block %main_return__phi_1 [ var y:bv64 := x2; goto (%main_return); ];
       block %main_return [ var out:bv64 := y; return; ]
    ]
    |}]

let%expect_test "dsa 2" =
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

  let program = lst.prog in
  let proc = Lang.Program.entry_proc_exn program in
  let transformed = Dsa.dsa proc in
  Lang.Program.output_proc_pretty stdout transformed;
  [%expect
    {|
    proc @main(a_in:bv64, b_in:bv64, x_in:bv64)  -> (x_out:bv64) {  }


    [
       block %inputs [
         (var x_1:bv64 := x_in, var a_1:bv64 := a_in, var b_1:bv64 := b_in);
         goto (%main_entry__phi_1);
       ];
       block %main_entry__phi_1 [
         (var x_2:bv64 := x_1, var a_2:bv64 := a_1, var b_2:bv64 := b_1);
         goto (%main_entry);
       ];
       block %main_entry [ goto (%main_1,%main_2); ];
       block %main_2 [
         var x_3:bv64 := bvadd(x_2, b_2);
         goto (%main_return__phi,%main_entry__phi);
       ];
       block %main_entry__phi [
         (var x_2:bv64 := x_3, var a_2:bv64 := a_2, var b_2:bv64 := b_2);
         goto (%main_entry);
       ];
       block %main_return__phi [ var x_5:bv64 := x_3; goto (%main_return); ];
       block %main_1 [
         var x_4:bv64 := bvadd(x_2, a_2);
         goto (%main_return__phi_1);
       ];
       block %main_return__phi_1 [ var x_5:bv64 := x_4; goto (%main_return); ];
       block %main_return [ goto (%returns); ];
       block %returns [ var x_out:bv64 := x_5; return; ]
    ]
    |}]

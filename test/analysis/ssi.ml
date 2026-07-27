open Lang
open Containers
open Common
open Transforms.Into_ssi

let%expect_test "test_SSIFY_2" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
prog entry @main;

proc @main() -> (out:bv64)
[
    block %main_entry [
      var nam:bv64 := 12345:bv64;
      var v:bv64 := 0:bv64;
      (var v:bv64) := call @OX();
      goto(%main_1, %main_2);
    ];

    block %main_1
    [
      var nam:bv64 := bvadd(v:bv64, 10:bv64);
      var v:bv64 := bvadd(v, v);
      goto(%main_return, %main_1);
    ];

    block %main_2
    [
      var nam:bv64 := bvadd(nam:bv64, v:bv64);
      goto(%main_2_1);
    ];

    block %main_2_1
    [
      var nam:bv64 := bvor(v:bv64, 0xffffffff:bv64);
      var v:bv64 := bvadd(v:bv64, nam);
      goto(%main_return);
    ];

    block %main_return
      [
      var v:bv64 := bvadd(v, nam:bv64);
      return(v);
      ];
];

proc @OX() -> (OX_out:bv64)
[
    block %OX_entry [
      var OX_out:bv64 := 0:bv64;
      return;
    ];
];

proc @OY() -> (OY_out:bv64)
[
    block %OY_entry [
      var OY_out:bv64 := 1:bv64;
      return;
    ];
];
    |}
  in
  let program = lst.prog in
  let ssi_prog = ssify_prog program in
  Format.printf "%a\n" Containers_pp.pp (Program.prog_pretty ssi_prog);
  [%expect
    {|
    proc @main()  -> (out:bv64) {  }


    [
       block %main_entry [
         var nam_1:bv64 := 0x3039:bv64;
         var v_1:bv64 := 0x0:bv64;
         (var v_2:bv64=OX_out) := call @OX();
         goto (%main_2,%main_1);
       ];
       block %main_1 (
         var v_3:bv64 := phi(%main_1 -> v_4:bv64, %main_entry -> v_2:bv64)
       ) [
         var nam_2:bv64 := bvadd(v_3:bv64, 0xa:bv64);
         var v_4:bv64 := bvadd(v_3:bv64, v_3:bv64);
         goto (%main_return,%main_1);
       ];
       block %main_2 (
         var v_5:bv64 := phi(%main_entry -> v_2:bv64),
         var nam_3:bv64 := phi(%main_entry -> nam_1:bv64)
       ) [ var nam_4:bv64 := bvadd(nam_3:bv64, v_5:bv64); goto (%main_2_1); ];
       block %main_2_1 [
         var nam_5:bv64 := bvor(v_5:bv64, 0xffffffff:bv64);
         var v_6:bv64 := bvadd(v_5:bv64, nam_5:bv64);
         goto (%main_return);
       ];
       block %main_return (
         var v_7:bv64 := phi(%main_2_1 -> v_6:bv64, %main_1 -> v_4:bv64),
         var nam_6:bv64 := phi(%main_2_1 -> nam_5:bv64, %main_1 -> nam_2:bv64)
       ) [
         var v_8:bv64 := bvadd(v_7:bv64, nam_6:bv64);
         var out_3:bv64 := v_8:bv64;
         var out:bv64 := out_3:bv64;
         return;
       ]
    ];
    proc @OX()  -> (OX_out:bv64) {  }


    [
       block %OX_entry [
         var OX_out_1:bv64 := 0x0:bv64;
         var OX_out:bv64 := OX_out_1:bv64;
         return;
       ]
    ];
    proc @OY()  -> (OY_out:bv64) {  }


    [
       block %OY_entry [
         var OY_out_1:bv64 := 0x1:bv64;
         var OY_out:bv64 := OY_out_1:bv64;
         return;
       ]
    ];
    prog entry @main;
    |}]

let%expect_test "test_rename" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
prog entry @main;

proc @main(i:bv64) -> (out:bv64)
[
    block %main_entry [
      var v:bv64 := 0:bv64;
      (var v:bv64) := call @OX();
      goto(%main_1, %main_2);
    ];

    block %main_1
    (
      var v:bv64 := phi(%main_entry -> v:bv64)
    )
    [
      guard(bvsmod(i, 2:bv64));
      var nam:bv64 := bvadd(v:bv64, 10:bv64);
      var v:bv64 := bvadd(v, 69);
      var tmp:bv64 := bvadd(i, 1:bv64);
      goto(%main_return);
    ];

    block %main_2
    (
      var v:bv64 := phi(%main_entry -> v:bv64)
    )
    [
      guard(boolnot(bvsmod(i, 2:bv64)));
      (var v:bv64) := call @OY();
      var v:bv64 := bvadd(v, 420);
      goto(%main_2_1);
    ];

    block %main_2_1
    [
      var v:bv64 := v:bv64;
      var namnam:bv64 := bvor(v:bv64, 0xffffffff:bv64);
      goto(%main_return);
    ];

    block %main_return
    (
      var v:bv64 := phi(%main_1 -> v:bv64, %main_2_1 -> v:bv64)
    )
      [
      var v:bv64 := bvadd(v, 1:bv64);
      return(v);
      ];
];

proc @OX() -> (OX_out:bv64)
[
    block %OX_entry [
      var OX_out:bv64 := 0:bv64;
      return;
    ];
];

proc @OY() -> (OY_out:bv64)
[
    block %OY_entry [
      var OY_out:bv64 := 1:bv64;
      return;
    ];
];

    |}
  in
  let program = lst.prog in
  let proc = Program.entry_proc_exn program in
  let v =
    match Procedure.lookup_local_decl proc "v" with
    | Some v -> v
    | None -> failwith "Bleh"
  in
  let (info : Datastructures.ssi_info) =
    {
      proc;
      non_actual_insts = Datastructures.InstructionSet.empty;
      defs = Datastructures.DefUseMap.empty;
      uses = Datastructures.DefUseMap.empty;
      web = VarSet.empty;
    }
  in
  let bot_var =
    Var.create Bincaml_util.Unicode.bot_char (Var.typ v) ~scope:(Var.scope v)
  in
  let cfg =
    match Procedure.graph proc with Some g -> g | None -> Procedure.G.empty
  in
  let dom_functions = Datastructures.Dom.compute_all cfg Procedure.Vert.Entry in
  let proc' = Renaming.rename v bot_var cfg dom_functions info in
  Program.output_proc_pretty stdout proc'.proc;
  [%expect
    {|
    proc @main(i:bv64)  -> (out:bv64) {  }


    [
       block %main_entry [
         var v_1:bv64 := 0x0:bv64;
         (var v_2:bv64=OX_out) := call @OX();
         goto (%main_2,%main_1);
       ];
       block %main_1 ( var v_3:bv64 := phi(%main_entry -> v_2:bv64) ) [
         guard bvsmod(i:bv64, 0x2:bv64);
         var nam:bv64 := bvadd(v_3:bv64, 0xa:bv64);
         var v_4:bv64 := bvadd(v_3:bv64, 69);
         var tmp:bv64 := bvadd(i:bv64, 0x1:bv64);
         goto (%main_return);
       ];
       block %main_2 ( var v_5:bv64 := phi(%main_entry -> v_2:bv64) ) [
         guard boolnot(bvsmod(i:bv64, 0x2:bv64));
         (var v_6:bv64=OY_out) := call @OY();
         var v_7:bv64 := bvadd(v_6:bv64, 420);
         goto (%main_2_1);
       ];
       block %main_2_1 [
         var v_8:bv64 := v_7:bv64;
         var namnam:bv64 := bvor(v_8:bv64, 0xffffffff:bv64);
         goto (%main_return);
       ];
       block %main_return (
         var v_9:bv64 := phi(%main_1 -> v_4:bv64, %main_2_1 -> v_8:bv64)
       ) [
         var v_10:bv64 := bvadd(v_9:bv64, 0x1:bv64);
         var out:bv64 := v_10:bv64;
         return;
       ]
    ]
    |}]

let%expect_test "test_SSIFY" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
prog entry @main;

proc @main(i:bv64) -> (out:bv64)
[
    block %main_entry [
      var v:bv64 := 0:bv64;
      (var v:bv64) := call @OX();
      var namnam:bv64 := 12345:bv64;
      goto(%main_1, %main_2);
    ];

    block %main_1
    [
      guard(bvsmod(i, 2:bv64));
      var nam:bv64 := bvadd(v:bv64, 10:bv64);
      var v:bv64 := bvadd(v, v);
      var tmp:bv64 := bvadd(i, 1:bv64);
      var i:bv64 := tmp:bv64;
      goto(%main_return, %main_1);
    ];

    block %main_2
    [
      guard(boolnot(bvsmod(i, 2:bv64)));
      var nam:bv64 := bvadd(namnam:bv64, v:bv64);
      goto(%main_2_1);
    ];

    block %main_2_1
    [
      var namnam:bv64 := bvor(v:bv64, 0xffffffff:bv64);
      var v:bv64 := bvadd(v:bv64, namnam);
      goto(%main_return);
    ];

    block %main_return
      [
      var v:bv64 := bvadd(v, 1:bv64);
      return(v);
      ];
];

proc @OX() -> (OX_out:bv64)
[
    block %OX_entry [
      var OX_out:bv64 := 0:bv64;
      return;
    ];
];

proc @OY() -> (OY_out:bv64)
[
    block %OY_entry [
      var OY_out:bv64 := 1:bv64;
      return;
    ];
];
    |}
  in
  let program = lst.prog in
  let ssi_prog = ssify_prog program in
  Format.printf "%a\n" Containers_pp.pp (Program.prog_pretty ssi_prog);
  [%expect
    {|
    proc @main(i:bv64)  -> (out:bv64) {  }


    [
       block %main_entry [
         var v_1:bv64 := 0x0:bv64;
         (var v_2:bv64=OX_out) := call @OX();
         var namnam_1:bv64 := 0x3039:bv64;
         goto (%main_2,%main_1);
       ];
       block %main_1 (
         var i_1:bv64 := phi(%main_1 -> i_2:bv64, %main_entry -> i:bv64),
         var v_3:bv64 := phi(%main_1 -> v_4:bv64, %main_entry -> v_2:bv64)
       ) [
         guard bvsmod(i_1:bv64, 0x2:bv64);
         var nam_1:bv64 := bvadd(v_3:bv64, 0xa:bv64);
         var v_4:bv64 := bvadd(v_3:bv64, v_3:bv64);
         var tmp_1:bv64 := bvadd(i_1:bv64, 0x1:bv64);
         var i_2:bv64 := tmp_1:bv64;
         goto (%main_return,%main_1);
       ];
       block %main_2 (
         var i_3:bv64 := phi(%main_entry -> i:bv64),
         var v_5:bv64 := phi(%main_entry -> v_2:bv64),
         var namnam_3:bv64 := phi(%main_entry -> namnam_1:bv64)
       ) [
         guard boolnot(bvsmod(i_3:bv64, 0x2:bv64));
         var nam_2:bv64 := bvadd(namnam_3:bv64, v_5:bv64);
         goto (%main_2_1);
       ];
       block %main_2_1 [
         var namnam_4:bv64 := bvor(v_5:bv64, 0xffffffff:bv64);
         var v_6:bv64 := bvadd(v_5:bv64, namnam_4:bv64);
         goto (%main_return);
       ];
       block %main_return (
         var v_7:bv64 := phi(%main_2_1 -> v_6:bv64, %main_1 -> v_4:bv64)
       ) [
         var v_8:bv64 := bvadd(v_7:bv64, 0x1:bv64);
         var out_3:bv64 := v_8:bv64;
         var out:bv64 := out_3:bv64;
         return;
       ]
    ];
    proc @OX()  -> (OX_out:bv64) {  }


    [
       block %OX_entry [
         var OX_out_1:bv64 := 0x0:bv64;
         var OX_out:bv64 := OX_out_1:bv64;
         return;
       ]
    ];
    proc @OY()  -> (OY_out:bv64) {  }


    [
       block %OY_entry [
         var OY_out_1:bv64 := 0x1:bv64;
         var OY_out:bv64 := OY_out_1:bv64;
         return;
       ]
    ];
    prog entry @main;
    |}]

let%expect_test "test_multiple_conditionals" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
prog entry @main;
  proc @main(i:bv64) -> (out:bv64)
  [
    block %main_entry
    [
      var v:bv64 := 0;
      goto(%main_1, %main_2);
    ];

    block %main_1
    [
      guard(bvsmod(i, 2:bv64));
      var v:bv64 := bvadd(v, 2);
      goto(%main_3, %main_4);
    ];

    block %main_3
    [
      guard(bvsmod(i:bv64, 2:bv64));
      var v := bvadd(v:bv64, 3:bv64);
      goto(%main_return);
    ];

    block %main_4
    [
      guard(boolnot(bvsmod(i:bv64, 2:bv64)));
      var v := bvadd(v:bv64, 4:bv64);
      goto(%main_return);
    ];

    block %main_2
    [
      guard(boolnot(bvsmod(i:bv64, 2:bv64)));
      var v:bv64 := bvadd(v:bv64, 1);
      goto(%main_return);
    ];

    block %main_return
      [
      var v:bv64 := bvadd(v, 1:bv64);
      return(v);
      ];
  ];
|}
  in
  let program = lst.prog in
  let ssi_prog = ssify_prog program in
  Format.printf "%a\n" Containers_pp.pp (Program.prog_pretty ssi_prog);
  [%expect
    {|
    proc @main(i:bv64)  -> (out:bv64) {  }


    [
       block %main_entry [ var v_1:bv64 := 0; goto (%main_2,%main_1); ];
       block %main_1 (
         var i_1:bv64 := phi(%main_entry -> i:bv64),
         var v_2:bv64 := phi(%main_entry -> v_1:bv64)
       ) [
         guard bvsmod(i_1:bv64, 0x2:bv64);
         var v_3:bv64 := bvadd(v_2:bv64, 2);
         goto (%main_4,%main_3);
       ];
       block %main_3 (
         var i_2:bv64 := phi(%main_1 -> i_1:bv64),
         var v_4:bv64 := phi(%main_1 -> v_3:bv64)
       ) [
         guard bvsmod(i_2:bv64, 0x2:bv64);
         var v_5:bv64 := bvadd(v_4:bv64, 0x3:bv64);
         goto (%main_return);
       ];
       block %main_4 (
         var i_3:bv64 := phi(%main_1 -> i_1:bv64),
         var v_6:bv64 := phi(%main_1 -> v_3:bv64)
       ) [
         guard boolnot(bvsmod(i_3:bv64, 0x2:bv64));
         var v_7:bv64 := bvadd(v_6:bv64, 0x4:bv64);
         goto (%main_return);
       ];
       block %main_2 (
         var i_4:bv64 := phi(%main_entry -> i:bv64),
         var v_8:bv64 := phi(%main_entry -> v_1:bv64)
       ) [
         guard boolnot(bvsmod(i_4:bv64, 0x2:bv64));
         var v_9:bv64 := bvadd(v_8:bv64, 1);
         goto (%main_return);
       ];
       block %main_return (
         var v_10:bv64 := phi(%main_2 -> v_9:bv64, %main_4 -> v_7:bv64,
            %main_3 -> v_5:bv64)
       ) [
         var v_11:bv64 := bvadd(v_10:bv64, 0x1:bv64);
         var out_5:bv64 := v_11:bv64;
         var out:bv64 := out_5:bv64;
         return;
       ]
    ];
    prog entry @main;
    |}]

let%expect_test "test_loop_diff_block" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
prog entry @main;
  proc @main(i:bv64) -> (out:bv64)
  [
    block %main_entry
    [
      var v:bv64 := 0;
      goto(%main_1, %main_2);
    ];

    block %main_1
    [
      guard(bvsmod(i, 2:bv64));
      var v:bv64 := bvadd(v, 2);
      goto(%main_return);
    ];

    block %main_2
    [
      guard(boolnot(bvsmod(i:bv64, 2:bv64)));
      var v:bv64 := bvadd(v:bv64, 1);
      goto(%main_2_1);
    ];

    block %main_2_1
    [
      guard(boolnot(bvsmod(i:bv64, 2:bv64)));
      var v := bvadd(v:bv64, 4:bv64);
      goto(%main_2, %main_return);
    ];

    block %main_return
      [
      var v:bv64 := bvadd(v, 1:bv64);
      return(v);
      ];
  ];
|}
  in
  let program = lst.prog in
  let ssi_prog = ssify_prog program in
  Format.printf "%a\n" Containers_pp.pp (Program.prog_pretty ssi_prog);
  [%expect
    {|
    proc @main(i:bv64)  -> (out:bv64) {  }


    [
       block %main_entry [ var v_1:bv64 := 0; goto (%main_2,%main_1); ];
       block %main_1 (
         var i_1:bv64 := phi(%main_entry -> i:bv64),
         var v_2:bv64 := phi(%main_entry -> v_1:bv64)
       ) [
         guard bvsmod(i_1:bv64, 0x2:bv64);
         var v_3:bv64 := bvadd(v_2:bv64, 2);
         goto (%main_return);
       ];
       block %main_2 (
         var i_2:bv64 := phi(%main_2_1 -> i_2:bv64, %main_entry -> i:bv64),
         var v_4:bv64 := phi(%main_2_1 -> v_6:bv64, %main_entry -> v_1:bv64)
       ) [
         guard boolnot(bvsmod(i_2:bv64, 0x2:bv64));
         var v_5:bv64 := bvadd(v_4:bv64, 1);
         goto (%main_2_1);
       ];
       block %main_2_1 [
         guard boolnot(bvsmod(i_2:bv64, 0x2:bv64));
         var v_6:bv64 := bvadd(v_5:bv64, 0x4:bv64);
         goto (%main_return,%main_2);
       ];
       block %main_return (
         var v_7:bv64 := phi(%main_2_1 -> v_6:bv64, %main_1 -> v_3:bv64)
       ) [
         var v_8:bv64 := bvadd(v_7:bv64, 0x1:bv64);
         var out_3:bv64 := v_8:bv64;
         var out:bv64 := out_3:bv64;
         return;
       ]
    ];
    prog entry @main;
    |}]

let%expect_test "test_loop_same_block" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
prog entry @main;
  proc @main(i:bv64) -> (out:bv64)
  [
    block %main_entry
    [
      var v:bv64 := 0;
      goto(%main_1);
    ];

    block %main_1
    [
      guard(bvsmod(i, 2:bv64));
      var v:bv64 := bvadd(v, 2);
      goto(%main_1, %main_return);
    ];

    block %main_return
      [
      guard(boolnot(bvsmod(i, 2:bv64)));
      var v:bv64 := bvadd(v, 1:bv64);
      return(v);
      ];
  ];
|}
  in
  let program = lst.prog in
  let ssi_prog = ssify_prog program in
  Format.printf "%a\n" Containers_pp.pp (Program.prog_pretty ssi_prog);
  [%expect
    {|
    proc @main(i:bv64)  -> (out:bv64) {  }


    [
       block %main_entry [ var v_1:bv64 := 0; goto (%main_1); ];
       block %main_1 (
         var i_1:bv64 := phi(%main_1 -> i_1:bv64, %main_entry -> i:bv64),
         var v_2:bv64 := phi(%main_1 -> v_3:bv64, %main_entry -> v_1:bv64)
       ) [
         guard bvsmod(i_1:bv64, 0x2:bv64);
         var v_3:bv64 := bvadd(v_2:bv64, 2);
         goto (%main_return,%main_1);
       ];
       block %main_return (
         var i_2:bv64 := phi(%main_1 -> i_1:bv64),
         var v_4:bv64 := phi(%main_1 -> v_3:bv64)
       ) [
         guard boolnot(bvsmod(i_2:bv64, 0x2:bv64));
         var v_5:bv64 := bvadd(v_4:bv64, 0x1:bv64);
         var out_2:bv64 := v_5:bv64;
         var out:bv64 := out_2:bv64;
         return;
       ]
    ];
    prog entry @main;
    |}]

let%expect_test "test_ssa_multi_deps" =
  let lst =
    Loader.Loadir.ast_of_string
      {|



prog entry @main  { .invariants = ["NoPhis"] } ;

proc @main () -> ()
[
  block %e [
    var v:bv64 := 0;
    goto (%e1, %e2, %e3);
  ];
  block %e1 [
    var v := bvadd(v, 1);
    goto (%e2);
  ];
  block %e2 [
    goto (%e4, %e1);
  ];
  block %e3 [
    var v := bvadd(v, 2);
    goto (%e4, %e1);
  ];

  block %e4 [
    var v := bvadd(v, 2);
    goto (%e5);
  ];

  block %e5 [
    var v:= bvadd(v, 67);
    return ();
  ]
];
|}
  in
  let program = lst.prog in
  let ssi_prog = ssify_prog program in
  Format.printf "%a\n" Containers_pp.pp (Program.prog_pretty ssi_prog);
  [%expect
    {|
    proc @main()  -> () {  }


    [
       block %e [ var v_1:bv64 := 0; goto (%e3,%e2,%e1); ];
       block %e1 (
         var v_2:bv64 := phi(%e3 -> v_6:bv64, %e2 -> v_4:bv64, %e -> v_1:bv64)
       ) [ var v_3:bv64 := bvadd(v_2:bv64, 1); goto (%e2); ];
       block %e2 ( var v_4:bv64 := phi(%e1 -> v_3:bv64, %e -> v_1:bv64) ) [
         goto (%e4,%e1);
       ];
       block %e3 ( var v_5:bv64 := phi(%e -> v_1:bv64) ) [
         var v_6:bv64 := bvadd(v_5:bv64, 2);
         goto (%e4,%e1);
       ];
       block %e4 ( var v_7:bv64 := phi(%e3 -> v_6:bv64, %e2 -> v_4:bv64) ) [
         var v_8:bv64 := bvadd(v_7:bv64, 2);
         goto (%e5);
       ];
       block %e5 [ var v_9:bv64 := bvadd(v_8:bv64, 67); return; ]
    ];
    prog entry @main;
    |}]

let%expect_test "test_ssa_multi_deps_reconstruction" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
prog entry @main;
  proc @main()  -> () {  }


  [
    block %e [
      var v_1:bv64 := 0;
      var x:bv64 := 2;
      goto (%e3,%e2,%e1);
      ];
     block %e1 (
       var v_2:bv64 := phi(%e3 -> v_7:bv64, %e2 -> v_5:bv64, %e -> v_1:bv64)
     ) [
       var x := bvadd(x, 1);
       var v_3:bv64 := bvadd(v_2:bv64, 1); goto (%e2);
      ];
     block %e2 ( var v_4:bv64 := phi(%e1 -> v_3:bv64, %e -> v_1:bv64) ) [
       var v_5:bv64 := v_4:bv64;
       var x := bvadd(x, 2);
       goto (%e4,%e1);
     ];
     block %e3 ( var v_6:bv64 := phi(%e -> v_1:bv64) ) [
       var v_7:bv64 := bvadd(v_6:bv64, 2);
       goto (%e4,%e1);
     ];
     block %e4 ( var v_8:bv64 := phi(%e3 -> v_7:bv64, %e2 -> v_5:bv64) ) [
       var v_9:bv64 := bvadd(v_8:bv64, 2);
       goto (%e5);
     ];
     block %e5 [
       var v_10:bv64 := bvadd(v_9:bv64, 67);
       var x := bvadd(x, 5);
       return;
     ]
  ];
  |}
  in
  let program = lst.prog in
  let ssi_prog = ssify_prog program in
  Format.printf "%a\n" Containers_pp.pp (Program.prog_pretty ssi_prog);
  [%expect
    {|
    proc @main()  -> () {  }


    [
       block %e [ var v_52:bv64 := 0; var x_1:bv64 := 2; goto (%e1,%e2,%e3); ];
       block %e3 (
         var x_2:bv64 := phi(%e -> x_1:bv64),
         var v_48:bv64 := phi(%e -> v_52:bv64)
       ) [ var v_16:bv64 := bvadd(v_48:bv64, 2); goto (%e4,%e1); ];
       block %e2 (
         var x_3:bv64 := phi(%e1 -> x_6:bv64, %e -> x_1:bv64),
         var v_40:bv64 := phi(%e1 -> v_36:bv64, %e -> v_52:bv64)
       ) [
         var v_44:bv64 := v_40:bv64;
         var x_4:bv64 := bvadd(x_3:bv64, 2);
         goto (%e4,%e1);
       ];
       block %e1 (
         var x_5:bv64 := phi(%e -> x_1:bv64, %e2 -> x_4:bv64, %e3 -> x_2:bv64),
         var v_14:bv64 := phi(%e3 -> v_16:bv64, %e2 -> v_44:bv64, %e -> v_52:bv64)
       ) [
         var x_6:bv64 := bvadd(x_5:bv64, 1);
         var v_36:bv64 := bvadd(v_14:bv64, 1);
         goto (%e2);
       ];
       block %e4 (
         var x_7:bv64 := phi(%e2 -> x_4:bv64, %e3 -> x_2:bv64),
         var v_24:bv64 := phi(%e3 -> v_16:bv64, %e2 -> v_44:bv64)
       ) [ var v_33:bv64 := bvadd(v_24:bv64, 2); goto (%e5); ];
       block %e5 [
         var v_29:bv64 := bvadd(v_33:bv64, 67);
         var x_8:bv64 := bvadd(x_7:bv64, 5);
         return;
       ]
    ];
    prog entry @main;
    |}]

let%expect_test "test_v_1" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
prog entry @main;

proc @main(i:bv64)  -> (out:bv64) {  }
    [
       block %main_entry [
         var v_1:bv64 := 0x0:bv64;
         (var v_2:bv64=OX_out) := call @OX();
         goto (%main_2,%main_1);
       ];
       block %main_1 (
         var v_7:bv64 := phi(%main_1 -> v_8:bv64, %main_entry -> v_2:bv64)
       ) [
         guard bvsmod(i:bv64, 0x2:bv64);
         var nam:bv64 := bvadd(v_7:bv64, 0xa:bv64);
         var v_8:bv64 := bvadd(v_7:bv64, v_7:bv64);
         var tmp:bv64 := bvadd(i:bv64, 0x1:bv64);
         goto (%main_return,%main_1);
       ];
       block %main_2 ( var v_5:bv64 := phi(%main_entry -> v_2:bv64) ) [
         guard boolnot(bvsmod(i:bv64, 0x2:bv64));
         var v_1:bv64 := 0x111:bv64;
         goto (%main_2_1);
       ];
       block %main_2_1 [
         var namnam:bv64 := bvor(v_5:bv64, 0xffffffff:bv64);
         var v_6:bv64 := bvadd(v_5:bv64, 420);
         goto (%main_return);
       ];
       block %main_return (
         var v_3:bv64 := phi(%main_2_1 -> v_6:bv64, %main_1 -> v_8:bv64)
       ) [
         var v_4:bv64 := bvadd(v_3:bv64, 0x1:bv64);
         var out:bv64 := v_4:bv64;
         return;
       ];
    ];
    proc @OX() -> (OX_out:bv64)
[
    block %OX_entry [
      var OX_out:bv64 := 0:bv64;
      return;
    ];
];

proc @OY() -> (OY_out:bv64)
[
    block %OY_entry [
      var OY_out:bv64 := 1:bv64;
      return;
    ];
];
    |}
  in
  let program = lst.prog in
  let proc = Program.entry_proc_exn program in
  let v =
    match Procedure.lookup_local_decl proc "v_1" with
    | Some v -> v
    | None -> failwith "Bleh"
  in
  let cfg =
    match Procedure.graph proc with Some g -> g | None -> Procedure.G.empty
  in
  let dom_functions = Datastructures.Dom.compute_all cfg Procedure.Vert.Entry in
  let rev_cfg : Datastructures.RevDom.t =
    match Procedure.graph proc with Some g -> g | None -> Procedure.G.empty
  in
  let rev_dom_functions =
    Datastructures.Dom.compute_all rev_cfg Procedure.Vert.Return
  in

  let proc_split = ssify v proc cfg rev_cfg dom_functions rev_dom_functions in
  Program.output_proc_pretty stdout proc_split;
  [%expect
    {|
    proc @main(i:bv64)  -> (out:bv64) {  }


    [
       block %main_entry [
         var v_9:bv64 := 0x0:bv64;
         (var v_2:bv64=OX_out) := call @OX();
         goto (%main_2,%main_1);
       ];
       block %main_1 (
         var v_7:bv64 := phi(%main_1 -> v_8:bv64, %main_entry -> v_2:bv64)
       ) [
         guard bvsmod(i:bv64, 0x2:bv64);
         var nam:bv64 := bvadd(v_7:bv64, 0xa:bv64);
         var v_8:bv64 := bvadd(v_7:bv64, v_7:bv64);
         var tmp:bv64 := bvadd(i:bv64, 0x1:bv64);
         goto (%main_return,%main_1);
       ];
       block %main_2 ( var v_5:bv64 := phi(%main_entry -> v_2:bv64) ) [
         guard boolnot(bvsmod(i:bv64, 0x2:bv64));
         var v_11:bv64 := 0x111:bv64;
         goto (%main_2_1);
       ];
       block %main_2_1 [
         var namnam:bv64 := bvor(v_5:bv64, 0xffffffff:bv64);
         var v_6:bv64 := bvadd(v_5:bv64, 420);
         goto (%main_return);
       ];
       block %main_return (
         var v_3:bv64 := phi(%main_2_1 -> v_6:bv64, %main_1 -> v_8:bv64)
       ) [
         var v_4:bv64 := bvadd(v_3:bv64, 0x1:bv64);
         var out:bv64 := v_4:bv64;
         return;
       ]
    ]
    |}]

let%expect_test "test_loop.il" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
      prog entry @main ;

var $R0 : bv64;
var $R1 : bv64;


proc @main () -> () [
  block %entry  [
    $R0 := 0:bv64;
    $R1 := 0:bv64;
    goto (%loop);
  ];
  block %loop [
    goto (%loop_true, %loop_false);
  ];
  block %loop_true [
    guard (bvult($R0, 10:bv64));
    $R1 := bvadd($R1, $R0);
    $R0 := bvadd($R0, 1:bv64);
    goto (%loop);
  ];
  block %loop_false [
    guard (bvuge($R0, 10:bv64));
    return ();
  ];

];

proc @main_local () -> () [
  block %entry  [
    var v0:bv64 := 0:bv64;
    var r1:bv64 := 0:bv64;
    goto (%loop);
  ];
  block %loop [
    goto (%loop_true, %loop_false);
  ];
  block %loop_true [
    guard (bvult(v0, 10:bv64));
    var r1:bv64 := bvadd(r1, v0);
    var v0:bv64 := bvadd(v0, 1:bv64);
    goto (%loop);
  ];
  block %loop_false [
    guard (bvuge(v0, 10:bv64));
    return ();
  ];

];
    |}
  in
  let program = lst.prog in
  let ssi_prog = ssify_prog program in
  Format.printf "%a\n" Containers_pp.pp (Program.prog_pretty ssi_prog);
  [%expect
    {|
    var $R0:bv64;
    var $R1:bv64;
    proc @main()  -> () {  }
      modifies $R0:bv64, $R1:bv64
      captures $R0:bv64, $R1:bv64

    [
       block %entry [ $R0:bv64 := 0x0:bv64; $R1:bv64 := 0x0:bv64; goto (%loop); ];
       block %loop [ goto (%loop_false,%loop_true); ];
       block %loop_true [
         guard bvult($R0, 0xa:bv64);
         $R1:bv64 := bvadd($R1, $R0);
         $R0:bv64 := bvadd($R0, 0x1:bv64);
         goto (%loop);
       ];
       block %loop_false [ guard boolnot(bvult($R0, 0xa:bv64)); return; ]
    ];
    proc @main_local()  -> () {  }


    [
       block %entry [
         var v0_1:bv64 := 0x0:bv64;
         var r1_1:bv64 := 0x0:bv64;
         goto (%loop);
       ];
       block %loop (
         var v0_2:bv64 := phi(%loop_true -> v0_4:bv64, %entry -> v0_1:bv64),
         var r1_2:bv64 := phi(%loop_true -> r1_4:bv64, %entry -> r1_1:bv64)
       ) [ goto (%loop_false,%loop_true); ];
       block %loop_true (
         var v0_3:bv64 := phi(%loop -> v0_2:bv64),
         var r1_3:bv64 := phi(%loop -> r1_2:bv64)
       ) [
         guard bvult(v0_3:bv64, 0xa:bv64);
         var r1_4:bv64 := bvadd(r1_3:bv64, v0_3:bv64);
         var v0_4:bv64 := bvadd(v0_3:bv64, 0x1:bv64);
         goto (%loop);
       ];
       block %loop_false ( var v0_5:bv64 := phi(%loop -> v0_2:bv64) ) [
         guard boolnot(bvult(v0_5:bv64, 0xa:bv64));
         return;
       ]
    ];
    prog entry @main;
    |}]

let%expect_test "test_linear_copy.il" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
      prog entry @main;

proc @main(a:bv64, x:bool) -> ()
[
    block %main [
        (var b:bv64) := call @f(a:bv64);
        (var c:bv64, var d:bv64) := call @loop(b:bv64, b:bv64);
        (var e:bv64) := call @cross(d:bv64, bvadd(d:bv64, 1:bv64));
        (var f:bv64 := bvadd(1:bv64, c:bv64), var g:bv64 := bvadd(1:bv64, e:bv64));
        (var y:bool) := call @bool_id(x:bool);
        var z:bool := y:bool;
        return;
    ];
];

proc @f(x:bv64) -> (o:bv64)
[
    block %f_entry [
        goto (%f_a, %f_b);
    ];
    block %f_a [
        var y_1:bv64 := x;
        goto (%f_c, %f_d);
    ];
    block %f_b [
        (var y_2:bv64, var z:bv64) := call @g(x);
        goto (%f_c, %f_d);
    ];
    block %f_c (
        var y_3:bv64 := phi(%f_a -> y_1:bv64, %f_b -> y_2:bv64)
    ) [
        var w_1:bv64 := y_3:bv64;
        goto (%f_return);
    ];
    block %f_d (
        var y_4:bv64 := phi(%f_a -> y_1:bv64, %f_b -> y_2:bv64)
    ) [
        (var w_2:bv64, var p:bv64) := call @g(y_4);
        goto (%f_return);
    ];
    block %f_return (
        var w_3:bv64 := phi(%f_c -> w_1:bv64, %f_d -> w_2:bv64)
    ) [
        return (w_3:bv64);
    ];
];

proc @g(x:bv64) -> (o:bv64, p:bv64)
[
    block %g_entry [
        goto (%g_a, %g_b);
    ];
    block %g_a [
        var y_1:bv64 := x;
        goto (%g_return);
    ];
    block %g_b [
        (var y_2:bv64) := call @f(x);
        goto (%g_return);
    ];
    block %g_return (
        var y_3:bv64 := phi(%g_a -> y_1:bv64, %g_b -> y_2:bv64)
    ) [
        return (x:bv64, y_3:bv64);
    ];
];

proc @loop(x:bv64, y:bv64) -> (o:bv64, p:bv64)
[
    block %entry [
        var x_1:bv64 := bvadd(x:bv64, 1:bv64);
        var y_1:bv64 := bvadd(y:bv64, 1:bv64);
        goto(%a, %ret);
    ];
    block %a (
        var x_2:bv64 := phi(%entry -> x_1:bv64, %a -> x_3:bv64),
        var y_2:bv64 := phi(%entry -> y_1:bv64, %a -> y_3:bv64)
    ) [
        var x_3:bv64 := bvadd(x_2:bv64, 1:bv64);
        var y_3:bv64 := y_2;
        goto(%a, %ret);
    ];
    block %ret (
        var x_4:bv64 := phi(%entry -> x_1:bv64, %a -> x_3:bv64),
        var y_4:bv64 := phi(%entry -> y_1:bv64, %a -> y_3:bv64)
    ) [
        (var o:bv64 := x_4:bv64, var p:bv64 := y_4:bv64);
        return;
    ];
];

proc @cross(a:bv64, b:bv64) -> (o:bv64)
[
    block %entry [
        goto(%a, %b);
    ];
    block %a [
        var o_1:bv64 := a:bv64;
        goto(%ret);
    ];
    block %b [
        var o_2:bv64 := bvsub(b:bv64, 1:bv64);
        goto(%ret);
    ];
    block %ret (
        var o_3:bv64 := phi(%a -> o_1:bv64, %b -> o_2:bv64)
    ) [
        return (o_3:bv64);
    ];
];

proc @bool_id(a:bool) -> (o:bool)
[
    block %entry [
        return (a:bool);
    ];
];

    |}
  in
  let program = lst.prog in
  let ssi_prog = ssify_prog program in
  Format.printf "%a\n" Containers_pp.pp (Program.prog_pretty ssi_prog);
  [%expect
    {|
    proc @main(a:bv64, x:bool)  -> () {  }


    [
       block %main [
         (var b_1:bv64=o) := call @f(x=a:bv64);
         (var c_1:bv64=o, var d_1:bv64=p) := call @loop(x=b_1:bv64, y=b_1:bv64);
         (var e_1:bv64=o) := call @cross(a=d_1:bv64, b=bvadd(d_1:bv64, 0x1:bv64));
         (var f_1:bv64 := bvadd(0x1:bv64, c_1:bv64),
          var g_1:bv64 := bvadd(0x1:bv64, e_1:bv64));
         (var y_1:bool=o) := call @bool_id(a=x:bool);
         var z_1:bool := y_1:bool;
         return;
       ]
    ];
    proc @f(x:bv64)  -> (o:bv64) {  }


    [
       block %f_entry [ goto (%f_b,%f_a); ];
       block %f_a ( var x_1:bv64 := phi(%f_entry -> x:bv64) ) [
         var y_5:bv64 := x_1:bv64;
         goto (%f_d,%f_c);
       ];
       block %f_b ( var x_2:bv64 := phi(%f_entry -> x:bv64) ) [
         (var y_23:bv64=o, var z_2:bv64=p) := call @g(x=x_2:bv64);
         goto (%f_d,%f_c);
       ];
       block %f_c ( var y_19:bv64 := phi(%f_a -> y_5:bv64, %f_b -> y_23:bv64) ) [
         var w_17:bv64 := y_19:bv64;
         goto (%f_return);
       ];
       block %f_d ( var y_14:bv64 := phi(%f_a -> y_5:bv64, %f_b -> y_23:bv64) ) [
         (var w_13:bv64=o, var p_4:bv64=p) := call @g(x=y_14:bv64);
         goto (%f_return);
       ];
       block %f_return (
         var w_9:bv64 := phi(%f_c -> w_17:bv64, %f_d -> w_13:bv64)
       ) [ var o_5:bv64 := w_9:bv64; var o:bv64 := o_5:bv64; return; ]
    ];
    proc @g(x:bv64)  -> (o:bv64, p:bv64) {  }


    [
       block %g_entry [ goto (%g_b,%g_a); ];
       block %g_a ( var x_1:bv64 := phi(%g_entry -> x:bv64) ) [
         var y_4:bv64 := x_1:bv64;
         goto (%g_return);
       ];
       block %g_b ( var x_2:bv64 := phi(%g_entry -> x:bv64) ) [
         (var y_12:bv64=o) := call @f(x=x_2:bv64);
         goto (%g_return);
       ];
       block %g_return (
         var x_3:bv64 := phi(%g_b -> x_2:bv64, %g_a -> x_1:bv64),
         var y_10:bv64 := phi(%g_a -> y_4:bv64, %g_b -> y_12:bv64)
       ) [
         (var o_3:bv64 := x_3:bv64, var p_3:bv64 := y_10:bv64);
         var p:bv64 := p_3:bv64;
         var o:bv64 := o_3:bv64;
         return;
       ]
    ];
    proc @loop(x:bv64, y:bv64)  -> (o:bv64, p:bv64) {  }


    [
       block %entry [
         var x_5:bv64 := bvadd(x:bv64, 0x1:bv64);
         var y_5:bv64 := bvadd(y:bv64, 0x1:bv64);
         goto (%ret,%a);
       ];
       block %a (
         var x_14:bv64 := phi(%entry -> x_5:bv64, %a -> x_8:bv64),
         var y_14:bv64 := phi(%entry -> y_5:bv64, %a -> y_11:bv64)
       ) [
         var x_8:bv64 := bvadd(x_14:bv64, 0x1:bv64);
         var y_11:bv64 := y_14:bv64;
         goto (%ret,%a);
       ];
       block %ret (
         var x_12:bv64 := phi(%entry -> x_5:bv64, %a -> x_8:bv64),
         var y_10:bv64 := phi(%entry -> y_5:bv64, %a -> y_11:bv64)
       ) [
         (var o_2:bv64 := x_12:bv64, var p_2:bv64 := y_10:bv64);
         var p:bv64 := p_2:bv64;
         var o:bv64 := o_2:bv64;
         return;
       ]
    ];
    proc @cross(a:bv64, b:bv64)  -> (o:bv64) {  }


    [
       block %entry [ goto (%b,%a); ];
       block %a ( var a_1:bv64 := phi(%entry -> a:bv64) ) [
         var o_11:bv64 := a_1:bv64;
         goto (%ret);
       ];
       block %b ( var b_2:bv64 := phi(%entry -> b:bv64) ) [
         var o_9:bv64 := bvsub(b_2:bv64, 0x1:bv64);
         goto (%ret);
       ];
       block %ret ( var o_7:bv64 := phi(%a -> o_11:bv64, %b -> o_9:bv64) ) [
         var o_16:bv64 := o_7:bv64;
         var o:bv64 := o_16:bv64;
         return;
       ]
    ];
    proc @bool_id(a:bool)  -> (o:bool) {  }


    [ block %entry [ var o_1:bool := a:bool; var o:bool := o_1:bool; return; ] ];
    prog entry @main;
    |}]

let%expect_test "test_SSIFY_multiple_returns" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
prog entry @main;

proc @main(i:bv64) -> (out:bv64)
[
    block %main_entry [
      var v:bv64 := 0:bv64;
      (var v:bv64) := call @OX();
      var namnam:bv64 := 12345:bv64;
      goto(%main_1, %main_2);
    ];

    block %main_1
    [
      guard(bvsmod(i, 2:bv64));
      var nam:bv64 := bvadd(v:bv64, 10:bv64);
      var v:bv64 := bvadd(v, v);
      var tmp:bv64 := bvadd(i, 1:bv64);
      var i:bv64 := tmp:bv64;
      goto(%main_return, %main_1);
    ];

    block %main_2
    [
      guard(boolnot(bvsmod(i, 2:bv64)));
      var nam:bv64 := bvadd(namnam:bv64, v:bv64);
      goto(%main_2_1, %main_return_2);
    ];

    block %main_2_1
    [
      var namnam:bv64 := bvor(v:bv64, 0xffffffff:bv64);
      var v:bv64 := bvadd(v:bv64, namnam);
      goto(%main_return);
    ];

    block %main_return
      [
      var v:bv64 := bvadd(v, 1:bv64);
      return(v);
      ];

    block %main_return_2
    [
      guard(bvsmod(nam, 20:bv64));
      assert bvule(nam, 0x0000:bv64);
      var tmp:bv64 := bvadd(nam, v);
      return (tmp);
    ];
];

proc @OX() -> (OX_out:bv64)
[
    block %OX_entry [
      var OX_out:bv64 := 0:bv64;
      return;
    ];
];

proc @OY() -> (OY_out:bv64)
[
    block %OY_entry [
      var OY_out:bv64 := 1:bv64;
      return;
    ];
];
    |}
  in
  let program = lst.prog in
  let ssi_prog = ssify_prog program in
  Format.printf "%a\n" Containers_pp.pp (Program.prog_pretty ssi_prog);
  [%expect
    {|
    proc @main(i:bv64)  -> (out:bv64) {  }


    [
       block %main_entry [
         var v_1:bv64 := 0x0:bv64;
         (var v_2:bv64=OX_out) := call @OX();
         var namnam_1:bv64 := 0x3039:bv64;
         goto (%main_2,%main_1);
       ];
       block %main_1 (
         var i_1:bv64 := phi(%main_1 -> i_2:bv64, %main_entry -> i:bv64),
         var v_3:bv64 := phi(%main_1 -> v_4:bv64, %main_entry -> v_2:bv64)
       ) [
         guard bvsmod(i_1:bv64, 0x2:bv64);
         var nam_1:bv64 := bvadd(v_3:bv64, 0xa:bv64);
         var v_4:bv64 := bvadd(v_3:bv64, v_3:bv64);
         var tmp_1:bv64 := bvadd(i_1:bv64, 0x1:bv64);
         var i_2:bv64 := tmp_1:bv64;
         goto (%main_return,%main_1);
       ];
       block %main_2 (
         var i_3:bv64 := phi(%main_entry -> i:bv64),
         var v_5:bv64 := phi(%main_entry -> v_2:bv64),
         var namnam_3:bv64 := phi(%main_entry -> namnam_1:bv64)
       ) [
         guard boolnot(bvsmod(i_3:bv64, 0x2:bv64));
         var nam_2:bv64 := bvadd(namnam_3:bv64, v_5:bv64);
         goto (%main_return_2,%main_2_1);
       ];
       block %main_2_1 ( var v_6:bv64 := phi(%main_2 -> v_5:bv64) ) [
         var namnam_4:bv64 := bvor(v_6:bv64, 0xffffffff:bv64);
         var v_7:bv64 := bvadd(v_6:bv64, namnam_4:bv64);
         goto (%main_return);
       ];
       block %main_return_2 (
         var v_8:bv64 := phi(%main_2 -> v_5:bv64),
         var nam_4:bv64 := phi(%main_2 -> nam_2:bv64)
       ) [
         guard bvsmod(nam_4:bv64, 0x14:bv64);
         assert bvule(nam_4:bv64, 0x0:bv64);
         var tmp_4:bv64 := bvadd(nam_4:bv64, v_8:bv64);
         var out_4:bv64 := tmp_4:bv64;
         var out:bv64 := out_5:bv64;
         return;
       ];
       block %main_return (
         var v_9:bv64 := phi(%main_2_1 -> v_7:bv64, %main_1 -> v_4:bv64)
       ) [
         var v_10:bv64 := bvadd(v_9:bv64, 0x1:bv64);
         var out_5:bv64 := v_10:bv64;
         return;
       ]
    ];
    proc @OX()  -> (OX_out:bv64) {  }


    [
       block %OX_entry [
         var OX_out_1:bv64 := 0x0:bv64;
         var OX_out:bv64 := OX_out_1:bv64;
         return;
       ]
    ];
    proc @OY()  -> (OY_out:bv64) {  }


    [
       block %OY_entry [
         var OY_out_1:bv64 := 0x1:bv64;
         var OY_out:bv64 := OY_out_1:bv64;
         return;
       ]
    ];
    prog entry @main;
    |}]

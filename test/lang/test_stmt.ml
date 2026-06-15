open Lang
open Lang.Stmt
open Lang.Common
open Expr

let%expect_test "frees" =
  let s =
    Instr_Assign
      {
        al =
          [
            ( Var.create "v1" Types.Boolean,
              BasilExpr.rvar @@ Var.create "v2" Types.Boolean );
            ( Var.create "v3" Types.Boolean,
              BasilExpr.rvar @@ Var.create "v4" Types.Boolean );
          ];
        attrib = Attrib.empty;
      }
  in
  print_endline (to_string ~width:80 Var.pretty Var.pretty BasilExpr.pretty s);
  print_string "Rvars: ";
  print_endline @@ Iter.to_string ~sep:"," Var.to_string (free_vars_iter s);
  print_string "Lvars: ";
  print_endline @@ Iter.to_string ~sep:"," Var.to_string (iter_lvar s);
  [%expect
    {|
    (v1:bool := v2:bool, v3:bool := v4:bool)
    Rvars: v2:bool,v4:bool
    Lvars: v1:bool,v3:bool
    |}]

let%expect_test "fold_block" =
  let block =
    Loader.Loadir.parse_single_block
      {|
   block %main_entry [
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xfffffffffffffffc:bv64) extract(32,0, R0_in:bv64) 32;
      var load45_1:bv32 := load le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xfffffffffffffffc:bv64) 32;
      var R1_4:bv64 := zero_extend(32, load45_1:bv32);
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) 0x420034:bv64 extract(32,0, R1_4:bv64) 32;
      var load46_1:bv32 := load le $mem:(bv64->bv8) 0x42002c:bv64 32;
      var R0_10:bv64 := zero_extend(32, load46_1:bv32);
      goto (%phi_4,%phi_3);
      ]
    |}
  in
  Block.fold_forwards
    ~f:(fun _ i -> print_endline (Stmt.show_stmt_basil i))
    ~phi:(fun a _ -> a)
    () block;
  print_endline (Block.to_string block);
  ();
  [%expect
    {|
    Warn: global undeclared $stack assuming mutable unshared
    Warn: global undeclared $mem assuming mutable unshared
    $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(R31_in:bv64,
     0xfffffffffffffffc:bv64) extract(32,0, R0_in:bv64) 32
    var load45_1:bv32 := load le $stack:(bv64->bv8) bvadd(R31_in:bv64,
     0xfffffffffffffffc:bv64) 32
    var R1_4:bv64 := zero_extend(32, load45_1:bv32)
    $mem:(bv64->bv8) := store le $mem:(bv64->bv8) 0x420034:bv64 extract(32,0, R1_4:bv64) 32
    var load46_1:bv32 := load le $mem:(bv64->bv8) 0x42002c:bv64 32
    var R0_10:bv64 := zero_extend(32, load46_1:bv32)
    [
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(R31_in:bv64, 0xfffffffffffffffc:bv64) extract(32,0, R0_in:bv64) 32;
      load45_1:bv32 := load le $stack:(bv64->bv8) bvadd(R31_in:bv64, 0xfffffffffffffffc:bv64) 32;
      R1_4:bv64 := zero_extend(32, load45_1:bv32);
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) 0x420034:bv64 extract(32,0, R1_4:bv64) 32;
      load46_1:bv32 := load le $mem:(bv64->bv8) 0x42002c:bv64 32;
      R0_10:bv64 := zero_extend(32, load46_1:bv32);
    ]
    |}]

let%expect_test "parsing of attribs on stmts" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
var $PC:bv64;
prog entry @main;

proc @main()  -> () {  }
  requires boolor(eq(0x400808:bv64, $PC))
[
  block %main_code { .gtirb_block = "b8tsihT4Q6a/SWPo4w8HoA";
      .succ = [ { .address = 4196228; .conditional = "false"; .direct = "true";
              .target = "stmts:OuTzy8qRTci75taVjGinFQ"; .type = "Type_Call" } ] } [
    assume eq(0x400808:bv64, $PC);
    assert false { .opcode = "0xa9be7bfd" };
    assert boolor(eq(0x400784:bv64, $PC));
    goto (%ret_1);
  ];
  block %ret_1 [ return; ]
];
    |}
  in
  let prog = lst.prog in
  let _proc = Lang.Program.entry_proc_exn prog in
  print_endline
  @@ Containers_pp.Pretty.to_string ~width:80 (Lang.Program.prog_pretty prog);
  [%expect
    {|
    var $PC:bv64;
    proc @main()  -> () {  }
      captures $PC:bv64
      requires boolor(eq(0x400808:bv64, $PC))

    [
       block %main_code [
         assume eq(0x400808:bv64, $PC);
         assert false;
         assert boolor(eq(0x400784:bv64, $PC));
         goto (%ret_1);
       ];
       block %ret_1 [ return; ]
    ];
    prog entry @main;
  |}]

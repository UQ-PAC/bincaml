open Bincaml_util.Common

let%expect_test "bayat1" =
  let prog = (Loader.Loadir.ast_of_fname "bayat1.il").prog in
  let proc = Lang.Program.get_proc_by_name "@main" prog in
  let mainid = Lang.Procedure.id proc in
  let prog = Lang.Program.set_entry_proc mainid prog in

  let prog =
    Lang.Program.declarations prog
    |> Iter.fold
         (fun prog (id, decl) ->
           if not (ID.equal id mainid) then Lang.Program.remove_decl prog decl
           else prog)
         prog
  in
  let prog = Bincaml.Passes.PassManager.(run_transform prog aslp_semantics) in
  let prog = Bincaml.Passes.PassManager.(run_transform prog sparams) in
  let prog = Bincaml.Passes.PassManager.(run_transform prog sssa) in

  let dsgraph = Analysis.Dsa.dsa prog in
  let _, g = IDMap.find mainid dsgraph in
  print_endline @@ Analysis.Dsa.dot_string g;
  [%expect
    {|
    digraph G {
      rankdir="LR"
      node[shape=record]
      "node0"[label="node0 S \nStack(@main) |{<0>[-48, -41]|<1>[-40, -33]|<2>[-20, -17]|<3>[-8, 3]}"];
      "node3"[label="node3 UO \nPar(@main_R0_in:bv64)\nLoaded(local_39:bv32) |{<4>Top}"];
      "node5"[label="node5 G \nGlobal |{<5>[131128, 131143]|<6>[131144, 131151]|<7>[131152, 131159]|<8>[131160, 131167]}"];
      "node6"[label="node6 U \nPar(@main_R29_in:bv64)\nLoaded(local_53:bv64) |{<9>[0, 7]}"];
      "node7"[label="node7 U \nPar(@main_R30_in:bv64)\nLoaded(local_56:bv64) |{<10>[0, 7]}"];
      "node0":2 -> "node3":4
      "node5":7 -> "node5":8
      "node0":0 -> "node6":9
      "node5":5 -> "node0":3
      "node5":6 -> "node5":5
      "node0":1 -> "node7":10
    }
    |}]

let%expect_test "bayat2" =
  let prog = (Loader.Loadir.ast_of_fname "bayat2.il").prog in
  let proc = Lang.Program.get_proc_by_name "@main" prog in
  let mainid = Lang.Procedure.id proc in
  let prog = Lang.Program.set_entry_proc mainid prog in

  let prog =
    Lang.Program.declarations prog
    |> Iter.fold
         (fun prog (id, decl) ->
           if not (ID.equal id mainid) then Lang.Program.remove_decl prog decl
           else prog)
         prog
  in
  let prog = Bincaml.Passes.PassManager.(run_transform prog aslp_semantics) in
  let prog = Bincaml.Passes.PassManager.(run_transform prog sparams) in
  let prog = Bincaml.Passes.PassManager.(run_transform prog sssa) in

  let dsgraph = Analysis.Dsa.dsa prog in
  let _, g = IDMap.find mainid dsgraph in
  print_endline @@ Analysis.Dsa.dot_string g;
  [%expect
    {|
    digraph G {
      rankdir="LR"
      node[shape=record]
      "node8"[label="node8 S \nStack(@main) |{<0>[-32, -25]|<1>[-24, -17]|<2>[-4, -1]}"];
      "node11"[label="node11 UO \nPar(@main_R0_in:bv64)\nLoaded(local_35:bv32) |{<3>Top}"];
      "node12"[label="node12 G \nGlobal |{<4>[131168, 131175]|<5>[131176, 131183]}"];
      "node14"[label="node14 U \nLoaded(local_42:bv32) |{<6>[0, 3]}"];
      "node15"[label="node15 U \nPar(@main_R29_in:bv64)\nLoaded(local_47:bv64) |{<7>[0, 7]}"];
      "node16"[label="node16 U \nPar(@main_R30_in:bv64)\nLoaded(local_50:bv64) |{<8>[0, 7]}"];
      "node8":2 -> "node11":3
      "node8":0 -> "node15":7
      "node12":5 -> "node12":4
      "node11":3 -> "node14":6
      "node8":1 -> "node16":8
    }
    |}]

let%expect_test "lattner1" =
  let prog = (Loader.Loadir.ast_of_fname "lattner1.il").prog in

  let prog = Bincaml.Passes.PassManager.(run_transform prog aslp_semantics) in
  let prog = Bincaml.Passes.PassManager.(run_transform prog sparams) in
  let prog =
    Bincaml.Passes.PassManager.(run_transform prog lift_intrinsics_aarch64)
  in
  Lang.Program.pretty_to_chan stdout prog;
  let prog = Bincaml.Passes.PassManager.(run_transform prog sssa) in

  let dsgraph = Analysis.Dsa.dsa prog in
  let procs = [ "@createnode"; "@splitclone"; "@processlist" ] in
  List.iter
    (fun name ->
      let _, g = IDMap.find (Lang.Program.get_id_by_name name prog) dsgraph in
      print_endline @@ name;
      print_endline @@ Analysis.Dsa.dot_string g;
      print_endline "")
    procs;
  [%expect.unreachable]
[@@expect.uncaught_exn {|
  (* CR expect_test_collector: This test expectation appears to contain a backtrace.
     This is strongly discouraged as backtraces are fragile.
     Please change this test to not include a backtrace. *)
  Not_found
  Raised at Stdlib__Map.Make.find in file "map.ml", line 141, characters 10-25
  Called from Transforms__Ssa.Construction.ssa_proc.(fun) in file "lib/transforms/ssa.ml", line 407, characters 14-54
  Called from Iter.filter.(fun) in file "src/Iter.ml", line 126, characters 47-50
  Called from Stdlib__List.iter in file "list.ml", line 114, characters 12-15
  Called from Transforms__Ssa.Construction.add_phis in file "lib/transforms/ssa.ml", lines 164-197, characters 6-18
  Called from Iter.fold.(fun) in file "src/Iter.ml", line 77, characters 23-31
  Called from Stdlib__Map.Make.iter in file "map.ml", line 305, characters 20-25
  Called from Stdlib__Map.Make.iter in file "map.ml", line 305, characters 10-18
  Called from Iter.fold in file "src/Iter.ml", line 77, characters 2-32
  Called from Transforms__Ssa.Construction.ssa_proc.(fun) in file "lib/transforms/ssa.ml", lines 416-417, characters 12-62
  Called from Lang__Procedure.PG.map_graph.(fun) in file "lib/lang/procedure.ml", line 209, characters 22-25
  Called from Stdlib__Option.map in file "option.ml", line 24, characters 57-62
  Called from Lang__Procedure.PG.map_graph in file "lib/lang/procedure.ml", lines 207-216, characters 6-15
  Called from Transforms__Ssa.Construction.ssa_proc in file "lib/transforms/ssa.ml", lines 392-421, characters 6-63
  Called from Lang__Program.map_procedures.(fun) in file "lib/lang/program.ml", line 133, characters 63-77
  Called from Bincaml_util__Indexed_list.Make.mapi.f in file "lib/util/indexed_list.ml", line 205, characters 23-32
  Called from Bincaml_util__Indexed_list.Make.update.(fun) in file "lib/util/indexed_list.ml", line 141, characters 19-22
  Called from Stdlib__Map.Make.update in file "map.ml", line 287, characters 18-28
  Called from Stdlib__Map.Make.update in file "map.ml", line 295, characters 21-33
  Called from Stdlib__Map.Make.update in file "map.ml", line 292, characters 21-33
  Called from Stdlib__Map.Make.update in file "map.ml", line 292, characters 21-33
  Called from Stdlib__Map.Make.update in file "map.ml", line 292, characters 21-33
  Called from Bincaml_util__Indexed_list.Make.update in file "lib/util/indexed_list.ml", lines 139-146, characters 6-13
  Called from Iter.foldi.(fun) in file "src/Iter.ml", line 84, characters 11-22
  Called from CCFQueue.to_iter.(fun) in file "src/data/CCFQueue.ml", line 268, characters 8-11
  Called from CCFQueue._digit_to_iter in file "src/data/CCFQueue.ml" (inlined), line 254, characters 4-7
  Called from CCFQueue.to_iter in file "src/data/CCFQueue.ml", line 266, characters 4-23
  Called from CCFQueue.to_iter in file "src/data/CCFQueue.ml", lines 267-269, characters 4-12
  Called from Iter.foldi in file "src/Iter.ml", lines 83-85, characters 2-13
  Called from Lang__Program.map_procedures in file "lib/lang/program.ml", lines 131-134, characters 6-17
  Called from Bincaml__Passes.PassManager.run_transform.(fun) in file "lib/passes.ml", line 617, characters 16-20
  Called from Dsa_tests__Inline.(fun) in file "test/dsa/inline.ml", line 665, characters 41-64
  Called from Ppx_expect_runtime__Test_block.Configured.dump_backtrace in file "runtime/test_block.ml", line 142, characters 10-28

  Trailing output
  ---------------
  var observable $mem:(bv64->bv8);
  proc @createnode(PC_in:bv64, R0_in:bv64, R16_in:bv64, R17_in:bv64, R1_in:bv64,
     R29_in:bv64, R30_in:bv64, SP_in:bv64)
     -> (PC_out:bv64, R0_out:bv64, R16_out:bv64, R17_out:bv64, R1_out:bv64,
     R29_out:bv64, R30_out:bv64, SP_out:bv64) {  }
    modifies $mem:(bv64->bv8)
    captures $mem:(bv64->bv8)
    requires boolor(eq(0x8e4:bv64, PC_in:bv64))

  [
     block %ret_1 [ goto (%returns); ];
     block %ret_2 [ goto (%returns); ];
     block %returns [
       (var PC_out:bv64 := PC:bv64, var R0_out:bv64 := R0:bv64,
        var R1_out:bv64 := R1:bv64, var R16_out:bv64 := R16:bv64,
        var R17_out:bv64 := R17:bv64, var R29_out:bv64 := R29:bv64,
        var R30_out:bv64 := R30:bv64, var SP_out:bv64 := SP:bv64);
       return;
     ];
     block %createnode_code_3 [
       assert boolor(eq(0x9b0:bv64, PC:bv64), eq(0x974:bv64, PC:bv64));
       goto (%ret_2,%ret_1);
     ];
     block %block_11 { .asm = "ret " } [
       var local_14:bv64 := 0x0:bv64;
       var BTypeNext:bv2 := 0x0:bv2;
       var BranchTaken:bool := true;
       var PC:bv64 := R30:bv64;
       goto (%createnode_code_3);
     ];
     block %block_10 { .asm = "ldp x29, x30, [sp], #0x30" } [
       var local_9:bv64 := 0x0:bv64;
       var local_9:bv64 := SP:bv64;
       var local_10:bv64 := 0x0:bv64;
       var local_11:bv64 := load le $mem:(bv64->bv8) SP:bv64 64;
       var local_10:bv64 := local_11:bv64;
       var local_12:bv64 := 0x0:bv64;
       var local_13:bv64 := load le $mem:(bv64->bv8) bvadd(SP:bv64, 0x8:bv64) 64;
       var local_12:bv64 := local_13:bv64;
       var R29:bv64 := local_10:bv64;
       var R30:bv64 := local_12:bv64;
       var SP:bv64 := bvadd(local_9:bv64, 0x30:bv64);
       (var BranchTaken:bool := false, var PC:bv64 := 0x910:bv64);
       goto (%block_11);
     ];
     block %block_9 { .asm = "ldr x0, [sp, #0x28]" } [
       var local_7:bv64 := 0x0:bv64;
       var local_8:bv64 := load le $mem:(bv64->bv8) bvadd(SP:bv64, 0x28:bv64) 64;
       var local_7:bv64 := local_8:bv64;
       var R0:bv64 := zero_extend(0, zero_extend(0, local_7:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x90c:bv64);
       goto (%block_10);
     ];
     block %block_8 { .asm = "str x1, [x0, #8]" } [
       var local_6:bv64 := 0x0:bv64;
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(R0:bv64, 0x8:bv64) R1:bv64 64;
       (var BranchTaken:bool := false, var PC:bv64 := 0x908:bv64);
       goto (%block_9);
     ];
     block %block_7 { .asm = "ldr x1, [sp, #0x18]" } [
       var local_4:bv64 := 0x0:bv64;
       var local_5:bv64 := load le $mem:(bv64->bv8) bvadd(SP:bv64, 0x18:bv64) 64;
       var local_4:bv64 := local_5:bv64;
       var R1:bv64 := zero_extend(0, zero_extend(0, local_4:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x904:bv64);
       goto (%block_8);
     ];
     block %block_6 { .asm = "ldr x0, [sp, #0x28]" } [
       var local_2:bv64 := 0x0:bv64;
       var local_3:bv64 := load le $mem:(bv64->bv8) bvadd(SP:bv64, 0x28:bv64) 64;
       var local_2:bv64 := local_3:bv64;
       var R0:bv64 := zero_extend(0, zero_extend(0, local_2:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x900:bv64);
       goto (%block_7);
     ];
     block %block_5 { .asm = "str x0, [sp, #0x28]" } [
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(SP:bv64, 0x28:bv64) R0:bv64 64;
       (var BranchTaken:bool := false, var PC:bv64 := 0x8fc:bv64);
       goto (%block_6);
     ];
     block %createnode_code_1 { .address = 2296;
         .gtirb_block = "lrKKe+miRjSnSiaG164qMA";
         .succ = [ { .address = 2480; .conditional = "false"; .direct = "true";
                 .target = "external:9oceKFiPSN69RSkX65b7GQ"; .type = "Type_Return" };
             { .address = 2420; .conditional = "false"; .direct = "true";
                 .target = "external:pao7tNGFTG2/wwL2A6BKrQ"; .type = "Type_Return" } ] } [
       assume eq(0x8f8:bv64, PC:bv64);
       goto (%block_5);
     ];
     block %createnode_ext_2 [
       assume eq(0x770:bv64, PC:bv64);
       (var PC:bv64=PC_out, var R16:bv64=R16_out, var R17:bv64=R17_out) := call @FUN_770(PC_in=PC:bv64,
          R16_in=R16:bv64, R17_in=R17:bv64);
       assert boolor(eq(0x8f8:bv64, PC:bv64));
       goto (%createnode_code_1);
     ];
     block %createnode_code_2 [
       assert boolor(eq(0x770:bv64, PC:bv64));
       goto (%createnode_ext_2);
     ];
     block %block_4 { .asm = "bl #0xfffffffffffffe7c" } [
       var R30:bv64 := 0x8f8:bv64;
       var BranchTaken:bool := true;
       var PC:bv64 := 0x770:bv64;
       goto (%createnode_code_2);
     ];
     block %block_3 { .asm = "mov x0, #0x10" } [
       var R0:bv64 := 0x10:bv64;
       (var BranchTaken:bool := false, var PC:bv64 := 0x8f4:bv64);
       goto (%block_4);
     ];
     block %block_2 { .asm = "str x0, [sp, #0x18]" } [
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(SP:bv64, 0x18:bv64) R0:bv64 64;
       (var BranchTaken:bool := false, var PC:bv64 := 0x8f0:bv64);
       goto (%block_3);
     ];
     block %block_1 { .asm = "mov x29, sp" } [
       var local_1:bv64 := 0x0:bv64;
       var R29:bv64 := bvadd(SP:bv64, 0x0:bv64);
       (var BranchTaken:bool := false, var PC:bv64 := 0x8ec:bv64);
       goto (%block_2);
     ];
     block %block { .asm = "stp x29, x30, [sp, #-0x30]!" } [
       var local:bv64 := 0x0:bv64;
       var local:bv64 := SP:bv64;
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(SP:bv64,
        0xffffffffffffffd0:bv64) R29:bv64 64;
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(bvadd(SP:bv64,
         0xffffffffffffffd0:bv64), 0x8:bv64) R30:bv64 64;
       var SP:bv64 := bvadd(local:bv64, 0xffffffffffffffd0:bv64);
       (var BranchTaken:bool := false, var PC:bv64 := 0x8e8:bv64);
       goto (%block_1);
     ];
     block %createnode_code { .address = 2276;
         .gtirb_block = "c/WxqFxXSHWNzwaD8KmaZw";
         .succ = [ { .address = 1904; .conditional = "false"; .direct = "true";
                 .target = "stmts:tXIOhSQ+R1WA/9VL5+6KQQ"; .type = "Type_Call" } ] } [
       assume eq(0x8e4:bv64, PC:bv64);
       goto (%block);
     ];
     block %inputs [
       (var PC:bv64 := PC_in:bv64, var R0:bv64 := R0_in:bv64,
        var R1:bv64 := R1_in:bv64, var R16:bv64 := R16_in:bv64,
        var R17:bv64 := R17_in:bv64, var R29:bv64 := R29_in:bv64,
        var R30:bv64 := R30_in:bv64, var SP:bv64 := SP_in:bv64);
       goto (%createnode_code);
     ]
  ];
  proc @FUN_750(PC_in:bv64, R16_in:bv64, R17_in:bv64)
     -> (PC_out:bv64, R16_out:bv64, R17_out:bv64) {  }
    captures $mem:(bv64->bv8)
    requires boolor(eq(0x750:bv64, PC_in:bv64))

  [
     block %FUN_750_code_1 [ assert false; unreachable; ];
     block %block_3 { .asm = "br x17" } [
       var local_5:bv64 := 0x0:bv64;
       var BTypeNext:bv2 := 0x1:bv2;
       var BranchTaken:bool := true;
       var PC:bv64 := R17:bv64;
       goto (%FUN_750_code_1);
     ];
     block %block_2 { .asm = "add x16, x16, #0" } [
       var local_3:bv64 := 0x0:bv64;
       var local_4:bv64 := 0x0:bv64;
       var local_4:bv64 := R16:bv64;
       var R16:bv64 := bvadd(local_4:bv64, 0x0:bv64);
       (var BranchTaken:bool := false, var PC:bv64 := 0x75c:bv64);
       goto (%block_3);
     ];
     block %block_1 { .asm = "ldr x17, [x16]" } [
       var local:bv64 := 0x0:bv64;
       var local:bv64 := R16:bv64;
       var local_1:bv64 := 0x0:bv64;
       var local_2:bv64 := load le $mem:(bv64->bv8) bvadd(local:bv64, 0x0:bv64) 64;
       var local_1:bv64 := local_2:bv64;
       var R17:bv64 := zero_extend(0, zero_extend(0, local_1:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x758:bv64);
       goto (%block_2);
     ];
     block %block { .asm = "adrp x16, #0x20000" } [
       var R16:bv64 := 0x20000:bv64;
       (var BranchTaken:bool := false, var PC:bv64 := 0x754:bv64);
       goto (%block_1);
     ];
     block %FUN_750_code { .address = 1872; .gtirb_block = "cdQ2GS2+QhaOa7OUvPWMRQ";
         .succ = [ { .conditional = "false"; .direct = "false";
                 .target = "proxy:gq8no6SPS6K/NewOLhch1Q"; .type = "Type_Branch" } ] } [
       assume eq(0x750:bv64, PC:bv64);
       goto (%block);
     ];
     block %inputs [
       (var PC:bv64 := PC_in:bv64, var R16:bv64 := R16_in:bv64,
        var R17:bv64 := R17_in:bv64);
       goto (%FUN_750_code);
     ];
     block %returns [
       (var PC_out:bv64 := PC:bv64, var R16_out:bv64 := R16:bv64,
        var R17_out:bv64 := R17:bv64);
       return;
     ]
  ];
  proc @processlist(PC_in:bv64, PSTATE_C_in:bv1, PSTATE_N_in:bv1, PSTATE_V_in:bv1,
     PSTATE_Z_in:bv1, R0_in:bv64, R16_in:bv64, R17_in:bv64, R1_in:bv64, R29_in:bv64,
     R2_in:bv64, R30_in:bv64, R3_in:bv64, SP_in:bv64)
     -> (PC_out:bv64, PSTATE_C_out:bv1, PSTATE_N_out:bv1, PSTATE_V_out:bv1,
     PSTATE_Z_out:bv1, R0_out:bv64, R16_out:bv64, R17_out:bv64, R1_out:bv64,
     R29_out:bv64, R2_out:bv64, R30_out:bv64, R3_out:bv64, SP_out:bv64) {  }
    modifies $mem:(bv64->bv8)
    captures $mem:(bv64->bv8)
    requires boolor(eq(0x9e4:bv64, PC_in:bv64))

  [
     block %block_13 [
       assume boolnot(eq(PSTATE_Z:bv1, 0x1:bv1));
       var BranchTaken:bool := true;
       var PC:bv64 := 0xa0c:bv64;
       goto (%block_15);
     ];
     block %block_14 [
       assume boolnot(boolnot(eq(PSTATE_Z:bv1, 0x1:bv1)));
       (var BranchTaken:bool := false, var PC:bv64 := 0xa34:bv64);
       goto (%block_15);
     ];
     block %processlist_code_13 [
       assert boolor(eq(0xa54:bv64, PC:bv64));
       goto (%processlist_code_1);
     ];
     block %block_16 { .asm = "b #0x20" } [
       var BranchTaken:bool := true;
       var PC:bv64 := 0xa54:bv64;
       goto (%processlist_code_13);
     ];
     block %processlist_code_3 { .address = 2612;
         .gtirb_block = "P5G7bTtwQ5KzfyzEb1rceA";
         .succ = [ { .address = 2644; .conditional = "false"; .direct = "true";
                 .target = "internal:L48C5LViSEOx7RJ+UdllRQ"; .type = "Type_Branch" } ] } [
       assume eq(0xa34:bv64, PC:bv64);
       goto (%block_16);
     ];
     block %processlist_code_14 [
       assert boolor(eq(0x7a0:bv64, PC:bv64));
       goto (%processlist_ext);
     ];
     block %block_21 { .asm = "bl #0xfffffffffffffd84" } [
       var R30:bv64 := 0xa20:bv64;
       var BranchTaken:bool := true;
       var PC:bv64 := 0x7a0:bv64;
       goto (%processlist_code_14);
     ];
     block %block_20 { .asm = "ldr x0, [sp, #0x30]" } [
       var local_19:bv64 := 0x0:bv64;
       var local_20:bv64 := load le $mem:(bv64->bv8) bvadd(SP:bv64, 0x30:bv64) 64;
       var local_19:bv64 := local_20:bv64;
       var R0:bv64 := zero_extend(0, zero_extend(0, local_19:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0xa1c:bv64);
       goto (%block_21);
     ];
     block %block_19 { .asm = "str x0, [sp, #0x38]" } [
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(SP:bv64, 0x38:bv64) R0:bv64 64;
       (var BranchTaken:bool := false, var PC:bv64 := 0xa18:bv64);
       goto (%block_20);
     ];
     block %block_18 { .asm = "ldr x0, [x0]" } [
       var local_16:bv64 := 0x0:bv64;
       var local_16:bv64 := R0:bv64;
       var local_17:bv64 := 0x0:bv64;
       var local_18:bv64 := load le $mem:(bv64->bv8) bvadd(local_16:bv64, 0x0:bv64) 64;
       var local_17:bv64 := local_18:bv64;
       var R0:bv64 := zero_extend(0, zero_extend(0, local_17:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0xa14:bv64);
       goto (%block_19);
     ];
     block %block_17 { .asm = "ldr x0, [sp, #0x30]" } [
       var local_14:bv64 := 0x0:bv64;
       var local_15:bv64 := load le $mem:(bv64->bv8) bvadd(SP:bv64, 0x30:bv64) 64;
       var local_14:bv64 := local_15:bv64;
       var R0:bv64 := zero_extend(0, zero_extend(0, local_14:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0xa10:bv64);
       goto (%block_18);
     ];
     block %processlist_code_5 { .address = 2572;
         .gtirb_block = "VbaiJkWGQ4ukB7rQdAOUrw";
         .succ = [ { .address = 1952; .conditional = "false"; .direct = "true";
                 .target = "stmts:D9t2gNJrSmyMH3GAVRe3IQ"; .type = "Type_Call" } ] } [
       assume eq(0xa0c:bv64, PC:bv64);
       goto (%block_17);
     ];
     block %block_25 [
       assume boolnot(eq(PSTATE_Z:bv1, 0x1:bv1));
       var BranchTaken:bool := true;
       var PC:bv64 := 0xa38:bv64;
       goto (%block_27);
     ];
     block %block_26 [
       assume boolnot(boolnot(eq(PSTATE_Z:bv1, 0x1:bv1)));
       (var BranchTaken:bool := false, var PC:bv64 := 0xa60:bv64);
       goto (%block_27);
     ];
     block %returns [
       (var PC_out:bv64 := PC:bv64, var PSTATE_C_out:bv1 := PSTATE_C:bv1,
        var PSTATE_N_out:bv1 := PSTATE_N:bv1, var PSTATE_V_out:bv1 := PSTATE_V:bv1,
        var PSTATE_Z_out:bv1 := PSTATE_Z:bv1, var R0_out:bv64 := R0:bv64,
        var R1_out:bv64 := R1:bv64, var R16_out:bv64 := R16:bv64,
        var R17_out:bv64 := R17:bv64, var R2_out:bv64 := R2:bv64,
        var R29_out:bv64 := R29:bv64, var R3_out:bv64 := R3:bv64,
        var R30_out:bv64 := R30:bv64, var SP_out:bv64 := SP:bv64);
       return;
     ];
     block %ret_8 [ goto (%returns); ];
     block %processlist_code_16 [ assert false; goto (%ret_8); ];
     block %block_29 { .asm = "ret " } [
       var local_30:bv64 := 0x0:bv64;
       var BTypeNext:bv2 := 0x0:bv2;
       var BranchTaken:bool := true;
       var PC:bv64 := R30:bv64;
       goto (%processlist_code_16);
     ];
     block %block_28 { .asm = "ldp x29, x30, [sp], #0x40" } [
       var local_25:bv64 := 0x0:bv64;
       var local_25:bv64 := SP:bv64;
       var local_26:bv64 := 0x0:bv64;
       var local_27:bv64 := load le $mem:(bv64->bv8) SP:bv64 64;
       var local_26:bv64 := local_27:bv64;
       var local_28:bv64 := 0x0:bv64;
       var local_29:bv64 := load le $mem:(bv64->bv8) bvadd(SP:bv64, 0x8:bv64) 64;
       var local_28:bv64 := local_29:bv64;
       var R29:bv64 := local_26:bv64;
       var R30:bv64 := local_28:bv64;
       var SP:bv64 := bvadd(local_25:bv64, 0x40:bv64);
       (var BranchTaken:bool := false, var PC:bv64 := 0xa6c:bv64);
       goto (%block_29);
     ];
     block %processlist_code_6 { .address = 2656;
         .gtirb_block = "XRX9EXFkQgWL1KMW/G8EHQ";
         .succ = [ { .conditional = "false"; .direct = "false";
                 .target = "proxy:lW0ohNgNSB+4yKq2vEm5cg"; .type = "Type_Return" } ] } [
       assume eq(0xa60:bv64, PC:bv64);
       call @_aarch64_eval(0xd503201f:bv32, 0xa60:bv64) { .asm = "nop ";
           .error = "Failure(\"unsupported\")" };
       call @_aarch64_eval(0xd503201f:bv32, 0xa64:bv64) { .asm = "nop ";
           .error = "Failure(\"unsupported\")" };
       goto (%block_28);
     ];
     block %processlist_code_17 [
       assert boolor(eq(0x7a0:bv64, PC:bv64));
       goto (%processlist_ext);
     ];
     block %block_34 { .asm = "bl #0xfffffffffffffd58" } [
       var R30:bv64 := 0xa4c:bv64;
       var BranchTaken:bool := true;
       var PC:bv64 := 0x7a0:bv64;
       goto (%processlist_code_17);
     ];
     block %block_33 { .asm = "ldr x0, [sp, #0x28]" } [
       var local_36:bv64 := 0x0:bv64;
       var local_37:bv64 := load le $mem:(bv64->bv8) bvadd(SP:bv64, 0x28:bv64) 64;
       var local_36:bv64 := local_37:bv64;
       var R0:bv64 := zero_extend(0, zero_extend(0, local_36:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0xa48:bv64);
       goto (%block_34);
     ];
     block %block_32 { .asm = "str x0, [sp, #0x38]" } [
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(SP:bv64, 0x38:bv64) R0:bv64 64;
       (var BranchTaken:bool := false, var PC:bv64 := 0xa44:bv64);
       goto (%block_33);
     ];
     block %block_31 { .asm = "ldr x0, [x0]" } [
       var local_33:bv64 := 0x0:bv64;
       var local_33:bv64 := R0:bv64;
       var local_34:bv64 := 0x0:bv64;
       var local_35:bv64 := load le $mem:(bv64->bv8) bvadd(local_33:bv64, 0x0:bv64) 64;
       var local_34:bv64 := local_35:bv64;
       var R0:bv64 := zero_extend(0, zero_extend(0, local_34:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0xa40:bv64);
       goto (%block_32);
     ];
     block %block_30 { .asm = "ldr x0, [sp, #0x28]" } [
       var local_31:bv64 := 0x0:bv64;
       var local_32:bv64 := load le $mem:(bv64->bv8) bvadd(SP:bv64, 0x28:bv64) 64;
       var local_31:bv64 := local_32:bv64;
       var R0:bv64 := zero_extend(0, zero_extend(0, local_31:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0xa3c:bv64);
       goto (%block_31);
     ];
     block %processlist_code_7 { .address = 2616;
         .gtirb_block = "u7bJ/kNaSgSa1iIFXxesQw";
         .succ = [ { .address = 1952; .conditional = "false"; .direct = "true";
                 .target = "stmts:D9t2gNJrSmyMH3GAVRe3IQ"; .type = "Type_Call" } ] } [
       assume eq(0xa38:bv64, PC:bv64);
       goto (%block_30);
     ];
     block %processlist_code_15 [
       assert boolor(eq(0xa38:bv64, PC:bv64), eq(0xa60:bv64, PC:bv64));
       goto (%processlist_code_7,%processlist_code_6);
     ];
     block %block_27 [
       var PC:bv64 := if boolnot(eq(PSTATE_Z:bv1, 0x1:bv1)) then 0xa38:bv64 else 0xa60:bv64;
       goto (%processlist_code_15);
     ];
     block %block_24 { .asm = "b.ne #0xffffffffffffffdc" } [
       goto (%block_26,%block_25);
     ];
     block %block_23 { .asm = "cmp x0, #0" } [
       var local_23:bv64 := 0x0:bv64;
       var local_24:bv64 := 0x0:bv64;
       var PSTATE_V:bv1 := bvnot(booltobv1(eq(sign_extend(64,
          bvadd(bvadd(R0:bv64, 0xffffffffffffffff:bv64), 0x1:bv64)),
          bvadd(bvadd(sign_extend(64, R0:bv64),
            0xffffffffffffffffffffffffffffffff:bv128), 0x1:bv128))));
       var PSTATE_C:bv1 := bvnot(booltobv1(eq(zero_extend(64,
          bvadd(bvadd(R0:bv64, 0xffffffffffffffff:bv64), 0x1:bv64)),
          bvadd(bvadd(zero_extend(64, R0:bv64), 0xffffffffffffffff:bv128), 0x1:bv128))));
       var PSTATE_Z:bv1 := booltobv1(eq(bvadd(bvadd(R0:bv64, 0xffffffffffffffff:bv64),
          0x1:bv64), 0x0:bv64));
       var PSTATE_N:bv1 := extract(64,63, bvadd(bvadd(R0:bv64,
         0xffffffffffffffff:bv64), 0x1:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0xa5c:bv64);
       goto (%block_24);
     ];
     block %block_22 { .asm = "ldr x0, [sp, #0x28]" } [
       var local_21:bv64 := 0x0:bv64;
       var local_22:bv64 := load le $mem:(bv64->bv8) bvadd(SP:bv64, 0x28:bv64) 64;
       var local_21:bv64 := local_22:bv64;
       var R0:bv64 := zero_extend(0, zero_extend(0, local_21:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0xa58:bv64);
       goto (%block_23);
     ];
     block %processlist_code_1 { .address = 2644;
         .gtirb_block = "L48C5LViSEOx7RJ+UdllRQ";
         .succ = [ { .address = 2616; .conditional = "true"; .direct = "true";
                 .target = "internal:u7bJ/kNaSgSa1iIFXxesQw"; .type = "Type_Branch" };
             { .address = 2656; .conditional = "true"; .direct = "true";
                 .target = "internal:XRX9EXFkQgWL1KMW/G8EHQ";
                 .type = "Type_Fallthrough" } ] } [
       assume eq(0xa54:bv64, PC:bv64);
       goto (%block_22);
     ];
     block %processlist_code_18 [
       assert boolor(eq(0xa54:bv64, PC:bv64));
       goto (%processlist_code_1);
     ];
     block %block_36 { .asm = "str x0, [sp, #0x28]" } [
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(SP:bv64, 0x28:bv64) R0:bv64 64;
       (var BranchTaken:bool := false, var PC:bv64 := 0xa54:bv64);
       goto (%processlist_code_18);
     ];
     block %block_35 { .asm = "ldr x0, [sp, #0x38]" } [
       var local_38:bv64 := 0x0:bv64;
       var local_39:bv64 := load le $mem:(bv64->bv8) bvadd(SP:bv64, 0x38:bv64) 64;
       var local_38:bv64 := local_39:bv64;
       var R0:bv64 := zero_extend(0, zero_extend(0, local_38:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0xa50:bv64);
       goto (%block_36);
     ];
     block %processlist_code { .address = 2636;
         .gtirb_block = "FuGyG5p3Q2ycp9qxOC2b6Q";
         .succ = [ { .address = 2644; .conditional = "false"; .direct = "true";
                 .target = "internal:L48C5LViSEOx7RJ+UdllRQ";
                 .type = "Type_Fallthrough" } ] } [
       assume eq(0xa4c:bv64, PC:bv64);
       goto (%block_35);
     ];
     block %processlist_code_19 [
       assert boolor(eq(0xa28:bv64, PC:bv64));
       goto (%processlist_code_4);
     ];
     block %block_38 { .asm = "str x0, [sp, #0x30]" } [
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(SP:bv64, 0x30:bv64) R0:bv64 64;
       (var BranchTaken:bool := false, var PC:bv64 := 0xa28:bv64);
       goto (%processlist_code_19);
     ];
     block %block_37 { .asm = "ldr x0, [sp, #0x38]" } [
       var local_40:bv64 := 0x0:bv64;
       var local_41:bv64 := load le $mem:(bv64->bv8) bvadd(SP:bv64, 0x38:bv64) 64;
       var local_40:bv64 := local_41:bv64;
       var R0:bv64 := zero_extend(0, zero_extend(0, local_40:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0xa24:bv64);
       goto (%block_38);
     ];
     block %processlist_code_9 { .address = 2592;
         .gtirb_block = "3JEWNpsjRGmkoycWQqb04Q";
         .succ = [ { .address = 2600; .conditional = "false"; .direct = "true";
                 .target = "internal:Tk0jY0ehQLuBFrbkab7gag";
                 .type = "Type_Fallthrough" } ] } [
       assume eq(0xa20:bv64, PC:bv64);
       goto (%block_37);
     ];
     block %processlist_ext [
       assume eq(0x7a0:bv64, PC:bv64);
       (var PC:bv64=PC_out, var R16:bv64=R16_out, var R17:bv64=R17_out) := call @FUN_7a0(PC_in=PC:bv64,
          R16_in=R16:bv64, R17_in=R17:bv64);
       assert boolor(eq(0xa20:bv64, PC:bv64), eq(0xa4c:bv64, PC:bv64));
       goto (%processlist_code_9,%processlist_code);
     ];
     block %processlist_code_12 [
       assert boolor(eq(0xa0c:bv64, PC:bv64), eq(0xa34:bv64, PC:bv64));
       goto (%processlist_code_5,%processlist_code_3);
     ];
     block %block_15 [
       var PC:bv64 := if boolnot(eq(PSTATE_Z:bv1, 0x1:bv1)) then 0xa0c:bv64 else 0xa34:bv64;
       goto (%processlist_code_12);
     ];
     block %block_12 { .asm = "b.ne #0xffffffffffffffdc" } [
       goto (%block_14,%block_13);
     ];
     block %block_11 { .asm = "cmp x0, #0" } [
       var local_12:bv64 := 0x0:bv64;
       var local_13:bv64 := 0x0:bv64;
       var PSTATE_V:bv1 := bvnot(booltobv1(eq(sign_extend(64,
          bvadd(bvadd(R0:bv64, 0xffffffffffffffff:bv64), 0x1:bv64)),
          bvadd(bvadd(sign_extend(64, R0:bv64),
            0xffffffffffffffffffffffffffffffff:bv128), 0x1:bv128))));
       var PSTATE_C:bv1 := bvnot(booltobv1(eq(zero_extend(64,
          bvadd(bvadd(R0:bv64, 0xffffffffffffffff:bv64), 0x1:bv64)),
          bvadd(bvadd(zero_extend(64, R0:bv64), 0xffffffffffffffff:bv128), 0x1:bv128))));
       var PSTATE_Z:bv1 := booltobv1(eq(bvadd(bvadd(R0:bv64, 0xffffffffffffffff:bv64),
          0x1:bv64), 0x0:bv64));
       var PSTATE_N:bv1 := extract(64,63, bvadd(bvadd(R0:bv64,
         0xffffffffffffffff:bv64), 0x1:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0xa30:bv64);
       goto (%block_12);
     ];
     block %block_10 { .asm = "ldr x0, [sp, #0x30]" } [
       var local_10:bv64 := 0x0:bv64;
       var local_11:bv64 := load le $mem:(bv64->bv8) bvadd(SP:bv64, 0x30:bv64) 64;
       var local_10:bv64 := local_11:bv64;
       var R0:bv64 := zero_extend(0, zero_extend(0, local_10:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0xa2c:bv64);
       goto (%block_11);
     ];
     block %processlist_code_4 { .address = 2600;
         .gtirb_block = "Tk0jY0ehQLuBFrbkab7gag";
         .succ = [ { .address = 2572; .conditional = "true"; .direct = "true";
                 .target = "internal:VbaiJkWGQ4ukB7rQdAOUrw"; .type = "Type_Branch" };
             { .address = 2612; .conditional = "true"; .direct = "true";
                 .target = "internal:P5G7bTtwQ5KzfyzEb1rceA";
                 .type = "Type_Fallthrough" } ] } [
       assume eq(0xa28:bv64, PC:bv64);
       goto (%block_10);
     ];
     block %processlist_code_11 [
       assert boolor(eq(0xa28:bv64, PC:bv64));
       goto (%processlist_code_4);
     ];
     block %block_9 { .asm = "b #0x20" } [
       var BranchTaken:bool := true;
       var PC:bv64 := 0xa28:bv64;
       goto (%processlist_code_11);
     ];
     block %processlist_code_2 { .address = 2568;
         .gtirb_block = "Nc5WfkQBRwahCMMkX4LB9A";
         .succ = [ { .address = 2600; .conditional = "false"; .direct = "true";
                 .target = "internal:Tk0jY0ehQLuBFrbkab7gag"; .type = "Type_Branch" } ] } [
       assume eq(0xa08:bv64, PC:bv64);
       goto (%block_9);
     ];
     block %processlist_ext_1 [
       assume eq(0x914:bv64, PC:bv64);
       (var PC:bv64=PC_out, var PSTATE_C:bv1=PSTATE_C_out,
          var PSTATE_N:bv1=PSTATE_N_out, var PSTATE_V:bv1=PSTATE_V_out,
          var PSTATE_Z:bv1=PSTATE_Z_out, var R0:bv64=R0_out, var R16:bv64=R16_out,
          var R17:bv64=R17_out, var R1:bv64=R1_out, var R29:bv64=R29_out,
          var R2:bv64=R2_out, var R30:bv64=R30_out, var R3:bv64=R3_out,
          var SP:bv64=SP_out) := call @splitclone(PC_in=PC:bv64,
          PSTATE_C_in=PSTATE_C:bv1, PSTATE_N_in=PSTATE_N:bv1,
          PSTATE_V_in=PSTATE_V:bv1, PSTATE_Z_in=PSTATE_Z:bv1, R0_in=R0:bv64,
          R16_in=R16:bv64, R17_in=R17:bv64, R1_in=R1:bv64, R29_in=R29:bv64,
          R2_in=R2:bv64, R30_in=R30:bv64, R3_in=R3:bv64, SP_in=SP:bv64);
       assert boolor(eq(0xa08:bv64, PC:bv64));
       goto (%processlist_code_2);
     ];
     block %processlist_code_10 [
       assert boolor(eq(0x914:bv64, PC:bv64));
       goto (%processlist_ext_1);
     ];
     block %block_8 { .asm = "bl #0xffffffffffffff10" } [
       var R30:bv64 := 0xa08:bv64;
       var BranchTaken:bool := true;
       var PC:bv64 := 0x914:bv64;
       goto (%processlist_code_10);
     ];
     block %block_7 { .asm = "ldr x0, [sp, #0x18]" } [
       var local_8:bv64 := 0x0:bv64;
       var local_9:bv64 := load le $mem:(bv64->bv8) bvadd(SP:bv64, 0x18:bv64) 64;
       var local_8:bv64 := local_9:bv64;
       var R0:bv64 := zero_extend(0, zero_extend(0, local_8:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0xa04:bv64);
       goto (%block_8);
     ];
     block %block_6 { .asm = "mov x1, x0" } [
       var local_6:bv64 := 0x0:bv64;
       var local_6:bv64 := 0x0:bv64;
       var local_7:bv64 := 0x0:bv64;
       var local_7:bv64 := R0:bv64;
       var R1:bv64 := bvor(local_6:bv64,
        bvshl(local_7:bv64, zero_extend(52, 0x0:bv12)));
       (var BranchTaken:bool := false, var PC:bv64 := 0xa00:bv64);
       goto (%block_7);
     ];
     block %block_5 { .asm = "mov x2, x1" } [
       var local_4:bv64 := 0x0:bv64;
       var local_4:bv64 := 0x0:bv64;
       var local_5:bv64 := 0x0:bv64;
       var local_5:bv64 := R1:bv64;
       var R2:bv64 := bvor(local_4:bv64,
        bvshl(local_5:bv64, zero_extend(52, 0x0:bv12)));
       (var BranchTaken:bool := false, var PC:bv64 := 0x9fc:bv64);
       goto (%block_6);
     ];
     block %block_4 { .asm = "add x0, sp, #0x30" } [
       var local_3:bv64 := 0x0:bv64;
       var R0:bv64 := bvadd(SP:bv64, 0x30:bv64);
       (var BranchTaken:bool := false, var PC:bv64 := 0x9f8:bv64);
       goto (%block_5);
     ];
     block %block_3 { .asm = "add x1, sp, #0x28" } [
       var local_2:bv64 := 0x0:bv64;
       var R1:bv64 := bvadd(SP:bv64, 0x28:bv64);
       (var BranchTaken:bool := false, var PC:bv64 := 0x9f4:bv64);
       goto (%block_4);
     ];
     block %block_2 { .asm = "str x0, [sp, #0x18]" } [
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(SP:bv64, 0x18:bv64) R0:bv64 64;
       (var BranchTaken:bool := false, var PC:bv64 := 0x9f0:bv64);
       goto (%block_3);
     ];
     block %block_1 { .asm = "mov x29, sp" } [
       var local_1:bv64 := 0x0:bv64;
       var R29:bv64 := bvadd(SP:bv64, 0x0:bv64);
       (var BranchTaken:bool := false, var PC:bv64 := 0x9ec:bv64);
       goto (%block_2);
     ];
     block %block { .asm = "stp x29, x30, [sp, #-0x40]!" } [
       var local:bv64 := 0x0:bv64;
       var local:bv64 := SP:bv64;
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(SP:bv64,
        0xffffffffffffffc0:bv64) R29:bv64 64;
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(bvadd(SP:bv64,
         0xffffffffffffffc0:bv64), 0x8:bv64) R30:bv64 64;
       var SP:bv64 := bvadd(local:bv64, 0xffffffffffffffc0:bv64);
       (var BranchTaken:bool := false, var PC:bv64 := 0x9e8:bv64);
       goto (%block_1);
     ];
     block %processlist_code_8 { .address = 2532;
         .gtirb_block = "0LRsc3xvSnmWSGdUG3zWQA";
         .succ = [ { .address = 2324; .conditional = "false"; .direct = "true";
                 .target = "stmts:U8BozksvTwaykuzNC4dZRQ"; .type = "Type_Call" } ] } [
       assume eq(0x9e4:bv64, PC:bv64);
       goto (%block);
     ];
     block %inputs [
       (var PC:bv64 := PC_in:bv64, var PSTATE_C:bv1 := PSTATE_C_in:bv1,
        var PSTATE_N:bv1 := PSTATE_N_in:bv1, var PSTATE_V:bv1 := PSTATE_V_in:bv1,
        var PSTATE_Z:bv1 := PSTATE_Z_in:bv1, var R0:bv64 := R0_in:bv64,
        var R1:bv64 := R1_in:bv64, var R16:bv64 := R16_in:bv64,
        var R17:bv64 := R17_in:bv64, var R2:bv64 := R2_in:bv64,
        var R29:bv64 := R29_in:bv64, var R3:bv64 := R3_in:bv64,
        var R30:bv64 := R30_in:bv64, var SP:bv64 := SP_in:bv64);
       goto (%processlist_code_8);
     ]
  ];
  proc @FUN_770(PC_in:bv64, R16_in:bv64, R17_in:bv64)
     -> (PC_out:bv64, R16_out:bv64, R17_out:bv64) {  }
    captures $mem:(bv64->bv8)
    requires boolor(eq(0x770:bv64, PC_in:bv64))

  [
     block %FUN_770_code_1 [ assert false; unreachable; ];
     block %block_3 { .asm = "br x17" } [
       var local_5:bv64 := 0x0:bv64;
       var BTypeNext:bv2 := 0x1:bv2;
       var BranchTaken:bool := true;
       var PC:bv64 := R17:bv64;
       goto (%FUN_770_code_1);
     ];
     block %block_2 { .asm = "add x16, x16, #0x10" } [
       var local_3:bv64 := 0x0:bv64;
       var local_4:bv64 := 0x0:bv64;
       var local_4:bv64 := R16:bv64;
       var R16:bv64 := bvadd(local_4:bv64, 0x10:bv64);
       (var BranchTaken:bool := false, var PC:bv64 := 0x77c:bv64);
       goto (%block_3);
     ];
     block %block_1 { .asm = "ldr x17, [x16, #0x10]" } [
       var local:bv64 := 0x0:bv64;
       var local:bv64 := R16:bv64;
       var local_1:bv64 := 0x0:bv64;
       var local_2:bv64 := load le $mem:(bv64->bv8) bvadd(local:bv64, 0x10:bv64) 64;
       var local_1:bv64 := local_2:bv64;
       var R17:bv64 := zero_extend(0, zero_extend(0, local_1:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x778:bv64);
       goto (%block_2);
     ];
     block %block { .asm = "adrp x16, #0x20000" } [
       var R16:bv64 := 0x20000:bv64;
       (var BranchTaken:bool := false, var PC:bv64 := 0x774:bv64);
       goto (%block_1);
     ];
     block %FUN_770_code { .address = 1904; .gtirb_block = "tXIOhSQ+R1WA/9VL5+6KQQ";
         .succ = [ { .conditional = "false"; .direct = "false";
                 .target = "proxy:DwpNnuk8TK6A1SIfun21jA"; .type = "Type_Branch" } ] } [
       assume eq(0x770:bv64, PC:bv64);
       goto (%block);
     ];
     block %inputs [
       (var PC:bv64 := PC_in:bv64, var R16:bv64 := R16_in:bv64,
        var R17:bv64 := R17_in:bv64);
       goto (%FUN_770_code);
     ];
     block %returns [
       (var PC_out:bv64 := PC:bv64, var R16_out:bv64 := R16:bv64,
        var R17_out:bv64 := R17:bv64);
       return;
     ]
  ];
  proc @FUN_760(PC_in:bv64, R16_in:bv64, R17_in:bv64)
     -> (PC_out:bv64, R16_out:bv64, R17_out:bv64) {  }
    captures $mem:(bv64->bv8)
    requires boolor(eq(0x760:bv64, PC_in:bv64))

  [
     block %FUN_760_code_1 [ assert false; unreachable; ];
     block %block_3 { .asm = "br x17" } [
       var local_5:bv64 := 0x0:bv64;
       var BTypeNext:bv2 := 0x1:bv2;
       var BranchTaken:bool := true;
       var PC:bv64 := R17:bv64;
       goto (%FUN_760_code_1);
     ];
     block %block_2 { .asm = "add x16, x16, #8" } [
       var local_3:bv64 := 0x0:bv64;
       var local_4:bv64 := 0x0:bv64;
       var local_4:bv64 := R16:bv64;
       var R16:bv64 := bvadd(local_4:bv64, 0x8:bv64);
       (var BranchTaken:bool := false, var PC:bv64 := 0x76c:bv64);
       goto (%block_3);
     ];
     block %block_1 { .asm = "ldr x17, [x16, #8]" } [
       var local:bv64 := 0x0:bv64;
       var local:bv64 := R16:bv64;
       var local_1:bv64 := 0x0:bv64;
       var local_2:bv64 := load le $mem:(bv64->bv8) bvadd(local:bv64, 0x8:bv64) 64;
       var local_1:bv64 := local_2:bv64;
       var R17:bv64 := zero_extend(0, zero_extend(0, local_1:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x768:bv64);
       goto (%block_2);
     ];
     block %block { .asm = "adrp x16, #0x20000" } [
       var R16:bv64 := 0x20000:bv64;
       (var BranchTaken:bool := false, var PC:bv64 := 0x764:bv64);
       goto (%block_1);
     ];
     block %FUN_760_code { .address = 1888; .gtirb_block = "rIlbG4jGSTydaFqMhxCKWw";
         .succ = [ { .conditional = "false"; .direct = "false";
                 .target = "proxy:xyyyD0pYSZaT/KNxqITDUg"; .type = "Type_Branch" } ] } [
       assume eq(0x760:bv64, PC:bv64);
       goto (%block);
     ];
     block %inputs [
       (var PC:bv64 := PC_in:bv64, var R16:bv64 := R16_in:bv64,
        var R17:bv64 := R17_in:bv64);
       goto (%FUN_760_code);
     ];
     block %returns [
       (var PC_out:bv64 := PC:bv64, var R16_out:bv64 := R16:bv64,
        var R17_out:bv64 := R17:bv64);
       return;
     ]
  ];
  proc @.L_780(PC_in:bv64, R16_in:bv64, R17_in:bv64)
     -> (PC_out:bv64, R16_out:bv64, R17_out:bv64) {  }
    captures $mem:(bv64->bv8)
    requires boolor(eq(0x780:bv64, PC_in:bv64))

  [
     block %L_780_code_1 [ assert false; unreachable; ];
     block %block_3 { .asm = "br x17" } [
       var local_5:bv64 := 0x0:bv64;
       var BTypeNext:bv2 := 0x1:bv2;
       var BranchTaken:bool := true;
       var PC:bv64 := R17:bv64;
       goto (%L_780_code_1);
     ];
     block %block_2 { .asm = "add x16, x16, #0x18" } [
       var local_3:bv64 := 0x0:bv64;
       var local_4:bv64 := 0x0:bv64;
       var local_4:bv64 := R16:bv64;
       var R16:bv64 := bvadd(local_4:bv64, 0x18:bv64);
       (var BranchTaken:bool := false, var PC:bv64 := 0x78c:bv64);
       goto (%block_3);
     ];
     block %block_1 { .asm = "ldr x17, [x16, #0x18]" } [
       var local:bv64 := 0x0:bv64;
       var local:bv64 := R16:bv64;
       var local_1:bv64 := 0x0:bv64;
       var local_2:bv64 := load le $mem:(bv64->bv8) bvadd(local:bv64, 0x18:bv64) 64;
       var local_1:bv64 := local_2:bv64;
       var R17:bv64 := zero_extend(0, zero_extend(0, local_1:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x788:bv64);
       goto (%block_2);
     ];
     block %block { .asm = "adrp x16, #0x20000" } [
       var R16:bv64 := 0x20000:bv64;
       (var BranchTaken:bool := false, var PC:bv64 := 0x784:bv64);
       goto (%block_1);
     ];
     block %L_780_code { .address = 1920; .gtirb_block = "oqiqdATZTc6MDOYJqL9Aew";
         .succ = [ { .conditional = "false"; .direct = "false";
                 .target = "proxy:19dUtUkfQT29MOZB2jCDZQ"; .type = "Type_Branch" } ] } [
       assume eq(0x780:bv64, PC:bv64);
       goto (%block);
     ];
     block %inputs [
       (var PC:bv64 := PC_in:bv64, var R16:bv64 := R16_in:bv64,
        var R17:bv64 := R17_in:bv64);
       goto (%L_780_code);
     ];
     block %returns [
       (var PC_out:bv64 := PC:bv64, var R16_out:bv64 := R16:bv64,
        var R17_out:bv64 := R17:bv64);
       return;
     ]
  ];
  proc @FUN_790(PC_in:bv64, R16_in:bv64, R17_in:bv64)
     -> (PC_out:bv64, R16_out:bv64, R17_out:bv64) {  }
    captures $mem:(bv64->bv8)
    requires boolor(eq(0x790:bv64, PC_in:bv64))

  [
     block %FUN_790_code_1 [ assert false; unreachable; ];
     block %block_3 { .asm = "br x17" } [
       var local_5:bv64 := 0x0:bv64;
       var BTypeNext:bv2 := 0x1:bv2;
       var BranchTaken:bool := true;
       var PC:bv64 := R17:bv64;
       goto (%FUN_790_code_1);
     ];
     block %block_2 { .asm = "add x16, x16, #0x20" } [
       var local_3:bv64 := 0x0:bv64;
       var local_4:bv64 := 0x0:bv64;
       var local_4:bv64 := R16:bv64;
       var R16:bv64 := bvadd(local_4:bv64, 0x20:bv64);
       (var BranchTaken:bool := false, var PC:bv64 := 0x79c:bv64);
       goto (%block_3);
     ];
     block %block_1 { .asm = "ldr x17, [x16, #0x20]" } [
       var local:bv64 := 0x0:bv64;
       var local:bv64 := R16:bv64;
       var local_1:bv64 := 0x0:bv64;
       var local_2:bv64 := load le $mem:(bv64->bv8) bvadd(local:bv64, 0x20:bv64) 64;
       var local_1:bv64 := local_2:bv64;
       var R17:bv64 := zero_extend(0, zero_extend(0, local_1:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x798:bv64);
       goto (%block_2);
     ];
     block %block { .asm = "adrp x16, #0x20000" } [
       var R16:bv64 := 0x20000:bv64;
       (var BranchTaken:bool := false, var PC:bv64 := 0x794:bv64);
       goto (%block_1);
     ];
     block %FUN_790_code { .address = 1936; .gtirb_block = "IkNYmV06TxC75h8A4NM3wA";
         .succ = [ { .conditional = "false"; .direct = "false";
                 .target = "proxy:SuifTKCYSwiGCbBYg+SF+w"; .type = "Type_Branch" } ] } [
       assume eq(0x790:bv64, PC:bv64);
       goto (%block);
     ];
     block %inputs [
       (var PC:bv64 := PC_in:bv64, var R16:bv64 := R16_in:bv64,
        var R17:bv64 := R17_in:bv64);
       goto (%FUN_790_code);
     ];
     block %returns [
       (var PC_out:bv64 := PC:bv64, var R16_out:bv64 := R16:bv64,
        var R17_out:bv64 := R17:bv64);
       return;
     ]
  ];
  proc @_fini(PC_in:bv64, R29_in:bv64, R30_in:bv64, SP_in:bv64)
     -> (PC_out:bv64, R29_out:bv64, R30_out:bv64, SP_out:bv64) {  }
    modifies $mem:(bv64->bv8)
    captures $mem:(bv64->bv8)
    requires boolor(eq(0xa84:bv64, PC_in:bv64))

  [
     block %returns [
       (var PC_out:bv64 := PC:bv64, var R29_out:bv64 := R29:bv64,
        var R30_out:bv64 := R30:bv64, var SP_out:bv64 := SP:bv64);
       return;
     ];
     block %ret_1 [ goto (%returns); ];
     block %_fini_code_4 [ assert false; goto (%ret_1); ];
     block %block_3 { .asm = "ret " } [
       var local_7:bv64 := 0x0:bv64;
       var BTypeNext:bv2 := 0x0:bv2;
       var BranchTaken:bool := true;
       var PC:bv64 := R30:bv64;
       goto (%_fini_code_4);
     ];
     block %_fini_code_3 [
       call @_aarch64_eval(0xd50323bf:bv32, 0xa94:bv64) { .asm = "autiasp ";
           .error = "Failure(\"unsupported\")" };
       goto (%block_3);
     ];
     block %block_2 { .asm = "ldp x29, x30, [sp], #0x10" } [
       var local_2:bv64 := 0x0:bv64;
       var local_2:bv64 := SP:bv64;
       var local_3:bv64 := 0x0:bv64;
       var local_4:bv64 := load le $mem:(bv64->bv8) SP:bv64 64;
       var local_3:bv64 := local_4:bv64;
       var local_5:bv64 := 0x0:bv64;
       var local_6:bv64 := load le $mem:(bv64->bv8) bvadd(SP:bv64, 0x8:bv64) 64;
       var local_5:bv64 := local_6:bv64;
       var R29:bv64 := local_3:bv64;
       var R30:bv64 := local_5:bv64;
       var SP:bv64 := bvadd(local_2:bv64, 0x10:bv64);
       (var BranchTaken:bool := false, var PC:bv64 := 0xa94:bv64);
       goto (%_fini_code_3);
     ];
     block %_fini_code_1 { .address = 2704; .gtirb_block = "wQy5IvXtT0a6h9Xb/DD2Pg";
         .succ = [ { .conditional = "false"; .direct = "false";
                 .target = "proxy:lW0ohNgNSB+4yKq2vEm5cg"; .type = "Type_Return" } ] } [
       assume eq(0xa90:bv64, PC:bv64);
       goto (%block_2);
     ];
     block %_fini_code_2 [
       assert boolor(eq(0xa90:bv64, PC:bv64));
       goto (%_fini_code_1);
     ];
     block %block_1 { .asm = "mov x29, sp" } [
       var local_1:bv64 := 0x0:bv64;
       var R29:bv64 := bvadd(SP:bv64, 0x0:bv64);
       (var BranchTaken:bool := false, var PC:bv64 := 0xa90:bv64);
       goto (%_fini_code_2);
     ];
     block %block { .asm = "stp x29, x30, [sp, #-0x10]!" } [
       var local:bv64 := 0x0:bv64;
       var local:bv64 := SP:bv64;
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(SP:bv64,
        0xfffffffffffffff0:bv64) R29:bv64 64;
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(bvadd(SP:bv64,
         0xfffffffffffffff0:bv64), 0x8:bv64) R30:bv64 64;
       var SP:bv64 := bvadd(local:bv64, 0xfffffffffffffff0:bv64);
       (var BranchTaken:bool := false, var PC:bv64 := 0xa8c:bv64);
       goto (%block_1);
     ];
     block %_fini_code { .address = 2692; .gtirb_block = "ee2a4PNPSWyjB3fxfvR3Pg";
         .succ = [ { .address = 2704; .conditional = "false"; .direct = "true";
                 .target = "internal:wQy5IvXtT0a6h9Xb/DD2Pg";
                 .type = "Type_Fallthrough" } ] } [
       assume eq(0xa84:bv64, PC:bv64);
       call @_aarch64_eval(0xd503233f:bv32, 0xa84:bv64) { .asm = "paciasp ";
           .error = "Failure(\"unsupported\")" };
       goto (%block);
     ];
     block %inputs [
       (var PC:bv64 := PC_in:bv64, var R29:bv64 := R29_in:bv64,
        var R30:bv64 := R30_in:bv64, var SP:bv64 := SP_in:bv64);
       goto (%_fini_code);
     ]
  ];
  proc @deregister_tm_clones(PC_in:bv64, PSTATE_C_in:bv1, PSTATE_N_in:bv1,
     PSTATE_V_in:bv1, PSTATE_Z_in:bv1, R0_in:bv64, R16_in:bv64, R1_in:bv64,
     R30_in:bv64)
     -> (PC_out:bv64, PSTATE_C_out:bv1, PSTATE_N_out:bv1, PSTATE_V_out:bv1,
     PSTATE_Z_out:bv1, R0_out:bv64, R16_out:bv64, R1_out:bv64) {  }
    captures $mem:(bv64->bv8)
    requires boolor(eq(0x820:bv64, PC_in:bv64))

  [
     block %block_6 [
       assume eq(PSTATE_Z:bv1, 0x1:bv1);
       var BranchTaken:bool := true;
       var PC:bv64 := 0x84c:bv64;
       goto (%block_8);
     ];
     block %block_7 [
       assume boolnot(eq(PSTATE_Z:bv1, 0x1:bv1));
       (var BranchTaken:bool := false, var PC:bv64 := 0x838:bv64);
       goto (%block_8);
     ];
     block %returns [
       (var PC_out:bv64 := PC:bv64, var PSTATE_C_out:bv1 := PSTATE_C:bv1,
        var PSTATE_N_out:bv1 := PSTATE_N:bv1, var PSTATE_V_out:bv1 := PSTATE_V:bv1,
        var PSTATE_Z_out:bv1 := PSTATE_Z:bv1, var R0_out:bv64 := R0:bv64,
        var R1_out:bv64 := R1:bv64, var R16_out:bv64 := R16:bv64);
       return;
     ];
     block %ret [ goto (%returns); ];
     block %deregister_tm_clones_code_5 [
       assert boolor(eq(0x8c0:bv64, PC:bv64));
       goto (%ret);
     ];
     block %block_9 { .asm = "ret " } [
       var local_6:bv64 := 0x0:bv64;
       var BTypeNext:bv2 := 0x0:bv2;
       var BranchTaken:bool := true;
       var PC:bv64 := R30:bv64;
       goto (%deregister_tm_clones_code_5);
     ];
     block %deregister_tm_clones_code { .address = 2124;
         .gtirb_block = "HVqN0/3+RWiLPKsHRvUqeg";
         .succ = [ { .address = 2240; .conditional = "false"; .direct = "true";
                 .target = "external:G0vHB4sSQ3yHYTbHJG37zQ"; .type = "Type_Return" } ] } [
       assume eq(0x84c:bv64, PC:bv64);
       goto (%block_9);
     ];
     block %block_13 [
       assume eq(R1:bv64, 0x0:bv64);
       var BranchTaken:bool := true;
       var PC:bv64 := 0x84c:bv64;
       goto (%block_15);
     ];
     block %block_14 [
       assume boolnot(eq(R1:bv64, 0x0:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x844:bv64);
       goto (%block_15);
     ];
     block %deregister_tm_clones_code_7 [ assert false; unreachable; ];
     block %block_17 { .asm = "br x16" } [
       var local_12:bv64 := 0x0:bv64;
       var BTypeNext:bv2 := 0x1:bv2;
       var BranchTaken:bool := true;
       var PC:bv64 := R16:bv64;
       goto (%deregister_tm_clones_code_7);
     ];
     block %block_16 { .asm = "mov x16, x1" } [
       var local_10:bv64 := 0x0:bv64;
       var local_10:bv64 := 0x0:bv64;
       var local_11:bv64 := 0x0:bv64;
       var local_11:bv64 := R1:bv64;
       var R16:bv64 := bvor(local_10:bv64,
        bvshl(local_11:bv64, zero_extend(52, 0x0:bv12)));
       (var BranchTaken:bool := false, var PC:bv64 := 0x848:bv64);
       goto (%block_17);
     ];
     block %deregister_tm_clones_code_2 { .address = 2116;
         .gtirb_block = "ZLfuz7OtTNOS9GLtqSI1gg";
         .succ = [ { .conditional = "false"; .direct = "false";
                 .target = "proxy:lW0ohNgNSB+4yKq2vEm5cg"; .type = "Type_Branch" } ] } [
       assume eq(0x844:bv64, PC:bv64);
       goto (%block_16);
     ];
     block %deregister_tm_clones_code_6 [
       assert boolor(eq(0x844:bv64, PC:bv64), eq(0x84c:bv64, PC:bv64));
       goto (%deregister_tm_clones_code_2,%deregister_tm_clones_code);
     ];
     block %block_15 [
       var PC:bv64 := if eq(R1:bv64, 0x0:bv64) then 0x84c:bv64 else 0x844:bv64;
       goto (%deregister_tm_clones_code_6);
     ];
     block %block_12 { .asm = "cbz x1, #0xc" } [ goto (%block_14,%block_13); ];
     block %block_11 { .asm = "ldr x1, [x1, #0xfc0]" } [
       var local_7:bv64 := 0x0:bv64;
       var local_7:bv64 := R1:bv64;
       var local_8:bv64 := 0x0:bv64;
       var local_9:bv64 := load le $mem:(bv64->bv8) bvadd(local_7:bv64, 0xfc0:bv64) 64;
       var local_8:bv64 := local_9:bv64;
       var R1:bv64 := zero_extend(0, zero_extend(0, local_8:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x840:bv64);
       goto (%block_12);
     ];
     block %block_10 { .asm = "adrp x1, #0x1f000" } [
       var R1:bv64 := 0x1f000:bv64;
       (var BranchTaken:bool := false, var PC:bv64 := 0x83c:bv64);
       goto (%block_11);
     ];
     block %deregister_tm_clones_code_3 { .address = 2104;
         .gtirb_block = "rCSSdLZcRB2TKAu9h+WCqg";
         .succ = [ { .address = 2116; .conditional = "true"; .direct = "true";
                 .target = "internal:ZLfuz7OtTNOS9GLtqSI1gg";
                 .type = "Type_Fallthrough" };
             { .address = 2124; .conditional = "true"; .direct = "true";
                 .target = "internal:HVqN0/3+RWiLPKsHRvUqeg"; .type = "Type_Branch" } ] } [
       assume eq(0x838:bv64, PC:bv64);
       goto (%block_10);
     ];
     block %deregister_tm_clones_code_4 [
       assert boolor(eq(0x838:bv64, PC:bv64), eq(0x84c:bv64, PC:bv64));
       goto (%deregister_tm_clones_code_3,%deregister_tm_clones_code);
     ];
     block %block_8 [
       var PC:bv64 := if eq(PSTATE_Z:bv1, 0x1:bv1) then 0x84c:bv64 else 0x838:bv64;
       goto (%deregister_tm_clones_code_4);
     ];
     block %block_5 { .asm = "b.eq #0x18" } [ goto (%block_7,%block_6); ];
     block %block_4 { .asm = "cmp x1, x0" } [
       var local_4:bv64 := 0x0:bv64;
       var local_5:bv64 := 0x0:bv64;
       var PSTATE_V:bv1 := bvnot(booltobv1(eq(sign_extend(64,
          bvadd(bvadd(R1:bv64, bvnot(bvshl(R0:bv64, zero_extend(52, 0x0:bv12)))),
           0x1:bv64)),
          bvadd(bvadd(sign_extend(64, R1:bv64),
            sign_extend(64, bvnot(bvshl(R0:bv64, zero_extend(52, 0x0:bv12))))),
           0x1:bv128))));
       var PSTATE_C:bv1 := bvnot(booltobv1(eq(zero_extend(64,
          bvadd(bvadd(R1:bv64, bvnot(bvshl(R0:bv64, zero_extend(52, 0x0:bv12)))),
           0x1:bv64)),
          bvadd(bvadd(zero_extend(64, R1:bv64),
            zero_extend(64, bvnot(bvshl(R0:bv64, zero_extend(52, 0x0:bv12))))),
           0x1:bv128))));
       var PSTATE_Z:bv1 := booltobv1(eq(bvadd(bvadd(R1:bv64,
           bvnot(bvshl(R0:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64), 0x0:bv64));
       var PSTATE_N:bv1 := extract(64,63, bvadd(bvadd(R1:bv64,
         bvnot(bvshl(R0:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x834:bv64);
       goto (%block_5);
     ];
     block %block_3 { .asm = "add x1, x1, #0x40" } [
       var local_2:bv64 := 0x0:bv64;
       var local_3:bv64 := 0x0:bv64;
       var local_3:bv64 := R1:bv64;
       var R1:bv64 := bvadd(local_3:bv64, 0x40:bv64);
       (var BranchTaken:bool := false, var PC:bv64 := 0x830:bv64);
       goto (%block_4);
     ];
     block %block_2 { .asm = "adrp x1, #0x20000" } [
       var R1:bv64 := 0x20000:bv64;
       (var BranchTaken:bool := false, var PC:bv64 := 0x82c:bv64);
       goto (%block_3);
     ];
     block %block_1 { .asm = "add x0, x0, #0x40" } [
       var local:bv64 := 0x0:bv64;
       var local_1:bv64 := 0x0:bv64;
       var local_1:bv64 := R0:bv64;
       var R0:bv64 := bvadd(local_1:bv64, 0x40:bv64);
       (var BranchTaken:bool := false, var PC:bv64 := 0x828:bv64);
       goto (%block_2);
     ];
     block %block { .asm = "adrp x0, #0x20000" } [
       var R0:bv64 := 0x20000:bv64;
       (var BranchTaken:bool := false, var PC:bv64 := 0x824:bv64);
       goto (%block_1);
     ];
     block %deregister_tm_clones_code_1 { .address = 2080;
         .gtirb_block = "OuTzy8qRTci75taVjGinFQ";
         .succ = [ { .address = 2104; .conditional = "true"; .direct = "true";
                 .target = "internal:rCSSdLZcRB2TKAu9h+WCqg";
                 .type = "Type_Fallthrough" };
             { .address = 2124; .conditional = "true"; .direct = "true";
                 .target = "internal:HVqN0/3+RWiLPKsHRvUqeg"; .type = "Type_Branch" } ] } [
       assume eq(0x820:bv64, PC:bv64);
       goto (%block);
     ];
     block %inputs [
       (var PC:bv64 := PC_in:bv64, var PSTATE_C:bv1 := PSTATE_C_in:bv1,
        var PSTATE_N:bv1 := PSTATE_N_in:bv1, var PSTATE_V:bv1 := PSTATE_V_in:bv1,
        var PSTATE_Z:bv1 := PSTATE_Z_in:bv1, var R0:bv64 := R0_in:bv64,
        var R1:bv64 := R1_in:bv64, var R16:bv64 := R16_in:bv64,
        var R30:bv64 := R30_in:bv64);
       goto (%deregister_tm_clones_code_1);
     ]
  ];
  proc @_start(PC_in:bv64, R0_in:bv64, R16_in:bv64, R17_in:bv64, R1_in:bv64,
     R29_in:bv64, R2_in:bv64, R30_in:bv64, R3_in:bv64, R4_in:bv64, R5_in:bv64,
     R6_in:bv64, SP_in:bv64)
     -> (PC_out:bv64, R0_out:bv64, R16_out:bv64, R17_out:bv64, R1_out:bv64,
     R29_out:bv64, R2_out:bv64, R30_out:bv64, R3_out:bv64, R4_out:bv64, R5_out:bv64,
     R6_out:bv64) {  }
    captures $mem:(bv64->bv8)
    requires boolor(eq(0x7c0:bv64, PC_in:bv64))

  [
     block %_start_ext [
       assume eq(0x790:bv64, PC:bv64);
       (var PC:bv64=PC_out, var R16:bv64=R16_out, var R17:bv64=R17_out) := call @FUN_790(PC_in=PC:bv64,
          R16_in=R16:bv64, R17_in=R17:bv64);
       assert false;
       unreachable;
     ];
     block %_start_code_3 [
       assert boolor(eq(0x790:bv64, PC:bv64));
       goto (%_start_ext);
     ];
     block %block_11 { .asm = "bl #0xffffffffffffffa0" } [
       var R30:bv64 := 0x7f4:bv64;
       var BranchTaken:bool := true;
       var PC:bv64 := 0x790:bv64;
       goto (%_start_code_3);
     ];
     block %_start_code { .address = 2032; .gtirb_block = "TxTRm4kpQiq/Xgistx+xbQ";
         .succ = [ { .address = 1936; .conditional = "false"; .direct = "true";
                 .target = "stmts:IkNYmV06TxC75h8A4NM3wA"; .type = "Type_Call" } ] } [
       assume eq(0x7f0:bv64, PC:bv64);
       goto (%block_11);
     ];
     block %_start_ext_1 [
       assume eq(0x750:bv64, PC:bv64);
       (var PC:bv64=PC_out, var R16:bv64=R16_out, var R17:bv64=R17_out) := call @FUN_750(PC_in=PC:bv64,
          R16_in=R16:bv64, R17_in=R17:bv64);
       assert boolor(eq(0x7f0:bv64, PC:bv64));
       goto (%_start_code);
     ];
     block %_start_code_2 [
       assert boolor(eq(0x750:bv64, PC:bv64));
       goto (%_start_ext_1);
     ];
     block %block_10 { .asm = "bl #0xffffffffffffff64" } [
       var R30:bv64 := 0x7f0:bv64;
       var BranchTaken:bool := true;
       var PC:bv64 := 0x750:bv64;
       goto (%_start_code_2);
     ];
     block %block_9 { .asm = "mov x4, #0" } [
       var R4:bv64 := 0x0:bv64;
       (var BranchTaken:bool := false, var PC:bv64 := 0x7ec:bv64);
       goto (%block_10);
     ];
     block %block_8 { .asm = "mov x3, #0" } [
       var R3:bv64 := 0x0:bv64;
       (var BranchTaken:bool := false, var PC:bv64 := 0x7e8:bv64);
       goto (%block_9);
     ];
     block %block_7 { .asm = "ldr x0, [x0, #0xfd8]" } [
       var local_6:bv64 := 0x0:bv64;
       var local_6:bv64 := R0:bv64;
       var local_7:bv64 := 0x0:bv64;
       var local_8:bv64 := load le $mem:(bv64->bv8) bvadd(local_6:bv64, 0xfd8:bv64) 64;
       var local_7:bv64 := local_8:bv64;
       var R0:bv64 := zero_extend(0, zero_extend(0, local_7:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x7e4:bv64);
       goto (%block_8);
     ];
     block %block_6 { .asm = "adrp x0, #0x1f000" } [
       var R0:bv64 := 0x1f000:bv64;
       (var BranchTaken:bool := false, var PC:bv64 := 0x7e0:bv64);
       goto (%block_7);
     ];
     block %block_5 { .asm = "mov x6, sp" } [
       var local_5:bv64 := 0x0:bv64;
       var R6:bv64 := bvadd(SP:bv64, 0x0:bv64);
       (var BranchTaken:bool := false, var PC:bv64 := 0x7dc:bv64);
       goto (%block_6);
     ];
     block %block_4 { .asm = "add x2, sp, #8" } [
       var local_4:bv64 := 0x0:bv64;
       var R2:bv64 := bvadd(SP:bv64, 0x8:bv64);
       (var BranchTaken:bool := false, var PC:bv64 := 0x7d8:bv64);
       goto (%block_5);
     ];
     block %block_3 { .asm = "ldr x1, [sp]" } [
       var local_2:bv64 := 0x0:bv64;
       var local_3:bv64 := load le $mem:(bv64->bv8) bvadd(SP:bv64, 0x0:bv64) 64;
       var local_2:bv64 := local_3:bv64;
       var R1:bv64 := zero_extend(0, zero_extend(0, local_2:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x7d4:bv64);
       goto (%block_4);
     ];
     block %block_2 { .asm = "mov x5, x0" } [
       var local:bv64 := 0x0:bv64;
       var local:bv64 := 0x0:bv64;
       var local_1:bv64 := 0x0:bv64;
       var local_1:bv64 := R0:bv64;
       var R5:bv64 := bvor(local:bv64,
        bvshl(local_1:bv64, zero_extend(52, 0x0:bv12)));
       (var BranchTaken:bool := false, var PC:bv64 := 0x7d0:bv64);
       goto (%block_3);
     ];
     block %block_1 { .asm = "mov x30, #0" } [
       var R30:bv64 := 0x0:bv64;
       (var BranchTaken:bool := false, var PC:bv64 := 0x7cc:bv64);
       goto (%block_2);
     ];
     block %block { .asm = "mov x29, #0" } [
       var R29:bv64 := 0x0:bv64;
       (var BranchTaken:bool := false, var PC:bv64 := 0x7c8:bv64);
       goto (%block_1);
     ];
     block %_start_code_1 { .address = 1984; .gtirb_block = "lwyID0MJQb6vgyjzPFtz8Q";
         .succ = [ { .address = 1872; .conditional = "false"; .direct = "true";
                 .target = "stmts:cdQ2GS2+QhaOa7OUvPWMRQ"; .type = "Type_Call" } ] } [
       assume eq(0x7c0:bv64, PC:bv64);
       call @_aarch64_eval(0xd503245f:bv32, 0x7c0:bv64) { .asm = "bti c";
           .error = "Failure(\"unsupported\")" };
       goto (%block);
     ];
     block %inputs [
       (var PC:bv64 := PC_in:bv64, var R0:bv64 := R0_in:bv64,
        var R1:bv64 := R1_in:bv64, var R16:bv64 := R16_in:bv64,
        var R17:bv64 := R17_in:bv64, var R2:bv64 := R2_in:bv64,
        var R29:bv64 := R29_in:bv64, var R3:bv64 := R3_in:bv64,
        var R30:bv64 := R30_in:bv64, var R4:bv64 := R4_in:bv64,
        var R5:bv64 := R5_in:bv64, var R6:bv64 := R6_in:bv64,
        var SP:bv64 := SP_in:bv64);
       goto (%_start_code_1);
     ];
     block %returns [
       (var PC_out:bv64 := PC:bv64, var R0_out:bv64 := R0:bv64,
        var R1_out:bv64 := R1:bv64, var R16_out:bv64 := R16:bv64,
        var R17_out:bv64 := R17:bv64, var R2_out:bv64 := R2:bv64,
        var R29_out:bv64 := R29:bv64, var R3_out:bv64 := R3:bv64,
        var R30_out:bv64 := R30:bv64, var R4_out:bv64 := R4:bv64,
        var R5_out:bv64 := R5:bv64, var R6_out:bv64 := R6:bv64);
       return;
     ]
  ];
  proc @register_tm_clones(PC_in:bv64, R0_in:bv64, R16_in:bv64, R1_in:bv64,
     R2_in:bv64, R30_in:bv64)
     -> (PC_out:bv64, R0_out:bv64, R16_out:bv64, R1_out:bv64, R2_out:bv64) {  }
    captures $mem:(bv64->bv8)
    requires boolor(eq(0x850:bv64, PC_in:bv64))

  [
     block %block_9 [
       assume eq(R1:bv64, 0x0:bv64);
       var BranchTaken:bool := true;
       var PC:bv64 := 0x888:bv64;
       goto (%block_11);
     ];
     block %block_10 [
       assume boolnot(eq(R1:bv64, 0x0:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x874:bv64);
       goto (%block_11);
     ];
     block %block_15 [
       assume eq(R2:bv64, 0x0:bv64);
       var BranchTaken:bool := true;
       var PC:bv64 := 0x888:bv64;
       goto (%block_17);
     ];
     block %block_16 [
       assume boolnot(eq(R2:bv64, 0x0:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x880:bv64);
       goto (%block_17);
     ];
     block %register_tm_clones_code_6 [ assert false; unreachable; ];
     block %block_19 { .asm = "br x16" } [
       var local_15:bv64 := 0x0:bv64;
       var BTypeNext:bv2 := 0x1:bv2;
       var BranchTaken:bool := true;
       var PC:bv64 := R16:bv64;
       goto (%register_tm_clones_code_6);
     ];
     block %block_18 { .asm = "mov x16, x2" } [
       var local_13:bv64 := 0x0:bv64;
       var local_13:bv64 := 0x0:bv64;
       var local_14:bv64 := 0x0:bv64;
       var local_14:bv64 := R2:bv64;
       var R16:bv64 := bvor(local_13:bv64,
        bvshl(local_14:bv64, zero_extend(52, 0x0:bv12)));
       (var BranchTaken:bool := false, var PC:bv64 := 0x884:bv64);
       goto (%block_19);
     ];
     block %register_tm_clones_code { .address = 2176;
         .gtirb_block = "b8tsihT4Q6a/SWPo4w8HoA";
         .succ = [ { .conditional = "false"; .direct = "false";
                 .target = "proxy:lW0ohNgNSB+4yKq2vEm5cg"; .type = "Type_Branch" } ] } [
       assume eq(0x880:bv64, PC:bv64);
       goto (%block_18);
     ];
     block %register_tm_clones_code_5 [
       assert boolor(eq(0x888:bv64, PC:bv64), eq(0x880:bv64, PC:bv64));
       goto (%register_tm_clones_code_2,%register_tm_clones_code);
     ];
     block %block_17 [
       var PC:bv64 := if eq(R2:bv64, 0x0:bv64) then 0x888:bv64 else 0x880:bv64;
       goto (%register_tm_clones_code_5);
     ];
     block %block_14 { .asm = "cbz x2, #0xc" } [ goto (%block_16,%block_15); ];
     block %block_13 { .asm = "ldr x2, [x2, #0xfe0]" } [
       var local_10:bv64 := 0x0:bv64;
       var local_10:bv64 := R2:bv64;
       var local_11:bv64 := 0x0:bv64;
       var local_12:bv64 := load le $mem:(bv64->bv8) bvadd(local_10:bv64, 0xfe0:bv64) 64;
       var local_11:bv64 := local_12:bv64;
       var R2:bv64 := zero_extend(0, zero_extend(0, local_11:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x87c:bv64);
       goto (%block_14);
     ];
     block %block_12 { .asm = "adrp x2, #0x1f000" } [
       var R2:bv64 := 0x1f000:bv64;
       (var BranchTaken:bool := false, var PC:bv64 := 0x878:bv64);
       goto (%block_13);
     ];
     block %register_tm_clones_code_1 { .address = 2164;
         .gtirb_block = "lr6o4ptnRiK3TGR1gpiWGg";
         .succ = [ { .address = 2184; .conditional = "true"; .direct = "true";
                 .target = "internal:rlVqjjqoR6uHwOYvPCS15g"; .type = "Type_Branch" };
             { .address = 2176; .conditional = "true"; .direct = "true";
                 .target = "internal:b8tsihT4Q6a/SWPo4w8HoA";
                 .type = "Type_Fallthrough" } ] } [
       assume eq(0x874:bv64, PC:bv64);
       goto (%block_12);
     ];
     block %returns [
       (var PC_out:bv64 := PC:bv64, var R0_out:bv64 := R0:bv64,
        var R1_out:bv64 := R1:bv64, var R16_out:bv64 := R16:bv64,
        var R2_out:bv64 := R2:bv64);
       return;
     ];
     block %ret_3 [ goto (%returns); ];
     block %register_tm_clones_code_7 [ assert false; goto (%ret_3); ];
     block %block_20 { .asm = "ret " } [
       var local_16:bv64 := 0x0:bv64;
       var BTypeNext:bv2 := 0x0:bv2;
       var BranchTaken:bool := true;
       var PC:bv64 := R30:bv64;
       goto (%register_tm_clones_code_7);
     ];
     block %register_tm_clones_code_2 { .address = 2184;
         .gtirb_block = "rlVqjjqoR6uHwOYvPCS15g";
         .succ = [ { .conditional = "false"; .direct = "false";
                 .target = "proxy:lW0ohNgNSB+4yKq2vEm5cg"; .type = "Type_Return" } ] } [
       assume eq(0x888:bv64, PC:bv64);
       goto (%block_20);
     ];
     block %register_tm_clones_code_4 [
       assert boolor(eq(0x888:bv64, PC:bv64), eq(0x874:bv64, PC:bv64));
       goto (%register_tm_clones_code_2,%register_tm_clones_code_1);
     ];
     block %block_11 [
       var PC:bv64 := if eq(R1:bv64, 0x0:bv64) then 0x888:bv64 else 0x874:bv64;
       goto (%register_tm_clones_code_4);
     ];
     block %block_8 { .asm = "cbz x1, #0x18" } [ goto (%block_10,%block_9); ];
     block %block_7 { .asm = "asr x1, x1, #1" } [
       var local_9:bv64 := 0x0:bv64;
       var local_9:bv64 := R1:bv64;
       var R1:bv64 := bvor(bvand(sign_extend(63,
         extract(1,0, extract(1,0, bvlshr(local_9:bv64, zero_extend(52, 0x3f:bv12))))),
         0x8000000000000000:bv64),
        bvand(bvor(bvand(0x0:bv64, 0x0:bv64),
          bvand(bvor(bvlshr(local_9:bv64, zero_extend(52, 0x1:bv12)),
            bvshl(local_9:bv64, zero_extend(48, 0x3f:bv16))),
           0xffffffffffffffff:bv64)), 0x7fffffffffffffff:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x870:bv64);
       goto (%block_8);
     ];
     block %block_6 { .asm = "add x1, x2, x1, asr #3" } [
       var local_7:bv64 := 0x0:bv64;
       var local_7:bv64 := R2:bv64;
       var local_8:bv64 := 0x0:bv64;
       var local_8:bv64 := R1:bv64;
       var R1:bv64 := bvadd(local_7:bv64,
        bvashr(local_8:bv64, zero_extend(52, 0x3:bv12)));
       (var BranchTaken:bool := false, var PC:bv64 := 0x86c:bv64);
       goto (%block_7);
     ];
     block %block_5 { .asm = "lsr x2, x1, #0x3f" } [
       var local_6:bv64 := 0x0:bv64;
       var local_6:bv64 := R1:bv64;
       var R2:bv64 := bvor(bvand(0x0:bv64, 0xfffffffffffffffe:bv64),
        bvand(bvor(bvand(0x0:bv64, 0x0:bv64),
          bvand(bvor(bvlshr(local_6:bv64, zero_extend(52, 0x3f:bv12)),
            bvshl(local_6:bv64, zero_extend(48, 0x1:bv16))), 0xffffffffffffffff:bv64)),
         0x1:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x868:bv64);
       goto (%block_6);
     ];
     block %block_4 { .asm = "sub x1, x1, x0" } [
       var local_4:bv64 := 0x0:bv64;
       var local_4:bv64 := R1:bv64;
       var local_5:bv64 := 0x0:bv64;
       var local_5:bv64 := R0:bv64;
       var R1:bv64 := bvadd(bvadd(local_4:bv64,
         bvnot(bvshl(local_5:bv64, zero_extend(52, 0x0:bv12)))), 0x1:bv64);
       (var BranchTaken:bool := false, var PC:bv64 := 0x864:bv64);
       goto (%block_5);
     ];
     block %block_3 { .asm = "add x1, x1, #0x40" } [
       var local_2:bv64 := 0x0:bv64;
       var local_3:bv64 := 0x0:bv64;
       var local_3:bv64 := R1:bv64;
       var R1:bv64 := bvadd(local_3:bv64, 0x40:bv64);
       (var BranchTaken:bool := false, var PC:bv64 := 0x860:bv64);
       goto (%block_4);
     ];
     block %block_2 { .asm = "adrp x1, #0x20000" } [
       var R1:bv64 := 0x20000:bv64;
       (var BranchTaken:bool := false, var PC:bv64 := 0x85c:bv64);
       goto (%block_3);
     ];
     block %block_1 { .asm = "add x0, x0, #0x40" } [
       var local:bv64 := 0x0:bv64;
       var local_1:bv64 := 0x0:bv64;
       var local_1:bv64 := R0:bv64;
       var R0:bv64 := bvadd(local_1:bv64, 0x40:bv64);
       (var BranchTaken:bool := false, var PC:bv64 := 0x858:bv64);
       goto (%block_2);
     ];
     block %block { .asm = "adrp x0, #0x20000" } [
       var R0:bv64 := 0x20000:bv64;
       (var BranchTaken:bool := false, var PC:bv64 := 0x854:bv64);
       goto (%block_1);
     ];
     block %register_tm_clones_code_3 { .address = 2128;
         .gtirb_block = "32fWxY7+R++JNJOFTmT+Sg";
         .succ = [ { .address = 2184; .conditional = "true"; .direct = "true";
                 .target = "internal:rlVqjjqoR6uHwOYvPCS15g"; .type = "Type_Branch" };
             { .address = 2164; .conditional = "true"; .direct = "true";
                 .target = "internal:lr6o4ptnRiK3TGR1gpiWGg";
                 .type = "Type_Fallthrough" } ] } [
       assume eq(0x850:bv64, PC:bv64);
       goto (%block);
     ];
     block %inputs [
       (var PC:bv64 := PC_in:bv64, var R0:bv64 := R0_in:bv64,
        var R1:bv64 := R1_in:bv64, var R16:bv64 := R16_in:bv64,
        var R2:bv64 := R2_in:bv64, var R30:bv64 := R30_in:bv64);
       goto (%register_tm_clones_code_3);
     ]
  ];
  proc @__do_global_dtors_aux(PC_in:bv64, PSTATE_C_in:bv1, PSTATE_N_in:bv1,
     PSTATE_V_in:bv1, PSTATE_Z_in:bv1, R0_in:bv64, R16_in:bv64, R17_in:bv64,
     R19_in:bv64, R1_in:bv64, R29_in:bv64, R30_in:bv64, SP_in:bv64)
     -> (PC_out:bv64, PSTATE_C_out:bv1, PSTATE_N_out:bv1, PSTATE_V_out:bv1,
     PSTATE_Z_out:bv1, R0_out:bv64, R16_out:bv64, R17_out:bv64, R19_out:bv64,
     R1_out:bv64, R29_out:bv64, R30_out:bv64, SP_out:bv64) {  }
    modifies $mem:(bv64->bv8)
    captures $mem:(bv64->bv8)
    requires boolor(eq(0x88c:bv64, PC_in:bv64))

  [
     block %block_6 [
       assume eq(extract(1,0, extract(1,0, bvlshr(extract(32,0, R0:bv64),
         zero_extend(20, 0x0:bv12)))), 0x1:bv1);
       var BranchTaken:bool := true;
       var PC:bv64 := 0x8c8:bv64;
       goto (%block_8);
     ];
     block %block_7 [
       assume boolnot(eq(extract(1,0, extract(1,0, bvlshr(extract(32,0, R0:bv64),
          zero_extend(20, 0x0:bv12)))), 0x1:bv1));
       (var BranchTaken:bool := false, var PC:bv64 := 0x8a4:bv64);
       goto (%block_8);
     ];
     block %returns [
       (var PC_out:bv64 := PC:bv64, var PSTATE_C_out:bv1 := PSTATE_C:bv1,
        var PSTATE_N_out:bv1 := PSTATE_N:bv1, var PSTATE_V_out:bv1 := PSTATE_V:bv1,
        var PSTATE_Z_out:bv1 := PSTATE_Z:bv1, var R0_out:bv64 := R0:bv64,
        var R1_out:bv64 := R1:bv64, var R16_out:bv64 := R16:bv64,
        var R17_out:bv64 := R17:bv64, var R19_out:bv64 := R19:bv64,
        var R29_out:bv64 := R29:bv64, var R30_out:bv64 := R30:bv64,
        var SP_out:bv64 := SP:bv64);
       return;
     ];
     block %ret_1 [ goto (%returns); ];
     block %__do_global_dtors_aux_code_7 [ assert false; goto (%ret_1); ];
     block %block_11 { .asm = "ret " } [
       var local_12:bv64 := 0x0:bv64;
       var BTypeNext:bv2 := 0x0:bv2;
       var BranchTaken:bool := true;
       var PC:bv64 := R30:bv64;
       goto (%__do_global_dtors_aux_code_7);
     ];
     block %block_10 { .asm = "ldp x29, x30, [sp], #0x20" } [
       var local_7:bv64 := 0x0:bv64;
       var local_7:bv64 := SP:bv64;
       var local_8:bv64 := 0x0:bv64;
       var local_9:bv64 := load le $mem:(bv64->bv8) SP:bv64 64;
       var local_8:bv64 := local_9:bv64;
       var local_10:bv64 := 0x0:bv64;
       var local_11:bv64 := load le $mem:(bv64->bv8) bvadd(SP:bv64, 0x8:bv64) 64;
       var local_10:bv64 := local_11:bv64;
       var R29:bv64 := local_8:bv64;
       var R30:bv64 := local_10:bv64;
       var SP:bv64 := bvadd(local_7:bv64, 0x20:bv64);
       (var BranchTaken:bool := false, var PC:bv64 := 0x8d0:bv64);
       goto (%block_11);
     ];
     block %block_9 { .asm = "ldr x19, [sp, #0x10]" } [
       var local_5:bv64 := 0x0:bv64;
       var local_6:bv64 := load le $mem:(bv64->bv8) bvadd(SP:bv64, 0x10:bv64) 64;
       var local_5:bv64 := local_6:bv64;
       var R19:bv64 := zero_extend(0, zero_extend(0, local_5:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x8cc:bv64);
       goto (%block_10);
     ];
     block %__do_global_dtors_aux_code_1 { .address = 2248;
         .gtirb_block = "LyxvLr79TJCmN7I2k2Z9dA";
         .succ = [ { .conditional = "false"; .direct = "false";
                 .target = "proxy:lW0ohNgNSB+4yKq2vEm5cg"; .type = "Type_Return" } ] } [
       assume eq(0x8c8:bv64, PC:bv64);
       goto (%block_9);
     ];
     block %block_15 [
       assume eq(R0:bv64, 0x0:bv64);
       var BranchTaken:bool := true;
       var PC:bv64 := 0x8bc:bv64;
       goto (%block_17);
     ];
     block %block_16 [
       assume boolnot(eq(R0:bv64, 0x0:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x8b0:bv64);
       goto (%block_17);
     ];
     block %__do_global_dtors_aux_ext_1 [
       assume eq(0x760:bv64, PC:bv64);
       (var PC:bv64=PC_out, var R16:bv64=R16_out, var R17:bv64=R17_out) := call @FUN_760(PC_in=PC:bv64,
          R16_in=R16:bv64, R17_in=R17:bv64);
       assert boolor(eq(0x8bc:bv64, PC:bv64));
       goto (%__do_global_dtors_aux_code_4);
     ];
     block %__do_global_dtors_aux_code_9 [
       assert boolor(eq(0x760:bv64, PC:bv64));
       goto (%__do_global_dtors_aux_ext_1);
     ];
     block %block_20 { .asm = "bl #0xfffffffffffffea8" } [
       var R30:bv64 := 0x8bc:bv64;
       var BranchTaken:bool := true;
       var PC:bv64 := 0x760:bv64;
       goto (%__do_global_dtors_aux_code_9);
     ];
     block %block_19 { .asm = "ldr x0, [x0, #0x38]" } [
       var local_16:bv64 := 0x0:bv64;
       var local_16:bv64 := R0:bv64;
       var local_17:bv64 := 0x0:bv64;
       var local_18:bv64 := load le $mem:(bv64->bv8) bvadd(local_16:bv64, 0x38:bv64) 64;
       var local_17:bv64 := local_18:bv64;
       var R0:bv64 := zero_extend(0, zero_extend(0, local_17:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x8b8:bv64);
       goto (%block_20);
     ];
     block %block_18 { .asm = "adrp x0, #0x20000" } [
       var R0:bv64 := 0x20000:bv64;
       (var BranchTaken:bool := false, var PC:bv64 := 0x8b4:bv64);
       goto (%block_19);
     ];
     block %__do_global_dtors_aux_code_2 { .address = 2224;
         .gtirb_block = "Y/R8k4zNQOW7WdsmX6n3Vw";
         .succ = [ { .address = 1888; .conditional = "false"; .direct = "true";
                 .target = "stmts:rIlbG4jGSTydaFqMhxCKWw"; .type = "Type_Call" } ] } [
       assume eq(0x8b0:bv64, PC:bv64);
       goto (%block_18);
     ];
     block %__do_global_dtors_aux_code_11 [
       assert boolor(eq(0x8c8:bv64, PC:bv64));
       goto (%__do_global_dtors_aux_code_1);
     ];
     block %block_23 { .asm = "strb w0, [x19, #0x40]" } [
       var local_19:bv64 := 0x0:bv64;
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(R19:bv64, 0x40:bv64) extract(8,0, R0:bv64) 8;
       (var BranchTaken:bool := false, var PC:bv64 := 0x8c8:bv64);
       goto (%__do_global_dtors_aux_code_11);
     ];
     block %block_22 { .asm = "mov w0, #1" } [
       var R0:bv64 := 0x1:bv64;
       (var BranchTaken:bool := false, var PC:bv64 := 0x8c4:bv64);
       goto (%block_23);
     ];
     block %__do_global_dtors_aux_code { .address = 2240;
         .gtirb_block = "G0vHB4sSQ3yHYTbHJG37zQ";
         .succ = [ { .address = 2248; .conditional = "false"; .direct = "true";
                 .target = "internal:LyxvLr79TJCmN7I2k2Z9dA";
                 .type = "Type_Fallthrough" } ] } [
       assume eq(0x8c0:bv64, PC:bv64);
       goto (%block_22);
     ];
     block %__do_global_dtors_aux_ext [
       assume eq(0x820:bv64, PC:bv64);
       (var PC:bv64=PC_out, var PSTATE_C:bv1=PSTATE_C_out,
          var PSTATE_N:bv1=PSTATE_N_out, var PSTATE_V:bv1=PSTATE_V_out,
          var PSTATE_Z:bv1=PSTATE_Z_out, var R0:bv64=R0_out, var R16:bv64=R16_out,
          var R1:bv64=R1_out) := call @deregister_tm_clones(PC_in=PC:bv64,
          PSTATE_C_in=PSTATE_C:bv1, PSTATE_N_in=PSTATE_N:bv1,
          PSTATE_V_in=PSTATE_V:bv1, PSTATE_Z_in=PSTATE_Z:bv1, R0_in=R0:bv64,
          R16_in=R16:bv64, R1_in=R1:bv64, R30_in=R30:bv64);
       assert boolor(eq(0x8c0:bv64, PC:bv64));
       goto (%__do_global_dtors_aux_code);
     ];
     block %__do_global_dtors_aux_code_10 [
       assert boolor(eq(0x820:bv64, PC:bv64));
       goto (%__do_global_dtors_aux_ext);
     ];
     block %block_21 { .asm = "bl #0xffffffffffffff64" } [
       var R30:bv64 := 0x8c0:bv64;
       var BranchTaken:bool := true;
       var PC:bv64 := 0x820:bv64;
       goto (%__do_global_dtors_aux_code_10);
     ];
     block %__do_global_dtors_aux_code_4 { .address = 2236;
         .gtirb_block = "lFxxVCVARIKoZ6fzUj5YPw";
         .succ = [ { .address = 2080; .conditional = "false"; .direct = "true";
                 .target = "stmts:OuTzy8qRTci75taVjGinFQ"; .type = "Type_Call" } ] } [
       assume eq(0x8bc:bv64, PC:bv64);
       goto (%block_21);
     ];
     block %__do_global_dtors_aux_code_8 [
       assert boolor(eq(0x8bc:bv64, PC:bv64), eq(0x8b0:bv64, PC:bv64));
       goto (%__do_global_dtors_aux_code_4,%__do_global_dtors_aux_code_2);
     ];
     block %block_17 [
       var PC:bv64 := if eq(R0:bv64, 0x0:bv64) then 0x8bc:bv64 else 0x8b0:bv64;
       goto (%__do_global_dtors_aux_code_8);
     ];
     block %block_14 { .asm = "cbz x0, #0x10" } [ goto (%block_16,%block_15); ];
     block %block_13 { .asm = "ldr x0, [x0, #0xfc8]" } [
       var local_13:bv64 := 0x0:bv64;
       var local_13:bv64 := R0:bv64;
       var local_14:bv64 := 0x0:bv64;
       var local_15:bv64 := load le $mem:(bv64->bv8) bvadd(local_13:bv64, 0xfc8:bv64) 64;
       var local_14:bv64 := local_15:bv64;
       var R0:bv64 := zero_extend(0, zero_extend(0, local_14:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x8ac:bv64);
       goto (%block_14);
     ];
     block %block_12 { .asm = "adrp x0, #0x1f000" } [
       var R0:bv64 := 0x1f000:bv64;
       (var BranchTaken:bool := false, var PC:bv64 := 0x8a8:bv64);
       goto (%block_13);
     ];
     block %__do_global_dtors_aux_code_5 { .address = 2212;
         .gtirb_block = "wK9NYU4TTr+D8gXPiCk+7w";
         .succ = [ { .address = 2236; .conditional = "true"; .direct = "true";
                 .target = "internal:lFxxVCVARIKoZ6fzUj5YPw"; .type = "Type_Branch" };
             { .address = 2224; .conditional = "true"; .direct = "true";
                 .target = "internal:Y/R8k4zNQOW7WdsmX6n3Vw";
                 .type = "Type_Fallthrough" } ] } [
       assume eq(0x8a4:bv64, PC:bv64);
       goto (%block_12);
     ];
     block %__do_global_dtors_aux_code_6 [
       assert boolor(eq(0x8a4:bv64, PC:bv64), eq(0x8c8:bv64, PC:bv64));
       goto (%__do_global_dtors_aux_code_5,%__do_global_dtors_aux_code_1);
     ];
     block %block_8 [
       var PC:bv64 := if eq(extract(1,0, extract(1,0, bvlshr(extract(32,0, R0:bv64),
         zero_extend(20, 0x0:bv12)))), 0x1:bv1) then 0x8c8:bv64 else 0x8a4:bv64;
       goto (%__do_global_dtors_aux_code_6);
     ];
     block %block_5 { .asm = "tbnz w0, #0, #0x28" } [ goto (%block_7,%block_6); ];
     block %block_4 { .asm = "ldrb w0, [x19, #0x40]" } [
       var local_2:bv64 := 0x0:bv64;
       var local_2:bv64 := R19:bv64;
       var local_3:bv8 := 0x0:bv8;
       var local_4:bv8 := load le $mem:(bv64->bv8) bvadd(local_2:bv64, 0x40:bv64) 8;
       var local_3:bv8 := local_4:bv8;
       var R0:bv64 := zero_extend(32, zero_extend(24, local_3:bv8));
       (var BranchTaken:bool := false, var PC:bv64 := 0x8a0:bv64);
       goto (%block_5);
     ];
     block %block_3 { .asm = "adrp x19, #0x20000" } [
       var R19:bv64 := 0x20000:bv64;
       (var BranchTaken:bool := false, var PC:bv64 := 0x89c:bv64);
       goto (%block_4);
     ];
     block %block_2 { .asm = "str x19, [sp, #0x10]" } [
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(SP:bv64, 0x10:bv64) R19:bv64 64;
       (var BranchTaken:bool := false, var PC:bv64 := 0x898:bv64);
       goto (%block_3);
     ];
     block %block_1 { .asm = "mov x29, sp" } [
       var local_1:bv64 := 0x0:bv64;
       var R29:bv64 := bvadd(SP:bv64, 0x0:bv64);
       (var BranchTaken:bool := false, var PC:bv64 := 0x894:bv64);
       goto (%block_2);
     ];
     block %block { .asm = "stp x29, x30, [sp, #-0x20]!" } [
       var local:bv64 := 0x0:bv64;
       var local:bv64 := SP:bv64;
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(SP:bv64,
        0xffffffffffffffe0:bv64) R29:bv64 64;
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(bvadd(SP:bv64,
         0xffffffffffffffe0:bv64), 0x8:bv64) R30:bv64 64;
       var SP:bv64 := bvadd(local:bv64, 0xffffffffffffffe0:bv64);
       (var BranchTaken:bool := false, var PC:bv64 := 0x890:bv64);
       goto (%block_1);
     ];
     block %__do_global_dtors_aux_code_3 { .address = 2188;
         .gtirb_block = "gFBdrsFTRkSCdIsDFMk6qA";
         .succ = [ { .address = 2212; .conditional = "true"; .direct = "true";
                 .target = "internal:wK9NYU4TTr+D8gXPiCk+7w";
                 .type = "Type_Fallthrough" };
             { .address = 2248; .conditional = "true"; .direct = "true";
                 .target = "internal:LyxvLr79TJCmN7I2k2Z9dA"; .type = "Type_Branch" } ] } [
       assume eq(0x88c:bv64, PC:bv64);
       goto (%block);
     ];
     block %inputs [
       (var PC:bv64 := PC_in:bv64, var PSTATE_C:bv1 := PSTATE_C_in:bv1,
        var PSTATE_N:bv1 := PSTATE_N_in:bv1, var PSTATE_V:bv1 := PSTATE_V_in:bv1,
        var PSTATE_Z:bv1 := PSTATE_Z_in:bv1, var R0:bv64 := R0_in:bv64,
        var R1:bv64 := R1_in:bv64, var R16:bv64 := R16_in:bv64,
        var R17:bv64 := R17_in:bv64, var R19:bv64 := R19_in:bv64,
        var R29:bv64 := R29_in:bv64, var R30:bv64 := R30_in:bv64,
        var SP:bv64 := SP_in:bv64);
       goto (%__do_global_dtors_aux_code_3);
     ]
  ];
  proc @frame_dummy(PC_in:bv64, R0_in:bv64, R16_in:bv64, R1_in:bv64, R2_in:bv64,
     R30_in:bv64)
     -> (PC_out:bv64, R0_out:bv64, R16_out:bv64, R1_out:bv64, R2_out:bv64) {  }
    captures $mem:(bv64->bv8)
    requires boolor(eq(0x8e0:bv64, PC_in:bv64))

  [
     block %frame_dummy_ext [
       assume eq(0x850:bv64, PC:bv64);
       (var PC:bv64=PC_out, var R0:bv64=R0_out, var R16:bv64=R16_out,
          var R1:bv64=R1_out, var R2:bv64=R2_out) := call @register_tm_clones(PC_in=PC:bv64,
          R0_in=R0:bv64, R16_in=R16:bv64, R1_in=R1:bv64, R2_in=R2:bv64,
          R30_in=R30:bv64);
       assert false;
       unreachable;
     ];
     block %frame_dummy_code_1 [
       assert boolor(eq(0x850:bv64, PC:bv64));
       goto (%frame_dummy_ext);
     ];
     block %block { .asm = "b #0xffffffffffffff70" } [
       var BranchTaken:bool := true;
       var PC:bv64 := 0x850:bv64;
       goto (%frame_dummy_code_1);
     ];
     block %frame_dummy_code { .address = 2272;
         .gtirb_block = "X7GJYS43TTaiN95nNBoPIg";
         .succ = [ { .address = 2128; .conditional = "false"; .direct = "true";
                 .target = "stmts:32fWxY7+R++JNJOFTmT+Sg"; .type = "Type_Branch" } ] } [
       assume eq(0x8e0:bv64, PC:bv64);
       goto (%block);
     ];
     block %inputs [
       (var PC:bv64 := PC_in:bv64, var R0:bv64 := R0_in:bv64,
        var R1:bv64 := R1_in:bv64, var R16:bv64 := R16_in:bv64,
        var R2:bv64 := R2_in:bv64, var R30:bv64 := R30_in:bv64);
       goto (%frame_dummy_code);
     ];
     block %returns [
       (var PC_out:bv64 := PC:bv64, var R0_out:bv64 := R0:bv64,
        var R1_out:bv64 := R1:bv64, var R16_out:bv64 := R16:bv64,
        var R2_out:bv64 := R2:bv64);
       return;
     ]
  ];
  proc @FUN_7a0(PC_in:bv64, R16_in:bv64, R17_in:bv64)
     -> (PC_out:bv64, R16_out:bv64, R17_out:bv64) {  }
    captures $mem:(bv64->bv8)
    requires boolor(eq(0x7a0:bv64, PC_in:bv64))

  [
     block %FUN_7a0_code_1 [ assert false; unreachable; ];
     block %block_3 { .asm = "br x17" } [
       var local_5:bv64 := 0x0:bv64;
       var BTypeNext:bv2 := 0x1:bv2;
       var BranchTaken:bool := true;
       var PC:bv64 := R17:bv64;
       goto (%FUN_7a0_code_1);
     ];
     block %block_2 { .asm = "add x16, x16, #0x28" } [
       var local_3:bv64 := 0x0:bv64;
       var local_4:bv64 := 0x0:bv64;
       var local_4:bv64 := R16:bv64;
       var R16:bv64 := bvadd(local_4:bv64, 0x28:bv64);
       (var BranchTaken:bool := false, var PC:bv64 := 0x7ac:bv64);
       goto (%block_3);
     ];
     block %block_1 { .asm = "ldr x17, [x16, #0x28]" } [
       var local:bv64 := 0x0:bv64;
       var local:bv64 := R16:bv64;
       var local_1:bv64 := 0x0:bv64;
       var local_2:bv64 := load le $mem:(bv64->bv8) bvadd(local:bv64, 0x28:bv64) 64;
       var local_1:bv64 := local_2:bv64;
       var R17:bv64 := zero_extend(0, zero_extend(0, local_1:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x7a8:bv64);
       goto (%block_2);
     ];
     block %block { .asm = "adrp x16, #0x20000" } [
       var R16:bv64 := 0x20000:bv64;
       (var BranchTaken:bool := false, var PC:bv64 := 0x7a4:bv64);
       goto (%block_1);
     ];
     block %FUN_7a0_code { .address = 1952; .gtirb_block = "D9t2gNJrSmyMH3GAVRe3IQ";
         .succ = [ { .conditional = "false"; .direct = "false";
                 .target = "proxy:Ix0zptxZTQy3V+ryLWplvQ"; .type = "Type_Branch" } ] } [
       assume eq(0x7a0:bv64, PC:bv64);
       goto (%block);
     ];
     block %inputs [
       (var PC:bv64 := PC_in:bv64, var R16:bv64 := R16_in:bv64,
        var R17:bv64 := R17_in:bv64);
       goto (%FUN_7a0_code);
     ];
     block %returns [
       (var PC_out:bv64 := PC:bv64, var R16_out:bv64 := R16:bv64,
        var R17_out:bv64 := R17:bv64);
       return;
     ]
  ];
  proc @FUN_730(PC_in:bv64, R16_in:bv64, R17_in:bv64, R30_in:bv64, SP_in:bv64)
     -> (PC_out:bv64, R16_out:bv64, R17_out:bv64, SP_out:bv64) {  }
    modifies $mem:(bv64->bv8)
    captures $mem:(bv64->bv8)
    requires boolor(eq(0x730:bv64, PC_in:bv64))

  [
     block %FUN_730_code_1 [ assert false; unreachable; ];
     block %block_4 { .asm = "br x17" } [
       var local_6:bv64 := 0x0:bv64;
       var BTypeNext:bv2 := 0x1:bv2;
       var BranchTaken:bool := true;
       var PC:bv64 := R17:bv64;
       goto (%FUN_730_code_1);
     ];
     block %block_3 { .asm = "add x16, x16, #0xff8" } [
       var local_4:bv64 := 0x0:bv64;
       var local_5:bv64 := 0x0:bv64;
       var local_5:bv64 := R16:bv64;
       var R16:bv64 := bvadd(local_5:bv64, 0xff8:bv64);
       (var BranchTaken:bool := false, var PC:bv64 := 0x740:bv64);
       goto (%block_4);
     ];
     block %block_2 { .asm = "ldr x17, [x16, #0xff8]" } [
       var local_1:bv64 := 0x0:bv64;
       var local_1:bv64 := R16:bv64;
       var local_2:bv64 := 0x0:bv64;
       var local_3:bv64 := load le $mem:(bv64->bv8) bvadd(local_1:bv64, 0xff8:bv64) 64;
       var local_2:bv64 := local_3:bv64;
       var R17:bv64 := zero_extend(0, zero_extend(0, local_2:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x73c:bv64);
       goto (%block_3);
     ];
     block %block_1 { .asm = "adrp x16, #0x1f000" } [
       var R16:bv64 := 0x1f000:bv64;
       (var BranchTaken:bool := false, var PC:bv64 := 0x738:bv64);
       goto (%block_2);
     ];
     block %block { .asm = "stp x16, x30, [sp, #-0x10]!" } [
       var local:bv64 := 0x0:bv64;
       var local:bv64 := SP:bv64;
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(SP:bv64,
        0xfffffffffffffff0:bv64) R16:bv64 64;
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(bvadd(SP:bv64,
         0xfffffffffffffff0:bv64), 0x8:bv64) R30:bv64 64;
       var SP:bv64 := bvadd(local:bv64, 0xfffffffffffffff0:bv64);
       (var BranchTaken:bool := false, var PC:bv64 := 0x734:bv64);
       goto (%block_1);
     ];
     block %FUN_730_code { .address = 1840; .gtirb_block = "NfWWPq4PTwyv0VapVhBGag";
         .succ = [ { .conditional = "false"; .direct = "false";
                 .target = "proxy:lW0ohNgNSB+4yKq2vEm5cg"; .type = "Type_Branch" } ] } [
       assume eq(0x730:bv64, PC:bv64);
       goto (%block);
     ];
     block %inputs [
       (var PC:bv64 := PC_in:bv64, var R16:bv64 := R16_in:bv64,
        var R17:bv64 := R17_in:bv64, var R30:bv64 := R30_in:bv64,
        var SP:bv64 := SP_in:bv64);
       goto (%FUN_730_code);
     ];
     block %returns [
       (var PC_out:bv64 := PC:bv64, var R16_out:bv64 := R16:bv64,
        var R17_out:bv64 := R17:bv64, var SP_out:bv64 := SP:bv64);
       return;
     ]
  ];
  proc @call_weak_fn(PC_in:bv64, R0_in:bv64, R16_in:bv64, R17_in:bv64, R30_in:bv64)
     -> (PC_out:bv64, R0_out:bv64, R16_out:bv64, R17_out:bv64) {  }
    captures $mem:(bv64->bv8)
    requires boolor(eq(0x7f4:bv64, PC_in:bv64))

  [
     block %block_3 [
       assume eq(R0:bv64, 0x0:bv64);
       var BranchTaken:bool := true;
       var PC:bv64 := 0x804:bv64;
       goto (%block_5);
     ];
     block %block_4 [
       assume boolnot(eq(R0:bv64, 0x0:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x800:bv64);
       goto (%block_5);
     ];
     block %call_weak_fn_ext_1 [
       assume eq(0x780:bv64, PC:bv64);
       (var PC:bv64=PC_out, var R16:bv64=R16_out, var R17:bv64=R17_out) := call @.L_780(PC_in=PC:bv64,
          R16_in=R16:bv64, R17_in=R17:bv64);
       assert false;
       unreachable;
     ];
     block %call_weak_fn_code_4 [
       assert boolor(eq(0x780:bv64, PC:bv64));
       goto (%call_weak_fn_ext_1);
     ];
     block %block_6 { .asm = "b #0xffffffffffffff80" } [
       var BranchTaken:bool := true;
       var PC:bv64 := 0x780:bv64;
       goto (%call_weak_fn_code_4);
     ];
     block %call_weak_fn_code_1 { .address = 2048;
         .gtirb_block = "mmpaLvZYQk2b8selWCLriA";
         .succ = [ { .address = 1920; .conditional = "false"; .direct = "true";
                 .target = "stmts:oqiqdATZTc6MDOYJqL9Aew"; .type = "Type_Branch" } ] } [
       assume eq(0x800:bv64, PC:bv64);
       goto (%block_6);
     ];
     block %returns [
       (var PC_out:bv64 := PC:bv64, var R0_out:bv64 := R0:bv64,
        var R16_out:bv64 := R16:bv64, var R17_out:bv64 := R17:bv64);
       return;
     ];
     block %ret_3 [ goto (%returns); ];
     block %call_weak_fn_code_5 [
       assert boolor(eq(0x720:bv64, PC:bv64));
       goto (%ret_3);
     ];
     block %block_7 { .asm = "ret " } [
       var local_3:bv64 := 0x0:bv64;
       var BTypeNext:bv2 := 0x0:bv2;
       var BranchTaken:bool := true;
       var PC:bv64 := R30:bv64;
       goto (%call_weak_fn_code_5);
     ];
     block %call_weak_fn_code_2 { .address = 2052;
         .gtirb_block = "6JJvkaLhTaWXaEL0+yxKxg";
         .succ = [ { .address = 1824; .conditional = "false"; .direct = "true";
                 .target = "external:GghTYm6bT12tNFmqu0nIjA"; .type = "Type_Return" } ] } [
       assume eq(0x804:bv64, PC:bv64);
       goto (%block_7);
     ];
     block %call_weak_fn_code_3 [
       assert boolor(eq(0x804:bv64, PC:bv64), eq(0x800:bv64, PC:bv64));
       goto (%call_weak_fn_code_2,%call_weak_fn_code_1);
     ];
     block %block_5 [
       var PC:bv64 := if eq(R0:bv64, 0x0:bv64) then 0x804:bv64 else 0x800:bv64;
       goto (%call_weak_fn_code_3);
     ];
     block %block_2 { .asm = "cbz x0, #8" } [ goto (%block_4,%block_3); ];
     block %block_1 { .asm = "ldr x0, [x0, #0xfd0]" } [
       var local:bv64 := 0x0:bv64;
       var local:bv64 := R0:bv64;
       var local_1:bv64 := 0x0:bv64;
       var local_2:bv64 := load le $mem:(bv64->bv8) bvadd(local:bv64, 0xfd0:bv64) 64;
       var local_1:bv64 := local_2:bv64;
       var R0:bv64 := zero_extend(0, zero_extend(0, local_1:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x7fc:bv64);
       goto (%block_2);
     ];
     block %block { .asm = "adrp x0, #0x1f000" } [
       var R0:bv64 := 0x1f000:bv64;
       (var BranchTaken:bool := false, var PC:bv64 := 0x7f8:bv64);
       goto (%block_1);
     ];
     block %call_weak_fn_code { .address = 2036;
         .gtirb_block = "SFN4dpBgSO2bPUu0fyDluw";
         .succ = [ { .address = 2052; .conditional = "true"; .direct = "true";
                 .target = "internal:6JJvkaLhTaWXaEL0+yxKxg"; .type = "Type_Branch" };
             { .address = 2048; .conditional = "true"; .direct = "true";
                 .target = "internal:mmpaLvZYQk2b8selWCLriA";
                 .type = "Type_Fallthrough" } ] } [
       assume eq(0x7f4:bv64, PC:bv64);
       goto (%block);
     ];
     block %inputs [
       (var PC:bv64 := PC_in:bv64, var R0:bv64 := R0_in:bv64,
        var R16:bv64 := R16_in:bv64, var R17:bv64 := R17_in:bv64,
        var R30:bv64 := R30_in:bv64);
       goto (%call_weak_fn_code);
     ]
  ];
  proc @_init(PC_in:bv64, R0_in:bv64, R16_in:bv64, R17_in:bv64, R29_in:bv64,
     R30_in:bv64, SP_in:bv64)
     -> (PC_out:bv64, R0_out:bv64, R16_out:bv64, R17_out:bv64, R29_out:bv64,
     R30_out:bv64, SP_out:bv64) {  }
    modifies $mem:(bv64->bv8)
    captures $mem:(bv64->bv8)
    requires boolor(eq(0x710:bv64, PC_in:bv64))

  [
     block %returns [
       (var PC_out:bv64 := PC:bv64, var R0_out:bv64 := R0:bv64,
        var R16_out:bv64 := R16:bv64, var R17_out:bv64 := R17:bv64,
        var R29_out:bv64 := R29:bv64, var R30_out:bv64 := R30:bv64,
        var SP_out:bv64 := SP:bv64);
       return;
     ];
     block %ret_1 [ goto (%returns); ];
     block %_init_code_4 [ assert false; goto (%ret_1); ];
     block %block_4 { .asm = "ret " } [
       var local_7:bv64 := 0x0:bv64;
       var BTypeNext:bv2 := 0x0:bv2;
       var BranchTaken:bool := true;
       var PC:bv64 := R30:bv64;
       goto (%_init_code_4);
     ];
     block %_init_code_3 [
       call @_aarch64_eval(0xd50323bf:bv32, 0x724:bv64) { .asm = "autiasp ";
           .error = "Failure(\"unsupported\")" };
       goto (%block_4);
     ];
     block %block_3 { .asm = "ldp x29, x30, [sp], #0x10" } [
       var local_2:bv64 := 0x0:bv64;
       var local_2:bv64 := SP:bv64;
       var local_3:bv64 := 0x0:bv64;
       var local_4:bv64 := load le $mem:(bv64->bv8) SP:bv64 64;
       var local_3:bv64 := local_4:bv64;
       var local_5:bv64 := 0x0:bv64;
       var local_6:bv64 := load le $mem:(bv64->bv8) bvadd(SP:bv64, 0x8:bv64) 64;
       var local_5:bv64 := local_6:bv64;
       var R29:bv64 := local_3:bv64;
       var R30:bv64 := local_5:bv64;
       var SP:bv64 := bvadd(local_2:bv64, 0x10:bv64);
       (var BranchTaken:bool := false, var PC:bv64 := 0x724:bv64);
       goto (%_init_code_3);
     ];
     block %_init_code_1 { .address = 1824; .gtirb_block = "GghTYm6bT12tNFmqu0nIjA";
         .succ = [ { .conditional = "false"; .direct = "false";
                 .target = "proxy:lW0ohNgNSB+4yKq2vEm5cg"; .type = "Type_Return" } ] } [
       assume eq(0x720:bv64, PC:bv64);
       goto (%block_3);
     ];
     block %_init_ext [
       assume eq(0x7f4:bv64, PC:bv64);
       (var PC:bv64=PC_out, var R0:bv64=R0_out, var R16:bv64=R16_out,
          var R17:bv64=R17_out) := call @call_weak_fn(PC_in=PC:bv64, R0_in=R0:bv64,
          R16_in=R16:bv64, R17_in=R17:bv64, R30_in=R30:bv64);
       assert boolor(eq(0x720:bv64, PC:bv64));
       goto (%_init_code_1);
     ];
     block %_init_code_2 [
       assert boolor(eq(0x7f4:bv64, PC:bv64));
       goto (%_init_ext);
     ];
     block %block_2 { .asm = "bl #0xd8" } [
       var R30:bv64 := 0x720:bv64;
       var BranchTaken:bool := true;
       var PC:bv64 := 0x7f4:bv64;
       goto (%_init_code_2);
     ];
     block %block_1 { .asm = "mov x29, sp" } [
       var local_1:bv64 := 0x0:bv64;
       var R29:bv64 := bvadd(SP:bv64, 0x0:bv64);
       (var BranchTaken:bool := false, var PC:bv64 := 0x71c:bv64);
       goto (%block_2);
     ];
     block %block { .asm = "stp x29, x30, [sp, #-0x10]!" } [
       var local:bv64 := 0x0:bv64;
       var local:bv64 := SP:bv64;
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(SP:bv64,
        0xfffffffffffffff0:bv64) R29:bv64 64;
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(bvadd(SP:bv64,
         0xfffffffffffffff0:bv64), 0x8:bv64) R30:bv64 64;
       var SP:bv64 := bvadd(local:bv64, 0xfffffffffffffff0:bv64);
       (var BranchTaken:bool := false, var PC:bv64 := 0x718:bv64);
       goto (%block_1);
     ];
     block %_init_code { .address = 1808; .gtirb_block = "GW0MHC+ORUKlCdpgOcZ6zA";
         .succ = [ { .address = 2036; .conditional = "false"; .direct = "true";
                 .target = "stmts:SFN4dpBgSO2bPUu0fyDluw"; .type = "Type_Call" } ] } [
       assume eq(0x710:bv64, PC:bv64);
       call @_aarch64_eval(0xd503233f:bv32, 0x710:bv64) { .asm = "paciasp ";
           .error = "Failure(\"unsupported\")" };
       goto (%block);
     ];
     block %inputs [
       (var PC:bv64 := PC_in:bv64, var R0:bv64 := R0_in:bv64,
        var R16:bv64 := R16_in:bv64, var R17:bv64 := R17_in:bv64,
        var R29:bv64 := R29_in:bv64, var R30:bv64 := R30_in:bv64,
        var SP:bv64 := SP_in:bv64);
       goto (%_init_code);
     ]
  ];
  proc @main(PC_in:bv64, R0_in:bv64, R29_in:bv64, R30_in:bv64, SP_in:bv64)
     -> (PC_out:bv64, R0_out:bv64, R29_out:bv64, R30_out:bv64, SP_out:bv64) {  }
    modifies $mem:(bv64->bv8)
    captures $mem:(bv64->bv8)
    requires boolor(eq(0xa70:bv64, PC_in:bv64))

  [
     block %returns [
       (var PC_out:bv64 := PC:bv64, var R0_out:bv64 := R0:bv64,
        var R29_out:bv64 := R29:bv64, var R30_out:bv64 := R30:bv64,
        var SP_out:bv64 := SP:bv64);
       return;
     ];
     block %ret [ goto (%returns); ];
     block %main_code_1 [ assert false; goto (%ret); ];
     block %block_4 { .asm = "ret " } [
       var local_7:bv64 := 0x0:bv64;
       var BTypeNext:bv2 := 0x0:bv2;
       var BranchTaken:bool := true;
       var PC:bv64 := R30:bv64;
       goto (%main_code_1);
     ];
     block %block_3 { .asm = "ldp x29, x30, [sp], #0x10" } [
       var local_2:bv64 := 0x0:bv64;
       var local_2:bv64 := SP:bv64;
       var local_3:bv64 := 0x0:bv64;
       var local_4:bv64 := load le $mem:(bv64->bv8) SP:bv64 64;
       var local_3:bv64 := local_4:bv64;
       var local_5:bv64 := 0x0:bv64;
       var local_6:bv64 := load le $mem:(bv64->bv8) bvadd(SP:bv64, 0x8:bv64) 64;
       var local_5:bv64 := local_6:bv64;
       var R29:bv64 := local_3:bv64;
       var R30:bv64 := local_5:bv64;
       var SP:bv64 := bvadd(local_2:bv64, 0x10:bv64);
       (var BranchTaken:bool := false, var PC:bv64 := 0xa80:bv64);
       goto (%block_4);
     ];
     block %block_2 { .asm = "mov w0, #0" } [
       var R0:bv64 := 0x0:bv64;
       (var BranchTaken:bool := false, var PC:bv64 := 0xa7c:bv64);
       goto (%block_3);
     ];
     block %block_1 { .asm = "mov x29, sp" } [
       var local_1:bv64 := 0x0:bv64;
       var R29:bv64 := bvadd(SP:bv64, 0x0:bv64);
       (var BranchTaken:bool := false, var PC:bv64 := 0xa78:bv64);
       goto (%block_2);
     ];
     block %block { .asm = "stp x29, x30, [sp, #-0x10]!" } [
       var local:bv64 := 0x0:bv64;
       var local:bv64 := SP:bv64;
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(SP:bv64,
        0xfffffffffffffff0:bv64) R29:bv64 64;
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(bvadd(SP:bv64,
         0xfffffffffffffff0:bv64), 0x8:bv64) R30:bv64 64;
       var SP:bv64 := bvadd(local:bv64, 0xfffffffffffffff0:bv64);
       (var BranchTaken:bool := false, var PC:bv64 := 0xa74:bv64);
       goto (%block_1);
     ];
     block %main_code { .address = 2672; .gtirb_block = "NnUwG2aZR7u/s4UzGfPLYA";
         .succ = [ { .conditional = "false"; .direct = "false";
                 .target = "proxy:lW0ohNgNSB+4yKq2vEm5cg"; .type = "Type_Return" } ] } [
       assume eq(0xa70:bv64, PC:bv64);
       goto (%block);
     ];
     block %inputs [
       (var PC:bv64 := PC_in:bv64, var R0:bv64 := R0_in:bv64,
        var R29:bv64 := R29_in:bv64, var R30:bv64 := R30_in:bv64,
        var SP:bv64 := SP_in:bv64);
       goto (%main_code);
     ]
  ];
  proc @splitclone(PC_in:bv64, PSTATE_C_in:bv1, PSTATE_N_in:bv1, PSTATE_V_in:bv1,
     PSTATE_Z_in:bv1, R0_in:bv64, R16_in:bv64, R17_in:bv64, R1_in:bv64, R29_in:bv64,
     R2_in:bv64, R30_in:bv64, R3_in:bv64, SP_in:bv64)
     -> (PC_out:bv64, PSTATE_C_out:bv1, PSTATE_N_out:bv1, PSTATE_V_out:bv1,
     PSTATE_Z_out:bv1, R0_out:bv64, R16_out:bv64, R17_out:bv64, R1_out:bv64,
     R29_out:bv64, R2_out:bv64, R30_out:bv64, R3_out:bv64, SP_out:bv64) {  }
    modifies $mem:(bv64->bv8)
    captures $mem:(bv64->bv8)
    requires boolor(eq(0x914:bv64, PC_in:bv64))

  [
     block %block_8 [
       assume boolnot(eq(PSTATE_Z:bv1, 0x1:bv1));
       var BranchTaken:bool := true;
       var PC:bv64 := 0x950:bv64;
       goto (%block_10);
     ];
     block %block_9 [
       assume boolnot(boolnot(eq(PSTATE_Z:bv1, 0x1:bv1)));
       (var BranchTaken:bool := false, var PC:bv64 := 0x934:bv64);
       goto (%block_10);
     ];
     block %splitclone_code_10 [
       assert boolor(eq(0x9dc:bv64, PC:bv64));
       goto (%splitclone_code_4);
     ];
     block %block_17 { .asm = "b #0x90" } [
       var BranchTaken:bool := true;
       var PC:bv64 := 0x9dc:bv64;
       goto (%splitclone_code_10);
     ];
     block %block_16 { .asm = "str x1, [x0]" } [
       var local_16:bv64 := 0x0:bv64;
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(R0:bv64, 0x0:bv64) R1:bv64 64;
       (var BranchTaken:bool := false, var PC:bv64 := 0x94c:bv64);
       goto (%block_17);
     ];
     block %block_15 { .asm = "ldr x0, [sp, #0x20]" } [
       var local_14:bv64 := 0x0:bv64;
       var local_15:bv64 := load le $mem:(bv64->bv8) bvadd(SP:bv64, 0x20:bv64) 64;
       var local_14:bv64 := local_15:bv64;
       var R0:bv64 := zero_extend(0, zero_extend(0, local_14:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x948:bv64);
       goto (%block_16);
     ];
     block %block_14 { .asm = "ldr x1, [x0]" } [
       var local_11:bv64 := 0x0:bv64;
       var local_11:bv64 := R0:bv64;
       var local_12:bv64 := 0x0:bv64;
       var local_13:bv64 := load le $mem:(bv64->bv8) bvadd(local_11:bv64, 0x0:bv64) 64;
       var local_12:bv64 := local_13:bv64;
       var R1:bv64 := zero_extend(0, zero_extend(0, local_12:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x944:bv64);
       goto (%block_15);
     ];
     block %block_13 { .asm = "ldr x0, [sp, #0x18]" } [
       var local_9:bv64 := 0x0:bv64;
       var local_10:bv64 := load le $mem:(bv64->bv8) bvadd(SP:bv64, 0x18:bv64) 64;
       var local_9:bv64 := local_10:bv64;
       var R0:bv64 := zero_extend(0, zero_extend(0, local_9:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x940:bv64);
       goto (%block_14);
     ];
     block %block_12 { .asm = "str xzr, [x0]" } [
       var local_8:bv64 := 0x0:bv64;
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(R0:bv64, 0x0:bv64) 0x0:bv64 64;
       (var BranchTaken:bool := false, var PC:bv64 := 0x93c:bv64);
       goto (%block_13);
     ];
     block %block_11 { .asm = "ldr x0, [sp, #0x18]" } [
       var local_6:bv64 := 0x0:bv64;
       var local_7:bv64 := load le $mem:(bv64->bv8) bvadd(SP:bv64, 0x18:bv64) 64;
       var local_6:bv64 := local_7:bv64;
       var R0:bv64 := zero_extend(0, zero_extend(0, local_6:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x938:bv64);
       goto (%block_12);
     ];
     block %splitclone_code { .address = 2356;
         .gtirb_block = "H7LPJaZbQvWx+VL+kBk//Q";
         .succ = [ { .address = 2524; .conditional = "false"; .direct = "true";
                 .target = "internal:WTjM+CpMSlaCQoaCOxiagA"; .type = "Type_Branch" } ] } [
       assume eq(0x934:bv64, PC:bv64);
       goto (%block_11);
     ];
     block %splitclone_code_11 [
       assert boolor(eq(0x9dc:bv64, PC:bv64));
       goto (%splitclone_code_4);
     ];
     block %block_18 { .asm = "b #0x3c" } [
       var BranchTaken:bool := true;
       var PC:bv64 := 0x9dc:bv64;
       goto (%splitclone_code_11);
     ];
     block %splitclone_code_2 { .address = 2464;
         .gtirb_block = "QIZPtsaTQjiAsr+paN6ljw";
         .succ = [ { .address = 2524; .conditional = "false"; .direct = "true";
                 .target = "internal:WTjM+CpMSlaCQoaCOxiagA"; .type = "Type_Branch" } ] } [
       assume eq(0x9a0:bv64, PC:bv64);
       goto (%block_18);
     ];
     block %ret_7 [ goto (%returns); ];
     block %ret_8 [ goto (%returns); ];
     block %ret_9 [ goto (%returns); ];
     block %returns [
       (var PC_out:bv64 := PC:bv64, var PSTATE_C_out:bv1 := PSTATE_C:bv1,
        var PSTATE_N_out:bv1 := PSTATE_N:bv1, var PSTATE_V_out:bv1 := PSTATE_V:bv1,
        var PSTATE_Z_out:bv1 := PSTATE_Z:bv1, var R0_out:bv64 := R0:bv64,
        var R1_out:bv64 := R1:bv64, var R16_out:bv64 := R16:bv64,
        var R17_out:bv64 := R17:bv64, var R2_out:bv64 := R2:bv64,
        var R29_out:bv64 := R29:bv64, var R3_out:bv64 := R3:bv64,
        var R30_out:bv64 := R30:bv64, var SP_out:bv64 := SP:bv64);
       return;
     ];
     block %splitclone_code_12 [
       assert boolor(eq(0xa08:bv64, PC:bv64), eq(0x9dc:bv64, PC:bv64),
        eq(0x9a0:bv64, PC:bv64));
       goto (%ret_9,%ret_8,%ret_7);
     ];
     block %block_20 { .asm = "ret " } [
       var local_22:bv64 := 0x0:bv64;
       var BTypeNext:bv2 := 0x0:bv2;
       var BranchTaken:bool := true;
       var PC:bv64 := R30:bv64;
       goto (%splitclone_code_12);
     ];
     block %block_19 { .asm = "ldp x29, x30, [sp], #0x30" } [
       var local_17:bv64 := 0x0:bv64;
       var local_17:bv64 := SP:bv64;
       var local_18:bv64 := 0x0:bv64;
       var local_19:bv64 := load le $mem:(bv64->bv8) SP:bv64 64;
       var local_18:bv64 := local_19:bv64;
       var local_20:bv64 := 0x0:bv64;
       var local_21:bv64 := load le $mem:(bv64->bv8) bvadd(SP:bv64, 0x8:bv64) 64;
       var local_20:bv64 := local_21:bv64;
       var R29:bv64 := local_18:bv64;
       var R30:bv64 := local_20:bv64;
       var SP:bv64 := bvadd(local_17:bv64, 0x30:bv64);
       (var BranchTaken:bool := false, var PC:bv64 := 0x9e0:bv64);
       goto (%block_20);
     ];
     block %splitclone_code_4 { .address = 2524;
         .gtirb_block = "WTjM+CpMSlaCQoaCOxiagA";
         .succ = [ { .address = 2568; .conditional = "false"; .direct = "true";
                 .target = "external:Nc5WfkQBRwahCMMkX4LB9A"; .type = "Type_Return" };
             { .address = 2524; .conditional = "false"; .direct = "true";
                 .target = "internal:WTjM+CpMSlaCQoaCOxiagA"; .type = "Type_Return" };
             { .address = 2464; .conditional = "false"; .direct = "true";
                 .target = "internal:QIZPtsaTQjiAsr+paN6ljw"; .type = "Type_Return" } ] } [
       assume eq(0x9dc:bv64, PC:bv64);
       goto (%block_19);
     ];
     block %block_27 [
       assume eq(PSTATE_Z:bv1, 0x1:bv1);
       var BranchTaken:bool := true;
       var PC:bv64 := 0x9a4:bv64;
       goto (%block_29);
     ];
     block %block_28 [
       assume boolnot(eq(PSTATE_Z:bv1, 0x1:bv1));
       (var BranchTaken:bool := false, var PC:bv64 := 0x968:bv64);
       goto (%block_29);
     ];
     block %splitclone_code_14 [
       assert boolor(eq(0x8e4:bv64, PC:bv64));
       goto (%splitclone_ext_1);
     ];
     block %block_32 { .asm = "bl #0xffffffffffffff74" } [
       var R30:bv64 := 0x974:bv64;
       var BranchTaken:bool := true;
       var PC:bv64 := 0x8e4:bv64;
       goto (%splitclone_code_14);
     ];
     block %block_31 { .asm = "ldr x0, [x0, #8]" } [
       var local_36:bv64 := 0x0:bv64;
       var local_36:bv64 := R0:bv64;
       var local_37:bv64 := 0x0:bv64;
       var local_38:bv64 := load le $mem:(bv64->bv8) bvadd(local_36:bv64, 0x8:bv64) 64;
       var local_37:bv64 := local_38:bv64;
       var R0:bv64 := zero_extend(0, zero_extend(0, local_37:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x970:bv64);
       goto (%block_32);
     ];
     block %block_30 { .asm = "ldr x0, [sp, #0x28]" } [
       var local_34:bv64 := 0x0:bv64;
       var local_35:bv64 := load le $mem:(bv64->bv8) bvadd(SP:bv64, 0x28:bv64) 64;
       var local_34:bv64 := local_35:bv64;
       var R0:bv64 := zero_extend(0, zero_extend(0, local_34:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x96c:bv64);
       goto (%block_31);
     ];
     block %splitclone_code_1 { .address = 2408;
         .gtirb_block = "I2aaHzp+TUWUl9oP4OxUPg";
         .succ = [ { .address = 2276; .conditional = "false"; .direct = "true";
                 .target = "stmts:c/WxqFxXSHWNzwaD8KmaZw"; .type = "Type_Call" } ] } [
       assume eq(0x968:bv64, PC:bv64);
       goto (%block_30);
     ];
     block %splitclone_code_15 [
       assert boolor(eq(0x8e4:bv64, PC:bv64));
       goto (%splitclone_ext_1);
     ];
     block %block_35 { .asm = "bl #0xffffffffffffff38" } [
       var R30:bv64 := 0x9b0:bv64;
       var BranchTaken:bool := true;
       var PC:bv64 := 0x8e4:bv64;
       goto (%splitclone_code_15);
     ];
     block %block_34 { .asm = "ldr x0, [x0, #8]" } [
       var local_41:bv64 := 0x0:bv64;
       var local_41:bv64 := R0:bv64;
       var local_42:bv64 := 0x0:bv64;
       var local_43:bv64 := load le $mem:(bv64->bv8) bvadd(local_41:bv64, 0x8:bv64) 64;
       var local_42:bv64 := local_43:bv64;
       var R0:bv64 := zero_extend(0, zero_extend(0, local_42:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x9ac:bv64);
       goto (%block_35);
     ];
     block %block_33 { .asm = "ldr x0, [sp, #0x28]" } [
       var local_39:bv64 := 0x0:bv64;
       var local_40:bv64 := load le $mem:(bv64->bv8) bvadd(SP:bv64, 0x28:bv64) 64;
       var local_39:bv64 := local_40:bv64;
       var R0:bv64 := zero_extend(0, zero_extend(0, local_39:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x9a8:bv64);
       goto (%block_34);
     ];
     block %splitclone_code_6 { .address = 2468;
         .gtirb_block = "vIU4IpBoQ7iHGSsu/mSe3g";
         .succ = [ { .address = 2276; .conditional = "false"; .direct = "true";
                 .target = "stmts:c/WxqFxXSHWNzwaD8KmaZw"; .type = "Type_Call" } ] } [
       assume eq(0x9a4:bv64, PC:bv64);
       goto (%block_33);
     ];
     block %splitclone_code_16 [
       assert boolor(eq(0x914:bv64, PC:bv64));
       goto (%splitclone_code_3);
     ];
     block %block_46 { .asm = "bl #0xffffffffffffff78" } [
       var R30:bv64 := 0x9a0:bv64;
       var BranchTaken:bool := true;
       var PC:bv64 := 0x914:bv64;
       goto (%splitclone_code_16);
     ];
     block %block_45 { .asm = "mov x0, x3" } [
       var local_63:bv64 := 0x0:bv64;
       var local_63:bv64 := 0x0:bv64;
       var local_64:bv64 := 0x0:bv64;
       var local_64:bv64 := R3:bv64;
       var R0:bv64 := bvor(local_63:bv64,
        bvshl(local_64:bv64, zero_extend(52, 0x0:bv12)));
       (var BranchTaken:bool := false, var PC:bv64 := 0x99c:bv64);
       goto (%block_46);
     ];
     block %block_44 { .asm = "mov x1, x0" } [
       var local_61:bv64 := 0x0:bv64;
       var local_61:bv64 := 0x0:bv64;
       var local_62:bv64 := 0x0:bv64;
       var local_62:bv64 := R0:bv64;
       var R1:bv64 := bvor(local_61:bv64,
        bvshl(local_62:bv64, zero_extend(52, 0x0:bv12)));
       (var BranchTaken:bool := false, var PC:bv64 := 0x998:bv64);
       goto (%block_45);
     ];
     block %block_43 { .asm = "ldr x2, [sp, #0x18]" } [
       var local_59:bv64 := 0x0:bv64;
       var local_60:bv64 := load le $mem:(bv64->bv8) bvadd(SP:bv64, 0x18:bv64) 64;
       var local_59:bv64 := local_60:bv64;
       var R2:bv64 := zero_extend(0, zero_extend(0, local_59:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x994:bv64);
       goto (%block_44);
     ];
     block %block_42 { .asm = "ldr x0, [x0]" } [
       var local_56:bv64 := 0x0:bv64;
       var local_56:bv64 := R0:bv64;
       var local_57:bv64 := 0x0:bv64;
       var local_58:bv64 := load le $mem:(bv64->bv8) bvadd(local_56:bv64, 0x0:bv64) 64;
       var local_57:bv64 := local_58:bv64;
       var R0:bv64 := zero_extend(0, zero_extend(0, local_57:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x990:bv64);
       goto (%block_43);
     ];
     block %block_41 { .asm = "ldr x0, [sp, #0x20]" } [
       var local_54:bv64 := 0x0:bv64;
       var local_55:bv64 := load le $mem:(bv64->bv8) bvadd(SP:bv64, 0x20:bv64) 64;
       var local_54:bv64 := local_55:bv64;
       var R0:bv64 := zero_extend(0, zero_extend(0, local_54:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x98c:bv64);
       goto (%block_42);
     ];
     block %block_40 { .asm = "ldr x3, [x0]" } [
       var local_51:bv64 := 0x0:bv64;
       var local_51:bv64 := R0:bv64;
       var local_52:bv64 := 0x0:bv64;
       var local_53:bv64 := load le $mem:(bv64->bv8) bvadd(local_51:bv64, 0x0:bv64) 64;
       var local_52:bv64 := local_53:bv64;
       var R3:bv64 := zero_extend(0, zero_extend(0, local_52:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x988:bv64);
       goto (%block_41);
     ];
     block %block_39 { .asm = "ldr x0, [sp, #0x28]" } [
       var local_49:bv64 := 0x0:bv64;
       var local_50:bv64 := load le $mem:(bv64->bv8) bvadd(SP:bv64, 0x28:bv64) 64;
       var local_49:bv64 := local_50:bv64;
       var R0:bv64 := zero_extend(0, zero_extend(0, local_49:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x984:bv64);
       goto (%block_40);
     ];
     block %block_38 { .asm = "str x1, [x0]" } [
       var local_48:bv64 := 0x0:bv64;
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(R0:bv64, 0x0:bv64) R1:bv64 64;
       (var BranchTaken:bool := false, var PC:bv64 := 0x980:bv64);
       goto (%block_39);
     ];
     block %block_37 { .asm = "ldr x0, [sp, #0x20]" } [
       var local_46:bv64 := 0x0:bv64;
       var local_47:bv64 := load le $mem:(bv64->bv8) bvadd(SP:bv64, 0x20:bv64) 64;
       var local_46:bv64 := local_47:bv64;
       var R0:bv64 := zero_extend(0, zero_extend(0, local_46:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x97c:bv64);
       goto (%block_38);
     ];
     block %block_36 { .asm = "mov x1, x0" } [
       var local_44:bv64 := 0x0:bv64;
       var local_44:bv64 := 0x0:bv64;
       var local_45:bv64 := 0x0:bv64;
       var local_45:bv64 := R0:bv64;
       var R1:bv64 := bvor(local_44:bv64,
        bvshl(local_45:bv64, zero_extend(52, 0x0:bv12)));
       (var BranchTaken:bool := false, var PC:bv64 := 0x978:bv64);
       goto (%block_37);
     ];
     block %splitclone_code_5 { .address = 2420;
         .gtirb_block = "pao7tNGFTG2/wwL2A6BKrQ";
         .succ = [ { .address = 2324; .conditional = "false"; .direct = "true";
                 .target = "internal:U8BozksvTwaykuzNC4dZRQ"; .type = "Type_Call" } ] } [
       assume eq(0x974:bv64, PC:bv64);
       goto (%block_36);
     ];
     block %splitclone_code_17 [
       assert boolor(eq(0x914:bv64, PC:bv64));
       goto (%splitclone_code_3);
     ];
     block %block_57 { .asm = "bl #0xffffffffffffff3c" } [
       var R30:bv64 := 0x9dc:bv64;
       var BranchTaken:bool := true;
       var PC:bv64 := 0x914:bv64;
       goto (%splitclone_code_17);
     ];
     block %block_56 { .asm = "mov x0, x3" } [
       var local_84:bv64 := 0x0:bv64;
       var local_84:bv64 := 0x0:bv64;
       var local_85:bv64 := 0x0:bv64;
       var local_85:bv64 := R3:bv64;
       var R0:bv64 := bvor(local_84:bv64,
        bvshl(local_85:bv64, zero_extend(52, 0x0:bv12)));
       (var BranchTaken:bool := false, var PC:bv64 := 0x9d8:bv64);
       goto (%block_57);
     ];
     block %block_55 { .asm = "ldr x1, [sp, #0x20]" } [
       var local_82:bv64 := 0x0:bv64;
       var local_83:bv64 := load le $mem:(bv64->bv8) bvadd(SP:bv64, 0x20:bv64) 64;
       var local_82:bv64 := local_83:bv64;
       var R1:bv64 := zero_extend(0, zero_extend(0, local_82:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x9d4:bv64);
       goto (%block_56);
     ];
     block %block_54 { .asm = "mov x2, x0" } [
       var local_80:bv64 := 0x0:bv64;
       var local_80:bv64 := 0x0:bv64;
       var local_81:bv64 := 0x0:bv64;
       var local_81:bv64 := R0:bv64;
       var R2:bv64 := bvor(local_80:bv64,
        bvshl(local_81:bv64, zero_extend(52, 0x0:bv12)));
       (var BranchTaken:bool := false, var PC:bv64 := 0x9d0:bv64);
       goto (%block_55);
     ];
     block %block_53 { .asm = "ldr x0, [x0]" } [
       var local_77:bv64 := 0x0:bv64;
       var local_77:bv64 := R0:bv64;
       var local_78:bv64 := 0x0:bv64;
       var local_79:bv64 := load le $mem:(bv64->bv8) bvadd(local_77:bv64, 0x0:bv64) 64;
       var local_78:bv64 := local_79:bv64;
       var R0:bv64 := zero_extend(0, zero_extend(0, local_78:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x9cc:bv64);
       goto (%block_54);
     ];
     block %block_52 { .asm = "ldr x0, [sp, #0x18]" } [
       var local_75:bv64 := 0x0:bv64;
       var local_76:bv64 := load le $mem:(bv64->bv8) bvadd(SP:bv64, 0x18:bv64) 64;
       var local_75:bv64 := local_76:bv64;
       var R0:bv64 := zero_extend(0, zero_extend(0, local_75:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x9c8:bv64);
       goto (%block_53);
     ];
     block %block_51 { .asm = "ldr x3, [x0]" } [
       var local_72:bv64 := 0x0:bv64;
       var local_72:bv64 := R0:bv64;
       var local_73:bv64 := 0x0:bv64;
       var local_74:bv64 := load le $mem:(bv64->bv8) bvadd(local_72:bv64, 0x0:bv64) 64;
       var local_73:bv64 := local_74:bv64;
       var R3:bv64 := zero_extend(0, zero_extend(0, local_73:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x9c4:bv64);
       goto (%block_52);
     ];
     block %block_50 { .asm = "ldr x0, [sp, #0x28]" } [
       var local_70:bv64 := 0x0:bv64;
       var local_71:bv64 := load le $mem:(bv64->bv8) bvadd(SP:bv64, 0x28:bv64) 64;
       var local_70:bv64 := local_71:bv64;
       var R0:bv64 := zero_extend(0, zero_extend(0, local_70:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x9c0:bv64);
       goto (%block_51);
     ];
     block %block_49 { .asm = "str x1, [x0]" } [
       var local_69:bv64 := 0x0:bv64;
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(R0:bv64, 0x0:bv64) R1:bv64 64;
       (var BranchTaken:bool := false, var PC:bv64 := 0x9bc:bv64);
       goto (%block_50);
     ];
     block %block_48 { .asm = "ldr x0, [sp, #0x18]" } [
       var local_67:bv64 := 0x0:bv64;
       var local_68:bv64 := load le $mem:(bv64->bv8) bvadd(SP:bv64, 0x18:bv64) 64;
       var local_67:bv64 := local_68:bv64;
       var R0:bv64 := zero_extend(0, zero_extend(0, local_67:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x9b8:bv64);
       goto (%block_49);
     ];
     block %block_47 { .asm = "mov x1, x0" } [
       var local_65:bv64 := 0x0:bv64;
       var local_65:bv64 := 0x0:bv64;
       var local_66:bv64 := 0x0:bv64;
       var local_66:bv64 := R0:bv64;
       var R1:bv64 := bvor(local_65:bv64,
        bvshl(local_66:bv64, zero_extend(52, 0x0:bv12)));
       (var BranchTaken:bool := false, var PC:bv64 := 0x9b4:bv64);
       goto (%block_48);
     ];
     block %splitclone_code_8 { .address = 2480;
         .gtirb_block = "9oceKFiPSN69RSkX65b7GQ";
         .succ = [ { .address = 2324; .conditional = "false"; .direct = "true";
                 .target = "internal:U8BozksvTwaykuzNC4dZRQ"; .type = "Type_Call" } ] } [
       assume eq(0x9b0:bv64, PC:bv64);
       goto (%block_47);
     ];
     block %splitclone_ext_1 [
       assume eq(0x8e4:bv64, PC:bv64);
       (var PC:bv64=PC_out, var R0:bv64=R0_out, var R16:bv64=R16_out,
          var R17:bv64=R17_out, var R1:bv64=R1_out, var R29:bv64=R29_out,
          var R30:bv64=R30_out, var SP:bv64=SP_out) := call @createnode(PC_in=PC:bv64,
          R0_in=R0:bv64, R16_in=R16:bv64, R17_in=R17:bv64, R1_in=R1:bv64,
          R29_in=R29:bv64, R30_in=R30:bv64, SP_in=SP:bv64);
       assert boolor(eq(0x9b0:bv64, PC:bv64), eq(0x974:bv64, PC:bv64));
       goto (%splitclone_code_8,%splitclone_code_5);
     ];
     block %splitclone_code_13 [
       assert boolor(eq(0x9a4:bv64, PC:bv64), eq(0x968:bv64, PC:bv64));
       goto (%splitclone_code_6,%splitclone_code_1);
     ];
     block %block_29 [
       var PC:bv64 := if eq(PSTATE_Z:bv1, 0x1:bv1) then 0x9a4:bv64 else 0x968:bv64;
       goto (%splitclone_code_13);
     ];
     block %block_26 { .asm = "b.eq #0x40" } [ goto (%block_28,%block_27); ];
     block %block_25 { .asm = "cmp w0, #0" } [
       var local_32:bv32 := 0x0:bv32;
       var local_33:bv32 := 0x0:bv32;
       var PSTATE_V:bv1 := bvnot(booltobv1(eq(sign_extend(32,
          bvadd(bvadd(extract(32,0, R0:bv64), 0xffffffff:bv32), 0x1:bv32)),
          bvadd(bvadd(sign_extend(32, extract(32,0, R0:bv64)),
            0xffffffffffffffff:bv64), 0x1:bv64))));
       var PSTATE_C:bv1 := bvnot(booltobv1(eq(zero_extend(32,
          bvadd(bvadd(extract(32,0, R0:bv64), 0xffffffff:bv32), 0x1:bv32)),
          bvadd(bvadd(zero_extend(32, extract(32,0, R0:bv64)), 0xffffffff:bv64),
           0x1:bv64))));
       var PSTATE_Z:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, R0:bv64),
           0xffffffff:bv32), 0x1:bv32), 0x0:bv32));
       var PSTATE_N:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, R0:bv64),
         0xffffffff:bv32), 0x1:bv32));
       (var BranchTaken:bool := false, var PC:bv64 := 0x964:bv64);
       goto (%block_26);
     ];
     block %block_24 { .asm = "and w0, w0, #1" } [
       var local_31:bv32 := 0x0:bv32;
       var local_31:bv32 := extract(32,0, R0:bv64);
       var R0:bv64 := zero_extend(32, bvand(local_31:bv32, 0x1:bv32));
       (var BranchTaken:bool := false, var PC:bv64 := 0x960:bv64);
       goto (%block_25);
     ];
     block %block_23 { .asm = "ldr w0, [x0]" } [
       var local_28:bv64 := 0x0:bv64;
       var local_28:bv64 := R0:bv64;
       var local_29:bv32 := 0x0:bv32;
       var local_30:bv32 := load le $mem:(bv64->bv8) bvadd(local_28:bv64, 0x0:bv64) 32;
       var local_29:bv32 := local_30:bv32;
       var R0:bv64 := zero_extend(32, zero_extend(0, local_29:bv32));
       (var BranchTaken:bool := false, var PC:bv64 := 0x95c:bv64);
       goto (%block_24);
     ];
     block %block_22 { .asm = "ldr x0, [x0, #8]" } [
       var local_25:bv64 := 0x0:bv64;
       var local_25:bv64 := R0:bv64;
       var local_26:bv64 := 0x0:bv64;
       var local_27:bv64 := load le $mem:(bv64->bv8) bvadd(local_25:bv64, 0x8:bv64) 64;
       var local_26:bv64 := local_27:bv64;
       var R0:bv64 := zero_extend(0, zero_extend(0, local_26:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x958:bv64);
       goto (%block_23);
     ];
     block %block_21 { .asm = "ldr x0, [sp, #0x28]" } [
       var local_23:bv64 := 0x0:bv64;
       var local_24:bv64 := load le $mem:(bv64->bv8) bvadd(SP:bv64, 0x28:bv64) 64;
       var local_23:bv64 := local_24:bv64;
       var R0:bv64 := zero_extend(0, zero_extend(0, local_23:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x954:bv64);
       goto (%block_22);
     ];
     block %splitclone_code_7 { .address = 2384;
         .gtirb_block = "5jlZESzjQ4a4yO3+e1nyHQ";
         .succ = [ { .address = 2468; .conditional = "true"; .direct = "true";
                 .target = "internal:vIU4IpBoQ7iHGSsu/mSe3g"; .type = "Type_Branch" };
             { .address = 2408; .conditional = "true"; .direct = "true";
                 .target = "internal:I2aaHzp+TUWUl9oP4OxUPg";
                 .type = "Type_Fallthrough" } ] } [
       assume eq(0x950:bv64, PC:bv64);
       goto (%block_21);
     ];
     block %splitclone_code_9 [
       assert boolor(eq(0x950:bv64, PC:bv64), eq(0x9dc:bv64, PC:bv64),
        eq(0x9a0:bv64, PC:bv64), eq(0x934:bv64, PC:bv64));
       goto (%splitclone_code_7,%splitclone_code_4,%splitclone_code_2,%splitclone_code);
     ];
     block %block_10 [
       var PC:bv64 := if boolnot(eq(PSTATE_Z:bv1, 0x1:bv1)) then 0x950:bv64 else 0x934:bv64;
       goto (%splitclone_code_9);
     ];
     block %block_7 { .asm = "b.ne #0x20" } [ goto (%block_9,%block_8); ];
     block %block_6 { .asm = "cmp x0, #0" } [
       var local_4:bv64 := 0x0:bv64;
       var local_5:bv64 := 0x0:bv64;
       var PSTATE_V:bv1 := bvnot(booltobv1(eq(sign_extend(64,
          bvadd(bvadd(R0:bv64, 0xffffffffffffffff:bv64), 0x1:bv64)),
          bvadd(bvadd(sign_extend(64, R0:bv64),
            0xffffffffffffffffffffffffffffffff:bv128), 0x1:bv128))));
       var PSTATE_C:bv1 := bvnot(booltobv1(eq(zero_extend(64,
          bvadd(bvadd(R0:bv64, 0xffffffffffffffff:bv64), 0x1:bv64)),
          bvadd(bvadd(zero_extend(64, R0:bv64), 0xffffffffffffffff:bv128), 0x1:bv128))));
       var PSTATE_Z:bv1 := booltobv1(eq(bvadd(bvadd(R0:bv64, 0xffffffffffffffff:bv64),
          0x1:bv64), 0x0:bv64));
       var PSTATE_N:bv1 := extract(64,63, bvadd(bvadd(R0:bv64,
         0xffffffffffffffff:bv64), 0x1:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x930:bv64);
       goto (%block_7);
     ];
     block %block_5 { .asm = "ldr x0, [sp, #0x28]" } [
       var local_2:bv64 := 0x0:bv64;
       var local_3:bv64 := load le $mem:(bv64->bv8) bvadd(SP:bv64, 0x28:bv64) 64;
       var local_2:bv64 := local_3:bv64;
       var R0:bv64 := zero_extend(0, zero_extend(0, local_2:bv64));
       (var BranchTaken:bool := false, var PC:bv64 := 0x92c:bv64);
       goto (%block_6);
     ];
     block %block_4 { .asm = "str x2, [sp, #0x18]" } [
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(SP:bv64, 0x18:bv64) R2:bv64 64;
       (var BranchTaken:bool := false, var PC:bv64 := 0x928:bv64);
       goto (%block_5);
     ];
     block %block_3 { .asm = "str x1, [sp, #0x20]" } [
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(SP:bv64, 0x20:bv64) R1:bv64 64;
       (var BranchTaken:bool := false, var PC:bv64 := 0x924:bv64);
       goto (%block_4);
     ];
     block %block_2 { .asm = "str x0, [sp, #0x28]" } [
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(SP:bv64, 0x28:bv64) R0:bv64 64;
       (var BranchTaken:bool := false, var PC:bv64 := 0x920:bv64);
       goto (%block_3);
     ];
     block %block_1 { .asm = "mov x29, sp" } [
       var local_1:bv64 := 0x0:bv64;
       var R29:bv64 := bvadd(SP:bv64, 0x0:bv64);
       (var BranchTaken:bool := false, var PC:bv64 := 0x91c:bv64);
       goto (%block_2);
     ];
     block %block { .asm = "stp x29, x30, [sp, #-0x30]!" } [
       var local:bv64 := 0x0:bv64;
       var local:bv64 := SP:bv64;
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(SP:bv64,
        0xffffffffffffffd0:bv64) R29:bv64 64;
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvadd(bvadd(SP:bv64,
         0xffffffffffffffd0:bv64), 0x8:bv64) R30:bv64 64;
       var SP:bv64 := bvadd(local:bv64, 0xffffffffffffffd0:bv64);
       (var BranchTaken:bool := false, var PC:bv64 := 0x918:bv64);
       goto (%block_1);
     ];
     block %splitclone_code_3 { .address = 2324;
         .gtirb_block = "U8BozksvTwaykuzNC4dZRQ";
         .succ = [ { .address = 2384; .conditional = "true"; .direct = "true";
                 .target = "internal:5jlZESzjQ4a4yO3+e1nyHQ"; .type = "Type_Branch" };
             { .address = 2524; .target = "internal:WTjM+CpMSlaCQoaCOxiagA" };
             { .address = 2464; .target = "internal:QIZPtsaTQjiAsr+paN6ljw" };
             { .address = 2356; .conditional = "true"; .direct = "true";
                 .target = "internal:H7LPJaZbQvWx+VL+kBk//Q";
                 .type = "Type_Fallthrough" } ] } [
       assume eq(0x914:bv64, PC:bv64);
       goto (%block);
     ];
     block %inputs [
       (var PC:bv64 := PC_in:bv64, var PSTATE_C:bv1 := PSTATE_C_in:bv1,
        var PSTATE_N:bv1 := PSTATE_N_in:bv1, var PSTATE_V:bv1 := PSTATE_V_in:bv1,
        var PSTATE_Z:bv1 := PSTATE_Z_in:bv1, var R0:bv64 := R0_in:bv64,
        var R1:bv64 := R1_in:bv64, var R16:bv64 := R16_in:bv64,
        var R17:bv64 := R17_in:bv64, var R2:bv64 := R2_in:bv64,
        var R29:bv64 := R29_in:bv64, var R3:bv64 := R3_in:bv64,
        var R30:bv64 := R30_in:bv64, var SP:bv64 := SP_in:bv64);
       goto (%splitclone_code_3);
     ]
  ];
  prog entry @_start { .initial_memory = [ { .address = 0;
              .bytes = "A#\000\000\000aeabi_feature_and_bits\000\001\000\000\000\001\000\002\000";
              .name = ".ARM.attributes"; .read_only = true; .size = 36 };
          { .address = 568;
              .bytes = [ "H4sIAAAAAAAA/wFuAJH/L25peC9zdG9yZS9rbDFjbHhkd2tydzRnMzdxYWtraWpkenE5Zm02cGJndy1nbGliYy1hYXJjaDY0LXVua25vd24tbGludXgtZ251LTIuNDItNjcvbGliL2xkLWxpbnV4LWFhcmNoNjQuc28uMQA6rjEIbgAAAA==" ];
              .name = ".interp"; .read_only = true; .size = 110 };
          { .address = 680;
              .bytes = "\003\000\000\000\011\000\000\000\007\000\000\000\n\000\000\000\b\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\003\000\000\000\000\000\000\000\005\000\000\000\000\000\000\000\006\000\000\000\004\000\000\000\t\000\000\000";
              .name = ".hash"; .read_only = true; .size = 64 };
          { .address = 744;
              .bytes = "\001\000\000\000\001\000\000\000\001\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000";
              .name = ".gnu.hash"; .read_only = true; .size = 28 };
          { .address = 776;
              .bytes = [ "H4sIAAAAAAAA/wEIAff+AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMACgAQBwAAAAAAAAAAAAAAAAAAAAAAAAMAFwAwAAIAAAAAAAAAAAAAAAAADQAAABIAAAAAAAAAAAAAAAAAAAAAAAAAHwEAACAAAAAAAAAAAAAAAAAAAAAAAAAAHwAAACIAAAAAAAAAAAAAAAAAAAAAAAAABgAAABIAAAAAAAAAAAAAAAAAAAAAAAAAOwEAACAAAAAAAAAAAAAAAAAAAAAAAAAALgAAABIAAAAAAAAAAAAAAAAAAAAAAAAAAQAAABIAAAAAAAAAAAAAAAAAAAAAAAAASgEAACAAAAAAAAAAAAAAAAAAAAAAAAAAFQpBtwgBAAA=" ];
              .name = ".dynsym"; .read_only = true; .size = 264 };
          { .address = 1040;
              .bytes = [ "H4sIAAAAAAAA/wFkAZv+AGZyZWUAbWFsbG9jAF9fbGliY19zdGFydF9tYWluAF9fY3hhX2ZpbmFsaXplAGFib3J0AGxpYmMuc28uNgBHTElCQ18yLjE3AEdMSUJDXzIuMzQAL25peC9zdG9yZS9rbDFjbHhkd2tydzRnMzdxYWtraWpkenE5Zm02cGJndy1nbGliYy1hYXJjaDY0LXVua25vd24tbGludXgtZ251LTIuNDItNjcvbGliOi9uaXgvc3RvcmUvbGd3cTB6eWhzZjB2eGcyMHI1ajJnMW13cnJyc3lncWctYWFyY2g2NC11bmtub3duLWxpbnV4LWdudS1nY2MtMTUuMy4wLWxpYi9hYXJjaDY0LXVua25vd24tbGludXgtZ251L2xpYgBfSVRNX2RlcmVnaXN0ZXJUTUNsb25lVGFibGUAX19nbW9uX3N0YXJ0X18AX0lUTV9yZWdpc3RlclRNQ2xvbmVUYWJsZQCIWUk9ZAEAAA==" ];
              .name = ".dynstr"; .read_only = true; .size = 356 };
          { .address = 1396;
              .bytes = "\000\000\000\000\000\000\002\000\000\000\003\000\003\000\000\000\003\000\003\000\000\000";
              .name = ".gnu.version"; .read_only = true; .size = 22 };
          { .address = 1424;
              .bytes = "\001\000\002\0004\000\000\000\016\000\000\000\000\000\000\000\151\145\150\006\000\000\003\000>\000\000\000\016\000\000\000\180\145\150\006\000\000\002\000I\000\000\000\000\000\000\000";
              .name = ".gnu.version_r"; .read_only = true; .size = 48 };
          { .address = 1472;
              .bytes = [ "H4sIAAAAAAAA/wHAAD//qP0BAAAAAAADBAAAAAAAAOAIAAAAAAAAsP0BAAAAAAADBAAAAAAAAIwIAAAAAAAA2P8BAAAAAAADBAAAAAAAAHAKAAAAAAAAOAACAAAAAAADBAAAAAAAADgAAgAAAAAAwP8BAAAAAAABBAAABAAAAAAAAAAAAAAAyP8BAAAAAAABBAAABQAAAAAAAAAAAAAA0P8BAAAAAAABBAAABwAAAAAAAAAAAAAA4P8BAAAAAAABBAAACgAAAAAAAAAAAAAAQgFGTsAAAAA=" ];
              .name = ".rela.dyn"; .read_only = true; .size = 192 };
          { .address = 1664;
              .bytes = [ "H4sIAAAAAAAA/wGQAG//AAACAAAAAAACBAAAAwAAAAAAAAAAAAAACAACAAAAAAACBAAABQAAAAAAAAAAAAAAEAACAAAAAAACBAAABgAAAAAAAAAAAAAAGAACAAAAAAACBAAABwAAAAAAAAAAAAAAIAACAAAAAAACBAAACAAAAAAAAAAAAAAAKAACAAAAAAACBAAACQAAAAAAAAAAAAAA+1ZZqJAAAAA=" ];
              .name = ".rela.plt"; .read_only = true; .size = 144 };
          { .address = 1808;
              .bytes = "?#\003\213\253{\191\169\253\003\000\1456\000\000\148\253{\193\168\191#\003\213\192\003_\214";
              .name = ".init"; .read_only = true; .size = 28 };
          { .address = 1840;
              .bytes = [ "H4sIAAAAAAAA/wGAAH//8Hu/qfAAAPAR/kf5EOI/kSACH9YfIAPVHyAD1R8gA9UQAQCQEQJA+RACAJEgAh/WEAEAkBEGQPkQIgCRIAIf1hABAJARCkD5EEIAkSACH9YQAQCQEQ5A+RBiAJEgAh/WEAEAkBESQPkQggCRIAIf1hABAJARFkD5EKIAkSACH9YwvoyYgAAAAA==" ];
              .name = ".plt"; .read_only = true; .size = 128 };
          { .address = 1984;
              .bytes = [ "H4sIAAAAAAAA/wHEAjv9XyQD1R0AgNIeAIDS5QMAquEDQPniIwCR5gMAkeAAAPAA7Ef5AwCA0gQAgNLZ//+X6P//l+AAAPAA6Ef5QAAAtOD//xfAA1/WHyAD1R8gA9UfIAPVHyAD1R8gA9UfIAPVAAEAkAAAAZEBAQCQIQABkT8AAOvAAABU4QAA8CHgR/lhAAC08AMBqgACH9bAA1/WAAEAkAAAAZEBAQCQIQABkSEAAMsi/H/TQQyBiyH8QZPBAAC04gAA8ELwR/liAAC08AMCqgACH9bAA1/W/Xu+qf0DAJHzCwD5EwEAkGACQTlAAQA34AAA8ADkR/mAAAC0AAEAkAAcQPmq//+X2f//lyAAgFJgAgE58wtA+f17wqjAA1/WHyAD1R8gA9UfIAPV3P//F/17van9AwCR4A8A+QACgNKf//+X4BcA+eAXQPnhD0D5AQQA+eAXQPn9e8OowANf1v17van9AwCR4BcA+eETAPniDwD54BdA+R8AAPEBAQBU4A9A+R8AAPngD0D5AQBA+eATQPkBAAD5JAAAFOAXQPkABED5AABAuQAAABIfAABxAAIAVOAXQPkABED53f//l+EDAKrgE0D5AQAA+eAXQPkDAED54BNA+QAAQPniD0D54QMAquADA6re//+XDwAAFOAXQPkABED5zv//l+EDAKrgD0D5AQAA+eAXQPkDAED54A9A+QAAQPniAwCq4RNA+eADA6rP//+X/XvDqMADX9b9e7yp/QMAkeAPAPnhowCR4MMAkeIDAarhAwCq4A9A+cT//5cIAAAU4BtA+QAAQPngHwD54BtA+WH//5fgH0D54BsA+eAbQPkfAADx4f7/VAgAABTgF0D5AABA+eAfAPngF0D5Vv//l+AfQPngFwD54BdA+R8AAPHh/v9UHyAD1R8gA9X9e8SowANf1v17v6n9AwCRAACAUv17wajAA1/WjSxVfMQCAAA=" ];
              .name = ".text"; .read_only = true; .size = 708 };
          { .address = 2692;
              .bytes = "?#\003\213\253{\191\169\253\003\000\145\253{\193\168\191#\003\213\192\003_\214";
              .name = ".fini"; .read_only = true; .size = 24 };
          { .address = 2716; .bytes = "\001\000\002\000"; .name = ".rodata";
              .read_only = true; .size = 4 };
          { .address = 2720;
              .bytes = [ "H4sIAAAAAAAA/wFUAKv/ARsDO1QAAAAJAAAAIP3//2wAAACA/f//gAAAALD9//+UAAAA7P3//6gAAABA/v//zAAAAET+///gAAAAdP7//wABAABE////IAEAAND///9AAQAAppmyHFQAAAA=" ];
              .name = ".eh_frame_hdr"; .read_only = true; .size = 84 };
          { .address = 2808;
              .bytes = [ "H4sIAAAAAAAA/wEMAfP+EAAAAAAAAAABelIABHgeARsMHwAQAAAAGAAAAKz8//80AAAAAEEHHhAAAAAsAAAA+Pz//zAAAAAAAAAAEAAAAEAAAAAU/f//PAAAAAAAAAAgAAAAVAAAADz9//9IAAAAAEEOIJ0EngNCkwJO3t3TDgAAAAAQAAAAeAAAAGz9//8EAAAAAAAAABwAAACMAAAAXP3//zAAAAAAQQ4wnQaeBUre3Q4AAAAAHAAAAKwAAABs/f//0AAAAABBDjCdBp4Fct7dDgAAAAAcAAAAzAAAABz+//+MAAAAAEEOQJ0Ingdh3t0OAAAAABwAAADsAAAAiP7//xQAAAAAQQ4QnQKeAUPe3Q4AAAAAAAAAAASF1OcMAQAA" ];
              .name = ".eh_frame"; .read_only = true; .size = 268 };
          { .address = 3076;
              .bytes = "\004\000\000\000\016\000\000\000\001\000\000\000GNU\000\000\000\000\000\003\000\000\000\n\000\000\000\000\000\000\000";
              .name = ".note.ABI-tag"; .read_only = true; .size = 32 };
          { .address = 130472; .bytes = "\224\b\000\000\000\000\000\000";
              .name = ".init_array"; .size = 8 };
          { .address = 130480; .bytes = "\140\b\000\000\000\000\000\000";
              .name = ".fini_array"; .size = 8 };
          { .address = 130488;
              .bytes = [ "H4sIAAAAAAAA/wEAAv/9AQAAAAAAAAA0AAAAAAAAAB0AAAAAAAAAVAAAAAAAAAAMAAAAAAAAABAHAAAAAAAADQAAAAAAAACECgAAAAAAABkAAAAAAAAAqP0BAAAAAAAbAAAAAAAAAAgAAAAAAAAAGgAAAAAAAACw/QEAAAAAABwAAAAAAAAACAAAAAAAAAAEAAAAAAAAAKgCAAAAAAAA9f7/bwAAAADoAgAAAAAAAAUAAAAAAAAAEAQAAAAAAAAGAAAAAAAAAAgDAAAAAAAACgAAAAAAAABkAQAAAAAAAAsAAAAAAAAAGAAAAAAAAAAVAAAAAAAAAAAAAAAAAAAAAwAAAAAAAADo/wEAAAAAAAIAAAAAAAAAkAAAAAAAAAAUAAAAAAAAAAcAAAAAAAAAFwAAAAAAAACABgAAAAAAAAcAAAAAAAAAwAUAAAAAAAAIAAAAAAAAAMAAAAAAAAAACQAAAAAAAAAYAAAAAAAAAPv//28AAAAAAAAACAAAAAD+//9vAAAAAJAFAAAAAAAA////bwAAAAABAAAAAAAAAPD//28AAAAAdAUAAAAAAAD5//9vAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD9SkqTAAIAAA==" ];
              .name = ".dynamic"; .size = 512 };
          { .address = 131000;
              .bytes = "\184\253\001\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000p\n\000\000\000\000\000\000\000\000\000\000\000\000\000\000";
              .name = ".got"; .size = 48 };
          { .address = 131048;
              .bytes = "\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\0000\007\000\000\000\000\000\0000\007\000\000\000\000\000\0000\007\000\000\000\000\000\0000\007\000\000\000\000\000\0000\007\000\000\000\000\000\0000\007\000\000\000\000\000\000";
              .name = ".got.plt"; .size = 72 };
          { .address = 131120;
              .bytes = "\000\000\000\000\000\000\000\0008\000\002\000\000\000\000\000";
              .name = ".data"; .size = 16 };
          { .address = 131136; .bytes = ""; .name = ".bss"; .size = 8 } ];
      .invariants = [ "Params"; "GtirbArm" ] };
  |}]

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
  Called from Dsa_tests__Inline.(fun) in file "test/dsa/inline.ml", line 88, characters 41-64
  Called from Ppx_expect_runtime__Test_block.Configured.dump_backtrace in file "runtime/test_block.ml", line 142, characters 10-28
  |}]

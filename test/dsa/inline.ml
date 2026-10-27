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

  let proc_names = [ "@processlist"; "@createnode"; "@splitclone" ] in

  let prog =
    Bincaml.Passes.PassManager.(run_transform prog lift_intrinsics_aarch64)
  in

  CCResult.pp CCFormat.unit Format.std_formatter
  @@ CCResult.guard_str
  @@ fun () ->
  (*let prog =
    Lang.Program.declarations prog
    |> Iter.fold
         (fun prog (id, decl) ->
           if List.mem (ID.name id) proc_names then prog
           else Lang.Program.remove_decl prog decl)
         prog
  in
  let prog =
    Lang.Program.(set_entry_proc (get_id_by_name (List.hd proc_names) prog))
      prog
    in*)
  let prog = Bincaml.Passes.PassManager.(run_transform prog aslp_semantics) in
  let prog = Bincaml.Passes.PassManager.(run_transform prog sparams) in
  let prog = Bincaml.Passes.PassManager.(run_transform prog sssa) in

  let dsgraph = Analysis.Dsa.dsa prog in

  List.iter
    (fun name ->
      let _, g = IDMap.find (Lang.Program.get_id_by_name name prog) dsgraph in
      print_endline @@ name;
      print_endline @@ Analysis.Dsa.dot_string g;
      print_endline "")
    proc_names;
  [%expect {| error(Not_found) |}]

let%expect_test "lattner2_indirect" =
  let prog = (Loader.Loadir.ast_of_fname "lattner2_indirect.il").prog in

  let proc_names = [ "@func1"; "@func2"; "@caller" ] in

  let prog =
    Bincaml.Passes.PassManager.(run_transform prog lift_intrinsics_aarch64)
  in

  (CCResult.pp CCFormat.unit Format.std_formatter
  @@ CCResult.guard_str
  @@ fun () ->
  (*let prog =
    Lang.Program.declarations prog
    |> Iter.fold
         (fun prog (id, decl) ->
           if List.mem (ID.name id) proc_names then prog
           else Lang.Program.remove_decl prog decl)
         prog
  in
  let prog =
    Lang.Program.(set_entry_proc (get_id_by_name (List.hd proc_names) prog))
      prog
    in*)
  let prog = Bincaml.Passes.PassManager.(run_transform prog aslp_semantics) in
  let prog = Bincaml.Passes.PassManager.(run_transform prog sparams) in
  let prog = Bincaml.Passes.PassManager.(run_transform prog sssa) in

  let dsgraph = Analysis.Dsa.dsa prog in

  List.iter
    (fun name ->
      let _, g = IDMap.find (Lang.Program.get_id_by_name name prog) dsgraph in
      print_endline @@ name;
      print_endline @@ Analysis.Dsa.dot_string g;
      print_endline "")
    proc_names);
  [%expect {| error(Not_found) |}]

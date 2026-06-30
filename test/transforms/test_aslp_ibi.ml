open Lang
open Common
open Transforms.Aslp

let id_gen = lazy (ID.make_gen ())

let make_call name =
  Printf.printf "make_call: %s\n" name;
  Stmt.Instr_Call
    {
      attrib = Attrib.empty;
      lhs = StringMap.empty;
      args = StringMap.empty;
      procid = (Lazy.force_val id_gen).fresh ~name ();
    }

let guard f =
  CCResult.pp CCFormat.unit Format.stdout
    (CCResult.guard_str (fun () -> ignore (f ())))

let guard_get_ir f =
  print_endline @@ CCResult.retract
  @@ CCResult.guard_str (fun () -> Aslp_state.show_aslp_diamond (f ()))

let%expect_test "nested diamonds" =
  let module I = (val Bincaml_ibi.from_generator (Aslp_state.empty_aslp_ids ()))
  in
  I.bincaml_set_address (Bitvec.of_int ~size:64 0xfaf);
  let branch1 = I.f_gen_branch (I.f_gen_bool_lit true) in
  I.bincaml_internal_emit (make_call "entry");

  I.f_switch_context (I.f_true_branch branch1);
  I.bincaml_internal_emit (make_call "t");
  I.f_gen_store I.v__PC
    (I.f_gen_bit_lit (I.bigint_of_int 64) (Bitvec.of_int ~size:64 0xaaa));

  I.f_switch_context (I.f_false_branch branch1);
  I.bincaml_internal_emit (make_call "f");
  begin
    let branch2 = I.f_gen_branch (I.f_gen_bool_lit false) in
    I.f_switch_context (I.f_true_branch branch2);
    I.bincaml_internal_emit (make_call "ft");
    I.f_gen_store I.v__PC
      (I.f_gen_bit_lit (I.bigint_of_int 64) (Bitvec.of_int ~size:64 0xbbb));
    I.f_switch_context (I.f_false_branch branch2);
    I.bincaml_internal_emit (make_call "ff");
    I.f_switch_context (I.f_merge_branch branch2);
    I.bincaml_internal_emit (make_call "fm")
  end;

  I.f_switch_context (I.f_merge_branch branch1);
  I.bincaml_internal_emit (make_call "m");

  guard_get_ir I.get_ir;
  [%expect.unreachable]
[@@expect.uncaught_exn {|
  (* CR expect_test_collector: This test expectation appears to contain a backtrace.
     This is strongly discouraged as backtraces are fragile.
     Please change this test to not include a backtrace. *)
  (Failure "invariant violation: invalid zipper path")
  Raised at Stdlib.failwith in file "stdlib.ml", line 29, characters 17-33
  Called from Transforms__Aslp__Diamond_zipper.focus in file "lib/transforms/aslp/diamond_zipper.ml", line 70, characters 44-58
  Called from CCFun.Infix.(%) in file "src/core/CCFun.pp.ml" (inlined), line 74, characters 31-36
  Called from Transforms__Aslp__Diamond_ibi.Make.f_switch_context in file "lib/transforms/aslp/diamond_ibi.ml", line 56, characters 22-64
  Called from Iter.find_pred.(fun) in file "src/Iter.ml", line 769, characters 9-12
  Called from Iter.find_map.(fun) in file "src/Iter.ml", line 740, characters 15-18
  Called from Transforms__Aslp__Diamond_zipper.iter_zippers_backwards.iter_paths_backwards in file "lib/transforms/aslp/diamond_zipper.ml", line 87, characters 8-48
  Called from Transforms__Aslp__Diamond_zipper.iter_zippers_backwards.iter_paths_backwards in file "lib/transforms/aslp/diamond_zipper.ml", line 88, characters 8-49
  Called from Iter.find_map in file "src/Iter.ml", lines 739-744, characters 5-34
  Called from Transforms__Aslp__Diamond_ibi.Make.f_switch_context in file "lib/transforms/aslp/diamond_ibi.ml", lines 54-56, characters 4-64
  Called from Transforms__Aslp__Bincaml_ibi_make.Make.f_switch_context in file "lib/transforms/aslp/bincaml_ibi_make.ml", line 71, characters 4-29
  Called from Test_aslp__Test_aslp_ibi.(fun) in file "test/transforms/test_aslp_ibi.ml", line 41, characters 4-48
  Called from Ppx_expect_runtime__Test_block.Configured.dump_backtrace in file "runtime/test_block.ml", line 142, characters 10-28

  Trailing output
  ---------------
  make_call: entry
  make_call: t
  make_call: f
  |}]

let%expect_test "sequential diamonds" =
  let module I = (val Bincaml_ibi.from_generator (Aslp_state.empty_aslp_ids ()))
  in
  ( guard @@ fun () ->
    I.bincaml_set_address (Bitvec.of_int ~size:64 0xfaf);
    let b1 = I.f_gen_branch (I.f_gen_bool_lit true) in
    I.bincaml_internal_emit (make_call "entry");

    I.f_switch_context (I.f_true_branch b1);
    I.bincaml_internal_emit (make_call "b1_t");
    I.f_switch_context (I.f_merge_branch b1);

    let b2 = I.f_gen_branch (I.f_gen_bool_lit true) in
    I.f_switch_context (I.f_true_branch b2);
    I.bincaml_internal_emit (make_call "b2_t");
    I.f_switch_context (I.f_merge_branch b2);

    I.bincaml_internal_emit (make_call "exit");

    guard_get_ir I.get_ir );
  [%expect {|
    make_call: entry
    make_call: b1_t
    make_call: b2_t
    make_call: exit
    Diamond {
      pred =
      Diamond {
        pred =
        (Leaf
           { Aslp_state.assume = true; stmts = [call entry_1()]; pc_assign = None
             });
        left =
        (Leaf
           { Aslp_state.assume = true; stmts = [call b1_t()]; pc_assign = None });
        right =
        (Leaf { Aslp_state.assume = boolnot(true); stmts = []; pc_assign = None });
        value = { Aslp_state.assume = true; stmts = []; pc_assign = None }};
      left =
      (Leaf { Aslp_state.assume = true; stmts = [call b2_t()]; pc_assign = None });
      right =
      (Leaf { Aslp_state.assume = boolnot(true); stmts = []; pc_assign = None });
      value =
      { Aslp_state.assume = true;
        stmts =
        [call exit(); (var BranchTaken:bool := false, $PC:bv64 := 0xfb3:bv64)];
        pc_assign = (Some 0xfb3:bv64) }}
    ok(())
    |}]

let%expect_test "skipped merge context when going to outer merge" =
  let module I = (val Bincaml_ibi.from_generator (Aslp_state.empty_aslp_ids ()))
  in
  I.bincaml_set_address (Bitvec.of_int ~size:64 0xfaf);
  let outer = I.f_gen_branch (I.f_gen_bool_lit true) in
  I.bincaml_internal_emit (make_call "entry");

  I.f_switch_context (I.f_true_branch outer);
  I.bincaml_internal_emit (make_call "t");

  let inner = I.f_gen_branch (I.f_gen_bool_lit true) in
  I.f_switch_context (I.f_true_branch inner);
  I.bincaml_internal_emit (make_call "tt");
  I.f_switch_context (I.f_false_branch inner);
  I.bincaml_internal_emit (make_call "tf");

  (* context switch skipped: *)
  (* I.f_switch_context (I.f_merge_branch inner); *)
  I.f_switch_context (I.f_merge_branch outer);
  I.bincaml_internal_emit (make_call "m_outer");

  guard_get_ir I.get_ir;

  [%expect.unreachable]
[@@expect.uncaught_exn {|
  (* CR expect_test_collector: This test expectation appears to contain a backtrace.
     This is strongly discouraged as backtraces are fragile.
     Please change this test to not include a backtrace. *)
  (Failure "invariant violation: invalid zipper path")
  Raised at Stdlib.failwith in file "stdlib.ml", line 29, characters 17-33
  Called from Transforms__Aslp__Diamond_zipper.focus in file "lib/transforms/aslp/diamond_zipper.ml", line 70, characters 44-58
  Called from CCFun.Infix.(%) in file "src/core/CCFun.pp.ml" (inlined), line 74, characters 31-36
  Called from Transforms__Aslp__Diamond_ibi.Make.f_switch_context in file "lib/transforms/aslp/diamond_ibi.ml", line 56, characters 22-64
  Called from Iter.find_pred.(fun) in file "src/Iter.ml", line 769, characters 9-12
  Called from Iter.find_map.(fun) in file "src/Iter.ml", line 740, characters 15-18
  Called from Transforms__Aslp__Diamond_zipper.iter_zippers_backwards.iter_paths_backwards in file "lib/transforms/aslp/diamond_zipper.ml", line 88, characters 8-49
  Called from Transforms__Aslp__Diamond_zipper.iter_zippers_backwards.iter_paths_backwards in file "lib/transforms/aslp/diamond_zipper.ml", line 87, characters 8-48
  Called from Iter.find_map in file "src/Iter.ml", lines 739-744, characters 5-34
  Called from Transforms__Aslp__Diamond_ibi.Make.f_switch_context in file "lib/transforms/aslp/diamond_ibi.ml", lines 54-56, characters 4-64
  Called from Transforms__Aslp__Bincaml_ibi_make.Make.f_switch_context in file "lib/transforms/aslp/bincaml_ibi_make.ml", line 71, characters 4-29
  Called from Test_aslp__Test_aslp_ibi.(fun) in file "test/transforms/test_aslp_ibi.ml", line 111, characters 2-45
  Called from Ppx_expect_runtime__Test_block.Configured.dump_backtrace in file "runtime/test_block.ml", line 142, characters 10-28

  Trailing output
  ---------------
  make_call: entry
  make_call: t
  make_call: tt
  |}]

let%expect_test "skipped merge context when going to outer branch" =
  let module I = (val Bincaml_ibi.from_generator (Aslp_state.empty_aslp_ids ()))
  in
  I.bincaml_set_address (Bitvec.of_int ~size:64 0xfaf);
  let outer = I.f_gen_branch (I.f_gen_bool_lit true) in
  I.bincaml_internal_emit (make_call "entry");

  I.f_switch_context (I.f_true_branch outer);
  I.bincaml_internal_emit (make_call "t");

  let inner = I.f_gen_branch (I.f_gen_bool_lit true) in
  I.f_switch_context (I.f_true_branch inner);
  I.bincaml_internal_emit (make_call "tt");
  I.f_switch_context (I.f_false_branch inner);
  I.bincaml_internal_emit (make_call "tf");

  (* context switch skipped: *)
  (* I.f_switch_context (I.f_merge_branch inner); *)
  I.f_switch_context (I.f_false_branch outer);
  I.bincaml_internal_emit (make_call "f");

  I.f_switch_context (I.f_merge_branch outer);
  I.bincaml_internal_emit (make_call "m_outer");

  guard_get_ir I.get_ir;

  [%expect.unreachable]
[@@expect.uncaught_exn {|
  (* CR expect_test_collector: This test expectation appears to contain a backtrace.
     This is strongly discouraged as backtraces are fragile.
     Please change this test to not include a backtrace. *)
  (Failure "invariant violation: invalid zipper path")
  Raised at Stdlib.failwith in file "stdlib.ml", line 29, characters 17-33
  Called from Transforms__Aslp__Diamond_zipper.focus in file "lib/transforms/aslp/diamond_zipper.ml", line 70, characters 44-58
  Called from CCFun.Infix.(%) in file "src/core/CCFun.pp.ml" (inlined), line 74, characters 31-36
  Called from Transforms__Aslp__Diamond_ibi.Make.f_switch_context in file "lib/transforms/aslp/diamond_ibi.ml", line 56, characters 22-64
  Called from Iter.find_pred.(fun) in file "src/Iter.ml", line 769, characters 9-12
  Called from Iter.find_map.(fun) in file "src/Iter.ml", line 740, characters 15-18
  Called from Transforms__Aslp__Diamond_zipper.iter_zippers_backwards.iter_paths_backwards in file "lib/transforms/aslp/diamond_zipper.ml", line 88, characters 8-49
  Called from Transforms__Aslp__Diamond_zipper.iter_zippers_backwards.iter_paths_backwards in file "lib/transforms/aslp/diamond_zipper.ml", line 87, characters 8-48
  Called from Iter.find_map in file "src/Iter.ml", lines 739-744, characters 5-34
  Called from Transforms__Aslp__Diamond_ibi.Make.f_switch_context in file "lib/transforms/aslp/diamond_ibi.ml", lines 54-56, characters 4-64
  Called from Transforms__Aslp__Bincaml_ibi_make.Make.f_switch_context in file "lib/transforms/aslp/bincaml_ibi_make.ml", line 71, characters 4-29
  Called from Test_aslp__Test_aslp_ibi.(fun) in file "test/transforms/test_aslp_ibi.ml", line 152, characters 2-45
  Called from Ppx_expect_runtime__Test_block.Configured.dump_backtrace in file "runtime/test_block.ml", line 142, characters 10-28

  Trailing output
  ---------------
  make_call: entry
  make_call: t
  make_call: tt
  |}]

let%expect_test
    "pathological: referencing old branch with intervening gen_branch" =
  let module I = (val Bincaml_ibi.from_generator (Aslp_state.empty_aslp_ids ()))
  in
  guard (fun () ->
      I.bincaml_set_address (Bitvec.of_int ~size:64 0xfaf);
      let b1 = I.f_gen_branch (I.f_gen_bool_lit true) in
      I.bincaml_internal_emit (make_call "entry");

      let b2 = I.f_gen_branch (I.f_gen_bool_lit true) in
      I.bincaml_internal_emit (make_call "still_in_entry");

      I.f_switch_context (I.f_true_branch b1);
      I.bincaml_internal_emit (make_call "true_of_first_branch");

      I.f_switch_context (I.f_false_branch b2);
      I.bincaml_internal_emit (make_call "false_of_second_branch");

      I.f_switch_context (I.f_merge_branch b1);
      I.bincaml_internal_emit (make_call "end");

      guard_get_ir I.get_ir);

  [%expect
    {|
    make_call: entry
    error(Failure("invariant violation: f_gen_branch twice without switching"))
    |}]

let%expect_test
    "pathological: sequential diamonds, then going back into the first one" =
  let module I = (val Bincaml_ibi.from_generator (Aslp_state.empty_aslp_ids ()))
  in
  ( guard @@ fun () ->
    begin
      I.bincaml_set_address (Bitvec.of_int ~size:64 0xfaf);
      let b1 = I.f_gen_branch (I.f_gen_bool_lit true) in
      I.bincaml_internal_emit (make_call "entry");

      I.f_switch_context (I.f_true_branch b1);
      I.bincaml_internal_emit (make_call "b1_t");
      I.f_switch_context (I.f_merge_branch b1);

      let b2 = I.f_gen_branch (I.f_gen_bool_lit true) in
      I.f_switch_context (I.f_true_branch b2);
      I.bincaml_internal_emit (make_call "b2_t");
      I.f_switch_context (I.f_merge_branch b2);

      I.f_switch_context (I.f_true_branch b1);
      I.bincaml_internal_emit (make_call "b1_t_again");

      I.f_switch_context (I.f_merge_branch b2);
      I.bincaml_internal_emit (make_call "exit");

      guard_get_ir I.get_ir
    end );

  [%expect {|
    make_call: entry
    make_call: b1_t
    make_call: b2_t
    error(Failure("invariant violation: invalid zipper path"))
    |}]

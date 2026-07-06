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

let%expect_test "diamond bfs" =
  let d n =
    Diamond.Diamond
      {
        value = n ^ "_merge";
        pred = Leaf (n ^ "_pred");
        left = Leaf (n ^ "_left");
        right = Leaf (n ^ "_right");
      }
  in
  let main =
    Diamond.Diamond
      { value = "merge"; pred = d "pred"; left = d "left"; right = d "right" }
  in
  let zip =
    Diamond_zipper.(main |> of_diamond |> move_in_to `L |> Result.get_ok)
  in
  CCFormat.output Format.stdout (CCKTree.pp CCString.pp)
    (Diamond_zipper.Bfs_internal.to_ktree `Initial zip
    |> CCKTree.map Diamond_zipper.focus);
  [%expect
    {|
    ("left_merge"
      ("merge"
        ("right_merge"
          "right_left"
          "right_right"
          "right_pred")
        ("pred_merge"
          "pred_left"
          "pred_right"
          "pred_pred"))
      "left_left"
      "left_right"
      "left_pred")
|}];
  Diamond_zipper.iter_bfs zip |> Iter.iter (print_endline % Diamond_zipper.focus);
  [%expect
    {|
    left_merge
    merge
    left_left
    left_right
    left_pred
    right_merge
    pred_merge
    right_left
    right_right
    right_pred
    pred_left
    pred_right
    pred_pred
    |}]

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
  [%expect
    {|
    make_call: entry
    make_call: t
    make_call: f
    make_call: ft
    make_call: ff
    make_call: fm
    make_call: m
    Diamond {
      pred =
      (Leaf
         { Aslp_state.assume = true; stmts = [call entry()]; pc_assign = None });
      left =
      (Leaf
         { Aslp_state.assume = true; stmts = [call t(); $PC:bv64 := 0xaaa:bv64];
           pc_assign = (Some 0xaaa:bv64) });
      right =
      Diamond {
        pred =
        (Leaf
           { Aslp_state.assume = boolnot(true); stmts = [call f()];
             pc_assign = None });
        left =
        (Leaf
           { Aslp_state.assume = false;
             stmts = [call ft(); $PC:bv64 := 0xbbb:bv64];
             pc_assign = (Some 0xbbb:bv64) });
        right =
        (Leaf
           { Aslp_state.assume = boolnot(false);
             stmts =
             [call ff(); (var BranchTaken:bool := false, $PC:bv64 := 0xfb3:bv64)];
             pc_assign = (Some 0xfb3:bv64) });
        value =
        { Aslp_state.assume = true; stmts = [call fm()];
          pc_assign = (Some if false then 0xbbb:bv64 else 0xfb3:bv64) }};
      value =
      { Aslp_state.assume = true;
        stmts =
        [call m();
          $PC:bv64 := if true then 0xaaa:bv64 else if false then 0xbbb:bv64 else 0xfb3:bv64
          ];
        pc_assign =
        (Some if true then 0xaaa:bv64 else if false then 0xbbb:bv64 else 0xfb3:bv64)
        }}
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
  [%expect
    {|
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

let%expect_test "pc before branch" =
  let module I = (val Bincaml_ibi.from_generator (Aslp_state.empty_aslp_ids ()))
  in
  guard (fun () ->
      I.bincaml_set_address (Bitvec.of_int ~size:64 0xbadbad);
      I.bincaml_internal_emit (make_call "entry");
      I.f_gen_store I.v__PC
        (I.f_gen_bit_lit (I.bigint_of_int 64) (Bitvec.of_int ~size:64 0xaaa));
      let b1 = I.f_gen_branch (I.f_gen_bool_lit true) in

      I.f_switch_context (I.f_true_branch b1);
      I.bincaml_internal_emit (make_call "t");
      I.f_switch_context (I.f_false_branch b1);
      I.bincaml_internal_emit (make_call "f");

      I.f_switch_context (I.f_merge_branch b1);

      I.bincaml_internal_emit (make_call "exit");
      guard_get_ir I.get_ir);
  [%expect
    {|
    make_call: entry
    make_call: t
    make_call: f
    make_call: exit
    Diamond {
      pred =
      (Leaf
         { Aslp_state.assume = true;
           stmts = [call entry_2(); $PC:bv64 := 0xaaa:bv64];
           pc_assign = (Some 0xaaa:bv64) });
      left =
      (Leaf
         { Aslp_state.assume = true; stmts = [call t_1()];
           pc_assign = (Some 0xaaa:bv64) });
      right =
      (Leaf
         { Aslp_state.assume = boolnot(true); stmts = [call f_1()];
           pc_assign = (Some 0xaaa:bv64) });
      value =
      { Aslp_state.assume = true;
        stmts =
        [call exit_1(); $PC:bv64 := if true then 0xaaa:bv64 else 0xaaa:bv64];
        pc_assign = (Some if true then 0xaaa:bv64 else 0xaaa:bv64) }}
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

  [%expect
    {|
    make_call: entry
    make_call: t
    make_call: tt
    make_call: tf
    make_call: m_outer
    Diamond {
      pred =
      (Leaf
         { Aslp_state.assume = true; stmts = [call entry_3()]; pc_assign = None });
      left =
      Diamond {
        pred =
        (Leaf
           { Aslp_state.assume = true; stmts = [call t_2()]; pc_assign = None });
        left =
        (Leaf { Aslp_state.assume = true; stmts = [call tt()]; pc_assign = None });
        right =
        (Leaf
           { Aslp_state.assume = boolnot(true); stmts = [call tf()];
             pc_assign = None });
        value = { Aslp_state.assume = true; stmts = []; pc_assign = None }};
      right =
      (Leaf { Aslp_state.assume = boolnot(true); stmts = []; pc_assign = None });
      value =
      { Aslp_state.assume = true;
        stmts =
        [call m_outer(); (var BranchTaken:bool := false, $PC:bv64 := 0xfb3:bv64)];
        pc_assign = (Some 0xfb3:bv64) }}
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

  [%expect
    {|
    make_call: entry
    make_call: t
    make_call: tt
    make_call: tf
    make_call: f
    make_call: m_outer
    Diamond {
      pred =
      (Leaf
         { Aslp_state.assume = true; stmts = [call entry_4()]; pc_assign = None });
      left =
      Diamond {
        pred =
        (Leaf
           { Aslp_state.assume = true; stmts = [call t_3()]; pc_assign = None });
        left =
        (Leaf
           { Aslp_state.assume = true; stmts = [call tt_1()]; pc_assign = None });
        right =
        (Leaf
           { Aslp_state.assume = boolnot(true); stmts = [call tf_1()];
             pc_assign = None });
        value = { Aslp_state.assume = true; stmts = []; pc_assign = None }};
      right =
      (Leaf
         { Aslp_state.assume = boolnot(true); stmts = [call f_2()];
           pc_assign = None });
      value =
      { Aslp_state.assume = true;
        stmts =
        [call m_outer_1();
          (var BranchTaken:bool := false, $PC:bv64 := 0xfb3:bv64)];
        pc_assign = (Some 0xfb3:bv64) }}
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

  [%expect
    {|
    make_call: entry
    make_call: b1_t
    make_call: b2_t
    make_call: b1_t_again
    make_call: exit
    Diamond {
      pred =
      Diamond {
        pred =
        (Leaf
           { Aslp_state.assume = true; stmts = [call entry_6()]; pc_assign = None
             });
        left =
        (Leaf
           { Aslp_state.assume = true;
             stmts = [call b1_t_1(); call b1_t_again()]; pc_assign = None });
        right =
        (Leaf { Aslp_state.assume = boolnot(true); stmts = []; pc_assign = None });
        value = { Aslp_state.assume = true; stmts = []; pc_assign = None }};
      left =
      (Leaf
         { Aslp_state.assume = true; stmts = [call b2_t_1()]; pc_assign = None });
      right =
      (Leaf { Aslp_state.assume = boolnot(true); stmts = []; pc_assign = None });
      value =
      { Aslp_state.assume = true;
        stmts =
        [call exit_2(); (var BranchTaken:bool := false, $PC:bv64 := 0xfb3:bv64)];
        pc_assign = (Some 0xfb3:bv64) }}
    ok(())
    |}]

open Lang
open Common
open Transforms.Aslp

let id_gen = lazy (ID.make_gen ())

let make_call name =
  Stmt.Instr_Call
    {
      attrib = Attrib.empty;
      lhs = StringMap.empty;
      args = StringMap.empty;
      procid = (Lazy.force_val id_gen).fresh ~name ();
    }

let%expect_test "nested diamonds" =
  let module I = (val Bincaml_ibi.from_generator (Aslp_state.empty_aslp_ids ()))
  in
  I.bincaml_set_address (Bitvec.of_int ~size:64 0xbadbadbad000);
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

  print_endline @@ Aslp_state.show_aslp_diamond @@ I.get_ir ();
  [%expect
    {|
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
             [call ff();
               (var BranchTaken:bool := false, $PC:bv64 := 0xbadbadbad004:bv64)];
             pc_assign = (Some 0xbadbadbad004:bv64) });
        value =
        { Aslp_state.assume = true; stmts = [call fm()];
          pc_assign = (Some if false then 0xbbb:bv64 else 0xbadbadbad004:bv64) }};
      value =
      { Aslp_state.assume = true; stmts = [call m()];
        pc_assign =
        (Some if true then 0xaaa:bv64 else if false then 0xbbb:bv64 else 0xbadbadbad004:bv64)
        }}
    |}]

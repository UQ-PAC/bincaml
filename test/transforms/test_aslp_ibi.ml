open Lang
open Common
open Transforms.Aslp

let%expect_test "nested diamonds" =
  let module I = (val Bincaml_ibi.from_generator (Aslp_state.empty_aslp_ids ()))
  in
  I.bincaml_set_address (Bitvec.of_int ~size:64 0xbadbadbad000);
  let branch1 = I.f_gen_branch (I.f_gen_bool_lit true) in
  I.f_gen_assert (I.f_gen_bool_lit true);

  I.f_switch_context (I.f_true_branch branch1);
  I.f_gen_store I.v__PC
    (I.f_gen_bit_lit (I.bigint_of_int 64) (Bitvec.of_int ~size:64 0xaaa));

  I.f_switch_context (I.f_false_branch branch1);
  begin
    let branch2 = I.f_gen_branch (I.f_gen_bool_lit false) in
    I.f_switch_context (I.f_true_branch branch2);
    I.f_gen_store I.v__PC
      (I.f_gen_bit_lit (I.bigint_of_int 64) (Bitvec.of_int ~size:64 0xbbb));
    I.f_switch_context (I.f_false_branch branch2);
    I.f_switch_context (I.f_merge_branch branch2)
  end;

  I.f_switch_context (I.f_merge_branch branch1);

  print_endline @@ Aslp_state.show_aslp_diamond @@ I.get_ir ();
  [%expect
    {|
    { Aslp_state.address = 0xbadbadbad000:bv64;
      blocks = "block_0"
      -> { Aslp_state.assume = None; stmts = [assert true];
           succs = ["block_1"; "block_2"]; pc_assign = None },
      "block_1"
      -> { Aslp_state.assume = (Some true); stmts = [$PC:bv64 := 0xaaa:bv64];
           succs = ["block_3"]; pc_assign = (Some 0xaaa:bv64) },
      "block_2"
      -> { Aslp_state.assume = (Some boolnot(true));
           stmts =
           [(var BranchTaken:bool := false, $PC:bv64 := 0xbadbadbad004:bv64)];
           succs = ["block_4"; "block_5"]; pc_assign = (Some 0xbadbadbad004:bv64)
           },
      "block_3"
      -> { Aslp_state.assume = None; stmts = []; succs = [];
           pc_assign = (Some if true then 0xaaa:bv64 else 0xbadbadbad004:bv64) },
      "block_4"
      -> { Aslp_state.assume = (Some false); stmts = [$PC:bv64 := 0xbbb:bv64];
           succs = ["block_6"]; pc_assign = (Some 0xbbb:bv64) },
      "block_5"
      -> { Aslp_state.assume = (Some boolnot(false));
           stmts =
           [(var BranchTaken:bool := false, $PC:bv64 := 0xbadbadbad004:bv64)];
           succs = ["block_6"]; pc_assign = (Some 0xbadbadbad004:bv64) },
      "block_6"
      -> { Aslp_state.assume = None; stmts = []; succs = ["block_3"];
           pc_assign = (Some if false then 0xbbb:bv64 else 0xbadbadbad004:bv64) };
      entry = "block_0"; exit = "block_3" }
    |}]

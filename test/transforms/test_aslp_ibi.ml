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
  I.f_gen_assert (I.f_gen_bool_lit false);

  print_endline @@ Aslp_state.show_aslp_diamond @@ I.get_ir ();
  [%expect
    {|
    (Diamond {
       value =
       { Aslp_state.assume = None; stmts = [assert true]; pc_assign = None };
       left =
       (Leaf { Aslp_state.assume = (Some true); stmts = []; pc_assign = None });
       right =
       (Leaf
          { Aslp_state.assume = (Some boolnot(true)); stmts = [];
            pc_assign = None });
       merge = (Leaf { Aslp_state.assume = None; stmts = []; pc_assign = None })},
     [])
    t
    ((Leaf { Aslp_state.assume = (Some true); stmts = []; pc_assign = None }),
     [Left {
        value =
        { Aslp_state.assume = None; stmts = [assert true]; pc_assign = None };
        right =
        (Leaf
           { Aslp_state.assume = (Some boolnot(true)); stmts = [];
             pc_assign = None });
        merge = (Leaf { Aslp_state.assume = None; stmts = []; pc_assign = None })}
       ])


    ((Leaf
        { Aslp_state.assume = (Some true); stmts = [$PC:bv64 := 0xaaa:bv64];
          pc_assign = (Some 0xaaa:bv64) }),
     [Left {
        value =
        { Aslp_state.assume = None; stmts = [assert true]; pc_assign = None };
        right =
        (Leaf
           { Aslp_state.assume = (Some boolnot(true)); stmts = [];
             pc_assign = None });
        merge = (Leaf { Aslp_state.assume = None; stmts = []; pc_assign = None })}
       ])
    f
    ((Leaf
        { Aslp_state.assume = (Some boolnot(true)); stmts = []; pc_assign = None
          }),
     [Right {
        value =
        { Aslp_state.assume = None; stmts = [assert true]; pc_assign = None };
        left =
        (Leaf
           { Aslp_state.assume = (Some true); stmts = [$PC:bv64 := 0xaaa:bv64];
             pc_assign = (Some 0xaaa:bv64) });
        merge = (Leaf { Aslp_state.assume = None; stmts = []; pc_assign = None })}
       ])


    (Diamond {
       value =
       { Aslp_state.assume = (Some boolnot(true)); stmts = []; pc_assign = None };
       left =
       (Leaf { Aslp_state.assume = (Some false); stmts = []; pc_assign = None });
       right =
       (Leaf
          { Aslp_state.assume = (Some boolnot(false)); stmts = [];
            pc_assign = None });
       merge = (Leaf { Aslp_state.assume = None; stmts = []; pc_assign = None })},
     [Right {
        value =
        { Aslp_state.assume = None; stmts = [assert true]; pc_assign = None };
        left =
        (Leaf
           { Aslp_state.assume = (Some true); stmts = [$PC:bv64 := 0xaaa:bv64];
             pc_assign = (Some 0xaaa:bv64) });
        merge = (Leaf { Aslp_state.assume = None; stmts = []; pc_assign = None })}
       ])
    t
    ((Leaf { Aslp_state.assume = (Some false); stmts = []; pc_assign = None }),
     [Left {
        value =
        { Aslp_state.assume = (Some boolnot(true)); stmts = []; pc_assign = None
          };
        right =
        (Leaf
           { Aslp_state.assume = (Some boolnot(false)); stmts = [];
             pc_assign = None });
        merge = (Leaf { Aslp_state.assume = None; stmts = []; pc_assign = None })};
       Right {
         value =
         { Aslp_state.assume = None; stmts = [assert true]; pc_assign = None };
         left =
         (Leaf
            { Aslp_state.assume = (Some true); stmts = [$PC:bv64 := 0xaaa:bv64];
              pc_assign = (Some 0xaaa:bv64) });
         merge =
         (Leaf { Aslp_state.assume = None; stmts = []; pc_assign = None })}
       ])


    ((Leaf
        { Aslp_state.assume = (Some false); stmts = [$PC:bv64 := 0xbbb:bv64];
          pc_assign = (Some 0xbbb:bv64) }),
     [Left {
        value =
        { Aslp_state.assume = (Some boolnot(true)); stmts = []; pc_assign = None
          };
        right =
        (Leaf
           { Aslp_state.assume = (Some boolnot(false)); stmts = [];
             pc_assign = None });
        merge = (Leaf { Aslp_state.assume = None; stmts = []; pc_assign = None })};
       Right {
         value =
         { Aslp_state.assume = None; stmts = [assert true]; pc_assign = None };
         left =
         (Leaf
            { Aslp_state.assume = (Some true); stmts = [$PC:bv64 := 0xaaa:bv64];
              pc_assign = (Some 0xaaa:bv64) });
         merge =
         (Leaf { Aslp_state.assume = None; stmts = []; pc_assign = None })}
       ])
    f
    ((Leaf
        { Aslp_state.assume = (Some boolnot(false)); stmts = []; pc_assign = None
          }),
     [Right {
        value =
        { Aslp_state.assume = (Some boolnot(true)); stmts = []; pc_assign = None
          };
        left =
        (Leaf
           { Aslp_state.assume = (Some false); stmts = [$PC:bv64 := 0xbbb:bv64];
             pc_assign = (Some 0xbbb:bv64) });
        merge = (Leaf { Aslp_state.assume = None; stmts = []; pc_assign = None })};
       Right {
         value =
         { Aslp_state.assume = None; stmts = [assert true]; pc_assign = None };
         left =
         (Leaf
            { Aslp_state.assume = (Some true); stmts = [$PC:bv64 := 0xaaa:bv64];
              pc_assign = (Some 0xaaa:bv64) });
         merge =
         (Leaf { Aslp_state.assume = None; stmts = []; pc_assign = None })}
       ])


    ((Leaf
        { Aslp_state.assume = (Some boolnot(false)); stmts = []; pc_assign = None
          }),
     [Right {
        value =
        { Aslp_state.assume = (Some boolnot(true)); stmts = []; pc_assign = None
          };
        left =
        (Leaf
           { Aslp_state.assume = (Some false); stmts = [$PC:bv64 := 0xbbb:bv64];
             pc_assign = (Some 0xbbb:bv64) });
        merge = (Leaf { Aslp_state.assume = None; stmts = []; pc_assign = None })};
       Right {
         value =
         { Aslp_state.assume = None; stmts = [assert true]; pc_assign = None };
         left =
         (Leaf
            { Aslp_state.assume = (Some true); stmts = [$PC:bv64 := 0xaaa:bv64];
              pc_assign = (Some 0xaaa:bv64) });
         merge =
         (Leaf { Aslp_state.assume = None; stmts = []; pc_assign = None })}
       ])
    m
    ((Leaf
        { Aslp_state.assume = None; stmts = [];
          pc_assign = (Some if false then 0xbbb:bv64 else 0xbadbadbad004:bv64) }),
     [Merge {
        value =
        { Aslp_state.assume = (Some boolnot(true)); stmts = []; pc_assign = None
          };
        left =
        (Leaf
           { Aslp_state.assume = (Some false); stmts = [$PC:bv64 := 0xbbb:bv64];
             pc_assign = (Some 0xbbb:bv64) });
        right =
        (Leaf
           { Aslp_state.assume = (Some boolnot(false));
             stmts =
             [(var BranchTaken:bool := false, $PC:bv64 := 0xbadbadbad004:bv64)];
             pc_assign = (Some 0xbadbadbad004:bv64) })};
       Right {
         value =
         { Aslp_state.assume = None; stmts = [assert true]; pc_assign = None };
         left =
         (Leaf
            { Aslp_state.assume = (Some true); stmts = [$PC:bv64 := 0xaaa:bv64];
              pc_assign = (Some 0xaaa:bv64) });
         merge =
         (Leaf { Aslp_state.assume = None; stmts = []; pc_assign = None })}
       ])


    ((Leaf
        { Aslp_state.assume = None; stmts = [];
          pc_assign = (Some if false then 0xbbb:bv64 else 0xbadbadbad004:bv64) }),
     [Merge {
        value =
        { Aslp_state.assume = (Some boolnot(true)); stmts = []; pc_assign = None
          };
        left =
        (Leaf
           { Aslp_state.assume = (Some false); stmts = [$PC:bv64 := 0xbbb:bv64];
             pc_assign = (Some 0xbbb:bv64) });
        right =
        (Leaf
           { Aslp_state.assume = (Some boolnot(false));
             stmts =
             [(var BranchTaken:bool := false, $PC:bv64 := 0xbadbadbad004:bv64)];
             pc_assign = (Some 0xbadbadbad004:bv64) })};
       Right {
         value =
         { Aslp_state.assume = None; stmts = [assert true]; pc_assign = None };
         left =
         (Leaf
            { Aslp_state.assume = (Some true); stmts = [$PC:bv64 := 0xaaa:bv64];
              pc_assign = (Some 0xaaa:bv64) });
         merge =
         (Leaf { Aslp_state.assume = None; stmts = []; pc_assign = None })}
       ])
    m
    ((Leaf
        { Aslp_state.assume = None; stmts = [];
          pc_assign = (Some if false then 0xbbb:bv64 else 0xbadbadbad004:bv64) }),
     [Merge {
        value =
        { Aslp_state.assume = (Some boolnot(true)); stmts = []; pc_assign = None
          };
        left =
        (Leaf
           { Aslp_state.assume = (Some false); stmts = [$PC:bv64 := 0xbbb:bv64];
             pc_assign = (Some 0xbbb:bv64) });
        right =
        (Leaf
           { Aslp_state.assume = (Some boolnot(false));
             stmts =
             [(var BranchTaken:bool := false, $PC:bv64 := 0xbadbadbad004:bv64)];
             pc_assign = (Some 0xbadbadbad004:bv64) })};
       Right {
         value =
         { Aslp_state.assume = None; stmts = [assert true]; pc_assign = None };
         left =
         (Leaf
            { Aslp_state.assume = (Some true); stmts = [$PC:bv64 := 0xaaa:bv64];
              pc_assign = (Some 0xaaa:bv64) });
         merge =
         (Leaf { Aslp_state.assume = None; stmts = []; pc_assign = None })}
       ])


    Diamond {
      value =
      { Aslp_state.assume = None; stmts = [assert true]; pc_assign = None };
      left =
      (Leaf
         { Aslp_state.assume = (Some true); stmts = [$PC:bv64 := 0xaaa:bv64];
           pc_assign = (Some 0xaaa:bv64) });
      right =
      Diamond {
        value =
        { Aslp_state.assume = (Some boolnot(true)); stmts = []; pc_assign = None
          };
        left =
        (Leaf
           { Aslp_state.assume = (Some false); stmts = [$PC:bv64 := 0xbbb:bv64];
             pc_assign = (Some 0xbbb:bv64) });
        right =
        (Leaf
           { Aslp_state.assume = (Some boolnot(false));
             stmts =
             [(var BranchTaken:bool := false, $PC:bv64 := 0xbadbadbad004:bv64)];
             pc_assign = (Some 0xbadbadbad004:bv64) });
        merge =
        (Leaf
           { Aslp_state.assume = None; stmts = [assert false];
             pc_assign = (Some if false then 0xbbb:bv64 else 0xbadbadbad004:bv64)
             })};
      merge = (Leaf { Aslp_state.assume = None; stmts = []; pc_assign = None })}
    |}]

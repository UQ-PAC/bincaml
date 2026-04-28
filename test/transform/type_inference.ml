open Bincaml_util.Common
open Transforms.Type_inference
open ConstraintState
open ConstraintState.TypeConstraint
open InferredType

let gen = ID.make_gen ()

let%test_unit "Add bounds" =
  let st = VarIdMap.empty in
  let st = add_ub st (VarId.make_id "c") Top in
  let st = add_lb st (VarId.make_id "c") Bottom in
  let st = add_lb st (VarId.make_id "d") @@ TypeVar (VarId.make_id "e") in
  let st = add_ub st (VarId.make_id "d") @@ Bool in

  let ls =
    [
      ( VarId.make_id "c",
        { ub = TySet.singleton Top; lb = TySet.singleton Bottom } );
      ( VarId.make_id "d",
        {
          lb = TySet.singleton @@ TypeVar (VarId.make_id "e");
          ub = TySet.singleton @@ Bool;
        } );
    ]
  in
  let st2 = VarIdMap.of_list ls in
  assert (ConstraintState.equal st st2)

let%test_unit "Constraint generation - Simple Cascading" =
  (*
    ```
    var a : bv1 := b : bv1;
    var b : bv1 := c : bv1;
    var c : bv1 := true;
    ```
    
    b <= a
    c <= b, therefore c <= a

    a: lower = [bool, bv1],    upper = []
    b: lower = [bool, bv1],    upper = [a]
    c: lower = [bool, bv1],    upper = [b]
  *)
  let block =
    {|
memory shared $mem : (bv64 -> bv8);
var $XF: bv1;
var $YF: bv1;
var $ZF: bv1;

prog entry @main_4196260;

proc @main_4196260 () -> ()
[
  block %main_entry [
    $XF:bv1 := $YF:bv1;
    $YF:bv1 := $ZF:bv1;
    $ZF:bv1 := true;
    goto(%main_basil_return_1);
  ];
  block %main_basil_return_1 [
    return ();
  ]
];

    |}
  in
  let lst =
    Loader.Loadir.ast_of_string ~__LINE__ ~__FILE__ ~__FUNCTION__ block
  in
  let prog = lst.prog in

  let st = generate_constraints prog in

  let ls =
    [
      ( VarId.make_id "$XF",
        { lb = TySet.of_list [ Bool; BV 1 ]; ub = TySet.empty } );
      ( VarId.make_id "$YF",
        {
          lb = TySet.of_list [ Bool; BV 1 ];
          ub = TySet.singleton @@ TypeVar (VarId.make_id "$XF");
        } );
      ( VarId.make_id "$ZF",
        {
          lb = TySet.of_list [ Bool; BV 1 ];
          ub = TySet.singleton @@ TypeVar (VarId.make_id "$YF");
        } );
    ]
  in
  let st2 = VarIdMap.of_list ls in
  assert (ConstraintState.equal st st2)

let%test_unit "Simple Record" =
  (*
    ```
    var record : bv64 := 0x2 : bv64;
    var field1 : bv32 := extract(32, 0 , record : bv64);
    var field2 : bv32 := extract(64, 32, record : bv64);
    ```

    field1 <= alpha
    record <= {(0, 32) : alpha}
    field1 <= beta
    record <= {(32, 32) : beta}

    field1: lower = [bv32, alpha],    upper = []
    field2: lower = [bv32, beta ],    upper = []
    record: lower = [bv64, {(0,32): alpha, (32,32): beta} ],    upper = []
    
    
  *)
  let block =
    {|
memory shared $mem : (bv64 -> bv8);
var $record : bv64;
var $field1 : bv32;
var $field2 : bv32;

prog entry @main_4196260;

proc @main_4196260 () -> ()
[
  block %main_entry [
    $record : bv64 := 0x2 : bv64;
    $field1 : bv32 := extract(32, 0, $record : bv64);
    $field2 : bv32 := extract(64, 32, $record : bv64);
    goto(%main_basil_return_1);
  ];
  block %main_basil_return_1 [
    return ();
  ]
];

    |}
  in
  let lst =
    Loader.Loadir.ast_of_string ~__LINE__ ~__FILE__ ~__FUNCTION__ block
  in
  let prog = lst.prog in

  let st = generate_constraints prog in

  let field1 = TypeVar (VarId.make_id "Extraction_v") in
  let field2 = TypeVar (VarId.make_id "Extraction_v_1") in

  let record1 =
    Record
      (ZMap.singleton Z.zero { offset = Z.zero; size = 32; ty = field1 }, 64)
  in
  let record2 =
    Record
      ( ZMap.singleton (Z.of_int 32)
          { offset = Z.of_int 32; size = 32; ty = field2 },
        64 )
  in

  let ls =
    [
      ( VarId.make_id "$record",
        { lb = TySet.of_list [ BV 64; record1; record2 ]; ub = TySet.empty } );
      ( VarId.make_id "$field1",
        { lb = TySet.of_list [ BV 32 ]; ub = TySet.empty } );
      ( VarId.make_id "$field2",
        { lb = TySet.of_list [ BV 32 ]; ub = TySet.empty } );
      ( VarId.make_id "Extraction_v",
        {
          lb = TySet.of_list [ BV 32 ];
          ub = TySet.singleton (TypeVar (VarId.make_id "$field1"));
        } );
      ( VarId.make_id "Extraction_v_1",
        {
          lb = TySet.of_list [ BV 32 ];
          ub = TySet.singleton (TypeVar (VarId.make_id "$field2"));
        } );
    ]
  in
  let st2 = VarIdMap.of_list ls in
  assert (ConstraintState.equal st st2);

  let st = unconstrain_types st in
  let fields1 : InferredType.field ZMap.t =
    ZMap.of_list
      [
        ( Z.zero,
          ({
             offset = Z.zero;
             ty = Sect (Sect (field1, BV 32), BV 32);
             size = 32;
           }
            : InferredType.field) );
      ]
  in
  let fields2 : InferredType.field ZMap.t =
    ZMap.of_list
      [
        ( Z.of_int 32,
          {
            offset = Z.of_int 32;
            ty = Sect (Sect (field2, BV 32), BV 32);
            size = 32;
          } );
      ]
  in
  let record =
    Sect (Sect (InferredType.Record (fields1, 64), Record (fields2, 64)), BV 64)
  in
  let ls =
    [
      (VarId.make_id "$record", (record, Top));
      (VarId.make_id "$field1", (BV 32, Top));
      (VarId.make_id "$field2", (BV 32, Top));
      (VarId.make_id "Extraction_v", (BV 32, TypeVar (VarId.make_id "$field1")));
      ( VarId.make_id "Extraction_v_1",
        (BV 32, TypeVar (VarId.make_id "$field2")) );
    ]
  in
  let st2 = VarIdMap.of_list ls in

  assert (
    VarIdMap.equal
      (fun (a1, b1) (a2, b2) ->
        InferredType.equal a1 a2 && InferredType.equal b1 b2)
      st st2);

  let fields : Types.record_field StringMap.t =
    StringMap.of_list
      [
        ( "field0",
          ({ offset = Z.zero; typ = Types.Bitvector 32 } : Types.record_field)
        );
        ("field32", { offset = Z.of_int 32; typ = Types.Bitvector 32 });
      ]
  in

  let types =
    [
      (VarId.make_id "$field1", (Types.Top, Types.Bitvector 32));
      (VarId.make_id "$field2", (Types.Top, Types.Bitvector 32));
      ( VarId.make_id "$record",
        (Top, Types.Struct { name = "rec507745169"; fields; size = 64 }) );
      (VarId.make_id "Extraction_v", (Top, Types.Bitvector 32));
      (VarId.make_id "Extraction_v_1", (Top, Types.Bitvector 32));
    ]
  in

  assert (
    List.equal
      (* Accidently wrote the test the wrong way *)
      (fun (_, (ty, _)) (_, (_, ty2)) ->
        (* print_endline @@ Types.show ty; *)
        (* print_endline @@ Types.show ty2; *)
        Types.equal ty ty2)
      (snd @@ simplify_types st)
      types)

let%test_unit "Record joining" =
  let fields1 =
    [
      (Z.zero, { offset = Z.zero; size = 32; ty = TypeVar (VarId.make_id "a") });
      ( Z.of_int 32,
        { offset = Z.of_int 32; size = 32; ty = TypeVar (VarId.make_id "b") } );
    ]
  in
  let fields2 =
    [
      (Z.zero, { offset = Z.zero; size = 32; ty = TypeVar (VarId.make_id "c") });
      ( Z.of_int 64,
        { offset = Z.of_int 64; size = 32; ty = TypeVar (VarId.make_id "d") } );
    ]
  in
  let record1 = Record (ZMap.of_list fields1, 96) in
  let record2 = Record (ZMap.of_list fields2, 96) in
  let joined_record = Union (record1, record2) in

  let m =
    TypeAutomata.type_to_automata Polarity.Pos joined_record
      (Polarity.Pos, joined_record)
      "meow"
    |> TypeAutomata.simplify_automata
  in
  let fields =
    [
      (Z.zero, { offset = Z.zero; size = 32; ty = TypeVar (VarId.make_id "a") });
      ( Z.of_int 32,
        { offset = Z.of_int 32; size = 32; ty = TypeVar (VarId.make_id "b") } );
      ( Z.of_int 64,
        { offset = Z.of_int 64; size = 32; ty = TypeVar (VarId.make_id "d") } );
    ]
  in
  let actual = InferredType.Record (ZMap.of_list fields, 96) in
  assert (InferredType.equal actual @@ TypeAutomata.automata_to_type m)

let%test_unit "BinSub type ADT" =
  (*
    μα.α⊓stack_slot_2⊓ptr(a,{(4,4):b⊓(t1⊓α)})⊓ptr(c,{(0,4):d⊓(t2⊓int32)})⊓ptr({(0,4):e⊔int32, f)
  *)
  let alpha = VarId.make_id "alpha" in
  let stack_slot_2 = TypeVar (VarId.make_id "stack_slot_2") in
  let a = TypeVar (VarId.make_id "a") in
  let b = TypeVar (VarId.make_id "b") in
  let c = TypeVar (VarId.make_id "c") in
  let d = TypeVar (VarId.make_id "d") in
  let e = TypeVar (VarId.make_id "e") in
  let f = TypeVar (VarId.make_id "f") in
  let t1 = TypeVar (VarId.make_id "t1") in
  let t2 = TypeVar (VarId.make_id "t2") in
  let int32 = BV 32 in

  let fields1 =
    { offset = Z.of_int 4; size = 4; ty = Sect (b, Sect (t1, TypeVar alpha)) }
  in
  let fields2 =
    { offset = Z.zero; size = 4; ty = Sect (d, Sect (t2, int32)) }
  in
  let fields3 = { offset = Z.zero; size = 4; ty = Union (e, int32) } in
  let record1 = Record (ZMap.singleton (Z.of_int 4) fields1, 8) in
  let record2 = Record (ZMap.singleton Z.zero fields2, 8) in
  let record3 = Record (ZMap.singleton Z.zero fields3, 8) in

  let pointer1 = Pointer (a, record1) in
  let pointer2 = Pointer (c, record2) in
  let pointer3 = Pointer (record3, f) in

  let joined_type =
    Recursive
      (alpha, Union (stack_slot_2, Union (pointer1, Union (pointer2, pointer3))))
  in

  let m =
    TypeAutomata.type_to_automata Polarity.Neg joined_type
      (Polarity.Neg, joined_type)
      "stack_slot_1"
    |> TypeAutomata.simplify_automata
  in
  let res =
    Pointer
      ( Record
          ( ZMap.singleton Z.zero
              { offset = Z.zero; size = 4; ty = Union (e, BV 32) },
            8 ),
        Record
          ( ZMap.of_list
              [
                ( Z.zero,
                  { offset = Z.zero; size = 4; ty = Sect (d, Sect (t2, BV 32)) }
                );
                ( Z.of_int 4,
                  {
                    offset = Z.of_int 4;
                    size = 4;
                    ty = Sect (b, Sect (t1, TypeVar alpha));
                  } );
              ],
            8 ) )
  in
  assert (InferredType.equal res @@ TypeAutomata.automata_to_type m)

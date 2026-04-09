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
  let st = add_ub st (VarId.make_id "d") @@ BinCamlType BinCaml_Bool in

  let ls =
    [
      ( VarId.make_id "c",
        { ub = TySet.singleton Top; lb = TySet.singleton Bottom } );
      ( VarId.make_id "d",
        {
          lb = TySet.singleton @@ TypeVar (VarId.make_id "e");
          ub = TySet.singleton @@ BinCamlType BinCaml_Bool;
        } );
    ]
  in
  let st2 = VarIdMap.of_list ls in
  assert (ConstraintState.equal st st2)

let%test_unit "Basic consistent constraint set" =
  (*
    var a = b;
    var b = c;
    var c = true;

    b <= a
    c <= b

    c <= a

    a: lower = [bool], upper = []
    b: lower = [bool],     upper = [a]
    c: lower = [bool],    upper = [b]
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
    $ZF:bv1 := eq(true, true);
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

  let st =
    IDMap.values prog.procs
    |> Iter.fold
         (fun acc proc ->
           let sva = Analysis.Sva.DFGAnalysis.flow_insensitive proc in
           Lang.Procedure.iter_blocks_topo_fwd proc
           |> Iter.fold
                (fun acc (_, b) ->
                  Lang.Block.stmts_iter b
                  |> Iter.foldi (constrain_stmt prog (Some proc) sva) acc)
                acc)
         VarIdMap.empty
  in

  let ls =
    [
      ( VarId.make_id "$XF",
        {
          lb =
            TySet.of_list
              [ BinCamlType BinCaml_Bool; BinCamlType (BinCaml_BV 1) ];
          ub = TySet.empty;
        } );
      ( VarId.make_id "$YF",
        {
          lb =
            TySet.of_list
              [ BinCamlType BinCaml_Bool; BinCamlType (BinCaml_BV 1) ];
          ub = TySet.singleton @@ TypeVar (VarId.make_id "$XF");
        } );
      ( VarId.make_id "$ZF",
        {
          lb =
            TySet.of_list
              [ BinCamlType BinCaml_Bool; BinCamlType (BinCaml_BV 1) ];
          ub = TySet.singleton @@ TypeVar (VarId.make_id "$YF");
        } );
    ]
  in
  let st2 = VarIdMap.of_list ls in
  assert (ConstraintState.equal st st2)

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
  let record1 = Record (ZMap.of_list fields1) in
  let record2 = Record (ZMap.of_list fields2) in
  let joined_record = Union (record1, record2) in

  let m =
    TypeAutomata.type_to_automata Polarity.Pos joined_record
      (Polarity.Pos, joined_record)
      "meow"
    |> TypeAutomata.simplify_automata
  in
  let fields =
    [
      (Z.zero, { offset = Z.zero; size = 32; ty = Top });
      ( Z.of_int 32,
        { offset = Z.of_int 32; size = 32; ty = TypeVar (VarId.make_id "b") } );
      ( Z.of_int 64,
        { offset = Z.of_int 64; size = 32; ty = TypeVar (VarId.make_id "d") } );
    ]
  in
  let actual = InferredType.Record (ZMap.of_list fields) in
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
  let int32 = BinCamlType (BinCaml_BV 32) in

  let fields1 =
    { offset = Z.of_int 4; size = 4; ty = Sect (b, Sect (t1, TypeVar alpha)) }
  in
  let fields2 =
    { offset = Z.zero; size = 4; ty = Sect (d, Sect (t2, int32)) }
  in
  let fields3 = { offset = Z.zero; size = 4; ty = Union (e, int32) } in
  let record1 = Record (ZMap.singleton (Z.of_int 4) fields1) in
  let record2 = Record (ZMap.singleton Z.zero fields2) in
  let record3 = Record (ZMap.singleton Z.zero fields3) in

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
          (ZMap.singleton Z.zero
             {
               offset = Z.zero;
               size = 4;
               ty = Union (e, BinCamlType (BinCaml_BV 32));
             }),
        Record
          (ZMap.of_list
             [
               ( Z.zero,
                 {
                   offset = Z.zero;
                   size = 4;
                   ty = Sect (d, Sect (t2, BinCamlType (BinCaml_BV 32)));
                 } );
               ( Z.of_int 4,
                 {
                   offset = Z.of_int 4;
                   size = 4;
                   ty = Sect (b, Sect (t1, TypeVar alpha));
                 } );
             ]) )
  in
  assert (InferredType.equal res @@ TypeAutomata.automata_to_type m)

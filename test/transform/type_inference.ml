open Bincaml_util.Common
open Transforms.Type_inference
open Transforms.Type_automata
open Transforms.Asd
open ConstraintState
open ConstraintState.TypeConstraint
open InferredType

let gen = ID.make_gen ()

let%test_unit "add bounds" =
  let st = StringMap.empty in
  let st = add_ub st "c" Top in
  let st = add_lb st "c" Bottom in
  let st = add_lb st "d" @@ TypeVar "e" in
  let st = add_ub st "d" @@ Atom C_Bool in

  let ls =
    [
      ("c", { ub = TySet.singleton Top; lb = TySet.singleton Bottom });
      ( "d",
        {
          lb = TySet.singleton @@ TypeVar "e";
          ub = TySet.singleton @@ Atom C_Bool;
        } );
    ]
  in
  let st2 = StringMap.of_list ls in
  assert (ConstraintState.equal st st2)

let%test_unit "basic consistent constraint set" =
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
    ID.Map.values prog.procs |> Iter.fold (check_proc prog) StringMap.empty
  in
  let ls =
    [
      ( "@main_4196260_$XF",
        { lb = TySet.singleton @@ Atom C_Bool; ub = TySet.empty } );
      ( "@main_4196260_$YF",
        {
          lb = TySet.singleton @@ Atom C_Bool;
          ub = TySet.singleton @@ TypeVar "@main_4196260_$XF";
        } );
      ( "@main_4196260_$ZF",
        {
          lb = TySet.singleton @@ Atom C_Bool;
          ub = TySet.singleton @@ TypeVar "@main_4196260_$YF";
        } );
    ]
  in
  let st2 = StringMap.of_list ls in
  assert (ConstraintState.equal st st2)

let%test_unit "Yippie" =
  let fields1 =
    [
      { offset = 0; size = 32; ty = TypeVar "a" };
      { offset = 32; size = 32; ty = TypeVar "b" };
    ]
  in
  let fields2 =
    [
      { offset = 0; size = 32; ty = TypeVar "c" };
      { offset = 64; size = 32; ty = TypeVar "d" };
    ]
  in
  let record1 = Record fields1 in
  let record2 = Record fields2 in
  let joined_record = Union (record1, record2) in

  let m = minimise_type Polarity.Pos joined_record "meow" in
  print_string @@ TypeAutomata.export_graphviz m;
  assert true

let%test_unit "BinSub type ADT" =
  (*
    μα.α⊓stack_slot_2⊓ptr(a,{(4,4):b⊓(t1⊓α)})⊓ptr(c,{(0,4):d⊓(t2⊓int32)})⊓ptr({(0,4):e⊔int32, f )
  *)
  let alpha = TypeVar "alpha" in
  let stack_slot_2 = TypeVar "stack_slot_2" in
  let a = TypeVar "a" in
  let b = TypeVar "b" in
  let c = TypeVar "c" in
  let d = TypeVar "d" in
  let e = TypeVar "e" in
  let f = TypeVar "f" in
  let t1 = TypeVar "t1" in
  let t2 = TypeVar "t2" in
  let int32 = Atom (C_BV 32) in

  let fields1 = [ { offset = 4; size = 4; ty = Sect (b, Sect (t1, alpha)) } ] in
  let fields2 = [ { offset = 0; size = 4; ty = Sect (d, Sect (t2, int32)) } ] in
  let fields3 = [ { offset = 0; size = 4; ty = Union (e, int32) } ] in
  let record1 = Record fields1 in
  let record2 = Record fields2 in
  let record3 = Record fields3 in

  let recursive_type = Recursive (alpha, alpha) in
  let pointer1 = Pointer (a, record1) in
  let pointer2 = Pointer (c, record2) in
  let pointer3 = Pointer (record3, f) in

  let joined_type =
    Union
      ( recursive_type,
        Union (stack_slot_2, Union (pointer1, Union (pointer2, pointer3))) )
  in

  let m = minimise_type Polarity.Neg joined_type "stack_slot_1" in
  print_string @@ TypeAutomata.export_graphviz m;
  assert true

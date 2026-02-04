open Bincaml_util.Common
open Transforms.Type_inference

let gen = ID.make_gen ()

let%test_unit "add bounds" =
  let st = StringMap.empty in
  let st = add_ub st "c" Top in
  let st = add_lb st "c" Bottom in
  let st = add_lb st "d" @@ TypeVar "hi friends" in
  let st = add_ub st "d" @@ Atom C_Bool in

  let ls =
    [
      ("c", { ub = TySet.singleton Top; lb = TySet.singleton Bottom });
      ( "d",
        {
          lb = TySet.singleton @@ TypeVar "hi friends";
          ub = TySet.singleton @@ Atom C_Bool;
        } );
    ]
  in
  let st2 = StringMap.of_list ls in
  assert (StringMap.equal constraint_state_equals st st2)

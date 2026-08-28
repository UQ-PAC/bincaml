(** Type inference functions for hindley-milner, independent of specific typed
    language *)

module Hm_types = Hm_types
module Solve_bv = Solve_bv
module Unification = Unification
module TypeExpr = TypeExpr
open Common
open TypeExpr

(** Partially apply args list to function type funtype and return resulting type
*)
let type_applied (funtype : Types.t) (args : Types.t list) =
  let st = create_state () in
  let rt = TypeExpr.fix st @@ Var (st.gen.fresh ~name:"ret" ()) in
  let args = List.map (Hm_types.ty_of_basil st) args in

  let funt = Hm_types.curry_f st args rt in
  let ft = Hm_types.ty_of_basil st funtype in
  try
    Unification.unify st ~pos:[%here] ft funt |> ignore;
    Ok (Hm_types.to_basil rt)
  with Hm_types.TypeErr e -> Error e

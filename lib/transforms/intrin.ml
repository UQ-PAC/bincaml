open Lang
open Common
open Stmt.Intrinsic

(** How procedures are selected *)
type name =
  | ProcName of string
  | NameAttrib of string
  | HasAttrib of Attrib.attrib_map

let name_attrib_key = ".name"

type ispec = {
  names : name list;  (** procedures to apply to *)
  in_args : string list;  (** captures & modifies & in params to use in order *)
  out_args : string list;
      (** modifies (must be in-params also) & out params to use in order *)
  intrin : Stmt.Intrinsic.t;  (** the intrin to generatre *)
}
(** Specification for replacement of functions by intrinsics *)

open struct
  module LOM = List.Traverse (Option)
end

(** try to instantiate intrin parameters for a given call *)
let spec_to_func { in_args; out_args; intrin } lhs rhs p =
  let spec = Procedure.specification p in
  let modifies =
    spec.modifies_globs
    |> List.map (fun v -> (Var.name v, v))
    |> StringMap.of_list
  in
  let captures =
    spec.captures_globs
    |> List.map (fun v -> (Var.name v, v))
    |> StringMap.of_list
  in
  let lookup_in n =
    Option.or_ (StringMap.find_opt n rhs)
      ~else_:(StringMap.find_opt n captures |> Option.map Expr.BasilExpr.rvar)
  in
  let lookup_out n =
    Option.or_ (StringMap.find_opt n lhs) ~else_:(StringMap.find_opt n modifies)
  in
  let open Option in
  let* n_args = LOM.map_m lookup_in in_args in
  let* n_lhs = LOM.map_m lookup_out out_args in
  let hvoc =
    Iter.append (modifies |> StringMap.values) (lhs |> StringMap.values)
    |> Iter.filter (fun v -> not @@ List.exists (Var.equal v) n_lhs)
    |> Iter.to_list
    |> function
    | [] -> []
    | lhs ->
        [
          Stmt.Instr_IntrinCall
            { lhs; args = []; name = Havoc; attrib = Attrib.empty };
        ]
  in
  let icall =
    Stmt.Instr_IntrinCall
      { lhs = n_lhs; args = n_args; name = intrin; attrib = Attrib.empty }
  in
  Some (icall :: hvoc)

(** check whether an intrin spec applies a given call instruction *)
let match_name proc name =
  let open Option in
  let has_attrib a =
    let oa = Procedure.attrib proc in
    StringMap.for_all
      (fun k v -> StringMap.find_opt k oa |> Option.exists (Attrib.equal v))
      a
  in
  match name with
  | ProcName n -> String.equal n (ID.to_string (Procedure.id proc))
  | NameAttrib name ->
      has_attrib (StringMap.singleton name_attrib_key (`String name))
  | HasAttrib a -> has_attrib a

(** Replace first intrinsic replacement pattern which matches a call *)
let intrin_applies intrin_spec =
  let open Option in
  fun prog stmt ->
    let* lhs, args, procid, proc =
      match stmt with
      | Stmt.Instr_Call { lhs; args; procid } ->
          Some (lhs, args, procid, Program.get_proc procid prog)
      | _ -> None
    in
    let* _ = List.find_opt (match_name proc) intrin_spec.names in
    spec_to_func intrin_spec lhs args proc

(** Evaluate the first intrin spec which is compatible *)
let transform_intrin specs =
 fun prog stmt ->
  let fun_specs = List.map intrin_applies specs in
  match stmt with
  | Stmt.Instr_Call _ ->
      fun_specs
      |> List.find_map (fun f -> f prog stmt)
      |> Option.map Iter.of_list
      |> Option.get_or ~default:(Iter.singleton stmt)
  | _ -> Iter.singleton stmt

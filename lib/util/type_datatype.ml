(** Helper for mapping bincaml's types into algebraic datatypes for SMT and
    boogie backend *)

open Containers
open Fun
module StringMap = Map.Make (String)

type datatype =
  | ADT of {
      name : string;  (** sort name *)
      cases : constructor list;  (** list of variant constructors *)
    }
  | Sort of {
      name : string;  (** declaration name *)
      nfields : int;  (** declaration num type params *)
      instantiation : datatype list; (* sort instantiation with these params *)
    }
  | Prim of Types.t

and constructor = {
  name : string;  (** constructor name (analg. variant case) *)
  selectors : (string * datatype) list;
      (** selectors: like record fields to the constructor *)
}
[@@deriving eq, ord, show]
(**adt variant constructor *)

module TMap = Map.Make (Types)

type mapping =
  | Record of { variant_name : string; fields : record_field_info list }
  | Variant of variant_case_info list

and variant_case_info = {
  old_constr_name : string;
  new_constr_name : string;
  new_fields_ordered : string list;
}

and record_field_info = {
  orig_field : string;
  selector_name : string;
  typ : Types.t;
}

type type_decl_info = {
  orig_binding_name : string;
  sort_name : string;
  type_mapping : mapping;
}

type context = {
  name_gen : ID.generator;
  sanitise : string -> string;
  adt_for_typ : datatype TMap.t;
  translating : type_decl_info TMap.t;
}

let empty_context ?sanitise () =
  let sanitise = Option.get_or ~default:Fun.id sanitise in
  {
    name_gen = ID.make_gen ();
    sanitise;
    adt_for_typ = TMap.empty;
    translating = TMap.empty;
  }

let get_adt_maping ctx typ = TMap.find_opt typ ctx.translating
let get_adt_desc ctx typ = TMap.find typ ctx.adt_for_typ

(** put a datatype declaration in the context, assuming it has never been
    declared before *)
let rec desc_datatype ctx binding_name (ty : Types.t) =
  let name_uniq n = ctx.name_gen.fresh ~name:n () |> ID.name |> ctx.sanitise in
  match ty with
  | Types.NewType (args, name) ->
      let name =
        ctx.name_gen.fresh ~name:(binding_name ^ "_" ^ name) () |> ID.name
      in
      ( None,
        Sort
          {
            name;
            nfields = List.length args;
            instantiation = List.map (get_datatype ctx) args;
          } )
  | Types.Record fields ->
      let name = name_uniq binding_name in
      let case_name = name_uniq ("Record" ^ name) in
      let selectors =
        fields
        |> List.map (fun (field_name, field_typ) ->
            ( field_name,
              name_uniq @@ case_name ^ "_fld_" ^ field_name,
              field_typ,
              get_datatype ctx field_typ ))
      in
      let mapping =
        Record
          {
            variant_name = case_name;
            fields =
              List.map
                (fun (orig_field, selector_name, typ, datatyp) ->
                  { orig_field; selector_name; typ })
                selectors;
          }
      in
      let typedef =
        ADT
          {
            name;
            cases =
              [
                {
                  name = case_name;
                  selectors =
                    List.map
                      (fun (_, selector_name, _, datatyp) ->
                        (selector_name, datatyp))
                      selectors;
                };
              ];
          }
      in
      let nty =
        {
          orig_binding_name = binding_name;
          sort_name = name;
          type_mapping = mapping;
        }
      in
      (Some nty, typedef)
  | Types.Variant variants ->
      let name = name_uniq binding_name in
      let variants =
        variants
        |> List.map (fun (variant, args) ->
            let new_constr_name = name_uniq (name ^ "__" ^ variant) in
            let new_fields =
              args
              |> List.mapi (fun ind ty ->
                  ( name_uniq
                    @@ Printf.sprintf "%s_%s_constr_arg_%d" name variant ind,
                    get_datatype ctx ty ))
            in
            let mapping =
              {
                old_constr_name = variant;
                new_constr_name;
                new_fields_ordered = List.map fst new_fields;
              }
            in
            let adt_repr = { name = new_constr_name; selectors = new_fields } in
            (mapping, adt_repr))
      in
      let mapping =
        {
          orig_binding_name = binding_name;
          sort_name = name;
          type_mapping = Variant (List.map fst variants);
        }
      in
      let typedef = ADT { name; cases = List.map snd variants } in
      (Some mapping, typedef)
  | Types.Function _ | Types.Variable _ | Types.ByteArray _ | Types.Boolean
  | Types.Integer | Types.Bitvector _ | Types.Unit | Types.Top | Types.Nothing
  | Types.Map _ ->
      (None, Prim ty)

(** lookup a previously declared datatype *)
and get_datatype ctx typ =
  match typ with
  | Types.Function _ | Types.Variable _ | Types.ByteArray _ | Types.Boolean
  | Types.Integer | Types.Bitvector _ | Types.Unit | Types.Top | Types.Nothing
  | Types.Map _ ->
      Prim typ
  | others ->
      (* there is a failure mode with recursive types here *)
      TMap.find typ ctx.adt_for_typ

let decl_datatype ctx binding typ =
  let desc, decl = desc_datatype ctx binding typ in
  ( {
      ctx with
      adt_for_typ = TMap.add typ decl ctx.adt_for_typ;
      translating =
        Option.map (fun c -> TMap.add typ c ctx.translating) desc
        |> Option.get_or ~default:ctx.translating;
    },
    decl )

let get_or_decl ctx typ =
  try (ctx, get_datatype ctx typ)
  with _ ->
    let binding =
      ctx.name_gen.fresh ~name:"anon_type" () |> ID.name |> ctx.sanitise
    in
    decl_datatype ctx binding typ

(*
  Paper this work is based on: https://arxiv.org/abs/2409.01841

  TODO:
    Don't rely on full type information
*)

open Bincaml_util.Common
open Lang
open Expr

module Polarity = struct
  (*
    Negative polarity
      - Stores
      - Lower bounds
      - Intersection

    Positive polarity
      - Loads
      - Upper bounds
      - Union
  *)
  type t = Pos | Neg [@@deriving ord, eq]

  let show = function Pos -> "+" | Neg -> "-"
  let not p = match p with Pos -> Neg | Neg -> Pos
  let positive = equal Pos
end

module VarId : sig
  (*
    Creates a unique way to look at variables by combining procedure and variable name
  
    NOTE: Sig is needed to string and t can't be the same type
  *)
  type t

  val compare : t -> t -> int
  val equal : t -> t -> bool
  val show : t -> string
  val var_proc_to_uid : Var.t -> Program.proc option -> t
  val var_procid_to_uid : Var.t -> ID.t -> t
  val make_id : string -> t
end = struct
  type t = string

  let compare = String.compare
  let equal = String.equal
  let show = id

  let var_procid_to_uid (var : Var.t) (procId : ID.t) : t =
    if Var.is_global var then Var.name var
    else
      let s = ID.name procId in
      String.sub s 1 (String.length s - 1) ^ "_" ^ Var.name var

  let var_proc_to_uid (var : Var.t) (proc : Program.proc option) : t =
    match proc with
    | None -> Var.name var
    | Some proc -> var_procid_to_uid var (Procedure.id proc)

  let make_id hint = hint
end

module VarIdMap = Map.Make (VarId)

module BinCamlType = struct
  type t = BinCaml_Int | BinCaml_BV of int | BinCaml_Bool [@@deriving ord, eq]

  let show = function
    | BinCaml_Int -> "int"
    | BinCaml_BV size -> "bv" ^ string_of_int size
    | BinCaml_Bool -> "bool"

  let bincaml_type_to_type : t -> Types.t = function
    | BinCaml_Int -> Types.Integer
    | BinCaml_BV sz -> Types.Bitvector sz
    | BinCaml_Bool -> Types.Boolean

  let type_to_bincaml_type : Types.t -> t = function
    | Types.Integer -> BinCaml_Int
    | Types.Bitvector s -> BinCaml_BV s
    | Types.Boolean -> BinCaml_Bool
    | _ -> failwith "no BinCamlType"
end

module InferredType = struct
  type t =
    | Top
    | Bottom
    | Union of t * t (* type ∪ type *)
    | Sect of t * t (* type ∩ type *)
    | Pointer of t * t (* ptr(lb, ub) *)
    | Function of
        string
        * t StringMap.t
        * t StringMap.t (* list of inputs and list of outputs *)
    | Record of field ZMap.t (* A list of fields in the record *)
    | TypeVar of VarId.t
    | Recursive of VarId.t * t
    | BinCamlType of BinCamlType.t
  [@@deriving eq, ord]

  and field = { offset : Z.t; size : int; ty : t } [@@deriving eq, ord]

  let rec show = function
    | Top -> "⊤"
    | Bottom -> "⊥"
    | BinCamlType c -> BinCamlType.show c
    | TypeVar id -> Printf.sprintf "%s" @@ VarId.show id
    | Recursive (t1, t2) -> Printf.sprintf "μ%s.%s" (VarId.show t1) (show t2)
    | Union (t1, t2) -> Printf.sprintf "%s ⊔ %s" (show t1) (show t2)
    | Sect (t1, t2) -> Printf.sprintf "%s ⊓ %s" (show t1) (show t2)
    | Pointer (lb, ub) -> Printf.sprintf "ptr(%s, %s)" (show lb) (show ub)
    | Function (name, ins, outs) ->
        Printf.sprintf "(%s) → (%s)"
          (Iter.to_string show (StringMap.values ins))
          (Iter.to_string show (StringMap.values outs))
    | Record fields ->
        Printf.sprintf "{ %s }"
        @@ String.concat_iter ~sep:", "
        @@ Iter.map (fun (_, field) -> show_field field)
        @@ ZMap.to_iter fields

  and show_field { offset; size; ty } =
    Printf.sprintf "(%s, %d): %s" (Z.to_string offset) size (show ty)

  let rec iter f (ty : t) =
    f ty;
    match ty with
    | Top | Bottom | BinCamlType _ | TypeVar _ | Recursive _ -> ()
    | Union (a, b) | Sect (a, b) ->
        iter f b;
        iter f a
    | Pointer (lb, ub) ->
        iter f ub;
        iter f lb
    | Function (_, ins, outs) ->
        StringMap.iter (fun _ v -> iter f v) ins;
        StringMap.iter (fun _ v -> iter f v) outs
    | Record fields -> ZMap.iter (fun _ { ty } -> iter f ty) fields

  let rec join (ty0 : t) (ty1 : t) : t =
    match (ty0, ty1) with
    | Record fields0, Record fields1 ->
        (* WARN: I think this could be improved, cause this is gross *)
        let module FieldMap = Map.Make (struct
          type t = Z.t * int

          let compare = Stdlib.compare
        end) in
        let fieldmap_to_field_list (map : t FieldMap.t) : field ZMap.t =
          FieldMap.bindings map
          |> List.map (fun ((offset, size), ty) ->
              (offset, { offset; size; ty }))
          |> ZMap.of_list
        in
        let fieldmap_of_list (fields : field ZMap.t) : t FieldMap.t =
          ZMap.fold
            (fun _ ({ offset; size; ty } : field) acc ->
              FieldMap.add (offset, size) ty acc)
            fields FieldMap.empty
        in
        let f0 = fieldmap_of_list fields0 in
        let f1 = fieldmap_of_list fields1 in
        let joined_map =
          FieldMap.merge_safe
            ~f:(fun (offset, size) v ->
              match v with
              | `Both (a, b) -> Some (Union (a, b))
              | `Left a | `Right a -> Some a)
            f0 f1
        in
        Record (fieldmap_to_field_list joined_map)
    | (Record _ as a), _ | _, (Record _ as a) -> a
    | Pointer (a, b), Pointer (c, d) ->
        (* ptr((a u c) n (b n d), (b n d)) *)
        (* WARN: IDK *)
        Pointer (join (Union (a, c)) (join b d), join b d)
    | (Pointer _ as a), _ | _, (Pointer _ as a) -> a
    (*
      WARN:
        This is not how BinSub did it
        I think I am just smarter and had better DS
    *)
    | Function (name0, ins0, outs0), Function (name1, ins1, outs1) ->
        if not @@ String.equal name0 name1 then
          failwith "Function names do not match and a join between them occured"
        else
          (* args are the same just just union over the args *)
          let ins =
            StringMap.merge_safe
              ~f:(fun _ b ->
                match b with
                | `Both (l, r) -> Some (join l r)
                | _ -> failwith "Function declartion differs to function usage")
              ins0 ins1
          in
          Function (name0, ins, outs0)
    | (Function _ as a), _ | _, (Function _ as a) -> a
    (* TypeVar at this stage is pretty much Top *)
    (* | TypeVar _, TypeVar _ -> Top *)
    | Top, a | a, Top | TypeVar _, a | a, TypeVar _ -> Top
    | Bottom, a | a, Bottom -> Bottom
    | a, b when equal a b -> a
    | a, b -> b (* TODO *)

  (* Top and type_var might be valid, and maybe even bottom and then those can just default to whatever type it had prior *)
  let rec inferred_to_real recursives typ : (VarId.t * Types.t) list * Types.t =
    match typ with
    | Top -> (recursives, Types.Top)
    | Bottom -> (recursives, Types.Nothing)
    | TypeVar a -> (recursives, Types.Variable (VarId.show a))
    | BinCamlType a -> (recursives, BinCamlType.bincaml_type_to_type a)
    | Pointer (Top, Top) ->
        (recursives, Types.Pointer { name = "void*"; lower = Top; upper = Top })
    | Pointer (lower, upper) ->
        let recursives, lower = inferred_to_real recursives lower in
        let recursives, upper = inferred_to_real recursives upper in
        let name = "ptr" ^ Int.to_string @@ Hashtbl.hash typ in

        (recursives, Types.Pointer { name; lower; upper })
    | Record fields ->
        let name = "rec" ^ Int.to_string @@ Hashtbl.hash typ in
        let recursives, fields =
          List.fold_left_map
            (fun recursives ({ offset; ty } : field) ->
              let recursives, typ = inferred_to_real recursives ty in
              ( recursives,
                ( "field" ^ Z.to_string offset,
                  ({ typ; offset } : Types.record_field) ) ))
            recursives
          @@ List.of_iter @@ ZMap.values fields
        in
        (recursives, Types.Struct (name, StringMap.of_list fields))
    | Recursive (varid, typ) ->
        let recursives, typ = inferred_to_real recursives typ in
        ((varid, typ) :: recursives, Types.Variable (VarId.show varid))
    (* NOTE: Will need to check to make sure the typevar isn't a recursive and if it is use that one instead *)
    | Union (a, b) -> inferred_to_real recursives @@ join a b
    | Sect (a, b) ->
        inferred_to_real recursives
          (match (a, b) with
          (* This is inf recursion *)
          | Top, a | a, Top | TypeVar _, a | a, TypeVar _ -> Top
          | Bottom, a | a, Bottom -> Bottom
          | a, b when equal a b -> a
          | a, b -> b (* TODO *))
    | Function _ -> (recursives, Top)

  let rec type_to_inferred (typ : Types.t) : t =
    match typ with
    | Top -> Top
    | Nothing -> Bottom
    | Variable a -> TypeVar (VarId.make_id a)
    | Pointer { lower; upper } ->
        Pointer (type_to_inferred lower, type_to_inferred upper)
    | Struct (name, fields) -> failwith "TODO"
    | Bitvector bv -> BinCamlType (BinCaml_BV bv)
    | Boolean -> BinCamlType BinCaml_Bool
    | Integer -> BinCamlType BinCaml_Int
    | Unit | Map _ | Sort _ -> failwith "No inferred type mapping"
end

module TySet = struct
  module S = Set.Make (struct
    type t = InferredType.t

    let compare = InferredType.compare
  end)

  include S

  (* TODO *)
  let show ts = to_list ts |> List.map InferredType.show |> String.concat ", "
end

module ConstraintState = struct
  module TypeConstraint = struct
    type t = { lb : TySet.t; ub : TySet.t }

    let equal { lb; ub } { lb = lb2; ub = ub2 } =
      TySet.equal lb lb2 && TySet.equal ub ub2
  end

  type t = TypeConstraint.t VarIdMap.t

  let equal (a : t) (b : t) = VarIdMap.equal TypeConstraint.equal a b

  let show (m : t) =
    VarIdMap.bindings m
    |> List.map (fun (name, ({ lb; ub } : TypeConstraint.t)) ->
        Printf.sprintf "%s: lower [%s], upper [%s]" (VarId.show name)
          (TySet.show lb) (TySet.show ub))
    |> String.concat "\n"

  let add_ub (st : t) name ty =
    VarIdMap.update name
      (function
        | None ->
            Some
              ({ lb = TySet.empty; ub = TySet.singleton ty } : TypeConstraint.t)
        | Some c -> Some { c with ub = TySet.add ty c.ub })
      st

  let add_lb (st : t) name ty =
    VarIdMap.update name
      (function
        | None ->
            Some
              ({ ub = TySet.empty; lb = TySet.singleton ty } : TypeConstraint.t)
        | Some c -> Some { c with lb = TySet.add ty c.lb })
      st

  let check_bounded (st : t) var typ bound =
    match VarIdMap.find_opt var st with
    | None -> false
    | Some { lb; ub } ->
        if Polarity.positive bound then TySet.mem typ lb else TySet.mem typ ub

  let export_graphviz (t : t) : string =
    Printf.sprintf "\ndigraph G {\n%s\n%s\n}"
      (Iter.fold
         (fun a ty ->
           Printf.sprintf
             "%s\"%s\" [shape=circle style=filled, fillcolor=\"#c4a7e7\"];\n" a
             (VarId.show ty))
         ""
      @@ VarIdMap.keys t)
      (VarIdMap.fold
         (fun k ({ lb; ub } : TypeConstraint.t) acc ->
           let acc =
             TySet.fold
               (fun ty acc ->
                 Printf.sprintf "%s\"%s\" -> \"%s\";\n" acc (VarId.show k)
                   (InferredType.show ty))
               lb acc
           in
           TySet.fold
             (fun ty acc ->
               Printf.sprintf "%s\"%s\" -> \"%s\";\n" acc (InferredType.show ty)
                 (VarId.show k))
             ub acc)
         t "")
end

module Sigma = struct
  (*
    Edges for type automata

    RecLabel is offset, size
    FnIn / FnOut is name of the parameter
  *)
  type t =
    | Ep
    | StoreLabel
    | LoadLabel
    | Reclabel of Z.t * int
    | FnIn of string
    | FnOut of string
  [@@deriving eq, ord]

  let show = function
    | Ep -> "ε"
    | StoreLabel -> "Store Label"
    | LoadLabel -> "Load Label"
    | Reclabel (n, m) -> Printf.sprintf "Record Label %s %d" (Z.to_string n) m
    | FnIn n -> Printf.sprintf "Function in %s" n
    | FnOut n -> Printf.sprintf "Function out %s" n

  let is_epislon = equal Ep
end

module State = struct
  (*
    States for type automata

    Made up of a polarity and a type
  *)
  type t = Polarity.t * InferredType.t [@@deriving eq, ord]

  let show (p, ty) =
    Printf.sprintf "(%s, %s)" (Polarity.show p) (InferredType.show ty)
end

module TypeAutomata = struct
  module StateEdges = Map.Make (State)
  module Edges = Map.Make (Sigma)

  type t = {
    transitions : State.t list Edges.t StateEdges.t;
    start : State.t;
    name : string;
  }
  [@@deriving eq, ord]

  open struct
    let get_transitions m : (State.t * Sigma.t * State.t) list =
      StateEdges.fold
        (fun state edges acc ->
          Edges.fold
            (fun sigma end_states acc ->
              List.fold_left
                (fun acc end_state -> (state, sigma, end_state) :: acc)
                acc end_states)
            edges acc)
        m.transitions []

    let get_transitions_from m s =
      match StateEdges.find_opt s m.transitions with
      | None -> Iter.empty
      | Some a -> Edges.to_iter a

    let get_next_states m s =
      match StateEdges.find_opt s m.transitions with
      | None -> []
      | Some states -> List.concat (Iter.to_list @@ Edges.values states)

    let get_states m : State.t Iter.t =
      let module StateSet = Set.Make (State) in
      Iter.cons m.start
      @@ StateSet.to_iter
           (StateEdges.fold
              (fun _ edges set ->
                Edges.fold
                  (fun _ end_states set ->
                    List.fold_left
                      (fun set end_state -> StateSet.add end_state set)
                      set end_states)
                  edges set)
              m.transitions StateSet.empty)
  end

  let export_graphviz n =
    Printf.sprintf
      "\n\
       digraph G {\n\
       \tranksep=2\n\
       \tnodesep=2\n\n\
       \t\"%s\" [height=0, width=0, style=filled, fillcolor=\"#c4a7e7\" ]\n\
       %s\n\n\
       \t\"%s\" -> %s;\n\
       \t%s\n\
       }\n\n\n"
      n.name
      (Iter.fold
         (fun a (polarity, typ) ->
           let shape =
             if Polarity.positive polarity then "c4a7e7" else "eb6f92"
           in
           Printf.sprintf
             "%s\"%s\" [shape=oval style=filled, fillcolor=\"#%s\"];\n" a
             (InferredType.show typ ^ Polarity.show polarity)
             shape)
         "" (get_states n))
      n.name
      (Printf.sprintf "\"%s\""
      @@ (fun (p, n) -> InferredType.show n ^ Polarity.show p) n.start)
      (List.fold_left
         (fun acc ((polarity, s), a, (polarity2, t)) ->
           Printf.sprintf "%s\"%s\" -> \"%s\" [label=\"%s\", ];\n" acc
             (InferredType.show s ^ Polarity.show polarity)
             (InferredType.show t ^ Polarity.show polarity2)
           @@ Sigma.show a)
         "" (get_transitions n))

  (*
    Meow meow meow
  *)
  let merge_nodes (m : t) : t =
    let rec helper (trans : State.t list Edges.t StateEdges.t)
        (curr_state : State.t) =
      (* Get outgoing edges from curr_state *)
      let children = get_next_states m curr_state in
      let trans = List.fold_left helper trans children in
      (* WARN, this wrongly assumes kids are the same *)
      let edges =
        match StateEdges.find_opt curr_state m.transitions with
        | None -> Iter.empty
        | Some a -> Edges.to_iter a
      in
      let trans, edge_list =
        (* Map those edges so that there is one state per edge *)
        List.fold_filter_map
          (fun (trans : State.t list Edges.t StateEdges.t) edge ->
            match edge with
            (* Edge but no state is filtered *)
            | _, [] -> (trans, None)
            (* Already one state *)
            | edge, [ a ] -> (trans, Some (edge, [ a ]))
            (* Join all states together *)
            | edge, (p, h) :: tl ->
                let children =
                  match StateEdges.find_opt (p, h) trans with
                  | None -> Iter.empty
                  | Some a -> Edges.to_iter a
                in
                let edges, state =
                  List.fold_left
                    (fun (edges, acc) ((_, typ) as state) ->
                      (*
                        If the end state from the edge has edges,
                          they should be attached to the new state
                      *)
                      let children =
                        match StateEdges.find_opt state trans with
                        | None -> Iter.empty
                        | Some a -> Edges.to_iter a
                      in

                      (Iter.append children edges, InferredType.join acc typ))
                    (children, h) tl
                in
                let trans =
                  StateEdges.add (p, state) (Edges.of_iter edges) trans
                in
                (trans, Some (edge, [ (p, state) ])))
          trans
        @@ List.of_iter edges
      in
      let trans = StateEdges.add curr_state (Edges.of_list edge_list) trans in
      trans
    in
    let transitions = helper StateEdges.empty m.start in
    { m with transitions }

  let remove_unreachable (m : t) : t =
    let rec helper acc curr : State.t list Edges.t StateEdges.t =
      let edges = get_transitions_from m curr in
      Iter.fold
        (fun acc (sigma, states) ->
          List.fold_left
            (fun acc state -> helper acc state)
            (StateEdges.add curr (Edges.of_iter edges) acc)
            states)
        acc edges
    in
    let good = helper StateEdges.empty m.start in
    { m with transitions = good }

  let simplify_automata (m : t) : t = m |> merge_nodes |> remove_unreachable

  (*
    Two mutually recursive functions that take a given InferredType.t
      and make it into an automata.

    grab_edges is like a worker of type_to_automata, with the sole job of
      recursing down paths that would lead to epsilon edges and returning the
      states that won't and any edges that need to be added.

      This has the benefit of never needing to remove epsilon edges, as
        none are ever made, saving an entire pass of the types.

    type_to_automata takes a given type structure and decomposes it into
      states and edges, when union / intersection are encounted, grab_edges
      steps in to deal with epsilon edges and then provides a list of types that
      act as the next types to deconstruct since grab_edges skips some types.

    It would be nice to have the merge_nodes in the same step as this, however,
      it isn't that nice to have it here.

      grab_edges is the only way we can get similar edges, but it is from both the
        new types to convert next and the edges we just got.

        Edges are easy to do, but the next types makes another recursive function.

        so messy
  *)
  let type_to_automata (polarity : Polarity.t) ty init name =
    let rec grab_edges (ty : InferredType.t) p :
        (Polarity.t * InferredType.t) list * (Sigma.t * State.t) list =
      match ty with
      | Top | BinCamlType _ | TypeVar _ | Bottom -> ([], [])
      | Recursive (a, ty) ->
          (*
              WARN: IDK
            *)
          (* ([], []) *)
          grab_edges ty p
      | Union (a, b) | Sect (a, b) ->
          let ty1, edge1 = grab_edges a p in
          let ty2, edge2 = grab_edges b p in
          (ty1 @ ty2, edge1 @ edge2)
      | Function (_, ins, outs) ->
          let np = Polarity.not p in
          let a1, a2 =
            List.fold_left_map
              (fun acc (n, ty) ->
                ((np, ty) :: acc, (Sigma.FnIn n, (Polarity.not p, ty))))
              [] (StringMap.to_list ins)
          in
          let b1, b2 =
            List.fold_left_map
              (fun acc (n, ty) -> ((p, ty) :: acc, (Sigma.FnOut n, (p, ty))))
              []
            @@ StringMap.to_list outs
          in
          (a1 @ b1, a2 @ b2)
      | Pointer (a, b) ->
          ( [ (p, b); (Polarity.not p, a) ],
            [ (Sigma.LoadLabel, (p, b)); (StoreLabel, (Polarity.not p, a)) ] )
      | Record fields ->
          List.fold_left_map
            (fun acc ({ offset; size; ty } : InferredType.field) ->
              ((p, ty) :: acc, (Sigma.Reclabel (offset, size), (p, ty))))
            []
          @@ List.of_iter @@ ZMap.values fields
    in
    let rec type_to_state_list p (ty : InferredType.t) ((ls, tbl) as acc) =
      let open Sigma in
      match ty with
      | Top | BinCamlType _ | TypeVar _ | Bottom -> ((p, ty) :: ls, tbl)
      | Recursive (id, typ) ->
          (*
            NOTE: I think it is easiest to deal with recursives with type decls
          *)
          let next, edges = grab_edges typ p in
          let ls, tbl =
            List.fold_left
              (fun acc (p, typ) -> type_to_state_list p typ acc)
              acc next
          in
          let edges =
            List.fold_left
              (fun edges (edge, state) -> Edges.add_to_list edge state edges)
              Edges.empty edges
          in
          let tbl = StateEdges.add (p, ty) edges tbl in
          ((p, ty) :: ls, tbl)
      | Union (a, b) | Sect (a, b) ->
          let next1, edges1 = grab_edges a p in
          let next2, edges2 = grab_edges b p in
          let next, edges = (next1 @ next2, edges1 @ edges2) in
          let ls, tbl =
            List.fold_left
              (fun acc (p, typ) -> type_to_state_list p typ acc)
              acc next
          in
          let edges =
            List.fold_left
              (fun edges (edge, state) -> Edges.add_to_list edge state edges)
              Edges.empty edges
          in
          let tbl = StateEdges.add (p, ty) edges tbl in
          ((p, ty) :: ls, tbl)
      | Function (_, ins, outs) ->
          let acc =
            StringMap.fold
              (fun _ -> type_to_state_list @@ Polarity.not p)
              ins acc
          in
          let ls, tbl =
            StringMap.fold (fun _ -> type_to_state_list p) outs acc
          in
          let edges =
            List.fold_left
              (fun edges (n, ty) ->
                Edges.add_to_list (FnIn n) (Polarity.not p, ty) edges)
              Edges.empty
            @@ StringMap.to_list ins
          in
          let edges =
            List.fold_left
              (fun edges (n, ty) -> Edges.add_to_list (FnOut n) (p, ty) edges)
              edges
            @@ StringMap.to_list outs
          in
          let tbl = StateEdges.add (p, ty) edges tbl in
          ((p, ty) :: ls, tbl)
      | Pointer (a, b) ->
          let ((ls, tbl) as acc) = type_to_state_list p b acc in
          let ls, tbl = type_to_state_list (Polarity.not p) a acc in
          let edges =
            Edges.add_to_list LoadLabel (p, b)
            @@ Edges.add_to_list StoreLabel (Polarity.not p, a) Edges.empty
          in
          let tbl = StateEdges.add (p, ty) edges tbl in
          ((p, ty) :: ls, tbl)
      | Record fields ->
          let ls, tbl =
            ZMap.fold
              (fun _ ({ ty } : InferredType.field) acc ->
                type_to_state_list p ty acc)
              fields acc
          in
          let edges =
            ZMap.fold
              (fun _ ({ offset; size; ty } : InferredType.field) edges ->
                Edges.add_to_list (Reclabel (offset, size)) (p, ty) edges)
              fields Edges.empty
          in
          let tbl = StateEdges.add (p, ty) edges tbl in
          ((p, ty) :: ls, tbl)
    in
    let states, transitions =
      type_to_state_list polarity ty ([], StateEdges.empty)
    in
    { transitions; start = init; name }

  let automata_to_type n =
    (* Look at edges and make a list of them + the type field to make a field *)
    let make_record types : InferredType.t =
      InferredType.Record
        (ZMap.of_list
        @@ List.map
             (fun (edge, ty) ->
               match edge with
               | Sigma.Reclabel (offset, size) ->
                   (offset, ({ offset; size; ty } : InferredType.field))
               | _ -> failwith "Illegal edge in record list")
             types)
    in
    (* Assume the list is only of two things *)
    let make_pointer : (Sigma.t * InferredType.t) list -> InferredType.t =
      function
      | [ (StoreLabel, lb); (LoadLabel, ub) ]
      | [ (LoadLabel, ub); (StoreLabel, lb) ] ->
          Pointer (lb, ub)
      | _ -> failwith "Illegal types in pointer list"
    in
    (* Check the FnIn / FnOut and construct it accordingly *)
    let make_function types =
      let ins, outs =
        List.partition_filter_map
          (fun (edge, ty) ->
            match edge with
            | Sigma.FnIn name -> `Left (name, ty)
            | FnOut name -> `Right (name, ty)
            | _ -> failwith "Illegal type in function list")
          types
      in
      InferredType.Function
        ( "lowkirkenuily dont think this field matters at this stage, but if \
           it does it should not be that much more effort just to cascade the \
           name to here",
          StringMap.of_list ins,
          StringMap.of_list outs )
    in
    let make_type (types : (Sigma.t * InferredType.t) list) ((_, ty) : State.t)
        : InferredType.t =
      (* Figure out what constructor to use *)
      match types with
      | [] -> ty
      | (Reclabel _, _) :: _ -> make_record types
      | ((StoreLabel | LoadLabel), _) :: _ -> make_pointer types
      | ((FnIn _ | FnOut _), _) :: _ -> make_function types
      | (Ep, _) :: _ -> failwith "Should have been removed"
    in
    let rec construct_type (state : State.t) : InferredType.t =
      let edges = get_transitions_from n state in
      let highest_edges =
        Iter.fold
          (fun acc ((edge, state) as a) ->
            match (acc, edge) with
            | _, Sigma.Ep -> failwith "Should have been removed"
            (* Empty acc, add anything *)
            | [], _ -> [ (edge, state) ]
            (* Record label in acc and record label edge *)
            | (Sigma.Reclabel _, _) :: _, Sigma.Reclabel _ -> a :: acc
            (* Record label in acc and non record label edge *)
            | (Sigma.Reclabel _, _) :: _, _ -> acc
            (* Pointer label in acc and pointer label edge *)
            | ( ((Sigma.StoreLabel | Sigma.LoadLabel), _) :: _,
                (Sigma.StoreLabel | Sigma.LoadLabel) ) ->
                a :: acc
            (* Pointer label in acc and record label edge *)
            | ((Sigma.StoreLabel | Sigma.LoadLabel), _) :: _, Sigma.Reclabel _
              ->
                [ a ]
            (* Pointer label in acc and non pointer label edge *)
            | ((Sigma.StoreLabel | Sigma.LoadLabel), _) :: _, _ -> acc
            (* Function label in acc and function label edge *)
            | ( ((Sigma.FnIn _ | Sigma.FnOut _), _) :: _,
                (Sigma.FnIn _ | Sigma.FnOut _) ) ->
                a :: acc
            (* Function label in acc and higher than function label edge *)
            | ( ((Sigma.FnIn _ | Sigma.FnOut _), _) :: _,
                (Sigma.Reclabel _ | Sigma.StoreLabel | Sigma.LoadLabel) ) ->
                [ a ]
            (* Atoms in acc and non-atom edge *)
            | ( _,
                ( Sigma.FnIn _ | Sigma.FnOut _ | Sigma.LoadLabel
                | Sigma.StoreLabel | Sigma.Reclabel _ ) ) ->
                [ a ])
          [] edges
      in
      let children_types =
        List.map
          (fun (edge, state) ->
            let state =
              match state with
              | state :: [] -> state
              | [] -> failwith "Map wasn't removed when edges were removed"
              | states ->
                  failwith "A list of states here means they weren't merged"
            in
            (edge, construct_type state))
          highest_edges
      in
      make_type children_types state
    in
    construct_type n.start

  let create_simple_type (polarity : Polarity.t) ty init name : InferredType.t =
    let m = type_to_automata polarity ty init name |> simplify_automata in
    (* print_endline @@ export_graphviz m; *)
    m |> automata_to_type
end

(* Needed for extraction calls etc. *)
let gen = ID.make_gen ()

(*

  Start of actual type inferencing algorithm
  ==========================================

  Three main functions

  1) gen_constraint_set
    Runs over each statement in the program and generates the initial constraints

  2) coalesce_types
    Takes constraints over variables and changes it to be one combined type that is not constrained

  3) minimise type
    Takes a (coalesced) type and returns an automata that represents that type
    Has side effects (removing epsilon edges and that have the same incoming edges where possible)
    

*)

let minimise_type p ty name =
  TypeAutomata.create_simple_type p ty (p, ty) (VarId.show name)

(*
  Given a type tau get all bounds (depending on polarity) and make a combined
    type out of them using u or n (depending on polarity).

    This recurses into the bounds of their bounds, etc. so that the type
      constraints are represented in the single type now instead of two lists
      of types (lower and upper bounds)

  For example:

  a: lower [bv32]
     upper [b]
  b: lower [bv32]
     upper [c]
  c: lower [bv32]
     upper []

  Coalesce starting at 'a', with positive polarity (upper bounds) would be
    b n c
  Coalesce starting at 'a', with negative polarity (lower bounds) would be
    bv32
*)
let rec coalesce_types (constraint_set : ConstraintState.t)
    (recursive_set : TySet.t) (polarity : Polarity.t) (tau : InferredType.t) :
    InferredType.t =
  let open InferredType in
  let recursive_call = coalesce_types constraint_set recursive_set in
  match tau with
  | Record fields ->
      Record
        (ZMap.map
           (fun { size; offset; ty } ->
             let ty = recursive_call polarity ty in
             match ty with
             (* First one should be the TypeVar that just goes to the name, is not useful WARN: probably should remove this and make it work without *)
             | Union (_, b) | Sect (_, b) -> { size; offset; ty = b }
             (*
               Field had no constraints on it,
                it could just be a bitvector of size size
              *)
             | a -> { size; offset; ty = BinCamlType (BinCaml_BV size) })
           fields)
  | Pointer (a, b) ->
      Pointer
        (recursive_call (Polarity.not polarity) a, recursive_call polarity b)
  | Function (name, ins, outs) ->
      (* This might be useless, but just in case there are exprs in function calls *)
      Function
        ( name,
          StringMap.map (recursive_call @@ Polarity.not polarity) ins,
          StringMap.map (recursive_call polarity) outs )
  | TypeVar a -> (
      match TySet.find_opt tau recursive_set with
      | Some c -> c (* Seen before *)
      | None ->
          (* Has not been seen *)
          let bounds =
            (* Get the bounds for the variable depending on the polarity *)
            match VarIdMap.find_opt a constraint_set with
            | Some { lb; ub } -> if Polarity.positive polarity then lb else ub
            | None -> TySet.empty
          in
          (* If tau is in bounds then we have a recursive type *)
          let rec_check = TySet.mem tau bounds in
          let recursive_set = TySet.add tau recursive_set in
          let s =
            TySet.fold
              (fun bound type_cons ->
                let y =
                  coalesce_types constraint_set recursive_set polarity bound
                in
                if Polarity.positive polarity then
                  InferredType.Union (type_cons, y)
                else Sect (type_cons, y))
              bounds tau
          in
          if rec_check then Recursive (a, s) else s)
  | BinCamlType _ -> tau
  | _ -> Top

(*
  Given a statement constrain the variables involed (based on the expression)

  Prefer giving upper bounds when possible

  NOTE: This could possibly be used else where some what easily

        By providing an empty constraint state and a statement you can generate
          all typing constraints a particular statement can generate

        Might need to make SVA an option type to better support this, however
          no-sva leads to bad types when sva is needed.

        Program is needed for formal params

        Procedure is needed for unique IDs for local variables
*)
let rec constrain (st : ConstraintState.t) (type0 : InferredType.t)
    (type1 : InferredType.t) : ConstraintState.t =
  match (type0, type1) with
  | Pointer (type0_a, type0_b), Pointer (type1_a, type1_b) ->
      constrain (constrain st type1_a type0_a) type0_b type1_b
  | TypeVar a, TypeVar b -> (
      if
        VarId.equal a b || ConstraintState.check_bounded st a type1 Polarity.Neg
      then st
      else
        let st = ConstraintState.add_ub st a type1 in
        let bounds = VarIdMap.get a st in
        match bounds with
        | Some { lb } ->
            TySet.to_iter lb
            |> Iter.fold (fun st bound -> constrain st bound type1) st
        | None -> st)
  | _, TypeVar a -> (
      if ConstraintState.check_bounded st a type0 Polarity.Pos then st
      else
        (* The right hand side is not a type variable *)
        let st = ConstraintState.add_lb st a type0 in
        let bounds = VarIdMap.get a st in
        match bounds with
        | Some { ub } ->
            TySet.to_iter ub
            |> Iter.fold (fun st bound -> constrain st type0 bound) st
        | None -> st)
  | BinCamlType a, BinCamlType b when BinCamlType.equal a b -> st
  | BinCamlType a, BinCamlType b ->
      failwith
        (Printf.sprintf "Attempted to constrain to disjoint bincamltypes: %s %s"
           (BinCamlType.show a) (BinCamlType.show b))
  | _, BinCamlType b -> st
  | _ ->
      failwith
      @@ Printf.sprintf "Illegal types at this stage: %s %s"
           (InferredType.show type0) (InferredType.show type1)

let constrain_arg proc st l t =
  let l = BasilExpr.unfix l in
  match l with
  | RVar { id } -> constrain st t (TypeVar (VarId.var_proc_to_uid id proc))
  | _ -> st

let constrain_args proc st l r t =
  let st = constrain_arg proc st l t in
  constrain_arg proc st r t

let rec constrain_expr proc (st : ConstraintState.t)
    (expr : 'e BasilExpr.abstract_expr) =
  let open InferredType in
  match expr with
  (* TODO *)
  | Lambda _ -> (st, Top)
  | Let _ -> (st, Top)
  | RVar { id } ->
      let typ =
        match Var.typ id with
        | Integer -> BinCamlType BinCaml_Int
        | Boolean -> BinCamlType BinCaml_Bool
        | Bitvector sz -> BinCamlType (BinCaml_BV sz)
        | _ -> failwith "Illegal variable type"
      in
      ( constrain_arg proc st (BasilExpr.fix expr) typ,
        TypeVar (VarId.var_proc_to_uid id proc) )
  | Constant { const } ->
      ( st,
        match const with
        | `Bool _ -> BinCamlType BinCaml_Bool
        | `Bitvector bv -> BinCamlType (BinCaml_BV (Bitvec.size bv))
        | `Integer _ -> BinCamlType BinCaml_Int
        | `Record (_, typ) -> InferredType.type_to_inferred typ
        | `Pointer (bv, { lower; upper }) ->
            InferredType.Pointer
              ( InferredType.type_to_inferred lower,
                InferredType.type_to_inferred upper ) )
  | UnaryExpr { op; arg = a } -> (
      let st, _ = constrain_expr proc st (BasilExpr.unfix a) in
      match op with
      | `ReadField offset ->
          let { typ; offset } : Types.record_field =
            Types.struct_field offset (BasilExpr.type_of a)
          in
          (st, type_to_inferred typ)
      | `BoolNOT ->
          ( constrain_arg proc st a @@ BinCamlType BinCaml_Bool,
            BinCamlType BinCaml_Bool )
      | `BOOLTOBV1 ->
          ( constrain_arg proc st a @@ BinCamlType BinCaml_Bool,
            BinCamlType (BinCaml_BV 1) )
      | `INTNEG ->
          ( constrain_arg proc st a @@ BinCamlType BinCaml_Int,
            BinCamlType BinCaml_Int )
      | `BVNEG | `BVNOT ->
          let typ =
            match BasilExpr.type_of a with
            | Bitvector size -> BinCamlType (BinCaml_BV size)
            | _ -> failwith "Bitvector operation without bitvector arguments"
          in
          (constrain_arg proc st a @@ typ, typ)
      | `SignExtend b | `ZeroExtend b ->
          let size =
            match BasilExpr.type_of a with
            | Bitvector size -> size
            | _ -> failwith "Bitvector operation without bitvector arguments"
          in
          ( constrain_arg proc st a @@ BinCamlType (BinCaml_BV size),
            BinCamlType (BinCaml_BV (size + b)) )
      | `Old -> (st, Top)
      | `Gamma -> (st, Top)
      | `Classification -> (st, Top)
      | `Extract (finish, rt) ->
          (* NOTE: This seems hard to determine what type is within a record *)
          let size = finish - rt in
          let name =
            VarId.make_id
            @@ Printf.sprintf "Extraction_%s"
            @@ ID.name @@ gen.fresh ()
          in
          let ty = TypeVar name in
          let field = { offset = Z.of_int rt; size; ty } in
          let st =
            ConstraintState.add_lb st name (BinCamlType (BinCaml_BV size))
          in
          ( constrain_arg proc st a
            @@ Record (ZMap.singleton (Z.of_int rt) field),
            ty ))
  | BinaryExpr { op; arg1 = l; arg2 = r } -> (
      let st, _ = constrain_expr proc st (BasilExpr.unfix l) in
      let st, _ = constrain_expr proc st (BasilExpr.unfix r) in
      match op with
      | `WriteField offset ->
          (* TODO: constrain the r to be the type of that field in the record l*)
          let { typ } : Types.record_field =
            Types.struct_field offset (BasilExpr.type_of r)
          in
          let st =
            constrain_arg proc st r @@ InferredType.type_to_inferred typ
          in
          (st, type_to_inferred @@ BasilExpr.type_of l)
      | `PTRADD ->
          (* The pointer is the the left pointer but with the offsets translated by the right value, use SVA to see if we know the right ptr? *)
          (st, Pointer (Top, Top))
      | `INTMOD | `INTSUB | `INTDIV | `INTADD | `INTMUL ->
          let st = constrain_args proc st l r @@ BinCamlType BinCaml_Int in
          (st, BinCamlType BinCaml_Int)
      | `NEQ | `EQ -> (
          match (BasilExpr.unfix l, BasilExpr.unfix r) with
          | RVar { id = a }, RVar { id = b } ->
              let a_id = VarId.var_proc_to_uid a proc in
              let b_id = VarId.var_proc_to_uid b proc in
              let st = ConstraintState.add_lb st a_id (TypeVar b_id) in
              let st = ConstraintState.add_ub st a_id (TypeVar b_id) in
              let st = ConstraintState.add_lb st b_id (TypeVar a_id) in
              let st = ConstraintState.add_ub st b_id (TypeVar a_id) in
              (st, BinCamlType BinCaml_Bool)
          | RVar { id }, a | a, RVar { id } ->
              let id = VarId.var_proc_to_uid id proc in
              let st, expr = constrain_expr proc st a in
              let st = ConstraintState.add_lb st id expr in
              let st = ConstraintState.add_ub st id expr in
              (st, BinCamlType BinCaml_Bool)
          | _, _ -> (st, BinCamlType BinCaml_Bool))
      | `INTLT | `INTLE ->
          let st = constrain_args proc st l r @@ BinCamlType BinCaml_Int in
          (st, BinCamlType BinCaml_Bool)
      | `BVULE | `BVULT | `BVSLE | `BVSLT -> (
          match BasilExpr.type_of l with
          | Bitvector size ->
              let st =
                constrain_args proc st l r @@ BinCamlType (BinCaml_BV size)
              in
              (st, BinCamlType BinCaml_Bool)
          | _ -> failwith "BV operation without BV arguments")
      | `BVSREM | `BVSDIV | `BVADD | `BVMUL | `BVUREM | `BVSUB | `BVUDIV
      | `BVSMOD | `BVSHL | `BVLSHR | `BVASHR | `BVNAND | `BVAND | `BVXOR | `BVOR
        -> (
          match BasilExpr.type_of l with
          | Bitvector size ->
              let typ = BinCamlType (BinCaml_BV size) in
              let st = constrain_args proc st l r typ in
              (st, typ)
          | _ -> failwith "BV operation without BV arguments")
      (* WARN: I forgot what this was meant to be *)
      | `IMPLIES -> (st, Top)
      | `Load _ | `IfThen | `MapAccess -> (st, Top))
  | ApplyIntrin { op; args } -> (
      match op with
      (* output is constrain by every input *)
      | `BVOR | `BVXOR | `BVAND | `BVADD -> (
          match BasilExpr.type_of (List.hd args) with
          | Bitvector size ->
              let typ = BinCamlType (BinCaml_BV size) in
              let st =
                List.fold_left
                  (fun acc a -> constrain_arg proc st a typ)
                  st args
              in
              (st, typ)
          | _ -> failwith "BV operation without BV arguments")
      | `OR | `AND ->
          (* All types need to be the same *)
          let typ =
            BinCamlType
              (BinCamlType.type_to_bincaml_type
                 (BasilExpr.type_of (List.hd args)))
          in
          let st =
            List.fold_left (fun acc a -> constrain_arg proc st a typ) st args
          in
          (st, typ)
      | `Cases -> (st, Top)
      | `MapUpdate -> (st, Top)
      | `BVConcat ->
          ( st,
            BinCamlType
              (BinCamlType.type_to_bincaml_type
              @@ BasilExpr.type_of (BasilExpr.fix expr)) ))
  | ApplyFun _ -> (st, Top)

let constrain_stmt prog proc sva (st : ConstraintState.t) stmt_number stmt :
    ConstraintState.t =
  let open AbstractExpr in
  let open InferredType in
  let sva_res_check sva_res addr =
    (*
      When dealing with load or store statements, sva results are used

      Before they can be used, they need to be checked to see if useful.

      They should be not top or bottom, with only one SymBase that is not Stack.
    *)
    let open Analysis.Sva in
    let open Analysis.Wrapped_intervals in
    SymAddrSetLattice.cardinal sva_res <> 1
    || WrappedIntervalsLattice.equal
         (snd @@ List.hd @@ snd @@ SymAddrSetLattice.to_list sva_res)
         WrappedIntervalsLattice.Top
    || SymBase.is_stack
         (fst @@ List.hd @@ snd @@ SymAddrSetLattice.to_list sva_res)
    || WrappedIntervalsLattice.equal
         (snd @@ List.hd @@ snd @@ SymAddrSetLattice.to_list sva_res)
         WrappedIntervalsLattice.Bot
  in
  (* Given a expression constrain the variables involed *)
  match stmt with
  | Stmt.Instr_Assert { body } | Stmt.Instr_Assume { body } ->
      let st, constrain_expr = constrain_expr proc st (BasilExpr.unfix body) in
      constrain st constrain_expr (BinCamlType BinCaml_Bool)
  | Stmt.Instr_Assign ls ->
      List.fold_left
        (fun st (lhs, expr) ->
          if String.starts_with ~prefix:"_PC" @@ Var.name lhs then st
          else
            let lhs = VarId.var_proc_to_uid lhs proc in
            let st, constrain_expr =
              constrain_expr proc st @@ BasilExpr.unfix expr
            in
            constrain st constrain_expr (TypeVar lhs))
        st ls
  | Stmt.Instr_Store { lhs; rhs; addr = Scalar }
  | Stmt.Instr_Load { lhs; rhs; addr = Scalar } ->
      if String.starts_with ~prefix:"_PC" @@ Var.name lhs then st
      else
        let lhs = VarId.var_proc_to_uid lhs proc in
        let rhs = VarId.var_proc_to_uid rhs proc in
        constrain st (TypeVar rhs) (TypeVar lhs)
  (* TODO: These should probably be constrain calls and joined somehow *)
  | Stmt.Instr_Load { lhs; addr = Addr { addr; size } } ->
      let sva_res =
        Analysis.Sva.Eval.EV.eval
          ((flip Analysis.Sva.StateAbstraction.read) sva)
          addr
      in
      let lhs = VarId.var_proc_to_uid lhs proc in
      if sva_res_check sva_res addr then
        (*
          No information case

          Simply just a ptr(a,b) where a <= b
        *)
        let lb = VarId.make_id @@ Int.to_string stmt_number ^ "_lower_load" in
        let ub = VarId.make_id @@ Int.to_string stmt_number ^ "_upper_load" in
        let st, addr = constrain_expr proc st (BasilExpr.unfix addr) in
        let st = constrain st (Pointer (TypeVar lb, TypeVar ub)) addr in
        let bv_type = BinCamlType (BinCaml_BV size) in
        let st = constrain st (Pointer (bv_type, bv_type)) addr in
        let st = constrain st (TypeVar lb) @@ TypeVar ub in
        constrain st (TypeVar ub) (TypeVar lhs)
      else
        (*
          Some information case

          ptr with the upper bound as a record with the offset as the offset,
            and size of load as the size, type is var atm and gets constrained
            to lhs
        *)
        let res =
          snd @@ List.hd @@ snd
          @@ Analysis.Sva.SymAddrSetLattice.to_list sva_res
        in
        let offset =
          match res with
          | Interval { lower } -> Bitvec.to_signed_bigint lower
          | _ -> failwith "impossible"
        in
        let ty =
          TypeVar (VarId.make_id @@ Int.to_string stmt_number ^ "_upper_load")
        in
        let ub = Record (ZMap.singleton offset { size; offset; ty }) in
        let lb =
          TypeVar (VarId.make_id @@ Int.to_string stmt_number ^ "_lower_load")
        in
        let st, addr = constrain_expr proc st (BasilExpr.unfix addr) in
        let st = constrain st (Pointer (lb, ub)) addr in
        let st = constrain st ub lb in
        let ub =
          Record
            (ZMap.singleton offset
               { size; offset; ty = BinCamlType (BinCaml_BV size) })
        in
        let st = constrain st (Pointer (lb, ub)) addr in
        let st = constrain st ub lb in
        constrain st ty (TypeVar lhs)
  | Stmt.Instr_Store { lhs; addr = Addr { addr; size } } ->
      let sva_res =
        Analysis.Sva.Eval.EV.eval
          ((flip Analysis.Sva.StateAbstraction.read) sva)
          addr
      in
      let lhs = TypeVar (VarId.var_proc_to_uid lhs proc) in
      if sva_res_check sva_res addr then
        (*
          No information case

          Simply just a ptr(a,b) where a <= b
        *)
        let lb =
          TypeVar (VarId.make_id @@ Int.to_string stmt_number ^ "_lower_store")
        in
        let ub =
          TypeVar (VarId.make_id @@ Int.to_string stmt_number ^ "_upper_store")
        in
        let st, addr = constrain_expr proc st (BasilExpr.unfix addr) in
        let bv_type = BinCamlType (BinCaml_BV size) in
        let st = constrain st (Pointer (bv_type, bv_type)) addr in
        let st = constrain st (Pointer (lb, ub)) addr in
        let st = constrain st lb ub in
        constrain st lhs lb
      else
        (*
          Some information case

          ptr with the upper bound as a record with the offset as the offset,
            and size of load as the size, type is var atm and gets constrained
            to lhs
        *)
        let res =
          snd @@ List.hd @@ snd
          @@ Analysis.Sva.SymAddrSetLattice.to_list sva_res
        in
        let offset =
          match res with
          | Interval { lower } -> Bitvec.to_signed_bigint lower
          | _ -> failwith "impossible"
        in
        let ty =
          TypeVar (VarId.make_id @@ Int.to_string stmt_number ^ "_lower_store")
        in
        let lb = Record (ZMap.singleton offset { size; offset; ty }) in
        let ub =
          TypeVar (VarId.make_id @@ Int.to_string stmt_number ^ "_upper_store")
        in
        let st, addr = constrain_expr proc st (BasilExpr.unfix addr) in
        let st = constrain st (Pointer (lb, ub)) addr in
        let st = constrain st lb ub in
        let lb =
          Record
            (ZMap.singleton offset
               { size; offset; ty = BinCamlType (BinCaml_BV size) })
        in
        let st = constrain st lb ub in
        let st = constrain st (Pointer (lb, ub)) addr in
        constrain st lhs ty
  | Stmt.Instr_Call { lhs; args; procid } ->
      let formal_in = Procedure.formal_in_params @@ Program.proc prog procid in
      let formal_out =
        Procedure.formal_out_params @@ Program.proc prog procid
      in
      let st =
        StringMap.fold
          (fun k v acc ->
            match constrain_expr proc acc @@ BasilExpr.unfix v with
            | acc, TypeVar a ->
                constrain acc
                  (TypeVar
                     (VarId.var_procid_to_uid
                        (StringMap.find k formal_in)
                        procid))
                  (TypeVar a)
            | acc, a ->
                ConstraintState.add_ub acc
                  (VarId.var_procid_to_uid (StringMap.find k formal_in) procid)
                  a)
          args
        @@ StringMap.fold
             (fun k v acc ->
               constrain acc
                 (TypeVar
                    (VarId.var_procid_to_uid
                       (StringMap.find k formal_out)
                       procid))
                 (TypeVar (VarId.var_proc_to_uid v proc)))
             lhs st
      in
      let args =
        StringMap.map
          (fun v -> snd @@ constrain_expr proc st @@ BasilExpr.unfix v)
          args
      in
      let rets =
        StringMap.map (fun v -> TypeVar (VarId.var_proc_to_uid v proc)) lhs
      in
      let func = Function (ID.name procid, args, rets) in
      ConstraintState.add_ub st (VarId.make_id @@ ID.name procid) func
  (*
    NOTE: This will eventually be a 'special' function list
      containing things like malloc

      aka, another match that allows for exact return types.
  *)
  | Stmt.Instr_IntrinCall _ -> st
  (*
    WARN: Unconstrained, this is unsound
      The correct thing to do would be to constrain everything to Top
       as anything could happen to any variable during this?
  *)
  | Stmt.Instr_IndirectCall _ -> st

(* Passes through a given program and returns a given constraint set *)
let analyse (prog : Program.t) : Types.t VarIdMap.t * (VarId.t * Types.t) list =
  (* Generate constraint set *)
  let type_constraint_map =
    IDMap.values prog.procs
    |> Iter.fold
         (fun acc proc ->
           let sva = Analysis.Sva.DFGAnalysis.flow_insensitive proc in
           Procedure.iter_blocks_topo_fwd proc
           |> Iter.fold
                (fun acc (_, (b : Program.bloc)) ->
                  let acc =
                    List.fold_left
                      (fun acc ({ lhs; rhs } : Var.t Block.phi) ->
                        let lhs = VarId.var_proc_to_uid lhs (Some proc) in
                        List.fold_left
                          (fun acc (_, rhs) ->
                            let rhs = VarId.var_proc_to_uid rhs (Some proc) in
                            constrain acc (TypeVar rhs) (TypeVar lhs))
                          acc rhs)
                      acc b.phis
                  in
                  Block.stmts_iter b
                  |> Iter.foldi (constrain_stmt prog (Some proc) sva) acc)
                acc)
         VarIdMap.empty
  in
  (* Create polar unconstrained types for each variable / function etc. *)
  let types =
    VarIdMap.mapi
      (fun name ({ lb; ub } : ConstraintState.TypeConstraint.t) ->
        let lower =
          TySet.fold
            (fun ty (acc : InferredType.t) ->
              let a =
                coalesce_types type_constraint_map TySet.empty Polarity.Neg ty
              in
              match acc with Top -> a | _ -> Sect (acc, a))
            lb Top
        in
        let upper =
          TySet.fold
            (fun ty (acc : InferredType.t) ->
              let a =
                coalesce_types type_constraint_map TySet.empty Polarity.Pos ty
              in
              match acc with Top -> a | _ -> Union (acc, a))
            ub Top
        in
        (lower, upper))
      type_constraint_map
  in

  (*
    What would happen if we made one huge automata and tried to solve it like that?
  *)
  (* Make the types simpler *)
  let ( (recursives : (VarId.t * Types.t) list),
        (types : (VarId.t * Types.t) list) ) =
    VarIdMap.fold
      (fun name (lower_ty, upper_ty) (recursives, types) ->
        let recursives2, types2 =
          InferredType.inferred_to_real recursives
          @@ InferredType.join
               (minimise_type Polarity.Neg lower_ty name)
               (minimise_type Polarity.Pos upper_ty name)
        in
        (recursives, (name, types2) :: types))
      types ([], [])
  in

  (VarIdMap.of_list types, recursives)

(*
  Transform Section
  =================

  Actual transform to replace the types in stmt / exprs etc. with inferred types  
*)

let get_type results proc var : Types.t =
  match VarIdMap.find_opt (VarId.var_proc_to_uid var proc) results with
  | None | Some Types.Top ->
      Var.typ var
      (* NOTE: This should fail, but might as well keep old type for now, this only really happens when the variable isn't used ever, i.e. function parameters, this could be changed to do a constraint there though, just forgot *)
      (* TODO: Make this a failwith and instead just get better code to always have constraints *)
  | Some a -> a

let map_var results proc (var : Var.t) : Var.t =
  Var.create (Var.name var) ~pure:(Var.pure var) ~scope:(Var.scope var)
  @@ get_type results proc var

let map_expr results proc =
  let expr_rewriter results proc (abstract_expr : 'e BasilExpr.abstract_expr) :
      BasilExpr.rewrite =
    match abstract_expr with
    | AbstractExpr.RVar { id; attrib } ->
        BasilExpr.replace [%here]
          (BasilExpr.rvar ?attrib @@ map_var results proc id)
    | AbstractExpr.UnaryExpr { op = `Extract (_, offset1); arg; attrib } -> (
        (* arg is a Struct, I love structs *)
        match BasilExpr.type_of arg with
        | Types.Struct (name, fields) ->
            let field, _ =
              List.find (fun (_, ({ offset } : Types.record_field)) ->
                  Z.equal offset @@ Z.of_int offset1)
              @@ StringMap.bindings fields
            in
            BasilExpr.replace [%here]
              (BasilExpr.unexp ?attrib ~op:(`ReadField field) arg)
        | _ -> BasilExpr.Keep)
    | AbstractExpr.BinaryExpr { op = `BVADD; arg1; arg2; attrib } -> (
        match (BasilExpr.type_of arg1, BasilExpr.type_of arg2) with
        | Types.Pointer _, Types.Pointer _ ->
            failwith "Two pointer types adding"
        | Types.Pointer _, _ ->
            BasilExpr.replace [%here]
              (BasilExpr.binexp ?attrib ~op:`PTRADD arg1 arg2)
        | _, Types.Pointer _ ->
            BasilExpr.replace [%here]
              (BasilExpr.binexp ?attrib ~op:`PTRADD arg2 arg1)
        | _ -> BasilExpr.Keep)
    | _ -> BasilExpr.Keep
  in
  BasilExpr.rewrite ~rw_fun:(expr_rewriter results proc)

let map_stmt results proc (stmt : Program.stmt) : Program.stmt =
  match stmt with
  | Stmt.Instr_Assign assignments ->
      Stmt.Instr_Assign
        (List.map
           (fun (lvar, expr) ->
             (map_var results proc lvar, map_expr results proc expr))
           assignments)
  | Stmt.Instr_Assume { body; branch } ->
      Stmt.Instr_Assume { branch; body = map_expr results proc body }
  | Stmt.Instr_Assert { body } ->
      Stmt.Instr_Assert { body = map_expr results proc body }
  | Stmt.Instr_Load { lhs; rhs; addr = Scalar } ->
      Stmt.Instr_Load
        {
          lhs = map_var results proc lhs;
          rhs = map_var results proc rhs;
          addr = Scalar;
        }
  | Stmt.Instr_Load { lhs; rhs; addr = Addr { addr; size; endian } } ->
      Stmt.Instr_Load
        {
          lhs = map_var results proc lhs;
          rhs = map_var results proc rhs;
          addr = Addr { size; endian; addr = map_expr results proc addr };
        }
  | Stmt.Instr_Store { lhs; rhs; value; addr = Scalar } ->
      Stmt.Instr_Store
        {
          lhs = map_var results proc lhs;
          rhs = map_var results proc rhs;
          value = map_expr results proc value;
          addr = Scalar;
        }
  | Stmt.Instr_Store { lhs; rhs; value; addr = Addr { addr; size; endian } } ->
      Stmt.Instr_Store
        {
          lhs = map_var results proc lhs;
          rhs = map_var results proc rhs;
          addr = Addr { size; endian; addr = map_expr results proc addr };
          value = map_expr results proc value;
        }
  | Stmt.Instr_IntrinCall { lhs; args; name } ->
      Stmt.Instr_IntrinCall
        {
          lhs = StringMap.map (map_var results proc) lhs;
          args = StringMap.map (map_expr results proc) args;
          name;
        }
  | Stmt.Instr_Call { lhs; procid; args } ->
      Stmt.Instr_Call
        {
          lhs = StringMap.map (map_var results proc) lhs;
          args = StringMap.map (map_expr results proc) args;
          procid;
        }
  | Stmt.Instr_IndirectCall { target } ->
      Stmt.Instr_IndirectCall { target = map_expr results proc target }

let map_decl results proc (decl : Program.declaration) : Program.declaration =
  match decl with
  (* Leave type decls alone, could have a pass that removes dead ones *)
  | Program.Type _ -> decl
  (* TODO: confused *)
  | Program.Function { definition; attrib; binding } ->
      Function
        {
          attrib;
          (* TODO: Ask Ali if this should be mapped *)
          binding;
          definition =
            (match definition with
            | Axiom e -> Axiom (map_expr results proc e)
            | Function e -> Function (map_expr results proc e)
            | Uninterpreted -> Uninterpreted);
        }
  | Program.Variable { binding; attrib } ->
      Variable { binding = map_var results proc binding; attrib }

let declare_typ (typ : Types.t) : (string * Types.t) option * Types.t =
  match typ with
  | Struct (name, _) | Pointer { name } -> (Some (name, typ), typ)
  | _ -> (None, typ)

let declare_recursive_typs (recursives : (VarId.t * Types.t) list) :
    (string * Program.declaration) list =
  List.map
    (fun (varid, typ) ->
      let binding = VarId.show varid in
      (binding, (Type { typ; binding } : Program.declaration)))
    recursives

let transform (prog : Program.t) (results : Types.t VarIdMap.t)
    (recursives : (VarId.t * Types.t) list) : Program.t =
  let decls, results =
    List.fold_left_map
      (fun acc (id, typ) ->
        let name, typ = declare_typ typ in
        (name :: acc, (id, typ)))
      [] (VarIdMap.to_list results)
  in
  let results = VarIdMap.of_list results in
  let decls =
    List.filter_map
      (fun a ->
        match a with
        | Some (binding, typ) ->
            Some (binding, (Type { typ; binding } : Program.declaration))
        | None -> None)
      decls
  in
  let mapped_globals = StringMap.map (map_decl results None) prog.globals in
  {
    prog with
    procs =
      IDMap.map
        (fun proc ->
          Procedure.map_formal_in_params
            (StringMap.map (map_var results (Some proc)))
          @@ Procedure.map_formal_out_params
               (StringMap.map (map_var results (Some proc)))
          @@ Procedure.map_blocks_nondet
               (fun (id, block) ->
                 Block.map
                   ~phi:
                     (List.map (fun ({ lhs; rhs } : Var.t Block.phi) ->
                          ({
                             lhs = map_var results (Some proc) lhs;
                             rhs =
                               List.map
                                 (fun (id, var) ->
                                   (id, map_var results (Some proc) var))
                                 rhs;
                           }
                            : Var.t Block.phi)))
                   (fun stmt -> map_stmt results (Some proc) stmt)
                   block)
               proc)
        prog.procs;
    (*
      Change global variable types
      Change function formal ins/outs
      Add type decls
    *)
    globals = StringMap.add_list mapped_globals decls;
  }

let infer_types (prog : Program.t) =
  let results, recursives = analyse prog in
  transform prog results recursives

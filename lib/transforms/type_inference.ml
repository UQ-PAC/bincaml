(** Type Inference using Algebaric Subtyping
    {1 Overview and related reading}

    If you wanna learn how algebaric subtyping works the best bet is one of the
    papers this is based off of:
    - {{:https://arxiv.org/abs/2409.01841}BinSub}
    - {{:https://dl.acm.org/doi/pdf/10.1145/3409006}SimpleSub}
    - {{:https://dl.acm.org/doi/pdf/10.1145/3009837.3009882}MlSub}
    - {{:https://www.cs.tufts.edu/~nr/cs257/archive/stephen-dolan/thesis.pdf}Algebraic
       Subtyping Thesis}

    If you wanna learn how it works within BinCaml you can probably just look at
    my stuff, the slides are pretty barebones though.
    - {{:https://typst.app/project/rIVqCuLCBKG7ZQIBQyeaKL}Interim Presentation
       Slides}
    - {{:https://typst.app/project/rIVqCuLCBKG7ZQIBQyeaKL}Final Presentation
       Slides}
    - {{:https://typst.app/project/rIVqCuLCBKG7ZQIBQyeaKL}Final Report}

    In short, this transform adds Record and Pointer types to the IR using type
    inference, naturally from these changes, additional operations are added to
    suit these new types, i.e. rectobv, ptradd, field access etc.

    Extra considerations are then needed to have these new types, as each type
    now has a lower and upper type (side effect of algebaric subtyping). Since
    type inference requires SSA form, this can largely be ignored.

    - The upper type just represents any type that value can take in, and is
      often only constrained by size.
    - The lower type just represents the type when used on the right hand side
      (or similar situtations)

    Example:
    {[
      type rec1 = { field0 : (bv32, 0)} 64;
      var a: bv64 := 0x1c:bv64
      var b: bv32 := (a:rec1.field0)
    ]}

    The variable [a] has the lower type of [rec1] and the upper type of [bv64],
    this is able to type check because a record with size [s] is a subtype of a
    bv with size [s] *)

open Bincaml_util.Common
open Bincaml_util.Logger
open Lang
open Expr

(** Polar Types - lhs type is positive, rhs type is negative
    {1 Polar Types}
    {2 Negative polarity}
    - Stores
    - Lower bounds
    - Intersection

    {2 Positive polarity}
    - Loads
    - Upper bounds
    - Union *)
module Polarity = struct
  type t = Pos | Neg [@@deriving ord, eq]

  let show = function Pos -> "+" | Neg -> "-"
  let not p = match p with Pos -> Neg | Neg -> Pos
  let positive = equal Pos
end

(** Creates a unique way to look at variables by combining procedure and
    variable name NOTE: Sig is needed to string and t can't be the same type *)
module VarId : sig
  type t

  val compare : t -> t -> int
  val equal : t -> t -> bool
  val show : t -> string
  val var_proc_to_uid : Var.t -> Program.proc option -> t
  val var_procid_to_uid : Var.t -> ID.t -> t
  val make_id : string -> t
  val fresh : unit -> t
end = struct
  type t = string [@@deriving eq, ord]

  let show a = a

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
  let rand_chr () = Char.chr (97 + CCRandom.full_int 26)

  let fresh () =
    List.fold_left
      (fun string char -> String.cat string @@ Char.to_string char)
      ""
    @@ List.init 10 (fun _ -> rand_chr ())
end

module VarIdMap = Map.Make (VarId)

(** The type system for the type inference algorithm
    {1 Inferred Types}
    {2 Types}
    - It is almost a superset of Types.t (Missing Map / ADT) adding Union and
      intersection types

    {2 Why not use Types.t?}
    - Probably could?
    - But, it is easier this way to be honest, I would have to add in Union /
      Sect types into it as well, and this keeps them more seperate as type
      inference wants more information about things like records than the rest
      of the IR wants. *)
module InferredType = struct
  type t =
    | Top
    | Bottom
    | Union of t * t  (** type ∪ type *)
    | Sect of t * t  (** type ∩ type *)
    | Pointer of t * t  (** ptr(lb, ub) *)
    | Function of string * t StringMap.t * t StringMap.t
        (** list of inputs and list of outputs *)
    | Record of field ZMap.t * int  (** A list of fields in the record *)
    | TypeVar of VarId.t
    | Recursive of VarId.t * t
    | BV of int
    | Int
    | Bool
  [@@deriving eq, ord]

  and field = { offset : Z.t; size : int; ty : t } [@@deriving eq, ord]

  let rec show = function
    | Top -> "⊤"
    | Bottom -> "⊥"
    | Int -> "int"
    | BV size -> "bv" ^ string_of_int size
    | Bool -> "bool"
    | TypeVar id -> Printf.sprintf "%s" @@ VarId.show id
    | Recursive (t1, t2) -> Printf.sprintf "μ%s.%s" (VarId.show t1) (show t2)
    | Union (t1, t2) -> Printf.sprintf "(%s ⊔ %s)" (show t1) (show t2)
    | Sect (t1, t2) -> Printf.sprintf "(%s ⊓ %s)" (show t1) (show t2)
    | Pointer (lb, ub) -> Printf.sprintf "ptr(%s, %s)" (show lb) (show ub)
    | Function (name, ins, outs) ->
        Printf.sprintf "(%s) → (%s)"
          (Iter.to_string show (StringMap.values ins))
          (Iter.to_string show (StringMap.values outs))
    | Record (fields, size) ->
        Printf.sprintf "{ %s } : %d"
          (String.concat_iter ~sep:", "
          @@ Iter.map (fun (_, field) -> show_field field)
          @@ ZMap.to_iter fields)
          size

  and show_field { offset; size; ty } =
    Printf.sprintf "(%s, %d): %s" (Z.to_string offset) size (show ty)

  let rec iter f (ty : t) =
    f ty;
    match ty with
    | Top | Bottom | BV _ | Int | Bool | TypeVar _ -> ()
    | Recursive (_, t) -> iter f t
    | Union (a, b) | Sect (a, b) ->
        iter f b;
        iter f a
    | Pointer (lb, ub) ->
        iter f ub;
        iter f lb
    | Function (_, ins, outs) ->
        StringMap.iter (fun _ v -> iter f v) ins;
        StringMap.iter (fun _ v -> iter f v) outs
    | Record (fields, _) -> ZMap.iter (fun _ { ty } -> iter f ty) fields

  let rec intersect (a : t) (b : t) : t =
    match (a, b) with
    | a, b when equal a b -> a
    | Recursive (a, b), _ | _, Recursive (a, b) ->
        (*
          TODO:
            Deal with recursives, I doubt they are real though
            they are probs more important than anything else?
        *)
        print_endline "Intersection Recursive";
        Recursive (a, b)
    | Record (fields0, size), Record (fields1, _) ->
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
        Record (fieldmap_to_field_list joined_map, size)
    | Pointer (a, b), Pointer (c, d) ->
        (* ptr((a u c) n (b n d), (b n d)) *)
        Pointer (intersect (union a c) (intersect b d), intersect b d)
    | (Pointer _ as a), _ | _, (Pointer _ as a) -> a
    | Function (name0, ins0, outs0), Function (name1, ins1, outs1) ->
        if not @@ String.equal name0 name1 then
          failwith "Function names do not match and a join between them occured"
        else
          (* args are the same just just union over the args *)
          let ins =
            StringMap.merge_safe
              ~f:(fun _ b ->
                match b with
                | `Both (l, r) -> Some (intersect l r)
                | _ -> failwith "Function declaration differs to function usage")
              ins0 ins1
          in
          Function (name0, ins, outs0)
    | (Function _ as a), _ | _, (Function _ as a) -> a
    (* TODO: Will need to check to make sure the typevar isn't a recursive and if it is use that one instead *)
    | Top, a | a, Top | TypeVar _, a | a, TypeVar _ -> a
    | Bottom, a | a, Bottom -> Bottom
    | c, Union (a, b) | Union (a, b), c -> Sect (c, union a b)
    | c, Sect (a, b) | Sect (a, b), c -> intersect c @@ intersect a b
    | a, b -> order a b

  and union a b =
    match (a, b) with
    | _, _ when equal a b -> a
    | Recursive (a, b), _ | _, Recursive (a, b) ->
        (*
          TODO:
            Deal with recursives, I doubt they are real though
            they are probs more important than anything else?
        *)
        print_endline "Union Recursive";
        Recursive (a, b) (*TODO*)
    | Top, _ | _, Top -> Top
    | Union (a, b), c | c, Union (a, b) -> union c @@ union a b
    | Sect (a, b), c | c, Sect (a, b) -> union c @@ intersect a b
    | Record (name, f1), Record (_, f2) -> a (* TODO *)
    | Record (name, f), _ | _, Record (name, f) -> Record (name, f)
    | Pointer (l1, u1), Pointer (l2, u2) -> a (* TODO *)
    | Pointer (l, u), _ | _, Pointer (l, u) -> Pointer (l, u)
    (* TODO: Will need to check to make sure the typevar isn't a recursive and if it is use that one instead *)
    | TypeVar a, _ | _, TypeVar a -> TypeVar a
    | BV _, _ | Bottom, _ | Int, _ | Function _, _ | Bool, _ ->
        failwith
          "Type inference union hit a weird case that should be unreachable"

  (** As well as having intersection and union defined, types have an inherent
      heuristic based ordering on them from BinSub, records -> functions ->
      Pointers -> the rest *)
  and order a b =
    match (a, b) with
    | a, b when equal a b -> a
    | BV _, BV _ ->
        print_endline @@ Printf.sprintf "DISJOINT BV %s %s" (show a) (show b);
        Top
    | (Record _ as a), _ | _, (Record _ as a) -> a
    | (Pointer _ as a), _ | _, (Pointer _ as a) -> a
    | (Function _ as a), _ | _, (Function _ as a) -> a
    | BV _, _
    | Top, _
    | Bottom, _
    | Int, _
    | Bool, _
    | Union _, _
    | Sect _, _
    | TypeVar _, _
    | Recursive _, _ ->
        print_endline
        @@ Printf.sprintf "No order over these types %s %s" (show a) (show b);
        failwith "No order over these types"

  (* Top and type_var might be valid, and maybe even bottom and then those can just default to whatever type it had prior *)
  let rec inferred_to_real recursives typ : (VarId.t * Types.t) list * Types.t =
    match typ with
    | Top -> (recursives, Types.Top)
    | Bottom -> (recursives, Types.Nothing)
    | TypeVar a ->
        ( recursives,
          if List.exists (fun (var, _) -> VarId.equal var a) recursives then
            Types.Variable (VarId.show a)
          else Top )
    | Int -> (recursives, Types.Integer)
    | BV sz -> (recursives, Types.Bitvector sz)
    | Bool -> (recursives, Types.Boolean)
    | Pointer (Top, Top) ->
        (recursives, Types.Pointer { lower = Top; upper = Top })
    | Pointer (lower, upper) ->
        let recursives, lower = inferred_to_real recursives lower in
        let recursives, upper = inferred_to_real recursives upper in
        (recursives, Types.Pointer { lower; upper })
    | Record (fields, size) ->
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
        let name = "rec" ^ Int.to_string @@ Hashtbl.hash fields in
        ( recursives,
          Types.Struct { name; fields = StringMap.of_list fields; size } )
    | Recursive (varid, typ) ->
        let recursives, typ = inferred_to_real recursives typ in
        ((varid, typ) :: recursives, Types.Variable (VarId.show varid))
    (* TODO: Will need to check to make sure the typevar isn't a recursive and if it is use that one instead *)
    | Union (a, b) -> inferred_to_real recursives @@ union a b
    | Sect (a, b) -> inferred_to_real recursives @@ intersect a b
    | Function _ -> (recursives, Top)

  let rec type_to_inferred (typ : Types.t) : t =
    match typ with
    | Top -> Top
    | Nothing -> Bottom
    | Variable a -> TypeVar (VarId.make_id a)
    | Pointer { lower; upper } ->
        Pointer (type_to_inferred lower, type_to_inferred upper)
    | Struct { name; fields; size } ->
        let fields =
          ZMap.of_iter
          @@ Iter.map
               (fun ({ offset; typ } : Types.record_field) ->
                 let typ = type_to_inferred typ in
                 let size =
                   match typ with
                   | BV sz -> sz
                   | Pointer _ -> 64
                   | Record (_, sz) -> sz
                   | _ -> failwith "Undefined"
                 in
                 (offset, ({ offset; ty = typ; size } : field)))
               (StringMap.values fields)
        in
        Record (fields, size)
    | Bitvector bv -> BV bv
    | Boolean -> Bool
    | Integer -> Int
    | Unit | Map _ | Sort _ -> failwith "No inferred type mapping"
end

module TySet = struct
  module S = Set.Make (InferredType)
  include S

  let show ts = to_list ts |> List.map InferredType.show |> String.concat ", "
end

(** Map of VarId -> TypeConstraint *)
module ConstraintState = struct
  (** Two TySet.t representing the lower and upper constraints on a variable's
      type *)
  module TypeConstraint = struct
    type t = { lb : TySet.t; ub : TySet.t } [@@deriving eq, ord]

    let show { lb; ub } =
      "lower: " ^ TySet.show lb ^ "\nupper: " ^ TySet.show ub
  end

  type t = TypeConstraint.t VarIdMap.t [@@deriving eq, ord]

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

  let iter = VarIdMap.iter
  let bindings = VarIdMap.bindings

  let export_graphviz (t : t) : string =
    Printf.sprintf "\ndigraph G {\n%s\n%s\n}"
      "node [shape=circle style=filled, fillcolor=\"#c4a7e7\"];\n"
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

(** Edges for type automata
    - RecLabel is offset, field_size, record_size
    - FnIn / FnOut is name of the parameter *)
module Sigma = struct
  type t =
    | Ep
    | StoreLabel
    | LoadLabel
    | Reclabel of Z.t * int * int
    | FnIn of string
    | FnOut of string
  [@@deriving eq, ord]

  let show = function
    | Ep -> "ε"
    | StoreLabel -> "Store Label"
    | LoadLabel -> "Load Label"
    | Reclabel (n, m, _) ->
        Printf.sprintf "Record Label %s %d" (Z.to_string n) m
    | FnIn n -> Printf.sprintf "Function in %s" n
    | FnOut n -> Printf.sprintf "Function out %s" n

  let is_epislon = equal Ep
end

(** States for type automata

    Made up of a polarity and a type *)
module State = struct
  type t = Polarity.t * InferredType.t [@@deriving eq, ord]

  let show (p, ty) =
    Printf.sprintf "(%s, %s)" (Polarity.show p) (InferredType.show ty)
end

(** Automata representation of a Inferred Type

    States represent some data that is a Inferred Types

    Edges represent the structure between two states, i.e. record edges from
    [a -> b] say that [a] is a record and [b] is it's field *)
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
       \tnode [height=0, width=0, style=filled, fillcolor=\"#c4a7e7\" ]\n\
       %s\n\n\
       \t\"%s\" -> %s;\n\
       \t%s\n\
       }\n\n\n"
      (Iter.fold
         (fun a (polarity, typ) ->
           if Polarity.positive polarity then a
           else
             Printf.sprintf "%s\"%s\" [fillcolor=\"#eb6f92\"];\n" a
               (InferredType.show typ ^ Polarity.show polarity))
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

  let merge_nodes (m : t) : t =
    let rec helper (trans : State.t list Edges.t StateEdges.t)
        (curr_state : State.t) =
      (* Get outgoing edges from curr_state *)
      let children = get_next_states m curr_state in
      let trans = List.fold_left helper trans children in
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

                      ( Iter.append children edges,
                        InferredType.intersect acc typ ))
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

  (** Two mutually recursive functions that take a given InferredType.t and make
      it into an automata.

      grab_edges is like a worker of type_to_automata, with the sole job of
      recursing down paths that would lead to epsilon edges and returning the
      states that won't and any edges that need to be added.

      This has the benefit of never needing to remove epsilon edges, as none are
      ever made, saving an entire pass of the types.

      type_to_automata takes a given type structure and decomposes it into
      states and edges, when union / intersection are encounted, grab_edges
      steps in to deal with epsilon edges and then provides a list of types that
      act as the next types to deconstruct since grab_edges skips some types.

      It would be nice to have the merge_nodes in the same step as this,
      however, it isn't that nice to have it here. grab_edges is the only way we
      can get similar edges, but it is from both the new types to convert next
      and the edges we just got.

      Edges are easy to do, but the next types makes another recursive function.

      so messy *)
  let type_to_automata (polarity : Polarity.t) ty init name =
    let rec grab_edges (ty : InferredType.t) p :
        (Polarity.t * InferredType.t) list * (Sigma.t * State.t) list =
      match ty with
      | Top | BV _ | Bool | Int | TypeVar _ | Bottom -> ([], [])
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
      | Record (fields, r_size) ->
          List.fold_left_map
            (fun acc ({ offset; size; ty } : InferredType.field) ->
              ((p, ty) :: acc, (Sigma.Reclabel (offset, size, r_size), (p, ty))))
            []
          @@ List.of_iter @@ ZMap.values fields
    in
    let rec type_to_state_list p (ty : InferredType.t) ((ls, tbl) as acc) =
      let open Sigma in
      match ty with
      | Top | BV _ | Bool | Int | TypeVar _ | Bottom ->
          (Iter.cons (p, ty) ls, tbl)
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
          (Iter.cons (p, ty) ls, tbl)
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
          (Iter.cons (p, ty) ls, tbl)
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
          (Iter.cons (p, ty) ls, tbl)
      | Pointer (a, b) ->
          let ((ls, tbl) as acc) = type_to_state_list p b acc in
          let ls, tbl = type_to_state_list (Polarity.not p) a acc in
          let edges =
            Edges.add_to_list LoadLabel (p, b)
            @@ Edges.add_to_list StoreLabel (Polarity.not p, a) Edges.empty
          in
          let tbl = StateEdges.add (p, ty) edges tbl in
          (Iter.cons (p, ty) ls, tbl)
      | Record (fields, r_size) ->
          let ls, tbl =
            ZMap.fold
              (fun _ ({ ty } : InferredType.field) acc ->
                type_to_state_list p ty acc)
              fields acc
          in
          let edges =
            ZMap.fold
              (fun _ ({ offset; size; ty } : InferredType.field) edges ->
                Edges.add_to_list
                  (Reclabel (offset, size, r_size))
                  (p, ty) edges)
              fields Edges.empty
          in
          let tbl = StateEdges.add (p, ty) edges tbl in
          (Iter.cons (p, ty) ls, tbl)
    in
    let states, transitions =
      type_to_state_list polarity ty (Iter.empty, StateEdges.empty)
    in
    { transitions; start = init; name }

  let automata_to_type n =
    (* Look at edges and make a list of them + the type field to make a field *)
    let make_record types size : InferredType.t =
      let fields =
        List.map
          (fun (edge, ty) ->
            match edge with
            | Sigma.Reclabel (offset, size, _) ->
                (offset, ({ offset; size; ty } : InferredType.field))
            | _ -> failwith "Illegal edge in record list")
          types
      in
      let fields =
        fields
        |> List.sort
             (fun
               (_, ({ size; _ } : InferredType.field))
               (_, { size = size2; _ })
             -> Int.compare size2 size)
      in
      let rec helper (fields : (Z.t * InferredType.field) list) =
        let nest_record ({ ty = ty1; offset; size } : InferredType.field)
            ({ offset = offset2 } as field_to_nest : InferredType.field) :
            InferredType.field =
          let ty =
            match ty1 with
            | InferredType.Record (fields, size) ->
                let fields =
                  helper (ZMap.to_list fields @ [ (offset2, field_to_nest) ])
                in
                InferredType.Record (ZMap.of_list fields, size)
            | _ ->
                InferredType.Record (ZMap.singleton offset2 field_to_nest, size)
          in
          { offset; size; ty }
        in
        let fields =
          List.fold_left
            (fun fields
                 (_, (({ offset; ty; size } : InferredType.field) as field)) ->
              match
                List.last_opt
                @@ List.find_all
                     (fun ( _,
                            ({ offset = offset1; size = size1 } :
                              InferredType.field) ) ->
                       Z.leq offset1 offset
                       && Z.leq
                            (Z.add offset @@ Z.of_int size)
                            (Z.add offset1 @@ Z.of_int size1))
                     fields
              with
              | Some (offset1, field1) ->
                  let fields = List.remove_assq offset1 fields in
                  (offset1, nest_record field1 field) :: fields
              | None -> (offset, field) :: fields)
            [] fields
        in
        fields
      in

      let fields = helper fields in
      let overlapped_field fields =
        let overlaps (o1, (f1 : InferredType.field))
            (o2, (f2 : InferredType.field)) =
          let open Z in
          let end1 = add o1 (of_int f1.size) in
          let end2 = add o2 (of_int f2.size) in
          not (leq end1 o2 || leq end2 o1)
        in

        let check_fields fields =
          let rec aux = function
            | [] -> false
            | x :: xs ->
                if List.exists (fun y -> overlaps x y) xs then true else aux xs
          in
          aux fields
        in

        let rec best_friend fields =
          if check_fields fields then true
          else
            List.exists
              (fun (_, (f : InferredType.field)) ->
                match f.ty with
                | InferredType.Record (subfields, _) ->
                    subfields |> ZMap.bindings |> best_friend
                | _ -> false)
              fields
        in
        best_friend fields
      in
      if overlapped_field fields then BV size
      else InferredType.Record (ZMap.of_list fields, size)
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
      | (Reclabel (_, _, rsize), _) :: _ -> make_record types rsize
      | ((StoreLabel | LoadLabel), _) :: _ -> make_pointer types
      | ((FnIn _ | FnOut _), _) :: _ -> make_function types
      | (Ep, _) :: _ -> failwith "Unreachable - Should have been removed"
    in
    let rec construct_type (state : State.t) : InferredType.t =
      let edges = get_transitions_from n state in
      let highest_edges =
        Iter.fold
          (fun acc ((edge, state) as a) ->
            match (acc, edge) with
            | _, Sigma.Ep -> failwith "Unreachable - Should have been removed"
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
              | [] ->
                  failwith
                    "Unreachable - Map wasn't removed when edges were removed"
              | states ->
                  failwith
                    "Unreachable - A list of states here means they weren't \
                     merged"
            in
            (edge, construct_type state))
          highest_edges
      in
      make_type children_types state
    in
    construct_type n.start

  let create_simple_type (polarity : Polarity.t) ty init name : InferredType.t =
    type_to_automata polarity ty init name
    |> simplify_automata |> automata_to_type
end

(* Needed for extraction calls etc. *)
let gen = ID.make_gen ()

(** {1 Type Inferencing Algorithm}

    Three main functions:
    + generate_constraints Runs over each statement in the program and generates
      the initial constraints
    + coalesce_types Takes constraints over variables and changes it to be one
      combined type that is not constrained
    + minimise type Takes a (coalesced) type and returns an automata that
      represents that type has side effects (removing epsilon edges and that
      have the same incoming edges where possible) *)

(** {2 Minimise type}*)

(** Uses TypeAutomata simplification methods to create simple types *)
let minimise_type p (ty : InferredType.t) name =
  if String.starts_with ~prefix:"@" (VarId.show name) then InferredType.Top
  else TypeAutomata.create_simple_type p ty (p, ty) (VarId.show name)

(** {2 Coalesce types} *)

(** Given a type tau get all bounds (depending on polarity) and make a combined
    type out of them using u or n (depending on polarity).

    This recurses into the bounds of their bounds, etc. so that the type
    constraints are represented in the single type now instead of two lists of
    types (lower and upper bounds)

    For example:
    {[
      a: lower [bv32]
         upper [b]
      b: lower [bv32]
         upper [c]
      c: lower [bv32]
         upper []
    ]}

    Coalesce starting at 'a', with positive polarity (upper bounds) would be b n
    c Coalesce starting at 'a', with negative polarity (lower bounds) would be
    bv32 *)
let rec coalesce_types (constraint_set : ConstraintState.t)
    (recursive_set : TySet.t) (polarity : Polarity.t) (tau : InferredType.t) :
    InferredType.t =
  let open InferredType in
  let recursive_call = coalesce_types constraint_set recursive_set in
  match tau with
  | Record (fields, size) ->
      Record
        ( ZMap.map
            (fun { size; offset; ty } ->
              let ty = recursive_call polarity ty in
              let ty =
                if Polarity.positive polarity then
                  InferredType.Union (ty, BV size)
                else Sect (ty, BV size)
              in
              { size; offset; ty })
            fields,
          size )
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
            | Some { ub; _ } when Polarity.positive polarity -> ub
            | Some { lb; _ } -> lb
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
          if rec_check then (
            print_endline @@ VarId.show a;
            print_endline @@ TySet.show bounds;
            print_endline "BOOM";
            Recursive (a, s))
          else s)
  | BV _ | Bool | Int -> tau
  | _ -> Top

(** Given a statement constrain the variables involed (based on the expression)

    Prefer giving upper bounds when possible

    NOTE: This could possibly be used else where some what easily

    By providing an empty constraint state and a statement you can generate all
    typing constraints a particular statement can generate

    Might need to make SVA an option type to better support this, however no-sva
    leads to bad types when sva is needed.

    Program is needed for formal params

    Procedure is needed for unique IDs for local variables *)
let rec constrain (st : ConstraintState.t) (type0 : InferredType.t)
    (type1 : InferredType.t) : ConstraintState.t =
  match (type0, type1) with
  | _, _ when InferredType.equal type0 type1 -> st
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
  | (BV _ | Int | Bool), (BV _ | Int | Bool) ->
      failwith
        (Printf.sprintf "Attempted to constrain to disjoint atomic types: %s %s"
           (InferredType.show type0) (InferredType.show type1))
  | _, (BV _ | Int | Bool) -> st
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

(** Given a expr update a ConstraintState.t with new constraints*)
let rec constrain_expr proc (st : ConstraintState.t)
    (expr : 'e BasilExpr.abstract_expr) =
  let open InferredType in
  match expr with
  (* TODO *)
  | Lambda _ -> (st, Top)
  | Let _ -> (st, Top)
  | RVar { id } ->
      let typ = InferredType.type_to_inferred (Var.typ id) in
      ( constrain_arg proc st (BasilExpr.fix expr) typ,
        TypeVar (VarId.var_proc_to_uid id proc) )
  | Constant { const } ->
      ( st,
        match const with
        | `Sort _ ->
            Top
            (* TODO: Not sure what to do with sort, top will just make it its original type *)
        | `Bool _ -> Bool
        | `Bitvector bv -> BV (Bitvec.size bv)
        | `Integer _ -> Int
        | `Record (_, typ) -> InferredType.type_to_inferred typ
        | `Pointer (bv, { lower; upper }) ->
            InferredType.Pointer
              ( InferredType.type_to_inferred lower,
                InferredType.type_to_inferred upper ) )
  | UnaryExpr { op; arg = a } -> (
      let st, inner = constrain_expr proc st (BasilExpr.unfix a) in
      match op with
      | `ReadField offset ->
          let { typ; offset } : Types.record_field =
            Types.struct_field offset (BasilExpr.type_of a)
          in
          (st, type_to_inferred typ)
      | `BoolNOT -> (constrain_arg proc st a @@ Bool, Bool)
      | `BOOLTOBV1 -> (constrain_arg proc st a @@ Bool, BV 1)
      | `PTRTOBV64 -> (constrain_arg proc st a @@ Pointer (Top, Top), BV 64)
      | `RECTOBV -> (
          match BasilExpr.type_of a with
          | Struct { size } ->
              (constrain_arg proc st a @@ Pointer (Top, Top), BV size)
          | _ -> failwith "Record operation without record arguments")
      | `INTNEG -> (constrain_arg proc st a @@ Int, Int)
      | `BVNEG | `BVNOT ->
          let typ =
            match BasilExpr.type_of a with
            | Bitvector size -> BV size
            | _ -> failwith "Bitvector operation without bitvector arguments"
          in
          (constrain_arg proc st a @@ typ, typ)
      | `SignExtend b | `ZeroExtend b ->
          let size =
            match BasilExpr.type_of a with
            | Bitvector size -> size
            | _ -> failwith "Bitvector operation without bitvector arguments"
          in
          (constrain_arg proc st a @@ BV size, BV (size + b))
      | `Old -> (st, Top)
      | `Gamma -> (st, Top)
      | `Classification -> (st, Top)
      | `Extract (finish, offset) ->
          let size = finish - offset in
          let name =
            VarId.make_id
            @@ Printf.sprintf "Extraction_%s"
            @@ ID.name @@ gen.fresh ()
          in
          let ty = TypeVar name in
          let field = { offset = Z.of_int offset; size; ty } in
          let st = constrain st (BV size) ty in
          let record_size =
            match BasilExpr.type_of a with
            | Bitvector sz -> sz
            | _ -> failwith "Unreachable - Can you do this? Probs not"
          in
          let st =
            constrain_arg proc st a
            @@ Record (ZMap.singleton (Z.of_int offset) field, record_size)
          in
          let st =
            constrain st
              (Record (ZMap.singleton (Z.of_int offset) field, record_size))
              inner
          in
          (st, ty))
  | BinaryExpr { op; arg1 = l; arg2 = r } -> (
      let st, _ = constrain_expr proc st (BasilExpr.unfix l) in
      let st, _ = constrain_expr proc st (BasilExpr.unfix r) in
      match op with
      | `WriteField offset ->
          let { typ } : Types.record_field =
            Types.struct_field offset (BasilExpr.type_of r)
          in
          let st =
            constrain_arg proc st r @@ InferredType.type_to_inferred typ
          in
          (st, type_to_inferred @@ BasilExpr.type_of l)
      | `PTRADD -> (st, Pointer (Top, Top))
      | `INTMOD | `INTSUB | `INTDIV | `INTADD | `INTMUL ->
          let st = constrain_args proc st l r Int in
          (st, Int)
      | `NEQ | `EQ -> (
          match (BasilExpr.unfix l, BasilExpr.unfix r) with
          | RVar { id = a }, RVar { id = b } ->
              let a_id = TypeVar (VarId.var_proc_to_uid a proc) in
              let b_id = TypeVar (VarId.var_proc_to_uid b proc) in
              let st = constrain st a_id b_id in
              let st = constrain st b_id a_id in
              (st, Bool)
          | RVar { id }, a | a, RVar { id } ->
              let id = VarId.var_proc_to_uid id proc in
              let st, expr = constrain_expr proc st a in
              let st = ConstraintState.add_lb st id expr in
              let st = ConstraintState.add_ub st id expr in
              (st, Bool)
          | _, _ -> (st, Bool))
      | `INTLT | `INTLE ->
          let st = constrain_args proc st l r @@ Int in
          (st, Bool)
      | `BVULE | `BVULT | `BVSLE | `BVSLT -> (
          match BasilExpr.type_of l with
          | Bitvector size ->
              let st = constrain_args proc st l r @@ BV size in
              (st, Bool)
          | _ -> failwith "BV operation without BV arguments")
      | `BVSREM | `BVSDIV | `BVUREM | `BVUDIV | `BVSMOD | `BVSUB | `BVSHL
      | `BVLSHR | `BVASHR | `BVNAND -> (
          match BasilExpr.type_of l with
          | Bitvector size ->
              let typ = BV size in
              let st = constrain_args proc st l r typ in
              (st, typ)
          | _ -> failwith "BV operation without BV arguments")
      (* WARN: TODO I forgot what this was meant to be *)
      | `IMPLIES -> (st, Top)
      | `Load _ | `IfThen | `MapAccess -> (st, Top))
  | ApplyIntrin { op; args } -> (
      let st =
        List.fold_left
          (fun st a -> fst @@ constrain_expr proc st (BasilExpr.unfix a))
          st args
      in
      match op with
      (* output is constrain by every input *)
      | `BVOR | `BVXOR | `BVAND | `BVMUL | `BVADD -> (
          match BasilExpr.type_of (List.hd args) with
          | Bitvector size ->
              let typ = BV size in
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
            InferredType.type_to_inferred (BasilExpr.type_of (List.hd args))
          in
          let st =
            List.fold_left (fun acc a -> constrain_arg proc st a typ) st args
          in
          (st, typ)
      | `Cases -> (st, Top)
      | `MapUpdate -> (st, Top)
      | `BVConcat ->
          ( st,
            InferredType.type_to_inferred
            @@ BasilExpr.type_of (BasilExpr.fix expr) ))
  | ApplyFun _ -> (st, Top)

(** Given a stmt update a ConstraintState.t with new constraints*)
let constrain_stmt prog proc sva (st : ConstraintState.t) stmt_number stmt
    block_id : ConstraintState.t =
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
    not
      (SymAddrSetLattice.cardinal sva_res <> 1
      || WrappedIntervalsLattice.equal
           (snd @@ List.hd @@ snd @@ SymAddrSetLattice.to_list sva_res)
           WrappedIntervalsLattice.Top
      || SymBase.is_stack
           (fst @@ List.hd @@ snd @@ SymAddrSetLattice.to_list sva_res)
      || WrappedIntervalsLattice.equal
           (snd @@ List.hd @@ snd @@ SymAddrSetLattice.to_list sva_res)
           WrappedIntervalsLattice.Bot)
  in
  (* Given a expression constrain the variables involed *)
  match stmt with
  | Stmt.Instr_Assert { body } | Stmt.Instr_Assume { body } ->
      let st, constrain_expr = constrain_expr proc st (BasilExpr.unfix body) in
      constrain st constrain_expr Bool
  | Stmt.Instr_Assign { al } ->
      List.fold_left
        (fun st (lhs, expr) ->
          if String.starts_with ~prefix:"_PC" @@ Var.name lhs then st
          else
            let lhs = VarId.var_proc_to_uid lhs proc in
            let st, constrain_expr =
              constrain_expr proc st @@ BasilExpr.unfix expr
            in
            constrain st constrain_expr (TypeVar lhs))
        st al
  | Stmt.Instr_Store { lhs; rhs; addr = Scalar }
  | Stmt.Instr_Load { lhs; rhs; addr = Scalar } ->
      if String.starts_with ~prefix:"_PC" @@ Var.name lhs then st
      else
        let lhs = VarId.var_proc_to_uid lhs proc in
        let rhs = VarId.var_proc_to_uid rhs proc in
        constrain st (TypeVar rhs) (TypeVar lhs)
  | ( Stmt.Instr_Store { lhs; addr = Addr { addr; size } }
    | Stmt.Instr_Load { lhs; addr = Addr { addr; size } } ) as stmt
    when sva_res_check
           (Analysis.Sva.Eval.EV.eval
              ((flip Analysis.Sva.StateAbstraction.read) sva)
              addr)
           addr -> (
      (* Generate constraints from the addr argument *)
      let lhs = VarId.var_proc_to_uid lhs proc in
      let sva_res =
        Analysis.Sva.Eval.EV.eval
          ((flip Analysis.Sva.StateAbstraction.read) sva)
          addr
      in
      let res =
        snd @@ List.hd @@ snd @@ Analysis.Sva.SymAddrSetLattice.to_list sva_res
      in
      let offset =
        match res with
        | Interval { lower } -> Bitvec.to_signed_bigint lower
        | _ -> failwith "Impossible"
      in
      let ty = TypeVar (VarId.make_id @@ ID.name @@ gen.fresh ()) in

      match stmt with
      | Stmt.Instr_Load _ ->
          let st = ConstraintState.add_lb st lhs ty in
          let lb, ub =
            ( VarId.make_id @@ ID.name @@ gen.fresh (),
              Record (ZMap.singleton offset { size; offset; ty }, size) )
          in
          let st =
            match BasilExpr.unfix addr with
            | RVar { id } ->
                let addr = TypeVar (VarId.var_proc_to_uid id proc) in
                constrain st (Pointer (TypeVar lb, ub)) addr
            | _ -> st
          in
          let st, addr1 = constrain_expr proc st (BasilExpr.unfix addr) in
          let st = constrain st (Pointer (TypeVar lb, ub)) addr1 in
          let st = ConstraintState.add_ub st lb ub in
          let ub =
            Record (ZMap.singleton offset { size; offset; ty = BV size }, size)
          in
          let st = constrain st (Pointer (TypeVar lb, ub)) addr1 in
          ConstraintState.add_ub st lb ub
      | Stmt.Instr_Store { value } ->
          let st =
            match BasilExpr.unfix value with
            | RVar { id } ->
                let value = VarId.var_proc_to_uid id proc in
                let st = ConstraintState.add_ub st value ty in
                st
            | _ -> st
          in
          let lb, ub =
            ( Record (ZMap.singleton offset { size; offset; ty }, size),
              VarId.make_id @@ ID.name @@ gen.fresh () )
          in
          let st, _ = constrain_expr proc st (BasilExpr.unfix value) in
          let st, addr1 = constrain_expr proc st (BasilExpr.unfix addr) in
          let st = constrain st (Pointer (lb, TypeVar ub)) addr1 in
          let st =
            match BasilExpr.unfix addr with
            | RVar { id } ->
                let addr = TypeVar (VarId.var_proc_to_uid id proc) in
                constrain st (Pointer (lb, TypeVar ub)) addr
            | _ -> st
          in
          let st = ConstraintState.add_lb st ub lb in
          let lb =
            Record (ZMap.singleton offset { size; offset; ty = BV size }, size)
          in
          let st = constrain st (Pointer (lb, TypeVar ub)) addr1 in
          ConstraintState.add_lb st ub lb
      | _ -> failwith "Impossible")
  | ( Stmt.Instr_Load { lhs; addr = Addr { addr; size } }
    | Stmt.Instr_Store { lhs; addr = Addr { addr; size } } ) as stmt ->
      let lhs = TypeVar (VarId.var_proc_to_uid lhs proc) in
      let lb = TypeVar (VarId.make_id @@ ID.name @@ gen.fresh ()) in
      let ub = TypeVar (VarId.make_id @@ ID.name @@ gen.fresh ()) in
      let st, addr = constrain_expr proc st (BasilExpr.unfix addr) in
      let st = constrain st (Pointer (lb, ub)) addr in
      let st = constrain st ub lb in
      let st =
        match stmt with
        | Instr_Store { value } ->
            fst @@ constrain_expr proc st (BasilExpr.unfix value)
        | _ -> st
      in
      constrain st ub lhs
  | Stmt.Instr_Call { lhs; args; procid } ->
      let formal_in = Procedure.formal_in_params @@ Program.proc prog procid in
      let formal_out =
        Procedure.formal_out_params @@ Program.proc prog procid
      in
      let st =
        StringMap.fold
          (fun k v acc ->
            let acc, input =
              match BasilExpr.unfix v with
              | RVar { id } -> (st, TypeVar (VarId.var_procid_to_uid id procid))
              | o -> constrain_expr proc acc o
            in
            constrain acc
              (TypeVar
                 (VarId.var_procid_to_uid (StringMap.find k formal_in) procid))
              input)
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

       modifies stuff
  *)
  | Stmt.Instr_IndirectCall _ -> st

(**{2 Generate Constraints}*)

(** Given a program, generate all constraints*)
let generate_constraints prog =
  Logs.info (fun m ->
      m "Generating the constraint set" ~tags:(Logger.time_stamp ()));
  Program.procs prog
  |> Iter.fold
       (fun acc (_, proc) ->
         let sva = Analysis.Sva.DFGAnalysis.flow_insensitive proc in
         Procedure.iter_blocks_topo_fwd proc
         |> Iter.fold
              (fun acc (bid, (b : Program.bloc)) ->
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
                |> Iter.foldi
                     (fun acc stmt_number stmt ->
                       constrain_stmt prog (Some proc) sva acc stmt_number stmt
                       @@ ID.hash bid)
                     acc)
              acc)
       VarIdMap.empty

(** Given a constraint state generate two polar unconstrained types *)
let unconstrain_types type_constraint_map =
  Logs.info (fun m -> m "Coalescing types" ~tags:(Logger.time_stamp ()));
  let types =
    VarIdMap.mapi
      (fun name ({ lb; ub } : ConstraintState.TypeConstraint.t) ->
        Logs.info (fun m ->
            m "%s" (VarId.show name) ~tags:(Logger.time_stamp ()));
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
  VarIdMap.iter
    (fun k (lower, upper) ->
      Logs.debug (fun m ->
          m "VarID: %s\n\t\tLower: %s\n\t\tUpper: %s" (VarId.show k)
            (InferredType.show lower) (InferredType.show upper)
            ~tags:(Logger.time_stamp ())))
    types;
  types

(** Given unconstrained types, simplify the types using type automatas *)
let simplify_types types =
  Logs.info (fun m ->
      m "Type automata based simplification" ?header:None
        ~tags:(Logger.time_stamp ()));

  VarIdMap.fold
    (fun name (lower_ty, upper_ty) (recursives, types) ->
      let recursives2, types2 =
        let r1, t1 =
          InferredType.inferred_to_real recursives
          @@ minimise_type Polarity.Neg lower_ty name
        in
        let r2, t2 =
          InferredType.inferred_to_real recursives
          @@ minimise_type Polarity.Pos upper_ty name
        in
        (r1 @ r2, (t1, t2))
      in
      (recursives, (name, types2) :: types))
    types ([], [])

(** Passes through a given program and returns a given constraint set *)
let analyse (prog : Program.t) :
    (Types.t * Types.t) VarIdMap.t * (VarId.t * Types.t) list =
  let cons =
    Trace_core.with_span ~__FILE__ ~__LINE__
      "transform-proc::generate_constraints" (fun _ ->
        generate_constraints prog)
  in
  let types =
    Trace_core.with_span ~__FILE__ ~__LINE__ "type-inference::coalesce_types"
      (fun _ -> unconstrain_types cons)
  in
  let recursives, types =
    Trace_core.with_span ~__FILE__ ~__LINE__ "type-inference::simplification"
      (fun _ -> simplify_types types)
  in
  Logs.info (fun m ->
      m "Done type inference analysis" ~tags:(Logger.time_stamp ()));
  (VarIdMap.of_list types, recursives)

(** {1 IR Transformation}

    Actual transform to replace the types in stmt / exprs etc. with inferred
    types

    Just a series of mapping function that rewrite the IR based on the type of a
    variable on in what context it is used in *)

let get_lower_type results proc var : Types.t =
  match VarIdMap.find_opt (VarId.var_proc_to_uid var proc) results with
  | None | Some (Types.Top, _) -> Var.typ var
  | Some (a, _) -> a

let get_upper_type results proc var : Types.t =
  match VarIdMap.find_opt (VarId.var_proc_to_uid var proc) results with
  | None | Some (_, Types.Top) -> Var.typ var
  | Some (_, a) -> a

let cast arg : BasilExpr.t =
  match BasilExpr.type_of arg with
  | Pointer _ -> BasilExpr.unexp ~op:`PTRTOBV64 arg
  | Struct _ -> BasilExpr.unexp ~op:`RECTOBV arg
  | _ -> arg

let map_lvar results proc (var : Var.t) : Var.t =
  Var.create (Var.name var) ~scope:(Var.scope var)
  @@ get_upper_type results proc var

let map_var results proc (var : Var.t) : Var.t =
  Var.create (Var.name var) ~scope:(Var.scope var)
  @@ get_lower_type results proc var

let map_expr results proc =
  let expr_rewriter results proc (abstract_expr : 'e BasilExpr.abstract_expr) :
      BasilExpr.rewrite =
    match abstract_expr with
    | AbstractExpr.RVar { id; attrib } ->
        BasilExpr.replace [%here]
          (BasilExpr.rvar ?attrib:(Some attrib) @@ map_var results proc id)
    | AbstractExpr.UnaryExpr { op = `Extract (endv, offset1); arg; attrib } -> (
        (* arg is a Struct, I love structs *)
        match BasilExpr.type_of arg with
        | Types.Struct { name; fields; size } as typ ->
            let rec find_field offset1 size1 fields exp =
              match
                List.last_opt
                @@ List.find_all (fun (_, ({ offset } : Types.record_field)) ->
                    Z.leq offset @@ Z.of_int offset1)
                @@ StringMap.bindings fields
              with
              | Some (str, { typ = Types.Struct { fields; size } })
                when size <> size1 ->
                  let exp =
                    BasilExpr.unexp ?attrib:(Some attrib) ~op:(`ReadField str)
                      exp
                  in
                  find_field offset1 size1 fields exp
              | Some (str, field) ->
                  let exp =
                    BasilExpr.unexp ?attrib:(Some attrib) ~op:(`ReadField str)
                      exp
                  in
                  exp
              | None ->
                  failwith
                  @@ Printf.sprintf
                       "No such field field%d in %s for the expression %s in \
                        proc %s"
                       offset1 (Types.to_string typ)
                       (BasilExpr.to_string @@ BasilExpr.fix abstract_expr)
                       (ID.name @@ Procedure.id @@ Option.get_exn_or "" proc)
            in
            let field = find_field offset1 (endv - offset1) fields arg in
            BasilExpr.replace [%here] field
        | _ ->
            BasilExpr.replace [%here]
              (BasilExpr.unexp ?attrib:(Some attrib)
                 ~op:(`Extract (endv, offset1))
                 (cast arg)))
    | AbstractExpr.ApplyIntrin { op = `BVADD; args; attrib } -> (
        let pointer, args =
          List.fold_filter_map
            (fun acc arg ->
              match BasilExpr.type_of arg with
              | Pointer _ -> (arg :: acc, None)
              | _ -> (acc, Some arg))
            [] args
        in
        match (pointer, args) with
        | [], _ ->
            BasilExpr.replace [%here]
              (BasilExpr.applyintrin ?attrib:(Some attrib) ~op:`BVADD
                 (List.map cast args))
        | [ pointer ], [ x ] ->
            BasilExpr.replace [%here]
              (BasilExpr.binexp ?attrib:(Some attrib) ~op:`PTRADD pointer x)
        | [ pointer ], x :: tl ->
            BasilExpr.replace [%here]
              (BasilExpr.binexp ?attrib:(Some attrib) ~op:`PTRADD pointer
                 (BasilExpr.applyintrin ?attrib:(Some attrib) ~op:`BVADD args))
        | x, _ ->
            failwith
            @@ Printf.sprintf "Two or more pointer types adding, ptrs: %s"
            @@ List.fold_left
                 (fun acc a -> acc ^ " " ^ BasilExpr.to_string a)
                 "" x)
    | AbstractExpr.BinaryExpr { op = `BVSUB; arg1; arg2; attrib } -> (
        match (BasilExpr.type_of arg1, BasilExpr.type_of arg2) with
        | Types.Pointer _, Types.Pointer _ ->
            failwith "Two or more pointer types adding"
        | Types.Pointer _, _ ->
            BasilExpr.replace [%here]
              (BasilExpr.binexp ?attrib:(Some attrib) ~op:`PTRADD arg1
                 (BasilExpr.unexp ?attrib:(Some attrib) ~op:`BVNEG arg2))
        | _, Types.Pointer _ ->
            BasilExpr.replace [%here]
              (BasilExpr.binexp ?attrib:(Some attrib) ~op:`PTRADD arg2
                 (BasilExpr.unexp ?attrib:(Some attrib) ~op:`BVNEG arg1))
        | _ ->
            BasilExpr.replace [%here]
              (BasilExpr.binexp ?attrib:(Some attrib) ~op:`BVSUB (cast arg1)
                 (cast arg2)))
    (*
      THESE OPERATIONS ARE NOT DEFINED OVER POINTERS OR RECORDS

      THEY SHOULD BE CAST TO BV IF THEY APPEAR
    *)
    | AbstractExpr.UnaryExpr { op; arg; attrib } ->
        BasilExpr.replace [%here]
          (BasilExpr.unexp ?attrib:(Some attrib) ~op (cast arg))
    | AbstractExpr.BinaryExpr { op; arg1; arg2; attrib } ->
        BasilExpr.replace [%here]
          (BasilExpr.binexp ?attrib:(Some attrib) ~op (cast arg1) (cast arg2))
    | AbstractExpr.ApplyIntrin { op; args; attrib } ->
        BasilExpr.replace [%here]
          (BasilExpr.applyintrin ?attrib:(Some attrib) ~op (List.map cast args))
    | _ -> BasilExpr.Keep
  in
  BasilExpr.rewrite ~rw_fun:(expr_rewriter results proc)

let map_stmt results proc (stmt : Program.stmt) : Program.stmt =
  match stmt with
  | Stmt.Instr_Assign { al; attrib } ->
      Stmt.Instr_Assign
        {
          attrib;
          al =
            List.map
              (fun (lvar, expr) ->
                (map_lvar results proc lvar, map_expr results proc expr))
              al;
        }
  | Stmt.Instr_Assume { body; branch; attrib } ->
      Stmt.Instr_Assume { branch; body = map_expr results proc body; attrib }
  | Stmt.Instr_Assert { body; attrib } ->
      Stmt.Instr_Assert { attrib; body = map_expr results proc body }
  | Stmt.Instr_Load { lhs; rhs; addr = Scalar; attrib } ->
      Stmt.Instr_Load
        {
          lhs = map_lvar results proc lhs;
          rhs = map_var results proc rhs;
          addr = Scalar;
          attrib;
        }
  | Stmt.Instr_Load { lhs; rhs; addr = Addr { addr; size; endian }; attrib } ->
      Stmt.Instr_Load
        {
          lhs = map_lvar results proc lhs;
          rhs = map_var results proc rhs;
          addr = Addr { size; endian; addr = map_expr results proc addr };
          attrib;
        }
  | Stmt.Instr_Store { lhs; rhs; value; addr = Scalar; attrib } ->
      Stmt.Instr_Store
        {
          lhs = map_lvar results proc lhs;
          rhs = map_var results proc rhs;
          value = map_expr results proc value;
          addr = Scalar;
          attrib;
        }
  | Stmt.Instr_Store
      { lhs; rhs; value; addr = Addr { addr; size; endian }; attrib } ->
      Stmt.Instr_Store
        {
          lhs = map_lvar results proc lhs;
          rhs = map_var results proc rhs;
          addr = Addr { size; endian; addr = map_expr results proc addr };
          value = map_expr results proc value;
          attrib;
        }
  | Stmt.Instr_IntrinCall { lhs; args; name; attrib } ->
      Stmt.Instr_IntrinCall
        {
          lhs = List.map (map_lvar results proc) lhs;
          args = List.map (map_expr results proc) args;
          name;
          attrib;
        }
  | Stmt.Instr_Call { lhs; procid; args; attrib } ->
      Stmt.Instr_Call
        {
          lhs = StringMap.map (map_lvar results proc) lhs;
          args = StringMap.map (map_expr results proc) args;
          procid;
          attrib;
        }
  | Stmt.Instr_IndirectCall { target; attrib } ->
      Stmt.Instr_IndirectCall { target = map_expr results proc target; attrib }

let map_decl results proc (decl : Program.declaration) : Program.declaration =
  match decl with
  (* Leave type decls alone, could have a pass that removes dead ones *)
  | Program.Type _ -> decl
  | Program.Function { definition; attrib; binding } ->
      Function
        {
          attrib;
          binding = map_var results proc binding;
          definition =
            (match definition with
            | Axiom e -> Axiom (map_expr results proc e)
            | Function e -> Function (map_expr results proc e)
            | Uninterpreted -> Uninterpreted);
        }
  | Program.Variable { binding; attrib; classification } ->
      Variable
        { binding = map_var results proc binding; attrib; classification }
  | Program.Procedure { definition = proc } ->
      let definition =
        Procedure.map_formal_in_params
          (StringMap.map (map_lvar results (Some proc)))
        @@ Procedure.map_formal_out_params
             (StringMap.map (map_var results (Some proc)))
        @@ Procedure.map_blocks_nondet
             (fun (id, block) ->
               Block.map
                 ~phi:
                   (List.map (fun ({ lhs; rhs } : Var.t Block.phi) ->
                        ({
                           lhs = map_lvar results (Some proc) lhs;
                           rhs =
                             List.map
                               (fun (id, var) ->
                                 (id, map_var results (Some proc) var))
                               rhs;
                         }
                          : Var.t Block.phi)))
                 (fun stmt -> map_stmt results (Some proc) stmt)
                 block)
             proc
      in
      Procedure { definition }

let rec declare_typ (typ : Types.t) acc : (string * Types.t) option list =
  match typ with
  | Struct { name; fields } ->
      Some (name, typ)
      :: StringMap.fold
           (fun _ ({ typ } : Types.record_field) acc -> declare_typ typ acc)
           fields acc
  | Pointer { lower; upper } -> declare_typ lower (declare_typ upper acc)
  | _ -> None :: acc

let declare_recursive_typs (recursives : (VarId.t * Types.t) list) :
    (string * Program.declaration) list =
  List.map
    (fun (varid, typ) ->
      let binding = VarId.show varid in
      (binding, (Type { typ; binding } : Program.declaration)))
    recursives

let transform (prog : Program.t) (results : (Types.t * Types.t) VarIdMap.t)
    (recursives : (VarId.t * Types.t) list) : Program.t =
  Logs.info (fun m ->
      m "Starting type inference transform" ~tags:(Logger.time_stamp ()));
  let decls =
    List.fold_left
      (fun acc (id, (l, u)) ->
        let name1 = declare_typ l [] in
        let name2 = declare_typ u [] in
        name1 @ name2 @ acc)
      [] (VarIdMap.to_list results)
    |> List.filter_map (fun a ->
        match a with
        | Some (binding, typ) ->
            Some (Type { typ; binding } : Program.declaration)
        | None -> None)
  in
  Program.map_decls (fun _ s -> map_decl results None s) prog |> fun prog ->
  List.fold_left (fun prog decl -> Program.add_decl prog decl) prog
  @@ List.sort
       (fun a b ->
         match (a, b) with
         | Program.Type { binding; _ }, Type { binding = binding2; _ } ->
             String.compare binding binding2
         | _ -> failwith "Unreachable")
       decls

let infer_types (prog : Program.t) =
  let a, b =
    Trace_core.with_span ~__FILE__ ~__LINE__ "type-inference::analyse"
    @@ fun _ -> analyse prog
  in
  let prog =
    Trace_core.with_span ~__FILE__ ~__LINE__ "type-inference::transform"
      (fun _ -> transform prog a b)
  in
  prog

(*

  Useful things to note before reading the code:

    Negative polarity
      - Stores
      - Upper bounds
      - Intersection

    Positive polarity
      - Loads
      - Lower bounds
      - Union

  Paper this work is based on: https://arxiv.org/abs/2409.01841




  TODO:
    Ask if I should make it more general and work with less type information
      or should prio speed / space instead
*)

open Bincaml_util.Common
open Lang
open Expr

module Polarity = struct
  type t = Pos | Neg [@@deriving ord, eq, show]

  let not p = match p with Pos -> Neg | Neg -> Pos
  let positive = equal Pos
end

(* NOTE: Sig is needed to string and t can't be the same type *)
module VarId : sig
  type t

  val compare : t -> t -> int
  val equal : t -> t -> bool
  val show : t -> string
  val var_proc_to_uid : Var.t -> Program.proc -> t
  val var_procid_to_uid : Var.t -> ID.t -> t
  val make_id : string -> t
end = struct
  type t = string

  let compare = String.compare
  let equal = String.equal
  let show = id

  let var_procid_to_uid (var : Var.t) (procId : ID.t) : t =
    if Var.is_global var then Var.name var
    else ID.name procId ^ "_" ^ Var.name var

  let var_proc_to_uid (var : Var.t) (proc : Program.proc) : t =
    var_procid_to_uid var (Procedure.id proc)

  let make_id hint = hint
end

module VarIdMap = Map.Make (VarId)

module CType = struct
  type t = C_Int | C_BV of int | C_Bool [@@deriving ord, eq]

  let show = function
    | C_Int -> "int"
    | C_BV size -> "bv" ^ string_of_int size
    | C_Bool -> "bool"

  let c_to_type : t -> Types.t = function
    | C_Int -> Types.Integer
    | C_BV sz -> Types.Bitvector sz
    | C_Bool -> Types.Boolean
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
    | Field of field
    | Record of field list (* A list of fields in the record *)
    | TypeVar of VarId.t
    | Recursive of t * t
    | CType of CType.t

  and field = { offset : Z.t; size : int; ty : t }

  let rec show = function
    | Top -> "⊤"
    | Bottom -> "⊥"
    | CType c -> CType.show c
    | TypeVar id -> Printf.sprintf "%s" @@ VarId.show id
    | Recursive (t1, t2) -> Printf.sprintf "μ%s.%s" (show t1) (show t2)
    | Union (t1, t2) -> Printf.sprintf "%s ⊔ %s" (show t1) (show t2)
    | Sect (t1, t2) -> Printf.sprintf "%s ⊓ %s" (show t1) (show t2)
    | Pointer (lb, ub) -> Printf.sprintf "ptr(%s, %s)" (show lb) (show ub)
    | Function (name, ins, outs) ->
        Printf.sprintf "(%s) → (%s)"
          (Iter.to_string show (StringMap.values ins))
          (Iter.to_string show (StringMap.values outs))
    | Field field -> show_field field
    | Record fields ->
        Printf.sprintf "{ %s }" @@ List.to_string show_field fields

  and show_field { offset; size; ty } =
    Printf.sprintf "(%s, %d): %s" (Z.to_string offset) size (show ty)

  let rec compare type1 type2 =
    match (type1, type2) with
    | Top, Top | Bottom, Bottom -> 0
    | CType a, CType b -> CType.compare a b
    | TypeVar a, TypeVar b -> VarId.compare a b
    | Recursive (a, b), Recursive (c, d) ->
        let c = compare a c in
        if c <> 0 then c else compare b d
    | Union (a, b), Union (a2, b2) ->
        let c = compare a a2 in
        if c <> 0 then c else compare b b2
    | Sect (a, b), Sect (a2, b2) ->
        let c = compare a a2 in
        if c <> 0 then c else compare b b2
    | Pointer (a, b), Pointer (a2, b2) ->
        let c = compare a a2 in
        if c <> 0 then c else compare b b2
    | Function (name, ins, outs), Function (name2, ins2, outs2) ->
        let c = String.compare name name2 in
        if c <> 0 then c
        else
          let c = StringMap.compare compare ins ins2 in
          if c <> 0 then c else StringMap.compare compare outs outs2
    | ( Field { offset; size; ty },
        Field { offset = offset2; size = size2; ty = ty2 } ) ->
        let c = Z.compare offset offset2 in
        if c <> 0 then c
        else
          let c = Int.compare size size2 in
          if c <> 0 then c else compare ty ty2
    | Record fields, Record fields2 ->
        List.compare (fun { ty } { ty = ty2 } -> compare ty ty2) fields fields2
    | _ -> 1

  let equal a b = Stdlib.( == ) 0 @@ compare a b

  let rec iter f (ty : t) =
    f ty;
    match ty with
    | Top | Bottom | CType _ | TypeVar _ | Recursive _ -> ()
    | Union (a, b) | Sect (a, b) ->
        iter f b;
        iter f a
    | Pointer (lb, ub) ->
        iter f ub;
        iter f lb
    | Function (_, ins, outs) ->
        StringMap.iter (fun _ v -> iter f v) ins;
        StringMap.iter (fun _ v -> iter f v) outs
    | Field { ty } -> iter f ty
    | Record fields -> List.iter (fun { ty } -> iter f ty) fields

  let rec inferred_to_real : t -> Types.t = function
    | Top | Bottom | TypeVar _ | Recursive _ | Union _ | Sect _ | Function _ ->
        failwith "These types should have been removed prior to transform!"
    | Pointer (lb, ub) -> Types.Integer
    | Record fields -> Types.Boolean
    | CType a -> CType.c_to_type a
    | Field { ty } -> inferred_to_real ty
end

module TySet = struct
  module S = Set.Make (struct
    type t = InferredType.t

    let compare = InferredType.compare
  end)

  include S

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

  let export_graph_viz (t : t) : string =
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
                 Printf.sprintf "%s\"%s\" -> \"%s\" [];\n" acc (VarId.show k)
                   (InferredType.show ty))
               lb acc
           in
           TySet.fold
             (fun ty acc ->
               Printf.sprintf "%s\"%s\" -> \"%s\" [];\n" acc
                 (InferredType.show ty) (VarId.show k))
             ub acc)
         t "")
end

module Sigma = struct
  type t =
    | Ep
    | StoreLabel
    | LoadLabel
    | Reclabel of Z.t * int
    | FnIn of string
    | FnOut of string

  let show = function
    | Ep -> "ε"
    | StoreLabel -> "Store Label"
    | LoadLabel -> "Load Label"
    | Reclabel (n, m) -> Printf.sprintf "Record Label %s %d" (Z.to_string n) m
    | FnIn n -> Printf.sprintf "Function in %s" n
    | FnOut n -> Printf.sprintf "Function out %s" n

  let equal a b =
    match (a, b) with
    | Ep, Ep | StoreLabel, StoreLabel | LoadLabel, LoadLabel -> true
    | Reclabel (n, m), Reclabel (n1, m1) -> Z.equal n n1 && m = m1
    | FnIn n, FnIn n1 | FnOut n, FnOut n1 -> String.equal n n1
    | _ -> false

  let is_epislon = equal Ep
end

module State = struct
  type t = Polarity.t * InferredType.t

  let equal (p1, ty1) (p2, ty2) =
    InferredType.equal ty1 ty2 && Polarity.equal p1 p2
end

module TypeAutomata = struct
  type t = {
    mutable states : State.t list;
    transitions : (State.t, (Sigma.t, State.t) Hashtbl.t) Hashtbl.t;
    start : State.t;
    name : string;
  }

  open struct
    let set_states m qs = m.states <- qs
    let add_state m (s : State.t) = set_states m (s :: m.states)

    let get_transitions m =
      Hashtbl.fold
        (fun s ats acc ->
          Hashtbl.fold (fun a t acc' -> (s, a, t) :: acc') ats acc)
        m.transitions []

    let get_next_states m s =
      match Hashtbl.find_opt m.transitions s with
      | None -> Iter.empty
      | Some states -> Hashtbl.values states

    let get_prev_states m t =
      Hashtbl.fold
        (fun s v acc ->
          Hashtbl.fold
            (fun a' t' acc' -> if State.equal t t' then s :: acc' else acc')
            v acc)
        m.transitions []

    let filter_states_inplace m f =
      set_states m (List.filter f m.states);
      Hashtbl.filter_map_inplace
        (fun s ts -> if f s then Some ts else None)
        m.transitions
  end

  let remove_ep m =
    let rec helper acc current_state =
      (* Do the lower states first, I am scared about what happens if loop *)
      let acc = Iter.fold helper acc @@ get_next_states m current_state in
      let acc =
        match Hashtbl.find_opt m.transitions current_state with
        | None -> acc
        | Some edges ->
            Hashtbl.fold
              (fun edge end_state acc ->
                if not @@ Sigma.is_epislon edge then acc
                (* There exists a epislon edge from start -> end *)
                  else
                  let orphans = Hashtbl.find_all m.transitions end_state in
                  Hashtbl.remove m.transitions end_state;
                  List.iter (Hashtbl.iter (Hashtbl.add edges)) orphans;
                  end_state :: acc)
              edges acc
      in
      match Hashtbl.find_opt m.transitions current_state with
      | None -> acc
      | Some edges ->
          let eps = Hashtbl.find_all edges Ep in
          for i = 0 to List.length eps do
            Hashtbl.remove (Hashtbl.find m.transitions current_state) Ep
          done;
          acc
    in
    let removal = helper [] m.start in
    filter_states_inplace m (fun state ->
        not
        @@ List.mem
             ~eq:(fun (p1, ty1) (p2, ty2) ->
               InferredType.equal ty1 ty2 && Polarity.equal p1 p2)
             state removal)

  let merge_nodes m =
    let rec join (ty0 : InferredType.t) (ty1 : InferredType.t) : InferredType.t
        =
      match (ty0, ty1) with
      | Record fields0, Record fields1 ->
          (* WARN: I think this could be improved, cause this is gross *)
          let module FieldMap = Map.Make (struct
            type t = Z.t * int

            let compare = Stdlib.compare
          end) in
          let fieldmap_to_field_list (map : InferredType.t FieldMap.t) =
            FieldMap.bindings map
            |> List.map (fun ((offset, size), ty) ->
                ({ offset; size; ty } : InferredType.field))
          in
          let fieldmap_of_list (fields : InferredType.field list) :
              InferredType.t FieldMap.t =
            List.fold_left
              (fun acc ({ offset; size; ty } : InferredType.field) ->
                FieldMap.add (offset, size) ty acc)
              FieldMap.empty fields
          in
          let f0 = fieldmap_of_list fields0 in
          let f1 = fieldmap_of_list fields1 in
          let joined_map =
            FieldMap.merge_safe
              ~f:(fun (offset, size) v ->
                match v with
                | `Both (a, b) -> Some (InferredType.Union (a, b))
                | `Left a | `Right a -> Some a)
              f0 f1
          in
          Record (fieldmap_to_field_list joined_map)
      | Pointer (a, b), Pointer (c, d) ->
          (* ptr((a u c) n (b n d), (b n d)) *)
          Pointer (join (Union (a, c)) (join b d), join b d)
      (* WARN: this is not how BinSub did it, but I think I am just smarter and had better DS *)
      | Function (name0, ins0, outs0), Function (name1, ins1, outs1) ->
          if not @@ String.equal name0 name1 then
            failwith
              "Function names do not match and a join between them occured"
          else
            (* args are the same just just union over the args *)
            let ins =
              StringMap.merge_safe
                ~f:(fun _ b ->
                  match b with
                  | `Both (l, r) -> Some (join l r)
                  | _ ->
                      failwith "Function declartion differs to function usage")
                ins0 ins1
            in
            Function (name0, ins, outs0)
      | a, Bottom | Bottom, a -> a
      | _ -> Sect (ty0, ty1)
    in
    let rec helper current_state =
      Iter.iter helper @@ get_next_states m current_state;
      match Hashtbl.find_opt m.transitions current_state with
      | None -> ()
      | Some edges ->
          Iter.iter (fun edge ->
              let curr_states = Hashtbl.find_all edges edge in
              if List.length curr_states <= 1 then ()
              else (
                set_states m
                  (List.filter
                     (fun state ->
                       not @@ List.mem ~eq:State.equal state curr_states)
                     m.states);
                let new_tbl = Hashtbl.create 2 in
                let new_state =
                  List.fold_left
                    (fun (_, new_typ) ((p, typ) as end_state) ->
                      let orphans = Hashtbl.find_all m.transitions end_state in
                      List.iter (Hashtbl.iter (Hashtbl.replace new_tbl)) orphans;
                      Hashtbl.remove edges edge;
                      Hashtbl.remove m.transitions end_state;
                      (p, join typ new_typ))
                    (Polarity.Pos, InferredType.Bottom)
                  @@ curr_states
                in
                Hashtbl.add edges edge new_state;
                Hashtbl.add m.transitions new_state new_tbl;
                add_state m new_state))
          @@ Hashtbl.keys edges
    in
    helper m.start

  let rec type_to_state_list p (ty : InferredType.t) ((ls, tbl) as acc) =
    let open Sigma in
    match ty with
    | Top | CType _ | TypeVar _ | Bottom | Field _ -> ((p, ty) :: ls, tbl)
    | Recursive (a, _) ->
        let ls, tbl = type_to_state_list p a acc in
        let edges = Hashtbl.create 1 in
        Hashtbl.add edges Sigma.Ep (p, a);
        Hashtbl.add tbl (p, ty) edges;
        ((p, ty) :: ls, tbl)
    | Union (a, b) | Sect (a, b) ->
        let ((ls, tbl) as acc) = type_to_state_list p a acc in
        let ls, tbl = type_to_state_list p b acc in
        let edges = Hashtbl.create 2 in
        Hashtbl.add edges Ep (p, a);
        Hashtbl.add edges Ep (p, b);
        Hashtbl.add tbl (p, ty) edges;
        ((p, ty) :: ls, tbl)
    | Function (_, ins, outs) ->
        let acc =
          StringMap.fold (fun _ -> type_to_state_list @@ Polarity.not p) ins acc
        in
        let ls, tbl = StringMap.fold (fun _ -> type_to_state_list p) outs acc in
        let edges = Hashtbl.create 30 in
        List.iter (fun (n, ty) ->
            Hashtbl.add edges (FnIn n) (Polarity.not p, ty))
        @@ StringMap.to_list ins;
        List.iter (fun (n, ty) -> Hashtbl.add edges (FnOut n) (p, ty))
        @@ StringMap.to_list outs;
        Hashtbl.add tbl (p, ty) edges;
        ((p, ty) :: ls, tbl)
    | Pointer (a, b) ->
        let ((ls, tbl) as acc) = type_to_state_list (Polarity.not p) a acc in
        let ls, tbl = type_to_state_list p b acc in
        let edges = Hashtbl.create 2 in
        Hashtbl.add edges StoreLabel (Polarity.not p, a);
        Hashtbl.add edges LoadLabel (p, b);
        Hashtbl.add tbl (p, ty) edges;
        ((p, ty) :: ls, tbl)
    | Record fields ->
        let ls, tbl =
          List.fold_left
            (fun acc ({ ty } : InferredType.field) ->
              type_to_state_list p ty acc)
            acc fields
        in
        let edges = Hashtbl.create 4 in
        List.iter
          (fun ({ offset; size; ty } : InferredType.field) ->
            Hashtbl.add edges (Reclabel (offset, size)) (p, ty))
          fields;
        Hashtbl.add tbl (p, ty) edges;
        ((p, ty) :: ls, tbl)

  let create_type_automata polarity ty init name =
    let states, transitions =
      type_to_state_list polarity ty ([], Hashtbl.create 10)
    in
    { states; transitions; start = init; name }

  let export_graphviz n =
    Printf.sprintf
      "\n\
       digraph G {\n\
      \ \"%s\" [height=0, width=0, style=filled, fillcolor=\"#c4a7e7\" ]\n\
       %s\n\
       \"%s\" -> %s;\n\
       %s\n\
       }"
      n.name
      (List.fold_left
         (fun a (polarity, typ) ->
           let shape =
             if Polarity.positive polarity then "house" else "invhouse"
           in
           Printf.sprintf
             "%s\"%s\" [shape=%s style=filled, fillcolor=\"#c4a7e7\"];\n" a
             (InferredType.show @@ typ) shape)
         "" n.states)
      n.name
      (Printf.sprintf "\"%s\"" @@ InferredType.show @@ snd n.start)
      (List.fold_left
         (fun acc ((_, s), a, (_, t)) ->
           Printf.sprintf "%s\"%s\" -> \"%s\" [label=\"%s\", ];\n" acc
             (InferredType.show s) (InferredType.show t)
           @@ Sigma.show a)
         "" (get_transitions n))
end

let gen = ID.make_gen ()

let minimise_type p ty name =
  let recursives = Hashtbl.create 2 in
  InferredType.iter
    (fun ty ->
      match ty with
      | InferredType.Recursive (a, b) -> Hashtbl.add recursives a (gen.fresh ())
      | _ -> ())
    ty;
  let automata =
    TypeAutomata.create_type_automata p ty (p, ty) (VarId.show name)
  in
  TypeAutomata.remove_ep automata;
  TypeAutomata.merge_nodes automata;
  automata

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

  Coalesce starting at 'a', with negative polarity (upper bounds) would be
    b n c
  Coalesce starting at 'a', with positive polarity (upper bounds) would be
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
        (List.map
           (fun { size; offset; ty } ->
             { size; offset; ty = recursive_call polarity ty })
           fields)
  | Field { ty } -> recursive_call polarity ty
  | Pointer (a, b) ->
      Pointer
        (recursive_call (Polarity.not polarity) a, recursive_call polarity b)
  | Function (name, ins, outs) ->
      (* This might be useless, but just in case there are exprs in function calls *)
      Function
        ( name,
          StringMap.map (recursive_call polarity) ins,
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
          if rec_check then Recursive (tau, s) else s)
  | CType _ -> tau
  | _ -> Top

(*
  Given a statement constrain the variables involed (based on the expression)

  Prefer giving upper bounds when possible
*)
let gen_constraint_set prog proc sva (st : ConstraintState.t) stmt_number stmt =
  let open AbstractExpr in
  let open InferredType in
  (* Given a expression constrain the variables involed *)
  let rec constrain_expr (st : ConstraintState.t)
      (expr : 'e BasilExpr.abstract_expr) =
    let constrain_arg st l t =
      let l = BasilExpr.unfix l in
      match l with
      | RVar { id } ->
          ConstraintState.add_lb st (VarId.var_proc_to_uid id proc) t
      | _ -> st
    in
    let constrain_args st l r t =
      let st = constrain_arg st l t in
      constrain_arg st r t
    in
    match expr with
    | RVar { id } ->
        let typ =
          match Var.typ id with
          | Integer -> CType C_Int
          | Boolean -> CType C_Bool
          | Bitvector sz -> CType (C_BV sz)
          | _ -> failwith "Illegal variable type"
        in
        ( constrain_arg st (BasilExpr.fix expr) typ,
          TypeVar (VarId.var_proc_to_uid id proc) )
    | Constant { const } ->
        ( st,
          match const with
          | `Bool _ -> CType C_Bool
          | `Bitvector bv -> CType (C_BV (Bitvec.size bv))
          | `Integer _ -> CType C_Int )
    | UnaryExpr { op; arg = a } -> (
        let st, _ = constrain_expr st (BasilExpr.unfix a) in
        match op with
        | `BoolNOT -> (constrain_arg st a @@ CType C_Bool, CType C_Bool)
        | `BOOLTOBV1 -> (constrain_arg st a @@ CType C_Bool, CType (C_BV 1))
        | `INTNEG -> (constrain_arg st a @@ CType C_Int, CType C_Int)
        | `BVNEG | `BVNOT ->
            let typ =
              match BasilExpr.type_of a with
              | Bitvector size -> CType (C_BV size)
              | _ -> failwith "Bitvector operation without bitvector arguments"
            in
            (constrain_arg st a @@ typ, typ)
        | `SignExtend b | `ZeroExtend b ->
            let size =
              match BasilExpr.type_of a with
              | Bitvector size -> size
              | _ -> failwith "Bitvector operation without bitvector arguments"
            in
            (constrain_arg st a @@ CType (C_BV size), CType (C_BV (size + b)))
        | `Exists -> (st, CType C_Bool) (* TODO: Confirm *)
        | `Old -> (st, Top)
        | `Forall -> (st, Top)
        | `Lambda | `Classification | `Gamma -> (st, Top)
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
            let st = ConstraintState.add_lb st name (CType (C_BV size)) in
            (constrain_arg st a @@ Record [ field ], Field field))
    | BinaryExpr { op; arg1 = l; arg2 = r } -> (
        let st, _ = constrain_expr st (BasilExpr.unfix l) in
        let st, _ = constrain_expr st (BasilExpr.unfix r) in
        match op with
        | `INTMOD | `INTSUB | `INTDIV | `INTADD | `INTMUL ->
            let st = constrain_args st l r @@ CType C_Int in
            (st, CType C_Int)
        | `NEQ | `EQ -> (
            match (BasilExpr.unfix l, BasilExpr.unfix r) with
            | RVar { id = a }, RVar { id = b } ->
                let a_id = VarId.var_proc_to_uid a proc in
                let b_id = VarId.var_proc_to_uid b proc in
                let st = ConstraintState.add_lb st a_id (TypeVar b_id) in
                let st = ConstraintState.add_ub st a_id (TypeVar b_id) in
                let st = ConstraintState.add_lb st b_id (TypeVar a_id) in
                let st = ConstraintState.add_ub st b_id (TypeVar a_id) in
                (st, CType C_Bool)
            | RVar { id }, a | a, RVar { id } ->
                let id = VarId.var_proc_to_uid id proc in
                let st, expr = constrain_expr st a in
                let st = ConstraintState.add_lb st id expr in
                let st = ConstraintState.add_ub st id expr in
                (st, CType C_Bool)
            | _, _ -> (st, CType C_Bool))
        | `INTLT | `INTLE ->
            let st = constrain_args st l r @@ CType C_Int in
            (st, CType C_Bool)
        | `BVULE | `BVULT | `BVSLE | `BVSLT -> (
            match BasilExpr.type_of l with
            | Bitvector size ->
                let st = constrain_args st l r @@ CType (C_BV size) in
                (st, CType C_Bool)
            | _ -> failwith "BV operation without BV arguments")
        | `BVSREM | `BVSDIV | `BVADD | `BVMUL | `BVUREM | `BVSUB | `BVUDIV
        | `BVSMOD | `BVSHL | `BVLSHR | `BVASHR | `BVNAND | `BVAND | `BVXOR
        | `BVOR -> (
            match BasilExpr.type_of l with
            | Bitvector size ->
                let typ = CType (C_BV size) in
                let st = constrain_args st l r typ in
                (st, typ)
            | _ -> failwith "BV operation without BV arguments")
        (* WARN: I forgot what this was meant to be *)
        | `IMPLIES -> (st, Top)
        | `Load _ | `IfThen | `MapAccess -> (st, Top))
    (* TODO: Do intrins *)
    | ApplyIntrin { op; args } -> (
        match op with
        (* output is constrain by every input, heurtistic deals with offset + ptr *)
        | `BVADD -> (st, Top)
        (* Maybe combine the bottom two cases *)
        | `BVOR | `BVXOR | `BVAND ->
            (st, Top) (* All types need to be the same *)
        | `OR | `AND -> (st, Top) (* All types need to be the same *)
        | `Cases -> (st, Top)
        | `BVConcat -> (st, Top))
    | ApplyFun _ -> (st, Top)
    | Binding _ -> (st, Top)
  in

  (*
    WARN: Not certain on this recurence check but seems to work

    Idea behind it is, if a variable has been constrained by another variable already
      there is no need to do it again.

    Transistive closure will be maintained as anything new being in added in, would be
      constrained as it is being added in anyway.
  *)
  let rec constrain (st : ConstraintState.t) (type0 : InferredType.t)
      (type1 : InferredType.t) : ConstraintState.t =
    match (type0, type1) with
    | Top, _ | _, Top | Bottom, _ | _, Bottom -> st
    | Pointer (type0_a, type0_b), Pointer (type1_a, type1_b) ->
        constrain (constrain st type1_a type0_a) type0_b type1_b
    | _, Pointer (type1_a, type1_b) ->
        constrain (constrain st type0 type1_a) type0 type1_b
    | TypeVar a, TypeVar b -> (
        if VarId.equal a b then st
        else
          let st = ConstraintState.add_ub st a type1 in
          let bounds = VarIdMap.get a st in
          match bounds with
          | Some { lb } ->
              TySet.to_iter lb
              |> Iter.fold (fun st bound -> constrain st bound type1) st
          | None -> st)
    | Field { ty }, TypeVar b -> (
        match ty with
        | TypeVar a -> (
            let st = ConstraintState.add_ub st a type1 in
            let bounds = VarIdMap.get a st in
            match bounds with
            | Some { lb } ->
                TySet.to_iter lb
                |> Iter.fold (fun st bound -> constrain st bound type1) st
            | None -> st)
        | _ -> st)
    | _, TypeVar a -> (
        if ConstraintState.check_bounded st a type0 Polarity.Neg then st
        else
          (* The right hand side is not a type variable *)
          let st = ConstraintState.add_lb st a type0 in
          let bounds = VarIdMap.get a st in
          match bounds with
          | Some { ub } ->
              TySet.to_iter ub
              |> Iter.fold (fun st bound -> constrain st type0 bound) st
          | None -> st)
    | _ ->
        (*
          You have to assign to a variable (or something similar) so this case should never occur

          Very restricting having this fail, would be nice just to ignore it
        *)
        failwith
          (Printf.sprintf "Illegal constrain call type0: %s; type1: %s stmt: %s"
             (InferredType.show type0) (InferredType.show type1)
             (Program.show_stmt stmt))
  in
  match stmt with
  | Stmt.Instr_Assert { body } | Stmt.Instr_Assume { body } -> (
      let st, constrain_expr = constrain_expr st (BasilExpr.unfix body) in
      match constrain_expr with
      | TypeVar a -> ConstraintState.add_lb st a (CType C_Bool)
      | _ -> st)
  | Stmt.Instr_Assign ls ->
      List.fold_left
        (fun st (lhs, expr) ->
          (* Ignore _PC variables *)
          if String.starts_with ~prefix:"_PC" @@ Var.name lhs then st
          else
            let lhs = VarId.var_proc_to_uid lhs proc in
            let st, constrain_expr =
              constrain_expr st @@ BasilExpr.unfix expr
            in
            constrain st constrain_expr (TypeVar lhs))
        st ls
  (* TODO: SVA *)
  | Stmt.Instr_Store { lhs; rhs; addr = Scalar }
  | Stmt.Instr_Load { lhs; rhs; addr = Scalar } ->
      if String.starts_with ~prefix:"_PC" @@ Var.name lhs then st
      else
        let lhs = VarId.var_proc_to_uid lhs proc in
        let rhs = VarId.var_proc_to_uid rhs proc in
        constrain st (TypeVar rhs) (TypeVar lhs)
  | Stmt.Instr_Load { lhs; rhs; addr = Addr { addr; size } } ->
      let sva_res =
        Analysis.Sva.Eval.EV.eval
          ((flip Analysis.Sva.StateAbstraction.read) sva)
          addr
      in
      let lhs = VarId.var_proc_to_uid lhs proc in
      if
        (* If there is more than one entry or it is top / bot, there is no info *)
        Analysis.Sva.SymAddrSetLattice.cardinal sva_res <> 1
        || Analysis.Wrapped_intervals.WrappedIntervalsLattice.equal
             (snd @@ List.hd @@ snd
             @@ Analysis.Sva.SymAddrSetLattice.to_list sva_res)
             Analysis.Wrapped_intervals.WrappedIntervalsLattice.Top
        || Analysis.Wrapped_intervals.WrappedIntervalsLattice.equal
             (snd @@ List.hd @@ snd
             @@ Analysis.Sva.SymAddrSetLattice.to_list sva_res)
             Analysis.Wrapped_intervals.WrappedIntervalsLattice.Bot
      then
        (*
          No information case

          Simply just a ptr(a,b) where a <= b
        *)
        let lb = VarId.make_id @@ Int.to_string stmt_number ^ "_a_load" in
        let ub = VarId.make_id @@ Int.to_string stmt_number ^ "_b_load" in
        let st =
          ConstraintState.add_ub st lhs (Pointer (TypeVar lb, TypeVar ub))
        in
        ConstraintState.add_ub st lb @@ TypeVar ub
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
        let lb = VarId.make_id @@ Int.to_string stmt_number ^ "_a_load" in
        let ty =
          TypeVar (VarId.make_id @@ Int.to_string stmt_number ^ "_b_load")
        in
        let ub = Record [ { size; offset; ty } ] in
        let st = ConstraintState.add_ub st lhs (Pointer (TypeVar lb, ub)) in
        ConstraintState.add_ub st lb ub
  | Stmt.Instr_Store { lhs; rhs; addr = Addr { addr; size } } ->
      let sva_res =
        Analysis.Sva.Eval.EV.eval
          ((flip Analysis.Sva.StateAbstraction.read) sva)
          addr
      in
      let lhs = VarId.var_proc_to_uid lhs proc in
      if
        (* If there is more than one entry or it is top / bot, there is no info *)
        Analysis.Sva.SymAddrSetLattice.cardinal sva_res <> 1
        || Analysis.Wrapped_intervals.WrappedIntervalsLattice.equal
             (snd @@ List.hd @@ snd
             @@ Analysis.Sva.SymAddrSetLattice.to_list sva_res)
             Analysis.Wrapped_intervals.WrappedIntervalsLattice.Top
        || Analysis.Wrapped_intervals.WrappedIntervalsLattice.equal
             (snd @@ List.hd @@ snd
             @@ Analysis.Sva.SymAddrSetLattice.to_list sva_res)
             Analysis.Wrapped_intervals.WrappedIntervalsLattice.Bot
      then
        (*
          No information case

          Simply just a ptr(a,b) where a <= b
        *)
        let lb = VarId.make_id @@ Int.to_string stmt_number ^ "_a_load" in
        let ub = VarId.make_id @@ Int.to_string stmt_number ^ "_b_load" in
        let st =
          ConstraintState.add_ub st lhs (Pointer (TypeVar lb, TypeVar ub))
        in
        ConstraintState.add_ub st lb @@ TypeVar ub
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
        let ub = VarId.make_id @@ Int.to_string stmt_number ^ "_a_load" in
        let ty =
          TypeVar (VarId.make_id @@ Int.to_string stmt_number ^ "_b_load")
        in
        let lb = Record [ { size; offset; ty } ] in
        let st = ConstraintState.add_ub st lhs (Pointer (lb, TypeVar ub)) in
        ConstraintState.add_ub st ub lb
  | Stmt.Instr_Call { lhs; args; procid } ->
      let formal_in = Procedure.formal_in_params @@ Program.proc prog procid in
      let formal_out =
        Procedure.formal_out_params @@ Program.proc prog procid
      in
      let st =
        StringMap.fold
          (fun k v acc ->
            match constrain_expr acc @@ BasilExpr.unfix v with
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
          (fun v -> snd @@ constrain_expr st @@ BasilExpr.unfix v)
          args
      in
      let rets =
        StringMap.map (fun v -> TypeVar (VarId.var_proc_to_uid v proc)) lhs
      in
      let func = Function (ID.name procid, args, rets) in
      ConstraintState.add_ub st (VarId.make_id @@ ID.name procid) func
  | Stmt.Instr_IntrinCall _ -> st
  (* NOTE: This is like a jump to, so it does not have args / ret *)
  | Stmt.Instr_IndirectCall _ -> st

let transform (prog : Program.t) =
  let type_constraint_map =
    ID.Map.values prog.procs
    |> Iter.fold
         (fun acc proc ->
           let sva = Analysis.Sva.DFGAnalysis.flow_insensitive proc in
           Procedure.iter_blocks_topo_fwd proc
           |> Iter.fold
                (fun acc (_, b) ->
                  Block.stmts_iter b
                  |> Iter.foldi (gen_constraint_set prog proc sva) acc)
                acc)
         VarIdMap.empty
  in
  (* print_endline @@ ConstraintState.export_graph_viz type_constraint_map; *)
  let types =
    VarIdMap.mapi
      (fun name ({ lb; ub } : ConstraintState.TypeConstraint.t) ->
        (* TODO this could be cleaner by making it a function or sum *)
        let lower =
          (* Posistive Occurences *)
          TySet.fold
            (fun ty (acc : InferredType.t) ->
              let a =
                coalesce_types type_constraint_map TySet.empty Polarity.Pos ty
              in
              match acc with Top -> a | _ -> Union (acc, a))
            lb Top
        in
        let upper =
          (* Negative Occurences *)
          TySet.fold
            (fun ty (acc : InferredType.t) ->
              let a =
                coalesce_types type_constraint_map TySet.empty Polarity.Neg ty
              in
              match acc with Top -> a | _ -> Sect (acc, a))
            ub Top
        in
        (lower, upper))
      type_constraint_map
  in

  (*
    Possible speed up strat would to only many as many automata as we need.

    So make an automata, and remove the types that are included in that automata from the string map,
      so we will have a list of automata, and then for every Var.decl grab the minimised type and then lower it
  *)
  let automatas =
    VarIdMap.mapi
      (fun name (lower_ty, upper_ty) ->
        ( minimise_type Polarity.Pos lower_ty name,
          minimise_type Polarity.Neg upper_ty name ))
      types
  in
  (* transform time *)
  prog

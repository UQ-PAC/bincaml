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





  TODO:

    Ask if I should make it more general and work with less type information
      or should prio speed / space instead
*)

open Bincaml_util.Common
open Lang
open Expr
open Asd

module Sigma = struct
  type t =
    | Ep
    | StoreLabel
    | LoadLabel
    | Reclabel of int * int
    | FnIn of string
    | FnOut of string

  let show = function
    | Ep -> "ε"
    | StoreLabel -> "Store Label"
    | LoadLabel -> "Load Label"
    | Reclabel (n, m) -> Printf.sprintf "Record Label %d %d" n m
    | FnIn n -> Printf.sprintf "Function in %s" n
    | FnOut n -> Printf.sprintf "Function out %s" n

  let equal a b =
    match (a, b) with
    | Ep, Ep | StoreLabel, StoreLabel | LoadLabel, LoadLabel -> true
    | Reclabel (n, m), Reclabel (n1, m1) -> n = n1 && m = m1
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
    (*
      NOTE:
        If there is an epilson edge like below
  
        start -- ep --> bad boy -- a --> end
  
        then start must raise the bad boy's children i.e.
  
        start -- a --> end
  
        If there are no kids, just kill
  
        start -- ep --> bad boy
  
        start
  
        What about a bigger case?
  
        start -- ep --> middle -- ep --> middle2 -- a --> end
  
        start -- a --> end
  
        works
    *)
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
            type t = int * int

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
          if not @@ String.equal name0 name1 then failwith "BOOOOM"
          else
            (* args are the same just just union over the args *)
            let ins =
              StringMap.merge_safe
                ~f:(fun _ b ->
                  match b with
                  | `Both (l, r) -> Some (join l r)
                  | _ -> failwith "BOOOMM")
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

  let rec type_to_state_list (p : Polarity.t) (ty : InferredType.t)
      ((ls, tbl) as acc :
        State.t list * (State.t, (Sigma.t, State.t) Hashtbl.t) Hashtbl.t) :
      State.t list * (State.t, (Sigma.t, State.t) Hashtbl.t) Hashtbl.t =
    let open Sigma in
    match ty with
    | Top | Atom _ | TypeVar _ | Bottom | Field _ -> ((p, ty) :: ls, tbl)
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
end

let var_proc_to_uid (var : Var.t) (proc : Program.proc) : string =
  if Var.is_global var then Var.name var
  else Var.name var ^ "_" ^ ID.name @@ Procedure.id proc

let gen = ID.make_gen ()

(* TODO: Could move these inside of InferredType module *)
let show_type_map (m : InferredType.t StringMap.t) : string =
  StringMap.bindings m
  |> List.map (fun (name, ty) ->
      Printf.sprintf "%s: %s" name (InferredType.show ty))
  |> String.concat "\n"

let show_type_map2 (m : (InferredType.t * InferredType.t) StringMap.t) : string
    =
  StringMap.bindings m
  |> List.map (fun (name, (ty1, ty2)) ->
      Printf.sprintf "%s:\n   lower: %s\n   upper: %s" name
        (InferredType.show ty1) (InferredType.show ty2))
  |> String.concat "\n"

(*
  4 main steps

  1) Turn the types into an automata
  2) Remove the ep edges from said automata
  3) DFA (not done, but lowkey don't see any case where it is needed at the moment)
  4) Merge the nodes that can be merged (handles more cases than DFA so idk)

  A possible improvement would to be never include ep edges when making the automata
    and as such saving a pass.

    I might need to restructure the algorithm to make this work though, would need
      some time to plan that out nicely
*)
let minimise_type p ty name =
  let recursives = Hashtbl.create 2 in
  InferredType.iter
    (fun ty ->
      match ty with
      | InferredType.Recursive (a, b) -> Hashtbl.add recursives a (gen.fresh ())
      | _ -> ())
    ty;
  let automata = TypeAutomata.create_type_automata p ty (p, ty) name in
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
  let recursive_call = coalesce_types constraint_set recursive_set in
  match tau with
  | Field _ | Record _ -> tau
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
            match StringMap.find_opt a constraint_set with
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
  | Atom _ -> tau
  | _ -> Top

(*
  Given a statement constrain the variables involed (based on the expression)
*)
let gen_constraint_set (st : ConstraintState.t) stmt stmt_number prog proc =
  let open AbstractExpr in
  let open InferredType in
  (* Given a expression constrain the variables involed *)
  let rec constrain_expr (st : ConstraintState.t)
      (expr : 'e BasilExpr.abstract_expr) =
    let constrain_arg st l t =
      let l = BasilExpr.unfix l in
      match l with
      | RVar { id } -> ConstraintState.add_lb st (var_proc_to_uid id proc) t
      | _ -> st
    in
    let constrain_args st l r t =
      let st = constrain_arg st l t in
      constrain_arg st r t
    in
    match expr with
    | RVar { id } -> (st, TypeVar (var_proc_to_uid id proc))
    | Constant { const } ->
        ( st,
          match const with
          | `Bool _ -> Atom C_Bool
          | `Bitvector bv -> Atom (C_BV (Bitvec.size bv))
          | `Integer _ -> Atom C_Int )
    | UnaryExpr { op; arg = a } -> (
        let st, _ = constrain_expr st (BasilExpr.unfix a) in
        match op with
        | `BoolNOT -> (constrain_arg st a @@ Atom C_Bool, Atom C_Bool)
        | `BOOLTOBV1 -> (constrain_arg st a @@ Atom C_Bool, Atom (C_BV 1))
        | `INTNEG -> (constrain_arg st a @@ Atom C_Int, Atom C_Int)
        | `BVNEG | `BVNOT ->
            let typ =
              match BasilExpr.type_of a with
              | Bitvector size -> Atom (C_BV size)
              | _ -> failwith "Bitvector operation without bitvector arguments"
            in
            (constrain_arg st a @@ typ, typ)
        | `SignExtend b | `ZeroExtend b ->
            let size =
              match BasilExpr.type_of a with
              | Bitvector size -> size
              | _ -> failwith "Bitvector operation without bitvector arguments"
            in
            (constrain_arg st a @@ Atom (C_BV size), Atom (C_BV (size + b)))
        | `Exists -> (st, Atom C_Bool) (* TODO: Confirm *)
        | `Old -> (st, Top)
        | `Forall -> (st, Top)
        | `Lambda | `Classification | `Gamma -> (st, Top)
        | `Extract (finish, rt) ->
            (* WARN: Is this actually constraining my field when they are used? *)
            let size = finish - rt in
            let ty =
              TypeVar (Printf.sprintf "Extraction_%s" @@ ID.name @@ gen.fresh ())
            in
            let field = { offset = rt; size; ty } in
            (constrain_arg st a @@ Record [ field ], Field field))
    | BinaryExpr { op; arg1 = l; arg2 = r } -> (
        let st, _ = constrain_expr st (BasilExpr.unfix l) in
        let st, _ = constrain_expr st (BasilExpr.unfix r) in
        match op with
        | `INTMOD | `INTSUB | `INTDIV | `INTADD | `INTMUL ->
            let st = constrain_args st l r @@ Atom C_Int in
            (st, Atom C_Int)
        | `NEQ | `EQ ->
            (* TODO: Merge the type constraints of the two variables *)
            (st, Atom C_Bool)
        | `INTLT | `INTLE ->
            let st = constrain_args st l r @@ Atom C_Int in
            (st, Atom C_Bool)
        | `BVULE | `BVULT | `BVSLE | `BVSLT -> (
            match BasilExpr.type_of l with
            | Bitvector size ->
                let st = constrain_args st l r @@ Atom (C_BV size) in
                (st, Atom C_Bool)
            | _ -> failwith "BV operation without BV arguments")
        | `BVSREM | `BVSDIV | `BVADD | `BVMUL | `BVUREM | `BVSUB | `BVUDIV
        | `BVSMOD | `BVSHL | `BVLSHR | `BVASHR | `BVNAND | `BVAND | `BVXOR
        | `BVOR -> (
            match BasilExpr.type_of l with
            | Bitvector size ->
                let typ = Atom (C_BV size) in
                let st = constrain_args st l r typ in
                (st, typ)
            | _ -> failwith "BV operation without BV arguments")
        | `Load _ | `IfThen | `MapAccess -> (st, Top)
        (* WARN: I forgot what this was meant to be *)
        | `IMPLIES -> (st, Top))
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
    WARN: I am extremely unhappy with the recurrence check
      I am very much struggling to reason about it, I think I have
      it as weak as possible while still catching the cntlm case

    This will need much more reasoning to come
  *)
  let rec constrain (st : ConstraintState.t) (type0 : InferredType.t)
      (type1 : InferredType.t) (rec_check : TySet.t) : ConstraintState.t =
    match (type0, type1) with
    | Top, _ | _, Top | Bottom, _ | _, Bottom -> st
    | Pointer (type0_a, type0_b), Pointer (type1_a, type1_b) ->
        constrain
          (constrain st type1_a type0_a rec_check)
          type0_b type1_b rec_check
    | _, Pointer (type1_a, type1_b) ->
        constrain (constrain st type0 type1_a rec_check) type0 type1_b rec_check
    | TypeVar a, TypeVar b -> (
        if String.equal a b then st
        else
          let st = ConstraintState.add_ub st a type1 in
          let bounds = StringMap.get a st in
          match bounds with
          | Some { lb } ->
              TySet.to_iter lb
              |> Iter.fold
                   (fun st bound -> constrain st bound type1 TySet.empty)
                   st
          | None -> st)
    | Field { ty }, TypeVar b -> (
        match ty with
        | TypeVar a -> (
            let st = ConstraintState.add_ub st a type1 in
            let bounds = StringMap.get a st in
            match bounds with
            | Some { lb } ->
                TySet.to_iter lb
                |> Iter.fold
                     (fun st bound -> constrain st bound type1 TySet.empty)
                     st
            | None -> st)
        | _ -> st)
    | _, TypeVar a -> (
        (* The right hand side is not a type variable *)
        let st = ConstraintState.add_lb st a type0 in
        let bounds = StringMap.get a st in
        if TySet.mem type1 rec_check then st
        else
          let rec_check = TySet.add type1 rec_check in
          match bounds with
          | Some { ub } ->
              TySet.to_iter ub
              |> Iter.fold
                   (fun st bound -> constrain st type0 bound rec_check)
                   st
          | None -> st)
    | _ ->
        (*
          You have to assign to a variable (or something similar) so this case should never occur
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
      | TypeVar a -> ConstraintState.add_lb st a (Atom C_Bool)
      | _ -> st)
  | Stmt.Instr_Assign ls ->
      List.fold_left
        (fun st (lhs, expr) ->
          (* Ignore _PC variables *)
          if String.starts_with ~prefix:"_PC" @@ Var.name lhs then st
          else
            let lhs = var_proc_to_uid lhs proc in
            let st, constrain_expr =
              constrain_expr st @@ BasilExpr.unfix expr
            in
            constrain st constrain_expr (TypeVar lhs) TySet.empty)
        st ls
  (* TODO: SVA *)
  | Stmt.Instr_Load { lhs } ->
      let lhs = var_proc_to_uid lhs proc in
      let st =
        ConstraintState.add_ub st lhs
          (Pointer
             ( TypeVar (Int.to_string stmt_number ^ "_a_load"),
               TypeVar (Int.to_string stmt_number ^ "_b_load") ))
      in
      ConstraintState.add_ub st (Int.to_string stmt_number ^ "_a_load")
      @@ TypeVar (Int.to_string stmt_number ^ "_b_load")
  | Stmt.Instr_Store { lhs } ->
      let lhs = var_proc_to_uid lhs proc in
      let st =
        ConstraintState.add_ub st lhs
          (Pointer
             ( TypeVar (Int.to_string stmt_number ^ "_a_store"),
               TypeVar (Int.to_string stmt_number ^ "_b_store") ))
      in
      ConstraintState.add_ub st (Int.to_string stmt_number ^ "_a_store")
      @@ TypeVar (Int.to_string stmt_number ^ "_b_store")
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
                  (TypeVar (Var.name @@ StringMap.find k formal_in))
                  (TypeVar a) TySet.empty
            | acc, a ->
                ConstraintState.add_ub acc
                  (Var.name @@ StringMap.find k formal_in)
                  a)
          args
        @@ StringMap.fold
             (fun k v acc ->
               constrain acc
                 (TypeVar (Var.name @@ StringMap.find k formal_out))
                 (TypeVar (Var.name v))
                 TySet.empty)
             lhs st
      in
      let args =
        StringMap.map
          (fun v -> snd @@ constrain_expr st @@ BasilExpr.unfix v)
          args
      in
      let rets =
        StringMap.map (fun v -> TypeVar (var_proc_to_uid v proc)) lhs
      in
      let func = Function (ID.name procid, args, rets) in
      ConstraintState.add_ub st (ID.name procid) func
  | Stmt.Instr_IntrinCall _ -> st
  (* NOTE: This is like a jump to, so it does not have args / ret *)
  | Stmt.Instr_IndirectCall _ -> st

let check_block p prog st (_, b) =
  Block.stmts_iter b
  |> Iter.foldi
       (fun st stmt_number stmt ->
         gen_constraint_set st stmt stmt_number prog p)
       st

let check_proc (prog : Program.t) st p =
  Procedure.iter_blocks_topo_fwd p |> Iter.fold (check_block p prog) st

let transform (prog : Program.t) =
  (* TODO: I might wanna change this to be cleaner and just a series of pipes *)
  let type_constraint_map =
    ID.Map.values prog.procs |> Iter.fold (check_proc prog) StringMap.empty
  in
  let types =
    StringMap.mapi
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
    StringMap.mapi
      (fun name (lower_ty, upper_ty) ->
        ( minimise_type Polarity.Pos lower_ty name,
          minimise_type Polarity.Neg upper_ty name ))
      types
  in
  (* transform time *)
  prog

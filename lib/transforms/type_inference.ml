open Bincaml_util.Common
open Lang
open Expr
open Asd
open Type_automata

(*
  TODO:

    Ask if I should make it more general and work with less type information
      or should prio speed / space instead
    
*)

let gen = ID.make_gen ()

let minimise_type p ty name =
  let recursives = Hashtbl.create 2 in
  InferredType.iter
    (fun ty ->
      match ty with
      | InferredType.Recursive (a, b) -> Hashtbl.add recursives a (gen.fresh ())
      | _ -> ())
    ty;
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
    | Paren ty -> type_to_state_list p ty acc
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
  in
  let states, edges = type_to_state_list p ty ([], Hashtbl.create 10) in
  let automata =
    TypeAutomata.create_type_automata states edges (p, ty) [] name
  in
  TypeAutomata.remove_ep automata;
  TypeAutomata.merge_nodes automata;
  automata

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

let gen_constraint_set (st : ConstraintState.t) stmt stmt_number prog proc_id =
  let open AbstractExpr in
  let open InferredType in
  let rename_variable (name : string) : string =
    Printf.sprintf "%s_%s" (ID.name proc_id) name
  in

  let rec constrain_expr (st : ConstraintState.t)
      (expr : 'e BasilExpr.abstract_expr) =
    let constrain_arg st l t =
      let l = BasilExpr.unfix l in
      match l with
      | RVar { id } -> ConstraintState.add_lb st (Var.name id) t
      | _ -> st
    in
    let constrain_args st l r t =
      let st = constrain_arg st l t in
      constrain_arg st r t
    in
    match expr with
    | RVar { id } ->
        let name = rename_variable @@ Var.name id in
        (st, TypeVar name)
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
            (* TODO: Can most likely extract more information from this *)
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
    | ApplyIntrin _ -> (st, Top)
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
  (* Deal with assignment cases *)
  | Stmt.Instr_Assign ls ->
      List.fold_left
        (fun st (lhs, expr) ->
          (* Ignore _PC variables *)
          if String.starts_with ~prefix:"_PC" (Var.name lhs) then st
          else
            let lhs = rename_variable @@ Var.name lhs in
            let st, constrain_expr = constrain_expr st (BasilExpr.unfix expr) in
            constrain st constrain_expr (TypeVar lhs) TySet.empty)
        st ls
  (* Pointer stuff here *)
  (* TODO: unsure about store but relativly confident about load *)
  (* TODO: This looks off, make it addr, cells in a record *)
  | Stmt.Instr_Load { lhs } ->
      let lhs = rename_variable @@ Var.name lhs in
      let st =
        ConstraintState.add_ub st lhs
          (Pointer
             ( TypeVar (Int.to_string stmt_number ^ "_a_load"),
               TypeVar (Int.to_string stmt_number ^ "_b_load") ))
      in
      ConstraintState.add_ub st (Int.to_string stmt_number ^ "_a_load")
      @@ TypeVar (Int.to_string stmt_number ^ "_b_load")
  | Stmt.Instr_Store { lhs } ->
      let lhs = rename_variable @@ Var.name lhs in
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
        StringMap.map (fun v -> TypeVar (rename_variable (Var.name v))) lhs
      in
      let func = Function (ID.name procid, args, rets) in
      ConstraintState.add_ub st (ID.name procid) func
  | Stmt.Instr_IntrinCall _ -> st
  (*
    NOTE:
        This is like a jump to, so it does not have args / ret

        This might completely invalidate my whole stack stuff,
          and maybe the variable renaming I do, however it should
          either use the same vars or assign them before right?
  *)
  | Stmt.Instr_IndirectCall _ -> st

let check_block p prog st (_, b) =
  Block.stmts_iter b
  |> Iter.foldi
       (fun st stmt_number stmt ->
         gen_constraint_set st stmt stmt_number prog @@ Procedure.id p)
       st

let check_proc (prog : Program.t) st p =
  Procedure.iter_blocks_topo_fwd p |> Iter.fold (check_block p prog) st

let transform (prog : Program.t) =
  print_endline "\n === Type Constraints === \n";
  let type_constraint_map : ConstraintState.t =
    ID.Map.values prog.procs |> Iter.fold (check_proc prog) StringMap.empty
  in
  print_endline @@ ConstraintState.show type_constraint_map;

  print_endline "\n === Coalesced Types === \n";
  let types =
    StringMap.mapi
      (fun name ({ lb; ub } : ConstraintState.TypeConstraint.t) ->
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
  print_endline @@ show_type_map2 types;

  (*
    Possible speed up strat would to only many as many automata as we need.

    So make an automata, and remove the types that are included in that automata from the string map,
      so we will have a list of automata, and then for every Var.decl grab the minimised type and then lower it

    This needs to passes of the program but I think the only other way would be to pass the program for
     every line in the program.
  *)
  let automatas =
    StringMap.mapi
      (fun name (lower_ty, upper_ty) ->
        ( minimise_type Polarity.Pos lower_ty name,
          minimise_type Polarity.Neg upper_ty name ))
      types
  in
  prog

open Bincaml_util.Common
open Lang
open Expr
open Asd
open Adt

let gen = ID.make_gen ()

let join (ty0 : ty) (ty1 : ty) : ty =
  match (ty0, ty1) with
  | Record fields0, Record fields1 ->
      (* I think this could be improved, cause this is gross *)
      let module FieldMap = Map.Make (struct
        type t = int * int

        let compare = Stdlib.compare
      end) in
      let fieldmap_to_field_list (map : ty FieldMap.t) =
        FieldMap.bindings map
        |> List.map (fun ((offset, size), ty) -> { offset; size; ty })
      in
      let fieldmap_of_list (fields : field list) : ty FieldMap.t =
        List.fold_left
          (fun acc { offset; size; ty } -> FieldMap.add (offset, size) ty acc)
          FieldMap.empty fields
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
  | Pointer (a, b), Pointer (c, d) ->
      (* ptr((a u c) n (b n d), (b n d)) *)
      Pointer (Sect (Union (a, c), Sect (b, d)), Sect (b, d))
  (* WARN: this is not how BinSub did it, but I think I am just smarter and had better DS *)
  | Function (name0, ins0, outs0), Function (name1, ins1, outs1) ->
      if not @@ String.equal name0 name1 then failwith "BOOOOM"
      else
        (* args are the same just just union over the args *)
        let ins =
          StringMap.merge_safe
            ~f:(fun _ b ->
              match b with
              | `Both (l, r) -> Some (Sect (l, r))
              | _ -> failwith "BOOOMM")
            ins0 ins1
        in
        Function (name0, ins, outs0)
  | _ -> Union (ty0, ty1)

let minimise_type p ty name =
  let rec type_to_state_list (p : bool) (ty : ty)
      ((ls, tbl) as acc : 's list * ('s, (sigma, 's) Hashtbl.t) Hashtbl.t) :
      's list * ('s, ('e, 's) Hashtbl.t) Hashtbl.t =
    match ty with
    | Top | Atom _ | TypeVar _ | Bottom | Field _ -> ((p, ty) :: ls, tbl)
    | Recursive (_, a) ->
        let ls, tbl = type_to_state_list p a acc in
        let edges = Hashtbl.create 1 in
        Hashtbl.add edges Ep (p, a);
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
          StringMap.fold (fun _ -> type_to_state_list @@ not p) ins acc
        in
        let ls, tbl = StringMap.fold (fun _ -> type_to_state_list p) outs acc in
        let edges = Hashtbl.create 30 in
        List.iter (fun (n, ty) -> Hashtbl.add edges (FnIn n) (not p, ty))
        @@ StringMap.to_list ins;
        List.iter (fun (n, ty) -> Hashtbl.add edges (FnOut n) (p, ty))
        @@ StringMap.to_list outs;
        Hashtbl.add tbl (p, ty) edges;
        ((p, ty) :: ls, tbl)
    | Pointer (a, b) ->
        let ((ls, tbl) as acc) = type_to_state_list p a acc in
        let ls, tbl = type_to_state_list p b acc in
        let edges = Hashtbl.create 2 in
        Hashtbl.add edges StoreLabel (not p, a);
        Hashtbl.add edges LoadLabel (p, b);
        ((p, ty) :: ls, tbl)
    | Record fields ->
        let ls, tbl =
          List.fold_left
            (fun acc { ty } -> type_to_state_list (not p) ty acc)
            acc fields
        in
        let edges = Hashtbl.create 30 in
        List.iter
          (fun { offset; size; ty } ->
            Hashtbl.add edges (Reclabel (offset, size)) (p, ty))
          fields;
        Hashtbl.add tbl (p, ty) edges;
        ((p, ty) :: ls, tbl)
  in
  let states, edges = type_to_state_list p ty ([], Hashtbl.create 10) in
  (* states trans start fin *)
  let automata = Adt.create_automata2 states edges (true, ty) [] name in
  Adt.remove_ep automata;
  print_string @@ export_graphviz automata;
  automata

let show_type_map (m : ty StringMap.t) : string =
  StringMap.bindings m
  |> List.map (fun (name, ty) -> Printf.sprintf "%s: %s" name (show_ty ty))
  |> String.concat "\n"

let show_type_map2 (m : (ty * ty) StringMap.t) : string =
  StringMap.bindings m
  |> List.map (fun (name, (ty1, ty2)) ->
      Printf.sprintf "%s:\n   lower: %s\n   upper: %s" name (show_ty ty1)
        (show_ty ty2))
  |> String.concat "\n"

let rec coalesce_types (constraint_set : constraint_state)
    (recursive_set : TySet.t) (pos_polarity : bool) (tau : ty) : ty =
  let recursive_call = coalesce_types constraint_set recursive_set in
  match tau with
  | Field _ | Record _ -> tau
  | Pointer (a, b) ->
      Pointer
        (recursive_call (not pos_polarity) a, recursive_call pos_polarity b)
  | Function (name, ins, outs) ->
      (* This might be useless, but just in case there are exprs in function calls *)
      Function
        ( name,
          StringMap.map (recursive_call pos_polarity) ins,
          StringMap.map (recursive_call pos_polarity) outs )
  | TypeVar a -> (
      match TySet.find_opt tau recursive_set with
      | Some c -> c (* Seen before *)
      | None -> (
          (* Has not been seen *)
          let bounds =
            (* Get the bounds for the variable depending on the polarity *)
            match StringMap.find_opt a constraint_set with
            | Some { lb; ub } -> if pos_polarity then ub else lb
            | None -> TySet.empty
          in
          (* If tau is in bounds then we have a recursive type *)
          let rec_check = TySet.find_opt tau bounds in
          let recursive_set = TySet.add tau recursive_set in
          let s =
            TySet.fold
              (fun bound type_cons ->
                let y =
                  coalesce_types constraint_set recursive_set pos_polarity bound
                in
                if pos_polarity then Union (type_cons, y)
                else Sect (type_cons, y))
              bounds tau
          in
          match rec_check with None -> s | Some _ -> Recursive (tau, s)))
  | Atom _ -> tau
  | _ -> Top (* Top, Bottom, Union, Sect, Paren *)

let gen_constraint_set (st : constraint_state) stmt stmt_number proc_id =
  let open AbstractExpr in
  let rename_variable (name : string) : string =
    Printf.sprintf "%s_%s" (ID.name proc_id) name
  in

  (*
    TODO:
          Restructure this function to actually allow constraints to be generated at this stage
  *)
  let rec constrain_expr (st : constraint_state)
      (expr : 'e BasilExpr.abstract_expr) =
    let constrain_arg st l t =
      let l = BasilExpr.unfix l in
      match l with RVar a -> add_lb st (Var.name a) t | _ -> st
    in
    let constrain_args st l r t =
      let st = constrain_arg st l t in
      constrain_arg st r t
    in
    match expr with
    | RVar a ->
        let name = rename_variable @@ Var.name a in
        (st, TypeVar name)
    | Constant op ->
        ( st,
          match op with
          | `Bool _ -> Atom C_Bool
          | `Bitvector bv -> Atom (C_BV (Bitvec.size bv))
          | `Integer _ -> Atom C_Int )
    | UnaryExpr (op, a) -> (
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
        | `Extract (finish, rt) ->
            let size = finish - rt in
            let ty =
              TypeVar (Printf.sprintf "Extraction_%s" @@ ID.name @@ gen.fresh ())
            in
            let field = { offset = rt; size; ty } in
            (constrain_arg st a @@ Record [ field ], Field field))
    | BinaryExpr (op, l, r) -> (
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
        (* WARN: I forgot what this was meant to be *)
        | `IMPLIES -> (st, Top))
    | ApplyIntrin (op, args) -> (st, Top) (* Concat *)
    | ApplyFun (a, b) -> (st, Top)
    | Binding (vars, b) -> (st, Top)
  in

  (*
    Main function to generate consistent constraint set
  *)
  (*
    WARN: I am extremely unhappy with the recurrence check
      I am very much struggling to reason about it, I think I have
      it as weak as possible while still catching the cntlm case

    This will need much more reasoning to come
  *)
  let rec constrain (st : constraint_state) (type0 : ty) (type1 : ty)
      (rec_check : TySet.t) : constraint_state =
    match (type0, type1) with
    | Top, _ | _, Top | Bottom, _ | _, Bottom -> st
    | Pointer (type0_a, type0_b), Pointer (type1_a, type1_b) ->
        constrain
          (constrain st type1_a type0_a rec_check)
          type0_b type1_b rec_check
    | _, Pointer (type1_a, type1_b) ->
        constrain (constrain st type0 type1_a rec_check) type0 type1_b rec_check
    | TypeVar a, TypeVar b -> (
        (* The right hand side is a type variable, fields are pretty much variables *)
        let st = add_ub st a type1 in
        let bounds = StringMap.get a st in
        match bounds with
        | Some { lb } ->
            TySet.to_iter lb
            |> Iter.fold
                 (fun st bound -> constrain st bound type1 TySet.empty)
                 st
        | None -> st)
    | Field { ty }, TypeVar b -> (
        (* The right hand side is a type variable, fields are pretty much variables *)
        match ty with
        | TypeVar a -> (
            let st = add_ub st a type1 in
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
        let st = add_lb st a type0 in
        let bounds = StringMap.get a st in
        if TySet.mem type0 rec_check then st
        else
          let rec_check = TySet.add type0 rec_check in
          match bounds with
          | Some { ub } ->
              TySet.to_iter ub
              |> Iter.fold
                   (fun st bound -> constrain st type0 bound rec_check)
                   st
          | None -> st)
    | _ ->
        (* You have to assign to a variable so this case should never occur *)
        failwith
          (Printf.sprintf "Illegal constrain call type0: %s; type1: %s stmt: %s"
             (show_ty type0) (show_ty type1) (Program.show_stmt stmt))
  in
  match stmt with
  | Stmt.Instr_Assert _ | Stmt.Instr_Assume _ -> st (* TODO inner is bool? *)
  (* Deal with assignment cases *)
  | Stmt.Instr_Assign ls ->
      List.fold_left
        (fun st (lhs, expr) ->
          (* Ignore _PC variables *)
          if String.starts_with ~prefix:"_PC" (Var.name lhs) then st
          else
            let lhs = rename_variable @@ Var.name lhs in
            let st, constrain_expr = constrain_expr st (BasilExpr.unfix expr) in
            Printf.printf "%s : %s \n%!" (show_ty constrain_expr) lhs;
            constrain st constrain_expr (TypeVar lhs) TySet.empty)
        st ls
  (* Pointer stuff here *)
  (* TODO: unsure about store but relativly confident about load *)
  | Stmt.Instr_Load { lhs; mem; cells; addr; endian } ->
      let lhs = rename_variable @@ Var.name lhs in
      let st =
        add_ub st lhs
          (Pointer
             ( TypeVar (Int.to_string stmt_number ^ "_a_load"),
               TypeVar (Int.to_string stmt_number ^ "_b_load") ))
      in
      add_ub st (Int.to_string stmt_number ^ "_a_load")
      @@ TypeVar (Int.to_string stmt_number ^ "_b_load")
  | Stmt.Instr_Store { lhs; mem; cells; value; addr; endian } ->
      let lhs = rename_variable @@ Var.name lhs in
      let st =
        add_ub st lhs
          (Pointer
             ( TypeVar (Int.to_string stmt_number ^ "_a_store"),
               TypeVar (Int.to_string stmt_number ^ "_b_store") ))
      in
      add_ub st (Int.to_string stmt_number ^ "_a_store")
      @@ TypeVar (Int.to_string stmt_number ^ "_b_store")
  | Stmt.Instr_Call { lhs; args; procid } ->
      let args =
        StringMap.map
          (fun v -> snd @@ constrain_expr st @@ BasilExpr.unfix v)
          args
      in
      let rets =
        StringMap.map (fun v -> TypeVar (rename_variable (Var.name v))) lhs
      in
      let func = Function (ID.name procid, args, rets) in
      add_ub st (ID.name procid) func
  (* TODO: Will need to ask what these actually mean / do *)
  | Stmt.Instr_IntrinCall _ -> st
  (*
    NOTE:
        This is like a jump to, so it does not have args / ret

        This might completely invalidate my whole stack stuff,
          and maybe the variable renaming I do, however it should
          either use the same vars or assign them before right?
  *)
  | Stmt.Instr_IndirectCall _ -> st

let check_block p st (_, b) =
  Block.stmts_iter b
  |> Iter.foldi
       (fun st stmt_number stmt ->
         gen_constraint_set st stmt stmt_number @@ Procedure.id p)
       st

let check_proc (prog : Program.t) st p =
  Procedure.iter_blocks_topo_fwd p |> Iter.fold (check_block p) st

let transform (prog : Program.t) =
  print_string "\n === Type Constraints === \n";
  let type_constraint_map =
    ID.Map.values prog.procs |> Iter.fold (check_proc prog) StringMap.empty
  in
  print_string @@ show_constraint_state type_constraint_map;

  print_string "\n === Coalesced Types === \n";
  let types =
    StringMap.mapi
      (fun name { lb; ub } ->
        let upper = (* Positive Occurences *)
          TySet.fold
            (fun ty (acc : ty) ->
              let a = coalesce_types type_constraint_map TySet.empty false ty in
              match acc with Top -> a | _ -> Sect (acc, a))
            ub Top
        in
        let lower = (* Negative Occurences *)
          TySet.fold
            (fun ty (acc : ty) ->
              let a = coalesce_types type_constraint_map TySet.empty false ty in
              match acc with Top -> a | _ -> Union (acc, a))
            lb Top
        in
        (lower, upper))
      type_constraint_map
  in
  print_string @@ show_type_map2 types;

  (*
    Possible speed up strat would to only many as many automata as we need.

    So make an automata, and remove the types that are included in that automata from the string map,
      so we will have a list of automata, and then for every Var.decl grab the minimised type and then lower it

    This needs to passes of the program but I think the only other way would be to pass the program for
     every line in the program.
  *)
  (* let automatas = StringMap.mapi (fun name (lower_ty, upper_ty) -> (minimise_type true lower_ty name, minimise_type false upper_ty name)) types in *)
  prog

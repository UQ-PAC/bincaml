open Bincaml_util.Common
open Lang
open Expr

(*
  TODO List:
    - Fully represent TypeVar's etc with IDs
*)

(*
  TODO: change to be a variable length bv and step away from int16 in favour of bv16
*)
type c_type = C_Int | C_Int8 | C_Int16 | C_Int32 | C_Int64 | C_Float | C_Bool
[@@deriving ord, eq]

let show_c_type = function
  | C_Int -> "int"
  | C_Int8 -> "int8"
  | C_Int16 -> "int16"
  | C_Int32 -> "int32"
  | C_Int64 -> "int64"
  | C_Float -> "float"
  | C_Bool -> "bool"

type ty =
  | Top
  | Bottom
  | Paren of ty
  | Union of ty * ty (* type ∪ type *)
  | Sect of ty * ty (* type ∩ type *)
  | Pointer of ty * ty (* ptr(lb, ub) *)
  | Function of
      string
      * ty StringMap.t
      * ty StringMap.t (* list of inputs and list of outputs *)
  | Field of field
  | Record of field list (* A list of fields in the record *)
  | TypeVar of string
  | Recursive of ty * ty
  | Atom of c_type

and field = { offset : int; size : int; tyName : string }

let rec show_ty = function
  | Top -> "⊤"
  | Bottom -> "⊥"
  | Atom c -> show_c_type c
  | TypeVar id -> id
  | Recursive (t1, t2) -> Printf.sprintf "μ%s.%s" (show_ty t1) (show_ty t2)
  | Paren ty -> Printf.sprintf "(%s)" @@ show_ty ty
  | Union (t1, t2) -> Printf.sprintf "%s ⊔ %s" (show_ty t1) (show_ty t2)
  | Sect (t1, t2) -> Printf.sprintf "%s ⊓ %s" (show_ty t1) (show_ty t2)
  | Pointer (lb, ub) -> Printf.sprintf "ptr(%s, %s)" (show_ty lb) (show_ty ub)
  | Function (name, ins, outs) ->
      Printf.sprintf "(%s) → (%s)"
        (Iter.to_string show_ty (StringMap.values ins))
        (Iter.to_string show_ty (StringMap.values outs))
  | Field field -> show_field field
  | Record fields -> Printf.sprintf "{ %s }" @@ List.to_string show_field fields

and show_field { offset; size; tyName } =
  Printf.sprintf "(%d, %d): %s" offset size tyName

let rec fold_ty f acc ty =
  let acc = f acc ty in
  match ty with
  | Top | Bottom | Atom _ | TypeVar _ | Recursive _ -> acc
  | Paren t -> fold_ty f acc t
  | Union (a, b) | Sect (a, b) -> fold_ty f (fold_ty f acc a) b
  | Pointer (lb, ub) -> fold_ty f (fold_ty f acc lb) ub
  | Function (name, ins, outs) ->
      let acc = StringMap.fold (fun k v acc -> fold_ty f v acc) ins acc in
      StringMap.fold (fun k v acc -> fold_ty f v acc) ins acc
  | Field { tyName } -> fold_ty f acc ty
  | Record fields ->
      List.fold_left (fun acc { tyName } -> fold_ty f acc ty) acc fields

let rec compare_ty type1 type2 =
  match (type1, type2) with
  | Top, Top | Bottom, Bottom -> 0
  | Atom a, Atom b -> compare_c_type a b
  | TypeVar a, TypeVar b -> String.compare a b
  | Recursive (a, b), Recursive (c, d) ->
      let c = compare_ty a c in
      if c <> 0 then c else compare_ty b d
  | Paren a, Paren b -> compare_ty a b
  | Union (a, b), Union (a2, b2) ->
      let c = compare_ty a a2 in
      if c <> 0 then c else compare_ty b b2
  | Sect (a, b), Sect (a2, b2) ->
      let c = compare_ty a a2 in
      if c <> 0 then c else compare_ty b b2
  | Pointer (a, b), Pointer (a2, b2) ->
      let c = compare_ty a a2 in
      if c <> 0 then c else compare_ty b b2
  | Function (name, ins, outs), Function (name2, ins2, outs2) ->
      let c = String.compare name name2 in
      if c <> 0 then c
      else
        let c = StringMap.compare compare_ty ins ins2 in
        if c <> 0 then c else StringMap.compare compare_ty outs outs2
  | ( Field { offset; size; tyName },
      Field { offset = offset2; size = size2; tyName = tyName2 } ) ->
      let c = compare offset offset2 in
      if c <> 0 then c
      else
        let c = compare size size2 in
        if c <> 0 then c else String.compare tyName tyName2
  | Record fields, Record fields2 -> List.compare compare_field fields fields2
  | _ -> 1

and compare_field field field2 = compare_ty (Field field) (Field field2)

(* left hand side maps to left hand side ty <= ty *)
module TySet = Set.Make (struct
  type t = ty

  let compare = compare_ty
end)

type type_constraint = { lb : TySet.t; ub : TySet.t }
type constraint_state = type_constraint StringMap.t

let constraint_state_equals { lb; ub } { lb = lb2; ub = ub2 } =
  if TySet.equal lb lb2 then if TySet.equal ub ub2 then true else false
  else false

let show_ty_set ts = TySet.to_list ts |> List.map show_ty |> String.concat ", "

let show_constraint_state (m : type_constraint StringMap.t) : string =
  StringMap.bindings m
  |> List.map (fun (name, { lb; ub }) ->
      Printf.sprintf "%s: lower [%s], upper [%s]" name (show_ty_set lb)
        (show_ty_set ub))
  |> String.concat "\n"

(* Helpers to actually add something to the upper / lower bounds *)
let add_ub st name ty =
  StringMap.update name
    (function
      | None -> Some { lb = TySet.empty; ub = TySet.singleton ty }
      | Some c -> Some { c with ub = TySet.add ty c.ub })
    st

let add_lb st name ty =
  StringMap.update name
    (function
      | None -> Some { ub = TySet.empty; lb = TySet.singleton ty }
      | Some c -> Some { c with lb = TySet.add ty c.lb })
    st

type sigma =
  | Ep
  | StoreLabel
  | LoadLabel
  | Reclabel of int * int
  | FnIn of int
  | FnOut of int

let show_sigma (sigma : sigma) =
  match sigma with
  | Ep -> "ε"
  | StoreLabel -> "Store Label"
  | LoadLabel -> "Load Label"
  | Reclabel (n, m) -> Printf.sprintf "Record Label %d %d" n m
  | FnIn n -> Printf.sprintf "Function in %d" n
  | FnOut n -> Printf.sprintf "Function out %d" n

let size_to_c_type (size : int) : ty =
  match size with
  | 8 -> Atom C_Int8
  | 16 -> Atom C_Int16
  | 32 -> Atom C_Int32
  | 64 -> Atom C_Int64
  | _ -> Atom C_Int

let gen = ID.make_gen ()
let transfer_func state (input : sigma) = Top

let show_coalesced_types (m : ty StringMap.t) : string =
  StringMap.bindings m
  |> List.map (fun (name, ty) -> Printf.sprintf "%s: %s" name (show_ty ty))
  |> String.concat "\n"

let rec coalesce_types (constraint_set : constraint_state)
    (recursive_set : TySet.t) (polarity : int) (tau : ty) : ty =
  let recursive_call = coalesce_types constraint_set recursive_set in
  match tau with
  | Field _ | Record _ -> tau
  | Pointer (a, b) ->
      Pointer (recursive_call (-polarity) a, recursive_call (-polarity) b)
  | Function (name, ins, outs) ->
      (* This might be useless, but just in case there are exprs in function calls *)
      Function
        ( name,
          StringMap.map (recursive_call polarity) ins,
          StringMap.map (recursive_call polarity) outs )
  | TypeVar a -> (
      match TySet.find_opt tau recursive_set with
      | Some c -> c (* Seen before *)
      | None -> (
          (* Has not been seen *)
          let bounds =
            (* Get the bounds for the variable depending on the polarity *)
            match StringMap.find_opt a constraint_set with
            | Some { lb; ub } -> if polarity <> 1 then lb else ub
            | None -> TySet.empty
          in
          (* If tau is in bounds then we have a recursive type *)
          let rec_check = TySet.find_opt tau bounds in
          let recursive_set = TySet.add tau recursive_set in
          let s =
            TySet.fold
              (fun bound type_cons ->
                let y =
                  coalesce_types constraint_set recursive_set polarity bound
                in
                if polarity = 1 then Union (type_cons, y)
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
  let constrain_expr (expr : 'e BasilExpr.abstract_expr) =
    match expr with
    | RVar a ->
        let name = rename_variable @@ Var.name a in
        if Var.is_local a then TypeVar name
        else
          (*
            NOTE:
                Memory analysis has the information that can get extra
                detail here, however that information is not avaliable
                outs
          *)
          TypeVar name
    | Constant op -> (
        match op with
        | `Bool _ -> Atom C_Bool
        | `Bitvector bv -> size_to_c_type @@ Bitvec.size bv
        | `Integer _ -> Atom C_Int)
    | UnaryExpr (op, a) -> (
        match op with
        | `BoolNOT -> Atom C_Bool
        | `BOOLTOBV1 ->
            Atom C_Bool
            (* IDK, the input is constrained by bool but not output maybe *)
        | `INTNEG -> Atom C_Int
        | `Extract (finish, rt) ->
            let size = finish - rt in
            let tyName =
              Printf.sprintf "Extraction_%s" @@ ID.name @@ gen.fresh ()
            in
            let field = { offset = rt; size; tyName } in
            Field field
        | `BVNEG -> Top
        | `SignExtend _ -> Top
        | `BVNOT -> Top
        | `ZeroExtend _ -> Top
        | `Exists -> Atom C_Bool (* TODO: Confirm *)
        | `Old -> Top
        | `Forall -> Top
        | _ -> Top)
    | BinaryExpr (op, l, r) -> (
        match op with
        | `INTMOD | `INTSUB | `INTDIV | `INTADD | `INTMUL -> Atom C_Int
        | `NEQ | `EQ | `INTLT | `INTLE | `BVULE | `BVULT | `BVSLE | `BVSLT ->
            Atom C_Bool
        (* Help *)
        | `IMPLIES -> Top
        | `BVSREM | `BVSDIV | `BVADD | `BVMUL | `BVUREM | `BVSUB | `BVUDIV
        | `BVSMOD (* Unsure but i just asked so don't wanna again *) | `BVSHL
        | `BVLSHR | `BVASHR -> (
            match BasilExpr.type_of l with
            | Bitvector size -> size_to_c_type size
            | _ -> Top)
        (* Help *)
        | `BVNAND -> Top
        | `BVAND -> Top
        | `BVXOR -> Top
        | `BVOR -> Top
        | _ -> Top)
    | ApplyIntrin (op, args) -> Top
    | ApplyFun (a, b) -> Top
    | Binding (vars, b) -> Top
  in

  (*
    Main function to generate consistent constraint set
  *)
  let rec constrain (st : constraint_state) (type0 : ty) (type1 : ty) :
      constraint_state =
    match (type0, type1) with
    | Top, _ | _, Top | Bottom, _ | _, Bottom -> st
    | Pointer (type0_a, type0_b), Pointer (type1_a, type1_b) ->
        constrain (constrain st type1_a type0_a) type0_b type1_b
    | _, Pointer (type1_a, type1_b) ->
        constrain (constrain st type0 type1_a) type0 type1_b
    | TypeVar a, TypeVar b | Field { tyName = a }, TypeVar b -> (
        (* The right hand side is a type variable, fields are pretty much variables *)
        let st = add_ub st a type1 in
        let bounds = StringMap.get a st in
        match bounds with
        | Some { lb } ->
            TySet.to_iter lb
            |> Iter.fold (fun st bound -> constrain st bound type1) st
        | None -> st)
    | _, TypeVar a -> (
        (* The right hand side is not a type variable *)
        let st = add_lb st a type0 in
        let bounds = StringMap.get a st in
        match bounds with
        | Some { ub } ->
            TySet.to_iter ub
            |> Iter.fold (fun st bound -> constrain st type0 bound) st
        | None -> st)
    | _ ->
        (* You have to assign to a variable so this case should never occur *)
        failwith
          (Printf.sprintf "Illegal constrain call type0: %s; type1: %s stmt: %s"
             (show_ty type0) (show_ty type1) (Program.show_stmt stmt))
  in
  match stmt with
  | Stmt.Instr_Assert _ | Stmt.Instr_Assume _ -> st
  (* Deal with assignment cases *)
  | Stmt.Instr_Assign ls ->
      List.fold_left
        (fun st (lhs, expr) ->
          (* Ignore _PC variables *)
          if String.starts_with ~prefix:"_PC" (Var.name lhs) then st
          else
            let lhs = rename_variable @@ Var.name lhs in
            let constrained_expr = constrain_expr (BasilExpr.unfix expr) in
            constrain st constrained_expr (TypeVar lhs))
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
        StringMap.map (fun v -> constrain_expr @@ BasilExpr.unfix v) args
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
  let type_constraint_map =
    ID.Map.values prog.procs |> Iter.fold (check_proc prog) StringMap.empty
  in
  print_string "\n === Type Constraints === \n";
  print_string @@ show_constraint_state type_constraint_map;
  let types =
    StringMap.mapi
      (fun name { ub } ->
        TySet.fold
          (fun ty (acc : ty) ->
            let a = coalesce_types type_constraint_map TySet.empty (-1) ty in
            match acc with Top -> a | _ -> Sect (acc, a))
          ub Top)
      type_constraint_map
  in
  print_string "\n\n === Coalesced Types === \n";
  print_string @@ show_coalesced_types types;
  prog

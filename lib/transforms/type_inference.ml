open Bincaml_util.Common
open Lang
open Expr

(*
  TODO List:
    - Ask about registers / stacks
      - Registers are like python vars where they can be assigned to anything not matther the type
      - Stack variables might be the same, or at least need to be renamed as in each proc they are different

      - They seem to be just the one type but idk if ali actually understood my question fully
      
    - Reason more about global variables
      - See if a Var is a global, if it is it can be a Record instead of a TypeVar?

*)

type c_type = C_Int | C_Int64 | C_Float | C_Bool

let show_c_type = function
  | C_Int -> "int"
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
  | Recursive of ID.t
  | Atom of c_type

and field = { offset : int; size : int; ty : ty }

let rec show_ty = function
  | Top -> "⊤"
  | Bottom -> "⊥"
  | Atom c -> show_c_type c
  | TypeVar id -> id
  | Recursive id -> ID.to_string id
  | Paren ty -> Printf.sprintf "(%s)" @@ show_ty ty
  | Union (t1, t2) -> Printf.sprintf "%s ∪ %s" (show_ty t1) (show_ty t2)
  | Sect (t1, t2) -> Printf.sprintf "%s ∩ %s" (show_ty t1) (show_ty t2)
  | Pointer (lb, ub) -> Printf.sprintf "ptr(%s, %s)" (show_ty lb) (show_ty ub)
  | Function (name, ins, outs) ->
      Printf.sprintf "(%s) → (%s)"
        (Iter.to_string show_ty (StringMap.values ins))
        (Iter.to_string show_ty (StringMap.values outs))
  | Field field -> show_field field
  | Record fields -> Printf.sprintf "{ %s }" @@ List.to_string show_field fields

and show_field { offset; size; ty } =
  Printf.sprintf "(%d, %d): %s" offset size (show_ty ty)

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
  | Field { ty } -> fold_ty f acc ty
  | Record fields ->
      List.fold_left (fun acc { ty } -> fold_ty f acc ty) acc fields

(* left hand side maps to left hand side ty <= ty *)
type type_constraint = { lb : ty list; ub : ty list }
type constraint_state = type_constraint StringMap.t

(* List append, is there a faster way *)
let merge_constraint_states (state1 : constraint_state)
    (state2 : constraint_state) : constraint_state =
  StringMap.merge
    (fun _ v1 v2 ->
      match (v1, v2) with
      | Some { lb = lb1; ub = ub1 }, Some { lb = lb2; ub = ub2 } ->
          Some { lb = lb1 @ lb2; ub = ub1 @ ub2 }
      | Some { lb = lb1; ub = ub1 }, None -> Some { lb = lb1; ub = ub1 }
      | None, Some { lb = lb1; ub = ub1 } -> Some { lb = lb1; ub = ub1 }
      | _, _ -> None)
    state1 state2

let show_ty_list ts = ts |> List.map show_ty |> String.concat ", "

let show_constraint_state (m : type_constraint StringMap.t) : string =
  StringMap.bindings m
  |> List.map (fun (name, { lb; ub }) ->
      Printf.sprintf "%s: lower [%s], upper [%s]" name (show_ty_list lb)
        (show_ty_list ub))
  |> String.concat "\n"

let coalesce_types constraints = []

let constrained prog (st : constraint_state) stmt i =
  let open AbstractExpr in
  (* TODO: confirm this type is correct *)
  (* TODO: could make a wrapper to get the type and then wrap it after perhaps, to get style points check if tuple return and if not tuple it? *)
  let constrain_expr st (expr : 'e BasilExpr.abstract_expr) =
    match expr with
    | RVar a ->
        if Var.is_local a then
          let a =
            if String.starts_with ~prefix:"Stack" (Var.name a) then
              Int.to_string i ^ Var.name a
            else Var.name a
          in
          TypeVar a
        else
          (* TODO: Deal with globals etc. to see if they are a record *)
          TypeVar (Var.name a)
    | Constant op -> (
        match op with
        | `Bool _ -> Atom C_Bool
        | `Bitvector bv -> Top
        | `Integer _ -> Atom C_Int)
    | UnaryExpr (op, a) -> (
        match op with
        | `Forall -> Top
        | `BVNEG -> Top
        | `BoolNOT -> Atom C_Bool
        | `BOOLTOBV1 -> Atom C_Bool (* Unsure if this should be this *)
        | `INTNEG -> Atom C_Int
        | `Old -> Top
        | `Exists -> Atom C_Bool (* TODO: Confirm *)
        | `Extract (finish, rt) ->
            let size = finish - rt in
            let fields = [ { offset = rt; size; ty = TypeVar "extracted" } ] in
            Record fields
        | `SignExtend _ -> Top
        | `BVNOT -> Top
        | `ZeroExtend _ -> Top)
    | BinaryExpr (op, l, r) -> (
        match op with
        (* Help *)
        | `IMPLIES -> Top
        (* Help *)
        | `BVSREM -> Top
        | `BVSDIV -> Top
        | `BVADD -> Top
        | `BVMUL -> Top
        | `BVUREM -> Top
        | `BVSUB -> Top
        | `BVUDIV -> Top
        | `BVSMOD -> Top
        (* Help *)
        | `BVSHL -> Top
        | `BVLSHR -> Top
        | `BVASHR -> Top
        (* Help *)
        | `BVNAND -> Top
        | `BVAND -> Top
        | `BVXOR -> Top
        | `BVOR -> Top
        | `INTMOD | `INTSUB | `INTDIV | `INTADD | `INTMUL -> Atom C_Int
        | `NEQ | `EQ | `INTLT | `INTLE | `BVULE | `BVULT | `BVSLE | `BVSLT ->
            Atom C_Bool)
    | ApplyIntrin (op, args) -> Top
    | ApplyFun (a, b) -> Top
    | Binding (vars, b) -> Top
  in
  let add_ub st name ty =
    StringMap.update name
      (function
        | None -> Some { lb = []; ub = [ ty ] }
        | Some c -> Some { c with ub = ty :: c.ub })
      st
  in
  let add_lb st name ty =
    StringMap.update name
      (function
        | None -> Some { lb = [ ty ]; ub = [] }
        | Some c -> Some { c with lb = ty :: c.lb })
      st
  in
  (*
    Constrain is from BinSub pseudocode and the names match hence starting from 0
    Type0 <= Type1

    Creates a consistent constraint set by recursively constraining types
      consistent constraint set means all uppers bounds of type t must also be upper bounds
      of type t's lower bounds
  *)
  (*
    TODO: Might have a flaw in logic, will most likely need to constrain globals at the end?
    i.e. here is my constraint set, I want to constrain the globals now, what variables do I that are named
    Global and lie within the memory region, then constrain those like they are a record
  *)
  let rec constrain (st : constraint_state) (type0 : ty) (type1 : ty) :
      constraint_state =
    match (type0, type1) with
    | Top, _ | _, Top | Bottom, _ | _, Bottom ->
        st (* TODO: Temporary to remove todos *)
    (* TODO: Add records and functions etc. *)
    (* Records can be assigned to a variable or another record? *)
    (* Assign a record to another record *)
    (*
      NOTE: I am confused about this
        1) Can this case happen
          - This depends on where Records come from, atm extracts and globals
          - At the moment im leaning on its impossible to occur, as it would be field level not record level
              with memory transforms and then I deal with records at the global level?
    *)
    (* | Record fields, Record fieldsb -> ( *)
    (* st *)
    (* ) *)
    (* Pointer stuff (taken from BinSub)*)
    | Pointer (type0_a, type0_b), Pointer (type1_a, type1_b) -> st
    (* constrain (constrain st type1_a type0_a) type0_b type1_b *)
    (* The right hand side is a type variable *)
    | TypeVar a, TypeVar b -> (
        let st = add_ub st a type1 in
        let bounds = StringMap.get a st in
        match bounds with
        | Some { lb } ->
            List.fold_left (fun st bound -> constrain st bound type1) st lb
        | None -> st)
    (*
      The right hand side is not a type variable
      Left hand side always is a type var so no cases other than this
    *)
    | _, TypeVar a -> (
        let st = add_lb st a type0 in
        let bounds = StringMap.get a st in
        match bounds with
        | Some { ub } ->
            List.fold_left (fun st bound -> constrain st type0 bound) st ub
        | None -> st)
    | _ ->
        failwith
          (Printf.sprintf "Illegal constrain call type0: %s; type1: %s \n"
             (show_ty type0) (show_ty type1))
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
            let lhs =
              if String.starts_with ~prefix:"Stack" (Var.name lhs) then
                Int.to_string i ^ Var.name lhs
              else Var.name lhs
            in
            constrain st
              (constrain_expr st (BasilExpr.unfix expr))
              (TypeVar lhs))
        st ls
  (* Pointer stuff here *)
  (* TODO: unsure about store but relativly confident about load *)
  | Stmt.Instr_Load { lhs; mem; cells; addr; endian } ->
      let st =
        add_ub st (Var.name lhs)
          (Pointer
             ( TypeVar (Int.to_string i ^ "a_load"),
               TypeVar (Int.to_string i ^ "b_load") ))
      in
      add_ub st (Int.to_string i ^ "a_load")
      @@ TypeVar (Int.to_string i ^ "b_load")
  | Stmt.Instr_Store { lhs; mem; cells; value; addr; endian } ->
      let st =
        add_ub st (Var.name lhs)
          (Pointer
             ( TypeVar (Int.to_string i ^ "a_store"),
               TypeVar (Int.to_string i ^ "b_store") ))
      in
      add_ub st (Int.to_string i ^ "a_store")
      @@ TypeVar (Int.to_string i ^ "b_store")
  | Stmt.Instr_Call { lhs; args; procid } ->
      let args =
        StringMap.map (fun v -> constrain_expr st @@ BasilExpr.unfix v) args
      in
      let rets = StringMap.map (fun v -> TypeVar (Var.name v)) lhs in
      let func = Function (ID.name procid, args, rets) in
      add_lb st (ID.name procid) func
  (* TODO: Will need to ask what these actually mean / do *)
  | Stmt.Instr_IntrinCall _ -> st
  | Stmt.Instr_IndirectCall _ -> st

let check_block prog st (_, b) =
  Block.stmts_iter b
  |> Iter.foldi (fun st i stmt -> constrained prog st stmt i) st

let check_proc (prog : Program.t) st p =
  Procedure.iter_blocks_topo_fwd p |> Iter.fold (check_block prog) st

let transform (prog : Program.t) =
  let type_constraint_map =
    ID.Map.values prog.procs |> Iter.fold (check_proc prog) StringMap.empty
  in
  print_string @@ show_constraint_state type_constraint_map;
  let types = coalesce_types type_constraint_map in
  prog

open Bincaml_util.Common
open Lang
open Expr

(*
  TODO List:
    - Ask about registers / stacks
      - Registers are like python vars where they can be assigned to anything not matther the type
      - Stack variables might be the same, or at least need to be renamed as in each proc they are different

      - They seem to be just the one type but idk if ali actually understood my question fully     
*)

type c_type = C_Int | C_Int64 | C_Float | C_Bool [@@deriving ord, eq]

let show_c_type = function
  | C_Int -> "int"
  | C_Int64 -> "int64"
  | C_Float -> "float"
  | C_Bool -> "bool"

module TypeVar = struct
  module M = struct
    type t = {
      stmt : int;
      name : string;
      k : [ `Load | `Store | `Extract | `ID | `Param of ID.t ];
    }
    [@@deriving eq, ord, show]

    let hash = function
      | { stmt; name; k } ->
          Hash.combine3 stmt (String.hash name) (Hashtbl.hash k)
  end

  module X = Fix.HashCons.ForHashedType (M)

  type t = M.t Fix.HashCons.cell

  include Fix.HashCons

  let show x = M.show (data x)

  let create ?op ?stmt name =
    X.make
      {
        stmt = Option.get_or ~default:0 stmt;
        name;
        k = Option.get_or ~default:`ID op;
      }

  let to_int k = id k
end

(*module TVMap = Map.Make (TypeVar)*)
module TVMap = struct
  include PatriciaTree.MakeMap (TypeVar)

  let equal = reflexive_equal
  let compare = reflexive_compare
  let to_iter m = Iter.from_iter (fun f -> iter (fun k v -> f (k, v)) m)
  let values m = to_iter m |> Iter.map snd
  let bindings m = to_iter
  let of_iter i = Iter.fold (fun m (k, v) -> add k v m) empty i
end

type ty =
  | Top
  | Bottom
  | Paren of ty
  | Union of ty * ty (* type ∪ type *)
  | Sect of ty * ty (* type ∩ type *)
  | Pointer of ty * ty (* ptr(lb, ub) *)
  | Function of
      string * ty TVMap.t * ty TVMap.t (* list of inputs and list of outputs *)
  | Field of field
  | Record of field list (* A list of fields in the record *)
  | TypeVar of TypeVar.t
  | Recursive of ty * ty
  | Atom of c_type
[@@deriving eq, ord]

and field = { offset : int; size : int; ty : ty }

let rec show_ty = function
  | Top -> "⊤"
  | Bottom -> "⊥"
  | Atom c -> show_c_type c
  | TypeVar id -> TypeVar.show id
  | Recursive (t1, t2) -> Printf.sprintf "μ%s.%s" (show_ty t1) (show_ty t2)
  | Paren ty -> Printf.sprintf "(%s)" @@ show_ty ty
  | Union (t1, t2) -> Printf.sprintf "%s ⊔ %s" (show_ty t1) (show_ty t2)
  | Sect (t1, t2) -> Printf.sprintf "%s ⊓ %s" (show_ty t1) (show_ty t2)
  | Pointer (lb, ub) -> Printf.sprintf "ptr(%s, %s)" (show_ty lb) (show_ty ub)
  | Function (name, ins, outs) ->
      Printf.sprintf "(%s) → (%s)"
        (Iter.to_string show_ty (TVMap.values ins))
        (Iter.to_string show_ty (TVMap.values outs))
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
      let acc = TVMap.fold (fun k v acc -> fold_ty f v acc) ins acc in
      TVMap.fold (fun k v acc -> fold_ty f v acc) ins acc
  | Field { ty } -> fold_ty f acc ty
  | Record fields ->
      List.fold_left (fun acc { ty } -> fold_ty f acc ty) acc fields

let rec compare_ty type1 type2 =
  match (type1, type2) with
  | Top, Top | Bottom, Bottom -> 0
  | Atom a, Atom b -> compare_c_type a b
  | TypeVar a, TypeVar b -> TypeVar.compare a b
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
        let c = TVMap.compare compare_ty ins ins2 in
        if c <> 0 then c else TVMap.compare compare_ty outs outs2
  | ( Field { offset; size; ty },
      Field { offset = offset2; size = size2; ty = ty2 } ) ->
      let c = compare offset offset2 in
      if c <> 0 then c
      else
        let c = compare size size2 in
        if c <> 0 then c else compare_ty ty ty2
  | Record fields, Record fields2 -> List.compare compare_field fields fields2
  | _ -> 1

and compare_field field field2 = compare_ty (Field field) (Field field2)

(* left hand side maps to left hand side ty <= ty *)
module TySet = Set.Make (struct
  type t = ty

  let compare = compare_ty
end)

type type_constraint = { lb : TySet.t; ub : TySet.t }
type constraint_state = type_constraint TVMap.t

let show_ty_set ts = TySet.to_list ts |> List.map show_ty |> String.concat ", "

let show_constraint_state (m : type_constraint TVMap.t) : string =
  TVMap.to_iter m
  |> Iter.map (fun (name, { lb; ub }) ->
      Printf.sprintf "%s: lower [%s], upper [%s]" (TypeVar.show name)
        (show_ty_set lb) (show_ty_set ub))
  |> Iter.concat_str

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

let transfer_func state (input : sigma) = Top

let show_coalesced_types (m : ty TVMap.t) : string =
  TVMap.to_iter m
  |> Iter.map (fun (name, ty) ->
      Printf.sprintf "%s: %s" (TypeVar.show name) (show_ty ty))
  |> Iter.to_string ~sep:"\n" id

let rec coalesce_types (constraint_set : constraint_state)
    (recursive_set : TySet.t) (polarity : int) (tau : ty) : ty =
  let recursive_call = coalesce_types constraint_set recursive_set in
  match tau with
  | Field { ty } -> recursive_call polarity ty
  | Record fields ->
      Record
        (List.map
           (fun { offset; size; ty } ->
             { offset; size; ty = recursive_call polarity ty })
           fields)
  | Pointer (a, b) ->
      Pointer (recursive_call (-polarity) a, recursive_call (-polarity) b)
  | Function (name, ins, outs) ->
      (* This might be useless, but just in case there are exprs in function calls *)
      Function
        ( name,
          TVMap.map (recursive_call polarity) ins,
          TVMap.map (recursive_call polarity) outs )
  | TypeVar a -> (
      match TySet.find_opt tau recursive_set with
      | Some c -> c
      | None -> (
          let bounds =
            match TVMap.find_opt a constraint_set with
            | Some { lb; ub } -> if polarity = 1 then lb else ub
            | None -> TySet.empty (* TODO: Should never occur *)
          in
          let rec_check = TySet.find_opt tau bounds in
          let recursive_set = TySet.add tau recursive_set in
          let s =
            TySet.fold
              (fun x a ->
                let y =
                  coalesce_types constraint_set recursive_set polarity x
                in
                if polarity = 1 then Union (a, y) else Sect (a, y))
              bounds tau
          in
          match rec_check with None -> s | Some c -> Recursive (tau, s)))
  | Atom c -> tau
  | _ -> Top (* Top, Bottom, Union, Sect, Paren *)

let gen_constraint_set (prog : Program.t) (st : constraint_state) stmt
    stmt_number block_id =
  let open AbstractExpr in
  let constrain_expr st (expr : 'e BasilExpr.abstract_expr) =
    match expr with
    | RVar a ->
        if Var.is_local a then
          let a =
            if String.starts_with ~prefix:"Stack" (Var.name a) then
              TypeVar.create (Var.name a) ~stmt:(ID.index block_id)
            else TypeVar.create (Var.name a)
          in
          TypeVar a
        else
          (*
            NOTE:
                Memory analysis has the information that can get extra
                detail here, however that information is not avaliable
                outs
        *)
          TypeVar (TypeVar.create (Var.name a))
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
            let name =
              TypeVar.create (ID.name block_id) ~op:`Extract
              (*Printf.sprintf "Extraction_%d_%s" stmt_number (ID.name block_id)*)
            in
            let fields = [ { offset = rt; size; ty = TypeVar name } ] in
            Record fields
        | `SignExtend _ -> Top
        | `BVNOT -> Top
        | `ZeroExtend _ -> Top
        | _ -> Top)
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
            Atom C_Bool
        | _ -> Top)
    | ApplyIntrin (op, args) -> Top
    | ApplyFun (a, b) -> Top
    | Binding (vars, b) -> Top
  in
  let add_ub st (name : TypeVar.t) ty =
    TVMap.update name
      (function
        | None -> Some { lb = TySet.empty; ub = TySet.singleton ty }
        | Some c -> Some { c with ub = TySet.add ty c.ub })
      st
  in
  let add_lb st name ty =
    TVMap.update name
      (function
        | None -> Some { ub = TySet.empty; lb = TySet.singleton ty }
        | Some c -> Some { c with lb = TySet.add ty c.lb })
      st
  in
  (*
    WARN: Might have a flaw in logic, will most likely need to constrain globals at the end?
    i.e. here is my constraint set, I want to constrain the globals now, what variables do I that are named
    Global and lie within the memory region, then constrain those like they are a record
  *)
  let rec constrain (st : constraint_state) (type0 : ty) (type1 : ty) :
      constraint_state =
    let n = "constrain (" ^ show_ty type0 ^ ") (" ^ show_ty type1 ^ ")" in
    Trace_core.with_span ~__FUNCTION__ ~__FILE__ ~__LINE__ n @@ fun _ ->
    match (type0, type1) with
    | Top, _ | _, Top | Bottom, _ | _, Bottom -> st
    (*
      WARN: I am confused about this
        Can this case even happen?
          - This depends on where Records come from, atm extracts and globals
          - At the moment im leaning on its impossible to occur, as it would be field level not record level
              with memory transforms and then I deal with records at the global level?
      | Record fields, Record fieldsb -> (
    *)
    | Pointer (type0_a, type0_b), Pointer (type1_a, type1_b) ->
        (* Pointer constraints taken from BinSub *)
        Trace_core.with_span ~__FILE__ ~__LINE__ "constrain_ptr" @@ fun _ ->
        constrain (constrain st type1_a type0_a) type0_b type1_b
    | TypeVar a, TypeVar b -> (
        Trace_core.with_span ~__FILE__ ~__LINE__ "constrain_tvarpair"
        @@ fun _ ->
        (* The right hand side is a type variable *)
        let st = add_ub st a type1 in
        let bounds = TVMap.find_opt a st in
        match bounds with
        | Some { lb } ->
            TySet.fold (fun bound st -> constrain st bound type1) lb st
        | None -> st)
    (* | Field b, TypeVar a -> st *)
    | _, TypeVar a -> (
        (* The right hand side is not a type variable *)
        let st = add_lb st a type0 in
        let bounds = TVMap.find_opt a st in
        match bounds with
        | Some { ub } ->
            TySet.fold (fun bound st -> constrain st type0 bound) ub st
        | None -> st)
    | _ ->
        (* You have to assign to a variable so this case should never occur *)
        failwith
          (Printf.sprintf "Illegal constrain call type0: %s; type1: %s \n"
             (show_ty type0) (show_ty type1))
  in
  match stmt with
  | Stmt.Instr_Assert _ | Stmt.Instr_Assume _ -> st
  (* Deal with assignment cases *)
  | Stmt.Instr_Assign ls ->
      Trace_core.with_span ~__FILE__ ~__LINE__ "constrain_assign" @@ fun _ ->
      List.fold_left
        (fun st (lhs, expr) ->
          (* Ignore _PC variables *)
          if String.starts_with ~prefix:"_PC" (Var.name lhs) then st
          else
            let lhs =
              (* WARN: This exact code is used else where and can be made into a function probs *)
              if String.starts_with ~prefix:"Stack" (Var.name lhs) then
                TypeVar.create (Var.name lhs) ~stmt:(ID.index block_id)
              else TypeVar.create (Var.name lhs)
            in

            constrain st
              (constrain_expr st (BasilExpr.unfix expr))
              (TypeVar lhs))
        st ls
  (* Pointer stuff here *)
  (* TODO: unsure about store but relativly confident about load *)
  | Stmt.Instr_Load { lhs; mem; cells; addr; endian } ->
      Trace_core.with_span ~__FILE__ ~__LINE__ "constrain_load" @@ fun _ ->
      let st =
        add_ub st
          (TypeVar.create (Var.name lhs))
          (Pointer
             ( TypeVar (TypeVar.create "a" ~op:`Load ~stmt:stmt_number),
               TypeVar (TypeVar.create "b" ~op:`Load ~stmt:stmt_number) ))
      in
      add_ub st (TypeVar.create ~stmt:stmt_number ~op:`Load "a")
      @@ TypeVar (TypeVar.create "b" ~stmt:stmt_number ~op:`Load)
  | Stmt.Instr_Store { lhs; mem; cells; value; addr; endian } ->
      Trace_core.with_span ~__FILE__ ~__LINE__ "constrain_store" @@ fun _ ->
      let st =
        add_ub st
          (TypeVar.create @@ Var.name lhs)
          (Pointer
             ( TypeVar (TypeVar.create "a" ~op:`Store ~stmt:stmt_number),
               TypeVar (TypeVar.create "b" ~op:`Store ~stmt:stmt_number) ))
      in
      add_ub st (TypeVar.create "a" ~op:`Store ~stmt:stmt_number)
      @@ TypeVar (TypeVar.create "b" ~op:`Store ~stmt:stmt_number)
  | Stmt.Instr_Call { lhs; args; procid } ->
      Trace_core.with_span ~__FILE__ ~__LINE__ "constrain_call" @@ fun _ ->
      let args =
        StringMap.to_iter args
        |> Iter.map (fun (k, v) ->
            ( TypeVar.create k ~op:(`Param procid),
              constrain_expr st @@ BasilExpr.unfix v ))
        |> TVMap.of_iter
      in
      let rets =
        StringMap.to_iter lhs
        |> Iter.map (fun (k, v) ->
            ( TypeVar.create k,
              TypeVar (TypeVar.create ~op:(`Param procid) @@ Var.name v) ))
        |> TVMap.of_iter
      in
      let func = Function (ID.name procid, args, rets) in
      add_ub st (TypeVar.create @@ ID.name procid) func
  (* TODO: Will need to ask what these actually mean / do *)
  | Stmt.Instr_IntrinCall _ -> st
  | Stmt.Instr_IndirectCall _ -> st

let check_block prog st (block_id, b) =
  Block.stmts_iter b
  |> Iter.foldi
       (fun st stmt_number stmt ->
         gen_constraint_set prog st stmt stmt_number block_id)
       st

let check_proc (prog : Program.t) st p =
  Procedure.iter_blocks_topo_fwd p |> Iter.fold (check_block prog) st

let transform (prog : Program.t) =
  let type_constraint_map =
    ID.Map.values prog.procs |> Iter.fold (check_proc prog) TVMap.empty
  in
  print_string "\n === Type Constraints === \n";
  print_string @@ show_constraint_state type_constraint_map;
  (* WARN: I think the below code is off as I should start with the variables upper bounds instantly and union etc. them together *)
  let types : ty TVMap.t =
    TVMap.to_iter type_constraint_map
    |> Iter.map (fun (name, { lb; ub }) ->
        let folded : ty =
          TySet.fold
            (fun ty (acc : ty) ->
              let a = coalesce_types type_constraint_map TySet.empty (-1) ty in
              match acc with Top -> a | _ -> Sect (acc, a))
            ub Top
        in
        (name, folded))
    |> TVMap.of_iter
  in
  print_string "\n\n === Coalesced Types === \n";
  print_string @@ show_coalesced_types types;
  prog

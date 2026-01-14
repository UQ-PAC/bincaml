(** Type Checking **)

(**
    Need to redo all the function names
**)

open Bincaml_util.Common
open Lang
open Expr

type type_error =
  | StatementEqualityError of { text: string;}

let print_errors ls =
  List.iter (
    fun msg -> match msg with
      | StatementEqualityError { text = t; } -> Printf.printf "%s\n" t
  ) ls

(** let checker acc:(type_error List.t * Types.t), abstract_expr: type_error List.t =
   failwith "unimplemented"
 
let check_expr e : type_error List.t = BasilExpr.fold_with_type checker e
 **)

let binary_same_types arg1 arg2 (typ: Types.t) =
  match arg1, arg2  with
  | tl, tr when Types.equal tl typ && Types.equal tr typ -> []
  | tl, _  when Types.equal tl typ -> [StatementEqualityError
    {
      text = String.cat (Types.to_string arg1) " is not the correct type";
    }]
  | _, _ -> [StatementEqualityError (* This only reports one error so if both are not ints can be bad *)
    {
      text = String.cat (Types.to_string arg2) " is not the correct type";
    }]


  let check_unary (op : Ops.AllOps.unary) (arg : Types.t) : type_error list =
    let open Ops in
    match op with
    | (`BoolNOT | `BOOLTOBV1 as op) ->
      if Types.equal (arg) (Types.Boolean) then []
      else [StatementEqualityError
      {
        text = String.cat (AllOps.to_string op) " body is not a integer";
      }]
    | (`INTNEG as op) ->
      if Types.equal (arg) (Types.Integer) then []
      else [StatementEqualityError
      {
        text = String.cat (AllOps.to_string op) " body is not a integer";
      }]
    | (`BVNOT | `BVNEG as op) -> (
      match (arg) with
      | Bitvector _ -> []
      | _ -> [StatementEqualityError
        {
          text = String.cat (AllOps.to_string op) " body is not a bitvector";
        }]
      )
    (* TODO not sure if these need to be seperate from above but there is probs type checking stuff I can do on b *)
    | (`ZeroExtend b | `SignExtend b as op) -> (
      match (arg) with
      | Bitvector _ -> []
      | _ -> [StatementEqualityError
        {
          text = String.cat (AllOps.to_string op) " body is not a bitvector";
        }]
      )
    | (`Extract (hi, _) as op) -> (
      match (arg) with
      | Bitvector sz -> (
          match sz >= hi with
          | true -> []
          | _    -> [StatementEqualityError
            {
              text = String.cat (AllOps.to_string op) " needs to have a bitvector of at least it's hi value";
            }]
        )
      | _ -> [StatementEqualityError
        {
          text = String.cat (AllOps.to_string op) " body is not a bitvector";
        }]
      )
    | `Old -> []
    | `Forall | `Exists -> []

  let check_binary (op : Ops.AllOps.binary) (arg1 : Types.t) (arg2 : Types.t) :
      type_error list =
    let open Ops in
    match op with
    | (`INTADD | `INTMUL | `INTSUB | `INTDIV | `INTMOD | `INTLT | `INTLE ) ->
      binary_same_types arg1 arg2 Types.Integer
    | (`EQ | `NEQ as op) -> (
        if Types.equal (arg1) (arg2) then []
        else [StatementEqualityError
          {
            text = String.cat "Arguments are not of the same type in " (AllOps.to_string op);
          }]
    )
    | `IMPLIES -> (
      binary_same_types arg1 arg2 Types.Boolean
    )
    | (`BVSREM | `BVSDIV | `BVADD | `BVASHR | `BVMUL | `BVSHL | `BVNAND |
       `BVSLE | `BVUREM | `BVXOR | `BVOR | `BVSUB | `BVUDIV | `BVLSHR |
        `BVAND | `BVSMOD | `BVULT | `BVULE | `BVSLT) -> (
          match arg2 with
          | Bitvector sz as typ -> binary_same_types arg1 arg2 typ
          | _ -> [StatementEqualityError
            {
              text = "Bitvector operator without bitvector args";
            }]
        )

  let check_intrin (op : Ops.AllOps.intrin) (args : Types.t list) :
      type_error list =
    failwith "not implemented"

  let type_error_alg e =
    let errors =
      AbstractExpr.map fst e
      |> AbstractExpr.fold (fun acc f -> List.append f acc) []
    in
    let typed_expr = AbstractExpr.map snd e in
    let new_errors : type_error list =
      match typed_expr with
      | RVar r -> []
      | Constant op -> []
      | ApplyFun (a, b) -> []
      | Binding (vars, b) -> []
      | UnaryExpr (op, a) -> check_unary op a
      | BinaryExpr (op, l, r) -> check_binary op l r
      | ApplyIntrin (op, args) -> check_intrin op args
    in
    List.append new_errors errors

  let type_check expr stmt = BasilExpr.fold_with_type type_error_alg expr

let check_statement_types stmt (pt: Program.t) =
  match stmt with
  | Stmt.Instr_IntrinCall { lhs = lhs } -> []
  | Stmt.Instr_Assign ls ->
    List.fold_left (fun acc (lvar, e) ->
      if Types.equal (BasilExpr.type_of e) (Var.typ lvar) then acc
      else StatementEqualityError
        {
          text = "Assigned var is not the same type as expr";
        }::acc
    ) [] ls
  (* TODO Replace list append with cons or just the thingy *)
  | Stmt.Instr_Assert { body = e } -> List.append
    (if Types.equal (BasilExpr.type_of e) Types.Boolean then []
    else
      [StatementEqualityError
        {
          text = "Assert body is not a bool";
        }
      ])
    (type_check e stmt)
  | Stmt.Instr_Assume { body = e } ->
    if Types.equal (BasilExpr.type_of e) Types.Boolean then []
    else
      [StatementEqualityError
        {
          text = "Assume body is not a bool";
        }
      ]
  | Stmt.Instr_Load { lhs = lvar; cells = size; mem = mem; addr = addr; } ->
    let addressSize = match (Var.typ mem) with
      | Map (Bitvector addressSize, Bitvector valueSize) -> addressSize
      | _ -> failwith "Mem addressSize did not exist"
    in
    let errors = [] in
    let errors =
      if Types.equal (Var.typ lvar) (Types.bv size)
      then errors
      else
        StatementEqualityError
          {
            text = "Load size doesn't match lhs";
          }
        ::errors
    in
    let errors =
      if Types.equal (BasilExpr.type_of addr) (Types.bv addressSize)
      then errors
      else
        StatementEqualityError
          {
            text = "Load address doesn't match memory";
          }
        ::errors
    in
    errors
  | Stmt.Instr_Store { value = value; cells = size; mem = mem; addr = addr; } ->
    let addressSize = match (Var.typ mem) with
      | Map (Bitvector addressSize, _) -> addressSize
      | _ -> failwith "Mem addressSize did not exist"
    in
    let errors = [] in
    let errors = if Types.equal (BasilExpr.type_of addr) (Types.bv addressSize)
                  then errors
                  else
        StatementEqualityError
          {
            text = "Store address doesn't match memory";
          }
        ::errors
    in
    let errors = if Types.equal (BasilExpr.type_of value) (Types.bv size)
                  then errors
                  else
        StatementEqualityError
          {
            text = "Store size doesn't match lhs";
          }
        ::errors
    in
    errors
  | Stmt.Instr_IndirectCall { target = target } ->
    if Types.equal (BasilExpr.type_of target) (Types.bv 64) then []
    else
      [StatementEqualityError
        {
          text = "Indirect call target must be an address";
        }
      ]
  | Stmt.Instr_Call { lhs = lhs; procid = id; args = args } -> (
    (* TODO tried using optional tf1 arg here and did not like it *)
    let compare_maps tf1 map1 map2 stmt=
      let list1 = StringMap.to_list map1 in
      let list2 = StringMap.to_list map2 in
      match List.compare_lengths list1 list2 with
      | 0 -> List.fold_left2 (fun acc (_, v) (_, v2) ->
          if Types.equal (tf1 v) (Var.typ v2) then acc
          else StatementEqualityError
            {
              text = "Type mismatch in arguments";
            }::acc
        ) [] list1 list2
      | _ -> [StatementEqualityError
        {
          text = "Missing or extra arguments";
        }]
    in
    let target_proc = ID.Map.find id pt.procs in
    let real_args = Procedure.formal_in_params target_proc in
    let output = Procedure.formal_out_params target_proc in
    List.append (compare_maps BasilExpr.type_of args real_args stmt)
      (compare_maps Var.typ lhs output stmt)
    )

let check (pt: Program.t) p =
  (*
    These all return arrays of error not just errors as some can return more than one error
    
    It could be seperated into an a new type that can be one or multiple errors? but that just
     sounds like a list with more steps
  *)  
  let check_type (id, bl) =
    let stmts = Block.stmts_iter bl in
    Iter.fold (fun acc x -> List.append (check_statement_types x pt) acc) [] stmts;
  in
  let errors = Procedure.iter_blocks_topo_fwd p
    |> Iter.fold (fun acc x ->
      List.append (check_type x) acc
    ) []
  in
  print_errors errors;
  if List.length errors = 0 then false else true

(** Type Checking **)

(**
    Need to redo all the function names
**)

open Bincaml_util.Common
open Lang
open Expr

type type_error =
  | StatementEqualityError of { text: string; stmt: string}
  | NotImplementedError

let print_errors ls =
  List.iter (
    fun msg -> match msg with
      | StatementEqualityError { text = t; stmt = stmt } -> Printf.printf "%s\n%s\n" stmt t
      | NotImplementedError -> print_string "Not implemented\n"
  ) ls

(** let checker acc:(type_error List.t * Types.t), abstract_expr: type_error List.t =
   failwith "unimplemented"
 
let check_expr e : type_error List.t = BasilExpr.fold_with_type checker e
 **)

let check (pt: Program.t) p =

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
            stmt = Stmt.show_stmt_basil stmt;
          }::acc
      ) [] list1 list2
    | _ -> [StatementEqualityError
      {
        text = "Missing or extra arguments";
        stmt = Stmt.show_stmt_basil stmt;
      }]
  in
  (*
    These all return arrays of error not just errors as some can return more than one error
    
    It could be seperated into an a new type that can be one or multiple errors? but that just
     sounds like a list with more steps
  *)
  let check_statement_types stmt =
    match stmt with
    | Stmt.Instr_Assign ls ->
      List.fold_left (fun acc (lvar, e) ->
        if Types.equal (BasilExpr.type_of e) (Var.typ lvar) then acc
        else StatementEqualityError
          {
            text = "Assigned var is not the same type as expr";
            stmt = Stmt.show_stmt_basil stmt;
          }::acc
      ) [] ls
    | Stmt.Instr_Assert { body = e } ->
      if Types.equal (BasilExpr.type_of e) Types.Boolean then []
      else
        [StatementEqualityError
          {
            text = "Assert body is not a bool";
            stmt=Stmt.show_stmt_basil stmt;
          }
        ]
    | Stmt.Instr_Assume { body = e } ->
      if Types.equal (BasilExpr.type_of e) Types.Boolean then []
      else
        [StatementEqualityError
          {
            text = "Assume body is not a bool";
            stmt=Stmt.show_stmt_basil stmt;
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
              stmt=Stmt.show_stmt_basil stmt;
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
              stmt=Stmt.show_stmt_basil stmt;
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
              stmt=Stmt.show_stmt_basil stmt
            }
          ::errors
      in
      let errors = if Types.equal (BasilExpr.type_of value) (Types.bv size)
                    then errors
                    else
          StatementEqualityError
            {
              text = "Store size doesn't match lhs";
              stmt=Stmt.show_stmt_basil stmt
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
            stmt=Stmt.show_stmt_basil stmt;
          }
        ]
    | Stmt.Instr_IntrinCall { lhs = lhs } -> [NotImplementedError]
    (* === TODO Below === *)
    (*
      TODO
      Get the params and make sure they match agaisnt the ones the function wants and check to make sure the function returns the type that the lhs is
    *)
    | Stmt.Instr_Call { lhs = lhs; procid = id; args = args } -> (
      let target_proc = ID.Map.find id pt.procs in
      let real_args = Procedure.formal_in_params target_proc in
      let output = Procedure.formal_out_params target_proc in
      let errors = List.append (compare_maps BasilExpr.type_of args real_args stmt)
        (compare_maps Var.typ lhs output stmt)
      in
        errors
      )
  in
  
  let check_type (id, bl) =
    let stmts = Block.stmts_iter bl in
    Iter.fold (fun acc x -> List.append (check_statement_types x) acc) [] stmts;
  in
  let errors = Procedure.iter_blocks_topo_fwd p
    |> Iter.fold (fun acc x ->
      List.append (check_type x) acc
      ) []
  in
  print_errors errors;
  if List.length errors = 0 then false else true

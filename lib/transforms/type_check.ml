(** Type Checking **)

open Bincaml_util.Common
open Lang
open Expr

type type_error = StatementEqualityError of { text : string }

let print_errors ls =
  List.iter
    (fun msg ->
      match msg with
      | StatementEqualityError { text = t } -> Printf.printf "%s\n" t)
    ls

let binary_same_types arg1 arg2 (typ : Types.t) =
  match (arg1, arg2) with
  | tl, tr when Types.equal tl typ && Types.equal tr typ -> []
  | tl, _ when Types.equal tl typ ->
      [
        StatementEqualityError
          {
            text = String.cat (Types.to_string arg1) " is not the correct type";
          };
      ]
  | _, tr when Types.equal tr typ ->
      [
        StatementEqualityError
          (* This only reports one error so if both are not ints can be bad *)
          {
            text = String.cat (Types.to_string arg2) " is not the correct type";
          };
      ]
  | _, _ ->
      [
        StatementEqualityError
          (* This only reports one error so if both are not ints can be bad *)
          {
            text =
              Printf.sprintf "%s and %s are not the correct type"
                (Types.to_string arg1) (Types.to_string arg2);
          };
      ]

let check_unary (op : Ops.AllOps.unary) (arg : Types.t) : type_error list =
  let open Ops in
  match op with
  | (`BoolNOT | `BOOLTOBV1) as op ->
      if Types.equal arg Types.Boolean then []
      else
        [
          StatementEqualityError
            { text = String.cat (AllOps.to_string op) " body is not a integer" };
        ]
  | `INTNEG as op ->
      if Types.equal arg Types.Integer then []
      else
        [
          StatementEqualityError
            { text = String.cat (AllOps.to_string op) " body is not a integer" };
        ]
  | (`BVNOT | `BVNEG) as op -> (
      match arg with
      | Bitvector _ -> []
      | _ ->
          [
            StatementEqualityError
              {
                text =
                  String.cat (AllOps.to_string op) " body is not a bitvector";
              };
          ])
  (* TODO not sure if these need to be seperate from above but there is probs type checking stuff I can do on b *)
  | (`ZeroExtend b | `SignExtend b) as op -> (
      match arg with
      | Bitvector _ -> []
      | _ ->
          [
            StatementEqualityError
              {
                text =
                  String.cat (AllOps.to_string op) " body is not a bitvector";
              };
          ])
  | `Extract (hi, _) as op -> (
      match arg with
      | Bitvector sz -> (
          match sz >= hi with
          | true -> []
          | _ ->
              [
                StatementEqualityError
                  {
                    text =
                      String.cat (AllOps.to_string op)
                        " needs to have a bitvector of at least it's hi value";
                  };
              ])
      | _ ->
          [
            StatementEqualityError
              {
                text =
                  String.cat (AllOps.to_string op) " body is not a bitvector";
              };
          ])
  | `Old -> []
  | `Forall | `Exists -> []

let check_binary (op : Ops.AllOps.binary) (arg1 : Types.t) (arg2 : Types.t) :
    type_error list =
  let open Ops in
  match op with
  | `INTADD | `INTMUL | `INTSUB | `INTDIV | `INTMOD | `INTLT | `INTLE ->
      binary_same_types arg1 arg2 Types.Integer
  | (`EQ | `NEQ) as op ->
      if Types.equal arg1 arg2 then []
      else
        [
          StatementEqualityError
            {
              text =
                String.cat "Arguments are not of the same type in "
                  (AllOps.to_string op);
            };
        ]
  | `IMPLIES -> binary_same_types arg1 arg2 Types.Boolean
  | `BVSREM | `BVSDIV | `BVADD | `BVASHR | `BVMUL | `BVSHL | `BVNAND | `BVSLE
  | `BVUREM | `BVXOR | `BVOR | `BVSUB | `BVUDIV | `BVLSHR | `BVAND | `BVSMOD
  | `BVULT | `BVULE | `BVSLT -> (
      match arg1 with
      | Bitvector sz as typ -> binary_same_types arg1 arg2 typ
      | _ ->
          [
            StatementEqualityError
              { text = "Bitvector operator without bitvector args" };
          ])

let check_intrin (op : Ops.AllOps.intrin) (args : Types.t list) :
    type_error list =
  match op with
  | `BVADD | `BVXOR | `BVOR | `BVAND ->
      let correct_type = List.hd args in
      List.fold_left
        (fun acc typ ->
          if Types.equal correct_type typ then acc
          else
            StatementEqualityError
              { text = Printf.sprintf "%s wrong type" (Types.to_string typ) }
            :: acc)
        [] args
  | `BVConcat ->
      (* Just make sure everything is a BV dont care about size *)
      List.fold_left
        (fun acc typ ->
          match typ with
          | Types.Bitvector _ -> acc
          | _ ->
              StatementEqualityError
                { text = Printf.sprintf "%s wrong type" (Types.to_string typ) }
              :: acc)
        [] args
  | `OR | `AND ->
      List.fold_left
        (fun acc typ ->
          if Types.equal Types.Boolean typ then acc
          else
            StatementEqualityError
              { text = Printf.sprintf "%s wrong type" (Types.to_string typ) }
            :: acc)
        [] args

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

let type_check expr = BasilExpr.fold_with_type type_error_alg expr

let check_statement_types stmt (pt : Program.t) =
  match stmt with
  | Stmt.Instr_IntrinCall { lhs } -> []
  | Stmt.Instr_Assign ls ->
      List.fold_left
        (fun acc (lvar, e) ->
          if Types.equal (BasilExpr.type_of e) (Var.typ lvar) then acc
          else
            StatementEqualityError
              { text = "Assigned var is not the same type as expr" }
            :: acc)
        [] ls
  | Stmt.Instr_Assert { body = e } | Stmt.Instr_Assume { body = e } ->
      let expr_errors = type_check e in
      if Types.equal (BasilExpr.type_of e) Types.Boolean then expr_errors
      else
        StatementEqualityError
          {
            text =
              Printf.sprintf "%s body is not a bool" (BasilExpr.to_string e);
          }
        :: expr_errors
  | Stmt.Instr_Load { lhs; cells; mem; addr } ->
      let addressSize =
        match Var.typ mem with
        | Map (Bitvector addressSize, Bitvector valueSize) -> addressSize
        | _ -> failwith "Mem addressSize did not exist"
      in
      let errors = type_check addr in
      let errors =
        if Types.equal (Var.typ lhs) (Types.bv cells) then errors
        else
          StatementEqualityError { text = "Load size doesn't match lhs" }
          :: errors
      in
      let errors =
        if Types.equal (BasilExpr.type_of addr) (Types.bv addressSize) then
          errors
        else
          StatementEqualityError { text = "Load address doesn't match memory" }
          :: errors
      in
      errors
  | Stmt.Instr_Store { value; cells; mem; addr } ->
      let addressSize =
        match Var.typ mem with
        | Map (Bitvector addressSize, _) -> addressSize
        | _ -> failwith "Mem addressSize did not exist"
      in
      let errors = List.append (type_check addr) (type_check value) in
      let errors =
        if Types.equal (BasilExpr.type_of addr) (Types.bv addressSize) then
          errors
        else
          StatementEqualityError { text = "Store address doesn't match memory" }
          :: errors
      in
      let errors =
        if Types.equal (BasilExpr.type_of value) (Types.bv cells) then errors
        else
          StatementEqualityError { text = "Store size doesn't match lhs" }
          :: errors
      in
      errors
  | Stmt.Instr_IndirectCall { target } ->
      let expr_errors = type_check target in
      if Types.equal (BasilExpr.type_of target) (Types.bv 64) then expr_errors
      else
        StatementEqualityError
          { text = "Indirect call target must be an address" }
        :: expr_errors
  | Stmt.Instr_Call { lhs; procid; args } ->
      (* TODO tried using optional tf1 arg here and did not like it *)
      let compare_maps tf1 map1 map2 stmt =
        let list1 = StringMap.to_list map1 in
        let list2 = StringMap.to_list map2 in
        match List.compare_lengths list1 list2 with
        | 0 ->
            List.fold_left2
              (fun acc (_, v) (_, v2) ->
                if Types.equal (tf1 v) (Var.typ v2) then acc
                else
                  StatementEqualityError { text = "Type mismatch in arguments" }
                  :: acc)
              [] list1 list2
        | _ ->
            [ StatementEqualityError { text = "Missing or extra arguments" } ]
      in
      let target_proc = ID.Map.find procid pt.procs in
      let real_args = Procedure.formal_in_params target_proc in
      let output = Procedure.formal_out_params target_proc in
      (* This is disgusting
          I have a list of exprs I want to go through and type check
            A fold through these will give back a list list type error
          The default case (first arg of fold) can be the things I want to add to the errors anyway
            So it can just be the result from type checking the real args to the args
             passed in appended to the outputs from function vs the outputs we are assigning
          The second arg in the fold is the StringMap as a list but mapped to remove the keys
            (probably a way to just get a seq or list of just the values in a single method)
          Then Finally List.concat takes the list list type_error to just a list type_error by
            joining over all of the lists.
      *)
      List.concat
        (List.fold_left
           (fun acc arg -> type_check arg :: acc)
           [
             List.append
               (compare_maps BasilExpr.type_of args real_args stmt)
               (compare_maps Var.typ lhs output stmt);
           ]
           (List.map (fun (_, v) -> v) (StringMap.to_list args)))

let check (pt : Program.t) p =
  (*
    These all return arrays of error not just errors as some can return more than one error
    
    It could be seperated into an a new type that can be one or multiple errors? but that just
     sounds like a list with more steps
  *)
  let check_type (id, bl) =
    let stmts = Block.stmts_iter bl in
    Iter.fold
      (fun acc x -> List.append (check_statement_types x pt) acc)
      [] stmts
  in
  let errors =
    Procedure.iter_blocks_topo_fwd p
    |> Iter.fold (fun acc x -> List.append (check_type x) acc) []
  in
  print_errors errors;
  if List.length errors = 0 then false else true

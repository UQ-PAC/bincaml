(** Type Checking **)

open Bincaml_util.Common
open Lang
open Expr
open Printf

type type_error = StatementEqualityError of { text : string }

let print_errors ls =
  List.iter
    (fun msg ->
      match msg with StatementEqualityError { text = t } -> printf "%s\n" t)
    ls

let check_unary (op : Ops.AllOps.unary) (arg : Types.t) : type_error list =
  let open Ops in
  match op with
  | `BoolNOT | `BOOLTOBV1 ->
      if Types.equal arg Types.Boolean then []
      else
        [
          StatementEqualityError
            { text = sprintf "%s body is not a boolean" (AllOps.to_string op) };
        ]
  | `INTNEG ->
      if Types.equal arg Types.Integer then []
      else
        [
          StatementEqualityError
            { text = sprintf "%s body is not a integer" (AllOps.to_string op) };
        ]
  | `BVNOT | `BVNEG -> (
      match arg with
      | Bitvector _ -> []
      | _ ->
          [
            StatementEqualityError
              {
                text =
                  sprintf "%s body is not a bitvector" (AllOps.to_string op);
              };
          ])
  | `ZeroExtend _ | `SignExtend _ -> (
      match arg with
      | Bitvector _ -> []
      | _ ->
          [
            StatementEqualityError
              {
                text =
                  sprintf "%s body is not a bitvector" (AllOps.to_string op);
              };
          ])
  | `Extract (hi, _) -> (
      match arg with
      | Bitvector sz -> (
          match sz >= hi with
          | true -> []
          | _ ->
              [
                StatementEqualityError
                  {
                    text =
                      sprintf
                        "%s needs to have a bitvector of at least it's hi value"
                        (AllOps.to_string op);
                  };
              ])
      | _ ->
          [
            StatementEqualityError
              {
                text =
                  sprintf "%s body is not a bitvector" (AllOps.to_string op);
              };
          ])
  | `Old -> []
  | `Forall | `Exists -> []

let check_binary (op : Ops.AllOps.binary) (arg1 : Types.t) (arg2 : Types.t) :
    type_error list =
  let binary_same_types arg1 arg2 (typ : Types.t) =
    match (arg1, arg2) with
    | tl, tr when Types.equal tl typ && Types.equal tr typ -> []
    | _, tr when Types.equal tr typ ->
        [
          StatementEqualityError
            {
              text =
                sprintf "%s is not the correct type of %s for %s"
                  (Types.to_string arg1) (Types.to_string typ)
                  (Ops.AllOps.to_string op);
            };
        ]
    | tl, _ when Types.equal tl typ ->
        [
          StatementEqualityError
            (* This only reports one error so if both are not ints can be bad *)
            {
              text =
                sprintf "%s is not the correct type of %s for %s"
                  (Types.to_string arg2) (Types.to_string typ)
                  (Ops.AllOps.to_string op);
            };
        ]
    | _, _ ->
        [
          StatementEqualityError
            (* This only reports one error so if both are not ints can be bad *)
            {
              text =
                sprintf "%s and %s are not the correct type of %s for %s"
                  (Types.to_string arg1) (Types.to_string arg2)
                  (Types.to_string typ) (Ops.AllOps.to_string op);
            };
        ]
  in
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
                sprintf "Arguments are not of the same type in %s"
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
              {
                text =
                  sprintf "%s is not of bitvector type in %s"
                    (Types.to_string arg1) (Ops.AllOps.to_string op);
              };
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
              {
                text =
                  sprintf "%s is not a bitvector type in %s"
                    (Types.to_string typ) (Ops.AllOps.to_string op);
              }
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
                {
                  text =
                    sprintf "%s is not a bitvector type in %s"
                      (Types.to_string typ) (Ops.AllOps.to_string op);
                }
              :: acc)
        [] args
  | `OR | `AND ->
      List.fold_left
        (fun acc typ ->
          if Types.equal Types.Boolean typ then acc
          else
            StatementEqualityError
              {
                text =
                  sprintf "%s is not a boolean in %s" (Types.to_string typ)
                    (Ops.AllOps.to_string op);
              }
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
  | Stmt.Instr_IntrinCall _ -> []
  | Stmt.Instr_Assign ls ->
      List.fold_left
        (fun acc (lvar, e) ->
          let expr_errors = type_check e in
          let acc = List.append acc expr_errors in
          if Types.equal (BasilExpr.type_of e) (Var.typ lvar) then acc
          else
            StatementEqualityError
              {
                text =
                  sprintf
                    "Paramters for the function has a type mismatch: type of \
                     %s != type of %s"
                    (BasilExpr.to_string e) (Var.to_string lvar);
              }
            :: acc)
        [] ls
  | Stmt.Instr_Assert { body = e } | Stmt.Instr_Assume { body = e } ->
      let expr_errors = type_check e in
      if Types.equal (BasilExpr.type_of e) Types.Boolean then expr_errors
      else
        StatementEqualityError
          {
            text = sprintf "Body of %s is not a Boolean" (BasilExpr.to_string e);
          }
        :: expr_errors
  | Stmt.Instr_Load { lhs; cells; mem; addr } ->
      let addressSize =
        match Var.typ mem with
        | Map (Bitvector addressSize, Bitvector valueSize) -> addressSize
        | _ -> failwith "Mem's addressSize did not exist"
      in
      let errors = type_check addr in
      let errors =
        if Types.equal (Var.typ lhs) (Types.bv cells) then errors
        else
          StatementEqualityError
            {
              text =
                sprintf "Load size (%d) doesn't match lhs (%s) type" cells
                  (Var.to_string lhs);
            }
          :: errors
      in
      let errors =
        if Types.equal (BasilExpr.type_of addr) (Types.bv addressSize) then
          errors
        else
          StatementEqualityError
            {
              text =
                sprintf
                  "Address loading data (%s) does not match address size (%d)"
                  (BasilExpr.to_string addr) addressSize;
            }
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
          StatementEqualityError
            {
              text =
                sprintf
                  "Address loading data (%s) does not match address size (%d)"
                  (BasilExpr.to_string addr) addressSize;
            }
          :: errors
      in
      let errors =
        if Types.equal (BasilExpr.type_of value) (Types.bv cells) then errors
        else
          StatementEqualityError
            {
              text =
                sprintf "Store size (%d) doesn't match lhs (%s) type" cells
                  (BasilExpr.to_string value);
            }
          :: errors
      in
      errors
  | Stmt.Instr_IndirectCall { target } ->
      let expr_errors = type_check target in
      if Types.equal (BasilExpr.type_of target) (Types.bv 64) then expr_errors
      else
        StatementEqualityError
          {
            text =
              sprintf
                "Indirect call target (%s) must be an address (i.e. Bitvector \
                 64)"
                (BasilExpr.to_string target);
          }
        :: expr_errors
  | Stmt.Instr_Call { lhs; procid; args } ->
      let compare_stringmaps ty_a str_a a ty_b str_b b =
        StringMap.merge
          (fun k arg real ->
            match (arg, real) with
            | None, _ | _, None ->
                Some (StatementEqualityError { text = "missing: " ^ k })
            | Some arg, Some real ->
                if Types.equal (ty_a arg) (ty_b real) then None
                else
                  Some
                    (StatementEqualityError
                       {
                         text =
                           sprintf "Type mismatch in arguments %s and %s"
                             (str_a arg) (str_b real);
                       }))
          a b
        |> StringMap.values |> Iter.to_list
      in
      let target_proc = ID.Map.find procid pt.procs in
      let real_args = Procedure.formal_in_params target_proc in
      let output = Procedure.formal_out_params target_proc in

      let params_check =
        List.append
          (compare_stringmaps BasilExpr.type_of BasilExpr.to_string args Var.typ
             Var.to_string real_args)
          (compare_stringmaps Var.typ Var.to_string lhs Var.typ Var.to_string
             output)
      in
      let args =
        StringMap.values args |> Iter.to_list |> List.flat_map type_check
      in
      List.append params_check args

let check (pt : Program.t) p =
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

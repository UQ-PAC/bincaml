open Containers
open Bincaml_util.Common

exception BoogieException of string

let function_name name =
  let open Containers_pp in
  text "f" ^ text name

let proc_name name =
  let open Containers_pp in
  let name = String.map (fun c -> match c with '@' -> '$' | _ -> c) name in
  text "p" ^ text name

let block_name v =
  let open Containers_pp in
  let name = Lang.Procedure.Vert.block_id_string v in
  let name = String.map (fun c -> match c with '%' -> '#' | _ -> c) name in
  text "b" ^ text name

let join_lines ?(s = "") ls =
  let open Containers_pp in
  append_l ~sep:(text ";\n") ls

let join_lines_end ?(s = "") ls =
  let open Containers_pp in
  append_l ~sep:(text @@ Printf.sprintf ";\n%s" s) ls ^ text ";"

let rec type_to_string (t : Types.t) =
  match t with
  | Types.Boolean -> "bool"
  | Types.Integer -> "int"
  | Types.Bitvector i -> String.cat "bv" (Int.to_string i)
  | Types.Map (i, o) ->
      String.concat "" [ "["; type_to_string i; "]"; type_to_string o ]
  | t ->
      raise
        (BoogieException (String.cat "Unsupported type" (Types.to_string t)))

let pretty_variable_declaration (v : Var.t) =
  let open Containers_pp in
  text "var "
  ^ text (Var.name v)
  ^ text ": "
  ^ text (type_to_string @@ Var.typ v)

let pretty_variable (v : Var.t) =
  let open Containers_pp in
  text (Var.name v)

let pretty_variable_typed (v : Var.t) =
  let open Containers_pp in
  text (Var.name v) ^ text ": " ^ text (type_to_string @@ Var.typ v)

let pretty_const (c : Lang.Ops.AllOps.const) =
  let open Containers_pp in
  match c with
  | `Integer i -> text @@ Z.format "%d" i
  | `Bitvector bv -> text @@ Printf.sprintf "%sbv%d" (Z.format "%d" bv.v) bv.w
  | `Bool b -> text @@ string_of_bool b
  | _ -> raise (BoogieException "Unsupported constant")

let rec pretty_binary_op (op : Lang.Ops.AllOps.binary) arg1 arg2 =
  let open Containers_pp in
  match op with
  | #Lang.Ops.BVOps.binary ->
      (text @@ Lang.Ops.AllOps.to_string op)
      ^ text "_"
      ^ fill (text "_")
          [
            text @@ type_to_string @@ Lang.Expr.BasilExpr.type_of arg1;
            text @@ type_to_string @@ Lang.Expr.BasilExpr.type_of arg2;
          ]
  | _ -> text @@ Lang.Ops.AllOps.to_string op

and pretty_unary_op (op : Lang.Ops.AllOps.unary) arg =
  let open Containers_pp in
  match op with
  | #Lang.Ops.BVOps.unary ->
      (text @@ Lang.Ops.AllOps.to_string op)
      ^ text "_" ^ text @@ type_to_string
      @@ Lang.Expr.BasilExpr.type_of arg
  | _ -> text @@ Lang.Ops.AllOps.to_string op

and pretty_binary_expr (op : Lang.Ops.AllOps.binary) (arg1 : Lang.Program.e)
    (arg2 : Lang.Program.e) =
  let open Containers_pp in
  match op with
  | `EQ -> pretty_expr arg1 ^ sp ^ text "==" ^ sp ^ pretty_expr arg2
  | `NEQ -> pretty_expr arg1 ^ sp ^ text "!=" ^ sp ^ pretty_expr arg2
  | _ ->
      pretty_binary_op op arg1 arg2
      ^ surround ~width:2 (text "(")
          (newline_or_spaces 0 ^ pretty_expr arg1 ^ text ","
         ^ newline_or_spaces 1 ^ pretty_expr arg2)
          (newline_or_spaces 0 ^ text ")")

and pretty_unary_expr (op : Lang.Ops.AllOps.unary) (arg : Lang.Program.e) =
  let open Containers_pp in
  match op with
  | _ -> pretty_unary_op op arg ^ bracket "(" (pretty_expr arg) ")"

and pretty_apply_intrinsic (op : Lang.Ops.AllOps.intrin)
    (args : Lang.Program.e list) =
  let open Containers_pp in
  match op with
  | `BVConcat ->
      let mapped =
        List.map
          (fun e ->
            match Lang.Expr.BasilExpr.type_of e with
            | Bitvector size -> (pretty_expr e, size)
            | _ -> raise (BoogieException "May only concat bitvecs"))
          args
      in
      let body, _ =
        List.reduce_exn
          (fun (acc_t, acc_s) (t, s) ->
            ( surround ~width:2 (text "(")
                (newline_or_spaces 0 ^ acc_t ^ newline_or_spaces 0 ^ text "++"
               ^ newline_or_spaces 0 ^ t)
                (newline_or_spaces 0 ^ text "):")
              ^+ text "bv" ^ text
              @@ string_of_int (acc_s + s),
              acc_s + s ))
          mapped
      in
      surround ~width:0 (text "(") body (text ")")
  | _ -> raise (BoogieException "Unsupported intrinsic application")

and pretty_apply_function (func : Lang.Program.e) (args : Lang.Program.e list) =
  let open Containers_pp in
  pretty_expr func
  ^ surround ~width:2 (text "(")
      (fill (text "," ^ sp) (List.map pretty_expr args))
      (newline_or_spaces 0 ^ text ")")

and pretty_expr (Lang.Expr.BasilExpr.E e) =
  let open Containers_pp in
  match e with
  | RVar { attrib; id } -> pretty_variable id
  | Constant { attrib; const } -> pretty_const const
  | UnaryExpr { op; arg } -> pretty_unary_expr op arg
  | BinaryExpr { op; arg1; arg2 } -> pretty_binary_expr op arg1 arg2
  | ApplyIntrin { op; args } -> pretty_apply_intrinsic op args
  | ApplyFun { func; args } -> pretty_apply_function func args
  | _ -> raise (BoogieException "Unsupported expression")

let rec pretty_function_args (Lang.Expr.BasilExpr.E e) =
  let open Containers_pp in
  match e with
  | UnaryExpr { attrib; op = `Lambda; arg } -> pretty_function_args arg
  | Binding { attrib; bound = vs; in_body } ->
      fill (text "," ^ sp) (List.map pretty_variable_typed vs)
  | _ -> raise (BoogieException "Unsupported expression as function args")

let rec pretty_function_body (Lang.Expr.BasilExpr.E e) =
  let open Containers_pp in
  match e with
  | UnaryExpr { attrib; op = `Lambda; arg } -> pretty_function_body arg
  | Binding { attrib; bound = vs; in_body } -> pretty_expr in_body
  | _ -> raise (BoogieException "Unsupported expression as function body")

(* type func_type = Axiom of e | Uninterpreted | Function of e *)
let pretty_declaration (d : Lang.Program.declaration) =
  let open Containers_pp in
  let open Containers_pp.Infix in
  match d with
  | Lang.Program.Variable { binding; attrib } ->
      pretty_variable_declaration binding
  | Lang.Program.Function { binding; attrib; definition = Function t } ->
      text "function"
      ^+ (function_name @@ Var.name binding)
      ^ bracket "(" (pretty_function_args t) ")"
      ^+ text "returns"
      ^+ bracket "(" (text (type_to_string @@ Var.typ binding)) ")"
      ^+ surround ~width:2 (text "{")
           (newline ^ pretty_function_body t)
           (newline ^ text "}")
  | Lang.Program.Function { binding; attrib; definition = Axiom t } ->
      fill sp [ text "axiom"; bracket "(" (pretty_expr t) ")" ]
  | Lang.Program.Function { binding; attrib; definition = Uninterpreted } ->
      let param, rt = Types.uncurry (Var.typ binding) in
      text "function "
      ^ (function_name @@ Var.name binding)
      ^ bracket "("
          (fill
             (text "," ^ sp)
             (List.map (fun t -> text @@ type_to_string t) param))
          ")"
      ^ bracket " returns (" (text (type_to_string rt)) ")"
         ^ text ";"

let rec pretty_statement (s : Lang.Program.stmt) =
  let open Containers_pp in
  let open List.Infix in
  match s with
  | Instr_Assign [] -> text ""
  | Instr_Assign ls ->
      let lhs =
        ls
        >|= compose fst pretty_variable
        |> fill (text "," ^ newline_or_spaces 1)
      in
      let rhs =
        ls >|= compose snd pretty_expr |> fill (text "," ^ newline_or_spaces 1)
      in
      nest 2 @@ lhs ^+ text ":=" ^+ rhs
  | Instr_Assert { body } -> text "assert" ^+ pretty_expr body
  | Instr_Assume { body; branch } -> text "assume" ^+ pretty_expr body
  | Instr_Store { lhs; rhs; value; addr = Scalar } -> text "STORE SCALAR"
  | Instr_Store { lhs; rhs; value; addr = Addr { addr; size; endian } } ->
      let fn_name =
        Printf.sprintf "store%d_%s" size (Lang.Stmt.show_endian endian)
      in
      pretty_statement
        (Lang.Stmt.Instr_Assign
           [
             ( lhs,
               Lang.Expr.BasilExpr.fapply
                 (Lang.Expr.BasilExpr.rvar (Var.create fn_name (Var.typ lhs)))
                 [ Lang.Expr.BasilExpr.rvar rhs; addr; value ] );
           ])
  | Instr_Load { lhs; rhs; addr = Scalar } -> text "LOAD SCALAR"
  | Instr_Load { lhs; rhs; addr = Addr { addr; size; endian } } ->
      let fn_name =
        Printf.sprintf "load%d_%s" size (Lang.Stmt.show_endian endian)
      in
      pretty_statement
        (Lang.Stmt.Instr_Assign
           [
             ( lhs,
               Lang.Expr.BasilExpr.fapply
                 (Lang.Expr.BasilExpr.rvar (Var.create fn_name (Var.typ lhs)))
                 [ Lang.Expr.BasilExpr.rvar rhs; addr ] );
           ])
  | Instr_IntrinCall { lhs; name; args } ->
      let lhs =
        if StringMap.cardinal lhs > 0 then
          (StringMap.bindings lhs
          |> List.map (compose snd pretty_variable)
          |> fill (text "," ^ newline_or_spaces 1))
          ^+ text ":=" ^ sp
        else text ""
      in
      let rhs =
        StringMap.bindings args
        |> List.map (compose snd pretty_expr)
        |> fill (text "," ^ newline_or_spaces 1)
      in
      nest 2 @@ text "call" ^+ lhs ^ (proc_name name) ^ bracket "(" rhs ")"
  | Instr_IndirectCall { target } -> text "INDIRECT CALL"
  | Instr_Call { lhs; procid; args } ->
      pretty_statement
      @@ Lang.Stmt.Instr_IntrinCall { lhs; name = ID.name procid; args }

let pretty_terminator (p : Lang.Program.proc) (i : IDSet.elt)
    (b : Lang.Procedure.Edge.block) =
  let open Containers_pp in
  Lang.Procedure.graph p
  |> Option.map (fun g ->
      match Lang.Procedure.G.succ_e g (Lang.Procedure.Vert.End i) with
      | [] -> text "Unreachable"
      | [ (b, re, Return) ] -> text "return"
      | succ ->
          let succ =
            List.map
              (fun (_, e, v) ->
                match v with
                | Lang.Procedure.Vert.Begin i -> block_name v
                | _ -> raise (BoogieException "Bad graph structure"))
              succ
          in
          text "goto" ^+ fill (text "," ^ sp) succ)
  |> Option.get

let pretty_block (p : Lang.Program.proc) (i : IDSet.elt)
    (b : Lang.Procedure.Edge.block) =
  let open Containers_pp in
  let g = Lang.Procedure.graph p in
  let name = block_name (Lang.Procedure.Vert.Begin i) in
  let stmts =
    Lang.Block.stmts_iter b |> Iter.map pretty_statement |> Iter.to_list
  in
  let terminator = [ pretty_terminator p i b ] in
  let body = stmts @ terminator |> join_lines in
  name ^ text ":" ^/ body |> nest 2

let pretty_procedure_header (s : string) (p : Lang.Program.proc) =
  let open Containers_pp in
  let open Containers_pp.Infix in
  let param_list sm =
    StringMap.bindings sm
    |> List.map (function i, p -> pretty_variable_typed p)
    |> fill (text "," ^ newline_or_spaces 1)
  in
  let in_params = Lang.Procedure.formal_in_params p in
  let out_params = Lang.Procedure.formal_out_params p in
  let args = bracket "(" (param_list in_params) ")" in
  let returns =
    if StringMap.cardinal out_params > 0 then
      sp ^ text "returns" ^+ bracket "(" (param_list out_params) ")"
    else text ""
  in
  let header = text s ^+ proc_name (ID.name @@ Lang.Procedure.id p) ^ args ^ returns in
  header

let pretty_modifies (p : Lang.Program.proc) =
  let open Containers_pp in
  let spec = Lang.Procedure.specification p in
  if List.is_empty spec.modifies_globs then []
  else
    [
      text "modifies"
      ^+ (spec.modifies_globs |> List.map pretty_variable
         |> fill (text "," ^ sp));
    ]

let pretty_ensures (p : Lang.Program.proc) =
  let open Containers_pp in
  let spec = Lang.Procedure.specification p in
  spec.ensures |> List.map pretty_expr
  |> List.map (fun s -> text "ensures" ^+ s)

let pretty_requires (p : Lang.Program.proc) =
  let open Containers_pp in
  let spec = Lang.Procedure.specification p in
  spec.requires |> List.map pretty_expr
  |> List.map (fun s -> text "requires" ^+ s)

let pretty_procedure_spec (p : Lang.Program.proc) =
  let open Containers_pp in
  let open Containers_pp.Infix in
  let header = pretty_procedure_header "procedure" p in
  let modifies = pretty_modifies p in
  let ensures = pretty_ensures p in
  let requires = pretty_requires p in
  nest 2 @@ join_lines ([ header ] @ modifies @ ensures @ requires)

let pretty_procedure_impl (p : Lang.Program.proc) =
  let open Containers_pp in
  let open Containers_pp.Infix in
  let in_params = Lang.Procedure.formal_in_params p in
  let out_params = Lang.Procedure.formal_out_params p in
  let local_decls =
    Lang.Procedure.local_decls p
    |> Hashtbl.to_list
    |> List.filter (fun (k, v) ->
        (Option.is_none @@ StringMap.get k in_params)
        && (Option.is_none @@ StringMap.get k out_params))
    |> List.map (fun (k, v) -> pretty_variable_declaration v)
    |> join_lines_end
  in
  let blocks =
    Lang.Procedure.iter_blocks_topo_fwd p
    |> Iter.map (fun (i, b) -> pretty_block p i b)
    |> Iter.to_list |> join_lines_end
  in
  let header = pretty_procedure_header "implementation" p in
  let body = local_decls ^/ blocks in
  header ^+ surround ~width:2 (text "{") (newline ^ body) (newline ^ text "}")

let pretty_procedure (p : Lang.Program.proc) =
  let open Containers_pp in
  join_lines
  @@ [ pretty_procedure_spec p ]
  @
  if negate List.is_empty @@ Lang.Procedure.blocks_to_list p then
    [ pretty_procedure_impl p ]
  else []

let pretty_program (p : Lang.Program.t) =
  let open Containers_pp in
  let glob_vars, glob_funs =
    p.globals |> StringMap.bindings |> List.map snd
    |> List.partition_filter_map (fun d ->
        let p = pretty_declaration d in
        match d with
        | Lang.Program.Variable _
        | Lang.Program.Function { definition = Axiom _ } ->
            `Left p
        | _ -> `Right p)
  in
  let glob_vars = join_lines_end glob_vars in
  let glob_funs = append_nl glob_funs in
  let procs =
    p.procs |> ID.Map.to_list
    |> List.map (fun (_, p) -> pretty_procedure p)
    |> join_lines_end ~s:"\n"
  in
  append_l ~sep:(newline ^ newline) [ glob_vars; glob_funs; procs ]

let pretty_to_chan chan (p : Lang.Program.t) =
  let p = pretty_program p in
  flush chan;
  let fmt = Format.formatter_of_out_channel chan in
  Containers_pp.Pretty.to_format ~width:80 fmt p;
  Format.flush fmt ()

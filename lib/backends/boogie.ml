open Containers
open Bincaml_util.Common

exception BoogieException of string

let function_name name =
  let open Containers_pp in
  let name =
    if String.starts_with ~prefix:"$" name then String.concat "" [ "f"; name ]
    else name
  in
  text name

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

let join_lines_end ls =
  let open Containers_pp in
  let ls = List.map (fun t -> t ^ text ";") ls in
  append_l ~sep:newline ls

let rec type_to_string (t : Types.t) =
  match t with
  | Types.Boolean -> "bool"
  | Types.Integer -> "int"
  | Types.Bitvector i -> String.cat "bv" (Int.to_string i)
  | Types.Map (i, o) ->
      String.concat "" [ "["; type_to_string i; "]"; type_to_string o ]
  | Types.Variable s -> s
  | Types.Sort (s, vs) -> s
  | t ->
      raise
        (BoogieException (String.cat "Unsupported type" (Types.to_string t)))

let pretty_variable_declaration ?(const = false) (v : Var.t) =
  let open Containers_pp in
  (if const then text "const " else text "var ")
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
  | `Record _ -> raise (BoogieException "records unsupported by boogie backend")
  | `Pointer _ ->
      raise (BoogieException "pointers unsupported by boogie backend")
  | `Sort _ -> raise (BoogieException "const sorts unsupported by boogie backend")

let pretty_call_args_no_brackets (args : Containers_pp.t list) =
  let open Containers_pp in
  newline_or_spaces 0 ^ List.hd args
  ^ append_l
      (List.map
         (fun arg -> text "," ^ newline_or_spaces 1 ^ arg)
         (List.tl args))

let pretty_call_args (args : Containers_pp.t list) =
  let open Containers_pp in
  surround ~width:2 (text "(")
    (newline_or_spaces 0 ^ List.hd args
    ^ append_l
        (List.map
           (fun arg -> text "," ^ newline_or_spaces 1 ^ arg)
           (List.tl args)))
    (newline_or_spaces 0 ^ text ")")

let pretty_binary_expr (op : Lang.Ops.AllOps.binary) (ty1, arg1) (ty2, arg2)
    (t : Types.t) =
  let open Containers_pp in
  match op with
  | `MapAccess -> arg1 ^ bracket "[" arg2 "]"
  | `WriteField s ->
      arg1 ^ text "->" ^ bracket "(" (text s ^+ text ":=" ^+ arg2) ")"
  | _ -> (
      match Transforms.Boogie_prepass.Builtins.name op [ ty1; ty2; t ] with
      | Function name -> text name ^ pretty_call_args [ arg1; arg2 ]
      | Infix name -> bracket "(" (arg1 ^+ text name ^+ arg2) ")"
      | _ -> failwith "Unsupported binary expr")

let pretty_unary_expr (op : Lang.Ops.AllOps.unary) (ty, arg) (rt : Types.t) =
  let open Containers_pp in
  match op with
  | `BOOLTOBV1 -> bracket "(if (" arg ")" ^+ text "then (1bv1) else (0bv1))"
  | `BoolNOT -> bracket "(!(" arg "))"
  | `Old -> bracket "old(" arg ")"
  | _ -> (
      match Transforms.Boogie_prepass.Builtins.name op [ ty; rt ] with
      | Function name -> text name ^ pretty_call_args [ arg ]
      | Prefix name -> text name ^ arg
      | Infix name -> failwith "Unary expressions may not be infix"
      | Postfix name -> arg ^ text name
      | _ ->
          failwith
          @@ Printf.sprintf "Unsupported unary expr: %s"
          @@ Lang.Ops.AllOps.to_string op)

let pretty_apply_intrinsic (op : Lang.Ops.AllOps.intrin)
    (args : (Types.t * Containers_pp.t) list) (t : Types.t) =
  let open Containers_pp in
  match op with
  (* BVConcat has explicit type annotations on each intermediate expression because of a bug in boogie, yay *)
  | `BVConcat ->
      bracket "("
        (append_l
           ~sep:(newline_or_spaces 1 ^ text "++" ^ newline_or_spaces 1)
           (List.map snd args))
        ")"
      ^ text ":" ^+ text @@ type_to_string @@ t
  | `MapUpdate ->
      let args = List.map snd args in
      List.hd args
      ^ surround ~width:0 (text "[")
          (List.nth args 1 ^+ text ":=" ^+ List.nth args 2)
          (text "]")
  | `AND -> bracket "(" (append_l ~sep:(text "&&") (List.map snd args)) ")"
  | `OR -> bracket "(" (append_l ~sep:(text "||") (List.map snd args)) ")"
  | e ->
      let x = Lang.Ops.AllOps.to_string e in
      raise
        String.(
          BoogieException (String.cat "Unsupported intrinsic application " x))

let pretty_apply_function (func : Containers_pp.t)
    (args : (Types.t * Containers_pp.t) list) =
  let open Containers_pp in
  func ^ pretty_call_args (List.map snd args)

let type_of e = Lang.Expr.BasilExpr.type_alg (Lang.Expr.AbstractExpr.map fst e)

let rec pretty_attribute (attr : Lang.Program.e Lang.Attrib.t) =
  let open Containers_pp in
  match attr with
  | `List l -> List.flat_map pretty_attribute l
  | `String s -> [ text s ]
  | `Expr e -> [ pretty_expr e ]
  | _ -> []

and pretty_attribute_map (key : string)
    (a : Lang.Program.e Lang.Attrib.attrib_map) =
  let open Containers_pp in
  StringMap.find_opt key a |> Option.to_list
  |> List.flat_map (function `Assoc m -> StringMap.to_list m | _ -> [])
  |> List.map (function k, f ->
      bracket "{"
        (text ":" ^ text (String.drop 1 k) ^+ append_sp @@ pretty_attribute f)
        "}")
  |> append_sp

and pretty_triggers (attrib : Lang.Program.e Lang.Attrib.t option) =
  let open Containers_pp in
  Lang.Attrib.find_opt ".triggers" attrib
  |> Option.map (fun attrib ->
      append_sp
      @@ List.map (fun b -> bracket "{" b "}")
      @@ pretty_attribute attrib)
  |> Option.get_or ~default:(text "")
  (* Option.map (Lang.Attrib.attrib_pretty Lang.Expr.BasilExpr.pretty) attrib |> Option.get_or ~default:(text "MAGIC") *)

and pretty_binding_expr ?(attrib : Lang.Program.e Lang.Attrib.t option) bound
    in_body =
  let open Containers_pp in
  pretty_call_args_no_brackets (List.map pretty_variable_typed bound)
  ^+ text "::" ^+ newline_or_spaces 0 ^ pretty_triggers attrib
  ^+ newline_or_spaces 0 ^ snd in_body

and pretty_expr_alg
    (e : (Types.t * Containers_pp.t) Lang.Expr.BasilExpr.abstract_expr) =
  let open Containers_pp in
  match e with
  | RVar { attrib; id } -> pretty_variable id
  | Constant { attrib; const } -> pretty_const const
  | Lambda { attrib; op; bound_vars; in_body } ->
      let op =
        text
        @@
        match op with
        | `Forall -> "forall"
        | `Exists -> "exists"
        | `Lambda -> "lambda"
      in
      bracket "(" (op ^+ pretty_binding_expr ?attrib bound_vars in_body) ")"
  | UnaryExpr { op; arg } -> pretty_unary_expr op arg (type_of e)
  | BinaryExpr { op; arg1; arg2 } -> pretty_binary_expr op arg1 arg2 (type_of e)
  | ApplyIntrin { op; args } -> pretty_apply_intrinsic op args (type_of e)
  | ApplyFun { func; args } -> pretty_apply_function (snd func) args
  | Let _ -> failwith "removed in prepass"

and pretty_expr e = Lang.Expr.BasilExpr.fold_with_type_r pretty_expr_alg e

let pretty_function_args (e : Lang.Program.e) =
  let open Containers_pp in
  match Lang.Expr.BasilExpr.unfix2 e with
  | Lambda { bound_vars } ->
      fill (text "," ^ sp) (List.map pretty_variable_typed bound_vars)
  | _ -> raise (BoogieException "Unsupported expression as function args")

let pretty_function_body funcname (e : Lang.Program.e) =
  let open Containers_pp in
  match Lang.Expr.BasilExpr.unfix e with
  | Lambda { attrib; op = `Lambda; bound_vars; in_body } ->
      let _, rt = Types.uncurry (Var.typ funcname) in
      (pretty_expr in_body, text @@ type_to_string rt)
  | _ ->
      raise
        (BoogieException
           (Printf.sprintf "Unsupported expression as function body of %s: %s"
              (Var.to_string funcname)
              (Lang.Expr.BasilExpr.to_string e)))

let pretty_variant_declaration (v : Types.variant) =
  let open Containers_pp in
  text v.variant
  ^ bracket "("
      (append_l
         ~sep:(text "," ^ sp)
         (List.map
            (fun (f : Types.field) ->
              text f.field ^ text ":" ^+ text (type_to_string f.typ))
            v.fields))
      ")"

let pretty_type_declaration (binding : string) (typ : Types.t) =
  let open Containers_pp in
  match typ with
  | Types.Sort (s, vs) ->
      text "datatype" ^+ text binding
      ^+ bracket "{" (append_sp (List.map pretty_variant_declaration vs)) "}"
  | _ -> raise (BoogieException "Unsupported type declaration")

let pretty_declaration (d : Lang.Program.declaration) =
  let open Containers_pp in
  let open Containers_pp.Infix in
  match d with
  | Lang.Program.Variable { binding; attrib } ->
      pretty_variable_declaration binding
  | Lang.Program.Function { binding; attrib; definition = Function t } ->
      let func_body, return_type = pretty_function_body binding t in

      (* Ideally use above return type
       * but unfortunately curry will uncurry returned maps... :( *) 
      let return_type = Lang.Expr.BasilExpr.type_of t in
      let return_type = text @@ type_to_string return_type in

      text "function"
      ^+ pretty_attribute_map ".boogie" attrib
      ^+ (function_name @@ Var.name binding)
      ^ bracket "(" (pretty_function_args t) ")"
      ^+ text "returns"
      ^+ bracket "(" return_type ")"
      ^+ surround ~width:2 (text "{") (newline ^ func_body) (newline ^ text "}")
  | Lang.Program.Function { binding; attrib; definition = Axiom t } ->
      fill sp [ text "axiom"; bracket "(" (pretty_expr t) ")" ]
  | Lang.Program.Function { binding; attrib; definition = Uninterpreted }
    when List.is_empty (fst @@ Types.uncurry (Var.typ binding)) ->
      pretty_variable_declaration ~const:true binding ^ text ";"
  | Lang.Program.Function { binding; attrib; definition = Uninterpreted } ->
      let param, rt = Types.uncurry (Var.typ binding) in
      text "function"
      ^+ pretty_attribute_map ".boogie" attrib
      ^+ (function_name @@ Var.name binding)
      ^ bracket "("
          (fill
             (text "," ^ sp)
             (List.map (fun t -> text @@ type_to_string t) param))
          ")"
      ^ bracket " returns (" (text (type_to_string rt)) ")"
      ^ text ";"
  | Lang.Program.Type { binding; typ } -> pretty_type_declaration binding typ

let rec pretty_statement (s : Lang.Program.stmt) =
  let open Containers_pp in
  let open List.Infix in
  match s with
  | Instr_Assign [] -> text "assert true"
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
      nest 2 @@ text "call" ^+ lhs ^ proc_name name ^ bracket "(" rhs ")"
  | Instr_Call { lhs; procid; args } ->
      pretty_statement
      @@ Lang.Stmt.Instr_IntrinCall { lhs; name = ID.name procid; args }
  | stmt ->
      raise
        (BoogieException
           (Printf.sprintf
              "Unsupported statement: expected boogie pre pass to remove:\n\t%s"
              (Lang.Stmt.to_string Var.pretty Var.pretty
                 Lang.Expr.BasilExpr.pretty stmt)))

let pretty_terminator (p : Lang.Program.proc) (i : IDSet.elt)
    (b : Lang.Procedure.Edge.block) =
  let open Containers_pp in
  match Lang.Procedure.graph p with
  | Some a -> (
      match Lang.Procedure.G.succ_e a (Lang.Procedure.Vert.End i) with
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
  | _ -> failwith "no procedure graph"

let pretty_block (p : Lang.Program.proc) (i : IDSet.elt)
    (b : Lang.Procedure.Edge.block) =
  let open Containers_pp in
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
  let header =
    text s ^+ proc_name (ID.name @@ Lang.Procedure.id p) ^ args ^ returns
  in
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
  nest 2 @@ join_lines_end ([ header ] @ modifies @ ensures @ requires)

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
  append_nl
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
    |> append_l ~sep:(newline ^ newline)
  in
  append_l ~sep:(newline ^ newline) [ glob_vars; glob_funs; procs ]

let pretty_to_chan chan (p : Lang.Program.t) =
  let p = Transforms.Boogie_prepass.transform p in
  let p = pretty_program p in
  flush chan;
  let fmt = Format.formatter_of_out_channel chan in
  Containers_pp.Pretty.to_format ~width:80 fmt p;
  Format.flush fmt ()

open Containers
open Bincaml_util.Common
open Lang

exception BoogieException of string

let var_name name =
  let name = Var.name name in
  let name =
    String.chop_prefix ~pre:"$" name
    |> Option.map (fun s -> "$" ^ s)
    |> Option.get_or ~default:name
  in
  name

let function_name name =
  let open Containers_pp in
  text (var_name name)

let proc_name name =
  let open Containers_pp in
  let name = String.map (fun c -> match c with '@' -> '$' | _ -> c) name in
  text "p" ^ text name

let block_name v =
  let open Containers_pp in
  let name = Procedure.Vert.block_id_string v in
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
  ^ text (var_name v)
  ^ text ": "
  ^ text (type_to_string @@ Var.typ v)

let pretty_variable (v : Var.t) =
  let open Containers_pp in
  text (var_name v)

let pretty_variable_typed (v : Var.t) =
  let open Containers_pp in
  text (var_name v) ^ text ": " ^ text (type_to_string @@ Var.typ v)

let pretty_const (c : Ops.AllOps.const) =
  let open Containers_pp in
  match c with
  | `Integer i -> text @@ Z.format "%d" i
  | `Bitvector bv -> text @@ Printf.sprintf "%sbv%d" (Z.format "%d" bv.v) bv.w
  | `Bool b -> text @@ string_of_bool b
  | `Record _ -> raise (BoogieException "records unsupported by boogie backend")
  | `Pointer _ ->
      raise (BoogieException "pointers unsupported by boogie backend")
  | `Sort _ ->
      raise (BoogieException "const sorts unsupported by boogie backend")

let pretty_call_args_no_brackets (args : Containers_pp.t list) =
  let open Containers_pp in
  newline_or_spaces 0
  ^
  match args with
  | [] -> text ""
  | [ hd ] -> hd
  | hd :: tl ->
      hd ^ append_l
      @@ List.map (fun arg -> text "," ^ newline_or_spaces 1 ^ arg) tl

let pretty_call_args (args : Containers_pp.t list) =
  let open Containers_pp in
  surround ~width:2 (text "(")
    (newline_or_spaces 0 ^ List.hd args
    ^ append_l
        (List.map
           (fun arg -> text "," ^ newline_or_spaces 1 ^ arg)
           (List.tl args)))
    (newline_or_spaces 0 ^ text ")")

let pretty_binary_expr (op : Ops.AllOps.binary) (ty1, arg1) (ty2, arg2)
    (t : Types.t) =
  let open Containers_pp in
  match op with
  | `MapAccess -> arg1 ^ bracket "[" arg2 "]"
  | `WriteField s ->
      arg1 ^ text "->" ^ bracket "(" (text s ^+ text ":=" ^+ arg2) ")"
  | `Load e ->
      let name =
        match e with
        | `Big, i -> Printf.sprintf "load%d_be" i
        | `Little, i -> Printf.sprintf "load%d_le" i
      in
      (text @@ name) ^ bracket "(" (arg1 ^ text "," ^+ arg2) ")"
  | `IfThen -> text "if" ^+ arg1 ^+ text "then" ^+ arg2
  | _ -> (
      match Transforms.Boogie_prepass.Builtins.name op [ ty1; ty2; t ] with
      | Function name -> text name ^ pretty_call_args [ arg1; arg2 ]
      | Infix name -> bracket "(" (arg1 ^+ text name ^+ arg2) ")"
      | _ ->
          failwith
            (Printf.sprintf "Unsupported binary expr: %s"
               (Ops.AllOps.to_string op)))

let pretty_unary_expr (op : Ops.AllOps.unary) (ty, arg) (rt : Types.t) =
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
          @@ Ops.AllOps.to_string op)

let pretty_apply_intrinsic (op : Ops.AllOps.intrin)
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
  | `AND ->
      bracket "("
        (append_l
           ~sep:(newline_or_spaces 1 ^ text "&&" ^ newline_or_spaces 1)
           (List.map snd args))
        ")"
  | `OR -> bracket "(" (append_l ~sep:(text "||") (List.map snd args)) ")"
  | `Cases -> (
      match args with
      | [ a ] -> snd a
      | [] -> failwith "empty cases"
      | h :: tl ->
          List.fold_left
            (fun a b -> a ^+ text "else" ^+ b)
            (snd h) (List.map snd tl))
  | e -> (
      match args with
      | [ (ty1, arg1); (ty2, arg2) ] -> (
          match Transforms.Boogie_prepass.Builtins.name op [ ty1; ty2; t ] with
          | Function name -> text name ^ pretty_call_args [ arg1; arg2 ]
          | Infix name -> bracket "(" (arg1 ^+ text name ^+ arg2) ")"
          | _ -> failwith "Unsupported binary-reduced intrinsic expr ")
      | _ ->
          let x = Ops.AllOps.to_string e in
          raise
            String.(
              BoogieException
                (String.cat "Unsupported intrinsic application: " x)))

let pretty_apply_function (func : Containers_pp.t)
    (args : (Types.t * Containers_pp.t) list) =
  let open Containers_pp in
  func ^ pretty_call_args (List.map snd args)

let type_of e = Expr.BasilExpr.type_alg (Expr.AbstractExpr.map fst e)

let rec pretty_attribute (attr : Attrib.t) =
  let open Containers_pp in
  match attr with
  | `List l -> List.flat_map pretty_attribute l
  | `String s -> [ text s ]
  | _ -> []

and pretty_attribute_map (key : string) (a : Attrib.attrib_map) =
  let open Containers_pp in
  StringMap.find_opt key a |> Option.to_list
  |> List.flat_map (function `Assoc m -> StringMap.bindings m | _ -> [])
  |> List.map (function k, f ->
      bracket "{"
        (text ":" ^ text (String.drop 1 k) ^+ append_sp @@ pretty_attribute f)
        "}")
  |> append_sp

and pretty_triggers (triggers : Containers_pp.t list list) =
  let open Containers_pp in
  triggers
  |> List.map (fun attrib -> bracket "{" (append_l ~sep:(text ", ") attrib) "}")
  |> append_sp
(* Option.map (Attrib.attrib_pretty Expr.BasilExpr.pretty) attrib |> Option.get_or ~default:(text "MAGIC") *)

and pretty_binding_expr triggers bound in_body =
  let open Containers_pp in
  pretty_call_args_no_brackets (List.map pretty_variable_typed bound)
  ^+ text "::" ^+ newline_or_spaces 0 ^ pretty_triggers triggers
  ^+ newline_or_spaces 0 ^ snd in_body

and pretty_expr_alg
    (e : (Types.t * Containers_pp.t) Expr.BasilExpr.abstract_expr) =
  let open Containers_pp in
  match e with
  | RVar { attrib; id } -> pretty_variable id
  | Constant { attrib; const } -> pretty_const const
  | Lambda { attrib; op; bound_vars; in_body; triggers } ->
      let op =
        text
        @@
        match op with
        | `Forall -> "forall"
        | `Exists -> "exists"
        | `Lambda -> "lambda"
      in
      bracket "("
        (op
        ^+ pretty_binding_expr
             (List.map (List.map snd) triggers)
             bound_vars in_body)
        ")"
  | UnaryExpr { op; arg } -> pretty_unary_expr op arg (type_of e)
  | BinaryExpr { op; arg1; arg2 } -> pretty_binary_expr op arg1 arg2 (type_of e)
  | ApplyIntrin { op; args } -> pretty_apply_intrinsic op args (type_of e)
  | ApplyFun { func; args } -> pretty_apply_function (snd func) args
  | Let _ -> failwith "removed in prepass"

and pretty_expr e = Expr.BasilExpr.fold_with_type_r pretty_expr_alg e

let pretty_function_args (e : Program.e) =
  let open Containers_pp in
  match Expr.BasilExpr.unfix2 e with
  | Lambda { bound_vars } ->
      fill (text "," ^ sp) (List.map pretty_variable_typed bound_vars)
  | _ -> raise (BoogieException "Unsupported expression as function args")

let pretty_function_body funcname (e : Program.e) =
  let open Containers_pp in
  match Expr.BasilExpr.unfix e with
  | Lambda { attrib; op = `Lambda; bound_vars; in_body } ->
      let _, rt = Types.uncurry (Var.typ funcname) in
      (pretty_expr in_body, text @@ type_to_string rt)
  | _ ->
      raise
        (BoogieException
           (Printf.sprintf "Unsupported expression as function body of %s: %s"
              (Var.to_string funcname)
              (Expr.BasilExpr.to_string e)))

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

let rec pretty_statement (s : Program.stmt) =
  let open Containers_pp in
  let open List.Infix in
  match s with
  | Instr_IntrinCall { lhs; name; args } ->
      let lhs =
        if List.length lhs > 0 then
          (List.map pretty_variable lhs |> fill (text "," ^ newline_or_spaces 1))
          ^+ text ":=" ^ sp
        else text ""
      in
      let rhs =
        List.map pretty_expr args |> fill (text "," ^ newline_or_spaces 1)
      in
      nest 2 @@ text "call" ^+ lhs ^ Stmt.Intrinsic.pretty name
      ^ bracket "(" rhs ")"
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
  | Instr_Call { lhs; procid; args } ->
      let name = ID.name procid in
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
  | stmt ->
      raise
        (BoogieException
           (Printf.sprintf
              "Unsupported statement: expected boogie pre pass to remove:\n\t%s"
              (Stmt.to_string Var.pretty Var.pretty Expr.BasilExpr.pretty stmt)))

let pretty_terminator (p : Program.proc) (i : IDSet.elt)
    (b : Procedure.Edge.block) =
  let open Containers_pp in
  match Procedure.graph p with
  | Some a -> (
      match Procedure.G.succ_e a (Procedure.Vert.End i) with
      | [] -> text "Unreachable"
      | [ (b, re, Return) ] -> text "return"
      | succ ->
          let succ =
            List.map
              (fun (_, e, v) ->
                match v with
                | Procedure.Vert.Begin i -> block_name v
                | _ -> raise (BoogieException "Bad graph structure"))
              succ
          in
          text "goto" ^+ fill (text "," ^ sp) succ)
  | _ -> failwith "no procedure graph"

let pretty_block (p : Program.proc) (i : IDSet.elt) (b : Procedure.Edge.block) =
  let open Containers_pp in
  let name = block_name (Procedure.Vert.Begin i) in
  let stmts = Block.stmts_iter b |> Iter.map pretty_statement |> Iter.to_list in
  let terminator = [ pretty_terminator p i b ] in
  let body = stmts @ terminator |> join_lines in
  name ^ text ":" ^/ body |> nest 2

let pretty_procedure_header (s : string) (p : Program.proc) =
  let open Containers_pp in
  let open Containers_pp.Infix in
  let param_list sm =
    StringMap.bindings sm
    |> List.map (function i, p -> pretty_variable_typed p)
    |> fill (text "," ^ newline_or_spaces 1)
  in
  let in_params = Procedure.formal_in_params p in
  let out_params = Procedure.formal_out_params p in
  let args = bracket "(" (param_list in_params) ")" in
  let returns =
    if StringMap.cardinal out_params > 0 then
      sp ^ text "returns" ^+ bracket "(" (param_list out_params) ")"
    else text ""
  in
  let header =
    text s ^+ proc_name (ID.name @@ Procedure.id p) ^ args ^ returns
  in
  header

let pretty_modifies (p : Program.proc) =
  let open Containers_pp in
  let spec = Procedure.specification p in
  if List.is_empty spec.modifies_globs then []
  else
    [
      text "modifies"
      ^+ (spec.modifies_globs |> List.map pretty_variable
         |> fill (text "," ^ sp));
    ]

let pretty_ensures (p : Program.proc) =
  let open Containers_pp in
  let spec = Procedure.specification p in
  spec.ensures |> List.map pretty_expr
  |> List.map (fun s -> text "ensures" ^+ s)

let pretty_requires (p : Program.proc) =
  let open Containers_pp in
  let spec = Procedure.specification p in
  spec.requires |> List.map pretty_expr
  |> List.map (fun s -> text "requires" ^+ s)

let pretty_procedure_spec (p : Program.proc) =
  let open Containers_pp in
  let open Containers_pp.Infix in
  let header = pretty_procedure_header "procedure" p in
  let modifies = pretty_modifies p in
  let ensures = pretty_ensures p in
  let requires = pretty_requires p in
  nest 2 @@ join_lines_end ([ header ] @ modifies @ ensures @ requires)

let pretty_procedure_impl (p : Program.proc) =
  let open Containers_pp in
  let open Containers_pp.Infix in
  let in_params = Procedure.formal_in_params p in
  let out_params = Procedure.formal_out_params p in
  let local_decls =
    Procedure.local_decls p |> Hashtbl.to_list
    |> List.filter (fun (k, v) ->
        (Option.is_none @@ StringMap.get k in_params)
        && (Option.is_none @@ StringMap.get k out_params))
    |> List.map (fun (k, v) -> pretty_variable_declaration v)
    |> join_lines_end
  in
  let blocks =
    Procedure.iter_blocks_topo_fwd p
    |> Iter.map (fun (i, b) -> pretty_block p i b)
    |> Iter.to_list |> join_lines_end
  in
  let header = pretty_procedure_header "implementation" p in
  let body = local_decls ^/ blocks in
  header ^+ surround ~width:2 (text "{") (newline ^ body) (newline ^ text "}")

let pretty_procedure (p : Program.proc) =
  let open Containers_pp in
  append_nl
  @@ [ pretty_procedure_spec p ]
  @
  if negate List.is_empty @@ Procedure.blocks_to_list p then
    [ pretty_procedure_impl p ]
  else []

let pretty_declaration (d : Program.declaration) =
  let open Containers_pp in
  let open Containers_pp.Infix in
  match d with
  | Program.Variable { binding; attrib } ->
      pretty_variable_declaration binding ^ text ";"
  | Program.Function { binding; attrib; definition = Function t } ->
      let func_body, return_type = pretty_function_body binding t in

      (* Ideally use above return type
       * but unfortunately curry will uncurry returned maps... :( *)
      let return_type = Expr.BasilExpr.type_of t in
      let return_type = text @@ type_to_string return_type in

      text "function"
      ^+ pretty_attribute_map ".boogie" attrib
      ^+ (function_name @@ binding)
      ^ bracket "(" (pretty_function_args t) ")"
      ^+ text "returns"
      ^+ bracket "(" return_type ")"
      ^+ surround ~width:2 (text "{") (newline ^ func_body) (newline ^ text "}")
  | Program.Function { binding; attrib; definition = Axiom t } ->
      fill sp [ text "axiom"; bracket "(" (pretty_expr t) ")" ] ^ text ";"
  | Program.Function { binding; attrib; definition = Uninterpreted }
    when List.is_empty (fst @@ Types.uncurry (Var.typ binding)) ->
      pretty_variable_declaration ~const:true binding ^ text ";"
  | Program.Function { binding; attrib; definition = Uninterpreted } ->
      let param, rt = Types.uncurry (Var.typ binding) in
      text "function"
      ^+ pretty_attribute_map ".boogie" attrib
      ^+ (function_name @@ binding)
      ^ bracket "("
          (fill
             (text "," ^ sp)
             (List.map (fun t -> text @@ type_to_string t) param))
          ")"
      ^ bracket " returns (" (text (type_to_string rt)) ")"
      ^ text ";"
  | Program.Type { binding; typ } -> pretty_type_declaration binding typ
  | Procedure { definition } -> pretty_procedure definition

let pretty_program (p : Program.t) =
  let open Containers_pp in
  let glob_vars_funs, rest =
    Program.declarations p |> Iter.map snd |> Iter.to_list
    |> List.partition_filter_map (fun d ->
        let p = pretty_declaration d in
        match d with
        | Program.Variable _ | Program.Function _ | Program.Type _ -> `Left p
        | _ -> `Right p)
  in
  let glob_vars = append_nl glob_vars_funs in
  let rest = append_nl rest in
  append_l ~sep:(newline ^ newline) [ glob_vars; rest ]

let pretty_to_chan chan (p : Program.t) =
  let p = Transforms.Boogie_prepass.transform p in
  let p = pretty_program p in
  flush chan;
  let fmt = Format.formatter_of_out_channel chan in
  Containers_pp.Pretty.to_format ~width:80 fmt p;
  Format.flush fmt ()

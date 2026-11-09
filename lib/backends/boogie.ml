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

let rec type_to_string types (t : Types.t) =
  match t with
  | Types.Boolean -> "bool"
  | Types.Integer -> "int"
  | Types.Bitvector i -> String.cat "bv" (Int.to_string i)
  | Types.Map (i, o) ->
      String.concat ""
        [ "["; type_to_string types i; "]"; type_to_string types o ]
  | Types.Function (i, o) ->
      String.concat ""
        [ "["; type_to_string types i; "]"; type_to_string types o ]
  | Types.Variable s -> s
  | Types.NewType _ | Record _ | Variant _ ->
      let t = Bincaml_util.Types_datatype.get_datatype types t in
      datatype_rpos_to_string types t
  | Unit | Top | Nothing ->
      raise
        (BoogieException (String.cat "Unsupported type" (Types.to_string t)))

and datatype_rpos_to_string types (dt : Bincaml_util.Types_datatype.datatype) =
  match dt with
  | ADT { name; cases } -> name
  | Sort { name } -> name
  | Prim typ -> type_to_string types typ

let pretty_variable_declaration types ?(const = false) (v : Var.t) =
  let open Containers_pp in
  (if const then text "const " else text "var ")
  ^ text (var_name v)
  ^ text ": "
  ^ text (type_to_string types @@ Var.typ v)

let pretty_variable (v : Var.t) =
  let open Containers_pp in
  text (var_name v)

let pretty_variable_typed types (v : Var.t) =
  let open Containers_pp in
  text (var_name v) ^ text ": " ^ text (type_to_string types @@ Var.typ v)

let pretty_const (c : Ops.AllOps.const) =
  let open Containers_pp in
  match c with
  | `Integer i -> text @@ Z.format "%d" i
  | `Bitvector bv -> text @@ Printf.sprintf "%sbv%d" (Z.format "%d" bv.v) bv.w
  | `Bool b -> text @@ string_of_bool b

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

let pretty_apply_intrinsic types (op : Ops.AllOps.intrin)
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
      ^ text ":" ^+ text @@ type_to_string types @@ t
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
  | `String s -> [ text (Printf.sprintf "%S" s) ]
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

and pretty_binding_expr types triggers bound in_body =
  let open Containers_pp in
  pretty_call_args_no_brackets (List.map (pretty_variable_typed types) bound)
  ^+ text "::" ^+ newline_or_spaces 0 ^ pretty_triggers triggers
  ^+ newline_or_spaces 0 ^ snd in_body

and pretty_expr_alg types
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
        ^+ (pretty_binding_expr types)
             (List.map (List.map snd) triggers)
             bound_vars in_body)
        ")"
  | UnaryExpr { op; arg } -> pretty_unary_expr op arg (type_of e)
  | BinaryExpr { op; arg1; arg2 } -> pretty_binary_expr op arg1 arg2 (type_of e)
  | ApplyIntrin { op; args } -> pretty_apply_intrinsic types op args (type_of e)
  | ApplyFun { func; args } -> pretty_apply_function (snd func) args
  | Let _ -> failwith "removed in prepass"

and pretty_expr types e =
  Expr.BasilExpr.fold_with_type_r (pretty_expr_alg types) e

let pretty_function_args types (e : Program.e) =
  let open Containers_pp in
  match Expr.BasilExpr.unfix2 e with
  | Lambda { bound_vars } ->
      fill (text "," ^ sp) (List.map (pretty_variable_typed types) bound_vars)
  | _ -> raise (BoogieException "Unsupported expression as function args")

let pretty_function_body types funcname (e : Program.e) =
  let open Containers_pp in
  match Expr.BasilExpr.unfix e with
  | Lambda { attrib; op = `Lambda; bound_vars; in_body } ->
      let rt =
        Hm_inference.type_applied (Var.typ funcname)
          (List.map Var.typ bound_vars)
      in
      let rt =
        match rt with
        | Ok e -> e
        | Error msg ->
            failwith
            @@ String.concat "" [ msg; " in "; Expr.BasilExpr.to_string e ]
      in

      (pretty_expr types in_body, text @@ type_to_string types rt)
  | _ ->
      raise
        (BoogieException
           (Printf.sprintf "Unsupported expression as function body of %s: %s"
              (Var.to_string funcname)
              (Expr.BasilExpr.to_string e)))

let rec pretty_variant_declaration types v =
  let open Containers_pp in
  let { name; selectors } : Bincaml_util.Types_datatype.constructor = v in
  let pretty_constructor vs =
    text name
    ^ bracket "("
        (append_l
           ~sep:(text "," ^ sp)
           (List.map
              (fun (fname, ftyp) ->
                text fname ^ text ":"
                ^+ text (datatype_rpos_to_string types ftyp))
              vs))
        ")"
  in
  match selectors with [] -> text name | os -> pretty_constructor os

and pretty_adt_datatype types name cases =
  let open Containers_pp in
  let cases = List.map (pretty_variant_declaration types) cases in
  let cases = append_l ~sep:(text "," ^ sp) cases in
  text "datatype" ^+ text name ^+ bracket "{" cases "}"

let pretty_type_declaration types (binding : string) (typ : Types.t) =
  let open Containers_pp in
  let dt = Bincaml_util.Types_datatype.get_datatype types typ in
  let dt = Bincaml_util.Types_datatype.sort_to_adt types dt in
  match dt with
  | ADT { name; cases } -> pretty_adt_datatype types name cases
  | Sort { name; nfields = 0 } -> pretty_adt_datatype types name []
  | Sort { name; nfields; instantiation } ->
      failwith "sort should be removed first"
  | Prim ty ->
      text "type " ^ text binding ^ text " = " ^ text (type_to_string types ty)

let pretty_statement types (s : Program.stmt) =
  let open Containers_pp in
  let open List.Infix in
  match s with
  | Instr_IntrinCall { lhs; name = Stmt.Intrinsic.Havoc; _ } ->
      let vars =
        List.map pretty_variable lhs |> fill (text "," ^ newline_or_spaces 1)
      in
      nest 2 @@ text "havoc" ^+ vars
  | Instr_IntrinCall { lhs; name; args } ->
      let lhs =
        if List.length lhs > 0 then
          (List.map pretty_variable lhs |> fill (text "," ^ newline_or_spaces 1))
          ^+ text ":=" ^ sp
        else text ""
      in
      let rhs =
        List.map (pretty_expr types) args
        |> fill (text "," ^ newline_or_spaces 1)
      in
      nest 2 @@ text "call" ^+ lhs
      ^ Stmt.Intrinsic.to_pretty name
      ^ bracket "(" rhs ")"
  | Instr_Assign { al = [] } -> text "assert true"
  | Instr_Assign { al = ls } ->
      let lhs =
        ls
        >|= compose fst pretty_variable
        |> fill (text "," ^ newline_or_spaces 1)
      in
      let rhs =
        ls
        >|= compose snd (pretty_expr types)
        |> fill (text "," ^ newline_or_spaces 1)
      in
      nest 2 @@ lhs ^+ text ":=" ^+ rhs
  | Instr_Assert { attrib; body } ->
      text "assert"
      ^ pretty_attribute_map ".boogie" attrib
      ^+ pretty_expr types body
  | Instr_Assume { body; branch } -> text "assume" ^+ pretty_expr types body
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
        |> List.map (compose snd (pretty_expr types))
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

let pretty_block types (p : Program.proc) (i : IDSet.elt)
    (b : Procedure.Edge.block) =
  let open Containers_pp in
  let name = block_name (Procedure.Vert.Begin i) in
  let stmts =
    Block.stmts_iter b |> Iter.map (pretty_statement types) |> Iter.to_list
  in
  let terminator = [ pretty_terminator p i b ] in
  let body = stmts @ terminator |> join_lines in
  name ^ text ":" ^/ body |> nest 2

let pretty_procedure_header types (s : string) (p : Program.proc) =
  let open Containers_pp in
  let open Containers_pp.Infix in
  let param_list sm =
    StringMap.bindings sm
    |> List.map (function i, p -> pretty_variable_typed types p)
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

let pretty_expr_attribs e =
  let open Containers_pp in
  let attrib = Expr.AbstractExpr.get_attrib @@ Expr.BasilExpr.unfix e in
  if StringMap.mem ".boogie" attrib then
    sp ^ pretty_attribute_map ".boogie" attrib
  else text ""

let pretty_ensures types (p : Program.proc) =
  let open Containers_pp in
  let spec = Procedure.specification p in
  spec.ensures
  |> List.map (fun s ->
      text "ensures" ^ pretty_expr_attribs s ^+ pretty_expr types s)

let pretty_requires types (p : Program.proc) =
  let open Containers_pp in
  let spec = Procedure.specification p in
  spec.requires
  |> List.map (fun s ->
      text "requires" ^ pretty_expr_attribs s ^+ pretty_expr types s)

let pretty_procedure_spec types (p : Program.proc) =
  let open Containers_pp in
  let open Containers_pp.Infix in
  let header = pretty_procedure_header types "procedure" p in
  let modifies = pretty_modifies p in
  let ensures = pretty_ensures types p in
  let requires = pretty_requires types p in
  nest 2 @@ join_lines_end ([ header ] @ modifies @ ensures @ requires)

let pretty_procedure_impl types (p : Program.proc) =
  let open Containers_pp in
  let open Containers_pp.Infix in
  let in_params = Procedure.formal_in_params p in
  let out_params = Procedure.formal_out_params p in
  let local_decls =
    Procedure.local_decls p |> Hashtbl.to_list
    |> List.filter (fun (k, v) ->
        (Option.is_none @@ StringMap.get k in_params)
        && (Option.is_none @@ StringMap.get k out_params))
    |> List.map (fun (k, v) -> pretty_variable_declaration types v)
    |> join_lines_end
  in
  let blocks =
    Procedure.iter_blocks_topo_fwd p
    |> Iter.map (fun (i, b) -> pretty_block types p i b)
    |> Iter.to_list |> join_lines_end
  in
  let header = pretty_procedure_header types "implementation" p in
  let body = local_decls ^/ blocks in
  header ^+ surround ~width:2 (text "{") (newline ^ body) (newline ^ text "}")

let pretty_procedure types (p : Program.proc) =
  let open Containers_pp in
  append_nl
  @@ [ pretty_procedure_spec types p ]
  @
  if negate List.is_empty @@ Procedure.blocks_to_list p then
    [ pretty_procedure_impl types p ]
  else []

let pretty_declaration types (d : Program.declaration) =
  let open Containers_pp in
  let open Containers_pp.Infix in
  match d with
  | Variable { binding; attrib } ->
      pretty_variable_declaration types binding ^ text ";"
  | Function { binding; attrib; definition = Function t } ->
      let func_body, return_type = pretty_function_body types binding t in
      text "function"
      ^+ pretty_attribute_map ".boogie" attrib
      ^+ (function_name @@ binding)
      ^ bracket "(" (pretty_function_args types t) ")"
      ^+ text "returns"
      ^+ bracket "(" return_type ")"
      ^+ surround ~width:2 (text "{") (newline ^ func_body) (newline ^ text "}")
  | Function { binding; attrib; definition = Axiom t } ->
      fill sp [ text "axiom"; bracket "(" (pretty_expr types t) ")" ] ^ text ";"
  | Function { binding; attrib; definition = Uninterpreted }
    when List.is_empty (fst @@ Types.uncurry (Var.typ binding)) ->
      pretty_variable_declaration types ~const:true binding ^ text ";"
  | Function { binding; attrib; definition = Uninterpreted } ->
      let param, rt = Types.uncurry (Var.typ binding) in
      text "function"
      ^+ pretty_attribute_map ".boogie" attrib
      ^+ (function_name @@ binding)
      ^ bracket "("
          (fill
             (text "," ^ sp)
             (List.map (fun t -> text @@ type_to_string types t) param))
          ")"
      ^ bracket " returns (" (text (type_to_string types rt)) ")"
      ^ text ";"
  | Type { binding; typ } -> pretty_type_declaration types binding typ
  | Procedure { definition } -> pretty_procedure types definition
  | Implicit _ -> failwith "cannot generate implicit"

let ltype ctx binding ty =
  let ctx, _ = Bincaml_util.Types_datatype.decl_datatype ctx binding ty in
  ctx

let pretty_program (p : Program.t) =
  let open Containers_pp in
  let types =
    Program.declarations p
    |> Iter.fold
         (fun ctx (_, decl) ->
           match decl with
           | Program.Type { binding; typ } -> ltype ctx binding typ
           | _ -> ctx)
         (Bincaml_util.Types_datatype.empty_context ())
  in
  let glob_vars_funs, rest =
    Program.declarations p |> Iter.map snd |> Iter.to_list
    |> List.partition_filter_map (fun d ->
        let p = pretty_declaration types d in
        match d with
        | Variable _ | Function _ | Type _ -> `Left p
        | Implicit _ -> `Drop
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

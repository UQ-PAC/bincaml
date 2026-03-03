open Containers
open Bincaml_util.Common

exception BoogieException of string

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

and pretty_expr (Lang.Expr.BasilExpr.E e) =
  let open Containers_pp in
  match e with
  | RVar { attrib; id } -> pretty_variable id
  | Constant { attrib; const } -> pretty_const const
  | UnaryExpr { op; arg } -> pretty_unary_expr op arg
  | BinaryExpr { op; arg1; arg2 } -> pretty_binary_expr op arg1 arg2
  | ApplyIntrin { op; args } -> pretty_apply_intrinsic op args
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
      ^+ text (Var.name binding)
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
      ^ text (Var.name binding)
      ^ bracket "("
          (fill
             (text "," ^ sp)
             (List.map (fun t -> text @@ type_to_string t) param))
          ")"
      ^ bracket " returns (" (text (type_to_string rt)) ")"

let pretty_block b = b

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
    text s ^+ text (ID.to_string (Lang.Procedure.id p)) ^ args ^ returns
  in
  header

let pretty_procedure_decl (p : Lang.Program.proc) =
  let open Containers_pp in
  let open Containers_pp.Infix in
  let header = pretty_procedure_header "procedure" p in
  let modifies = text "modifies _" in
  let requires = text "requires _" in
  let ensures = text "ensures _" in
  let body = append_l ~sep:(text ";\n") [ modifies; requires; ensures ] in
  nest 2 @@ header ^ text ";" ^/ body

let pretty_procedure_impl (p : Lang.Program.proc) =
  let open Containers_pp in
  let open Containers_pp.Infix in
  let in_params = Lang.Procedure.formal_in_params p in
  let out_params = Lang.Procedure.formal_out_params p in
  let local_decls =
    append_l ~sep:(text ";\n")
    @@ List.map
         (fun (k, v) -> pretty_variable_declaration v)
         (Hashtbl.to_list @@ Lang.Procedure.local_decls p
         |> List.filter (fun (k, v) ->
             (Option.is_none @@ StringMap.get k in_params)
             && (Option.is_none @@ StringMap.get k out_params)))
  in
  (* ^/ append_l ~sep:(text ";\n") @@ List.map (fun t -> text t) (Hashtbl.keys_list local_decls) *)
  let header = pretty_procedure_header "implementation" p in
  let body = local_decls in
  header ^+ surround ~width:2 (text "{") (newline ^ body) (newline ^ text "}")

let pretty_procedure (p : Lang.Program.proc) =
  let open Containers_pp in
  append_l ~sep:(text ";\n")
    [ pretty_procedure_decl p; pretty_procedure_impl p ]

let pretty_program (p : Lang.Program.t) =
  let open Containers_pp in
  let sep l = append_l ~sep:(text ";\n") l ^ text ";\n" in
  let glob_vars =
    StringMap.bindings p.globals
    |> List.filter_map (fun (n, v) ->
        match v with
        | Lang.Program.Variable _ -> Some (pretty_declaration v)
        | _ -> None)
    |> sep
  in
  let glob_funs =
    StringMap.bindings p.globals
    |> List.filter_map (fun (n, v) ->
        match v with
        | Lang.Program.Function _ -> Some (pretty_declaration v)
        | _ -> None)
    |> sep
  in
  let procs =
    append_l ~sep:(text ";\n\n")
      (List.map (fun (_, p) -> pretty_procedure p) (ID.Map.to_list p.procs))
    ^ text ";\n"
  in
  append_l ~sep:newline [ glob_vars; glob_funs; procs ]

let pretty_to_chan chan (p : Lang.Program.t) =
  let p = pretty_program p in
  flush chan;
  let fmt = Format.formatter_of_out_channel chan in
  Containers_pp.Pretty.to_format ~width:80 fmt p;
  Format.flush fmt ()

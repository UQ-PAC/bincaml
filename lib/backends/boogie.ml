open Containers
open Bincaml_util.Common

exception BoogieException of string

(* let prog_pretty (p : t) = *)
(* let open Containers_pp in *)
(* let open Containers_pp.Infix in *)
(* let globs = *)
(* StringMap.bindings p.globals *)
(* |> List.map (fun (n, v) -> pretty_declaration v) *)
(* in *)
(* let n = *)
(* p.entry_proc *)
(* |> Option.map (fun i -> text "prog entry " ^ text @@ ID.to_string i) *)
(* |> Option.to_list *)
(* in *)
(* let decls = *)
(* globs @ n *)
(* @ List.map *)
(* (fun (_, p) -> proc_pretty p) *)
(* (ID.Map.to_list p.procs *)
(* |> List.sort (fun (i, _) (j, _) -> ID.compare i j)) *)
(* in *)

(* append_l ~sep:(text ";\n") decls ^ text ";\n" *)

(* let pretty_declaration d = *)
(* let open Containers_pp in *)
(* match d with *)
(* | Variable { binding; attrib } -> *)
(* let classification = *)
(* StringMap.find_opt "classification" attrib *)
(* |> Option.to_list *)
(* |> List.flat_map (function *)
(* | `Expr e -> [ text " classification " ^ Expr.BasilExpr.pretty e ] *)
(* | _ -> []) *)
(* |> append_l *)
(* in *)
(* text (Var.to_decl_string_il binding) ^ classification *)
(* | Function { binding; attrib; definition = Axiom body } -> *)
(* text "axiom " *)
(* ^ text (Var.name binding) *)
(* ^ text " " ^ Expr.BasilExpr.pretty body *)
(* | Function { binding; attrib; definition = Uninterpreted } -> *)
(* text "val " ^ text (Var.to_string binding) *)
(* | Function { binding; attrib; definition = Function body } -> *)
(* text "let " *)
(* ^ text (Var.to_string binding) *)
(* ^ text " = " *)
(* ^ nest 2 (Expr.BasilExpr.pretty body) *)

(* let to_string_il_lvar v = *)
(* match scope v with Local -> "var " ^ to_string v | Global -> to_string v *)

(* let to_decl_string_il v = *)
(* let modifiers = if not (pure v) then "observable " else "" in *)
(* "var " ^ modifiers ^ to_string v *)

(* type t = *)
(* | Boolean *)
(* | Integer *)
(* | Bitvector of int *)
(* | Unit *)
(* | Top *)
(* | Nothing *)
(* | Map of t * t *)
(* [@@deriving eq, ord] *)

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
      ^ bracket "(" (pretty_expr arg1 ^ text "," ^ pretty_expr arg2) ")"

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
            ( bracket "(" (acc_t ^ sp ^ text "++" ^ sp ^ t) "):"
              ^+ text "bv" ^ text
              @@ string_of_int (acc_s + s),
              acc_s + s ))
          mapped
      in
      bracket "(" body ")"
  | _ -> raise (BoogieException "Unsupported intrinsic application")

and pretty_expr (Lang.Expr.BasilExpr.E e) =
  let open Containers_pp in
  match e with
  | RVar { attrib; id } -> pretty_variable id
  | Constant { attrib; const } -> pretty_const const
  | UnaryExpr { op; arg } -> pretty_unary_expr op arg
  | BinaryExpr { op; arg1; arg2 } -> pretty_binary_expr op arg1 arg2
  (* | ApplyFun _ -> text "apply" *)
  (* fill nil *)
  (* [ *)
  (* text (AllOps.to_string op) *)
  (* ^ a *)
  (* ^ bracket "(" (fill (text "," ^ newline) es) ")"; *)
  (* ] *)
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

(* | Function { binding; attrib; definition = Axiom body } -> *)
(* text "axiom " *)
(* ^ text (Var.name binding) *)
(* ^ text " " ^ Expr.BasilExpr.pretty body *)
(* | Function { binding; attrib; definition = Uninterpreted } -> *)
(* text "val " ^ text (Var.to_string binding) *)
(* | Function { binding; attrib; definition = Function body } -> *)
(* text "let " *)
(* ^ text (Var.to_string binding) *)
(* ^ text " = " *)
(* ^ nest 2 (Expr.BasilExpr.pretty body) *)

(* { *)
(* binding : Var.t; *)
(* attrib : Expr.BasilExpr.t Attrib.attrib_map; *)
(* definition : func_type; *)
(* } *)
(* | _ -> text "ah" *)

let pretty_procedure (p : Lang.Program.proc) =
  let open Containers_pp in
  let open Containers_pp.Infix in
  (* let params m = *)
  (* StringMap.bindings m |> List.map (function i, p -> show_var p) |> fun s -> *)
  (* bracket "(" (fill (text "," ^ newline_or_spaces 1) s) ")" *)
  (* in *)
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
    text "procedure"
    ^+ text (ID.to_string (Lang.Procedure.id p))
    ^ args ^ returns
    ^ nest 2
        (newline
        ^ append_l ~sep:newline [ text "magic"; text "not magic"; text "WHYY?" ]
        )
    (* ^ nest 2 (fill (newline ^ text " returns ") []) *)
    (* ^ nest 2 *)
    (* (fill *)
    (* (newline ^ text " -> ") *)
    (* [ params (formal_in_params p); params (formal_out_params p) ]) *)
    (* ^ text " " *)
    (* ^ Attrib.attrib_pretty show_expr (`Assoc (attrib p)) *)
  in
  header

let pretty_program (p : Lang.Program.t) =
  let open Containers_pp in
  let globs =
    StringMap.bindings p.globals
    |> List.map (fun (n, v) -> pretty_declaration v)
  in
  let decls =
    globs @ List.map (fun (_, p) -> pretty_procedure p) (ID.Map.to_list p.procs)
  in
  append_l ~sep:(text ";\n") decls ^ text ";\n"

let pretty_to_chan chan (p : Lang.Program.t) =
  let p = pretty_program p in
  flush chan;
  let fmt = Format.formatter_of_out_channel chan in
  Containers_pp.Pretty.to_format ~width:80 fmt p;
  Format.flush fmt ()

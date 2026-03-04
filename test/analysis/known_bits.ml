open Lang
open Common
open Expr
open Expr.BasilExpr

(** Algebra that infers types of expressions *)
let type_alg visit (e : Types.t abstract_expr) =
  let open Expr.AbstractExpr in
  let open Ops.AllOps in
  let get_ty (op : [ const | unary | binary | intrin ]) o =
    match o with
    | Fun { ret; _ } ->
        visit (op, o);
        ret
    | _ -> failwith "type error"
  in
  match e with
  | RVar { id; _ } -> Var.typ id
  | Constant { const = #Ops.AllOps.const as op; _ } ->
      ret_type_const op |> get_ty op
  | UnaryExpr { op = #Ops.AllOps.unary as op; arg; _ } ->
      ret_type_unary op arg |> get_ty op
  | BinaryExpr { op = #Ops.AllOps.binary as op; arg1 = l; arg2 = r; _ } ->
      ret_type_bin op l r |> get_ty op
  | ApplyIntrin { op = #Ops.AllOps.intrin as op; args; _ } ->
      ret_type_intrin op args |> get_ty op
  | ApplyFun { func; _ } ->
      let _, rt = Types.uncurry func in
      rt
  | Binding { bound = vars; in_body = b; _ } ->
      Types.curry (List.map Var.typ vars) b

let istmt v s =
  Stmt.iter_rexpr s (function
    | `Expr e -> BasilExpr.cata (type_alg v) e |> ignore
    | _ -> ())

let iprog v (prog : Program.t) =
  ID.Map.values prog.procs
  |> Iter.flat_map Procedure.iter_stmt_topo_fwd
  |> Iter.iter (istmt v)

let iter_prog prog =
  Iter.from_iter (fun f -> iprog f prog)
  |> Iter.uniq ~eq:(Equal.pair Ops.AllOps.equal Ops.AllOps.equal_op_fun_type)
  |> Iter.iter (function op, ty ->
      print_endline @@ Ops.AllOps.to_string op ^ " "
      ^ Ops.AllOps.show_op_fun_type ty)

let load = (Loader.Loadir.ast_of_fname "examples/cntlm-simp-output.il").prog
let () = iter_prog load

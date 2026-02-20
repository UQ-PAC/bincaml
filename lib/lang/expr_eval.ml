open Common
open Expr
open Ops

let eval_expr_alg (e : Ops.AllOps.const option BasilExpr.abstract_expr) =
  let open AbstractExpr in
  let bool e = Some (`Bool e) in
  let bv e = `Bitvector e in
  let z e = Some (`Integer e) in

  let get_bv = function Some (`Bitvector b) -> Some b | _ -> None in
  let get_bool = function Some (`Bool b) -> Some b | _ -> None in
  let get_int = function Some (`Integer b) -> Some b | _ -> None in

  let all_args f args =
    let e_args = List.filter_map f args in
    if List.length e_args = List.length args then Some e_args else None
  in

  let open Option.Infix in
  match e with
  | RVar _ -> None
  | Constant { const } -> Some const
  | BinaryExpr { op = `EQ; arg1 = a; arg2 = b } ->
      let* a = a in
      let* b = b in
      bool (AllOps.eval_equal a b)
  | BinaryExpr { op = `NEQ; arg1 = a; arg2 = b } ->
      let* a = a in
      let* b = b in
      bool (not @@ AllOps.eval_equal a b)
  | UnaryExpr { op = #BVOps.unary_unif as op; arg = b } ->
      get_bv b >|= BVOps.eval_unary_unif op >|= bv
  | UnaryExpr { op = #BVOps.unary_bool as op; arg = b } ->
      get_bool b >|= BVOps.eval_unary_bool op >|= bv
  | BinaryExpr { op = #BVOps.binary_unif as op; arg1 = a; arg2 = b } ->
      let* a = get_bv a in
      let* b = get_bv b in
      Some (bv (BVOps.eval_binary_unif op a b))
  | BinaryExpr { op = #BVOps.binary_pred as op; arg1 = a; arg2 = b } ->
      let* a = get_bv a in
      let* b = get_bv b in
      bool (BVOps.eval_binary_pred op a b)
  | ApplyIntrin { op = #BVOps.intrin as op; args } ->
      let* args = all_args get_bv args in
      Some (bv (BVOps.eval_intrin op args))
  | UnaryExpr { op = #LogicalOps.unary as op; arg = b } ->
      get_bool b >|= LogicalOps.eval_unary op >>= bool
  | UnaryExpr { op = `Forall } -> None
  | UnaryExpr { op = `Old } -> None
  | UnaryExpr { op = `Lambda } -> None
  | UnaryExpr { op = `Exists } -> None
  | UnaryExpr { op = #IntOps.unary as op; arg = b } ->
      get_int b >|= IntOps.eval_unary op >|= fun b -> `Integer b
  | BinaryExpr { op = #IntOps.binary_unif as op; arg1 = a; arg2 = b } ->
      let* a = get_int a in
      let* b = get_int b in
      z (IntOps.eval_binary_unif op a b)
  | BinaryExpr { op = #IntOps.binary_pred as op; arg1 = a; arg2 = b } ->
      let* a = get_int a in
      let* b = get_int b in
      bool (IntOps.eval_binary_pred op a b)
  | BinaryExpr { op = `IMPLIES; arg1 = a; arg2 = b } ->
      let* a = get_bool a in
      let* b = get_bool b in
      bool (b || not a)
  | ApplyIntrin { op = #LogicalOps.intrin as op; args } ->
      let* args = all_args get_bool args in
      bool @@ LogicalOps.eval_intrin op args
  | ApplyFun _ -> None
  | Binding _ -> None
  | UnaryExpr { op = #Ops.Spec.unary } -> None
  | BinaryExpr { op = #Ops.Spec.binary } -> None
  | ApplyIntrin { op = #Ops.Spec.intrin } -> None

let partial_eval_alg (e : BasilExpr.t BasilExpr.abstract_expr) :
    BasilExpr.t option =
  let open AbstractExpr in
  let open Option.Infix in
  let is_const e =
    match BasilExpr.unfix e with Constant { const } -> Some const | _ -> None
  in
  let e = AbstractExpr.map is_const e in
  eval_expr_alg e >|= BasilExpr.const

let partial_eval_expr e = BasilExpr.rewrite ~rw_fun:partial_eval_alg e
let eval_expr e = BasilExpr.cata eval_expr_alg e

let%expect_test _ =
  let open BasilExpr in
  let e = binexp ~op:`BVMUL (bv_of_int ~size:10 10) (bv_of_int ~size:10 10) in
  print_endline (to_string e);
  let r =
    eval_expr e |> Option.map const |> Option.map to_string |> function
    | Some e -> e
    | None -> "none"
  in
  print_endline r;
  [%expect {|
    bvmul(0xa:bv10, 0xa:bv10)
    0x64:bv10 |}]

let%expect_test _ =
  let open BasilExpr in
  let ten = bv_of_int ~size:10 10 in
  let e =
    binexp ~op:`BVMUL
      (binexp ~op:`BVADD ten ten)
      (BasilExpr.rvar (Var.create "beans" Types.(Bitvector 10)))
  in
  print_endline (to_string e);
  let r = to_string @@ partial_eval_expr e in
  print_endline r;
  [%expect
    {|
    bvmul(bvadd(0xa:bv10, 0xa:bv10), beans:bv10)
    bvmul(0x14:bv10, beans:bv10)
    |}]

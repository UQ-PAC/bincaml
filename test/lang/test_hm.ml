open Lang
open Common
open Hm

module HMDifferential = struct
  let arb_expr =
    let open QCheck.Gen in
    let* wd = Expr_gen.gen_width in
    Expr_gen.gen_bvexpr ~with_var:true (5, wd)

  let infer e =
    try
      Ok
        (locally_elaborate_expr e |> Expr.BasilExpr.unfix
       |> Expr.AbstractExpr.get_typ)
    with e -> Result.of_exn e

  let gener =
    QCheck.make ~print:(fun (e, inf_b, inf_hm) ->
        Printf.sprintf "%s : %s = %s"
          (Expr.BasilExpr.to_string e)
          (Types.to_string inf_b)
          (Format.sprintf "%a" (Result.pp Types.pp) inf_hm))
    @@
    let open QCheck.Gen in
    let* exp = arb_expr in
    let inf_b = Expr.BasilExpr.get_typ exp in
    let inf_hm = infer exp in
    return (exp, inf_b, inf_hm)

  let expect_type_error e =
    (* multiple variables with different types *)
    let has_type (acc, m) v =
      let e =
        StringMap.find_opt (Var.name v) m
        |> Option.for_all (Types.equal (Var.typ v))
      in
      (acc && e, StringMap.add (Var.name v) (Var.typ v) m)
    in
    let var_types_compat, _ =
      Expr.BasilExpr.free_vars_iter e
      |> Iter.fold has_type (true, StringMap.empty)
    in
    not var_types_compat

  let predicate (a, b, hm) =
    (expect_type_error a && Result.is_error hm)
    || (Result.is_ok hm && Types.equal b (Result.get_ok hm))

  let test =
    QCheck.Test.make ~name:"Hm inference matches" ~count:10000 ~max_fail:1 gener
      predicate
end

let _ =
  let suite =
    List.map
      (QCheck_alcotest.to_alcotest ~long:false ~speed_level:`Quick ~verbose:true)
      [ HMDifferential.test ]
  in
  Alcotest.run "hm" [ ("diff", suite) ]

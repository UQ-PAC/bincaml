open Lang
open Common

module ValueAbstractionSoundness
    (V : Analysis.Lattice_types.ValueAbstraction with module E = Expr.BasilExpr) =
struct
  module Eval = Analysis.Intra_analysis.EvalExprLog (V)

  let eval_expr =
    let open QCheck.Gen in
    let* wd = Expr_gen.gen_width in
    Expr_gen.gen_bvexpr (5, wd)

  let arb_abstract_eval =
    let eval_abs e =
      Eval.eval Ops.AllOps.show_const Ops.AllOps.show_unary
        Ops.AllOps.show_binary Ops.AllOps.show_intrin
        (fun v -> failwith "no vars")
        e
    in
    QCheck.make ~print:(fun (e, p, q, r) ->
        Printf.sprintf "%s = %s :: %s ⊆ %s\n    === %s ⊆ %s"
          (Expr.BasilExpr.to_string e)
          (Expr.BasilExpr.to_string (Lazy.force p))
          (V.show (fst (Lazy.force q)))
          (V.show (fst (Lazy.force r)))
          (Containers_pp.Pretty.to_string ~width:80 (snd (Lazy.force q)))
          (Containers_pp.Pretty.to_string ~width:80 (snd (Lazy.force r))))
    @@
    let open QCheck.Gen in
    let* exp = eval_expr in
    let partial = lazy (Expr_eval.partial_eval_expr exp) in
    let abstract = lazy (eval_abs exp) in
    let concrete = lazy (eval_abs (Lazy.force partial)) in
    return (exp, partial, abstract, concrete)

  let arb_bvexpr = QCheck.make ~print:Expr.BasilExpr.to_string eval_expr

  let is_sound (_, _, abstract, concrete) =
    let abstract = fst @@ Lazy.force abstract in
    let concrete = fst @@ Lazy.force concrete in
    V.equal abstract (V.join abstract concrete)

  let suite =
    let open QCheck in
    let test =
      Test.make ~name:V.name ~count:10000 ~max_fail:3 arb_abstract_eval is_sound
    in
    let suite = List.map QCheck_alcotest.to_alcotest [ test ] in
    ("soundness::" ^ V.name, suite)
end

(** {1 Define Suite}*)

module TestBoolDom =
  ValueAbstractionSoundness (Analysis.Defuse_bool.IsZeroValueAbstractionBasil)

let _ =
  Alcotest.run "value domain abstract eval soundness" [ TestBoolDom.suite ]

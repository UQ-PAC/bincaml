open Lang
open Common

module ValueAbstractionSoundness
    (V :
      Analysis.Lattice_types.TypedValueAbstraction
        with module E = Expr.BasilExpr) =
struct
  module Eval = Analysis.Intra_analysis.EvalExprLog (V)

  let arb_expr =
    let open QCheck.Gen in
    let* wd = Expr_gen.gen_width in
    Expr_gen.gen_bvexpr (5, wd)

  let arb_val =
    let open QCheck.Gen in
    QCheck.make ~print:Expr.BasilExpr.to_string
    @@
    let* wd = Expr_gen.gen_width in
    Expr_gen.gen_bvconst wd

  let arb_pair =
    let pair =
      let open QCheck.Gen in
      let* wd = Expr_gen.gen_width in
      let* l = Expr_gen.gen_bvconst wd in
      let* r = Expr_gen.gen_bvconst wd in
      return (l, r)
    in
    QCheck.make
      ~print:(fun (l, r) ->
        "(" ^ Expr.BasilExpr.to_string l ^ ", " ^ Expr.BasilExpr.to_string r
        ^ ")")
      pair

  let eval_abs e =
    Eval.eval Ops.AllOps.show_const Ops.AllOps.show_unary Ops.AllOps.show_binary
      Ops.AllOps.show_intrin
      (fun v -> failwith "no vars")
      e

  let join_symm (l, r) =
    let l = fst @@ eval_abs l in
    let r = fst @@ eval_abs r in
    V.equal (V.join l r) (V.join r l)

  let join_idem l =
    let l = fst @@ eval_abs l in
    V.equal (V.join l l) l

  let arb_abstract_eval =
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
    let* exp = arb_expr in
    let partial = lazy (Expr_eval.partial_eval_expr exp) in
    let abstract = lazy (eval_abs exp) in
    Lazy.force abstract |> ignore;
    let concrete = lazy (eval_abs (Lazy.force partial)) in
    return (exp, partial, abstract, concrete)

  let is_sound (_, _, abstract, concrete) =
    let abstract = fst @@ Lazy.force abstract in
    let concrete = fst @@ Lazy.force concrete in
    V.equal abstract (V.join abstract concrete)

  let suite =
    let open QCheck in
    let soundness =
      Test.make ~name:"soundness" ~count:10000 ~max_fail:1 arb_abstract_eval
        is_sound
    in
    let join_equal =
      Test.make ~name:"join self" ~count:10000 ~max_fail:1 arb_val join_idem
    in
    let join_symm =
      Test.make ~name:"join symmetric" ~count:10000 ~max_fail:1 arb_pair
        join_symm
    in
    let suite =
      List.map QCheck_alcotest.to_alcotest [ soundness; join_equal; join_symm ]
    in
    (V.name, suite)
end

(** {1 Define Suite}*)

module TestBoolDom =
  ValueAbstractionSoundness (Analysis.Defuse_bool.IsZeroValueAbstractionBasil)

module TestIsKnownDom =
  ValueAbstractionSoundness (Analysis.Known_bits.IsKnownValueAbstractionBasil)

module TestWrappedIntervalDom =
  ValueAbstractionSoundness
    (Analysis.Wrapped_intervals.WrappedIntervalsValueAbstractionBasil)

let _ =
  Alcotest.run "value domain abstract eval soundness"
    [ TestBoolDom.suite; TestWrappedIntervalDom.suite; TestIsKnownDom.suite ]

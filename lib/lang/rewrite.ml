open Common

let rewrite_proc_exprs ?visit
    (rewriter : ?visit:'a -> Expr.BasilExpr.t -> Expr.BasilExpr.t)
    (p : (Var.t, Expr.BasilExpr.t) Procedure.t) =
  let open Procedure in
  let simplify_proc_exprs p =
    p
    |> map_blocks_nondet (fun (i, b) ->
        let b =
          Block.map ~phi:Fun.id
            (Stmt.map ~f_lvar:Fun.id ~f_rvar:Fun.id ~f_expr:(rewriter ?visit))
            b
        in
        b)
  in

  let simplify_proc_spec_exprs p =
    let s = specification p in
    let s =
      {
        s with
        requires = List.map (rewriter ?visit) s.requires;
        ensures = List.map (rewriter ?visit) s.ensures;
        rely = List.map (rewriter ?visit) s.rely;
        guarantee = List.map (rewriter ?visit) s.guarantee;
      }
    in
    set_specification p s
  in
  p |> simplify_proc_exprs |> simplify_proc_spec_exprs

let rewrite_prog_exprs rewriter ?visit (p : Program.t) =
  let open Program in
  let simplify_prog_spec_exprs (p : t) =
    map_procedures
      (fun _ proc ->
        (fun ?visit rewriter p ->
          let s = Procedure.specification p in
          let s =
            {
              s with
              requires = List.map (rewriter ?visit) s.requires;
              ensures = List.map (rewriter ?visit) s.ensures;
              rely = List.map (rewriter ?visit) s.rely;
              guarantee = List.map (rewriter ?visit) s.guarantee;
            }
          in
          Procedure.set_specification p s)
          rewriter ?visit proc)
      p
  in

  let simplify_decls p =
    map_decls
      (fun id ->
        (function
        | Function { binding; attrib; definition; var_gen } ->
            let definition =
              match definition with
              | Axiom b ->
                  let rw = rewriter ?visit b in
                  Axiom rw
              | Function b -> Function (rewriter ?visit b)
              | Uninterpreted -> Uninterpreted
            in
            Function { binding; attrib; definition; var_gen }
        | o -> o))
      p
  in
  p
  |> Program.map_procedures (fun _ proc ->
      rewrite_proc_exprs rewriter ?visit proc)
  |> simplify_decls |> simplify_prog_spec_exprs

open Common

let ptr_add a b =
  let t = Var.create "$ptradd" (Map (Top, Map (Top, Top))) in
  Expr.BasilExpr.apply_fun ~func:(Expr.BasilExpr.rvar t) [ a; b ]

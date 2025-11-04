open Lang
open QCheck.Gen
module BasilExpr = Expr.BasilExpr

type 'a gen = 'a QCheck.Gen.t

let bv_unop = [ `BVNOT; `BVNEG ]
let bv_ops_partial = [ `BVSREM; `BVSDIV; `BVUREM; `BVUDIV; `BVSMOD ]

let bv_ops_total =
  [
    `BVADD;
    `BVASHR;
    `BVMUL;
    `BVSHL;
    `BVNAND;
    `BVXOR;
    `BVOR;
    `BVSUB;
    `BVLSHR;
    `BVAND;
  ]

let gen_width = int_range 1 62
let arb_bv_op : Ops.BVOps.binary gen = oneofl bv_ops_total

let gen_bv ?(min = 0) w =
  let* v =
    int_range min
      (Value.PrimQFBV.ones ~size:w |> Value.PrimQFBV.value |> Z.to_int)
  in
  return (Value.PrimQFBV.of_int ~size:w v)

let gen_unop l =
  let* op = oneofl bv_unop in
  return (BasilExpr.unexp ~op l)

let gen_binop_total l r =
  let* op = oneofl bv_ops_total in
  return (BasilExpr.binexp ~op l r)

let gen_binop_partial l r =
  let* op = oneofl bv_ops_partial in
  return (BasilExpr.binexp ~op l r)

let gen_bvconst ?min w =
  let* c = gen_bv ?min w in
  return (BasilExpr.bvconst c)

let make_bvconst wd x = BasilExpr.bvconst @@ Value.PrimQFBV.of_int ~size:wd x

let ensure_nonzero wd e =
  BasilExpr.binexp ~op:`BVOR e (make_bvconst wd 1)

let gen_bvexpr (size, wd) =
  fix
    (fun self (size, wd) ->
      match size with
      | 0 -> gen_bvconst wd
      | size ->
          frequency
            [
              (1, gen_bvconst wd);
              (2, self (size / 2, wd) >>= gen_unop);
              ( 2,
                let* l = self (size / 2, wd) in
                let* r = self (size / 2, wd) in
                gen_binop_total l r );
              ( 2,
                let* l = self (size / 2, wd) in
                let* r = self (size / 2, wd) >|= ensure_nonzero wd in
                gen_binop_partial l r );
            ])
    (size, wd)



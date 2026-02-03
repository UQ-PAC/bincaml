open Bincaml_util.Common
open Lang
open QCheck.Gen
module BasilExpr = Expr.BasilExpr

type 'a gen = 'a QCheck.Gen.t

let bv_unop = [ `BVNOT; `BVNEG ]
let bv_ops_partial = [ `BVSREM; `BVSDIV; `BVUREM; `BVUDIV; `BVSMOD ]

let bv_ops_total =
  [
    `BVADD;
    `BVSUB;
    `BVMUL;
    `BVSHL;
    `BVNAND;
    `BVXOR;
    `BVOR;
    `BVLSHR;
    `BVASHR;
    `BVAND;
  ]

let multi = [ `BVADD; `BVOR; `BVXOR; `BVAND ]
let gen_width = int_range 1 62
let arb_bv_op : Ops.BVOps.binary gen = oneof_list bv_ops_total

let random_binary_string st length =
  (* 0b011101... *)
  let s = Bytes.create (length + 2) in
  Bytes.set s 0 '0';
  Bytes.set s 1 'b';
  for i = 0 to length - 1 do
    Bytes.set s (i + 2) (if Random.State.bool st then '0' else '1')
  done;
  Bytes.unsafe_to_string s

let gen_bv ?(min = 0) w =
  let* v = fun st -> Z.of_string @@ random_binary_string st w in
  return (Bitvec.create ~size:w v)

let gen_unop l =
  let* op = oneof_list bv_unop in
  return (BasilExpr.unexp ~op l)

let gen_binop_total l r =
  let* op = oneof_list bv_ops_total in
  return (BasilExpr.binexp ~op l r)

let gen_binop_partial l r =
  let* op = oneof_list bv_ops_partial in
  return (BasilExpr.binexp ~op l r)

let gen_bvconst ?min w =
  let* c = gen_bv ?min w in
  return (BasilExpr.bvconst c)

let make_bvconst wd x = BasilExpr.bvconst @@ Bitvec.of_int ~size:wd x
let ensure_nonzero wd e = BasilExpr.binexp ~op:`BVOR e (make_bvconst wd 1)

let gen_extract w =
  let* lo = int_range 0 w in
  let* hi = int_range lo w in
  return (`Extract (hi, lo))

let gen_unop_advanced gen_bvexpr wd =
  let* w1 = int_range 0 wd in
  let w2 = wd - w1 in
  let* extr_gen_w = int_range wd (wd + 64) in
  let* hi_excl = int_range wd extr_gen_w in
  let lo_incl = hi_excl - wd in
  let multi () =
    let nmu = int_range 2 12 in
    let* op = oneof_list multi in
    let* args = list_size nmu (gen_bvexpr wd) in
    return (BasilExpr.applyintrin ~op @@ args)
  in
  oneof
    ([
       gen_bvexpr w2 >|= BasilExpr.sign_extend ~n_prefix_bits:w1;
       gen_bvexpr w2 >|= BasilExpr.zero_extend ~n_prefix_bits:w1;
       BasilExpr.concat <$> gen_bvexpr w1 <*> gen_bvexpr w2;
       multi ();
     ]
    @
    if wd > 0 then
      [ gen_bvexpr extr_gen_w >|= BasilExpr.extract ~hi_excl ~lo_incl ]
    else [])
(* >|= fun e -> *)
(* assert (BasilExpr.type_of e = Bitvector wd); *)
(* e *)

let gen_bvexpr =
  fix (fun self (size, wd) ->
      let self wd = self (size / 2, wd) in
      match size with
      | 0 -> gen_bvconst wd
      | size ->
          oneof_weighted
            [
              (1, gen_bvconst wd);
              (2, self wd >>= gen_unop);
              (2, gen_unop_advanced self wd);
              ( 2,
                let* l = self wd in
                let* r = self wd in
                gen_binop_total l r );
              ( 2,
                let* l = self wd in
                let* r = self wd >|= ensure_nonzero wd in
                gen_binop_partial l r );
            ])

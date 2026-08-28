open Bincaml_util.Common
open Lang

(*

eq(sext(32, bvadd(a:bv32, b:bv32)), bvadd(sext(32, a:bv32), sext(32, b:bv64)))
is an overflow check
can also be 64 and 128 bit...

$PSTATE_V:bv1 :=
bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32,0, $R26), bvnot(bvshl(extract(32,0, $R27), zero_extend(20, 0x0:bv12)))), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32,0, $R26)), sign_extend(32, bvnot(bvshl(extract(32,0, $R27), zero_extend(20, 0x0:bv12))))), 0x1:bv64))));

->

$PSTATE_V:bv1 :=
bvnot(booltobv1(eq(sign_extend(32, bvsub(extract(32,0, $R26), extract(32,0, $R27))), bvsub(sign_extend(32, extract(32,0, $R26)), sign_extend(32, extract(32,0, $R27))))));
also an overflow check!
*)

(** Rewrite common shapes of expressions *)
let specific_rewrites e =
  let open Expr.AbstractExpr in
  let open Expr.BasilExpr in
  let sext_eq extension bv1 bv2 =
    Bitvec.equal (Bitvec.sign_extend ~extension bv1) bv2
  in
  (* Get size of bv expr if it is one *)
  let size_of e =
    match type_of e with Types.Bitvector k -> Some k | _ -> None
  in
  let rw_fun (e : O.t abstract_expr) =
    match e with
    | BinaryExpr { op = `EQ; arg1; arg2 } -> (
        match (unfix3 arg1, unfix3 arg2) with
        | ( UnaryExpr
              {
                op = `SignExtend s1;
                arg =
                  ApplyIntrin
                    {
                      op = `BVADD;
                      args =
                        [
                          a;
                          Constant
                            { const = `Bitvector bv1; typ = Bitvector k1 };
                        ];
                    };
              },
            ApplyIntrin
              {
                op = `BVADD;
                args =
                  [
                    UnaryExpr { op = `SignExtend s2; arg = c };
                    Constant { const = `Bitvector bv2; typ = Bitvector k2 };
                  ];
              } )
          when s1 = s2 && s1 > 0
               && equal (fix a) (fix c)
               && k2 = k1 + s1
               && sext_eq s1 bv1 bv2 ->
            (* Overflow check when adding by a constant bv1 working with k1 bits *)
            if Bitvec.sgt bv1 (Bitvec.zero ~size:k1) then
              replace [%here]
                (binexp ~op:`BVSLE (fix a)
                   (bvconst (Bitvec.sub (Bitvec.max_value_signed k1) bv1)))
            else if Bitvec.slt bv1 (Bitvec.zero ~size:k1) then
              replace [%here]
                (binexp ~op:`BVSLE
                   (bvconst (Bitvec.sub (Bitvec.min_value_signed k1) bv1))
                   (fix a))
            else Keep
        | ( UnaryExpr
              {
                op = `SignExtend s1;
                arg = BinaryExpr { op = `BVSUB; arg1 = a; arg2 = b };
              },
            BinaryExpr
              {
                op = `BVSUB;
                arg1 = UnaryExpr { op = `SignExtend s2; arg = c };
                arg2 = UnaryExpr { op = `SignExtend s3; arg = d };
              } )
          when s1 = s2 && s2 = s3
               && equal (fix a) (fix c)
               && equal (fix b) (fix d) -> (
            (* Overflow check when subtracting two variables *)
            let a = fix a in
            let b = fix b in
            match size_of a with
            | Some size ->
                let z = bvconst (Bitvec.zero ~size) in
                let max = bvconst (Bitvec.max_value_signed size) in
                let min = bvconst (Bitvec.min_value_signed size) in
                replace [%here]
                  (applyintrin ~op:`OR
                     [
                       applyintrin ~op:`AND
                         [
                           binexp ~op:`BVSLE z b;
                           binexp ~op:`BVSLE a (binexp ~op:`BVSUB max b);
                         ];
                       applyintrin ~op:`AND
                         [
                           binexp ~op:`BVSLT b z;
                           binexp ~op:`BVSLE (binexp ~op:`BVSUB min b) a;
                         ];
                     ])
            | _ -> Keep)
        | _ -> Keep)
    | _ -> Keep
  in
  rewrite ~rw_fun e

let rewrite_expr e =
  e |> Algsimp.normalise |> specific_rewrites |> Algsimp.normalise

let transform (p : Program.proc) =
  Procedure.map_blocks_nondet
    (fun (bid, block) ->
      Block.map ~phi:id
        (Stmt.map ~f_lvar:id ~f_rvar:id ~f_expr:rewrite_expr)
        block)
    p

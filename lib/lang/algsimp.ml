(** Basic intra-expression algebraic simplifications *)

open Bincaml_util.Common
open Expr
open Ops

module Comb = struct
  let to_steady equal f x =
    let rec loop x =
      let n = f x in
      if equal n x then n else loop n
    in
    loop x

  let sequence (a : 'a -> BasilExpr.rewrite) (b : 'a -> BasilExpr.rewrite) e =
    match a e with Keep -> b e | e -> e

  let apply_fun in_body args =
    let args = args |> VarMap.of_list |> fun m v -> VarMap.find_opt v m in
    BasilExpr.substitute args in_body
end

open Comb

let rec inline_let_rec e =
  let open AbstractExpr in
  match BasilExpr.unfix e with
  | Let { bound_vars; in_body } ->
      inline_let_rec @@ apply_fun in_body bound_vars
  | ApplyFun { func; args } -> (
      match BasilExpr.unfix func with
      | Lambda { bound_vars; in_body } ->
          inline_let_rec @@ apply_fun in_body @@ List.combine bound_vars args
      | _ -> e)
  | BinaryExpr { op = `MapAccess; arg1 = func; arg2 } -> (
      (* a bit odd but why not*)
      match BasilExpr.unfix func with
      | Lambda { bound_vars; in_body } ->
          inline_let_rec @@ apply_fun in_body
          @@ List.combine bound_vars [ arg2 ]
      | _ -> e)
  | _ -> e

let inline_let_alg e : BasilExpr.rewrite =
  let open AbstractExpr in
  match e with
  | Let { bound_vars; in_body } ->
      let e = apply_fun in_body bound_vars in
      BasilExpr.replace [%here] e
  | ApplyFun { func; args } -> (
      match BasilExpr.unfix func with
      | Lambda { bound_vars; in_body } ->
          BasilExpr.replace [%here]
            (apply_fun in_body @@ List.combine bound_vars args)
      | _ -> Keep)
  | BinaryExpr { op = `MapAccess; arg1 = func; arg2 } -> (
      match BasilExpr.unfix func with
      | Lambda { bound_vars; in_body } ->
          BasilExpr.replace [%here]
            (apply_fun in_body @@ List.combine bound_vars [ arg2 ])
      | _ -> Keep)
  | _ -> Keep

let desugar_let_alg e : BasilExpr.rewrite =
  let open AbstractExpr in
  match e with
  | Let { bound_vars; in_body } ->
      (* desugar let to func
            
            let a = e and b = c in d ~> (fun a b -> d)(e)(c)
           *)
      let args = bound_vars |> List.map fst in
      let func = BasilExpr.lambda ~bound:args in_body in
      let app_args = bound_vars |> List.map snd in
      BasilExpr.replace [%here] (BasilExpr.apply_fun ~func app_args)
  | _ -> Keep

let desugar_let ?visit =
  to_steady BasilExpr.equal @@ BasilExpr.rewrite ?visit ~rw_fun:desugar_let_alg

let inline_let ?visit =
  to_steady BasilExpr.equal (BasilExpr.rewrite ?visit ~rw_fun:inline_let_alg)

let normalise e =
  let open AbstractExpr in
  let open BasilExpr in
  let open Bitvec in
  let e = AbstractExpr.map fst e in
  match e with
  | BinaryExpr { op = `IMPLIES; arg1; arg2 } ->
      replace [%here]
        (BasilExpr.applyintrin ~op:`OR
           [ fix arg2; BasilExpr.boolnot (fix arg1) ])
  | UnaryExpr { op = `BoolNOT; arg = UnaryExpr { op = `BoolNOT; arg } } ->
      replace [%here] arg
  | UnaryExpr { op = `BoolNOT; arg = ApplyIntrin { op = `AND; args } } ->
      replace [%here]
        (BasilExpr.applyintrin ~op:`OR (List.map BasilExpr.boolnot args))
  | UnaryExpr { op = `BoolNOT; arg = ApplyIntrin { op = `OR; args } } ->
      replace [%here]
        (BasilExpr.applyintrin ~op:`AND (List.map BasilExpr.boolnot args))
  | ApplyIntrin
      {
        attrib;
        op = `BVADD;
        args =
          [ (RVar _ as v); Constant { attrib = cattrib; const = `Bitvector i } ];
      }
    when Bitvec.is_negative i ->
      replace [%here]
        (BasilExpr.binexp ~attrib ~op:`BVSUB (fix v)
           (BasilExpr.bvconst ~attrib:cattrib (Bitvec.neg i)))
  | _ -> Keep

let simplify_concat
    (e :
      (BasilExpr.t BasilExpr.abstract_expr * Types.t) BasilExpr.abstract_expr) =
  let open AbstractExpr in
  let open BasilExpr in
  let open Bitvec in
  match e with
  | ApplyIntrin { op = `BVConcat; args = (arg1, Bitvector 1) :: tl }
    when List.for_all (BasilExpr.equal (fix arg1)) (List.map (fst %> fix) tl) ->
      let count = List.length tl in
      replace [%here] (BasilExpr.sign_extend ~n_prefix_bits:count (fix arg1))
  | ApplyIntrin
      {
        op = `BVConcat;
        args =
          (UnaryExpr { op = `SignExtend ext; arg = arg1 }, Bitvector n)
          :: ((UnaryExpr { op = `Extract _; arg = v }, Bitvector 1) as arg2)
          :: tl;
      }
    when List.for_all
           (BasilExpr.equal (fix @@ fst arg2))
           (List.map (fst %> fix) tl) ->
      let count = n + List.length tl in
      replace [%here]
        (BasilExpr.sign_extend ~n_prefix_bits:count (fix @@ fst arg2))
  | UnaryExpr
      { op = `Extract (1, 0); arg = BinaryExpr { op = `BVLSHR; arg1; arg2 }, _ }
    ->
      let rshift =
        match unfix arg2 with
        | Constant { const = `Bitvector a } -> Z.to_int @@ Bitvec.value a
        | _ -> failwith ""
      in
      replace [%here]
        (BasilExpr.extract ~hi_excl:(rshift + 1) ~lo_incl:rshift arg1)
  | _ -> Keep

let simp_concat_fix e =
  to_steady BasilExpr.equal (BasilExpr.rewrite_typed_two simplify_concat) e

(** Replace associative operators with empty or singleton argument lists with
    the identity element for the operation, or the single argument,
    respectively.

    Note we cannot infer the width of a bitvector operation with no arguments in
    order to construct the identity, so such an expression should never be
    constructed.

    Used by SMT encoding, so can't be tested by SMT*)
let drop_assoc
    (e :
      (BasilExpr.t BasilExpr.abstract_expr * Types.t) BasilExpr.abstract_expr) =
  let open AbstractExpr in
  let open BasilExpr in
  let open Bitvec in
  match e with
  | ApplyIntrin
      {
        op = `BVADD | `BVMUL | `BVOR | `BVXOR | `BVAND | `AND | `OR | `BVConcat;
        args = [ a ];
      } ->
      replace [%here] (fix (fst a))
  | ApplyIntrin { op = `AND; args = [] } ->
      replace [%here] (BasilExpr.boolconst true)
  | ApplyIntrin { op = `OR; args = [] } ->
      replace [%here] (BasilExpr.boolconst false)
  | ApplyIntrin { op = `BVConcat; args = [] } ->
      replace [%here] (BasilExpr.bvconst @@ Bitvec.zero ~size:0)
  | ApplyIntrin
      {
        attrib;
        op =
          (`BVADD | `BVMUL | `BVOR | `BVXOR | `BVAND | `AND | `OR | `BVConcat)
          as op;
        args;
      }
    when List.exists
           (function
             | ApplyIntrin { op = op' }, _ when Ops.AllOps.equal_intrin op op'
               ->
                 true
             | _ -> false)
           args ->
      replace [%here]
        (BasilExpr.applyintrin ~attrib ~op
           (List.flat_map
              (function
                | ApplyIntrin { op = op'; args }, _
                  when Ops.AllOps.equal_intrin op op' ->
                    args
                | e, _ -> [ fix e ])
              args))
  | _ -> Keep

let algebraic_simplifications
    (e :
      (BasilExpr.t BasilExpr.abstract_expr * Types.t) BasilExpr.abstract_expr) =
  let open AbstractExpr in
  let open BasilExpr in
  let open Bitvec in
  let keep a = fix (fst a) in
  let is_bvzero = function
    | Constant { const = `Bitvector i } when is_zero i -> true
    | _ -> false
  in
  let is_bvone = function
    | Constant { const = `Bitvector i }
      when Bitvec.equal i (Bitvec.one ~size:(Bitvec.size i)) ->
        true
    | _ -> false
  in
  let is_ones = function
    | Constant { const = `Bitvector i } when equal i (ones ~size:(size i)) ->
        true
    | _ -> false
  in
  let width_args args =
    let size =
      List.hd args |> snd |> Types.bit_width |> Option.get_exn_or "not a bv?"
    in
    size
  in
  match e with
  | ApplyIntrin
      {
        op = `BVConcat;
        attrib;
        args = (ApplyIntrin { op = `BVConcat; args = al }, _) :: tl;
      } ->
      replace [%here]
        (BasilExpr.concatl ~attrib @@ al @ List.map (fun i -> fix (fst i)) tl)
  | ApplyIntrin
      {
        op = `BVADD;
        attrib;
        args = ((RVar { id; attrib = attrib2 } as v), _) :: tl;
      }
    when List.length tl > 1
         && List.for_all (function Constant _, _ -> true | _ -> false) tl ->
      let size = width_args tl in
      let sum =
        List.fold_left
          (fun n e ->
            match e with
            | Constant { const = `Bitvector m }, _ -> Bitvec.add n m
            | _ -> failwith "unreachable")
          (Bitvec.zero ~size) tl
      in
      replace [%here]
        (BasilExpr.applyintrin ~op:`BVADD [ fix v; BasilExpr.bvconst sum ])
  | ApplyIntrin { attrib; op = (`BVADD | `BVOR) as op; args }
    when List.exists (fst %> is_bvzero) args ->
      let size = width_args args in
      let args =
        args |> List.map fst |> List.filter (is_bvzero %> not) |> List.map fix
      in
      if List.is_empty args then
        replace [%here] (BasilExpr.bvconst ~attrib (Bitvec.zero ~size))
      else replace [%here] (BasilExpr.applyintrin ~attrib ~op args)
  | ApplyIntrin { attrib; op = `BVAND | `BVMUL; args }
    when List.exists (fst %> is_bvzero) args ->
      let size = width_args args in
      replace [%here] (BasilExpr.bvconst ~attrib (Bitvec.zero ~size))
  | ApplyIntrin { attrib; op = `BVMUL as op; args }
    when List.exists (fst %> is_bvone) args ->
      let size = width_args args in
      let args =
        args |> List.map fst |> List.filter (is_bvone %> not) |> List.map fix
      in
      if List.is_empty args then
        replace [%here] (BasilExpr.bvconst ~attrib (Bitvec.one ~size))
      else replace [%here] (BasilExpr.applyintrin ~attrib ~op args)
  | BinaryExpr
      {
        op = `BVSUB | `BVASHR | `BVLSHR | `BVSHL;
        arg1;
        arg2 = Constant { const = `Bitvector i }, _;
      }
    when is_zero i ->
      replace [%here] @@ keep arg1
  | ApplyIntrin { attrib; op = `BVAND; args; typ }
    when List.exists (fst %> is_ones) args ->
      let args =
        args |> List.map fst |> List.filter (is_ones %> not) |> List.map fix
      in
      replace [%here] (fix @@ ApplyIntrin { attrib; op = `BVAND; args; typ })
  | ApplyIntrin { attrib; op = `BVOR; args }
    when List.exists (fst %> is_ones) args ->
      let size = width_args args in
      replace [%here] (BasilExpr.bvconst ~attrib @@ Bitvec.ones ~size)
  | UnaryExpr { op = `ZeroExtend 0; arg } -> replace [%here] @@ keep arg
  | UnaryExpr { op = `SignExtend 0; arg } -> replace [%here] @@ keep arg
  | UnaryExpr { op = `Extract (hi, 0); arg = a, Bitvector sz } when hi = sz ->
      replace [%here] (fix a)
  | UnaryExpr { op = `BVNOT; arg = UnaryExpr { op = `BVNOT; arg }, _ } ->
      replace [%here] arg
  | UnaryExpr { op = `BoolNOT; arg = UnaryExpr { op = `BoolNOT; arg }, _ } ->
      replace [%here] arg
  | _ -> Keep

let if_then_else
    (e :
      (BasilExpr.t BasilExpr.abstract_expr * Types.t) BasilExpr.abstract_expr) =
  let open AbstractExpr in
  let open BasilExpr in
  match e with
  | ApplyIntrin
      {
        op = `Cases;
        args =
          [
            ( ( ApplyIntrin { op = `IfThen; args = [ cond; br_true ] },
                Types.Boolean )
            | ( BinaryExpr { op = `IfThen; arg1 = cond; arg2 = br_true },
                Types.Boolean ) );
            (br_false, _);
          ];
        attrib;
      } ->
      ApplyIntrin
        {
          op = `IfThen;
          args = [ cond; br_true; fix br_false ];
          attrib;
          typ = BasilExpr.type_of br_true;
        }
      |> fix
      |> replace [%here]
  | _ -> Keep

let algebraic_simplifications = sequence drop_assoc algebraic_simplifications

let alg_simp_rewriter ?visit e =
  let partial_eval_expr e =
    BasilExpr.rewrite ?visit ~rw_fun:Expr_eval.partial_eval_alg e
  in
  let open Option.Infix in
  e
  |> ( to_steady BasilExpr.equal @@ fun e ->
       e |> partial_eval_expr |> simp_concat_fix )
  |> to_steady BasilExpr.equal
       (BasilExpr.rewrite_typed_two ?visit algebraic_simplifications)
  |> to_steady BasilExpr.equal (BasilExpr.rewrite_typed_two ?visit normalise)

let normalise e =
  let e = alg_simp_rewriter e in
  BasilExpr.rewrite_typed_two normalise e

let%expect_test "normalise" =
  let e =
    BasilExpr.boolnot @@ BasilExpr.boolnot @@ BasilExpr.boolnot
    @@ BasilExpr.applyintrin ~op:`AND
         [
           BasilExpr.boolnot
             (BasilExpr.boolnot (BasilExpr.rvar (Var.create "b" Boolean)));
           BasilExpr.rvar (Var.create "a" Boolean);
         ]
  in
  print_endline (BasilExpr.to_string e);
  let e = normalise e in
  print_endline (BasilExpr.to_string e);
  [%expect
    {|
    boolnot(boolnot(boolnot(booland(boolnot(boolnot(b:bool)), a:bool))))
    boolor(boolnot(b:bool), boolnot(a:bool))
    |}]

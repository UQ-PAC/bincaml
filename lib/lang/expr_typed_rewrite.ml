(** Type checked and elaborating rewriters *)

open Common
open Containers
open Ops
open BasilExpr
open Expr_rewrite
open BasilExpr.Constructors

(** {1 Typing}*)
let type_of e = AbstractExpr.get_typ (unfix e)

(** {1 Additional traversals}*)

let return_type_alg e = AbstractExpr.get_typ e

let fold_with_type (alg : 'e abstract_expr -> 'a) =
  zygo_l ~cata return_type_alg alg

let fold_with_type_r (alg : 'e abstract_expr -> 'a) =
  zygo ~cata return_type_alg alg

let elabourate_typ e = Hm.locally_elaborate_expr e
let rec fixup_typ (eo : t) : t = elabourate_typ eo

(** {1 Smart Constructors} *)

open R.Constructors

let binexp ?attrib ~op arg1 arg2 =
  (match op with
    | #Ops.AllOps.intrin as op -> applyintrin ?attrib ~op [ arg1; arg2 ]
    | #Ops.AllOps.binary as op -> binexp ?attrib ~op arg1 arg2)
  |> fixup_typ

let unexp ?attrib ?typ ~op arg = unexp ?attrib ?typ ~op arg |> fixup_typ

let apply_fun ?attrib ?typ ~func args =
  apply_fun ?attrib ?typ ~func args |> fixup_typ

let letexp ?attrib ?typ bound_vars in_body =
  letexp ?attrib ?typ bound_vars in_body |> fixup_typ

let zero_extend ?attrib ~n_prefix_bits (e : t) : t =
  unexp ?attrib ~op:(`ZeroExtend n_prefix_bits) e |> fixup_typ

let field_store ?attrib ~(field : string) (record : t) (e : t) : t =
  binexp ?attrib ~op:(`WriteField field) record e |> fixup_typ

let field_read ?attrib ~(field : string) (record : t) : t =
  unexp ?attrib ~op:(`ReadField field) record |> fixup_typ

let sign_extend ?attrib ~n_prefix_bits (e : t) : t =
  unexp ?attrib ~op:(`SignExtend n_prefix_bits) e |> fixup_typ

let load ?attrib ~bits endian (m : t) (ind : t) : t =
  binexp ?attrib ~op:(`Load (endian, bits)) m ind |> fixup_typ

let extract ?attrib ~hi_excl ~lo_incl (e : t) : t =
  unexp ?attrib ~op:(`Extract (hi_excl, lo_incl)) e |> fixup_typ

let concat ?attrib (e : t) (f : t) : t =
  applyintrin ?attrib ~op:`BVConcat [ e; f ] |> fixup_typ

let ifthenelse ?attrib cond t e =
  applyintrin ~op:`Cases [ binexp ~op:`IfThen cond t; e ] |> fixup_typ

let concatl ?attrib (e : t list) : t =
  applyintrin ?attrib ~op:`BVConcat e |> fixup_typ

let forall ?attrib ?triggers ~bound p =
  lambda ?triggers ?attrib ~op:`Forall bound p |> fixup_typ

let exists ?attrib ?triggers ~bound p =
  lambda ?triggers ?attrib ~op:`Exists bound p |> fixup_typ

let lambda ?attrib ?triggers ~bound p =
  lambda ?triggers ?attrib ~op:`Lambda bound p |> fixup_typ

let boolnot ?attrib e = unexp ?attrib ~op:`BoolNOT e |> fixup_typ

let intconst ?attrib (v : PrimInt.t) : t =
  const ?attrib ~typ:Integer (`Integer v) |> fixup_typ

let boolconst ?attrib (v : bool) : t =
  const ?attrib ~typ:Boolean (`Bool v) |> fixup_typ

let bvconst ?attrib (v : Bitvec.t) : t =
  const ?attrib ~typ:(Bitvector (Bitvec.size v)) (`Bitvector v)

let rvar ?attrib v = rvar ?attrib ~typ:(Var.typ v) v

let bv_of_int ~(size : int) (v : int) : t =
  const (`Bitvector (Bitvec.of_int ~size v)) ~typ:(Bitvector size)

let const ?attrib ?typ v = const ?attrib ?typ v |> fixup_typ
let fapply ?attrib ?typ func args = fapply ?attrib ?typ func args |> fixup_typ

let applyintrin ?attrib ?typ ~op args =
  applyintrin ?attrib ?typ ~op args |> fixup_typ

(** typed expression rewriter *)
let rewrite_typed (f : (t * Types.t) abstract_expr -> t option) (expr : t) =
  let rw_alg e =
    let orig s = fix @@ AbstractExpr.map fst s in
    match f e with Some e -> e | None -> orig e
  in
  fold_with_type rw_alg expr

let[@inline] replace (here : Lexing.position) v =
  SomeInfo { v; __LINE__ = here.pos_lnum; __FILE__ = here.pos_fname }

let replace_opt = function
  | Some v -> SomeInfo { v; __LINE__; __FILE__ }
  | None -> Keep
[@@inline always]

(** typed rewriter that expands two layers deep into the expression *)
let rewrite_typed_two ?visit
    (f : (t abstract_expr * Types.t) abstract_expr -> rewrite) (expr : t) =
  let rw_alg e =
    let unfold = AbstractExpr.map (fun (e, t) -> (unfix e, t)) e in
    let orig s = fix @@ AbstractExpr.map fst s in
    match f unfold with
    (*| Some n ->
        Option.iter
        (fun f ->
            f { from = orig e; into = n; __LINE__ = None; __FILE__ = None })
        visit;
        n *)
    | SomeInfo { v; __LINE__; __FILE__ } ->
        log_rw visit ~__LINE__ ~__FILE__ (orig e) v
    | Keep -> orig e
  in
  fold_with_type rw_alg expr

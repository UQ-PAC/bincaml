
open Common

open Expr.BasilExpr
open Expr.BasilExpr.Constructors


module Constr = struct


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


end

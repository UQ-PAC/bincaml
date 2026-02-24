(* The wp dual domain for precondition inference *)

open Lang
open Common
open Expr

module type RequiresAnnotation = sig
  val requires : ID.t -> BasilExpr.t list
end

module Domain (S : RequiresAnnotation) = struct
  let name = "WP dual domain"

  type t = Program.e

  let show = BasilExpr.to_string
  let equal = BasilExpr.equal
  let compare = BasilExpr.compare
  let pretty = BasilExpr.pretty
  let bottom = BasilExpr.boolconst true
  let top = BasilExpr.boolconst false
  let e_true = BasilExpr.boolconst true
  let e_false = BasilExpr.boolconst false

  (** Custom simplifier for this domain *)
  let simplify =
    let open AbstractExpr in
    let rw =
      BasilExpr.rewrite ~rw_fun:(function
        | ApplyIntrin { op; args = [ l ] } -> Some l
        | ApplyIntrin { attrib; op = `OR; args }
          when List.mem ~eq:BasilExpr.equal e_false args ->
            Some
              (BasilExpr.fix
                 (ApplyIntrin
                    {
                      attrib;
                      op = `OR;
                      args = List.remove ~eq:BasilExpr.equal ~key:e_false args;
                    }))
        | ApplyIntrin { attrib; op = `AND; args }
          when List.mem ~eq:BasilExpr.equal e_true args ->
            Some
              (BasilExpr.fix
                 (ApplyIntrin
                    {
                      attrib;
                      op = `OR;
                      args = List.remove ~eq:BasilExpr.equal ~key:e_true args;
                    }))
        | ApplyIntrin { op = `OR; args }
          when List.mem ~eq:BasilExpr.equal e_true args ->
            Some e_true
        | ApplyIntrin { op = `AND; args }
          when List.mem ~eq:BasilExpr.equal e_false args ->
            Some e_false
        | ApplyIntrin { op = `OR; args = [] } -> Some e_false
        | ApplyIntrin { op = `AND; args = [] } -> Some e_true
        | BinaryExpr { op = `EQ; arg1; arg2 } when BasilExpr.equal arg1 arg2 ->
            Some e_true
        | UnaryExpr { op = `BoolNOT; arg } when BasilExpr.equal arg e_true ->
            Some e_false
        | UnaryExpr { attrib; op = `Gamma; arg } ->
            Some
              (BasilExpr.fix
                 (ApplyIntrin
                    {
                      attrib;
                      op = `OR;
                      args =
                        BasilExpr.free_vars arg |> VarSet.to_list
                        |> List.map (BasilExpr.unexp ~op:`Gamma % BasilExpr.rvar);
                    }))
        | _ -> None)
      (* ummm this was needed to collapse empty ors *)
    in
    rw % rw

  let join a b = BasilExpr.applyintrin ~op:`OR [ a; b ] |> simplify
  let widening a b = top
  let init proc = bottom

  let leq a b =
    raise
      (Failure
         "(unimplemented) SMT query required to determine leq of predicates")

  let low_expr = Expr.BasilExpr.unexp ~op:`Gamma

  let transfer p stmt =
    let open Stmt in
    match stmt with
    | Instr_Assign a ->
        BasilExpr.substitute
          (fun v ->
            List.find_map (fun (v', e) -> Option.return_if (Var.equal v v') e) a)
          p
        |> simplify
    | Instr_Load l -> top
    | Instr_Assert { body } -> join p (BasilExpr.unexp ~op:`BoolNOT body)
    | Instr_Assume { body; branch } ->
        (* NOTE: if security conditions are added into the ir with a transform
           then this match case is incorrect and should be ignored *)
        let p =
          BasilExpr.applyintrin ~op:`AND
            [ p; BasilExpr.unexp ~op:`BoolNOT body ]
        in
        (if branch then BasilExpr.applyintrin ~op:`OR [ p; low_expr body ]
         else p)
        |> simplify
    | Instr_Call { procid } ->
        BasilExpr.applyintrin ~op:`AND (p :: S.requires procid)
    | Instr_IndirectCall _ | Instr_IntrinCall _ -> top
    | _ -> p

  (** Encode an abstract state as a predicate *)
  (* We use the Algsimp simplifier as a big simplifier pass at the end to make
     cleaner summaries. It may be worth using an external smt simplifier *)
  let to_pred = Algsimp.alg_simp_rewriter % BasilExpr.boolnot
end

module IntraDomain = Domain (struct
  let requires = const []
end)

module IntraAnalysis = Intra_analysis.Backwards (IntraDomain)

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
    let open BasilExpr in
    let rw =
      BasilExpr.rewrite ~rw_fun:(function
        | ApplyIntrin { op; args = [ l ] } -> replace [%here] l
        | ApplyIntrin { attrib; op = `OR; args }
          when List.mem ~eq:BasilExpr.equal e_false args ->
            let args = List.remove ~eq:BasilExpr.equal ~key:e_false args in
            replace [%here]
              (match args with
              | [] -> e_false
              | [ l ] -> l
              | args -> BasilExpr.fix (ApplyIntrin { attrib; op = `OR; args }))
        | ApplyIntrin { attrib; op = `AND; args }
          when List.mem ~eq:BasilExpr.equal e_true args ->
            let args = List.remove ~eq:BasilExpr.equal ~key:e_true args in
            replace [%here]
              (match args with
              | [] -> e_true
              | [ l ] -> l
              | args -> BasilExpr.fix (ApplyIntrin { attrib; op = `OR; args }))
        | ApplyIntrin { op = `OR; args }
          when List.mem ~eq:BasilExpr.equal e_true args ->
            replace [%here] e_true
        | ApplyIntrin { op = `AND; args }
          when List.mem ~eq:BasilExpr.equal e_false args ->
            replace [%here] e_false
        | BinaryExpr { op = `EQ; arg1; arg2 } when BasilExpr.equal arg1 arg2 ->
            replace [%here] e_true
        | UnaryExpr { op = `BoolNOT; arg } when BasilExpr.equal arg e_true ->
            replace [%here] e_false
        | UnaryExpr { attrib; op = `Gamma; arg } ->
            replace [%here]
              (match free_vars arg |> VarSet.to_list with
              | [] -> e_true
              | [ v ] -> unexp ~op:`Gamma @@ rvar v
              | vars ->
                  BasilExpr.fix
                    (ApplyIntrin
                       {
                         attrib;
                         op = `OR;
                         args =
                           vars
                           |> List.map
                                (BasilExpr.unexp ~op:`Gamma % BasilExpr.rvar);
                       }))
        | _ -> None)
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
        (if branch then BasilExpr.applyintrin ~op:`OR [ p; BasilExpr.boolnot @@ low_expr body ]
         else p)
        |> simplify
    | Instr_Call { procid } ->
        BasilExpr.applyintrin ~op:`AND (p :: S.requires procid)
    | Instr_IndirectCall _ | Instr_IntrinCall _ -> top
    | _ -> p

  (** Encode an abstract state as a predicate *)
  let to_pred = Algsimp.normalise % BasilExpr.boolnot
  (* We use the Algsimp simplifier as a big simplifier pass at the end to make
     cleaner summaries. It may be worth using an external smt simplifier *)
end

module IntraDomain = Domain (struct
  let requires = const []
end)

module IntraAnalysis = Intra_analysis.Backwards (IntraDomain)

(* The wp dual domain for precondition inference *)

open Lang
open Common
open Expr

module Domain = struct
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

  let simplify e =
    let open AbstractExpr in
    BasilExpr.rewrite
      ~rw_fun:(function
        | ApplyIntrin (op, [ l ]) -> Some l
        | ApplyIntrin (`OR, l) when List.mem ~eq:BasilExpr.equal e_false l ->
            Some
              (BasilExpr.fix
                 (ApplyIntrin
                    (`OR, List.remove ~eq:BasilExpr.equal ~key:e_false l)))
        | ApplyIntrin (`AND, l) when List.mem ~eq:BasilExpr.equal e_true l ->
            Some
              (BasilExpr.fix
                 (ApplyIntrin
                    (`OR, List.remove ~eq:BasilExpr.equal ~key:e_true l)))
        | ApplyIntrin (`OR, l) when List.mem ~eq:BasilExpr.equal e_true l ->
            Some e_true
        | ApplyIntrin (`AND, l) when List.mem ~eq:BasilExpr.equal e_false l ->
            Some e_false
        | ApplyIntrin (`OR, []) -> Some e_false
        | ApplyIntrin (`AND, []) -> Some e_true
        | BinaryExpr (`EQ, a, b) when BasilExpr.equal a b -> Some e_true
        | UnaryExpr (`BoolNOT, a) when BasilExpr.equal a e_true -> Some e_false
        | _ -> None)
      e

  let join a b = BasilExpr.applyintrin ~op:`OR [ a; b ] |> simplify
  let widening a b = top
  let init proc = bottom

  (* FIXME gamma *)
  let low_expr (e : Program.e) =
    BasilExpr.free_vars_iter e
    |> Iter.map (fun v ->
        BasilExpr.apply_fun ~name:"gamma" [ BasilExpr.rvar v ])
    |> Iter.to_list
    |> BasilExpr.applyintrin ~op:`OR

  let transfer p stmt =
    let open Stmt in
    match stmt with
    | Instr_Assign a ->
        BasilExpr.substitute
          (fun v ->
            List.find_map (fun (v', e) -> Option.return_if (Var.equal v v') e) a)
          p
    | Instr_Load l -> top
    | Instr_Assert { body } -> join p (BasilExpr.unexp ~op:`BoolNOT body)
    | Instr_Assume { body; branch } ->
        let p =
          BasilExpr.applyintrin ~op:`AND
            [ p; BasilExpr.unexp ~op:`BoolNOT body ]
        in
        (if branch then BasilExpr.applyintrin ~op:`OR [ p; low_expr body ]
         else p)
        |> simplify
    | Instr_IndirectCall _ | Instr_Call _ | Instr_IntrinCall _ -> top
    | _ -> p

  let to_pred (p : t) = BasilExpr.boolnot p
  (** Encode an abstract state as a predicate *)
end

module Analysis = Intra_analysis.Backwards (Domain)

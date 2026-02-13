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

  let simplify e =
    let open AbstractExpr in
    BasilExpr.rewrite
      ~rw_fun:(function
        | ApplyIntrin (op, [ l ]) -> Some l
        | ApplyIntrin (`OR, l) when List.mem ~eq:BasilExpr.equal (BasilExpr.boolconst false) l ->
            Some
              (BasilExpr.fix
                 (ApplyIntrin (`OR, List.remove ~eq:BasilExpr.equal ~key:top l)))
        | ApplyIntrin (`OR, l) when List.mem ~eq:BasilExpr.equal (BasilExpr.boolconst true) l ->
            Some (BasilExpr.boolconst true)
        | ApplyIntrin (`OR, []) -> Some (BasilExpr.boolconst false)
        | BinaryExpr (`EQ, a, b) when BasilExpr.equal a b ->
            Some (BasilExpr.boolconst true)
        | UnaryExpr (`BoolNOT, a)
          when BasilExpr.equal a (BasilExpr.boolconst true) ->
            Some (BasilExpr.boolconst false)
        | _ -> None)
      e

  let join a b = BasilExpr.applyintrin ~op:`OR [ a; b ] |> simplify
  let widening a b = top
  let init proc = bottom

  open Stmt

  (* FIXME gamma *)
  let low_expr (e : Program.e) =
    BasilExpr.free_vars_iter e
    |> Iter.map (fun v ->
        BasilExpr.apply_fun ~name:"gamma" [ BasilExpr.rvar v ])
    |> Iter.to_list
    |> BasilExpr.applyintrin ~op:`OR

  let transfer p = function
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
end

module Analysis = Intra_analysis.Backwards (Domain)

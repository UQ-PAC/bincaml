open Bincaml_util.Common
open Lang

(** Add wpif verification conditions (no rely/guarantee!) to the procedure *)
let wpif_conditions (proc : Program.proc) =
  let open Stmt in
  Procedure.map_blocks_nondet
    (fun (_, b) ->
      Block.flat_map ~phi:id
        (fun stmt ->
          match stmt with
          | Instr_Store { lhs; value; addr = Scalar } ->
              let po1 =
                Expr.BasilExpr.(
                  binexp ~op:`IMPLIES
                    (unexp ~op:`Classification (rvar lhs))
                    (unexp ~op:`Gamma value))
              in
              (* TODO forall y . x in vars(L(y)) => (L(y)[x \ e] => L(y) || Gamma_y) *)
              let po2 = Expr.BasilExpr.boolconst true in
              Iter.of_list
                [
                  Instr_Assert { attrib = Attrib.empty; body = po1 };
                  stmt;
                  Instr_Assert { attrib = Attrib.empty; body = po2 };
                ]
          | _ -> Iter.singleton stmt)
        b)
    proc

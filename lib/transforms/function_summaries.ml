(* Generate function summaries for a given procedure *)
open Lang
open Common
open Analysis.Wp_dual

let transform (proc : Program.proc) =
  let result =
    Analysis.analyse
      ~init:(fun _ -> Expr.BasilExpr.boolconst false)
      ~widening_set:Graph.ChaoticIteration.FromWto ~widening_delay:5 proc
  in
  let r =
    Analysis.A.M.find_opt Procedure.Vert.Entry result
    |> Option.map Domain.to_pred
  in
  match r with
  | Some r ->
      let spec = Procedure.specification proc in
      let requires = r :: spec.requires in
      let spec = { spec with requires } in
      Procedure.set_specification proc spec
  | _ -> proc

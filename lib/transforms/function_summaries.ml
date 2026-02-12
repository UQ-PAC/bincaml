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
  let n = ID.to_string @@ Procedure.id proc in
  CCIO.with_out
    ("wpdual" ^ n ^ ".dot")
    (fun s -> Analysis.print_dot (Format.of_chan s) proc result);
  proc

(* Generate function summaries for a given procedure *)
open Lang
open Common
open Analysis

module type FunctionSummaryAnnotation = sig
  val requires : ID.t -> Expr.BasilExpr.t list
  val ensures : ID.t -> Expr.BasilExpr.t list
end

let wp_dual_requires (module S : FunctionSummaryAnnotation)
    (proc : Program.proc) =
  let module Domain = Wp_dual.Domain (S) in
  let module Analysis = Intra_analysis.Backwards (Domain) in
  let result =
    Analysis.analyse
      ~init:(fun _ -> Expr.BasilExpr.boolconst false)
      ~widening_set:Graph.ChaoticIteration.FromWto ~widening_delay:5 proc
  in
  Analysis.A.M.find_opt Procedure.Vert.Entry result
  |> Option.map Domain.to_pred |> Option.to_list

(** `redundant p ps` returns true if the conjunction of `p :: ps` is equivalent
    to that of `ps`. *)
let redundant p ps = false

let annotate_proc (s : (module FunctionSummaryAnnotation)) (proc : Program.proc)
    =
  let r = wp_dual_requires s proc in
  (* TODO implement a sample ensures clause generator and some sort of analysis
     pass runner *)
  List.fold_left
    (fun proc r ->
      let spec = Procedure.specification proc in
      let requires =
        if redundant r spec.requires then spec.requires else r :: spec.requires
      in
      let spec = { spec with requires } in
      Procedure.set_specification proc spec)
    proc r

let transform =
  annotate_proc
    (module struct
      let requires _ = []
      let ensures _ = []
    end : FunctionSummaryAnnotation)

let annotate_component _g (prog : Program.t) component =
  (* TODO will want to use an smt solver to perform leq checks then do a data
       flow analysis on the component, but for now can just do a linear pass *)
  let open Program.CallGraph.Vert in
  let procs = prog.procs in
  let procs =
    List.fold_left
      (fun procs -> function
        | ProcBegin pid ->
            let proc = ID.Map.find pid procs in
            let proc' =
              annotate_proc
                (module struct
                  let requires id =
                    ID.Map.find id procs |> Procedure.specification |> fun s ->
                    s.requires

                  let ensures id =
                    ID.Map.find id procs |> Procedure.specification |> fun s ->
                    s.ensures
                end : FunctionSummaryAnnotation)
                proc
            in
            ID.Map.add (Procedure.id proc) proc' procs
        | _ -> procs)
      procs component
  in
  { prog with procs }

let interproc_transform (prog : Program.t) =
  let call_graph = Program.CallGraph.make_call_graph prog in
  let sccs = Program.CallGraph.Scc.scc_list call_graph in
  List.fold_left (annotate_component call_graph) prog sccs

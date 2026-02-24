(* Generate function summaries for a given procedure *)
open Lang
open Common
open Analysis

type summary = {
  requires : Expr.BasilExpr.t list;
  ensures : Expr.BasilExpr.t list;
}

module type FunctionSummaryAnnotation = sig
  val requires : ID.t -> Expr.BasilExpr.t list
  val ensures : ID.t -> Expr.BasilExpr.t list
end

(** `redundant p ps` returns true if the conjunction of `p :: ps` is equivalent
    to that of `ps`. *)
let redundant (solver : Bincaml_util.Smt.Solver.t) p ps =
  let conj = Expr.BasilExpr.applyintrin ~op:`AND ps in
  let q = Expr.BasilExpr.boolnot @@ Expr.BasilExpr.binexp ~op:`IMPLIES conj p in
  let open Expr_smt in
  let s =
    SMTLib2.assert_bexpr q SMTLib2.empty
    |> snd
    |> SMTLib2.to_sexp ~set_logic:true
  in
  let open Bincaml_util.Smt in
  let _ = Solver.push solver in
  s |> Iter.iter (fun c -> ignore @@ Solver.add_command solver c);
  let res = Solver.check solver in
  let _ = Solver.pop solver in
  match res with Unsat -> true | Sat -> false | Unknown -> false

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

let new_summary (solver : Bincaml_util.Smt.Solver.t)
    (module S : FunctionSummaryAnnotation) (proc : Program.proc) =
  (* TODO implement a sample ensures clause generator and some sort of analysis
     pass runner *)
  let cur_req = S.requires (Procedure.id proc) in
  let requires =
    wp_dual_requires (module S) proc
    |> List.fold_left
         (fun cur_req r ->
           if redundant solver r cur_req then cur_req else r :: cur_req)
         cur_req
  in
  { requires; ensures = S.ensures (Procedure.id proc) }

let annotate_proc (solver : Bincaml_util.Smt.Solver.t)
    (s : (module FunctionSummaryAnnotation)) (proc : Program.proc) =
  let summary = new_summary solver s proc in
  let spec = Procedure.specification proc in
  let spec =
    { spec with requires = summary.requires; ensures = summary.ensures }
  in
  Procedure.set_specification proc spec

let transform proc =
  let solver =
    Bincaml_util.Smt.Solver.create
      {
        Bincaml_util.Smt.Config.cvc5 with
        log = Bincaml_util.Smt.Config.quiet_log;
      }
  in
  annotate_proc solver
    (module struct
      let requires id =
        if ID.equal id (Procedure.id proc) then
          (Procedure.specification proc).requires
        else []

      let ensures id =
        if ID.equal id (Procedure.id proc) then
          (Procedure.specification proc).ensures
        else []
    end : FunctionSummaryAnnotation)
    proc

let annotate_component (solver : Bincaml_util.Smt.Solver.t) g (prog : Program.t)
    component =
  let procs = prog.procs in
  let component =
    List.filter_map
      (function Program.CallGraph.Vert.ProcBegin pid -> Some pid | _ -> None)
      component
    |> ID.Set.of_list
  in
  let module Domain = struct
    type property = summary

    let bottom = { requires = []; ensures = [] }

    let equal a b =
      List.equal Expr.BasilExpr.equal a.requires b.requires
      && List.equal Expr.BasilExpr.equal a.ensures b.ensures

    let is_maximal _ = false
  end in
  let module FixSummaries = Fix.Fix.ForHashedType (ID) (Domain) in
  let eqs (pid : ID.t) (vals : FixSummaries.valuation) =
    let annotations =
      (module struct
        (* TODO redundant requires are still added, see cntlm fmtfdinit
           I suspect this comes from these annotations containing redundancy maybe? *)
        let requires id =
          List.append
            ( ID.Map.find id procs |> Procedure.specification |> fun s ->
              s.requires )
            (vals id).requires

        let ensures id =
          List.append
            ( ID.Map.find id procs |> Procedure.specification |> fun s ->
              s.ensures )
            (vals id).ensures
      end : FunctionSummaryAnnotation)
    in
    new_summary solver annotations (ID.Map.find pid procs)
  in
  let sol = FixSummaries.lfp eqs in
  let procs =
    ID.Set.fold
      (fun pid procs ->
        let proc = ID.Map.find pid procs in
        let spec = Procedure.specification proc in
        let sum = sol pid in
        let spec =
          { spec with requires = sum.requires; ensures = sum.ensures }
        in
        let proc' = Procedure.set_specification proc spec in
        ID.Map.add pid proc' procs)
      component procs
  in
  { prog with procs }

let interproc_transform (prog : Program.t) =
  let call_graph = Program.CallGraph.make_call_graph prog in
  let sccs = Program.CallGraph.Scc.scc_list call_graph in
  let solver =
    Bincaml_util.Smt.Solver.create
      {
        Bincaml_util.Smt.Config.cvc5 with
        log = Bincaml_util.Smt.Config.quiet_log;
      }
  in
  List.fold_left (annotate_component solver call_graph) prog sccs

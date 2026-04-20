(* Generate function summaries for a given procedure *)
open Lang
open Common
open Analysis

type summary = {
  requires : Expr.BasilExpr.t list;
  ensures : Expr.BasilExpr.t list;
}

let append_summary s1 s2 =
  {
    requires = List.append s1.requires s2.requires;
    ensures = List.append s1.ensures s2.ensures;
  }

module type FunctionSummaryAnnotation = sig
  val requires : ID.t -> Expr.BasilExpr.t list
  val ensures : ID.t -> Expr.BasilExpr.t list
end

(** Replace gamma expressions with gamma variables for an smt query *)
let normalise_gamma =
  let open Expr.AbstractExpr in
  let open Expr.BasilExpr in
  let make_gamma_var v =
    rvar (Var.create ("Gamma_" ^ Var.name v) ~scope:(Var.scope v) Boolean)
  in
  Expr.BasilExpr.rewrite ~rw_fun:(function
    | UnaryExpr { op = `Gamma; arg } -> (
        (* TODO if needed handle the case when arg is a map *)
        let vars = free_vars arg in
        match VarSet.elements vars with
        | [] -> replace [%here] @@ boolconst true
        | v :: [] -> replace [%here] @@ make_gamma_var v
        | vs ->
            replace [%here] @@ applyintrin ~op:`OR (List.map make_gamma_var vs))
    | _ -> Keep)

(** `redundant p ps` returns true if the conjunction of `p :: ps` is equivalent
    to that of `ps`. *)
let redundant (solver : Bincaml_util.Smt.Solver.t) p ps =
  if Expr.BasilExpr.equal p (Expr.BasilExpr.boolconst true) then
    Bincaml_util.Smt.Solver.Unsat
  else if List.is_empty ps then Bincaml_util.Smt.Solver.Sat
  else
    try
      let conj = Expr.BasilExpr.applyintrin ~op:`AND ps in
      let q =
        normalise_gamma @@ Expr.BasilExpr.boolnot
        @@ Expr.BasilExpr.binexp ~op:`IMPLIES conj p
      in
      let open Expr_smt in
      let s =
        SMTLib2.assert_bexpr q SMTLib2.empty
        |> snd
        |> SMTLib2.to_sexp ~set_logic:false
      in
      let open Bincaml_util.Smt in
      Solver.push solver;
      s |> Iter.iter (fun c -> Solver.add_command solver c);
      let res = Solver.check solver in
      Solver.pop solver;
      res
    with _ -> Bincaml_util.Smt.Solver.Unknown

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

(** Compute an extension of the given procedure's summary *)
let extra_summary (solver : Bincaml_util.Smt.Solver.t)
    (module S : FunctionSummaryAnnotation) reiter (proc : Program.proc) =
  (* TODO implement a sample ensures clause generator and some sort of analysis
     pass runner *)
  let cur_req = S.requires (Procedure.id proc) in
  if IDSet.mem (Procedure.id proc) !reiter then
    { requires = cur_req; ensures = [] }
  else
    let requires =
      wp_dual_requires (module S) proc
      |> List.fold_left
           (fun rs r ->
             let open Bincaml_util.Smt in
             match redundant solver r (List.append rs cur_req) with
             | Unsat -> rs
             | Sat -> r :: rs
             | Unknown ->
                 reiter := IDSet.add (Procedure.id proc) !reiter;
                 r :: rs)
           []
    in
    { requires; ensures = [] }

let set_summary summary (proc : Program.proc) =
  let spec = Procedure.specification proc in
  let spec =
    { spec with requires = summary.requires; ensures = summary.ensures }
  in
  Procedure.set_specification proc spec

let add_summary summary (proc : Program.proc) =
  let spec = Procedure.specification proc in
  let spec =
    {
      spec with
      requires = List.append spec.requires summary.requires;
      ensures = List.append spec.ensures summary.ensures;
    }
  in
  Procedure.set_specification proc spec

let intraproc_transform_proc (prog : Program.t) (proc : Program.proc) =
  let solver =
    Bincaml_util.Smt.Solver.create
      {
        Bincaml_util.Smt.Config.cvc5 with
        log = Bincaml_util.Smt.Config.quiet_log;
      }
  in
  let builder = Expr_smt.SMTLib2.empty in
  let x: Expr_smt.SMTLib2.builder =
    Program.declarations prog |> Iter.from_iter
    |> Iter.map (function i, d -> Expr_smt.SMTLib2.trans_decl d)
    |> Iter.fold (fun acc t -> snd @@ t acc) builder
  in
  (* |> Iter.to_string ~sep:"," (fun d -> ""); *)
  (* let builder = Expr_smt.SMTLib2.add_ in *)
  (* Bincaml_util.Smt.Solver.add_command *)
  let summary =
    extra_summary solver
      (module struct
        let requires id =
          Program.proc_opt prog id
          |> Option.map_or
               (fun p -> (Procedure.specification p).requires)
               ~default:[]

        let ensures id =
          Program.proc_opt prog id
          |> Option.map_or
               (fun p -> (Procedure.specification p).ensures)
               ~default:[]
      end : FunctionSummaryAnnotation)
      (ref IDSet.empty) proc
  in
  Bincaml_util.Smt.Solver.stop solver;
  add_summary summary proc

let intraproc_transform (prog : Program.t) =
  let module Dfs = Graph.Traverse.Dfs (Program.CallGraph.G) in
  let cg = Program.CallGraph.make_call_graph prog in
  Iter.from_iter (fun f -> Dfs.postfix f cg)
  |> Iter.fold
       (fun prog v ->
         match v with
         | Program.CallGraph.Vert.ProcBegin id ->
             Program.update_proc id
               (function
                 | Some proc -> Some (intraproc_transform_proc prog proc)
                 | None -> None)
               prog
         | _ -> prog)
       prog

module Domain = struct
  type property = summary

  let bottom = { requires = []; ensures = [] }

  let equal a b =
    List.equal Expr.BasilExpr.equal a.requires b.requires
    && List.equal Expr.BasilExpr.equal a.ensures b.ensures

  let is_maximal _ = false
end

module FixSummaries = Fix.Fix.ForHashedType (ID) (Domain)

let solve_component (solver : Bincaml_util.Smt.Solver.t) g (prog : Program.t)
    res component =
  let procs = Program.procs prog |> IDMap.of_iter in
  let component =
    List.filter_map
      (function Program.CallGraph.Vert.ProcBegin pid -> Some pid | _ -> None)
      component
    |> IDSet.of_list
  in
  let reiters = ref IDSet.empty in
  let eqs (pid : ID.t) (vals : FixSummaries.valuation) =
    if IDSet.mem pid component then
      let annotations =
        (module struct
          let requires id =
            List.append (IDMap.find id res).requires (vals id).requires

          let ensures id =
            List.append (IDMap.find id res).ensures (vals id).ensures
        end : FunctionSummaryAnnotation)
      in
      let extra =
        extra_summary solver annotations reiters (IDMap.find pid procs)
      in
      append_summary (vals pid) extra
    else IDMap.get_or pid res ~default:Domain.bottom
  in
  let sol = FixSummaries.lfp eqs in
  IDSet.fold
    (fun pid res ->
      IDMap.add pid (append_summary (IDMap.find pid res) (sol pid)) res)
    component res

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
  let summaries =
    Program.procs prog
    |> Iter.map (fun (i, proc) ->
        let spec = Procedure.specification proc in
        (i, { requires = spec.requires; ensures = spec.ensures }))
    |> IDMap.of_iter
  in
  let summaries =
    List.fold_left (solve_component solver call_graph prog) summaries sccs
  in
  IDMap.fold
    (fun procid summary (prog : Program.t) ->
      Program.update_proc procid (Option.map (set_summary summary)) prog)
    summaries prog

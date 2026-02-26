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

let normalise_gamma =
  let open Expr.AbstractExpr in
  let open Expr.BasilExpr in
  let make_gamma_var v =
    rvar
      (Var.create
         ("Gamma_" ^ Var.name v)
         ~pure:(Var.pure v) ~scope:(Var.scope v) Boolean)
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
    | _ -> None)

(** `redundant p ps` returns true if the conjunction of `p :: ps` is equivalent
    to that of `ps`. *)
let redundant (solver : Bincaml_util.Smt.Solver.t) p ps =
  if Expr.BasilExpr.equal p (Expr.BasilExpr.boolconst true) then true
  else if List.is_empty ps then false
  else
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
    match res with Unsat -> true | Sat -> false | Unknown -> assert false

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

let extra_summary (solver : Bincaml_util.Smt.Solver.t)
    (module S : FunctionSummaryAnnotation) (proc : Program.proc) =
  (* TODO implement a sample ensures clause generator and some sort of analysis
     pass runner *)
  let cur_req = S.requires (Procedure.id proc) in
  let requires =
    wp_dual_requires (module S) proc
    |> List.fold_left
         (fun rs r ->
           if redundant solver r (List.append rs cur_req) then rs else r :: rs)
         []
  in
  { requires; ensures = [] }

let annotate_proc (solver : Bincaml_util.Smt.Solver.t)
    (s : (module FunctionSummaryAnnotation)) (proc : Program.proc) =
  let summary = extra_summary solver s proc in
  let spec = Procedure.specification proc in
  let spec =
    {
      spec with
      requires = List.append spec.requires summary.requires;
      ensures = List.append spec.ensures summary.ensures;
    }
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
    res component =
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
    if ID.Set.mem pid component then
      let annotations =
        (module struct
          let requires id =
            List.append (ID.Map.get_or id res ~default:Domain.bottom).requires
              (vals id).requires

          let ensures id =
            List.append (ID.Map.get_or id res ~default:Domain.bottom).ensures
              (vals id).ensures
        end : FunctionSummaryAnnotation)
      in
      let extra = extra_summary solver annotations (ID.Map.find pid procs) in
      append_summary (vals pid) extra
    else ID.Map.get_or pid res ~default:Domain.bottom
  in
  let sol = FixSummaries.lfp eqs in
  ID.Set.fold
    (fun pid res ->
      ID.Map.add pid (append_summary (ID.Map.find pid res) (sol pid)) res)
    component res

let interproc_transform (prog : Program.t) =
  let call_graph = Program.CallGraph.make_call_graph prog in
  let sccs = Program.CallGraph.Scc.scc_list call_graph in
  let solver =
    Bincaml_util.Smt.Solver.create
      {
        Bincaml_util.Smt.Config.z3 with
        log = Bincaml_util.Smt.Config.quiet_log;
      }
  in
  let summaries =
    prog.procs
    |> ID.Map.map (fun proc ->
        let spec = Procedure.specification proc in
        { requires = spec.requires; ensures = spec.ensures })
  in
  let summaries =
    List.fold_left (annotate_component solver call_graph prog) summaries sccs
  in
  ID.Map.fold
    (fun pid summary (prog : Program.t) ->
      let proc = ID.Map.find pid prog.procs in
      let spec = Procedure.specification proc in
      let spec =
        { spec with requires = summary.requires; ensures = summary.ensures }
      in
      let proc' = Procedure.set_specification proc spec in
      let procs = ID.Map.add pid proc' prog.procs in
      { prog with procs })
    summaries prog

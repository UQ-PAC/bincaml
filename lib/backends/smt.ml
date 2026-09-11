open Lang
open Lang.Common
open Bincaml_util.Common
open Bincaml_util
open Expr_smt
open Expr

(** SMT Backend. This backend expects the CFA Reduction and Summary Inlining
    transforms. Will output a .smt file containing all declarations and asserts
    necessary for verification. Live variant runs smt solver in bincaml,
    printing more useful and readable output from analysis. *)

open Effect

type _ Effect.t +=
  | Push : Sexp.t SMTLib2.t -> unit Effect.t
  | Verify : Sexp.t SMTLib2.t * (Program.proc * Program.stmt) -> unit Effect.t

let visit_stmt procedure =
  let open SMTLib2.Infix in
  function
  | Stmt.Instr_Assert { body } as stmt ->
      (* Verify negation of assertion is unsat. *)
      perform
        (Verify
           ( SMTLib2.of_bexpr (BasilExpr.boolnot body) >>= SMTLib2.assert_sexp,
             (procedure, stmt) ));

      (* Actual assertion. *)
      perform (Push (SMTLib2.of_bexpr body >>= SMTLib2.assert_sexp))
  | Stmt.Instr_Assume { body } ->
      (* Assert the assumption as is. SSA makes this equiv to assume. *)
      perform (Push (SMTLib2.of_bexpr body >>= SMTLib2.assert_sexp))
  | Stmt.Instr_Assign { al } ->
      (* Assign is just an assertion of equivalent lhs and rhs.
             This is bidirectional, but SSA + Reachability conds avoid this
             causing issues. *)
      al
      |> List.map (fun (v, e) ->
          BasilExpr.binexp ~op:`EQ (BasilExpr.rvar v) e
          |> SMTLib2.of_bexpr >>= SMTLib2.assert_sexp)
      |> List.map (fun s -> perform (Push s))
      |> ignore
  | _ -> ()

let visit_procedure (program : Program.t) (procedure : Program.proc) =
  perform (Push SMTLib2.push);

  perform
    (Push
       (SMTLib2.echo
          ("Verifying Procedure: " ^ ID.name (Procedure.id procedure))));

  let local_decls = Procedure.local_decls procedure in
  local_decls
  |> Hashtbl.iter (fun k v -> perform (Push (fun s -> SMTLib2.decl_var v s)));

  (* Translate each statement to smt. *)
  Procedure.iter_stmt_topo_fwd procedure
  |> flip Iter.for_each (visit_stmt procedure);

  perform (Push SMTLib2.pop)

let visit_program (program : Program.t) =
  let g = Program.DependencyGraph.make_dependency_graph ~rev:true program in
  let module Topo = Graph.Topological.Make (Program.DependencyGraph.G) in
  Iter.from_iter (flip Topo.iter g)
  |> Iter.filter_map (flip Program.get_decl program)
  |> flip Iter.for_each (function
    | Program.Procedure { definition } -> visit_procedure program definition
    | other -> perform (Push (SMTLib2.trans_decl other)))

(** Offline SMT backend. Converts entire program to smt and dumps to chan.
    Inserts verification condition checks with echos for easier tracing. *)
let smt_offline chan (program : Program.t) : unit =
  let open Containers_pp in
  let builder = ref SMTLib2.empty in
  (try visit_program program with
  | effect Push s, k ->
      (* Push the builder as is. *)
      builder := snd @@ s !builder;
      Effect.Deep.continue k ()
  | effect Verify (s, c), k ->
      (* Push, wrapped in a scope + check sat. *)
      builder := snd @@ SMTLib2.push !builder;
      builder := snd @@ s !builder;
      builder := snd @@ SMTLib2.check_sat !builder;
      builder := snd @@ SMTLib2.pop !builder;
      Effect.Deep.continue k ());

  (* Pretty print the output. *)
  let fmt = Format.formatter_of_out_channel chan in
  Expr_smt.SMTLib2.to_sexp ~set_logic:true !builder
  |> flip Iter.for_each (fun s ->
      Containers_pp.pp fmt (Sexp.to_string s |> text);
      Containers_pp.pp fmt newline);
  flush chan;
  Format.flush fmt ()

(** check satisfiability on the live solver, returning the result and printing
    failures + counterexamples to the output channel. *)
let check_sat chan stmt solver proc program =
  let result = Smt.Solver.check solver in
  (match result with
  | (Unknown : Smt.Solver.result) ->
      Printf.fprintf chan "\nUnknown Assertion:\n%s\n"
        (Stmt.to_string Var.pretty Var.pretty BasilExpr.pretty stmt)
  | Sat -> (
      Printf.fprintf chan "\nFailing Assertion: %s\n"
        (Stmt.to_string Var.pretty Var.pretty BasilExpr.pretty stmt);
      Printf.fprintf chan "Belonging to procedure: %s\n"
        (ID.name @@ Procedure.id proc);
      Printf.fprintf chan "Counterexample:\n";
      let model = Smt.Solver.get_model solver in
      match model with
      | `Atom a -> Printf.fprintf chan "%s\n" (Sexp.to_string model)
      | `List l ->
          l |> List.to_iter
          |> Iter.filter (function
            | `List (`Atom "define-fun" :: `Atom var :: _ :: `Atom typ :: _) ->
                Procedure.lookup_local_decl proc var |> Option.is_some
                || Program.get_decl_by_name var program |> Option.is_some
            | _ -> false)
          |> flip Iter.for_each (fun s ->
              Printf.fprintf chan "%s\n" (Sexp.to_string s)))
  | Unsat -> ());
  result

(** Online SMT backend. Starts up a solver and feeds program one statement at a
    time to it. Prints more useful messages for failing VCs and tracks stats for
    entire procedures. *)
let smt_online chan (program : Program.t) : unit =
  flush chan;
  let solver =
    Bincaml_util.Smt.Solver.create
      {
        Bincaml_util.Smt.Config.cvc5 with
        log = Bincaml_util.Smt.Config.quiet_log;
      }
  in

  (* Track a map of procedure,result to number of occurences. *)
  let module M = Map.Make (struct
    type t = Smt.Solver.result [@@deriving eq, ord]
  end) in
  let results : int M.t IDMap.t ref = ref IDMap.empty in

  let builder = ref SMTLib2.empty in

  (try visit_program program with
  | effect Push s, k ->
      let sexps, b = SMTLib2.extract s !builder in
      builder := b;
      if
        sexps
        |> Iter.map (Smt.Solver.add_sexp solver)
        |> Iter.for_all (function
          | `List (`Atom "error" :: body) as s ->
              Printf.fprintf chan "solver error: %s" (CCSexp.to_string s);
              (* Exit early on any error. *)
              false
          | _ -> true)
      then Effect.Deep.continue k ()
  | effect Verify (s, (proc, stmt)), k ->
      let sexps, b = SMTLib2.extract s !builder in
      builder := b;
      Smt.Solver.push solver;
      builder := SMTLib2.push_scope !builder;
      sexps |> Iter.iter (Smt.Solver.add_sexp solver %> ignore);
      let result = check_sat chan stmt solver proc program in
      (* Increment the counter for procedure/result type: *)
      results :=
        IDMap.update (Procedure.id proc)
          Option.(
            or_ ~else_:(Some M.empty)
            %> map (M.update result (or_ ~else_:(Some 0) %> map (( + ) 1))))
          !results;
      Smt.Solver.pop solver;
      builder := SMTLib2.pop_scope !builder;
      Effect.Deep.continue k ());

  (* Print out the counts of sat/unsat/unknown for each procedure. *)
  !results
  |> IDMap.iter (fun id map ->
      if
        (Option.is_some @@ M.get Unknown map)
        || (Option.is_some @@ M.get Sat map)
      then
        Printf.fprintf chan "Procedure %s failed verification with:\n"
          (ID.name id)
      else
        Printf.fprintf chan "Procedure %s succeeded verification with:\n"
          (ID.name id);
      [ Unknown; Sat; Unsat ]
      |> List.iter (fun k ->
          M.get_or ~default:0 k map
          |> Printf.fprintf chan "\t %s: %d\n" (Smt.Solver.show_result k)));

  Smt.Solver.stop solver

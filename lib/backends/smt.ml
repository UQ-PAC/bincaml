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
  | Push : SMTLib2.builder -> unit Effect.t
  | Verify : SMTLib2.builder * (Program.proc * Program.stmt) -> unit Effect.t

(* Get any ambiguous variables (shared name, different type). *)
let ambiguities (program : Program.t) : VarSet.t Iter.t =
  Program.procs program
  (* Get all variables in program: *)
  |> Iter.flat_map
       (snd %> Procedure.iter_blocks
       %> Iter.flat_map (fun (_, b) ->
           Iter.append (Block.read_vars_iter b) (Block.assigned_vars_iter b)))
  (* Group variables by name: *)
  |> Iter.group_by
       ~hash:(fun v -> Hash.string @@ Var.name v)
       ~eq:(fun v1 v2 -> String.equal (Var.name v1) (Var.name v2))
  |> Iter.map VarSet.of_list
  (* Only keep lists of length > 1: *)
  |> Iter.filter (VarSet.cardinal %> ( <= ) 2)

(* Map rvars to sexps, necessary to handle ambiguities and
   function calls which are sensitive to context in program. *)
let rvar_map (program : Program.t) =
  ambiguities program
  (* Map all ambiguous variables to as expressions. *)
  |> Iter.flat_map
     @@ VarSet.to_iter
        %> Iter.map (fun v ->
            let sexp =
             fun s ->
              let var, s = SMTLib2.get_var v s in
              let typ = fst @@ SMTLib2.of_typ (Var.typ v) in
              (CCSexp.(list [ atom "as"; var; typ ]), s)
            in
            (v, sexp))
  |> VarMap.of_iter

(** Remove all variable declarations from a builder which conflict with a sort
    declaration. *)
let dedup_decls (builder : SMTLib2.builder) : SMTLib2.builder =
  let removals =
    VarMap.to_iter builder.var_decls
    |> Iter.filter_map (fun (var, _) ->
        match Var.typ var with
        | Sort (name, _) -> Some (Var.copy ~typ:(Types.Variable name) var)
        | _ -> None)
    |> VarSet.of_iter
  in

  {
    builder with
    var_decls =
      builder.var_decls
      |> VarMap.filter (fun var _ -> not @@ VarSet.mem var removals);
  }

let visit_stmt procedure rvars = function
  | Stmt.Instr_Assert { body } as stmt ->
      (* Verify negation of assertion is unsat. *)
      let builder =
        SMTLib2.add_assert
          (SMTLib2.of_bexpr ~rvars (BasilExpr.boolnot body))
          SMTLib2.empty
        |> snd
      in
      perform (Verify (builder, (procedure, stmt)));

      (* Assert the actual assertion. *)
      let smt = SMTLib2.of_bexpr ~rvars body in
      let builder = SMTLib2.add_assert smt SMTLib2.empty |> snd in
      perform (Push builder)
  | Stmt.Instr_Assume { body } ->
      (* Assert the assumption as is. SSA makes this equiv to assume. *)
      let smt = SMTLib2.of_bexpr ~rvars body in
      let builder = SMTLib2.add_assert smt SMTLib2.empty |> snd in
      perform (Push builder)
  | Stmt.Instr_Assign { al } ->
      (* Assign is just an assertion of equivalent lhs and rhs.
             This is bidirectional, but SSA + Reachability conds avoid this
             causing issues. *)
      let asserts =
        List.map
          (fun (v, e) ->
            BasilExpr.binexp ~op:`EQ (BasilExpr.rvar v) e
            |> SMTLib2.of_bexpr ~rvars)
          al
      in
      let builder =
        List.fold_left
          (fun builder smt -> SMTLib2.add_assert smt builder |> snd)
          SMTLib2.empty asserts
      in
      perform (Push builder)
  | _ -> ()

let visit_procedure ~rvars (program : Program.t) (procedure : Program.proc) =
  print_endline @@ "visitng proc" ^ (Procedure.id procedure |> ID.name);
  let builder =
    SMTLib2.empty |> SMTLib2.push |> snd
    |> SMTLib2.echo ("Verifying Procedure: " ^ ID.name (Procedure.id procedure))
    |> snd
  in
  perform (Push builder);

  let local_decls = Procedure.local_decls procedure in
  local_decls
  |> Hashtbl.iter (fun k v ->
      perform (Push (snd @@ SMTLib2.decl_var v SMTLib2.empty)));

  (* Translate each statement to smt. *)
  Procedure.iter_stmt_topo_fwd procedure
  |> flip Iter.for_each (visit_stmt procedure rvars);

  perform (Push (SMTLib2.pop SMTLib2.empty |> snd))

let visit_program (program : Program.t) =
  let program =
    (Transforms.Ssa.set_params ~skip_observable:false ~skip_maps:false) program
  in
  let rvars = rvar_map program in
  Program.declarations program
  |> Iter.map snd
  |> flip Iter.for_each (function
    | Program.Procedure { definition } ->
        visit_procedure ~rvars program definition
    | other -> perform (Push (SMTLib2.trans_decl other SMTLib2.empty |> snd)))

(** Offline SMT backend. Converts entire program to smt and dumps to chan.
    Inserts verification condition checks with echos for easier tracing. *)
let smt_offline chan (program : Program.t) : unit =
  let open Containers_pp in
  let builder = ref SMTLib2.empty in
  (try visit_program program with
  | effect Push b, k ->
      builder := SMTLib2.append !builder b;
      Effect.Deep.continue k ()
  | effect Verify (b, c), k ->
      builder := snd @@ SMTLib2.push !builder;
      builder := SMTLib2.append !builder b;
      builder := snd @@ SMTLib2.check_sat !builder;
      builder := snd @@ SMTLib2.pop !builder;
      Effect.Deep.continue k ());
  let p =
    Expr_smt.SMTLib2.to_sexp ~set_logic:true !builder
    |> Iter.map (Sexp.to_string %> text)
    |> Iter.to_list |> append_nl
  in
  flush chan;
  let fmt = Format.formatter_of_out_channel chan in
  Containers_pp.Pretty.to_format ~width:80 fmt p;
  Format.flush fmt ()

(** Online SMT backend. Starts up a solver and feeds program one statement at a
    time to it. Prints more useful messages for failing VCs and tracks stats for
    entire procedures. *)
let smt_online chan (program : Program.t) : unit =
  let module M = Map.Make (struct
    type t = Smt.Solver.result [@@deriving eq, ord]
  end) in
  flush chan;
  let solver =
    Bincaml_util.Smt.Solver.create
      {
        Bincaml_util.Smt.Config.cvc5 with
        log = Bincaml_util.Smt.Config.printf_log;
      }
  in
  let results : int M.t IDMap.t ref = ref IDMap.empty in
  (try visit_program program with
  | effect Push b, k ->
      if
        SMTLib2.to_sexp ~set_logic:false b
        |> Iter.map (Smt.Solver.add_sexp solver)
        |> Iter.for_all (function
          | `List (`Atom "error" :: body) as s ->
              Printf.fprintf chan "solver error: %s" (CCSexp.to_string s);
              false
          | _ -> true)
      then Effect.Deep.continue k ()
  | effect Verify (b, (proc, stmt)), k ->
      Smt.Solver.push solver;
      SMTLib2.commands_to_sexp b
      |> Iter.map (Smt.Solver.add_sexp solver)
      |> Iter.iter (const ());
      let result = Smt.Solver.check solver in
      (match result with
      | Unknown ->
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
                | `List (`Atom "define-fun" :: `Atom var :: _ :: `Atom typ :: _)
                  ->
                    Procedure.lookup_local_decl proc var |> Option.is_some
                    || Program.get_decl_by_name var program |> Option.is_some
                | _ -> false)
              |> flip Iter.for_each (fun s ->
                  Printf.fprintf chan "%s\n" (Sexp.to_string s)))
      | Unsat -> ());
      results :=
        IDMap.update (Procedure.id proc)
          Option.(
            or_ ~else_:(Some M.empty)
            %> map (M.update result (or_ ~else_:(Some 0) %> map (( + ) 1))))
          !results;
      Smt.Solver.pop solver;
      Effect.Deep.continue k ());
  Smt.Solver.stop solver;
  flip IDMap.iter !results (fun id map ->
      Printf.fprintf chan "Procedure %s verified with:\n" (ID.name id);
      [ Unknown; Sat; Unsat ]
      |> List.iter (fun k ->
          M.get_or ~default:0 k map
          |> Printf.fprintf chan "\t %s: %d\n" (Smt.Solver.show_result k)))

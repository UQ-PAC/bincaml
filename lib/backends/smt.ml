open Lang
open Lang.Common
open Bincaml_util.Common
open Bincaml_util
open Expr_smt
open Expr

(* SMT Backend.
   This backend expects the CFA Reduction and Summary Inlining transforms.
   Will output a .smt file containing all declarations and asserts necessary
   for verification.
*)

type context = { stmt : Program.stmt option; proc : ID.t option; vc : bool }

let empty : context = { stmt = None; proc = None; vc = false }

(* type context = Stmt of Program.stmt | Verify of Program.stmt | None *)

(* Produce a list of builders for a procedure, with context.
   Builder for local declarations + one for each statement.
   Assertions produce a second builder for verification. *)
let build_procedure (program : Program.t) (procedure : Program.proc) :
    (SMTLib2.builder * context) list =
  let ctx = { empty with proc = Some (Procedure.id procedure) } in

  let builders = CCVector.create () in

  let builder =
    SMTLib2.empty |> SMTLib2.push |> snd
    |> SMTLib2.echo ("Verifying Procedure: " ^ ID.name (Procedure.id procedure))
    |> snd
  in

  (* Generate a declaration for each local var. *)
  let local_decls = Procedure.local_decls procedure in
  let builder =
    Hashtbl.to_iter local_decls
    |> Iter.fold (fun acc (k, v) -> snd @@ SMTLib2.decl_var v acc) builder
  in

  CCVector.push builders (builder, ctx);

  (* Translate each statement to smt. *)
  Procedure.iter_stmt_topo_fwd procedure
  |> flip Iter.for_each (fun stmt ->
      let builder = SMTLib2.empty in
      let ctx = { ctx with stmt = Some stmt; vc = false } in
      match stmt with
      | Stmt.Instr_Assert { body } ->
          (* Verify negation of assertion is unsat. *)
          let builder = snd @@ SMTLib2.push builder in
          let builder =
            snd
            @@ SMTLib2.add_assert
                 (SMTLib2.of_bexpr ~type_hints:true (BasilExpr.boolnot body))
                 builder
          in
          let builder = snd @@ SMTLib2.check_sat builder in
          let builder = snd @@ SMTLib2.pop builder in
          CCVector.push builders (builder, { ctx with vc = true });

          (* Assert the actual assertion. *)
          let smt = SMTLib2.of_bexpr ~type_hints:true body in
          let builder = SMTLib2.add_assert smt SMTLib2.empty |> snd in
          CCVector.push builders (builder, ctx)
      | Stmt.Instr_Assume { body } ->
          (* Assert the assumption as is. SSA makes this equiv to assume. *)
          let smt = SMTLib2.of_bexpr ~type_hints:true body in
          let builder = SMTLib2.add_assert smt builder |> snd in
          CCVector.push builders (builder, ctx)
      | Stmt.Instr_Assign { al } ->
          (* Assign is just an assertion of equivalent lhs and rhs.
             This is bidirectional, but SSA + Reachability conds avoid this
             causing issues. *)
          let asserts =
            List.map
              (fun (v, e) ->
                BasilExpr.binexp ~op:`EQ (BasilExpr.rvar v) e
                |> SMTLib2.of_bexpr ~type_hints:true)
              al
          in
          let builder =
            List.fold_left
              (fun builder smt -> SMTLib2.add_assert smt builder |> snd)
              builder asserts
          in
          CCVector.push builders (builder, ctx)
      | _ -> ());

  CCVector.push builders (SMTLib2.pop SMTLib2.empty |> snd, ctx);
  CCVector.to_list builders

let build_declaration (program : Program.t) (declaration : Program.declaration)
    : (SMTLib2.builder * context) list =
  match declaration with
  | Procedure { definition } -> build_procedure program definition
  | _ -> failwith "Unsupported SMT declaration"

let build_program (program : Program.t) : (SMTLib2.builder * context) list =
  Program.declarations program
  |> Iter.map snd
  |> Iter.flat_map_l (fun d -> build_declaration program d)
  |> Iter.to_list

let eval_single chan (solver : Smt.Solver.t)
    ((builder, context) : SMTLib2.builder * context) =
  let sexps = SMTLib2.commands_to_sexp builder in
  sexps
  |> flip Iter.for_each (fun sexp ->
      let response = Smt.Solver.add_sexp solver sexp in
      match (context, response) with
      | { stmt = Some stmt; vc = true }, `Atom "sat" ->
          Printf.fprintf chan "Failing Assertion: %s\n"
            (Stmt.to_string Var.pretty Var.pretty BasilExpr.pretty stmt)
      | _ -> ())

let eval_program chan (program : Program.t) =
  flush chan;
  let solver =
    Bincaml_util.Smt.Solver.create
      {
        Bincaml_util.Smt.Config.cvc5 with
        log = Bincaml_util.Smt.Config.quiet_log;
      }
  in
  let builders = build_program program in
  (* Join the builders together for computing unified declarations/preamble. *)
  let builder =
    List.fold_left
      (fun acc b -> SMTLib2.append acc (fst b))
      SMTLib2.empty builders
  in
  let preamble = SMTLib2.preamble_to_sexp builder in
  let decls = SMTLib2.decls_to_sexp builder in
  Iter.append preamble decls
  |> flip Iter.for_each (fun sexp -> Smt.Solver.add_command solver sexp);
  builders |> List.to_iter |> flip Iter.for_each @@ eval_single chan solver;
  flush chan

let pretty_program (program : Program.t) : Containers_pp.t =
  let open Containers_pp in
  let builders = build_program program in
  let builder =
    List.fold_left
      (fun acc b -> SMTLib2.append acc (fst b))
      SMTLib2.empty builders
  in
  Expr_smt.SMTLib2.to_sexp ~set_logic:true builder
  |> Iter.map (Sexp.to_string %> text)
  |> Iter.to_list |> append_nl

let pretty_to_chan chan (p : Program.t) =
  let p = pretty_program p in
  flush chan;
  let fmt = Format.formatter_of_out_channel chan in
  Containers_pp.Pretty.to_format ~width:80 fmt p;
  Format.flush fmt ()

open Lang
open Lang.Common
open Bincaml_util.Common
open Bincaml_util
open Expr_smt
open Expr

(* Takes a single edge procedure (see cfa_reduction.ml transform).
   Maps each statement to an smt expression. *)
let build_procedure (program : Program.t) (procedure : Program.proc)
    (builder : SMTLib2.builder) : SMTLib2.builder =
  let builder = snd @@ SMTLib2.push builder in

  (* Echo the name of the proc being verified. *)
  let builder =
    snd
    @@ SMTLib2.echo
         ("Verifying Procedure: " ^ ID.name (Procedure.id procedure))
         builder
  in

  (* Generate a declaration for each local var. *)
  let local_decls = Procedure.local_decls procedure in
  let builder =
    Hashtbl.to_iter local_decls
    |> Iter.fold (fun acc (k, v) -> snd @@ SMTLib2.decl_var v acc) builder
  in

  (* Need the specification for requires/ensures. *)
  let spec = Procedure.specification procedure in
  let assert_exprs f exprs builder =
    exprs
    |> List.fold_left
         (fun acc expr ->
           snd @@ SMTLib2.add_assert (SMTLib2.of_bexpr @@ f expr) acc)
         builder
  in

  (* Produce assertions for the requires requirements of a procedure. *)
  let builder = assert_exprs id spec.requires builder in

  (* Translate each statement to smt. *)
  let builder =
    Procedure.iter_stmt_topo_fwd procedure
    |> Iter.fold
         (fun acc stmt ->
           match stmt with
           | Stmt.Instr_Assert { body } ->
               (* Verify negation of assertion is unsat. *)
               let acc = snd @@ SMTLib2.push acc in
               let acc =
                 snd
                 @@ SMTLib2.add_assert
                      (SMTLib2.of_bexpr (BasilExpr.boolnot body))
                      acc
               in
               let acc = snd @@ SMTLib2.check_sat acc in
               let acc = snd @@ SMTLib2.pop acc in

               (* Assert the assertion. *)
               let smt = SMTLib2.of_bexpr body in
               SMTLib2.add_assert smt acc |> snd
           | Stmt.Instr_Assume { body } ->
               (* Assert the assumption as is. *)
               let smt = SMTLib2.of_bexpr body in
               SMTLib2.add_assert smt acc |> snd
           | Stmt.Instr_Assign { al } ->
               let asserts =
                 List.map
                   (fun (v, e) ->
                     BasilExpr.binexp ~op:`EQ (BasilExpr.rvar v) e
                     |> SMTLib2.of_bexpr)
                   al
               in
               List.fold_left
                 (fun acc smt -> SMTLib2.add_assert smt acc |> snd)
                 acc asserts
           | Stmt.Instr_Call { lhs; procid; args } ->
               (* For calls, assert the negation of requires is unsat.
                 Then we simply assert the requires/ensures.
                 Asserting the requires is fine as this is on fresh SSA
                 variables.*)
               let subst_var varmap expression =
                 BasilExpr.substitute
                   (fun v ->
                     StringMap.get (Var.name v) varmap
                     |> Option.map BasilExpr.rvar)
                   expression
               in
               let subst_expr varmap expression =
                 BasilExpr.substitute
                   (fun v -> StringMap.get (Var.name v) varmap)
                   expression
               in
               let call_proc = Program.proc program procid in
               let spec = Procedure.specification call_proc in

               let requires =
                 List.map (fun e -> subst_expr args e) spec.requires
               in
               let ensures =
                 List.map
                   (fun e -> subst_var lhs @@ subst_expr args e)
                   spec.ensures
               in

               (* Verify negation of requires is unsat. *)
               let acc = snd @@ SMTLib2.push acc in
               let acc = assert_exprs BasilExpr.boolnot requires acc in
               let acc = snd @@ SMTLib2.check_sat acc in
               let acc = snd @@ SMTLib2.pop acc in

               (* Assert Requires. *)
               let acc = assert_exprs id requires acc in

               (* Assert Ensures. *)
               let acc = assert_exprs id ensures acc in

               acc
           | _ -> acc)
         builder
  in

  (* Verify negation of ensures is unsat. *)
  let builder = snd @@ SMTLib2.push builder in
  let builder = assert_exprs BasilExpr.boolnot spec.ensures builder in
  let builder = snd @@ SMTLib2.check_sat builder in
  let builder = snd @@ SMTLib2.pop builder in

  let builder = snd @@ SMTLib2.pop builder in
  builder

let build_declaration (program : Program.t) (declaration : Program.declaration)
    (builder : SMTLib2.builder) : SMTLib2.builder =
  match declaration with
  | Procedure { definition } -> build_procedure program definition builder
  | _ -> failwith "Unsupported SMT declaration"

let build_program (program : Program.t) (builder : SMTLib2.builder) :
    SMTLib2.builder =
  Program.declarations program
  |> Iter.map snd
  |> Iter.fold (fun a b -> build_declaration program b a) builder

let pretty_program (program : Program.t) : Containers_pp.t =
  let open Containers_pp in
  let builder = build_program program SMTLib2.empty in
  Expr_smt.SMTLib2.to_sexp ~set_logic:true builder
  |> Iter.map (Sexp.to_string %> text)
  |> Iter.to_list |> append_nl

let pretty_to_chan chan (p : Program.t) =
  let p = pretty_program p in
  flush chan;
  let fmt = Format.formatter_of_out_channel chan in
  Containers_pp.Pretty.to_format ~width:80 fmt p;
  Format.flush fmt ()

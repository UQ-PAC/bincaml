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
           | _ -> acc)
         builder
  in

  let builder = snd @@ SMTLib2.pop builder in
  builder

let eval_procedure (program : Program.t) (procedure : Program.proc)
    (solver : Smt.Solver.t) =
  (* Builder constructed locally for eval. Will be cleared a few times. *)
  let builder = snd @@ SMTLib2.push SMTLib2.empty in

  (* Print out the proc being verified. *)
  print_endline ("Verifying Procedure: " ^ ID.name (Procedure.id procedure));

  (* Generate a declaration for each local var. *)
  let local_decls = Procedure.local_decls procedure in
  let builder =
    Hashtbl.to_iter local_decls
    |> Iter.fold (fun acc (k, v) -> snd @@ SMTLib2.decl_var v acc) builder
  in

  let res =
    Smt.Solver.add_assert solver (BasilExpr.boolconst true |> SMTLib2.of_bexpr)
  in
  print_endline "hahh";

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
           | _ -> acc)
         builder
  in

  let builder = snd @@ SMTLib2.pop builder in
  solver

let build_declaration (program : Program.t) (declaration : Program.declaration)
    (builder : SMTLib2.builder) : SMTLib2.builder =
  match declaration with
  | Procedure { definition } -> build_procedure program definition builder
  | _ -> failwith "Unsupported SMT declaration"

let eval_declaration (program : Program.t) (declaration : Program.declaration)
    (solver : Smt.Solver.t) =
  let solver =
    match declaration with
    | Procedure { definition } -> eval_procedure program definition solver
    | _ -> failwith "Unsupported SMT declaration"
  in
  solver

let build_program (program : Program.t) (builder : SMTLib2.builder) :
    SMTLib2.builder =
  Program.declarations program
  |> Iter.map snd
  |> Iter.fold (fun a b -> build_declaration program b a) builder

let eval_program (program : Program.t) (solver : Smt.Solver.t) =
  Program.declarations program
  |> Iter.map snd
  |> Iter.fold (fun a b -> eval_declaration program b a) solver

(* Pretty printing mode. Dump all of the SMT directly: *)
let pretty_program (program : Program.t) : Containers_pp.t =
  let open Containers_pp in
  let builder = build_program program SMTLib2.empty in
  Expr_smt.SMTLib2.to_sexp ~set_logic:true builder
  |> Iter.map (Sexp.to_string %> text)
  |> Iter.to_list |> append_nl

let eval_program (program : Program.t) =
  let solver_config = Smt.Config.cvc5 in
  let solver = Smt.Solver.create solver_config in
  let solver = eval_program program solver in
  solver
  (* Expr_smt.SMTLib2.to_sexp ~set_logic:true builder *)
  (* |> Iter.map (Sexp.to_string %> text) *)
  (* |> Iter.to_list |> append_nl *)

let pretty_to_chan chan (p : Program.t) =
  let p = pretty_program p in
  flush chan;
  let fmt = Format.formatter_of_out_channel chan in
  Containers_pp.Pretty.to_format ~width:80 fmt p;
  Format.flush fmt ()

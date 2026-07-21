open Lang
open Lang.Common
open Bincaml_util.Common
open Bincaml_util
(* open Containers *)

(* Takes a procedure that has been reduced to a single edge.
   Maps each statement to an smt expression. *)
let proc_to_smt (proc : Program.proc) : Smt.sexp list =
  let builder = Expr_smt.SMTLib2.empty in

  (* Generate a declaration for each local var. *)
  let local_decls = Procedure.local_decls proc in
  let builder =
    Hashtbl.to_iter local_decls
    |> Iter.fold
         (fun acc (k, v) -> snd @@ Expr_smt.SMTLib2.decl_var v acc)
         builder
  in

  let builder = snd @@ Expr_smt.SMTLib2.push builder in
  let builder = snd @@ Expr_smt.SMTLib2.pop builder in

  let builder =
    Procedure.iter_stmt_topo_fwd proc
    |> Iter.fold
         (fun acc stmt ->
           match stmt with
           | Stmt.Instr_Assert { body } ->
               let smt =
                 Expr_smt.SMTLib2.of_bexpr (Expr.BasilExpr.boolnot body)
               in
               Expr_smt.SMTLib2.add_assert smt acc |> snd
               (* | Stmt.Instr_Assume { body } -> *)
               (* let smt = Expr_smt.SMTLib2.of_bexpr body in *)
               (* Expr_smt.SMTLib2.add_assert smt acc |> snd *)
           | Stmt.Instr_Assign { al } ->
               let asserts =
                 List.map
                   (fun (v, e) ->
                     Expr.BasilExpr.binexp ~op:`EQ (Expr.BasilExpr.rvar v) e
                     |> Expr_smt.SMTLib2.of_bexpr)
                   al
               in
               List.fold_left
                 (fun acc smt -> Expr_smt.SMTLib2.add_assert smt acc |> snd)
                 acc asserts
           | _ -> acc)
         builder
  in
  let builder = snd @@ Expr_smt.SMTLib2.check_sat builder in
  Expr_smt.SMTLib2.to_sexp builder |> Iter.to_list

let pretty_procedure (p : Program.proc) =
  let open Containers_pp in
  let smts = proc_to_smt p in
  append_nl (smts |> List.map (CCSexp.to_string %> text))

let pretty_declaration (d : Program.declaration) =
  let open Containers_pp in
  let open Containers_pp.Infix in
  match d with
  | Procedure { definition } -> pretty_procedure definition
  | _ -> failwith "Unsupported SMT declaration"

let pretty_program (p : Program.t) =
  let open Containers_pp in
  let glob_vars_funs, rest =
    Program.declarations p |> Iter.map snd |> Iter.to_list
    |> List.partition_filter_map (fun d ->
        let p = pretty_declaration d in
        match d with
        | Program.Variable _ | Program.Function _ | Program.Type _ -> `Left p
        | _ -> `Right p)
  in
  let glob_vars = append_nl glob_vars_funs in
  let rest = append_nl rest in
  append_l ~sep:(newline ^ newline) [ glob_vars; rest ]

let pretty_to_chan chan (p : Program.t) =
  let p = pretty_program p in
  flush chan;
  let fmt = Format.formatter_of_out_channel chan in
  Containers_pp.Pretty.to_format ~width:80 fmt p;
  Format.flush fmt ()

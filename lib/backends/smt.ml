open Lang
open Lang.Common
open Bincaml_util.Common
open Bincaml_util
open Expr_smt
(* open Containers *)

(* Takes a procedure that has been reduced to a single edge.
   Maps each statement to an smt expression. *)
let build_proc (proc : Program.proc) (builder : SMTLib2.builder) :
    SMTLib2.builder =
  let builder = snd @@ SMTLib2.push builder in

  (* Generate a declaration for each local var. *)
  let local_decls = Procedure.local_decls proc in
  let builder =
    Hashtbl.to_iter local_decls
    |> Iter.fold (fun acc (k, v) -> snd @@ SMTLib2.decl_var v acc) builder
  in

  let builder =
    Procedure.iter_stmt_topo_fwd proc
    |> Iter.fold
         (fun acc stmt ->
           match stmt with
           | Stmt.Instr_Assert { body } ->
               let smt = SMTLib2.of_bexpr (Expr.BasilExpr.boolnot body) in
               SMTLib2.add_assert smt acc |> snd
           | Stmt.Instr_Assign { al } ->
               let asserts =
                 List.map
                   (fun (v, e) ->
                     Expr.BasilExpr.binexp ~op:`EQ (Expr.BasilExpr.rvar v) e
                     |> SMTLib2.of_bexpr)
                   al
               in
               List.fold_left
                 (fun acc smt -> SMTLib2.add_assert smt acc |> snd)
                 acc asserts
           | _ -> acc)
         builder
  in
  let builder = snd @@ SMTLib2.check_sat builder in
  let builder = snd @@ SMTLib2.pop builder in
  builder

let build_declaration (declaration : Program.declaration)
    (builder : SMTLib2.builder) : SMTLib2.builder =
  match declaration with
  | Procedure { definition } -> build_proc definition builder
  | _ -> failwith "Unsupported SMT declaration"

let build_program (program : Program.t) (builder : SMTLib2.builder) :
    SMTLib2.builder =
  Program.declarations program
  |> Iter.map snd
  |> Iter.fold (fun a b -> build_declaration b a) builder

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

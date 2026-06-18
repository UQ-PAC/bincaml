(** CHC problem types and Spacer solver interaction.

    Holds the constrained-Horn-clause data types ([predicate], [clause]), their
    serialisation to SMT-LIB, and the machinery for solving them with Z3/Spacer.
    {!Transforms.Chc_infer} encodes the IR into these clauses and decodes the
    solver's model; this module is kept separate so the solver protocol stays
    independent of the IR encoding. See {!Bincaml_util.Smt} for the underlying
    SMT-LIB sexp helpers. *)

open Bincaml_util.Common
open Lang
open CCSexp
module SmtExpr = Bincaml_util.Smt.Expr

type predicate = { name : string; params : Var.t list }
(** A CHC predicate: an uninterpreted [Bool]-valued function over a fixed list
    of typed parameters. The same parameter list is used for both declaration
    and application -- order matters. *)

type clause = {
  vars : Var.t list;  (** universally-quantified binders for the [forall] *)
  premises : Sexp.t list;  (** conjuncts of the antecedent *)
  head : Sexp.t option;
      (** [Some sexp] for a rule and [None] for a query (head = false) *)
}
(** A constrained Horn clause. **)

let var_sort v = fst (Expr_smt.SMTLib2.of_typ (Var.typ v))

(* A variable reference as an SMT atom. Routes through [smt_symbol] so names
   that aren't valid SMT-LIB simple symbols (e.g. names containing [#]) are
   emitted as quoted [|...|] symbols rather than mis-tokenised by the solver. *)
let var_atom v = Expr_smt.SMTLib2.smt_symbol (Var.name v)

let declare_predicate (p : predicate) : Sexp.t =
  SmtExpr.declare_fun p.name (List.map var_sort p.params) SmtExpr.t_bool

let forall_ binders body =
  if List.is_empty binders then body
  else SmtExpr.app_ "forall" [ list binders; body ]

let clause_to_sexp (c : clause) : Sexp.t =
  let binders = List.map (fun v -> list [ var_atom v; var_sort v ]) c.vars in
  let premise = SmtExpr.bool_ands c.premises in
  let body =
    match c.head with
    | Some h -> SmtExpr.bool_implies premise h
    | None -> SmtExpr.bool_not premise
  in
  list [ atom "assert"; forall_ binders body ]

(** Open a Z3 process configured for Spacer with model-preserving options.
    Spacer's slicing and eager-inlining transformations rewrite the input in
    ways that drop predicate parameters or fuse predicates together, which
    breaks our positional-parameter mapping when decoding the model. Turn both
    off so [(get-model)] returns predicates that line up with what we sent.

    [timeout_ms] controls Z3's [:timeout] option (per [check-sat], in
    milliseconds): [Some t] caps the solve at [t] ms (on timeout [check-sat]
    returns [unknown]), [None] leaves it unbounded. Defaults to [None]. *)
let open_spacer ?(timeout_ms = None) () =
  let module Solver = Bincaml_util.Smt.Solver in
  let s = Solver.create Bincaml_util.Smt.Config.z3 in
  Solver.set_option s ":fp.xform.slice" "false";
  Solver.set_option s ":fp.xform.inline_eager" "false";
  Option.iter
    (fun t -> Solver.set_option s ":timeout" (string_of_int t))
    timeout_ms;
  Solver.set_logic s "HORN";
  s

type model_def = {
  name : string;  (** the predicate name *)
  params : (string * Sexp.t) list;
      (** positional parameters with sorts (Spacer typically emits fresh names
          like [x!0], [x!1]) *)
  body : Sexp.t;  (** the predicate's inferred interpretation *)
}
(** One [define-fun] entry from a parsed [get-model]. Callers map [params] back
    to our actual variables by position. *)

(** Parse a model returned by [get-model] into a list of [model_def]s. *)
let parse_model (model : Sexp.t) : model_def list =
  let unexpected s = raise (Bincaml_util.Smt.UnexpectedSolverResponse s) in
  let parse_param p =
    match p with `List [ `Atom v; sort ] -> (v, sort) | _ -> unexpected p
  in
  let parse_def def =
    match def with
    | `List [ `Atom "define-fun"; `Atom name; `List params; _ret; body ] ->
        { name; params = List.map parse_param params; body }
    | _ -> unexpected def
  in
  match model with
  | `List defs -> List.map parse_def defs
  | `Atom _ -> unexpected model

type solve_result =
  | Sat of model_def list
      (** the solver's model, one [model_def] per predicate *)
  | Unsat
  | Unknown

(** One Spacer invocation against the encoded CHC system. Reuses
    {!Bincaml_util.Smt.Solver} directly; the only HORN-specific bit is the
    [(set-logic HORN)] preamble. On [Sat] the parsed model is carried in the
    result. *)
let solve_and_get_model ?timeout_ms (preds : predicate list)
    (clauses : clause list) : solve_result =
  let module Solver = Bincaml_util.Smt.Solver in
  let s = open_spacer ?timeout_ms () in
  List.iter (fun pr -> Solver.add_command s (declare_predicate pr)) preds;
  List.iter (fun c -> Solver.add_command s (clause_to_sexp c)) clauses;
  let result =
    match Solver.check s with
    | Solver.Sat -> Sat (parse_model (Solver.get_model s))
    | Solver.Unsat -> Unsat
    | Solver.Unknown -> Unknown
  in
  Solver.stop s;
  result

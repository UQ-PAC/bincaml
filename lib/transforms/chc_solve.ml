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
    and application — order matters. *)

type clause = {
  vars : Var.t list;  (** universally-quantified binders for the [forall] *)
  premises : Sexp.t list;  (** conjuncts of the antecedent *)
  head : Sexp.t option;
      (** [Some sexp] for a rule and [None] for a query (head = false) *)
}
(** A constrained Horn clause. **)

let var_sort v = fst (Expr_smt.SMTLib2.of_typ (Var.typ v))

let declare_predicate (p : predicate) : Sexp.t =
  SmtExpr.declare_fun p.name (List.map var_sort p.params) SmtExpr.t_bool

let forall_ binders body =
  if List.is_empty binders then body
  else SmtExpr.app_ "forall" [ list binders; body ]

let clause_to_sexp (c : clause) : Sexp.t =
  let binders =
    List.map (fun v -> list [ atom (Var.name v); var_sort v ]) c.vars
  in
  let premise = SmtExpr.bool_ands c.premises in
  let body =
    match c.head with
    | Some h -> SmtExpr.bool_implies premise h
    | None -> SmtExpr.bool_not premise
  in
  list [ atom "assert"; forall_ binders body ]

type solve_result = Sat | Unsat | Unknown

(** Default wall-clock cap (milliseconds) applied to every Spacer solve. On
    timeout Z3 returns [unknown], which {!Transforms.Chc_infer}'s pass entry
    points already handle as "no invariant inferred". *)
let default_timeout_ms = 30_000

(** Open a Z3 process configured for Spacer with model-preserving options.
    Spacer's slicing and eager-inlining transformations rewrite the input in
    ways that drop predicate parameters or fuse predicates together, which
    breaks our positional-parameter mapping when decoding the model. Turn both
    off so [(get-model)] returns predicates that line up with what we sent.

    [timeout_ms] controls Z3's [:timeout] option (per [check-sat], in
    milliseconds): [Some t] caps the solve at [t] ms (on timeout [check-sat]
    returns [unknown]), [None] leaves it unbounded. Defaults to
    [Some default_timeout_ms]. *)
let open_spacer ?(timeout_ms = Some default_timeout_ms) () =
  let module Solver = Bincaml_util.Smt.Solver in
  let s = Solver.create Bincaml_util.Smt.Config.z3 in
  Solver.set_option s ":fp.xform.slice" "false";
  Solver.set_option s ":fp.xform.inline_eager" "false";
  Option.iter
    (fun t -> Solver.set_option s ":timeout" (string_of_int t))
    timeout_ms;
  Solver.set_logic s "HORN";
  s

type model_def = string * (string * Sexp.t) list * Sexp.t
(** One [define-fun] entry from a parsed [get-model]: the predicate name, its
    positional parameters with sorts (Spacer typically emits fresh names like
    [x!0], [x!1]), and the body. Callers map params back to our actual variables
    by position. *)

(** Parse a model returned by Z3 [get-model] into a list of [model_def]s. *)
let parse_model (model : Sexp.t) : model_def list =
  match model with
  | `List defs ->
      List.filter_map
        (fun def ->
          match def with
          | `List [ `Atom "define-fun"; `Atom name; `List params; _ret; body ]
            ->
              let params =
                List.filter_map
                  (fun p ->
                    match p with
                    | `List [ `Atom v; sort ] -> Some (v, sort)
                    | _ -> None)
                  params
              in
              Some (name, params, body)
          | _ -> None)
        defs
  | _ -> []

(** One Spacer invocation against the encoded CHC system. Reuses
    {!Bincaml_util.Smt.Solver} directly; the only HORN-specific bit is the
    [(set-logic HORN)] preamble. Returns the [solve_result] together with the
    parsed model on Sat. *)
let solve_and_get_model ?timeout_ms (preds : predicate list)
    (clauses : clause list) : solve_result * model_def list option =
  let module Solver = Bincaml_util.Smt.Solver in
  let s = open_spacer ?timeout_ms () in
  List.iter (fun pr -> Solver.add_command s (declare_predicate pr)) preds;
  List.iter (fun c -> Solver.add_command s (clause_to_sexp c)) clauses;
  let result =
    match Solver.check s with
    | Sat ->
        let model = parse_model (Solver.get_model s) in
        (Sat, Some model)
    | Unsat -> (Unsat, None)
    | Unknown -> (Unknown, None)
  in
  Solver.stop s;
  result

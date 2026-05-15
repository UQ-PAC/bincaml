(** CHC encoding of the IR.

    This module encodes a program as a system of constrained Horn clauses
    (CHCs) over quantifier-free bit vectors. See {!Lang.Expr_smt.SMTLib2} for
    expression-level encoding and {!Bincaml_util.Smt} for the SMT-LIB sexp
    helpers used below.

    Step 1 only supports straight-line procedures with [Instr_Assign]
    statements. Later steps add assertions, queries, loops, and procedure
    calls. *)

open Bincaml_util.Common
open Lang
open Expr
open CCSexp

let src = Logs.Src.create "transforms.chc_infer"

module Logs = (val Logs.src_log src : Logs.LOG)
module SmtExpr = Bincaml_util.Smt.Expr

(** A CHC predicate: an uninterpreted [Bool]-valued function over a fixed list
    of typed parameters. The same parameter list is used for both declaration
    and application — order matters. *)
type predicate = { name : string; params : Var.t list }

(** A constrained Horn clause.
    - [vars] are the universally-quantified binders for the [forall];
    - [premises] are the conjuncts of the antecedent;
    - [head] is [Some sexp] for a rule and [None] for a query (head = false). *)
type clause = {
  vars : Var.t list;
  premises : Sexp.t list;
  head : Sexp.t option;
}

let var_sort v = fst (Expr_smt.SMTLib2.of_typ (Var.typ v))

let declare_predicate (p : predicate) : Sexp.t =
  SmtExpr.declare_fun p.name (List.map var_sort p.params) SmtExpr.t_bool

let apply_predicate (p : predicate) (args : Sexp.t list) : Sexp.t =
  SmtExpr.app_ p.name args

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

(** Predicates associated with a procedure. *)
type proc_predicates = {
  block_preds : predicate IDMap.t;
  enter : predicate;
  exit : predicate;
}

let predicate_name ~proc ~suffix = "p_" ^ proc ^ "_" ^ suffix

let block_predicate_name proc_id block_id =
  predicate_name ~proc:(ID.to_string proc_id) ~suffix:(ID.to_string block_id)

(** Compute predicate parameters for a block: the procedure's in-parameters
    followed by the live variables at block entry that aren't already
    in-parameters (preserving deterministic order). *)
let block_params ~in_params ~live_at =
  let in_set = VarSet.of_list in_params in
  let extra = VarSet.diff live_at in_set |> VarSet.to_list in
  in_params @ extra

let proc_predicates ~live (proc : Program.proc) : proc_predicates =
  let proc_id = Procedure.id proc in
  let pname = ID.to_string proc_id in
  let in_params =
    Procedure.formal_in_params proc |> StringMap.values |> Iter.to_list
  in
  let out_params =
    Procedure.formal_out_params proc |> StringMap.values |> Iter.to_list
  in
  let block_preds =
    Procedure.iter_blocks proc
    |> Iter.fold
         (fun acc (id, _) ->
           let live_at = live (Procedure.Vert.Begin id) in
           let params = block_params ~in_params ~live_at in
           IDMap.add id { name = block_predicate_name proc_id id; params } acc)
         IDMap.empty
  in
  let enter = { name = predicate_name ~proc:pname ~suffix:"enter"; params = in_params } in
  let exit =
    {
      name = predicate_name ~proc:pname ~suffix:"exit";
      params = in_params @ out_params;
    }
  in
  { block_preds; enter; exit }

(** Encoder state for a single block. Tracks the current variable renaming,
    the accumulated premises, and the set of binders introduced (for the
    eventual [forall]). *)
module Encoder = struct
  type t = {
    mutable delta : Var.t VarMap.t;
    mutable premises : Sexp.t list;
    mutable vars : Var.t list;
    mutable counter : int;
  }

  let create ~initial_vars =
    {
      delta = VarMap.empty;
      premises = [];
      vars = List.rev initial_vars;
      counter = 0;
    }

  let lookup t v =
    match VarMap.find_opt v t.delta with Some v' -> v' | None -> v

  let fresh t v =
    t.counter <- t.counter + 1;
    let nv =
      Var.copy ~name:(Var.name v ^ "!" ^ string_of_int t.counter) v
    in
    t.delta <- VarMap.add v nv t.delta;
    t.vars <- nv :: t.vars;
    nv

  let add_premise t p = t.premises <- p :: t.premises
  let premises t = List.rev t.premises
  let vars t = List.rev t.vars
end

(** Convert a [BasilExpr] to a sexp under the current variable renaming. *)
let encode_expr (enc : Encoder.t) (e : BasilExpr.t) : Sexp.t =
  let sub v = Some (BasilExpr.rvar (Encoder.lookup enc v)) in
  let renamed = BasilExpr.substitute sub e in
  Expr_smt.SMTLib2.of_bexpr renamed

(** Successors of a block, separated into block-local jumps and procedure
    return edges. *)
type block_succs = { blocks : ID.t list; returns : bool }

let block_successors (proc : Program.proc) (block_id : ID.t) : block_succs =
  match Procedure.graph proc with
  | None -> { blocks = []; returns = false }
  | Some g ->
      Procedure.G.fold_succ
        (fun v acc ->
          match v with
          | Procedure.Vert.Begin id -> { acc with blocks = id :: acc.blocks }
          | Return | Exit -> { acc with returns = true }
          | _ -> failwith "chc_infer: bad CFG structure")
        g
        (Procedure.Vert.End block_id)
        { blocks = []; returns = false }

(** Encode a single block. Returns one rule clause per outgoing edge (block
    successor or procedure return). *)
let encode_block (preds : proc_predicates) (proc : Program.proc)
    (block_id : ID.t) (block : Program.bloc) : clause list =
  let block_pred = IDMap.find block_id preds.block_preds in
  let enc = Encoder.create ~initial_vars:block_pred.params in
  let entry_args = List.map (fun v -> atom (Var.name v)) block_pred.params in
  Encoder.add_premise enc (apply_predicate block_pred entry_args);
  if not (List.is_empty block.phis) then
    failwith "chc_infer: phi nodes not supported yet (run dynamic-single-assignment first)";
  Vector.to_iter block.stmts
  |> Iter.iter (fun stmt ->
      match stmt with
      | Stmt.Instr_Assign assigns ->
          (* Evaluate RHSs in parallel before binding any new LHS — matches the
             simultaneous-assignment semantics of [Instr_Assign]. *)
          let rhss = List.map (fun (lhs, rhs) -> (lhs, encode_expr enc rhs)) assigns in
          List.iter
            (fun (lhs, rhs_sexp) ->
              let fresh = Encoder.fresh enc lhs in
              Encoder.add_premise enc
                (SmtExpr.eq (atom (Var.name fresh)) rhs_sexp))
            rhss
      | s ->
          failwith
            ("chc_infer: unsupported statement at Step 1: "
            ^ Stmt.show_stmt_basil s));
  let succs = block_successors proc block_id in
  let mk_head_args (pred : predicate) =
    List.map (fun v -> atom (Var.name (Encoder.lookup enc v))) pred.params
  in
  let block_clauses =
    List.map
      (fun succ_id ->
        let succ_pred = IDMap.find succ_id preds.block_preds in
        let head = apply_predicate succ_pred (mk_head_args succ_pred) in
        { vars = Encoder.vars enc; premises = Encoder.premises enc; head = Some head })
      succs.blocks
  in
  let return_clauses =
    if succs.returns then
      let head = apply_predicate preds.exit (mk_head_args preds.exit) in
      [ { vars = Encoder.vars enc; premises = Encoder.premises enc; head = Some head } ]
    else []
  in
  block_clauses @ return_clauses

let entry_block_of (proc : Program.proc) : ID.t option =
  Procedure.get_entry_block proc

(** Connect [enter⟨f⟩] to the entry block predicate. *)
let enter_to_entry_block (preds : proc_predicates) (proc : Program.proc) :
    clause list =
  match entry_block_of proc with
  | None -> []
  | Some entry_id ->
      let entry_pred = IDMap.find entry_id preds.block_preds in
      let enter_args =
        List.map (fun v -> atom (Var.name v)) preds.enter.params
      in
      let block_args =
        List.map (fun v -> atom (Var.name v)) entry_pred.params
      in
      [
        {
          vars = entry_pred.params;
          premises = [ apply_predicate preds.enter enter_args ];
          head = Some (apply_predicate entry_pred block_args);
        };
      ]

let encode_proc (proc : Program.proc) : proc_predicates * clause list =
  let live = Livevars.run proc in
  let preds = proc_predicates ~live proc in
  let connect = enter_to_entry_block preds proc in
  let block_clauses =
    Procedure.iter_blocks proc
    |> Iter.flat_map_l (fun (id, block) -> encode_block preds proc id block)
    |> Iter.to_list
  in
  (preds, connect @ block_clauses)

let all_predicates (preds : proc_predicates) : predicate list =
  preds.enter :: preds.exit
  :: (IDMap.values preds.block_preds |> Iter.to_list)

(** Encode the whole program: gather all predicates and clauses, then add an
    entry fact for [enter⟨main⟩] with unconstrained inputs. *)
let encode_program (prog : Program.t) : predicate list * clause list =
  let per_proc =
    Program.procs prog
    |> Iter.map (fun (_, proc) -> (proc, encode_proc proc))
    |> Iter.to_list
  in
  let preds =
    List.concat_map (fun (_, (p, _)) -> all_predicates p) per_proc
  in
  let clauses = List.concat_map (fun (_, (_, cs)) -> cs) per_proc in
  let entry_fact =
    match Program.entry_proc_opt prog with
    | None -> []
    | Some main_proc ->
        let _, (preds, _) =
          List.find
            (fun (p, _) -> ID.equal (Procedure.id p) (Procedure.id main_proc))
            per_proc
        in
        let args = List.map (fun v -> atom (Var.name v)) preds.enter.params in
        [
          {
            vars = preds.enter.params;
            premises = [];
            head = Some (apply_predicate preds.enter args);
          };
        ]
  in
  (preds, entry_fact @ clauses)

let emit_chc_problem (oc : out_channel) (preds : predicate list)
    (clauses : clause list) : unit =
  let p s =
    output_string oc (Sexp.to_string s);
    output_char oc '\n'
  in
  p (SmtExpr.set_logic "HORN");
  List.iter (fun pr -> p (declare_predicate pr)) preds;
  List.iter (fun c -> p (clause_to_sexp c)) clauses;
  p (list [ atom "check-sat" ])

let dump_to_file (prog : Program.t) (path : string) : unit =
  Logs.info (fun m -> m "Dumping CHC clauses to %s" path);
  let preds, clauses = encode_program prog in
  CCIO.with_out path (fun oc -> emit_chc_problem oc preds clauses)

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

(** Variables live just after the block's phi nodes, i.e. at the start of
    its regular statements. {!Livevars.run} gives us live-before-phis at
    [Begin id]; this walks the block's stmts backward starting from
    live-at-exit ([live (End id)]) and skips the phi step, yielding
    live-after-phis. This is the set we actually want for a block's CHC
    predicate parameters: it includes phi targets that are still used, and
    excludes phi sources that are only consumed by the phi. *)
let live_after_phis_of (block : Program.bloc) ~(live_at_exit : VarSet.t) :
    VarSet.t =
  Block.fold_backwards
    ~f:(fun init s -> Stmt.free_vars ~init s)
    ~phi:(fun acc _phis -> acc)
    ~init:live_at_exit
    block

(** Compute predicate parameters for a block: the procedure's in-parameters
    followed by [live-after-phis] (minus duplicates). *)
let block_params ~in_params ~live_after_phis =
  let in_set = VarSet.of_list in_params in
  let extras = VarSet.diff live_after_phis in_set |> VarSet.to_list in
  in_params @ extras

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
         (fun acc (id, block) ->
           let live_at_exit = live (Procedure.Vert.End id) in
           let live_after_phis = live_after_phis_of block ~live_at_exit in
           let params = block_params ~in_params ~live_after_phis in
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

(** Build a phi-substitution map for the edge from [from_id] into a block:
    each phi target maps to whichever rhs variable the source block
    contributes for this edge. Used when computing the head args of a
    transition clause — the successor's predicate has the phi target as a
    parameter, and we bind it to the source's value. *)
let phi_subst_for_edge ~(from_id : ID.t) (succ_block : Program.bloc) :
    Var.t VarMap.t =
  List.fold_left
    (fun acc (phi : Var.t Block.phi) ->
      match List.assoc_opt ~eq:ID.equal from_id phi.rhs with
      | Some src -> VarMap.add phi.lhs src acc
      | None -> acc)
    VarMap.empty
    succ_block.phis

(** Encode a single block. Returns one rule clause per outgoing edge (block
    successor or procedure return). Phi nodes in the successor are resolved
    by substituting each phi target with the appropriate rhs variable for
    this edge before doing the Δ lookup. *)
let encode_block (preds : proc_predicates) (proc : Program.proc)
    (block_id : ID.t) (block : Program.bloc) : clause list =
  let block_pred = IDMap.find block_id preds.block_preds in
  let enc = Encoder.create ~initial_vars:block_pred.params in
  let entry_args = List.map (fun v -> atom (Var.name v)) block_pred.params in
  Encoder.add_premise enc (apply_predicate block_pred entry_args);
  let queries = ref [] in
  let snapshot_query ~extra_premises =
    queries :=
      {
        vars = Encoder.vars enc;
        premises = Encoder.premises enc @ extra_premises;
        head = None;
      }
      :: !queries
  in
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
      | Stmt.Instr_Assert { body } ->
          let body_sexp = encode_expr enc body in
          snapshot_query ~extra_premises:[ SmtExpr.bool_not body_sexp ];
          Encoder.add_premise enc body_sexp
      | Stmt.Instr_Assume { body } ->
          Encoder.add_premise enc (encode_expr enc body)
      | Stmt.Instr_IntrinCall _ ->
          (* Treated as [assert false]: the current premise set must already
             be unsatisfiable for the intrinsic call to be unreachable. *)
          snapshot_query ~extra_premises:[]
      | s ->
          failwith
            ("chc_infer: unsupported statement: " ^ Stmt.show_stmt_basil s));
  let succs = block_successors proc block_id in
  let mk_head_args ~phi_subst (pred : predicate) =
    List.map
      (fun v ->
        let v' =
          match VarMap.find_opt v phi_subst with Some src -> src | None -> v
        in
        atom (Var.name (Encoder.lookup enc v')))
      pred.params
  in
  let block_clauses =
    List.map
      (fun succ_id ->
        let succ_pred = IDMap.find succ_id preds.block_preds in
        let succ_block =
          Procedure.get_block proc succ_id
          |> Option.get_exn_or "chc_infer: missing successor block"
        in
        let phi_subst = phi_subst_for_edge ~from_id:block_id succ_block in
        let head = apply_predicate succ_pred (mk_head_args ~phi_subst succ_pred) in
        { vars = Encoder.vars enc; premises = Encoder.premises enc; head = Some head })
      succs.blocks
  in
  let return_clauses =
    if succs.returns then
      let head =
        apply_predicate preds.exit
          (mk_head_args ~phi_subst:VarMap.empty preds.exit)
      in
      [ { vars = Encoder.vars enc; premises = Encoder.premises enc; head = Some head } ]
    else []
  in
  List.rev !queries @ block_clauses @ return_clauses

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

type solve_result = Sat | Unsat | Unknown

let show_solve_result = function
  | Sat -> "sat"
  | Unsat -> "unsat"
  | Unknown -> "unknown"

(** Send the encoded CHC system to Z3/Spacer. Reuses {!Bincaml_util.Smt.Solver}
    directly; the only HORN-specific bit is the [(set-logic HORN)] preamble. *)
let solve (preds : predicate list) (clauses : clause list) : solve_result =
  let module Solver = Bincaml_util.Smt.Solver in
  let s = Solver.create Bincaml_util.Smt.Config.z3 in
  Solver.set_logic s "HORN";
  List.iter
    (fun pr -> Solver.add_command s (declare_predicate pr))
    preds;
  List.iter
    (fun c -> Solver.add_command s (clause_to_sexp c))
    clauses;
  let result =
    match Solver.check s with
    | Sat -> Sat
    | Unsat -> Unsat
    | Unknown -> Unknown
  in
  Solver.stop s;
  result

let run_solver (prog : Program.t) : solve_result =
  let preds, clauses = encode_program prog in
  Logs.info (fun m ->
      m "Submitting %d predicates and %d clauses to solver"
        (List.length preds) (List.length clauses));
  let result = solve preds clauses in
  (match result with
  | Sat -> Logs.info (fun m -> m "Solver returned sat")
  | Unsat -> Logs.warn (fun m -> m "Solver returned unsat — assertions not provable")
  | Unknown -> Logs.warn (fun m -> m "Solver returned unknown"));
  result

(** Parse a model returned by Z3 [get-model] into a list of
    [(predicate_name, params, body)] triples. The model's parameter names
    typically don't match our input names — Z3 emits fresh [x!0], [x!1]
    placeholders — so the caller must map them back by position. *)
let parse_model (model : Sexp.t) : (string * (string * Sexp.t) list * Sexp.t) list =
  match model with
  | `List defs ->
      List.filter_map
        (fun def ->
          match def with
          | `List
              [
                `Atom "define-fun";
                `Atom name;
                `List params;
                _ret;
                body;
              ] ->
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

(** Preprocess a model body before decoding: expand [let] bindings and strip
    [(! ... :attrs ...)] annotation forms. Spacer's models wrap subterms in
    these and {!Lang.Expr_smt.SMTLib2.expr_of_smt} doesn't recognise them
    natively. *)
let preprocess_model_body (s : Sexp.t) : Sexp.t =
  let expanded = Bincaml_util.Smt.Expr.no_let s in
  let rec strip s =
    match s with
    | `List (`Atom "!" :: body :: _attrs) -> strip body
    | `List xs -> `List (List.map strip xs)
    | _ -> s
  in
  strip expanded

(** Decode a predicate body returned by the solver into a [BasilExpr.t],
    binding the model's positional parameters to the predicate's actual
    variables. Returns [None] if the body contains constructs
    {!Lang.Expr_smt.SMTLib2.expr_of_smt} can't decode (e.g. [ite] — see TODO
    in [expr_smt.ml]). *)
let extract_invariant (pred : predicate)
    (model_params : (string * Sexp.t) list) (body : Sexp.t) : BasilExpr.t option
    =
  if List.length model_params <> List.length pred.params then None
  else
    let vardefs =
      List.combine model_params pred.params
      |> List.fold_left
           (fun acc ((name, _sort), v) ->
             StringMap.add name (BasilExpr.rvar v) acc)
           StringMap.empty
    in
    Expr_smt.SMTLib2.expr_of_smt vardefs (preprocess_model_body body)

(** [true] when an expression is the boolean literal [true] — i.e. the
    solver gave us no useful information. We don't emit these as
    [requires]/[ensures]. *)
let is_trivially_true (e : BasilExpr.t) : bool =
  match BasilExpr.unfix e with
  | Constant { const = `Bool true; _ } -> true
  | _ -> false

(** Loop heads of a procedure — SCC component heads in the forward weak
    topological ordering. Every cycle in the CFG has exactly one of these as
    its entry point. *)
let loop_heads (proc : Program.proc) : ID.t list =
  Procedure.iter_blocks_topo_fwd_headers proc
  |> Iter.filter_map (fun (id, h, _b) ->
      match h with `Header -> Some id | `Vert -> None)
  |> Iter.to_list

(** Add [requires]/[ensures] to [proc] based on the solver's interpretations
    of its [enter]/[exit] predicates, and prepend [Instr_Assert] at each loop
    head with that block predicate's inferred invariant. [find_def] looks up
    a predicate by name in the parsed model. *)
let annotate_proc
    ~(find_def : string -> ((string * Sexp.t) list * Sexp.t) option)
    (proc : Program.proc) : Program.proc =
  let live = Livevars.run proc in
  let preds = proc_predicates ~live proc in
  let invariant_of (pred : predicate) : BasilExpr.t option =
    let open Option.Infix in
    let* params, body = find_def pred.name in
    let* inv = extract_invariant pred params body in
    if is_trivially_true inv then None else Some inv
  in
  (* Procedure-level annotations: requires from enter⟨f⟩, ensures from exit⟨f⟩. *)
  let spec = Procedure.specification proc in
  let spec =
    match invariant_of preds.enter with
    | Some inv -> { spec with requires = spec.requires @ [ inv ] }
    | None -> spec
  in
  let spec =
    match invariant_of preds.exit with
    | Some inv -> { spec with ensures = spec.ensures @ [ inv ] }
    | None -> spec
  in
  let proc = Procedure.set_specification proc spec in
  (* Loop invariants: prepend assert at each loop head. [Block.prepend_stmts]
     puts the new stmt at the start of [stmts], i.e. after any phi nodes —
     which is where the phi target is in scope. *)
  loop_heads proc
  |> List.fold_left
       (fun proc head_id ->
         let head_pred = IDMap.find head_id preds.block_preds in
         match invariant_of head_pred with
         | Some inv ->
             let block =
               Procedure.get_block proc head_id
               |> Option.get_exn_or "chc_infer: missing loop head block"
             in
             let block' =
               Block.prepend_stmts block [ Stmt.Instr_Assert { body = inv } ]
             in
             Procedure.update_block proc head_id block'
         | None -> proc)
       proc

(** Full pass: encode the program as CHCs, solve, and annotate each procedure
    with inferred [requires]/[ensures] when the solver returns sat. On unsat
    or unknown the program is returned unchanged. *)
let infer_invariants (prog : Program.t) : Program.t =
  let preds, clauses = encode_program prog in
  Logs.info (fun m ->
      m "Submitting %d predicates and %d clauses to solver"
        (List.length preds) (List.length clauses));
  let module Solver = Bincaml_util.Smt.Solver in
  let s = Solver.create Bincaml_util.Smt.Config.z3 in
  Solver.set_logic s "HORN";
  List.iter (fun pr -> Solver.add_command s (declare_predicate pr)) preds;
  List.iter (fun c -> Solver.add_command s (clause_to_sexp c)) clauses;
  let prog' =
    match Solver.check s with
    | Sat ->
        let model = Solver.get_model s in
        let defs = parse_model model in
        let find_def name =
          List.find_map
            (fun (n, params, body) ->
              if String.equal n name then Some (params, body) else None)
            defs
        in
        Logs.info (fun m ->
            m "Solver returned sat; extracted %d definitions"
              (List.length defs));
        Program.map_procedures (fun _ p -> annotate_proc ~find_def p) prog
    | Unsat ->
        Logs.warn (fun m ->
            m "Solver returned unsat — no invariants extracted");
        prog
    | Unknown ->
        Logs.warn (fun m ->
            m "Solver returned unknown — no invariants extracted");
        prog
  in
  Solver.stop s;
  prog'

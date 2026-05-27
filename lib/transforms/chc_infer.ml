(** CHC encoding of the IR.

    This module encodes a program as a system of constrained Horn clauses (CHCs)
    over quantifier-free bit vectors. See {!Lang.Expr_smt.SMTLib2} for
    expression-level encoding and {!Bincaml_util.Smt} for the SMT-LIB sexp
    helpers used below. *)

open Bincaml_util.Common
open Lang
open Expr
open CCSexp

let src = Logs.Src.create "transforms.chc_infer"

module Logs = (val Logs.src_log src : Logs.LOG)
module SmtExpr = Bincaml_util.Smt.Expr

type predicate = { name : string; params : Var.t list }
(** A CHC predicate: an uninterpreted [Bool]-valued function over a fixed list
    of typed parameters. The same parameter list is used for both declaration
    and application — order matters. *)

type clause = {
  vars : Var.t list;
  premises : Sexp.t list;
  head : Sexp.t option;
}
(** A constrained Horn clause.
    - [vars] are the universally-quantified binders for the [forall];
    - [premises] are the conjuncts of the antecedent;
    - [head] is [Some sexp] for a rule and [None] for a query (head = false). *)

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

type proc_predicates = {
  block_preds : predicate IDMap.t;
  enter : predicate;
  exit : predicate;
}
(** Predicates associated with a procedure. *)

let predicate_name ~proc ~suffix = "p_" ^ proc ^ "_" ^ suffix

let block_predicate_name proc_id block_id =
  predicate_name ~proc:(ID.to_string proc_id) ~suffix:(ID.to_string block_id)

(** Build the procedure-level [enter] and [exit] predicates. [enter] takes the
    formal in-params; [exit] takes in-params followed by out-params. *)
let enter_exit_predicates (proc : Program.proc) : predicate * predicate =
  let pname = ID.to_string (Procedure.id proc) in
  let in_params =
    Procedure.formal_in_params proc |> StringMap.values |> Iter.to_list
  in
  let out_params =
    Procedure.formal_out_params proc |> StringMap.values |> Iter.to_list
  in
  let enter =
    { name = predicate_name ~proc:pname ~suffix:"enter"; params = in_params }
  in
  let exit =
    {
      name = predicate_name ~proc:pname ~suffix:"exit";
      params = in_params @ out_params;
    }
  in
  (enter, exit)

(** A procedure has a spec if it declares any [requires] or [ensures] clauses.
*)
let has_spec (spec : (Var.t, BasilExpr.t) Procedure.proc_spec) : bool =
  (not (List.is_empty spec.requires)) || not (List.is_empty spec.ensures)

(** Default predicate for [use_spec]: any procedure with a non-trivial spec.
    When true at a call site, callers see only the callee's [requires] and
    [ensures] (substituted for the call) rather than connecting via the callee's
    [enter]/[exit] predicates. *)
let default_use_spec (p : Program.proc) : bool =
  has_spec (Procedure.specification p)

(** Variables live just after the block's phi nodes, i.e. at the start of its
    regular statements. {!Livevars.run} gives us live-before-phis at [Begin id];
    this walks the block's stmts backward starting from live-at-exit
    ([live (End id)]) and skips the phi step, yielding live-after-phis. This is
    the set we actually want for a block's CHC predicate parameters: it includes
    phi targets that are still used, and excludes phi sources that are only
    consumed by the phi. *)
let live_after_phis_of (block : Program.bloc) ~(live_at_exit : VarSet.t) :
    VarSet.t =
  Block.fold_backwards
    ~f:(fun init s -> Stmt.free_vars ~init s)
    ~phi:(fun acc _phis -> acc)
    ~init:live_at_exit block

(** Compute predicate parameters for a block: the procedure's in-parameters
    followed by [live-after-phis] (minus duplicates). *)
let block_params ~in_params ~live_after_phis =
  let in_set = VarSet.of_list in_params in
  let extras = VarSet.diff live_after_phis in_set |> VarSet.to_list in
  in_params @ extras

let proc_predicates ~live (proc : Program.proc) : proc_predicates =
  let proc_id = Procedure.id proc in
  let in_params =
    Procedure.formal_in_params proc |> StringMap.values |> Iter.to_list
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
  let enter, exit = enter_exit_predicates proc in
  { block_preds; enter; exit }

(** Encoder state for a single block. Tracks the current variable renaming, the
    accumulated premises, and the set of binders introduced (for the eventual
    [forall]). *)
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
    let nv = Var.copy ~name:(Var.name v ^ "!" ^ string_of_int t.counter) v in
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

type block_succs = { blocks : ID.t list; returns : bool }
(** Successors of a block, separated into block-local jumps and procedure return
    edges. *)

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
        g (Procedure.Vert.End block_id)
        { blocks = []; returns = false }

(** Build a phi-substitution map for the edge from [from_id] into a block: each
    phi target maps to whichever rhs variable the source block contributes for
    this edge. Used when computing the head args of a transition clause — the
    successor's predicate has the phi target as a parameter, and we bind it to
    the source's value. *)
let phi_subst_for_edge ~(from_id : ID.t) (succ_block : Program.bloc) :
    Var.t VarMap.t =
  List.fold_left
    (fun acc (phi : Var.t Block.phi) ->
      match List.assoc_opt ~eq:ID.equal from_id phi.rhs with
      | Some src -> VarMap.add phi.lhs src acc
      | None -> acc)
    VarMap.empty succ_block.phis

(** Encode a single block. Returns one rule clause per outgoing edge (block
    successor or procedure return). Phi nodes in the successor are resolved by
    substituting each phi target with the appropriate rhs variable for this edge
    before doing the Δ lookup.

    [use_spec] decides per-callee how the call site connects to the callee: when
    true, the caller assumes the callee's [ensures] post-call and does not refer
    to the callee's [enter]/[exit] predicates; when false, the caller emits a
    [C ⟹ enter⟨f⟩(args)] clause and uses [exit⟨f⟩] as a premise. Spec checking
    (precondition queries at the call site, postcondition queries on the body)
    is performed independently of [use_spec] whenever the callee has a
    [requires] or [ensures]. *)
let encode_block ~(use_spec : Program.proc -> bool) (prog : Program.t)
    (preds : proc_predicates) (proc : Program.proc) (block_id : ID.t)
    (block : Program.bloc) : clause list =
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
  let call_clauses = ref [] in
  let snapshot_call ~head =
    call_clauses :=
      {
        vars = Encoder.vars enc;
        premises = Encoder.premises enc;
        head = Some head;
      }
      :: !call_clauses
  in
  Vector.to_iter block.stmts
  |> Iter.iter (fun stmt ->
      match stmt with
      | Stmt.Instr_Assign { al; _ } ->
          (* Evaluate RHSs in parallel before binding any new LHS — matches the
             simultaneous-assignment semantics of [Instr_Assign]. *)
          let rhss =
            List.map (fun (lhs, rhs) -> (lhs, encode_expr enc rhs)) al
          in
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
      | Stmt.Instr_Call { lhs; procid; args } ->
          let callee =
            Program.proc_opt prog procid
            |> Option.get_exn_or
                 ("chc_infer: callee not found: " ^ ID.to_string procid)
          in
          let spec = Procedure.specification callee in
          (* Substitution from the callee's formal in-params to the
             caller's arg expressions. Used to instantiate the callee's
             spec at this specific call site. *)
          let in_subst =
            StringMap.fold
              (fun name v acc ->
                match StringMap.find_opt name args with
                | Some arg_e -> VarMap.add v arg_e acc
                | None ->
                    failwith
                      ("chc_infer: missing arg " ^ name ^ " at call to "
                     ^ ID.to_string procid))
              (Procedure.formal_in_params callee)
              VarMap.empty
          in
          let apply_in_subst e =
            BasilExpr.substitute (fun v -> VarMap.find_opt v in_subst) e
          in
          (* Always: emit precondition queries for the callee's [requires].
             Independent of [use_spec] — the caller is obligated to satisfy
             the callee's precondition either way. *)
          List.iter
            (fun req ->
              let req_sexp = encode_expr enc (apply_in_subst req) in
              snapshot_query ~extra_premises:[ SmtExpr.bool_not req_sexp ])
            spec.requires;
          if use_spec callee then begin
            (* Callers see only the spec: assume the postcondition post-call,
               don't refer to the callee's [enter]/[exit] predicates. *)
            (* Fresh-name returns, building the [callee out-param → caller fresh var]
               half of the postcondition substitution. *)
            let out_subst =
              StringMap.fold
                (fun name callee_out_v acc ->
                  match StringMap.find_opt name lhs with
                  | Some lhs_v ->
                      let fresh = Encoder.fresh enc lhs_v in
                      VarMap.add callee_out_v (BasilExpr.rvar fresh) acc
                  | None ->
                      failwith
                        ("chc_infer: missing return binding " ^ name
                       ^ " at call to " ^ ID.to_string procid))
                (Procedure.formal_out_params callee)
                VarMap.empty
            in
            let apply_full_subst e =
              BasilExpr.substitute
                (fun v ->
                  match VarMap.find_opt v in_subst with
                  | Some arg_e -> Some arg_e
                  | None -> VarMap.find_opt v out_subst)
                e
            in
            (* Assume each ensures clause (substituted) post-call. *)
            List.iter
              (fun ens ->
                Encoder.add_premise enc (encode_expr enc (apply_full_subst ens)))
              spec.ensures
          end
          else begin
            (* Full encoding: connect to the callee's enter/exit predicates. *)
            let enter_pred, exit_pred = enter_exit_predicates callee in
            (* Build arg sexps in the callee's formal-in-params order
               (alphabetical by name, matching [StringMap.values]). *)
            let arg_sexps =
              StringMap.bindings (Procedure.formal_in_params callee)
              |> List.map (fun (name, _) ->
                  match StringMap.find_opt name args with
                  | Some e -> encode_expr enc e
                  | None ->
                      failwith
                        ("chc_infer: missing arg " ^ name ^ " at call to "
                       ^ ID.to_string procid))
            in
            (* Emit C ⟹ enter⟨f⟩(args). Captures Encoder state before
               fresh-naming the returns. *)
            snapshot_call ~head:(apply_predicate enter_pred arg_sexps);
            (* Fresh-name each return, in the callee's formal-out-params order. *)
            let return_args =
              StringMap.bindings (Procedure.formal_out_params callee)
              |> List.map (fun (name, _) ->
                  match StringMap.find_opt name lhs with
                  | Some v -> atom (Var.name (Encoder.fresh enc v))
                  | None ->
                      failwith
                        ("chc_infer: missing return binding " ^ name
                       ^ " at call to " ^ ID.to_string procid))
            in
            (* Conjoin exit⟨f⟩(args, returns) to premises. *)
            Encoder.add_premise enc
              (apply_predicate exit_pred (arg_sexps @ return_args))
          end
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
        let head =
          apply_predicate succ_pred (mk_head_args ~phi_subst succ_pred)
        in
        {
          vars = Encoder.vars enc;
          premises = Encoder.premises enc;
          head = Some head;
        })
      succs.blocks
  in
  let return_clauses =
    if succs.returns then
      let head =
        apply_predicate preds.exit
          (mk_head_args ~phi_subst:VarMap.empty preds.exit)
      in
      [
        {
          vars = Encoder.vars enc;
          premises = Encoder.premises enc;
          head = Some head;
        };
      ]
    else []
  in
  List.rev !call_clauses @ List.rev !queries @ block_clauses @ return_clauses

(** Connect [enter⟨f⟩] to the entry block predicate. *)
let enter_to_entry_block (preds : proc_predicates) (proc : Program.proc) :
    clause list =
  match Procedure.get_entry_block proc with
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

let encode_proc ~(use_spec : Program.proc -> bool) (prog : Program.t)
    (proc : Program.proc) : proc_predicates * clause list =
  let live = Livevars.run proc in
  let preds = proc_predicates ~live proc in
  let connect = enter_to_entry_block preds proc in
  let block_clauses =
    Procedure.iter_blocks proc
    |> Iter.flat_map_l (fun (id, block) ->
        encode_block ~use_spec prog preds proc id block)
    |> Iter.to_list
  in
  (preds, connect @ block_clauses)

let all_predicates (preds : proc_predicates) : predicate list =
  preds.enter :: preds.exit :: (IDMap.values preds.block_preds |> Iter.to_list)

(** Entry fact for a procedure whose body needs to be reachable independently of
    any caller (main, or any procedure with [use_spec] = true):
    [⟦requires⟧ ⟹ enter⟨f⟩(in_params)]. The precondition defaults to [true] when
    [requires] is empty, yielding an unconditional entry fact. *)
let entry_fact_for (proc : Program.proc) (enter : predicate) : clause =
  let requires = (Procedure.specification proc).requires in
  let premises = List.map Expr_smt.SMTLib2.of_bexpr requires in
  let args = List.map (fun v -> atom (Var.name v)) enter.params in
  { vars = enter.params; premises; head = Some (apply_predicate enter args) }

(** One postcondition query per [ensures] clause:
    [exit⟨f⟩(in_params, out_params) ∧ ¬ensures ⟹ ⊥]. Asserts the body actually
    satisfies each user-declared postcondition. *)
let postcondition_queries (proc : Program.proc) (exit : predicate) : clause list
    =
  let ensures = (Procedure.specification proc).ensures in
  let args = List.map (fun v -> atom (Var.name v)) exit.params in
  let exit_app = apply_predicate exit args in
  List.map
    (fun e ->
      let body = Expr_smt.SMTLib2.of_bexpr e in
      {
        vars = exit.params;
        premises = [ exit_app; SmtExpr.bool_not body ];
        head = None;
      })
    ensures

(** Encode the whole program:

    - Body clauses for every procedure.
    - Entry fact [⟦requires⟧ ⟹ enter⟨f⟩] for procedures whose body needs to be
      reachable independently of any caller — main, and every procedure for
      which [use_spec] is true (call sites of those don't connect to
      [enter⟨f⟩]).
    - Postcondition queries [exit⟨f⟩ ∧ ¬ensures ⟹ ⊥] for *every* procedure with
      a non-empty [ensures], regardless of [use_spec]. Combined with the
      precondition queries emitted at every call site (also regardless of
      [use_spec]), this means spec checking is performed whenever a spec is
      present; [use_spec] only governs whether callers see the body via
      [enter]/[exit] predicates or via the spec. *)
let encode_program ?(use_spec = default_use_spec) (prog : Program.t) :
    predicate list * clause list =
  let main_id = Program.entry_proc_opt prog |> Option.map Procedure.id in
  let is_main p = Option.equal ID.equal main_id (Some (Procedure.id p)) in
  let needs_entry_fact p = is_main p || use_spec p in
  let per_proc =
    Program.procs prog
    |> Iter.map (fun (_, proc) -> (proc, encode_proc ~use_spec prog proc))
    |> Iter.to_list
  in
  let preds = List.concat_map (fun (_, (p, _)) -> all_predicates p) per_proc in
  let body_clauses = List.concat_map (fun (_, (_, cs)) -> cs) per_proc in
  let spec_clauses =
    List.concat_map
      (fun (proc, (proc_preds, _)) ->
        let entry =
          if needs_entry_fact proc then [ entry_fact_for proc proc_preds.enter ]
          else []
        in
        let post = postcondition_queries proc proc_preds.exit in
        entry @ post)
      per_proc
  in
  (preds, spec_clauses @ body_clauses)

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

(** Open a Z3 process configured for Spacer with model-preserving options.
    Spacer's slicing and eager-inlining transformations rewrite the input in
    ways that drop predicate parameters or fuse predicates together, which
    breaks our positional-parameter mapping when decoding the model. Turn both
    off so [(get-model)] returns predicates that line up with what we sent. *)
let open_spacer () =
  let module Solver = Bincaml_util.Smt.Solver in
  let s = Solver.create Bincaml_util.Smt.Config.z3 in
  Solver.set_option s ":fp.xform.slice" "false";
  Solver.set_option s ":fp.xform.inline_eager" "false";
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
let solve_and_get_model (preds : predicate list) (clauses : clause list) :
    solve_result * model_def list option =
  let module Solver = Bincaml_util.Smt.Solver in
  let s = open_spacer () in
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

(** Decode a predicate body returned by the solver into a [BasilExpr.t], binding
    the model's positional parameters to the predicate's actual variables.
    Returns [None] if the body contains constructs
    {!Lang.Expr_smt.SMTLib2.expr_of_smt} can't decode (e.g. [ite] — see TODO in
    [expr_smt.ml]). *)
let extract_invariant (pred : predicate) (model_params : (string * Sexp.t) list)
    (body : Sexp.t) : BasilExpr.t option =
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

(** [true] when an expression is the boolean literal [true] — i.e. the solver
    gave us no useful information. We don't emit these as annotations. *)
let is_trivially_true (e : BasilExpr.t) : bool =
  match BasilExpr.unfix e with
  | Constant { const = `Bool true; _ } -> true
  | _ -> false

(** Decode every model definition that names a known predicate into a
    [BasilExpr.t], keyed by predicate name. Skips definitions whose name we
    don't recognise (Spacer occasionally emits auxiliary functions), whose body
    can't be decoded by {!Expr_smt.SMTLib2.expr_of_smt}, or which decode to a
    trivially-true expression (uninformative). *)
let decode_model (preds : predicate list) (defs : model_def list) :
    BasilExpr.t StringMap.t =
  let pred_by_name =
    List.fold_left
      (fun acc (p : predicate) -> StringMap.add p.name p acc)
      StringMap.empty preds
  in
  List.fold_left
    (fun acc (name, params, body) ->
      match StringMap.find_opt name pred_by_name with
      | None -> acc
      | Some pred -> (
          match extract_invariant pred params body with
          | Some e when not (is_trivially_true e) -> StringMap.add name e acc
          | _ -> acc))
    StringMap.empty defs

(** Loop heads of a procedure — SCC component heads in the forward weak
    topological ordering. Every cycle in the CFG has exactly one of these as its
    entry point. *)
let loop_heads (proc : Program.proc) : ID.t list =
  Procedure.iter_blocks_topo_fwd_headers proc
  |> Iter.filter_map (fun (id, h, _b) ->
      match h with `Header -> Some id | `Vert -> None)
  |> Iter.to_list

(** Add [requires]/[ensures] to [proc] based on the solver's interpretations of
    its [enter]/[exit] predicates, and prepend [Instr_Assert] at each loop head
    with that block predicate's inferred invariant. [invs] maps each predicate
    name to its (already-decoded) inferred body — typically the output of
    {!decode_model}, or a per-predicate conjunction across multiple solver calls
    in per-query mode.

    Procedure-level annotation is skipped when [use_spec proc] is true: in that
    case the encoding has already constrained [enter⟨f⟩]/[exit⟨f⟩] to be
    consistent with the procedure's [requires]/[ensures] (via the
    precondition-gated entry fact and the postcondition queries), so Spacer's
    interpretations are essentially restatements of the spec in whatever shape
    it prefers. Attaching them would duplicate the spec. Loop-head invariants
    are still attached either way. *)
let annotate_proc ~(use_spec : Program.proc -> bool)
    ~(invs : BasilExpr.t StringMap.t) (proc : Program.proc) : Program.proc =
  let live = Livevars.run proc in
  let preds = proc_predicates ~live proc in
  let invariant_of (pred : predicate) : BasilExpr.t option =
    StringMap.find_opt pred.name invs
  in
  let proc =
    if use_spec proc then proc
    else
      (* Procedure-level annotations: [requires] from [enter⟨f⟩], [ensures]
         from [exit⟨f⟩]. Skipped above when [use_spec proc] is true. *)
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
      Procedure.set_specification proc spec
  in
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
               Block.prepend_stmts block
                 [ Stmt.Instr_Assert { attrib = Attrib.empty; body = inv } ]
             in
             Procedure.update_block proc head_id block'
         | None -> proc)
       proc

(** Apply per-predicate inferred invariants across every procedure in [prog]. *)
let annotate_program ~(use_spec : Program.proc -> bool)
    ~(invs : BasilExpr.t StringMap.t) (prog : Program.t) : Program.t =
  Program.map_procedures (fun _ p -> annotate_proc ~use_spec ~invs p) prog

(** Full pass: encode the program as CHCs, solve, and annotate each procedure
    with inferred [requires]/[ensures] when the solver returns sat. On unsat or
    unknown the program is returned unchanged. *)
let infer_invariants (prog : Program.t) : Program.t =
  let use_spec = default_use_spec in
  let preds, clauses = encode_program ~use_spec prog in
  Logs.info (fun m ->
      m "Submitting %d predicates and %d clauses to solver" (List.length preds)
        (List.length clauses));
  match solve_and_get_model preds clauses with
  | Sat, Some defs ->
      Logs.info (fun m ->
          m "Solver returned sat; extracted %d definitions" (List.length defs));
      let invs = decode_model preds defs in
      annotate_program ~use_spec ~invs prog
  | Unsat, _ ->
      Logs.warn (fun m -> m "Solver returned unsat — no invariants extracted");
      prog
  | Unknown, _ | Sat, None ->
      Logs.warn (fun m -> m "Solver returned unknown — no invariants extracted");
      prog

(** Per-query variant: one solver call per query clause, conjoining the inferred
    invariants across successful calls. See {!infer_invariants} for the
    single-call version. *)
let infer_invariants_per_query (prog : Program.t) : Program.t =
  let use_spec = default_use_spec in
  let preds, clauses = encode_program ~use_spec prog in
  let normal, queries =
    List.partition (fun c -> Option.is_some c.head) clauses
  in
  let n_queries = List.length queries in
  Logs.info (fun m ->
      m "Per-query mode: %d predicates, %d normal clauses, %d queries"
        (List.length preds) (List.length normal) n_queries);
  let accum = ref StringMap.empty in
  let successes = ref 0 in
  List.iteri
    (fun i q ->
      let idx = i + 1 in
      match solve_and_get_model preds (normal @ [ q ]) with
      | Sat, Some defs ->
          incr successes;
          let invs = decode_model preds defs in
          Logs.info (fun m ->
              m "Query %d/%d: sat (%d definitions, %d non-trivial)" idx
                n_queries (List.length defs) (StringMap.cardinal invs));
          StringMap.iter
            (fun name e ->
              let existing =
                StringMap.find_opt name !accum |> Option.value ~default:[]
              in
              accum := StringMap.add name (e :: existing) !accum)
            invs
      | Unsat, _ ->
          Logs.warn (fun m ->
              m "Query %d/%d: unsat — assertion not provable" idx n_queries)
      | Unknown, _ | Sat, None ->
          Logs.warn (fun m -> m "Query %d/%d: unknown" idx n_queries))
    queries;
  let conjoined =
    StringMap.map
      (fun es ->
        match es with
        | [] -> BasilExpr.boolconst true
        | [ e ] -> e
        | _ -> BasilExpr.applyintrin ~op:`AND es)
      !accum
  in
  Logs.info (fun m ->
      m
        "Per-query mode: %d/%d queries succeeded; extracted invariants for %d \
         predicates"
        !successes n_queries
        (StringMap.cardinal conjoined));
  annotate_program ~use_spec ~invs:conjoined prog

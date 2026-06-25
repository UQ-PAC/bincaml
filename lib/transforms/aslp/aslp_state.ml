open Lang
open Common

(** {1 Types} *)

open struct
  type stmt =
    ((Var.t, Var.t, Expr.BasilExpr.t) Stmt.t[@printer Stmt.pp_stmt_basil])
  [@@deriving show]

  type 'a list_for_printing = 'a list [@@deriving show]
end

type nonrec stmt = stmt
(** A statement within the Bincaml AST. This is just a type alias. *)

type aslp_block = {
  assume : Expr.BasilExpr.t;
  stmts : stmt CCVector.vector;
      [@printer Format.map CCVector.to_list (pp_list_for_printing pp_stmt)]
  pc_assign : Expr.BasilExpr.t option;
      (** The unique assignment to [PC] which is in effect at the end of this
          block, if [PC] has been assigned. *)
}
[@@deriving show]
(** An ASLp lifter block is a list of statements. Each block is optionally
    guarded by an assume statement. *)

type aslp_diamond = aslp_block Diamond.diamond [@@deriving show]
(** Offline lifter state representing a control flow diamond. See
    {!module-Diamond} for more details of the structure.

    This is used to represent the {b final} output of the offline IBI. However,
    it is not the representation which is used {i during} lifting. For the
    "in-progress" representation, see {!diamond}. *)

type aslp_ids = { local_id : unit -> string }
(** Generators for unique IDs used by the offline lifter.

    The {!aslp_ids} is stateful and the same {!aslp_ids} should be used by all
    opcodes within the same procedure, to ensure that IDs are unique.*)

type lifter_state = {
  address : Bitvec.t;
      (** Byte address of the instruction currently being lifted. *)
  diamond : aslp_block Diamond.diamond_zipper;
      (** Lifter state representing a control flow diamond while it is being
          built. *)
  generator : aslp_ids; [@opaque]  (** Generators for ID names. *)
  names : (string, string) Hashtbl.t;
      (** Map of ASLp local variable names to the "ID-ified" names produced for
          Bincaml.

          Local variables names are scoped to each {i instruction}. *)
}
[@@deriving show]
(** Intermediate offline lifter state while {i within} one particular
    instruction.

    The offline IBI ({!Bincaml_ibi}) operates by mutating a reference to this
    state. *)

(** {1 Utility functions} *)

let empty_block ~assume () =
  { stmts = CCVector.create (); assume; pc_assign = None }

(** Constructs a new empty {!lifter_state}.

    Callers should consider whether they wish to re-use an existing [generator]
    value by passing it explicitly.

    The initial {!address} is set to a garbage value. Users should remember to
    use {!Bincaml_ibi.IBI.bincaml_set_address} before starting any lifting. *)
let empty_lifter_state ~generator () =
  let tt = Expr.BasilExpr.boolconst true in
  {
    diamond = Diamond.empty_zipper (empty_block ~assume:tt ());
    names = Hashtbl.create 16;
    address = Bitvec.of_int ~size:64 0xbadbadbad000;
    generator;
  }

(** Construct a new {!aslp_ids} with no pre-existing IDs.

    Be careful! You should use {!aslp_ids_from_generators} if you will use the
    lifted statements within an existing Bincaml IR. *)
let empty_aslp_ids () =
  let local_id = Fix.Gensym.make () %> Printf.sprintf "var_%d" in
  { local_id }

(** {2 ID-generating functions} *)

(** Construct a {!aslp_ids} with the given {!Bincaml_util.ID.generator}s as
    underlying generators.

    This will ensure that ASLp's local variable and block names do not clash
    with existing names. *)
let aslp_ids_from_generators ~local_ids =
  let local_id = ID.fresh ~name:"var" local_ids %> ID.name in
  { local_id }

(** {1 State manipulation functions} *)

(** Appends the given statement to the given block.

    Sets {!pc_assign} if the statement is an assignment to {!Aslp_lexpr.PC}. It
    is assumed that [PC] is assigned at most once on any straight-line path.
    Raises an exception if the statement is an assignment to [PC] and
    {!pc_assign} is already set. *)
let add_stmt_to_block blk ~stmt =
  let pc_assign =
    match stmt with
    | Stmt.Instr_Assign { al = assigns; _ } ->
        assigns |> List.Assoc.get ~eq:Var.equal Aslp_lexpr.pc_var
    | _ -> None
  in
  match (pc_assign, blk.pc_assign) with
  | Some _, Some _ ->
      failwith
        "add_stmt_to_block: attempt to add PC assignment but pc_assign is \
         already set"
  | Some _, None ->
      CCVector.push blk.stmts stmt;
      { blk with pc_assign }
  | None, _ ->
      CCVector.push blk.stmts stmt;
      blk

let add_stmt_to_active stmt (lifter_state : lifter_state) =
  let diamond = lifter_state.diamond in
  let diamond = diamond |> Diamond.modify (add_stmt_to_block ~stmt) in
  { lifter_state with diamond }

(** {1 Program counter functions} *)

(** Ensures that the focused block has a PC assignment. If it already has
    {!pc_assign}, no changes are made. *)
let ensure_pc_assigned ~address =
  Diamond.modify (function
    | { pc_assign = None } as block ->
        let incremented =
          Expr.BasilExpr.bvconst Bitvec.(add address (of_int ~size:64 4))
        and ff = Expr.BasilExpr.boolconst false in

        let bt = Aslp_lexpr.branchtaken_var and pc = Aslp_lexpr.pc_var in
        let al = [ (bt, ff); (pc, incremented) ] in
        block
        |> add_stmt_to_block
             ~stmt:(Stmt.Instr_Assign { attrib = Attrib.empty; al })
    | block -> block)

(** Ensures that the preceding left and right blocks agree on their {!pc_assign}
    property. If [PC] is assigned in only one of the blocks, a default increment
    statement will be added to the other block and {!pc_assign} will be
    propagated to the join. Otherwise, nothing changes.

    This function should be called with blocks in this structure, with the focus
    on join:
    {v
    left  right
      \    /
       join
    v}
    It should be called after [left] and [right] have been populated with
    statements.

    This is used to maintain the invariant that at every control flow point, the
    [PC] variable is either assigned on all paths or assigned on no paths (from
    the beginning of the instruction). *)
let ensure_pc_consistency ~address state =
  let before_skel = Diamond.skeleton state in
  let left = state |> Diamond.move_in_to `L |> Result.get_ok
  and right = state |> Diamond.move_in_to `R |> Result.get_ok in

  (* Make PCs of left and right agree. Resulting state is at left or right. *)
  let state =
    match ((Diamond.focus left).pc_assign, (Diamond.focus right).pc_assign) with
    | Some _, None -> right |> ensure_pc_assigned ~address
    | None, Some _ -> left |> ensure_pc_assigned ~address
    | None, None | Some _, Some _ -> left (* arbitrary *)
  in

  (* Move back to join point and re-compute left/right with updated state. *)
  let state = state |> Diamond.move_out_of |> Result.get_ok in
  let left = state |> Diamond.move_in_to `L |> Result.get_ok
  and right = state |> Diamond.move_in_to `R |> Result.get_ok in
  assert (Diamond.(equal_skeleton before_skel (skeleton state)));

  (* Propagate PC to join point using ITE. *)
  match (Diamond.focus left, Diamond.focus right) with
  | { pc_assign = None }, { pc_assign = None } -> state
  | { pc_assign = Some lpc; assume }, { pc_assign = Some rpc } ->
      let ite = Expr.BasilExpr.(ifthenelse assume lpc rpc) in
      state |> Diamond.modify (fun b -> { b with pc_assign = Some ite })
  | _ -> failwith "invariant violation: pcs should agree at this point"

(** {1 Formatters} *)

let show_aslp_block = show_aslp_block
let pp_aslp_block = pp_aslp_block
let show_aslp_diamond = show_aslp_diamond
let pp_aslp_diamond = pp_aslp_diamond
let show_lifter_state = show_lifter_state
let pp_lifter_state = pp_lifter_state

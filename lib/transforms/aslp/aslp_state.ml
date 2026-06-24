open Lang
open Common

(** {1 Types} *)

open struct
  type stmt =
    ((Var.t, Var.t, Expr.BasilExpr.t) Stmt.t[@printer Stmt.pp_stmt_basil])
  [@@deriving show]
end

type nonrec stmt = stmt
(** A statement within the Bincaml AST. This is just a type alias. *)

open struct
  type 'a list_for_printing = 'a list [@@deriving show]
end

type aslp_block = {
  assume : Expr.BasilExpr.t option;
  stmts : stmt CCVector.vector;
      [@printer Format.map CCVector.to_list (pp_list_for_printing pp_stmt)]
  pc_assign : Expr.BasilExpr.t option;
      (** The unique assignment to [PC] which is in effect at the end of this
          block, if [PC] has been assigned. *)
}
[@@deriving show]
(** An ASLp lifter block is a list of statements. Each block is optionally
    guarded by an assume statement. *)

type aslp_diamond = {
  address : Bitvec.t;
      (** Byte address of the instruction described by this diamond. *)
  blocks : aslp_block StringMap.t;
      [@printer StringMap.pp CCString.pp pp_aslp_block]
  entry : string;
      (** Key of the entry block. The entry block is required to have no
          {!assume} condition. *)
  exit : string;
      (** Key of the exit block. The exit block is required to have no {!succs}.
      *)
}
[@@deriving show]
(** Offline lifter state representing a control flow diamond starting at
    [entry], then flowing through zero or more other blocks, then arriving at
    [exit].

    Alone, this is used to represent the lifter state {i between} instructions.
    Or, it forms a part of {!lifter_state} for {i within}-instruction state. *)

type aslp_ids = { block_id : unit -> string; local_id : unit -> string }
(** Generators for unique IDs used by the offline lifter.

    The {!aslp_ids} is stateful and the same {!aslp_ids} should be used by all
    opcodes within the same procedure, to ensure that IDs are unique.*)

type lifter_state = {
  active : string;
      (** Active block where new runtime statements will be appended. *)
  address : Bitvec.t;
      (** Byte address of the instruction currently being lifted. *)
  diamond : aslp_block Diamond.diamond_zipper;
      (** Lifter state representing a control flow diamond. *)
  generator : aslp_ids; [@opaque]  (** Generators for ID names. *)
  names : (string, string) Hashtbl.t;
      (** Map of ASLp local variable names to the "ID-ified" names produced for
          Bincaml.

          Local variables names are scoped to each {i instruction}. *)
}
[@@deriving show]
(** Intermediate offline lifter state while {i within} one particular
    instruction.

    This records the {!active} block to support ITE branching within an
    instruction. The offline IBI ({!Bincaml_ibi}) operates by mutating a
    reference to this state. *)

(** {1 Utility functions} *)

let empty_block () =
  let stmts = CCVector.create () in
  { assume = None; stmts; pc_assign = None }

(** Constructs a new empty {!lifter_state}.

    Callers should consider whether they wish to re-use an existing [generator]
    value by passing it explicitly. *)
let empty_lifter_state ~generator () =
  let entry = generator.block_id () in
  {
    active = entry;
    diamond = Diamond.empty_zipper (empty_block ());
    names = Hashtbl.create 16;
    address = Bitvec.of_int ~size:64 0xbadbadbad000;
    generator;
  }

(** Construct a new {!aslp_ids} with no pre-existing IDs.

    Be careful! You should use {!aslp_ids_from_generators} if you will use the
    lifted statements within an existing Bincaml IR. *)
let empty_aslp_ids () =
  let block_id = Fix.Gensym.make () %> Printf.sprintf "block_%d"
  and local_id = Fix.Gensym.make () %> Printf.sprintf "var_%d" in
  { block_id; local_id }

(** {2 ID-generating functions} *)

(** Construct a {!aslp_ids} with the given {!Bincaml_util.ID.generator}s as
    underlying generators.

    This will ensure that ASLp's local variable and block names do not clash
    with existing names. *)
let aslp_ids_from_generators ~block_ids ~local_ids =
  let block_id = ID.fresh ~name:"block" block_ids %> ID.name
  and local_id = ID.fresh ~name:"var" local_ids %> ID.name in
  { block_id; local_id }

(** {1 State manipulation functions} *)

let get_block aslp_state ~name =
  StringMap.find_opt name aslp_state.blocks
  |> Option.get_exn_or "get_block: block not found"

let modify_block aslp_state ~name ~f =
  let blocks =
    StringMap.update name
      (function
        | Some blk -> Some (f blk)
        | _ -> failwith "modify_block: block not found")
      aslp_state.blocks
  in
  { aslp_state with blocks }

(** Appends the given statement to the given block.

    Sets {!pc_assign} if the statement is an assignment to {!Aslp_lexpr.PC}. It
    is assumed that [PC] is assigned at most once on any straight-line path.
    Raises an exception if the statement is an assignment to [PC] and
    {!pc_assign} is already set. *)
let add_stmt_to_block blk ~stmt =
  let pc_assign =
    match stmt with
    | Stmt.Instr_Assign { al = assigns; _ } ->
        assigns |> List.Assoc.get ~eq:Var.equal Aslp_lexpr.(to_var PC)
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

(** Adds a new goto edge from [source] to [target]. If [source] was the exit
    block, sets {!exit} to be [target]. If [source] {!pc_assign}, this is
    propagated to [target]. *)
let add_goto aslp_state ~source ~target =
  let exit =
    if String.equal source aslp_state.exit then target else aslp_state.exit
  in
  let src_pc_assign =
    aslp_state |> get_block ~name:source |> fun x -> x.pc_assign
  in
  aslp_state
  |> modify_block ~name:source ~f:(fun b -> b)
  |> modify_block ~name:target ~f:(fun b ->
      if Option.is_some src_pc_assign then { b with pc_assign = src_pc_assign }
      else b)
  |> fun s -> { s with exit }

(** Creates a new block with the given name as a successor of the given [pred].
    If [pred] was the exit block, sets {!exit} to be the new block. *)
let add_block ?assume aslp_state ~pred ~name =
  let new_block = { (empty_block ()) with assume } in
  let blocks = aslp_state.blocks |> StringMap.add name new_block in
  { aslp_state with blocks } |> add_goto ~source:pred ~target:name

(** Sequentially joins the given {!aslp_diamond}s such that [first] is succeeded
    by [second]. *)
let append_aslp_states first second =
  let f key = function
    | `Both _ -> failwith "overlapping aslp_state block names"
    | `Left a | `Right a -> Some a
  in
  let blocks = StringMap.merge_safe ~f first.blocks second.blocks in
  { first with blocks } |> add_goto ~source:first.exit ~target:second.entry

(** {1 Program counter functions} *)

(** Ensures that the given block ID has a PC assignment. If it already
    {!pc_assign}, no changes are made. *)
let ensure_pc_assigned ~address =
  Diamond.modify (function
    | { pc_assign = None } as block ->
        let incremented =
          Expr.BasilExpr.bvconst Bitvec.(add address (of_int ~size:64 4))
        and boolfalse = Expr.BasilExpr.boolconst false in

        let al =
          Aslp_lexpr.[ (branchtaken_var, boolfalse); (pc_var, incremented) ]
        in
        block
        |> add_stmt_to_block
             ~stmt:(Stmt.Instr_Assign { attrib = Attrib.empty; al })
    | block -> block)

(** Ensures that the left and right blocks agree on their {!pc_assign} property.
    If [PC] is assigned in only one of the blocks, a default increment statement
    will be added to the other block and {!pc_assign} will be propagated to
    [join]. Otherwise, nothing changes.

    This function should be called with blocks in this structure:
    {v
    left  right
      \    /
       join
    v}
    It should be called after [left] and [right] have been populated with
    statements, before moving to [join].

    This is used to maintain the invariant that at every control flow point, the
    [PC] variable is either assigned on all paths or assigned on no paths (from
    the beginning of the instruction). *)
let ensure_pc_consistency ~address ~join:state =
  let left =
    state |> Diamond.move_adjacent `L |> Result.get_ok |> Diamond.move_to_end
  and right =
    state |> Diamond.move_adjacent `R |> Result.get_ok |> Diamond.move_to_end
  in

  let state =
    match (Diamond.root left, Diamond.root right) with
    | { pc_assign = None }, { pc_assign = None } -> state
    | { pc_assign = Some pc_assign }, { pc_assign = None } ->
        ensure_pc_assigned ~address right
    | { pc_assign = None }, { pc_assign = Some pc_assign } ->
        ensure_pc_assigned ~address left
    | ( { pc_assign = Some lpc; assume = lassume },
        { pc_assign = Some rpc; assume = rassume } ) ->
        state
  in

  match (Diamond.root left, Diamond.root right) with
  | { pc_assign = None }, { pc_assign = None } -> state
  | { pc_assign = Some lpc; assume = lassume }, { pc_assign = Some rpc } ->
      let lassume =
        Option.get_exn_or
          "invariant violation: branch expected to have assume set" lassume
      in
      let ite = Expr.BasilExpr.(ifthenelse lassume lpc rpc) in
      state |> Diamond.modify (fun b -> { b with pc_assign = Some ite })
  | _ -> failwith "invariant violation: pcs should agree at this point"

(** {1 Formatters} *)

let show_aslp_block = show_aslp_block
let pp_aslp_block = pp_aslp_block
let show_aslp_diamond = show_aslp_diamond
let pp_aslp_diamond = pp_aslp_diamond
let show_lifter_state = show_lifter_state
let pp_lifter_state = pp_lifter_state

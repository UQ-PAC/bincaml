open Lang
open Common

(** {1 Types} *)

type stmt =
  ((Var.t, Var.t, Expr.BasilExpr.t) Stmt.t[@printer Stmt.pp_stmt_basil])
[@@deriving show]
(** A statement within the Bincaml AST. This is just a type alias. *)

open struct
  type stmt_list_for_printing = stmt list [@@deriving show]
end

type aslp_block = {
  assume : Expr.BasilExpr.t option;
  stmts : stmt CCVector.vector;
      [@printer Format.map CCVector.to_list pp_stmt_list_for_printing]
  succs : string list;
  has_pc_assign : bool;
      (** Whether, upon reaching the end of this block, it is guaranteed that
          [PC] will have been assigned to on all control-flow paths. *)
}
[@@deriving show]
(** An ASLp lifter block is a list of statements followed by a non-deterministic
    goto to a number of successors. Each block is optionally guarded by an
    assume statement. *)

type aslp_diamond = {
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
  state : aslp_diamond;
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
  {
    assume = None;
    stmts = CCVector.create ();
    succs = [];
    has_pc_assign = false;
  }

let empty_aslp_state ~entry ~exit () =
  let blocks =
    StringMap.of_list [ (entry, { (empty_block ()) with succs = [] }) ]
  in
  { blocks; entry; exit = entry }

(** Constructs a new empty {!lifter_state}.

    Callers should consider whether they wish to re-use an existing [generator]
    value by passing it explicitly. *)
let empty_lifter_state ~generator () =
  let entry = generator.block_id () in
  let exit = generator.block_id () in
  {
    active = entry;
    state = empty_aslp_state ~entry ~exit ();
    names = Hashtbl.create 16;
    generator;
  }

(** Construct a new {!aslp_ids} with no pre-existing IDs.

    Be careful! You should use {!aslp_ids_from_generators} if you will use the
    lifted statements within an existing Bincaml IR. *)
let empty_aslp_ids () =
  let block_id = Printf.sprintf "block_%d" % Fix.Gensym.make ()
  and local_id = Printf.sprintf "var_%d" % Fix.Gensym.make () in
  { block_id; local_id }

(** {2 ID-generating functions} *)

(** Construct a {!aslp_ids} with the given {!Bincaml_util.ID.generator}s as
    underlying generators.

    This will ensure that ASLp's local variable and block names do not clash
    with existing names. *)
let aslp_ids_from_generators ~block_ids ~local_ids =
  let block_id = ID.name % ID.fresh ~name:"block" block_ids
  and local_id = ID.name % ID.fresh ~name:"var" local_ids in
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

let add_stmt_to_block blk ~stmt =
  let has_pc_assign =
    match stmt with
    | Stmt.Instr_Assign _ ->
        Stmt.iter_assigned stmt |> Iter.mem ~eq:Var.equal Aslp_lexpr.(to_var PC)
    | _ -> false
  in

  CCVector.push blk.stmts stmt;
  if has_pc_assign then { blk with has_pc_assign } else blk

let add_stmt_to_active stmt (lifter_state : lifter_state) =
  let state =
    lifter_state.state
    |> modify_block ~name:lifter_state.active ~f:(add_stmt_to_block ~stmt)
  in
  { lifter_state with state }

(** Ensures that the given block ID has a PC assignment on all paths. If it
    already {!has_pc_assign}, no changes are made. *)
let ensure_pc_assigned ~name state =
  state
  |> modify_block ~name ~f:(function
    | { has_pc_assign = false } as block ->
        let pc = Aslp_lexpr.to_var PC
        and branchtaken = Aslp_lexpr.to_var BranchTaken in
        let incremented =
          Expr.BasilExpr.(
            applyintrin ~op:`BVADD [ rvar pc; bv_of_int ~size:32 4 ])
        and boolfalse = Expr.BasilExpr.boolconst false in
        let al = [ (pc, incremented); (branchtaken, boolfalse) ] in
        block
        |> add_stmt_to_block
             ~stmt:(Stmt.Instr_Assign { attrib = Attrib.empty; al })
    | block -> block)

(** Adds a new goto edge from [source] to [target]. If [source] was the exit
    block, sets {!exit} to be [target]. *)
let add_goto aslp_state ~source ~target =
  let exit =
    if String.equal source aslp_state.exit then target else aslp_state.exit
  in
  modify_block aslp_state ~name:source ~f:(fun b ->
      { b with succs = target :: b.succs })
  |> fun s -> { s with exit }

(** Creates a new block with the given name as a successor of the given [pred].
    If [pred] was the exit block, sets {!exit} to be the new block. *)
let add_block aslp_state ~pred ~name =
  let blocks = aslp_state.blocks |> StringMap.add name (empty_block ()) in
  { aslp_state with blocks } |> add_goto ~source:pred ~target:name

let append_aslp_states first second =
  let f key = function
    | `Both _ -> failwith "overlapping aslp_state block names"
    | `Left a | `Right a -> Some a
  in
  let blocks = StringMap.merge_safe ~f first.blocks second.blocks in
  { first with blocks } |> add_goto ~source:first.exit ~target:second.entry

(** {1 Formatters} *)

let show_aslp_block = show_aslp_block
let pp_aslp_block = pp_aslp_block
let show_aslp_diamond = show_aslp_diamond
let pp_aslp_diamond = pp_aslp_diamond
let show_lifter_state = show_lifter_state
let pp_lifter_state = pp_lifter_state

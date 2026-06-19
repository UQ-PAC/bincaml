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
}
[@@deriving show]
(** An ASLp lifter block is a list of statements followed by a non-deterministic
    goto to a number of successors. Each block is optionally guarded by an
    assume statement. *)

type aslp_state = {
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

type aslp_ids = { block_ids : unit -> int; local_ids : unit -> int }
(** Generators for unique IDs used by the offline lifter.

    The {!aslp_ids} is stateful and the same {!aslp_ids} should be used by all
    opcodes within the same procedure, to ensure that IDs are unique.*)

type lifter_state = {
  active : string;
      (** Active block where new runtime statements will be appended. *)
  state : aslp_state;  (** Lifter state representing a control flow diamond. *)
  generator : aslp_ids; [@opaque]  (** Generators for ID numbers. *)
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

let empty_aslp_state ~entry ~exit () =
  let blocks =
    StringMap.of_list
      [
        (entry, { assume = None; stmts = CCVector.create (); succs = [ exit ] });
        (exit, { assume = None; stmts = CCVector.create (); succs = [] });
      ]
  in
  { blocks; entry; exit }

let gen_block_id gens = Printf.sprintf "block_%d" @@ gens.block_ids ()
let gen_local_id gens = Printf.sprintf "var_%d" @@ gens.local_ids ()

(** Constructs a new empty {!lifter_state}.

    Callers should consider whether they wish to re-use an existing [generator]
    value by passing it explicitly. *)
let empty_lifter_state ~generator () =
  let entry = gen_block_id generator in
  let exit = gen_block_id generator in
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
  { block_ids = Fix.Gensym.make (); local_ids = Fix.Gensym.make () }

(** {2 ID-generating functions} *)

(** Construct a {!aslp_ids} with the given {!Bincaml_util.ID.generator}s as
    underlying generators.

    This will ensure that ASLp's local variable and block names do not clash
    with existing names. *)
let aslp_ids_from_generators ~block_ids ~local_ids =
  let block_ids = ID.index % ID.fresh block_ids in
  let local_ids = ID.index % ID.fresh local_ids in
  { block_ids; local_ids }

let gen_block_id = gen_block_id
let gen_local_id = gen_local_id

(** {1 State manipulation functions} *)

let add_stmt_to_block state key stmt =
  let blocks =
    StringMap.update key
      (function
        | Some blk ->
            CCVector.push blk.stmts stmt;
            Some blk
        | None -> failwith "add_stmt: block not found")
      state.blocks
  in
  { state with blocks }

let add_stmt_to_active (lifter_state : lifter_state) stmt =
  let state = add_stmt_to_block lifter_state.state lifter_state.active stmt in
  { lifter_state with state }

let add_goto aslp_state ~source ~target =
  let blocks =
    StringMap.update source
      (function
        | Some blk -> Some { blk with succs = target :: blk.succs }
        | _ -> failwith "add_goto: block not found")
      aslp_state.blocks
  in
  { aslp_state with blocks }

let append_aslp_states first second =
  let f key = function
    | `Both _ -> failwith "overlapping aslp_state block names"
    | `Left a | `Right a -> Some a
  in
  let blocks = StringMap.merge_safe ~f first.blocks second.blocks in
  add_goto
    { blocks; entry = first.entry; exit = second.exit }
    ~source:first.exit ~target:second.entry

(** {1 Formatters} *)

let show_aslp_block = show_aslp_block
let pp_aslp_block = pp_aslp_block
let show_aslp_state = show_aslp_state
let pp_aslp_state = pp_aslp_state
let show_lifter_state = show_lifter_state
let pp_lifter_state = pp_lifter_state

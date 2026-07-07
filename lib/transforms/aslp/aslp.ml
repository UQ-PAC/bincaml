(** ASLp-based instruction lifter implementation.

    Transforms {!Lang.Stmt.Intrinsic.Aarch64Eval} intrinsic calls into Bincaml
    IR constructs which perform the effect of the instruction. Instruction
    semantics are provided by the offline ASLp lifter, and this transform also
    fixes the control flow and forwards branch conditions. *)

open Lang
open Common
module Diamond = Diamond
module Diamond_zipper = Diamond_zipper
module Aslp_lexpr = Aslp_lexpr
module Aslp_state = Aslp_state
module Diamond_ibi = Diamond_ibi
module Bincaml_ibi = Bincaml_ibi

(** {1 Basic lifting functions} *)

(** Lifts one opcode. Each lifted opcode will increment the [PC]. This can be
    through a default [PC += 4] assignment, an explicit [PC] assignment, or
    both.

    Requires and ensures that the IBI is in the "reset" state. *)
let lift_opcode (module I : Bincaml_ibi.IBI) ~address opcode =
  Fun.protect ~finally:I.reset_ir (fun () ->
      I.bincaml_set_address address;
      OfflineASL_pc.Offline.f_A64_decoder (module I) opcode address;
      I.get_ir ())

(** Lifts a sequence of opcodes.

    Requires and ensures that the IBI is in the "reset" state. *)
let lift_code_block (module I : Bincaml_ibi.IBI) ~address =
  List.mapi (fun i op ->
      let address = Bitvec.add (Bitvec.create ~size:64 Z.(~$4 * ~$i)) address in
      lift_opcode (module I) ~address op)

module Internal = struct
  (** [take_drop_while_map f xs] returns the longest prefix of [xs] where the
      elements yield [Some] when mapped through [f].

      These [Some] values are returned in the first tuple element. Upon reaching
      a value which yields [None], that value and values after it are returned
      in the second tuple element. *)
  let rec take_drop_while_map f = function
    | [] -> ([], [])
    | hd :: rest as all -> (
        match f hd with
        | Some x -> (
            match take_drop_while_map f rest with a, b -> (x :: a, b))
        | None -> ([], all))
end

(** {1 Interfacing with Bincaml IR} *)

let address_attrib_key = ".address"
and error_attrib_key = ".error"

(** Extracts the opcode and attribute from the given Bincaml statement, if it is
    an {!Lang.Stmt.Intrinsic.Aarch64Eval} intrinsic call. Otherwise, returns
    [None].

    Raises an exception if an {!Lang.Stmt.Intrinsic.Aarch64Eval} intrinsic call
    has an unexpected structure. *)
let aarch64_intrin_of_stmt ?(include_errors = false) :
    Program.stmt -> (Bitvec.t * Attrib.attrib_map) option = function
  | Stmt.Instr_IntrinCall { attrib; lhs; name = Aarch64Eval; args }
    when include_errors || not (StringMap.mem error_attrib_key attrib) -> (
      match (lhs, args) with
      | [], [ E (Constant { const = `Bitvector op }) ] -> Some (op, attrib)
      | _ -> failwith "unexpected Aarch64Eval intrin structure")
  | _ -> None

let stmt_of_aarch64_intrin : Bitvec.t * Attrib.attrib_map -> Program.stmt =
 fun (opcode, attrib) ->
  let args = [ Expr.BasilExpr.bvconst opcode ] in
  Stmt.Instr_IntrinCall { attrib; lhs = []; name = Aarch64Eval; args }

(** Extracts Aarch64 intrinsics from the given list of statements, partitioning
    the statements into [(before, aarch64_ops, after)].

    If there are no Aarch64 statements, this still succeeds but will return [[]]
    in the second and third elements. *)
let partition_aarch64_stmts stmts =
  let before, stmts =
    List.take_drop_while (Option.is_none % aarch64_intrin_of_stmt) stmts
  in
  let intrins, after =
    Internal.take_drop_while_map aarch64_intrin_of_stmt stmts
  in
  (before, intrins, after)

(** Extracts the next Aarch64 intrinsic from the given list of statements,
    returning [Some (before, (intrin, attrib), after)] if there exists an
    intrinsic. *)
let next_aarch64_stmt stmts =
  let intrin = CCList.find_map aarch64_intrin_of_stmt stmts in
  match intrin with
  | None -> None
  | Some intrin ->
      let before, after =
        CCList.take_drop_while (Option.is_none % aarch64_intrin_of_stmt) stmts
      in
      let after = CCList.drop 1 after in
      Some (before, intrin, after)

(** Returns the Bincaml global variable representing heap memory. *)
let aarch64_mem_of_prog prog =
  Program.get_decl_by_name "$mem" prog |> function
  | Some (Variable { binding }) -> binding
  | _ -> failwith "aarch64_mem_of_prog: no $mem found"

(** Returns the byte address in the given attribute map, if present. *)
let address_of_attrib attrib =
  match StringMap.find_opt address_attrib_key attrib with
  | Some (`CamlInt x) -> Bitvec.of_int ~size:64 x
  | Some (`Integer x) -> Bitvec.create ~size:64 x
  | Some (`Bitvector x) -> x
  | _ ->
      failwith "address_of_attrib: requires .address with int or bitvec value"

(** {1 Transforming Bincaml IR} *)

(** Inserts one {!Aslp_state.aslp_diamond} into the given procedure, including
    nested subdiamonds and adding any blocks as needed. Returns
    [(first_id, last_id, proc)].

    This includes {i internal} control flow, but does not connect to anything
    outside of this {!Aslp_state.aslp_diamond}. The caller should set up
    external control flow using the returned IDs. *)
let insert_one_diamond ~proc dia =
  let next_id _ = ID.fresh ~name:"%block" (Procedure.block_ids proc) () in
  let with_ids = dia |> Diamond.enumerate_with_successors next_id in

  let proc =
    with_ids |> Diamond.iter_backwards
    |> Iter.fold
         (fun proc (id, successors, st) ->
           let assume = Aslp_state.assume_of_aslp_block st in
           let stmts = Option.to_list assume @ CCVector.to_list st.stmts in
           Procedure.add_block proc id ~stmts ~successors ())
         proc
  and (first, _, _), (last, _, _) = Diamond.(first with_ids, last with_ids) in

  (first, last, proc)

(** Transforms the next {!Lang.Stmt.Intrinsic.Aarch64Eval} intrinsic within the
    given block ID within the given procedure.

    The first intrinsic appearing within the block's statement list, if any,
    will be transformed and [Some] will be returned with the updated procedure.
    If no intrinsic exists, [None] will be returned.

    If an error occurs while lifting through ASLp, an error attribute will be
    attached to the intrinsic (and it is excluded from subsequent calls). *)
let transform_one_stmt (module I : Bincaml_ibi.IBI) ~proc bid =
  let b = Procedure.get_block proc bid |> Option.get_exn_or "block not found" in

  match next_aarch64_stmt (Vector.to_list b.stmts) with
  | None -> None
  | Some (before, (opcode, intr_attrib), after) -> (
      let address = address_of_attrib intr_attrib in
      match
        CCResult.guard_str (fun () -> lift_opcode (module I) ~address opcode)
      with
      | Ok diamond ->
          let aslp_first, aslp_last, proc = insert_one_diamond ~proc diamond in

          let proc =
            proc
            |> Procedure.modify_block' ~id:bid ~f:(fun b ->
                { b with stmts = Vector.of_list before })
            |> Procedure.modify_block' ~id:aslp_first ~f:(fun b ->
                { b with attrib = intr_attrib })
            |> Procedure.modify_block' ~id:aslp_last ~f:(fun b ->
                Block.fmap_stmts_copy (Fun.flip CCVector.append_list after) b)
            |> Procedure.transplant_outgoing_edges ~from:bid ~to_:aslp_last
            |> Procedure.add_goto ~from:bid ~targets:[ aslp_first ]
          in
          Some (proc, aslp_last)
      | Error err ->
          let attrib =
            StringMap.add error_attrib_key (`String err) intr_attrib
          in
          let intrin_stmt = stmt_of_aarch64_intrin (opcode, attrib) in
          let stmts = Vector.of_list (before @ (intrin_stmt :: after)) in
          Some (Procedure.modify_block proc bid (fun b -> { b with stmts }), bid)
      )

(** Transforms the {!Lang.Stmt.Intrinsic.Aarch64Eval} intrinsics within the
    given block ID within the given procedure.

    Inserts control-flow edges between successive instructions within the block,
    and emits an assertion for the ITE expression representing the final [PC]
    value. *)
let rec transform_block (module I : Bincaml_ibi.IBI) ~proc bid =
  match transform_one_stmt (module I) ~proc bid with
  | Some (proc, bid) -> transform_block (module I) ~proc bid
  | None -> proc

(** Transforms the {!Lang.Stmt.Intrinsic.Aarch64Eval} intrinsics of all blocks
    within the given procedure. *)
let transform_procedure ~memory proc =
  let module I =
    (val Bincaml_ibi.from_generator
           ~memory:(fun () -> memory)
           (Aslp_state.aslp_ids_from_generators
              ~local_ids:(Procedure.local_ids proc)))
  in
  Procedure.iter_blocks proc
  |> Iter.fold (fun proc (bid, _) -> transform_block (module I) ~proc bid) proc

(** Adds all architectural variable declarations to the given program. *)
let add_aarch64_global_declarations prog =
  Lazy.force Aslp_lexpr.global_vars
  |> List.fold_left
       (fun prog var ->
         let decl =
           Program.Variable
             { binding = var; attrib = Attrib.empty; classification = None }
         in
         Program.add_decl prog decl)
       prog

(** Transforms the {!Lang.Stmt.Intrinsic.Aarch64Eval} intrinsics of all
    procedures within the given program.

    Also inserts global variable declarations for the architectural variables,
    if not already present. *)
let transform_program prog =
  let memory = aarch64_mem_of_prog prog in

  prog
  |> Program.map_procedures (fun _ proc -> transform_procedure ~memory proc)
  |> add_aarch64_global_declarations

(** Mini-pass to insert [.address] on each {!Lang.Stmt.Intrinsic.Aarch64Eval}
    intrinsic statement, computed from block-level [.address] attributes. This
    can be useful in tests to avoid needing to type every address.

    Existing statement [.address] attributes, if they exist, are unchanged and
    do not interact with this transform. If a block has no [.address] attribute,
    no changes are made to that block. *)
let apply_stmt_addresses_from_block (block : _ Block.t) =
  let apply_one address stmt =
    match aarch64_intrin_of_stmt ~include_errors:true stmt with
    | Some (opcode, attrib) when not (StringMap.mem address_attrib_key attrib)
      ->
        let attrib =
          StringMap.add address_attrib_key (`Bitvector address) attrib
        and args = [ Expr.BasilExpr.bvconst opcode ] in
        ( Bitvec.(add address (of_int ~size:64 4)),
          Stmt.Instr_IntrinCall { attrib; lhs = []; name = Aarch64Eval; args }
        )
    | _ -> (address, stmt)
  in

  match address_of_attrib block.attrib with
  | block_address ->
      let stmts =
        block.stmts |> CCVector.to_iter
        |> Iter.fold_map apply_one block_address
        |> CCVector.of_iter |> CCVector.freeze
      in
      { block with stmts }
  | exception _ -> block

(** TODO look into annotating attributes onto "landmark" points like memory
    access. *)

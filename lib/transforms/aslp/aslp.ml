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

module Util = struct
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

(** {1 Extracting data from Bincaml IR} *)

(** Extracts the opcode and attribute from the given Bincaml statement, if it is
    an {!Lang.Stmt.Intrinsic.Aarch64Eval} intrinsic call. Otherwise, returns
    [None].

    Raises an exception if an {!Lang.Stmt.Intrinsic.Aarch64Eval} intrinsic call
    has an unexpected structure. *)
let aarch64_intrin_of_stmt :
    Program.stmt -> (Bitvec.t * Attrib.attrib_map) option = function
  | Stmt.Instr_IntrinCall { attrib; lhs; name = Aarch64Eval; args } -> (
      match (lhs, args) with
      | [], [ E (Constant { const = `Bitvector op }) ] -> Some (op, attrib)
      | _ -> failwith "unexpected Aarch64Eval intrin structure")
  | _ -> None

(** Extracts Aarch64 intrinsics from the given list of statements, partitioning
    the statements into [(before, aarch64_ops, after)].

    If there are no Aarch64 statements, this still succeeds but will return [[]]
    in the second and third elements. *)
let partition_aarch64_stmts stmts =
  let before, stmts =
    List.take_drop_while (Option.is_none % aarch64_intrin_of_stmt) stmts
  in
  let intrins, after = Util.take_drop_while_map aarch64_intrin_of_stmt stmts in
  (before, intrins, after)

(** Returns the Bincaml global variable representing heap memory. *)
let aarch64_mem_of_prog prog =
  Program.get_decl_by_name "$mem" prog |> function
  | Some (Variable { binding }) -> binding
  | _ -> failwith "aarch64_mem_of_prog: no $mem found"

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
         (fun proc (id, successors, lifter_block) ->
           let { Aslp_state.stmts; assume } = lifter_block in
           let stmts =
             Stmt.Instr_Assume
               { attrib = Attrib.empty; body = assume; branch = true }
             :: CCVector.to_list stmts
           in
           Procedure.add_block proc id ~stmts ~successors ())
         proc
  and (first, _, _), (last, _, _) = Diamond.(first with_ids, last with_ids) in

  (first, last, proc)

(** Transforms the {!Lang.Stmt.Intrinsic.Aarch64Eval} intrinsics within the
    given block ID within the given procedure.

    Inserts control-flow edges between successive instructions within the block,
    and emits an assertion for the ITE expression representing the final [PC]
    value. *)
let transform_block (module I : Bincaml_ibi.IBI) ~proc ~address bid =
  let b = Procedure.get_block proc bid |> Option.get_exn_or "block not found" in
  let before, intrins, after =
    partition_aarch64_stmts (Vector.to_list b.stmts)
  in
  let opcodes, attribs = List.split intrins in

  (* Clear statements from first block aside from those before the intrinsics. *)
  let proc =
    Procedure.modify_block proc bid (fun x ->
        { x with stmts = Vector.of_list before })
  in

  (* Record then clear the successors of the first block. *)
  let block_successors = Procedure.get_blocks_succ proc (End bid) in
  let proc = Procedure.replace_block_succs proc bid [] in

  (* Lift each opcode, then join between each lifted opcode with gotos. *)
  let diamonds = lift_code_block (module I) ~address opcodes in
  let last, proc =
    List.fold_left2
      (fun (prev_last, proc) dia attrib ->
        let first, last, proc = insert_one_diamond ~proc dia in
        ( last,
          Procedure.modify_block proc first (fun x -> { x with attrib })
          |> Procedure.add_goto ~from:prev_last ~targets:[ first ] ))
      (bid, proc) diamonds attribs
  in

  (* Insert a PC assign to the merge point, if there was a branch. *)
  let after =
    match List.last_opt diamonds with
    | Some (Diamond { value = { pc_assign } }) ->
        let pc_assign =
          Option.get_exn_or "pc_assign unset at last in block?" pc_assign
        in
        let al = [ (Aslp_lexpr.pc_var, pc_assign) ] in
        Stmt.Instr_Assign { attrib = Attrib.empty; al } :: after
    | Some (Leaf _) | None -> after
  in

  (* Append back things which were previously after the Aarch64 intrinsic calls,
     but append them to the *last* block. Finally, fix up successors. *)
  let proc =
    Procedure.modify_block proc last (fun b -> Block.append_stmts b after)
  in
  Procedure.replace_block_succs proc last block_successors

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
  |> Iter.fold
       (fun proc (bid, _) ->
         (* TODO get address from somewhere. change gtirb to add to attribute. *)
         let address = Bitvec.of_int ~size:64 0xb00000 in
         transform_block (module I) ~proc ~address bid)
       proc

(** TODO look into global variable declarations *)

(** TODO look into annotating attributes onto "landmark" points like memory
    access. *)

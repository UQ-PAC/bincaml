(** Entry-point for ASLp-based instruction lifter transformation.

    Transforms {!Lang.Stmt.Intrinsic.Aarch64Eval} intrinsic calls into Bincaml
    IR constructs which perform the effect of the instruction. Instruction
    semantics are provided by the offline ASLp lifter, and this transform also
    fixes the control flow and forwards branch conditions. *)

open Lang
open Common
module Aslp_state = Aslp_state
module Aslp_lexpr = Aslp_lexpr
module Diamond = Diamond
module Diamond_ibi = Diamond_ibi
module Bincaml_ibi = Bincaml_ibi

(** Requires and ensures that the IBI is in the "reset" state. *)
let lift_opcode (module I : Bincaml_ibi.IBI) ~address opcode =
  Fun.protect ~finally:I.reset_ir (fun () ->
      I.bincaml_set_address address;
      OfflineASL_pc.Offline.f_A64_decoder (module I) opcode address;
      I.get_ir ())

(** Requires and ensures that the IBI is in the "reset" state. *)
let lift_empty (module I : Bincaml_ibi.IBI) ~address () =
  Fun.protect ~finally:I.reset_ir (fun () ->
      I.bincaml_set_address address;
      I.get_ir ())

(** Requires and ensures that the IBI is in the "reset" state. *)
let lift_code_block (module I : Bincaml_ibi.IBI) ~address opcodes =
  opcodes
  |> Iter.mapi (fun i op ->
      let address = Bitvec.add (Bitvec.create ~size:64 Z.(~$4 * ~$i)) address in
      lift_opcode (module I) ~address op)
  |> Iter.to_list

let aarch64_intrin_of_stmt :
    Program.stmt -> (Bitvec.t * Attrib.attrib_map) option = function
  | Stmt.Instr_IntrinCall { attrib; lhs; name = Aarch64Eval; args } -> (
      match (lhs, args) with
      | [], [ E (Constant { const = `Bitvector op }) ] -> Some (op, attrib)
      | _ -> failwith "unexpected Aarch64Eval intrin structure")
  | _ -> None

let rec take_drop_while_map f = function
  | [] -> ([], [])
  | hd :: rest as all -> (
      match f hd with
      | Some x -> ( match take_drop_while_map f rest with a, b -> (x :: a, b))
      | None -> ([], all))

let insert_one_diamond proc dia =
  let with_ids =
    dia
    |> Diamond.enumerate_with_successors (fun _ ->
        ID.fresh ~name:"%block" (Procedure.block_ids proc) ())
  in
  let proc =
    with_ids |> Diamond.iter_backwards
    |> Iter.fold
         (fun proc (id, successors, lifter_block) ->
           let stmts = CCVector.to_list lifter_block.Aslp_state.stmts in
           Procedure.add_block proc id ~stmts ~successors ())
         proc
  in
  let entry, _, _ = Diamond.first with_ids
  and exit, _, _ = Diamond.last with_ids in
  (entry, exit, proc)

let transform_block ~memory ~proc id (b : Program.bloc) =
  let local_ids = Procedure.local_ids proc in
  let stmts = b.stmts |> Vector.to_list in
  let before, stmts =
    List.take_drop_while (Option.is_none % aarch64_intrin_of_stmt) stmts
  in
  let intrins, after = take_drop_while_map aarch64_intrin_of_stmt stmts in
  let opcodes, attribs = List.split intrins in
  (* TODO: hoist this opcode filtering. split up stmt partition into its own funtcion. *)
  match opcodes with
  | [] -> proc
  | _ ->
      let proc =
        Procedure.modify_block proc id (fun x ->
            { x with stmts = Vector.of_list before })
      in

      (* TODO get address from somewhere. change gtirb to add to attribute. *)
      let address = Bitvec.of_int ~size:64 0xb00000 in

      let module I =
        (val Bincaml_ibi.from_generator ~memory
               (Aslp_state.aslp_ids_from_generators ~local_ids))
      in
      let diamonds =
        lift_code_block (module I) ~address Iter.(of_list opcodes)
      in

      let block_successors = Procedure.get_blocks_succ proc (End id) in
      let proc = Procedure.replace_block_succs proc id [] in

      let diamond_exit, proc =
        List.fold_left2
          (fun (prev_tail, proc) dia attrib ->
            let entry, exit, proc = insert_one_diamond proc dia in
            ( exit,
              Procedure.modify_block proc entry (fun x -> { x with attrib })
              |> Procedure.add_goto ~from:prev_tail ~targets:[ entry ] ))
          (id, proc) diamonds attribs
      in

      let proc =
        Procedure.modify_block proc diamond_exit (fun b ->
            Block.append_stmts b after)
      in
      Procedure.replace_block_succs proc diamond_exit block_successors

(** TODO look into global variable declarations *)

(** TODO look into annotating attributes onto "landmark" points like memory
    access. *)

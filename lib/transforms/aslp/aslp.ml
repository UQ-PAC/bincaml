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

(** {1 Interfacing with Bincaml IR} *)

(** Extracts the opcode, address, and attribute from the given Bincaml
    statement, if it is an {!Lang.Stmt.Intrinsic.Aarch64Eval} intrinsic call.
    Otherwise, returns [None].

    Raises an exception if an {!Lang.Stmt.Intrinsic.Aarch64Eval} intrinsic call
    has an unexpected structure. *)
let aarch64_intrin_of_stmt ?default_address :
    Program.stmt -> (Bitvec.t * Bitvec.t * Attrib.attrib_map) option = function
  | Stmt.Instr_IntrinCall { attrib; lhs; name = Aarch64Eval; args } -> (
      let args =
        match (args, default_address) with
        | [ x ], Some default -> [ x; Expr.BasilExpr.bvconst default ]
        | x, _ -> x
      in
      match (lhs, List.map Expr.BasilExpr.unfix args) with
      | ( [],
          [
            Constant { const = `Bitvector op };
            Constant { const = `Bitvector address };
          ] )
        when Bitvec.size op = 32 && Bitvec.size address = 64 ->
          Some (op, address, attrib)
      | _ ->
          failwith
            "invalid Aarch64Eval args. expected @_aarch64_eval(op:bv32, \
             addr:bv64)")
  | _ -> None

(** Inverse of {!aarch64_intrin_of_stmt}. *)
let stmt_of_aarch64_intrin ?error :
    Bitvec.t * Bitvec.t * Attrib.attrib_map -> Program.stmt =
 fun (opcode, address, attrib) ->
  let attrib = Option.fold (Fun.flip (StringMap.add ".error")) attrib error in
  let args = Expr.BasilExpr.[ bvconst opcode; bvconst address ] in
  Stmt.Instr_IntrinCall { attrib; lhs = []; name = Aarch64Eval; args }

(** {1 Main Bincaml IR transformation functions} *)

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
           let stmts = Aslp_state.stmts_of_aslp_block st in
           Procedure.add_block proc id ~stmts ~successors ())
         proc
  and (first, _, _), (last, _, _) = Diamond.(first with_ids, last with_ids) in

  (first, last, proc)

(** Maps the given statement through the ASLp lifter transform, if applicable.
    If the statement is a {!Lang.Stmt.Intrinsic.Aarch64Eval} intrinsic, then
    returns [Left] with the lifted blocks. Otherwise, or if an error occurs,
    returns [Right] with the original statement.

    If an error occurs while lifting through ASLp, an error attribute will be
    attached to the intrinsic (and it is excluded from subsequent calls). *)
let map_one_stmt (module I : Bincaml_ibi.IBI) ~proc stmt :
    _ Procedure.mapped_stmt =
  match aarch64_intrin_of_stmt stmt with
  | None -> `Stmts [ stmt ]
  | Some (opcode, address, attrib) -> (
      match lift_opcode (module I) ~address opcode with
      | diamond ->
          let aslp_first, aslp_last, proc = insert_one_diamond ~proc diamond in
          `Graph
            ( aslp_first,
              aslp_last,
              Procedure.modify_block proc aslp_first (fun b ->
                  { b with attrib }) )
      | exception error ->
          let error = `String (Printexc.to_string error) in
          let intrin = (opcode, address, attrib) in
          `Stmts [ stmt_of_aarch64_intrin ~error intrin ])

(** Transforms the {!Lang.Stmt.Intrinsic.Aarch64Eval} intrinsics within the
    given block ID within the given procedure.

    Inserts control-flow edges between successive instructions within the block,
    and emits an assertion for the ITE expression representing the final [PC]
    value. *)
let transform_block (module I : Bincaml_ibi.IBI) ~proc bid =
  let f = map_one_stmt (module I) in
  let _, _, proc = Procedure.cfg_concatmap_block bid ~f proc in
  proc

(** Transforms the {!Lang.Stmt.Intrinsic.Aarch64Eval} intrinsics of all blocks
    within the given procedure. *)
let transform_procedure proc =
  let module I = (val Bincaml_ibi.from_bincaml_procedure proc) in
  Procedure.iter_blocks proc
  |> Iter.fold (fun proc (bid, _) -> transform_block (module I) ~proc bid) proc

(** Adds architectural variable declarations to the given program. By default,
    includes only those variables which are used. *)
let add_aarch64_global_declarations ?(include_unused = false) prog =
  let include_predicate =
    if include_unused then Fun.const true
    else
      Fun.flip VarSet.mem
        (Program.referenced_vars_of_prog prog |> VarSet.of_iter)
  in

  Lazy.force Aslp_lexpr.globals
  |> List.to_iter
  |> Iter.filter (Aslp_lexpr.to_var %> include_predicate)
  |> Iter.map (Fun.tap (Aslp_lexpr.check_decl_type prog))
  |> Iter.fold
       (fun prog v ->
         let binding = Aslp_lexpr.to_var v in
         let attrib = Attrib.empty and classification = None in
         Program.add_decl ~at:`Prepend prog
           (Program.Variable { binding; attrib; classification }))
       prog

(** Transforms the {!Lang.Stmt.Intrinsic.Aarch64Eval} intrinsics of all
    procedures within the given program.

    Inserts global variable declarations for the architectural variables and
    memory, if used and not already present. Finally, re-computes the "modifies"
    sets of the procedures. *)
let transform_program prog =
  prog
  |> Program.map_procedures (fun _ -> transform_procedure)
  |> add_aarch64_global_declarations
  |> Spec_modifies.set_modsets ~add_only:false

(** {1 Supplementary transformation} *)

(** Micro-pass to insert addresses on each {!Lang.Stmt.Intrinsic.Aarch64Eval}
    intrinsic statement, computed from block-level [.address] attributes. This
    can be useful in tests to avoid needing to type every address.

    Existing statement addresses, if they exist, are unchanged and do not
    interact with this transform. If a block has no [.address] attribute, no
    changes are made to that block. *)
let apply_stmt_addresses_from_block (block : _ Block.t) =
  let default_address = Bitvec.ones ~size:64 in

  let apply_one address stmt =
    let address' = Bitvec.(add address (of_int ~size:64 4)) in
    match aarch64_intrin_of_stmt ~default_address stmt with
    | Some (opcode, a, attr) when Bitvec.equal a default_address ->
        (address', stmt_of_aarch64_intrin (opcode, address, attr))
    | Some _ -> (address', stmt) (* increment address *)
    | None -> (address, stmt)
  in

  (match StringMap.find_opt ".address" block.attrib with
    | Some (`CamlInt x) -> Some (Bitvec.of_int ~size:64 x)
    | Some (`Integer x) -> Some (Bitvec.create ~size:64 x)
    | Some (`Bitvector x) -> Some x
    | _ -> None)
  |> function
  | Some block_address ->
      let stmts =
        block.stmts |> CCVector.to_iter
        |> Iter.fold_map apply_one block_address
        |> CCVector.of_iter |> CCVector.freeze
      in
      { block with stmts }
  | None -> block

(** TODO look into annotating attributes onto "landmark" points like memory
    access. *)

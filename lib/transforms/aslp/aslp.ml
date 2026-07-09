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

and error_attrib_key = ".error"

(** Extracts the opcode, address, and attribute from the given Bincaml
    statement, if it is an {!Lang.Stmt.Intrinsic.Aarch64Eval} intrinsic call.
    Otherwise, returns [None].

    Raises an exception if an {!Lang.Stmt.Intrinsic.Aarch64Eval} intrinsic call
    has an unexpected structure. *)
let aarch64_intrin_of_stmt ?(include_failed = false) ?default_address :
    Program.stmt -> (Bitvec.t * Bitvec.t * Attrib.attrib_map) option = function
  | Stmt.Instr_IntrinCall { attrib; lhs; name = Aarch64Eval; args }
    when include_failed || not (StringMap.mem error_attrib_key attrib) -> (
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

(** Extracts the next Aarch64 intrinsic from the given list of statements,
    returning [Some (before, intrin, after)] if there exists an intrinsic. *)
let next_aarch64_stmt stmts =
  let open CCOption.Infix in
  let before, rest =
    CCList.take_drop_while (Option.is_none % aarch64_intrin_of_stmt) stmts
  in
  let* hd, after = Aslp_util_internal.uncons rest in
  let* intrin = aarch64_intrin_of_stmt hd in
  Some (before, intrin, after)

(** Returns the Bincaml global variable representing heap memory. *)
let aarch64_mem_of_prog prog =
  Program.get_decl_by_name "$mem" prog |> function
  | Some (Variable { binding }) -> binding
  | _ -> failwith "aarch64_mem_of_prog: no $mem found"

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

(** Transforms the next {!Lang.Stmt.Intrinsic.Aarch64Eval} intrinsic within the
    given block ID within the given procedure.

    The first intrinsic appearing within the block's statement list, if any,
    will be transformed. The block will be split at this point. Any statements
    after the intrinsic (and any successor edges) will be moved to the last
    block of the freshly-inserted ASLp blocks.

    If a change happened, [Some] will be returned with the updated procedure,
    along with the ID of the last block of the ASLp output (containing the
    suffix of the original block's statements). If no intrinsic exists, [None]
    will be returned.

    If an error occurs while lifting through ASLp, an error attribute will be
    attached to the intrinsic (and it is excluded from subsequent calls). *)
let transform_one_stmt (module I : Bincaml_ibi.IBI) ~proc bid =
  let b = Procedure.get_block proc bid |> Option.get_exn_or "block not found" in

  match next_aarch64_stmt (Vector.to_list b.stmts) with
  | None -> None
  | Some (before, (opcode, address, intrin_attrib), after) -> (
      match lift_opcode (module I) ~address opcode with
      | diamond ->
          let aslp_first, aslp_last, proc = insert_one_diamond ~proc diamond in

          let proc =
            proc
            |> Procedure.modify_block' ~id:bid ~f:(fun b ->
                { b with stmts = Vector.of_list before })
            |> Procedure.modify_block' ~id:aslp_first ~f:(fun b ->
                { b with attrib = intrin_attrib })
            |> Procedure.modify_block' ~id:aslp_last ~f:(fun b ->
                Block.fmap_stmts_copy (Fun.flip CCVector.append_list after) b)
            |> Procedure.transplant_outgoing_edges ~from:bid ~to_:aslp_last
            |> Procedure.add_goto ~from:bid ~targets:[ aslp_first ]
          in
          Some (proc, aslp_last)
      | exception error ->
          let error = `String (Printexc.to_string error) in
          let intrin_stmt =
            stmt_of_aarch64_intrin ~error (opcode, address, intrin_attrib)
          in
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
  | Some (proc, bid) -> (transform_block [@tailcall]) (module I) ~proc bid
  | None -> proc

(** Transforms the {!Lang.Stmt.Intrinsic.Aarch64Eval} intrinsics of all blocks
    within the given procedure. *)
let transform_procedure ~memory proc =
  let memory = Fun.const memory in
  let module I = (val Bincaml_ibi.from_bincaml_procedure ~memory proc) in
  Procedure.iter_blocks proc
  |> Iter.fold (fun proc (bid, _) -> transform_block (module I) ~proc bid) proc

(** Adds architectural variable declarations to the given program. By default,
    includes only those variables which are used. *)
let add_aarch64_global_declarations ?(add_all = false) prog =
  let include_var =
    if add_all then Fun.const true
    else
      Fun.flip VarSet.mem
        (Aslp_util_internal.referenced_vars_of_prog prog
        |> Iter.to_set (module VarSet))
  in

  Lazy.force Aslp_lexpr.global_vars
  |> List.to_iter |> Iter.filter include_var
  |> Iter.fold
       (fun prog var ->
         let attrib = Attrib.empty and classification = None in
         Program.add_decl prog
           (Program.Variable { binding = var; attrib; classification }))
       prog

(** Transforms the {!Lang.Stmt.Intrinsic.Aarch64Eval} intrinsics of all
    procedures within the given program.

    Also inserts global variable declarations for the architectural variables,
    if not already present. *)
let transform_program prog =
  let memory = aarch64_mem_of_prog prog in

  prog
  |> Program.map_procedures (fun _ -> transform_procedure ~memory)
  |> add_aarch64_global_declarations

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
    match aarch64_intrin_of_stmt ~include_failed:true ~default_address stmt with
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

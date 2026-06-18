open Lang
open Common

module Aslp_state : sig
  (** {1 Types} *)

  type stmt = (Var.t, Var.t, Expr.BasilExpr.t) Stmt.t
  (** A statement within the Bincaml AST. This is just a type alias. *)

  type aslp_block = {
    assume : Expr.BasilExpr.t option;
    stmts : (Var.t, Var.t, Expr.BasilExpr.t) Stmt.t CCVector.vector;
    succs : string list;
  }
  (** An ASLp lifter block is a list of statements followed by a
      non-deterministic goto to a number of successors. Each block is optionally
      guarded by an assume statement. *)

  type aslp_state = {
    blocks : aslp_block StringMap.t;
    entry : string;
        (** Key of the entry block. The entry block is required to have no
            {!assume} condition. *)
    exit : string;
        (** Key of the exit block. The exit block is required to have no
            {!succs}. *)
  }
  (** Offline lifter state representing a control flow diamond starting at
      [entry], then flowing through zero or more other blocks, then arriving at
      [exit].

      Alone, this is used to represent the lifter state {i between}
      instructions. Or, it forms a part of {!lifter_state} for
      {i within}-instruction state. *)

  type lifter_generators = {
    block_ids : ID.generator;
    local_ids : ID.generator;
    num_locals : int ref;
  }

  type lifter_state = {
    active : string;
    state : aslp_state;
    generator : lifter_generators;
  }
  (** Intermediate offline lifter state while {i within} one particular
      instruction.

      This records the {!active} block to support ITE branching within an
      instruction. The offline IBI ({!Bincaml_IBI}) operates by mutating a
      reference to this state. *)

  (** {1 Base functions} *)

  val empty_aslp_state : entry:string -> exit:string -> unit -> aslp_state

  val empty_lifter_state : ?generator:lifter_generators -> unit -> lifter_state
  (** Constructs a new empty {!lifter_state}.

      Callers should consider whether they wish to re-use an existing
      [generator] value by passing it explicitly. *)

  val map_aslp_state_names : (string -> string) -> aslp_state -> aslp_state

  (** {1 Manipulation functions} *)

  val add_goto : aslp_state -> source:string -> target:string -> aslp_state
  val add_stmt_to_block : aslp_state -> string -> stmt -> aslp_state
  val add_stmt_to_active : lifter_state -> stmt -> lifter_state
  val append_aslp_states : aslp_state -> aslp_state -> aslp_state

  (** {1 Formatters} *)

  val show_aslp_block : aslp_block -> string
  val pp_aslp_block : Format.formatter -> aslp_block -> unit
  val show_aslp_state : aslp_state -> string
  val pp_aslp_state : Format.formatter -> aslp_state -> unit
  val show_lifter_state : lifter_state -> string
  val pp_lifter_state : Format.formatter -> lifter_state -> unit
end = struct
  type stmt =
    ((Var.t, Var.t, Expr.BasilExpr.t) Stmt.t[@printer Stmt.pp_stmt_basil])
  [@@deriving show]

  type _stmt_list = stmt list [@@deriving show]

  type aslp_block = {
    assume : Expr.BasilExpr.t option;
    stmts : stmt CCVector.vector;
        [@printer Format.map CCVector.to_list pp__stmt_list]
    succs : string list;
  }
  [@@deriving show]

  type aslp_state = {
    blocks : aslp_block StringMap.t;
        [@printer StringMap.pp CCString.pp pp_aslp_block]
    entry : string;
    exit : string;
  }
  [@@deriving show]

  type lifter_generators = {
    block_ids : ID.generator;
    local_ids : ID.generator;
    num_locals : int ref;
  }

  let initial_lifter_generators () =
    let num_locals = ref 0 in
    { block_ids = ID.make_gen (); local_ids = ID.make_gen (); num_locals }

  type lifter_state = {
    active : string;
    state : aslp_state;
    generator : lifter_generators; [@opaque]
  }
  [@@deriving show]

  let empty_aslp_state ~entry ~exit () =
    let blocks =
      StringMap.of_list
        [
          ( entry,
            { assume = None; stmts = CCVector.create (); succs = [ exit ] } );
          (exit, { assume = None; stmts = CCVector.create (); succs = [] });
        ]
    in
    { blocks; entry; exit }

  let empty_lifter_state ?generator () =
    let generator = Option.get_lazy initial_lifter_generators generator in
    let entry = generator.block_ids.fresh ~name:"entry" () |> ID.name in
    let exit = generator.block_ids.fresh ~name:"exit" () |> ID.name in
    { active = entry; state = empty_aslp_state ~entry ~exit (); generator }

  let map_aslp_block_names f { assume; stmts; succs } =
    let succs = List.map f succs in
    { assume; stmts; succs }

  let map_aslp_state_names f { blocks; entry; exit } =
    let blocks =
      blocks |> StringMap.to_iter
      |> Iter.map (fun (k, v) -> (f k, map_aslp_block_names f v))
      |> StringMap.of_iter
    and entry = f entry
    and exit = f exit in
    { blocks; entry; exit }

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

  let add_stmt_to_active { active; state; generator } stmt =
    let state = add_stmt_to_block state active stmt in
    { active; state; generator }

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
end

module Bincaml_IBI (S : sig
  val bincaml_lifter_state : Aslp_state.lifter_state ref
end) =
struct
  type bigint = Z.t
  type bitvector = Bitvec.t
  type expr = Expr.BasilExpr.t
  type lexpr = Var.t
  type stmt = Aslp_state.stmt
  type branch = string
  type ast = Aslp_state.aslp_state

  let bincaml_emit stmt =
    S.bincaml_lifter_state :=
      Aslp_state.add_stmt_to_active !S.bincaml_lifter_state stmt

  let reset_ir () =
    let generator = !S.bincaml_lifter_state.generator in
    S.bincaml_lifter_state := Aslp_state.empty_lifter_state ~generator ()

  let get_ir = fun () -> !S.bincaml_lifter_state.state
  let bigint_of_string : string -> bigint = Z.of_string_base 10
  let bigint_of_int : int -> bigint = Z.of_int
  let bigint_zero : bigint = Z.zero
  let bigint_add : bigint -> bigint -> bigint = Z.add
  let bigint_sub : bigint -> bigint -> bigint = Z.sub
  let bigint_mul : bigint -> bigint -> bigint = Z.mul
  let undefined : unit -> expr = fun _ -> Expr.BasilExpr.bv_of_int ~size:0 0

  let mkBits : bigint -> bigint -> bitvector =
   fun size x -> Bitvec.create ~size:(Z.to_int size) x

  let from_bitsLit : string -> bitvector =
   fun bitstring ->
    Bitvec.of_string
      (Printf.sprintf "0b%s:bv%d" bitstring (String.length bitstring))

  let frem_int : bigint -> bigint -> bigint =
   fun x y -> Z.sub x (Z.mul y (Z.fdiv x y))

  let extract_bits : bitvector -> bigint -> bigint -> bitvector =
   fun x lo wd ->
    let wd = Z.to_int wd and lo = Z.to_int lo in
    let hi = lo + wd in
    Bitvec.extract ~lo ~hi x (* [hi] is exclusive *)

  (** [f_Elem_set operand_width elem_width operand elem_index elem_width elem]
  *)
  let f_Elem_set :
      bigint ->
      bigint ->
      bitvector ->
      bigint ->
      bigint ->
      bitvector ->
      bitvector =
   fun _ -> failwith "elem_set"

  let f_eq_bits : bigint -> bitvector -> bitvector -> bool =
   fun _ -> Bitvec.equal

  let f_ne_bits : bigint -> bitvector -> bitvector -> bool =
   fun _ a b -> not (Bitvec.equal a b)

  let f_add_bits : bigint -> bitvector -> bitvector -> bitvector =
   fun _ -> Bitvec.add

  let f_sub_bits : bigint -> bitvector -> bitvector -> bitvector =
   fun _ -> Bitvec.sub

  let f_mul_bits : bigint -> bitvector -> bitvector -> bitvector =
   fun _ -> Bitvec.mul

  let f_and_bits : bigint -> bitvector -> bitvector -> bitvector =
   fun _ -> Bitvec.bitand

  let f_or_bits : bigint -> bitvector -> bitvector -> bitvector =
   fun _ -> Bitvec.bitor

  let f_eor_bits : bigint -> bitvector -> bitvector -> bitvector =
   fun _ -> Bitvec.bitxor

  let f_not_bits : bigint -> bitvector -> bitvector = fun _ -> Bitvec.bitnot

  let f_slt_bits : bigint -> bitvector -> bitvector -> bool =
   fun _ -> Bitvec.slt

  let f_sle_bits : bigint -> bitvector -> bitvector -> bool =
   fun _ -> Bitvec.sle

  let f_zeros_bits : bigint -> bitvector =
   fun size -> Bitvec.zero ~size:(Z.to_int size)

  let f_ones_bits : bigint -> bitvector =
   fun size -> Bitvec.ones ~size:(Z.to_int size)

  (** [f_replicate_bits operand_width num_replications operand num_replications]
  *)
  let f_replicate_bits : bigint -> bigint -> bitvector -> bigint -> bitvector =
   fun _ _ x copies -> Bitvec.repeat_bits ~copies:(Z.to_int copies) x

  (** [f_append_bits w1 w2 x1 x2] *)
  let f_append_bits : bigint -> bigint -> bitvector -> bitvector -> bitvector =
   fun _ _ -> Bitvec.concat

  (** [f_ZeroExtend operand_width result_width operand result_width] *)
  let f_ZeroExtend : bigint -> bigint -> bitvector -> bigint -> bitvector =
   fun wd result_wd x _ ->
    let extension = Z.(to_int (result_wd - wd)) in
    Bitvec.zero_extend ~extension x

  (** [f_SignExtend operand_width result_width operand result_width] *)
  let f_SignExtend : bigint -> bigint -> bitvector -> bigint -> bitvector =
   fun wd result_wd x _ ->
    let extension = Z.(to_int (result_wd - wd)) in
    Bitvec.sign_extend ~extension x

  let unify_shift_widths apply_shift operand shift =
    let extension = Bitvec.(size operand - size shift) in
    let shift = Bitvec.zero_extend ~extension shift in
    apply_shift operand shift

  (** [f_lsl_bits operand_width shift_width operand shift] *)
  let f_lsl_bits : bigint -> bigint -> bitvector -> bitvector -> bitvector =
   fun _ _ -> unify_shift_widths Bitvec.shl

  (** [f_lsr_bits operand_width shift_width operand shift] *)
  let f_lsr_bits : bigint -> bigint -> bitvector -> bitvector -> bitvector =
   fun _ _ -> unify_shift_widths Bitvec.lshr

  (** [f_asr_bits operand_width shift_width operand shift] *)
  let f_asr_bits : bigint -> bigint -> bitvector -> bitvector -> bitvector =
   fun _ _ -> unify_shift_widths Bitvec.ashr

  (** [f_cvt_bits_uint operand_width operand] *)
  let f_cvt_bits_uint : bigint -> bitvector -> bigint =
   fun _ -> Bitvec.to_unsigned_bigint

  let f_sdiv_int : bigint -> bigint -> bigint = fun _ -> failwith "sdiv int"
  let f_shl_int : bigint -> bigint -> bigint = fun _ -> failwith "shl int"
  let v_PSTATE_C : lexpr = Var.create "v_PSTATE_C" (Types.Bitvector 1)
  let v_PSTATE_Z : lexpr = Var.create "v_PSTATE_Z" (Types.Bitvector 1)
  let v_PSTATE_V : lexpr = Var.create "v_PSTATE_V" (Types.Bitvector 1)
  let v_PSTATE_N : lexpr = Var.create "v_PSTATE_N" (Types.Bitvector 1)
  let v__PC : lexpr = Var.create "v__PC" (Types.Bitvector 1)
  let v__R : lexpr = Var.create "v__R" (Types.Bitvector 0)
  let v__Z : lexpr = Var.create "v__Z" (Types.Bitvector 0)
  let v_SP_EL0 : lexpr = Var.create "v_SP_EL0" (Types.Bitvector 1)
  let v_FPSR : lexpr = Var.create "v_FPSR" (Types.Bitvector 1)
  let v_FPCR : lexpr = Var.create "v_FPCR" (Types.Bitvector 1)
  let v_PSTATE_A : lexpr = Var.create "v_PSTATE_A" (Types.Bitvector 1)
  let v_PSTATE_D : lexpr = Var.create "v_PSTATE_D" (Types.Bitvector 1)
  let v_PSTATE_DIT : lexpr = Var.create "v_PSTATE_DIT" (Types.Bitvector 1)
  let v_PSTATE_F : lexpr = Var.create "v_PSTATE_F" (Types.Bitvector 1)
  let v_PSTATE_I : lexpr = Var.create "v_PSTATE_I" (Types.Bitvector 1)
  let v_PSTATE_PAN : lexpr = Var.create "v_PSTATE_PAN" (Types.Bitvector 1)
  let v_PSTATE_SP : lexpr = Var.create "v_PSTATE_SP" (Types.Bitvector 1)
  let v_PSTATE_SSBS : lexpr = Var.create "v_PSTATE_SSBS" (Types.Bitvector 1)
  let v_PSTATE_TCO : lexpr = Var.create "v_PSTATE_TCO" (Types.Bitvector 1)
  let v_PSTATE_UAO : lexpr = Var.create "v_PSTATE_UAO" (Types.Bitvector 1)
  let v_PSTATE_BTYPE : lexpr = Var.create "v_PSTATE_BTYPE" (Types.Bitvector 1)

  let v_BTypeCompatible : lexpr =
    Var.create "v_BTypeCompatible" (Types.Bitvector 1)

  let v___BranchTaken : lexpr = Var.create "v___BranchTaken" (Types.Bitvector 1)
  let v_BTypeNext : lexpr = Var.create "v_BTypeNext" (Types.Bitvector 1)

  let v___ExclusiveLocal : lexpr =
    Var.create "v___ExclusiveLocal" (Types.Bitvector 1)

  let f_switch_context : branch -> unit = fun _ -> failwith "f_switch_context"

  let f_gen_branch : expr -> branch * branch * branch =
   fun _ -> failwith "f_gen_branch"

  let f_true_branch : branch * branch * branch -> branch =
   fun _ -> failwith "f_true_branch"

  let f_false_branch : branch * branch * branch -> branch =
   fun _ -> failwith "f_false_branch"

  let f_merge_branch : branch * branch * branch -> branch =
   fun _ -> failwith "f_merge_branch"

  let f_gen_assert : expr -> unit = fun _ -> failwith "f_gen_assert"

  let f_gen_bit_lit : bigint -> bitvector -> expr =
   fun _ bv -> Expr.BasilExpr.const (`Bitvector bv)

  let f_gen_bool_lit : bool -> expr = fun _ -> failwith "f_gen_bool_lit"
  let f_gen_int_lit : bigint -> expr = fun _ -> failwith "f_gen_int_lit"

  let f_decl_bv : string -> bigint -> lexpr =
   fun name size -> Var.create name (Types.Bitvector (Z.to_int size))

  let f_decl_bool : string -> lexpr = fun _ -> failwith "f_decl_bool"
  let f_gen_load : lexpr -> expr = fun lhs -> Expr.BasilExpr.rvar lhs

  let f_gen_store : lexpr -> expr -> unit =
   fun lhs rhs ->
    bincaml_emit
      (Stmt.Instr_Assign { attrib = Attrib.empty; al = [ (lhs, rhs) ] })

  let f_gen_array_load : lexpr -> bigint -> expr =
   fun array idx ->
    match Var.name array with
    | "v__R" ->
        f_gen_load (Var.create ("v__R" ^ Z.to_string idx) (Types.Bitvector 64))
    | x -> failwith x

  let f_gen_array_store : lexpr -> bigint -> expr -> unit =
   fun array idx rhs ->
    match Var.name array with
    | "v__R" ->
        f_gen_store
          (Var.create ("v__R" ^ Z.to_string idx) (Types.Bitvector 64))
          rhs
    | x -> failwith x

  let f_gen_Elem_read : bigint -> bigint -> expr -> expr -> expr -> expr =
   fun _ -> failwith "f_gen_Elem_read"

  let f_gen_Elem_set : bigint -> bigint -> expr -> expr -> expr -> expr -> expr
      =
   fun _ -> failwith "f_gen_Elem_set"

  (** [f_gen_Mem_set size address size acctype value] *)
  let f_gen_Mem_set : bigint -> expr -> expr -> expr -> expr -> unit =
   fun _ -> failwith "f_gen_Mem_set"

  (** [f_gen_Mem_read size address size acctype value] *)
  let f_gen_Mem_read : bigint -> expr -> expr -> expr -> expr =
   fun _ -> failwith "f_gen_Mem_read"

  let f_AtomicStart : unit -> unit = fun _ -> failwith "f_AtomicStart"
  let f_AtomicEnd : unit -> unit = fun _ -> failwith "f_AtomicEnd"

  (** [f_gen_AArch64_MemTag_set address acctype value] *)
  let f_gen_AArch64_MemTag_set : expr -> expr -> expr -> unit =
   fun _ -> failwith "f_gen_AArch64_MemTag_set"

  (** [f_gen_AArch64_MemTag_read address acctype] *)
  let f_gen_AArch64_MemTag_read : expr -> expr -> expr =
   fun _ -> failwith "f_gen_AArch64_MemTag_read"

  let f_gen_and_bool : expr -> expr -> expr = fun _ -> failwith "f_gen_and_bool"
  let f_gen_or_bool : expr -> expr -> expr = fun _ -> failwith "f_gen_or_bool"
  let f_gen_not_bool : expr -> expr = fun _ -> failwith "f_gen_not_bool"

  let f_gen_cvt_bits_uint : bigint -> expr -> expr =
   fun _ -> failwith "f_gen_cvt_bits_uint"

  let f_gen_eq_bits : bigint -> expr -> expr -> expr =
   fun _ -> failwith "f_gen_eq_bits"

  let f_gen_ne_bits : bigint -> expr -> expr -> expr =
   fun _ -> failwith "f_gen_ne_bits"

  let f_gen_not_bits : bigint -> expr -> expr =
   fun _ -> failwith "f_gen_not_bits"

  let f_gen_cvt_bool_bv : expr -> expr = fun _ -> failwith "f_gen_cvt_bool_bv"

  let f_gen_or_bits : bigint -> expr -> expr -> expr =
   fun _ -> failwith "f_gen_or_bits"

  let f_gen_eor_bits : bigint -> expr -> expr -> expr =
   fun _ -> failwith "f_gen_eor_bits"

  let f_gen_and_bits : bigint -> expr -> expr -> expr =
   fun _ -> failwith "f_gen_and_bits"

  let f_gen_add_bits : bigint -> expr -> expr -> expr =
   fun _ -> Expr.BasilExpr.binexp ?attrib:None ~op:`BVADD

  let f_gen_sub_bits : bigint -> expr -> expr -> expr =
   fun _ -> failwith "f_gen_sub_bits"

  let f_gen_sdiv_bits : bigint -> expr -> expr -> expr =
   fun _ -> failwith "f_gen_sdiv_bits"

  let f_gen_sle_bits : bigint -> expr -> expr -> expr =
   fun _ -> failwith "f_gen_sle_bits"

  let f_gen_slt_bits : bigint -> expr -> expr -> expr =
   fun _ -> failwith "f_gen_slt_bits"

  let f_gen_mul_bits : bigint -> expr -> expr -> expr =
   fun _ -> failwith "f_gen_mul_bits"

  let f_gen_append_bits : bigint -> bigint -> expr -> expr -> expr =
   fun _ -> failwith "f_gen_append_bits"

  let f_gen_lsr_bits : bigint -> bigint -> expr -> expr -> expr =
   fun _ -> failwith "f_gen_lsr_bits"

  let f_gen_lsl_bits : bigint -> bigint -> expr -> expr -> expr =
   fun _ _ -> Expr.BasilExpr.binexp ?attrib:None ~op:`BVSHL

  let f_gen_asr_bits : bigint -> bigint -> expr -> expr -> expr =
   fun _ -> failwith "f_gen_asr_bits"

  (** [f_gen_replicate_bits operand_width num_replications operand
       num_replications] *)
  let f_gen_replicate_bits : bigint -> bigint -> expr -> expr -> expr =
   fun _ -> failwith "f_gen_replicate_bits"

  (** [f_gen_ZeroExtend operand_width result_width operand result_width] *)
  let f_gen_ZeroExtend : bigint -> bigint -> expr -> expr -> expr =
   fun _ -> failwith "f_gen_ZeroExtend"

  (** [f_gen_SignExtend operand_width result_width operand result_width] *)
  let f_gen_SignExtend : bigint -> bigint -> expr -> expr -> expr =
   fun _ -> failwith "f_gen_SignExtend"

  let f_gen_slice : expr -> bigint -> bigint -> expr =
   fun _ -> failwith "f_gen_slice"

  (* {1 Floating point intrinsics} *)

  let f_gen_FPCompare : bigint -> expr -> expr -> expr -> expr -> expr =
   fun _ -> failwith "f_gen_FPCompare"

  let f_gen_FPCompareEQ : bigint -> expr -> expr -> expr -> expr =
   fun _ -> failwith "f_gen_FPCompareEQ"

  let f_gen_FPCompareGE : bigint -> expr -> expr -> expr -> expr =
   fun _ -> failwith "f_gen_FPCompareGE"

  let f_gen_FPCompareGT : bigint -> expr -> expr -> expr -> expr =
   fun _ -> failwith "f_gen_FPCompareGT"

  let f_gen_FPAdd : bigint -> expr -> expr -> expr -> expr =
   fun _ -> failwith "f_gen_FPAdd"

  let f_gen_FPSub : bigint -> expr -> expr -> expr -> expr =
   fun _ -> failwith "f_gen_FPSub"

  let f_gen_FPMulAdd : bigint -> expr -> expr -> expr -> expr -> expr =
   fun _ -> failwith "f_gen_FPMulAdd"

  let f_gen_FPMulAddH : bigint -> expr -> expr -> expr -> expr -> expr =
   fun _ -> failwith "f_gen_FPMulAddH"

  let f_gen_FPMulX : bigint -> expr -> expr -> expr -> expr =
   fun _ -> failwith "f_gen_FPMulX"

  let f_gen_FPMul : bigint -> expr -> expr -> expr -> expr =
   fun _ -> failwith "f_gen_FPMul"

  let f_gen_FPDiv : bigint -> expr -> expr -> expr -> expr =
   fun _ -> failwith "f_gen_FPDiv"

  let f_gen_FPMin : bigint -> expr -> expr -> expr -> expr =
   fun _ -> failwith "f_gen_FPMin"

  let f_gen_FPMinNum : bigint -> expr -> expr -> expr -> expr =
   fun _ -> failwith "f_gen_FPMinNum"

  let f_gen_FPMax : bigint -> expr -> expr -> expr -> expr =
   fun _ -> failwith "f_gen_FPMax"

  let f_gen_FPMaxNum : bigint -> expr -> expr -> expr -> expr =
   fun _ -> failwith "f_gen_FPMaxNum"

  let f_gen_FPRecpX : bigint -> expr -> expr -> expr =
   fun _ -> failwith "f_gen_FPRecpX"

  let f_gen_FPSqrt : bigint -> expr -> expr -> expr =
   fun _ -> failwith "f_gen_FPSqrt"

  let f_gen_FPRecipEstimate : bigint -> expr -> expr -> expr =
   fun _ -> failwith "f_gen_FPRecipEstimate"

  let f_gen_UnsignedRSqrtEstimate : bigint -> expr -> expr =
   fun _ -> failwith "f_gen_UnsignedRSqrtEstimate"

  let f_gen_FPRSqrtEstimate : bigint -> expr -> expr -> expr =
   fun _ -> failwith "f_gen_FPRSqrtEstimate"

  let f_gen_BFAdd : expr -> expr -> expr = fun _ -> failwith "f_gen_BFAdd"
  let f_gen_BFMul : expr -> expr -> expr = fun _ -> failwith "f_gen_BFMul"

  let f_gen_FPConvertBF : expr -> expr -> expr -> expr =
   fun _ -> failwith "f_gen_FPConvertBF"

  let f_gen_FPRecipStepFused : bigint -> expr -> expr -> expr =
   fun _ -> failwith "f_gen_FPRecipStepFused"

  let f_gen_FPRSqrtStepFused : bigint -> expr -> expr -> expr =
   fun _ -> failwith "f_gen_FPRSqrtStepFused"

  let f_gen_FPToFixed :
      bigint -> bigint -> expr -> expr -> expr -> expr -> expr -> expr =
   fun _ -> failwith "f_gen_FPToFixed"

  let f_gen_FixedToFP :
      bigint -> bigint -> expr -> expr -> expr -> expr -> expr -> expr =
   fun _ -> failwith "f_gen_FixedToFP"

  let f_gen_FPConvert : bigint -> bigint -> expr -> expr -> expr -> expr =
   fun _ -> failwith "f_gen_FPConvert"

  let f_gen_FPRoundInt : bigint -> expr -> expr -> expr -> expr -> expr =
   fun _ -> failwith "f_gen_FPRoundInt"

  let f_gen_FPRoundIntN : bigint -> expr -> expr -> expr -> expr -> expr =
   fun _ -> failwith "f_gen_FPRoundIntN"

  let f_gen_FPToFixedJS_impl : bigint -> bigint -> expr -> expr -> expr -> expr
      =
   fun _ -> failwith "f_gen_FPToFixedJS_impl"
end

let ensure_aslp_globals_exist prog = 9

let lift_opcode
    (module I : OfflineASL_pc.Instruction_building_interface.IBI
      with type bitvector = Bitvec.t
       and type ast = Aslp_state.aslp_state) ~address opcode =
  I.reset_ir ();
  OfflineASL_pc.Offline.f_A64_decoder (module I) opcode address;
  I.get_ir ()

let lift_code_block
    (module I : OfflineASL_pc.Instruction_building_interface.IBI
      with type bitvector = Bitvec.t
       and type ast = Aslp_state.aslp_state) ~address opcodes =
  let initial =
    Aslp_state.empty_aslp_state ~entry:"entryyyy" ~exit:"exittt" ()
  in
  Iter.foldi
    (fun state_acc i op ->
      let address = Bitvec.add (Bitvec.create ~size:64 Z.(~$4 * ~$i)) address in
      let prefix = Int.to_string i ^ "_" in
      let lifted =
        lift_opcode (module I) ~address op
        |> Aslp_state.map_aslp_state_names (fun s -> prefix ^ s)
      in
      Aslp_state.append_aslp_states state_acc lifted)
    initial opcodes

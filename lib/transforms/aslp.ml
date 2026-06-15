open Lang
open Common

module Bincaml_IBI = struct
  type bigint = int
  type bitvector = int
  type expr = int
  type lexpr = int
  type stmt = int
  type branch = int
  type ast = int

  let reset_ir : unit -> unit = fun _ -> failwith ""
  let get_ir : unit -> ast = fun _ -> failwith ""
  let bigint_of_string : string -> bigint = fun _ -> failwith ""
  let bigint_of_int : int -> bigint = fun _ -> failwith ""
  let bigint_zero : bigint = 0
  let bigint_add : bigint -> bigint -> bigint = fun _ -> failwith ""
  let bigint_sub : bigint -> bigint -> bigint = fun _ -> failwith ""
  let bigint_mul : bigint -> bigint -> bigint = fun _ -> failwith ""
  let undefined : unit -> expr = fun _ -> failwith ""
  let mkBits : bigint -> bigint -> bitvector = fun _ -> failwith ""
  let from_bitsLit : string -> bitvector = fun _ -> failwith ""
  let frem_int : bigint -> bigint -> bigint = fun _ -> failwith ""

  let extract_bits : bitvector -> bigint -> bigint -> bitvector =
   fun _ -> failwith ""

  (** [f_Elem_set operand_width elem_width operand elem_index elem_width elem] =
      fun _ -> failwith "" *)
  let f_Elem_set :
      bigint ->
      bigint ->
      bitvector ->
      bigint ->
      bigint ->
      bitvector ->
      bitvector =
   fun _ -> failwith ""

  let f_eq_bits : bigint -> bitvector -> bitvector -> bool =
   fun _ -> failwith ""

  let f_ne_bits : bigint -> bitvector -> bitvector -> bool =
   fun _ -> failwith ""

  let f_add_bits : bigint -> bitvector -> bitvector -> bitvector =
   fun _ -> failwith ""

  let f_sub_bits : bigint -> bitvector -> bitvector -> bitvector =
   fun _ -> failwith ""

  let f_mul_bits : bigint -> bitvector -> bitvector -> bitvector =
   fun _ -> failwith ""

  let f_and_bits : bigint -> bitvector -> bitvector -> bitvector =
   fun _ -> failwith ""

  let f_or_bits : bigint -> bitvector -> bitvector -> bitvector =
   fun _ -> failwith ""

  let f_eor_bits : bigint -> bitvector -> bitvector -> bitvector =
   fun _ -> failwith ""

  let f_not_bits : bigint -> bitvector -> bitvector = fun _ -> failwith ""

  let f_slt_bits : bigint -> bitvector -> bitvector -> bool =
   fun _ -> failwith ""

  let f_sle_bits : bigint -> bitvector -> bitvector -> bool =
   fun _ -> failwith ""

  let f_zeros_bits : bigint -> bitvector = fun _ -> failwith ""
  let f_ones_bits : bigint -> bitvector = fun _ -> failwith ""

  (** [f_replicate_bits operand_width num_replications operand num_replications]
      = fun _ -> failwith "" *)
  let f_replicate_bits : bigint -> bigint -> bitvector -> bigint -> bitvector =
   fun _ -> failwith ""

  (** [f_append_bits w1 w2 x1 x2] *)
  let f_append_bits : bigint -> bigint -> bitvector -> bitvector -> bitvector =
   fun _ -> failwith ""

  (** [f_ZeroExtend operand_width result_width operand result_width] *)
  let f_ZeroExtend : bigint -> bigint -> bitvector -> bigint -> bitvector =
   fun _ -> failwith ""

  (** [f_SignExtend operand_width result_width operand result_width] *)
  let f_SignExtend : bigint -> bigint -> bitvector -> bigint -> bitvector =
   fun _ -> failwith ""

  (** [f_lsl_bits operand_width shift_width operand shift] *)
  let f_lsl_bits : bigint -> bigint -> bitvector -> bitvector -> bitvector =
   fun _ -> failwith ""

  (** [f_lsr_bits operand_width shift_width operand shift] *)
  let f_lsr_bits : bigint -> bigint -> bitvector -> bitvector -> bitvector =
   fun _ -> failwith ""

  (** [f_asr_bits operand_width shift_width operand shift] *)
  let f_asr_bits : bigint -> bigint -> bitvector -> bitvector -> bitvector =
   fun _ -> failwith ""

  (** [f_cvt_bits_uint operand_width operand] *)
  let f_cvt_bits_uint : bigint -> bitvector -> bigint = fun _ -> failwith ""

  let f_sdiv_int : bigint -> bigint -> bigint = fun _ -> failwith ""
  let f_shl_int : bigint -> bigint -> bigint = fun _ -> failwith ""
  let v_PSTATE_C : expr = 0
  let v_PSTATE_Z : expr = 0
  let v_PSTATE_V : expr = 0
  let v_PSTATE_N : expr = 0
  let v__PC : expr = 0
  let v__R : expr = 0
  let v__Z : expr = 0
  let v_SP_EL0 : expr = 0
  let v_FPSR : expr = 0
  let v_FPCR : expr = 0
  let v_PSTATE_A : expr = 0
  let v_PSTATE_D : expr = 0
  let v_PSTATE_DIT : expr = 0
  let v_PSTATE_F : expr = 0
  let v_PSTATE_I : expr = 0
  let v_PSTATE_PAN : expr = 0
  let v_PSTATE_SP : expr = 0
  let v_PSTATE_SSBS : expr = 0
  let v_PSTATE_TCO : expr = 0
  let v_PSTATE_UAO : expr = 0
  let v_PSTATE_BTYPE : expr = 0
  let v_BTypeCompatible : expr = 0
  let v___BranchTaken : expr = 0
  let v_BTypeNext : expr = 0
  let v___ExclusiveLocal : expr = 0
  let f_switch_context : branch -> unit = fun _ -> failwith ""
  let f_gen_branch : expr -> branch * branch * branch = fun _ -> failwith ""
  let f_true_branch : branch * branch * branch -> branch = fun _ -> failwith ""
  let f_false_branch : branch * branch * branch -> branch = fun _ -> failwith ""
  let f_merge_branch : branch * branch * branch -> branch = fun _ -> failwith ""
  let f_gen_assert : expr -> unit = fun _ -> failwith ""
  let f_gen_bit_lit : 'a -> bitvector -> expr = fun _ -> failwith ""
  let f_gen_bool_lit : bool -> expr = fun _ -> failwith ""
  let f_gen_int_lit : bigint -> expr = fun _ -> failwith ""
  let f_decl_bv : string -> bigint -> expr = fun _ -> failwith ""
  let f_decl_bool : string -> expr = fun _ -> failwith ""
  let f_gen_load : 'a -> 'a = fun _ -> failwith ""
  let f_gen_store : expr -> expr -> unit = fun _ -> failwith ""
  let f_gen_array_load : expr -> bigint -> expr = fun _ -> failwith ""
  let f_gen_array_store : expr -> bigint -> expr -> unit = fun _ -> failwith ""

  let f_gen_Elem_read : bigint -> bigint -> expr -> expr -> expr -> expr =
   fun _ -> failwith ""

  let f_gen_Elem_set : bigint -> bigint -> expr -> expr -> expr -> expr -> expr
      =
   fun _ -> failwith ""

  let f_gen_Mem_set : bigint -> expr -> 'a -> expr -> expr -> unit =
   fun _ -> failwith ""

  let f_gen_Mem_read : bigint -> expr -> 'a -> expr -> expr =
   fun _ -> failwith ""

  let f_AtomicStart : unit -> unit = fun _ -> failwith ""
  let f_AtomicEnd : unit -> unit = fun _ -> failwith ""
  let f_gen_AArch64_MemTag_set : 'a -> 'b -> 'c -> unit = fun _ -> failwith ""
  let f_gen_AArch64_MemTag_read : 'a -> 'b -> 'c = fun _ -> failwith ""
  let f_gen_and_bool : expr -> expr -> expr = fun _ -> failwith ""
  let f_gen_or_bool : expr -> expr -> expr = fun _ -> failwith ""
  let f_gen_not_bool : expr -> expr = fun _ -> failwith ""
  let f_gen_cvt_bits_uint : bigint -> expr -> expr = fun _ -> failwith ""
  let f_gen_eq_bits : bigint -> expr -> expr -> expr = fun _ -> failwith ""
  let f_gen_ne_bits : bigint -> expr -> expr -> expr = fun _ -> failwith ""
  let f_gen_not_bits : bigint -> expr -> expr = fun _ -> failwith ""
  let f_gen_cvt_bool_bv : expr -> expr = fun _ -> failwith ""
  let f_gen_or_bits : bigint -> expr -> expr -> expr = fun _ -> failwith ""
  let f_gen_eor_bits : bigint -> expr -> expr -> expr = fun _ -> failwith ""
  let f_gen_and_bits : bigint -> expr -> expr -> expr = fun _ -> failwith ""
  let f_gen_add_bits : bigint -> expr -> expr -> expr = fun _ -> failwith ""
  let f_gen_sub_bits : bigint -> expr -> expr -> expr = fun _ -> failwith ""
  let f_gen_sdiv_bits : bigint -> expr -> expr -> expr = fun _ -> failwith ""
  let f_gen_sle_bits : bigint -> expr -> expr -> expr = fun _ -> failwith ""
  let f_gen_slt_bits : bigint -> expr -> expr -> expr = fun _ -> failwith ""
  let f_gen_mul_bits : bigint -> expr -> expr -> expr = fun _ -> failwith ""

  let f_gen_append_bits : bigint -> bigint -> expr -> expr -> expr =
   fun _ -> failwith ""

  let f_gen_lsr_bits : bigint -> bigint -> expr -> expr -> expr =
   fun _ -> failwith ""

  let f_gen_lsl_bits : bigint -> bigint -> expr -> expr -> expr =
   fun _ -> failwith ""

  let f_gen_asr_bits : bigint -> bigint -> expr -> expr -> expr =
   fun _ -> failwith ""

  let f_gen_replicate_bits : bigint -> bigint -> expr -> 'a -> expr =
   fun _ -> failwith ""

  let f_gen_ZeroExtend : bigint -> bigint -> expr -> 'a -> expr =
   fun _ -> failwith ""

  let f_gen_SignExtend : bigint -> bigint -> expr -> 'a -> expr =
   fun _ -> failwith ""

  let f_gen_slice : expr -> bigint -> bigint -> expr = fun _ -> failwith ""

  let f_gen_FPCompare : bigint -> expr -> expr -> expr -> expr -> expr =
   fun _ -> failwith ""

  let f_gen_FPCompareEQ : bigint -> expr -> expr -> expr -> expr =
   fun _ -> failwith ""

  let f_gen_FPCompareGE : bigint -> expr -> expr -> expr -> expr =
   fun _ -> failwith ""

  let f_gen_FPCompareGT : bigint -> expr -> expr -> expr -> expr =
   fun _ -> failwith ""

  let f_gen_FPAdd : bigint -> expr -> expr -> expr -> expr =
   fun _ -> failwith ""

  let f_gen_FPSub : bigint -> expr -> expr -> expr -> expr =
   fun _ -> failwith ""

  let f_gen_FPMulAdd : bigint -> expr -> expr -> expr -> expr -> expr =
   fun _ -> failwith ""

  let f_gen_FPMulAddH : bigint -> expr -> expr -> expr -> expr -> expr =
   fun _ -> failwith ""

  let f_gen_FPMulX : bigint -> expr -> expr -> expr -> expr =
   fun _ -> failwith ""

  let f_gen_FPMul : bigint -> expr -> expr -> expr -> expr =
   fun _ -> failwith ""

  let f_gen_FPDiv : bigint -> expr -> expr -> expr -> expr =
   fun _ -> failwith ""

  let f_gen_FPMin : bigint -> expr -> expr -> expr -> expr =
   fun _ -> failwith ""

  let f_gen_FPMinNum : bigint -> expr -> expr -> expr -> expr =
   fun _ -> failwith ""

  let f_gen_FPMax : bigint -> expr -> expr -> expr -> expr =
   fun _ -> failwith ""

  let f_gen_FPMaxNum : bigint -> expr -> expr -> expr -> expr =
   fun _ -> failwith ""

  let f_gen_FPRecpX : bigint -> expr -> expr -> expr = fun _ -> failwith ""
  let f_gen_FPSqrt : bigint -> expr -> expr -> expr = fun _ -> failwith ""

  let f_gen_FPRecipEstimate : bigint -> expr -> expr -> expr =
   fun _ -> failwith ""

  let f_gen_UnsignedRSqrtEstimate : bigint -> expr -> expr =
   fun _ -> failwith ""

  let f_gen_FPRSqrtEstimate : bigint -> expr -> expr -> expr =
   fun _ -> failwith ""

  let f_gen_BFAdd : expr -> expr -> expr = fun _ -> failwith ""
  let f_gen_BFMul : expr -> expr -> expr = fun _ -> failwith ""
  let f_gen_FPConvertBF : expr -> expr -> expr -> expr = fun _ -> failwith ""

  let f_gen_FPRecipStepFused : bigint -> expr -> expr -> expr =
   fun _ -> failwith ""

  let f_gen_FPRSqrtStepFused : bigint -> expr -> expr -> expr =
   fun _ -> failwith ""

  let f_gen_FPToFixed :
      bigint -> bigint -> expr -> expr -> expr -> expr -> expr -> expr =
   fun _ -> failwith ""

  let f_gen_FixedToFP :
      bigint -> bigint -> expr -> expr -> expr -> expr -> expr -> expr =
   fun _ -> failwith ""

  let f_gen_FPConvert : bigint -> bigint -> expr -> expr -> expr -> expr =
   fun _ -> failwith ""

  let f_gen_FPRoundInt : bigint -> expr -> expr -> expr -> expr -> expr =
   fun _ -> failwith ""

  let f_gen_FPRoundIntN : bigint -> expr -> expr -> expr -> expr -> expr =
   fun _ -> failwith ""

  let f_gen_FPToFixedJS_impl : bigint -> bigint -> expr -> expr -> expr -> expr
      =
   fun _ -> failwith ""
end

let a () = OfflineASL.Offline.f_A64_decoder (module Bincaml_IBI) 2

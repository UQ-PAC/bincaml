open Lang
open Common

(** Makes a concrete module which implements {!Bincaml_ibi.IBI}. *)
module Make (S : sig
  val initial_lifter_state : Aslp_state.lifter_state
end) =
struct
  (** {2 Type definitions} *)

  type bigint = Z.t
  type bitvector = Bitvec.t
  type expr = Expr.BasilExpr.t
  type lexpr = Aslp_lexpr.t
  type stmt = Aslp_state.stmt
  type ast = Aslp_state.aslp_diamond

  (** {2 Bincaml-specific utility functions} *)

  let bincaml_lifter_state = ref S.initial_lifter_state

  let bincaml_set_address address =
    bincaml_lifter_state :=
      { !bincaml_lifter_state with address = Some address }

  let bincaml_get_address () =
    let err = "bincaml_get_address: address not set. use bincaml_set_address" in
    !bincaml_lifter_state.address |> Option.get_exn_or err

  (** Emits the given Bincaml statement. *)
  let bincaml_internal_emit stmt =
    bincaml_lifter_state :=
      !bincaml_lifter_state |> Aslp_state.add_stmt_to_active stmt

  let bincaml_local_var name ty =
    let id_name =
      match Hashtbl.find_opt !bincaml_lifter_state.names name with
      | None ->
          let id_name = !bincaml_lifter_state.generator.local_id () in
          Hashtbl.replace !bincaml_lifter_state.names name id_name;
          id_name
      | Some x -> x
    in
    Aslp_lexpr.Local (id_name, ty)

  let try_const_unsigned_value v =
    match Expr.BasilExpr.unfix v with
    | Constant { const = `Bitvector v } -> Bitvec.value v
    | Constant { const = `Integer v } -> v
    | Constant _ ->
        raise (Failure ("non-number: " ^ Expr.BasilExpr.to_string v))
    | _ -> raise (Failure ("non-constant: " ^ Expr.BasilExpr.to_string v))

  (** {2 Control flow}

      Implemented by {!Diamond_ibi.Make}. *)

  (** @inline *)
  include Diamond_ibi.Make (struct
    type nonrec expr = expr
    type state = Aslp_state.aslp_block

    let diamond_get () = !bincaml_lifter_state.diamond

    let diamond_set diamond =
      bincaml_lifter_state := { !bincaml_lifter_state with diamond }

    let diamond_make_branch cond =
      let pc_assign =
        (Diamond_zipper.focus !bincaml_lifter_state.diamond).pc_assign
      in
      let t = Aslp_state.empty_block ~assume:cond ()
      and f = Aslp_state.empty_block ~assume:(Expr.BasilExpr.boolnot cond) ()
      and m = Aslp_state.empty_block_unconditional () in
      ({ t with pc_assign }, { f with pc_assign }, { m with pc_assign })

    let equal_state = CCEqual.map (fun x -> x.Aslp_state.stmts) CCEqual.physical
  end)

  let f_switch_context (d, ctx) =
    f_switch_context (d, ctx);
    match d with
    | `T | `F -> ()
    | `M ->
        let address = bincaml_get_address ()
        and diamond = !bincaml_lifter_state.diamond in
        let diamond = diamond |> Aslp_state.ensure_pc_consistency ~address in
        bincaml_lifter_state := { !bincaml_lifter_state with diamond }

  (** {2 IR extraction} *)

  let reset_ir () =
    let generator = !bincaml_lifter_state.generator in
    bincaml_lifter_state := Aslp_state.empty_lifter_state ~generator ()

  let get_ir () =
    let diamond = !bincaml_lifter_state.diamond
    and address = bincaml_get_address () in
    match Diamond_zipper.path diamond with
    | _ :: _ ->
        failwith "invariant violation: context switches did not return to merge"
    | [] ->
        diamond
        |> Aslp_state.ensure_pc_assigned ~address
        |> Aslp_state.ensure_forwarded_pc |> Diamond_zipper.to_diamond

  (** {2 Instruction building interface implementation} *)

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

  let zero_extend_to_match_op apply_shift ~width_of shift =
    let extension = Bitvec.(size width_of - size shift) in
    let shift = Bitvec.zero_extend ~extension shift in
    apply_shift width_of shift

  (** [f_lsl_bits operand_width shift_width operand shift] *)
  let f_lsl_bits : bigint -> bigint -> bitvector -> bitvector -> bitvector =
   fun _ _ width_of b -> zero_extend_to_match_op Bitvec.shl ~width_of b

  (** [f_lsr_bits operand_width shift_width operand shift] *)
  let f_lsr_bits : bigint -> bigint -> bitvector -> bitvector -> bitvector =
   fun _ _ width_of b -> zero_extend_to_match_op Bitvec.lshr ~width_of b

  (** [f_asr_bits operand_width shift_width operand shift] *)
  let f_asr_bits : bigint -> bigint -> bitvector -> bitvector -> bitvector =
   fun _ _ width_of b -> zero_extend_to_match_op Bitvec.ashr ~width_of b

  (** [f_cvt_bits_uint operand_width operand] *)
  let f_cvt_bits_uint : bigint -> bitvector -> bigint =
   fun _ -> Bitvec.to_unsigned_bigint

  let f_sdiv_int : bigint -> bigint -> bigint = fun a b -> Z.div a b

  let f_shl_int : bigint -> bigint -> bigint =
   fun a b ->
    Z.shift_left a
      (Z.to_int64_unsigned b |> Int64.unsigned_to_int
      |> Option.get_exn_or "shift value too large for camlint")

  let v_PSTATE_C : lexpr = PSTATE_C
  let v_PSTATE_Z : lexpr = PSTATE_Z
  let v_PSTATE_V : lexpr = PSTATE_V
  let v_PSTATE_N : lexpr = PSTATE_N
  let v__PC : lexpr = PC
  let v__R : lexpr = R None
  let v__Z : lexpr = Z None
  let v_SP_EL0 : lexpr = SP_EL0
  let v_FPSR : lexpr = FPSR
  let v_FPCR : lexpr = FPCR
  let v_PSTATE_A : lexpr = PSTATE_A
  let v_PSTATE_D : lexpr = PSTATE_D
  let v_PSTATE_DIT : lexpr = PSTATE_DIT
  let v_PSTATE_F : lexpr = PSTATE_F
  let v_PSTATE_I : lexpr = PSTATE_I
  let v_PSTATE_PAN : lexpr = PSTATE_PAN
  let v_PSTATE_SP : lexpr = PSTATE_SP
  let v_PSTATE_SSBS : lexpr = PSTATE_SSBS
  let v_PSTATE_TCO : lexpr = PSTATE_TCO
  let v_PSTATE_UAO : lexpr = PSTATE_UAO
  let v_PSTATE_BTYPE : lexpr = PSTATE_BTYPE
  let v_BTypeCompatible : lexpr = BTypeCompatible
  let v___BranchTaken : lexpr = BranchTaken
  let v_BTypeNext : lexpr = BTypeNext
  let v___ExclusiveLocal : lexpr = ExclusiveLocal

  let f_gen_assert : expr -> unit =
   fun e ->
    bincaml_internal_emit
      (Stmt.Instr_Assert { attrib = Attrib.empty; body = e })

  let f_gen_bit_lit : bigint -> bitvector -> expr =
   fun _ bv -> Expr.BasilExpr.const (`Bitvector bv)

  let f_gen_bool_lit : bool -> expr = Expr.BasilExpr.boolconst
  let f_gen_int_lit : bigint -> expr = Expr.BasilExpr.intconst

  let f_gen_store : lexpr -> expr -> unit =
   fun lhs rhs ->
    bincaml_internal_emit
      (Stmt.Instr_Assign
         { attrib = Attrib.empty; al = [ (Aslp_lexpr.to_var lhs, rhs) ] })

  let f_decl_bv : string -> bigint -> lexpr =
   fun name size ->
    let v = bincaml_local_var name (Types.Bitvector (Z.to_int size)) in
    f_gen_store v (f_gen_bit_lit size (Bitvec.zero ~size:(Z.to_int size)));
    v

  let f_decl_bool : string -> lexpr =
   fun name ->
    let v = bincaml_local_var name Types.Boolean in
    f_gen_store v (f_gen_bool_lit false);
    v

  let f_gen_load : lexpr -> expr =
   fun lhs -> Expr.BasilExpr.rvar (Aslp_lexpr.to_var lhs)

  let f_gen_array_load : lexpr -> bigint -> expr =
   fun array idx ->
    match array with
    | R None -> f_gen_load (R (Some (Z.to_int idx)))
    | Z None -> f_gen_load (Z (Some (Z.to_int idx)))
    | x -> failwith @@ "f_gen_array_load: " ^ Aslp_lexpr.show x

  let f_gen_array_store : lexpr -> bigint -> expr -> unit =
   fun array idx rhs ->
    match array with
    | R None -> f_gen_store (R (Some (Z.to_int idx))) rhs
    | Z None -> f_gen_store (Z (Some (Z.to_int idx))) rhs
    | x -> failwith @@ "f_gen_array_store: " ^ Aslp_lexpr.show x

  let f_gen_Elem_read : bigint -> bigint -> expr -> expr -> expr -> expr =
   fun _ -> failwith "f_gen_Elem_read"

  let f_gen_Elem_set : bigint -> bigint -> expr -> expr -> expr -> expr -> expr
      =
   fun _ -> failwith "f_gen_Elem_set"

  (** [(f_gen_Mem_set size address size acctype value) : unit] emits an
      instruction which stores value to memory. Value must have bit width equal
      to size (bytes) in bits. *)
  let f_gen_Mem_set : bigint -> expr -> expr -> expr -> expr -> unit =
   fun size addr _ _acctype value ->
    let size = 8 * Z.to_int size in
    let addr = Stmt.Addr { addr; size; endian = `Little }
    and mem = Aslp_lexpr.to_var Memory in
    bincaml_internal_emit
      (Stmt.Instr_Store
         { attrib = Attrib.empty; lhs = mem; rhs = mem; value; addr })

  (** [let lhs = f_gen_Mem_read size address size acctype value] emits a read
      instruction reading a bitvector [size] (bytes) from the memory variable,
      assigning it to variable [lhs]. Returns [lhs] as an expression). *)
  let f_gen_Mem_read : bigint -> expr -> expr -> expr -> expr =
   fun size addr _ _acctype ->
    let size = 8 * Z.to_int size in
    let addr = Stmt.Addr { addr; size; endian = `Little }
    and mem = Aslp_lexpr.to_var Memory in
    (* NOTE: avoids `bincaml_local_var` so these variables do not clash with ASLp-declared variables. *)
    let name = !bincaml_lifter_state.generator.local_id () in
    let lhs = Var.create name (Types.bv size) in
    bincaml_internal_emit
      (Stmt.Instr_Load { attrib = Attrib.empty; lhs; rhs = mem; addr });
    Expr.BasilExpr.rvar lhs

  let f_AtomicStart : unit -> unit = fun _ -> failwith "f_AtomicStart"
  let f_AtomicEnd : unit -> unit = fun _ -> failwith "f_AtomicEnd"

  (** [f_gen_AArch64_MemTag_set address acctype value] *)
  let f_gen_AArch64_MemTag_set : expr -> expr -> expr -> unit =
   fun _ -> failwith "f_gen_AArch64_MemTag_set"

  (** [f_gen_AArch64_MemTag_read address acctype] *)
  let f_gen_AArch64_MemTag_read : expr -> expr -> expr =
   fun _ -> failwith "f_gen_AArch64_MemTag_read"

  let f_gen_and_bool : expr -> expr -> expr =
   fun a b -> Expr.BasilExpr.applyintrin ~op:`AND [ a; b ]

  let f_gen_or_bool : expr -> expr -> expr =
   fun a b -> Expr.BasilExpr.applyintrin ~op:`OR [ a; b ]

  let f_gen_not_bool : expr -> expr =
   fun a -> Expr.BasilExpr.unexp ~op:`BoolNOT a

  let f_gen_cvt_bits_uint : bigint -> expr -> expr =
   fun _ -> failwith "f_gen_cvt_bits_uint"

  let f_gen_eq_bits : bigint -> expr -> expr -> expr =
   fun _ a b -> Expr.BasilExpr.binexp ~op:`EQ a b

  let f_gen_ne_bits : bigint -> expr -> expr -> expr =
   fun _ a b -> Expr.BasilExpr.binexp ~op:`EQ a b

  let f_gen_not_bits : bigint -> expr -> expr =
   fun _ a -> Expr.BasilExpr.unexp ~op:`BVNOT a

  let f_gen_cvt_bool_bv : expr -> expr =
   fun e -> Expr.BasilExpr.unexp ~op:`BOOLTOBV1 e

  let f_gen_or_bits : bigint -> expr -> expr -> expr =
   fun _ a b -> Expr.BasilExpr.applyintrin ~op:`BVOR [ a; b ]

  let f_gen_eor_bits : bigint -> expr -> expr -> expr =
   fun _ a b -> Expr.BasilExpr.applyintrin ~op:`BVXOR [ a; b ]

  let f_gen_and_bits : bigint -> expr -> expr -> expr =
   fun _ a b -> Expr.BasilExpr.applyintrin ~op:`BVAND [ a; b ]

  let f_gen_add_bits : bigint -> expr -> expr -> expr =
   fun _ a b -> Expr.BasilExpr.applyintrin ~op:`BVADD [ a; b ]

  let f_gen_sub_bits : bigint -> expr -> expr -> expr =
   fun _ a b -> Expr.BasilExpr.binexp ~op:`BVSUB a b

  let f_gen_sdiv_bits : bigint -> expr -> expr -> expr =
   fun _ a b -> Expr.BasilExpr.binexp ~op:`BVSDIV a b

  let f_gen_sle_bits : bigint -> expr -> expr -> expr =
   fun _ a b -> Expr.BasilExpr.binexp ~op:`BVSLE a b

  let f_gen_slt_bits : bigint -> expr -> expr -> expr =
   fun _ a b -> Expr.BasilExpr.binexp ~op:`BVSLT a b

  let zero_extend_to_match ~width_of shift =
    let width a =
      Expr.BasilExpr.type_of a |> Types.bit_width
      |> Option.get_exn_or "expected bv argument to operator"
    in
    let wb = width shift and wa = width width_of in
    if wa = wb then shift
    else if wa > wb then
      Expr.BasilExpr.zero_extend ~n_prefix_bits:(wa - wb) shift
    else failwith "expected second shift argument to be equal or smaller"

  let f_gen_mul_bits : bigint -> expr -> expr -> expr =
   fun _ a b -> Expr.BasilExpr.applyintrin ~op:`BVMUL [ a; b ]

  let f_gen_append_bits : bigint -> bigint -> expr -> expr -> expr =
   fun _ _ a b -> Expr.BasilExpr.applyintrin ~op:`BVConcat [ a; b ]

  let f_gen_lsr_bits : bigint -> bigint -> expr -> expr -> expr =
   fun _ _ a b ->
    Expr.BasilExpr.binexp ~op:`BVLSHR a (zero_extend_to_match ~width_of:a b)

  let f_gen_lsl_bits : bigint -> bigint -> expr -> expr -> expr =
   fun _ _ a b ->
    Expr.BasilExpr.binexp ~op:`BVSHL a (zero_extend_to_match ~width_of:a b)

  let f_gen_asr_bits : bigint -> bigint -> expr -> expr -> expr =
   fun _ _ a b ->
    Expr.BasilExpr.binexp ~op:`BVASHR a (zero_extend_to_match ~width_of:a b)

  (** [f_gen_replicate_bits operand_width num_replications operand
       num_replications] *)
  let f_gen_replicate_bits : bigint -> bigint -> expr -> expr -> expr =
   fun targ0 targ1 opr nr ->
    try_const_unsigned_value nr |> Z.to_int |> fun repeats ->
    Expr.BasilExpr.applyintrin ~op:`BVConcat @@ List.init repeats (fun _ -> opr)

  (** [f_gen_ZeroExtend operand_width result_width operand result_width] *)
  let f_gen_ZeroExtend : bigint -> bigint -> expr -> expr -> expr =
   fun op_wd final_wd x _ ->
    Expr.BasilExpr.zero_extend ~n_prefix_bits:Z.(to_int (final_wd - op_wd)) x

  (** [f_gen_SignExtend operand_width result_width operand result_width] *)
  let f_gen_SignExtend : bigint -> bigint -> expr -> expr -> expr =
   fun op_wd final_wd x _ ->
    Expr.BasilExpr.sign_extend ~n_prefix_bits:Z.(to_int (final_wd - op_wd)) x

  (** [f_gen_slice x lo wd] *)
  let f_gen_slice : expr -> bigint -> bigint -> expr =
   fun x lo_incl wd ->
    let hi_excl = Z.(to_int (lo_incl + wd)) and lo_incl = Z.to_int lo_incl in
    Expr.BasilExpr.extract ~lo_incl ~hi_excl x

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

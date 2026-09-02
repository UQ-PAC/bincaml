open Bincaml_util.Common
open Lang

module FlagSemantics = struct
  type t =
    | Never
    | Always
    | O of computation  (** Overflow from computation *)
    | C of computation  (** Carry from computation *)
    | Z of computation  (** When computation is zero *)
    | N of computation  (** When computation is negative *)

  and computation =
    | Sum of Expr.BasilExpr.t * Expr.BasilExpr.t  (** Computed e1 + e2 *)
    | Diff of Expr.BasilExpr.t * Expr.BasilExpr.t  (** Computed e1 - e2 *)
    | Expr of Expr.BasilExpr.t  (** The result of evaluating an expr *)
  [@@deriving eq, ord, show { with_path = false }]

  (** Determine whether [v] exists in an expression in [f] *)
  let contains_var v f =
    match f with
    | O c | C c | Z c | N c -> (
        match c with
        | Sum (e1, e2) | Diff (e1, e2) ->
            VarSet.mem v (Expr.BasilExpr.free_vars e1)
            || VarSet.mem v (Expr.BasilExpr.free_vars e2)
        | Expr e -> VarSet.mem v (Expr.BasilExpr.free_vars e))
    | Never | Always -> false

  let extract_overflow_cary arg1 arg2 =
    let open Types in
    let open Expr.AbstractExpr in
    let open Expr.BasilExpr in
    let equiv_exp e1 e2 = equal (drop_attrib e1) (drop_attrib e2) in
    let sext_eq extension bv1 bv2 =
      Bitvec.(equal (sign_extend ~extension bv1) bv2)
    in
    let zext_eq extension bv1 bv2 =
      Bitvec.(equal (zero_extend ~extension bv1) bv2)
    in
    let is_one bv = Bitvec.(equal bv (one ~size:(size bv))) in
    match (unfix3 arg1, unfix3 arg2) with
    | ( UnaryExpr
          {
            op = `SignExtend s1;
            arg =
              ApplyIntrin
                {
                  op = `BVADD;
                  args = [ a; Constant { const = `Bitvector bv1 } ];
                };
          },
        ApplyIntrin
          {
            op = `BVADD;
            args =
              [
                UnaryExpr { op = `SignExtend s2; arg = c };
                Constant { const = `Bitvector bv2 };
              ];
          } )
      when s1 = s2 && s1 > 0 && equiv_exp (fix a) (fix c) && sext_eq s1 bv1 bv2
      ->
        if Bitvec.is_negative bv1 then
          Some (O (Diff (fix a, bvconst (Bitvec.neg bv1))))
        else Some (O (Sum (fix a, bvconst bv1)))
    | ( UnaryExpr
          {
            op = `SignExtend s1;
            arg = ApplyIntrin { op = `BVADD; args = [ a; b ] };
          },
        ApplyIntrin
          {
            op = `BVADD;
            args =
              [
                UnaryExpr { op = `SignExtend s2; arg = c };
                UnaryExpr { op = `SignExtend s3; arg = d };
              ];
          } )
      when s1 = s2 && s2 = s3 && s1 > 0
           && equiv_exp (fix a) (fix c)
           && equiv_exp (fix b) (fix d) ->
        Some (O (Sum (fix a, fix b)))
    | ( UnaryExpr
          {
            op = `SignExtend s1;
            arg = BinaryExpr { op = `BVSUB; arg1 = a; arg2 = b };
          },
        BinaryExpr
          {
            op = `BVSUB;
            arg1 = UnaryExpr { op = `SignExtend s2; arg = c };
            arg2 = UnaryExpr { op = `SignExtend s3; arg = d };
          } )
      when s1 = s2 && s2 = s3 && s1 > 0
           && equiv_exp (fix a) (fix c)
           && equiv_exp (fix b) (fix d) ->
        Some (O (Diff (fix a, fix b)))
    | ( UnaryExpr
          {
            op = `ZeroExtend z1;
            arg =
              ApplyIntrin
                {
                  op = `BVADD;
                  args = [ a; Constant { const = `Bitvector bv1 } ];
                };
          },
        ApplyIntrin
          {
            op = `BVADD;
            args =
              [
                UnaryExpr { op = `ZeroExtend z2; arg = c };
                Constant { const = `Bitvector bv2 };
              ];
          } )
      when z1 = z2 && z1 > 0 && equiv_exp (fix a) (fix c) && zext_eq z1 bv1 bv2
      ->
        if Bitvec.is_negative bv1 then
          Some (C (Diff (fix a, bvconst (Bitvec.neg bv1))))
        else Some (O (Sum (fix a, bvconst bv1)))
    | ( UnaryExpr
          {
            op = `ZeroExtend z1;
            arg = ApplyIntrin { op = `BVADD; args = [ a; b ] };
          },
        ApplyIntrin
          {
            op = `BVADD;
            args =
              [
                UnaryExpr { op = `ZeroExtend z2; arg = c };
                UnaryExpr { op = `ZeroExtend z3; arg = d };
              ];
          } )
      when z1 = z2 && z2 = z3 && z1 > 0
           && equiv_exp (fix a) (fix c)
           && equiv_exp (fix b) (fix d) ->
        Some (C (Sum (fix a, fix b)))
    | ( UnaryExpr
          {
            op = `ZeroExtend z1;
            arg = BinaryExpr { op = `BVSUB; arg1 = a; arg2 = b };
          },
        ApplyIntrin
          {
            op = `BVADD;
            args =
              [
                UnaryExpr { op = `ZeroExtend z2; arg = c };
                UnaryExpr
                  {
                    op = `ZeroExtend z3;
                    arg = UnaryExpr { op = `BVNOT; arg = d };
                  };
                Constant { const = `Bitvector bv };
              ];
          } )
      when z1 = z2 && z2 = z3 && z1 > 0
           && equiv_exp (fix a) (fix c)
           && equiv_exp (fix b) d
           && is_one bv ->
        Some (C (Diff (fix a, fix b)))
    | _ -> None

  let extract_expr arg =
    let open Expr.AbstractExpr in
    let open Expr.BasilExpr in
    match unfix2 arg with
    | ApplyIntrin
        { op = `BVADD; args = [ a; Constant { const = `Bitvector bv } ] } ->
        if Bitvec.is_negative bv then Diff (fix a, bvconst (Bitvec.neg bv))
        else Sum (fix a, bvconst bv)
    | ApplyIntrin { op = `BVADD; args = [ a; b ] } -> Sum (fix a, fix b)
    | BinaryExpr { op = `BVSUB; arg1 = a; arg2 = b } -> Diff (fix a, fix b)
    | a -> Expr (fix2 a)

  let extract_semantics e =
    let e = Algsimp.normalise e in
    let open Expr.AbstractExpr in
    let open Expr.BasilExpr in
    match unfix3 e with
    | Constant { const = `Bitvector k }
      when Bitvec.equal k (Bitvec.zero ~size:1) ->
        Some Never
    | Constant { const = `Bitvector k } when Bitvec.equal k (Bitvec.one ~size:1)
      ->
        Some Always
    | UnaryExpr
        {
          op = `BVNOT;
          arg =
            UnaryExpr
              { op = `BOOLTOBV1; arg = BinaryExpr { op = `EQ; arg1; arg2 } };
        } ->
        extract_overflow_cary arg1 arg2
    | UnaryExpr
        {
          op = `BOOLTOBV1;
          arg =
            BinaryExpr
              { op = `EQ; arg1; arg2 = Constant { const = `Bitvector bv } };
        }
      when Bitvec.is_zero bv ->
        Some (Z (extract_expr (fix arg1)))
    | UnaryExpr { op = `Extract (e1, e2); arg }
      when e1 = e2 + 1
           && Option.equal ( = )
                (Types.bit_width @@ type_of (fix2 arg))
                (Some e1) ->
        Some (N (extract_expr (fix2 arg)))
    | _ -> None
end

(** Add flag semantic annotations as attributes for debugging *)
let annotate_flag_assigns stmt =
  let open Stmt in
  match stmt with
  | Instr_Assign { attrib; al } ->
      let annotations =
        al
        |> List.filter (fun (v, _) ->
            Types.equal (Var.typ v) (Types.Bitvector 1))
        |> List.filter_map (fun (v, e) ->
            let o = FlagSemantics.extract_semantics e in
            if
              Option.is_none o
              && String.starts_with ~prefix:"$PSTATE_" (Var.name v)
            then
              Logs.debug (fun m ->
                  m "%s had no assigned semantic meaning for expr %s"
                    (Var.name v)
                    (Expr.BasilExpr.to_string (Algsimp.normalise e)));
            o |> Option.map (fun s -> (v, s)))
      in
      let attrib =
        List.fold_left
          (fun attrib (v, s) ->
            StringMap.add
              (".flag_semantics_" ^ Var.name v)
              (`String (FlagSemantics.show s))
              attrib)
          attrib annotations
      in
      Instr_Assign { attrib; al }
  | _ -> stmt

let annotate_flag_assign_stmts (p : Program.proc) =
  Procedure.map_blocks_nondet
    (fun (bid, block) -> Block.map ~phi:id annotate_flag_assigns block)
    p

module FlagLattice = struct
  include Analysis.Lattice_types.FlatLattice (struct
    include FlagSemantics

    let name = "flag"
  end)

  let contains_var v x =
    match x with
    | Top -> false
    | Bot -> false
    | V f -> FlagSemantics.contains_var v f
end

(** Assigns flag meaning values to flag variables at each code point. If a flag
    assumes a value of a variable that gets updated, that flags value will get
    dropped and set to top. This should be precise enough still as branches
    probably only occur direct after flags are set (probably). Note that none of
    this is a problem if ssa is run prior to this transform. *)
module FlagDomain = struct
  include Analysis.Intra_analysis.MapState (FlagLattice)

  let name = "pstate-flag-analysis"

  (* Assume nothing about the initial state *)
  let init ?vertex _ =
    match vertex with Some (Some Procedure.Vert.Entry) -> top | _ -> bottom

  (** Remove flags from state that referred to [v] (e.g. if [v] was updated) *)
  let drop_modified v =
    mapi (fun v' x ->
        if FlagLattice.contains_var v x then FlagLattice.top else x)

  let transfer m stmt =
    match stmt with
    | Stmt.Instr_Assign { al } ->
        List.fold_left
          (fun m (v, e) ->
            let m = drop_modified v m in
            (* If v is a bv1, update map with extract results *)
            if Types.equal (Var.typ v) (Types.Bitvector 1) then
              let f =
                FlagSemantics.extract_semantics e
                |> Option.map (fun f -> FlagLattice.V f)
                |> Option.get_or ~default:FlagLattice.top
              in
              update v f m
            else m)
          m al
    | _ -> m

  let transfer_phi m (p : Var.t Block.phi) =
    match p with
    | { lhs; rhs } ->
        (* assume phis never assign to in use variables (yikes) *)
        rhs
        |> List.map (fun (_, k) -> read k m)
        |> List.fold_left FlagLattice.join FlagLattice.bottom
        |> fun v -> drop_modified lhs m |> update lhs v
end

module FlagAnalysis = struct
  include Analysis.Intra_analysis.Forwards (FlagDomain)

  let analyse p = analyse p
end

let annotate_stmt_flags m stmt =
  let open Stmt in
  match stmt with
  | Instr_Assume { attrib; body; branch } ->
      let annotations =
        FlagDomain.to_list m |> snd
        |> List.filter_map (fun (v, s) ->
            match s with FlagLattice.V s -> Some (v, s) | _ -> None)
      in
      let attrib =
        List.fold_left
          (fun attrib (v, s) ->
            StringMap.add
              (".flag_semantics_" ^ Var.name v)
              (`String (FlagSemantics.show s))
              attrib)
          attrib annotations
      in
      Instr_Assume { attrib; body; branch }
  | _ -> stmt

(** Add flag annotations to assume statements based on flag variables prior *)
let annotate_assume_flags (p : Program.proc) =
  let a = FlagAnalysis.analyse p in
  Procedure.map_blocks_nondet
    (fun (bid, b) ->
      let r =
        FlagAnalysis.A.M.find_opt (Procedure.Vert.Begin bid) a
        |> Option.get_or ~default:FlagDomain.top
      in
      Block.map_fold_forwards
        ~phi:(fun m phi -> (List.fold_left FlagDomain.transfer_phi m phi, phi))
        ~f:(fun m stmt ->
          (FlagDomain.transfer m stmt, annotate_stmt_flags m stmt))
        r b
      |> snd)
    p

let transform = annotate_assume_flags

let%expect_test "flag_types" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
var $R0:bv64;
var $R1:bv64;
var $H2:bv64;
var $H3:bv64;
var $PSTATE_N:bv1;
var $PSTATE_Z:bv1;
var $PSTATE_C:bv1;
var $PSTATE_V:bv1;

proc @main() -> ()
[
  block %main [
     $PSTATE_V:bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(extract(32,0, $R0), 0x1:bv32)), bvadd(sign_extend(32, extract(32,0, $R0)), 0x1:bv64))));
     $PSTATE_V:bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32,0, $R0), 0xfffffffd:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32,0, $R0)), 0xfffffffffffffffd:bv64), 0x1:bv64))));
     $PSTATE_V:bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32,0, $R0), bvnot(bvshl(extract(32,0, $R1), zero_extend(20, 0x0:bv12)))), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32,0, $R0)), sign_extend(32, bvnot(bvshl(extract(32,0, $R1), zero_extend(20, 0x0:bv12))))), 0x1:bv64))));
     $PSTATE_V:bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(local_31:bv32, bvshl(local_32:bv32, zero_extend(20, 0x0:bv12)))), bvadd(sign_extend(32, local_31:bv32), sign_extend(32, bvshl(local_32:bv32, zero_extend(20, 0x0:bv12)))))));

     $PSTATE_C:bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(extract(32,0, $R0), 0x1:bv32)), bvadd(zero_extend(32, extract(32,0, $R0)), 0x1:bv64))));
     $PSTATE_C:bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32,0, $R0), 0xfffffffd:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32,0, $R0)), 0xfffffffd:bv64), 0x1:bv64))));
     $PSTATE_C:bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32,0, $R0), bvnot(bvshl(extract(32,0, $R1), zero_extend(20, 0x0:bv12)))), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32,0, $R0)), zero_extend(32, bvnot(bvshl(extract(32,0, $R1), zero_extend(20, 0x0:bv12))))), 0x1:bv64))));
     $PSTATE_C:bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd($H2:bv32, bvshl($H3:bv32, zero_extend(20, 0x0:bv12)))), bvadd(zero_extend(32, $H2:bv32), zero_extend(32, bvshl($H3:bv32, zero_extend(20, 0x0:bv12)))))));

     $PSTATE_Z:bv1 := booltobv1(eq(bvadd($H2:bv32, bvshl($H3:bv32, zero_extend(20, 0x0:bv12))), 0x0:bv32));
     $PSTATE_Z:bv1 := booltobv1(eq(bvadd(extract(32,0, $R0), 0x1:bv32), 0x0:bv32));
     $PSTATE_Z:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R0), bvnot(bvshl(extract(32,0, $R1), zero_extend(20, 0x0:bv12)))), 0x1:bv32), 0x0:bv32));

     $PSTATE_N:bv1 := extract(32,31, bvadd(extract(32,0, $R0), 0x1:bv32));
     $PSTATE_N:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R0), bvnot(bvshl(extract(32,0, $R1), zero_extend(20, 0x0:bv12)))), 0x1:bv32));
     $PSTATE_N:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R0), 0xffffffff:bv32), 0x1:bv32));

     // should not be annotated!
     $PSTATE_N:bv1 := extract(31,30, bvadd(extract(32,0, $R0), 0x1:bv32));
     $PSTATE_N:bv1 := extract(31,30, bvadd(bvadd(extract(32,0, $R0), bvnot(bvshl(extract(32,0, $R1), zero_extend(20, 0x0:bv12)))), 0x1:bv32));
     $PSTATE_N:bv1 := extract(31,30, bvadd(bvadd(extract(32,0, $R0), 0xffffffff:bv32), 0x1:bv32));

     $PSTATE_V:bv1 := 0x0:bv1;
     $PSTATE_C:bv1 := 0x0:bv1;
     $PSTATE_Z:bv1 := 0x1:bv1;
     $PSTATE_N:bv1 := 0x0:bv1;

    goto (%ret);
  ];
  block %ret [ return; ]
];

prog entry @main;
    |}
  in
  let prog =
    lst.prog |> Program.map_procedures (fun _ -> annotate_flag_assign_stmts)
  in
  print_endline
  @@ Containers_pp.Pretty.to_string ~width:800 (Lang.Program.prog_pretty prog);
  [%expect
    {|
    var $R0:bv64;
    var $R1:bv64;
    var $H2:bv64;
    var $H3:bv64;
    var $PSTATE_N:bv1;
    var $PSTATE_Z:bv1;
    var $PSTATE_C:bv1;
    var $PSTATE_V:bv1;
    proc @main()  -> () {  }
      modifies $PSTATE_C:bv1, $PSTATE_N:bv1, $PSTATE_V:bv1, $PSTATE_Z:bv1
      captures $H2:bv64, $H3:bv64, $PSTATE_C:bv1, $PSTATE_N:bv1, $PSTATE_V:bv1, $PSTATE_Z:bv1, $R0:bv64, $R1:bv64

    [
       block %main [
         $PSTATE_V:bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(extract(32,0, $R0), 0x1:bv32)), bvadd(sign_extend(32, extract(32,0, $R0)), 0x1:bv64)))) { .flag_semantics_$PSTATE_V = "(O (Sum (extract(32,0, $R0), 0x1:bv32)))" };
         $PSTATE_V:bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32,0, $R0), 0xfffffffd:bv32), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32,0, $R0)), 0xfffffffffffffffd:bv64), 0x1:bv64)))) { .flag_semantics_$PSTATE_V = "(O (Diff (extract(32,0, $R0), 0x2:bv32)))" };
         $PSTATE_V:bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(bvadd(extract(32,0, $R0), bvnot(bvshl(extract(32,0, $R1), zero_extend(20, 0x0:bv12)))), 0x1:bv32)), bvadd(bvadd(sign_extend(32, extract(32,0, $R0)), sign_extend(32, bvnot(bvshl(extract(32,0, $R1), zero_extend(20, 0x0:bv12))))), 0x1:bv64)))) { .flag_semantics_$PSTATE_V = "(O (Diff (extract(32,0, $R0), extract(32,0, $R1))))" };
         $PSTATE_V:bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(local_31:bv32, bvshl(local_32:bv32, zero_extend(20, 0x0:bv12)))), bvadd(sign_extend(32, local_31:bv32), sign_extend(32, bvshl(local_32:bv32, zero_extend(20, 0x0:bv12))))))) { .flag_semantics_$PSTATE_V = "(O (Sum (local_31:bv32, local_32:bv32)))" };
         $PSTATE_C:bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(extract(32,0, $R0), 0x1:bv32)), bvadd(zero_extend(32, extract(32,0, $R0)), 0x1:bv64)))) { .flag_semantics_$PSTATE_C = "(O (Sum (extract(32,0, $R0), 0x1:bv32)))" };
         $PSTATE_C:bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32,0, $R0), 0xfffffffd:bv32), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32,0, $R0)), 0xfffffffd:bv64), 0x1:bv64)))) { .flag_semantics_$PSTATE_C = "(C (Diff (extract(32,0, $R0), 0x2:bv32)))" };
         $PSTATE_C:bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(bvadd(extract(32,0, $R0), bvnot(bvshl(extract(32,0, $R1), zero_extend(20, 0x0:bv12)))), 0x1:bv32)), bvadd(bvadd(zero_extend(32, extract(32,0, $R0)), zero_extend(32, bvnot(bvshl(extract(32,0, $R1), zero_extend(20, 0x0:bv12))))), 0x1:bv64)))) { .flag_semantics_$PSTATE_C = "(C (Diff (extract(32,0, $R0), extract(32,0, $R1))))" };
         $PSTATE_C:bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd($H2, bvshl($H3, zero_extend(20, 0x0:bv12)))), bvadd(zero_extend(32, $H2), zero_extend(32, bvshl($H3, zero_extend(20, 0x0:bv12))))))) { .flag_semantics_$PSTATE_C = "(C (Sum ($H2, $H3)))" };
         $PSTATE_Z:bv1 := booltobv1(eq(bvadd($H2, bvshl($H3, zero_extend(20, 0x0:bv12))), 0x0:bv32)) { .flag_semantics_$PSTATE_Z = "(Z (Sum ($H2, $H3)))" };
         $PSTATE_Z:bv1 := booltobv1(eq(bvadd(extract(32,0, $R0), 0x1:bv32), 0x0:bv32)) { .flag_semantics_$PSTATE_Z = "(Z (Sum (extract(32,0, $R0), 0x1:bv32)))" };
         $PSTATE_Z:bv1 := booltobv1(eq(bvadd(bvadd(extract(32,0, $R0), bvnot(bvshl(extract(32,0, $R1), zero_extend(20, 0x0:bv12)))), 0x1:bv32), 0x0:bv32)) { .flag_semantics_$PSTATE_Z = "(Z (Diff (extract(32,0, $R0), extract(32,0, $R1))))" };
         $PSTATE_N:bv1 := extract(32,31, bvadd(extract(32,0, $R0), 0x1:bv32)) { .flag_semantics_$PSTATE_N = "(N (Sum (extract(32,0, $R0), 0x1:bv32)))" };
         $PSTATE_N:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R0), bvnot(bvshl(extract(32,0, $R1), zero_extend(20, 0x0:bv12)))), 0x1:bv32)) { .flag_semantics_$PSTATE_N = "(N (Diff (extract(32,0, $R0), extract(32,0, $R1))))" };
         $PSTATE_N:bv1 := extract(32,31, bvadd(bvadd(extract(32,0, $R0), 0xffffffff:bv32), 0x1:bv32)) { .flag_semantics_$PSTATE_N = "(N (Expr extract(32,0, $R0)))" };
         $PSTATE_N:bv1 := extract(31,30, bvadd(extract(32,0, $R0), 0x1:bv32));
         $PSTATE_N:bv1 := extract(31,30, bvadd(bvadd(extract(32,0, $R0), bvnot(bvshl(extract(32,0, $R1), zero_extend(20, 0x0:bv12)))), 0x1:bv32));
         $PSTATE_N:bv1 := extract(31,30, bvadd(bvadd(extract(32,0, $R0), 0xffffffff:bv32), 0x1:bv32));
         $PSTATE_V:bv1 := 0x0:bv1 { .flag_semantics_$PSTATE_V = "Never" };
         $PSTATE_C:bv1 := 0x0:bv1 { .flag_semantics_$PSTATE_C = "Never" };
         $PSTATE_Z:bv1 := 0x1:bv1 { .flag_semantics_$PSTATE_Z = "Always" };
         $PSTATE_N:bv1 := 0x0:bv1 { .flag_semantics_$PSTATE_N = "Never" };
         goto (%ret);
       ];
       block %ret [ return; ]
    ];
    prog entry @main;
    |}]

let%expect_test "flag_tracking" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
var $R0:bv64;
var $R1:bv64;
var $H2:bv64;
var $H3:bv64;
var $PSTATE_N:bv1;
var $PSTATE_Z:bv1;
var $PSTATE_C:bv1;
var $PSTATE_V:bv1;

proc @main() -> ()
[
  block %main [
     $PSTATE_V:bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(extract(32,0, $R0), 0x1:bv32)), bvadd(sign_extend(32, extract(32,0, $R0)), 0x1:bv64))));
     $PSTATE_C:bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(extract(32,0, $R0), 0x1:bv32)), bvadd(zero_extend(32, extract(32,0, $R0)), 0x1:bv64))));
     $PSTATE_Z:bv1 := booltobv1(eq(bvadd(extract(32,0, $R0), 0x1:bv32), 0x0:bv32));
     $PSTATE_N:bv1 := extract(32,31, bvadd(extract(32,0, $R0), 0x1:bv32));

     assume booland(eq($PSTATE_N, $PSTATE_V), eq($PSTATE_Z, 0x0:bv1));

     $R0:bv64 := bvadd($R0:bv64, 0xdeadbeef:bv64);

     assume booland(eq($PSTATE_N, $PSTATE_V), eq($PSTATE_Z, 0x0:bv1));

     $PSTATE_V:bv1 := 0x0:bv1;
     $PSTATE_C:bv1 := 0x0:bv1;
     $PSTATE_Z:bv1 := 0x1:bv1;
     $PSTATE_N:bv1 := 0x0:bv1;

     assume booland(eq($PSTATE_N, $PSTATE_V), eq($PSTATE_Z, 0x0:bv1));

     $R0:bv64 := bvadd($R0:bv64, 0xdeadbeef:bv64);

     assume booland(eq($PSTATE_N, $PSTATE_V), eq($PSTATE_Z, 0x0:bv1));

    goto (%ret);
  ];
  block %ret [ return; ]
];

prog entry @main;
    |}
  in
  let prog =
    lst.prog |> Program.map_procedures (fun _ -> annotate_assume_flags)
  in
  print_endline
  @@ Containers_pp.Pretty.to_string ~width:800 (Lang.Program.prog_pretty prog);
  [%expect
    {|
    var $R0:bv64;
    var $R1:bv64;
    var $H2:bv64;
    var $H3:bv64;
    var $PSTATE_N:bv1;
    var $PSTATE_Z:bv1;
    var $PSTATE_C:bv1;
    var $PSTATE_V:bv1;
    proc @main()  -> () {  }
      modifies $PSTATE_C:bv1, $PSTATE_N:bv1, $PSTATE_V:bv1, $PSTATE_Z:bv1, $R0:bv64
      captures $PSTATE_C:bv1, $PSTATE_N:bv1, $PSTATE_V:bv1, $PSTATE_Z:bv1, $R0:bv64

    [
       block %main [
         $PSTATE_V:bv1 := bvnot(booltobv1(eq(sign_extend(32, bvadd(extract(32,0, $R0), 0x1:bv32)), bvadd(sign_extend(32, extract(32,0, $R0)), 0x1:bv64))));
         $PSTATE_C:bv1 := bvnot(booltobv1(eq(zero_extend(32, bvadd(extract(32,0, $R0), 0x1:bv32)), bvadd(zero_extend(32, extract(32,0, $R0)), 0x1:bv64))));
         $PSTATE_Z:bv1 := booltobv1(eq(bvadd(extract(32,0, $R0), 0x1:bv32), 0x0:bv32));
         $PSTATE_N:bv1 := extract(32,31, bvadd(extract(32,0, $R0), 0x1:bv32));
         assume booland(eq($PSTATE_N, $PSTATE_V), eq($PSTATE_Z, 0x0:bv1)) { .flag_semantics_$PSTATE_C = "(O (Sum (extract(32,0, $R0), 0x1:bv32)))"; .flag_semantics_$PSTATE_N = "(N (Sum (extract(32,0, $R0), 0x1:bv32)))"; .flag_semantics_$PSTATE_V = "(O (Sum (extract(32,0, $R0), 0x1:bv32)))"; .flag_semantics_$PSTATE_Z = "(Z (Sum (extract(32,0, $R0), 0x1:bv32)))" };
         $R0:bv64 := bvadd($R0, 0xdeadbeef:bv64);
         assume booland(eq($PSTATE_N, $PSTATE_V), eq($PSTATE_Z, 0x0:bv1));
         $PSTATE_V:bv1 := 0x0:bv1;
         $PSTATE_C:bv1 := 0x0:bv1;
         $PSTATE_Z:bv1 := 0x1:bv1;
         $PSTATE_N:bv1 := 0x0:bv1;
         assume booland(eq($PSTATE_N, $PSTATE_V), eq($PSTATE_Z, 0x0:bv1)) { .flag_semantics_$PSTATE_C = "Never"; .flag_semantics_$PSTATE_N = "Never"; .flag_semantics_$PSTATE_V = "Never"; .flag_semantics_$PSTATE_Z = "Always" };
         $R0:bv64 := bvadd($R0, 0xdeadbeef:bv64);
         assume booland(eq($PSTATE_N, $PSTATE_V), eq($PSTATE_Z, 0x0:bv1)) { .flag_semantics_$PSTATE_C = "Never"; .flag_semantics_$PSTATE_N = "Never"; .flag_semantics_$PSTATE_V = "Never"; .flag_semantics_$PSTATE_Z = "Always" };
         goto (%ret);
       ];
       block %ret [ return; ]
    ];
    prog entry @main;
    |}]

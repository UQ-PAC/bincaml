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
  [@@deriving show { with_path = false }]

  let extract_overflow_cary arg1 arg2 =
    let open Types in
    let open Expr.AbstractExpr in
    let open Expr.BasilExpr in
    let equal e1 e2 = equal (drop_attrib e1) (drop_attrib e2) in
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
      when s1 = s2 && s1 > 0 && equal (fix a) (fix c) && sext_eq s1 bv1 bv2 ->
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
           && equal (fix a) (fix c)
           && equal (fix b) (fix d) ->
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
           && equal (fix a) (fix c)
           && equal (fix b) (fix d) ->
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
      when z1 = z2 && z1 > 0 && equal (fix a) (fix c) && zext_eq z1 bv1 bv2 ->
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
           && equal (fix a) (fix c)
           && equal (fix b) (fix d) ->
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
           && equal (fix a) (fix c)
           && equal (fix b) d
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
    let is_msb e (top, bot) =
      top = bot + 1
      && Option.equal ( = ) (Types.bit_width @@ type_of e) (Some top)
    in
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
    | UnaryExpr { op = `Extract ex; arg } when is_msb (fix2 arg) ex ->
        Some (N (extract_expr (fix2 arg)))
    | _ -> None
end

(** Add flag semantic annotations as attributes for debugging *)
let annotate_flag_assigns stmt =
  let open Stmt in
  match stmt with
  | Instr_Assign { attrib; al } ->
      let annotations =
        List.filter_map
          (fun (v, e) ->
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
          al
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

let transform = annotate_flag_assign_stmts

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

open Bincaml_util.Common
open Lang

(* instead of rewriting shapes, we should perform an analysis that assigns to each flag+codepoint an abstract value corresponding to its semantic meaning! Then we can rewrite assumes with the semantic meaning!
   For soundness, delete terms of the analysis value map whenever a variable present in the map is assigned to.
   This should not lose any precision since branch conditions should only occur directly after flag assignment!
 *)

module FlagSemantics = struct
  type t =
    | Never
    | Always
    | OverflowByConst of Expr.BasilExpr.t * Bitvec.t
        (** Overflow when adding expr and const *)
    | OverflowByDiff of Expr.BasilExpr.t * Expr.BasilExpr.t
        (** Overflow when subtracting first from second *)
  [@@deriving show]
end

let extract_semantics e =
  let e = Algsimp.normalise e in
  let open Expr.AbstractExpr in
  let open Expr.BasilExpr in
  let sext_eq extension bv1 bv2 =
    Bitvec.equal (Bitvec.sign_extend ~extension bv1) bv2
  in
  match unfix3 e with
  | Constant { const = `Bitvector k } when Bitvec.equal k (Bitvec.zero ~size:1)
    ->
      Some FlagSemantics.Never
  | Constant { const = `Bitvector k } when Bitvec.equal k (Bitvec.one ~size:1)
    ->
      Some FlagSemantics.Always
  | UnaryExpr
      {
        op = `BVNOT;
        arg =
          UnaryExpr
            { op = `BOOLTOBV1; arg = BinaryExpr { op = `EQ; arg1; arg2 } };
      } -> (
      match (unfix3 arg1, unfix3 arg2) with
      | ( UnaryExpr
            {
              op = `SignExtend s1;
              arg =
                ApplyIntrin
                  {
                    op = `BVADD;
                    args =
                      [
                        a;
                        Constant { const = `Bitvector bv1; typ = Bitvector k1 };
                      ];
                  };
            },
          ApplyIntrin
            {
              op = `BVADD;
              args =
                [
                  UnaryExpr { op = `SignExtend s2; arg = c };
                  Constant { const = `Bitvector bv2; typ = Bitvector k2 };
                ];
            } )
        when s1 = s2 && s1 > 0
             && equal (fix a) (fix c)
             && k2 = k1 + s1
             && sext_eq s1 bv1 bv2 ->
          Some (FlagSemantics.OverflowByConst (fix a, bv1))
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
        when s1 = s2 && s2 = s3
             && equal (fix a) (fix c)
             && equal (fix b) (fix d) ->
          Some (FlagSemantics.OverflowByDiff (fix a, fix b))
      | _ -> None)
  | _ -> None

(** Add flag semantic annotations as attributes for debugging *)
let annotate_stmt stmt =
  let open Stmt in
  match stmt with
  | Instr_Assign { attrib; al } ->
      let annotations =
        List.filter_map
          (fun (v, e) -> extract_semantics e |> Option.map (fun s -> (v, s)))
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

let transform (p : Program.proc) =
  Procedure.map_blocks_nondet
    (fun (bid, block) -> Block.map ~phi:id annotate_stmt block)
    p

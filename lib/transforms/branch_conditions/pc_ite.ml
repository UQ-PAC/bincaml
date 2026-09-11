(** Rewrite gotos after PC if-then-else (ite) assignments to assert conditions
    on the ite before the target goto block.

    {[
    block %block_22 [
      $PC:bv64 := if boolnot(eq($R19, 0x0:bv64)) then 0xce14:bv64 else 0xce08:bv64;
      goto (%paclist_get_code_21);
    ];
    block %paclist_get_code_21 [
      assert boolor(eq(0xce08:bv64, $PC), eq(0xce14:bv64, $PC));
      goto (%paclist_get_code_14,%paclist_get_code_1);
    ];
    ]}
    Here, before [%paclist_get_code_14] we would want to assume either
    [boolnot(eq($R19, 0x0:bv64))] or its negation! This module performs such
    rewrites. *)

open Lang
open Common

module PcValue = struct
  type 'a t = { cond : 'a; t_case : Bitvec.t; f_case : Bitvec.t }
  [@@deriving show { with_path = false }, ord, eq]

  let extract_value (f : Expr.BasilExpr.t -> 'a option) (e : Expr.BasilExpr.t) :
      'a t option =
    let open Expr.BasilExpr in
    match unfix3 e with
    | ApplyIntrin
        {
          op = `Cases;
          args =
            [
              BinaryExpr
                {
                  op = `IfThen;
                  arg1 = cond;
                  arg2 = Constant { const = `Bitvector t_case };
                };
              Constant { const = `Bitvector f_case };
            ];
        } ->
        f (fix cond) |> Option.map (fun cond -> { cond; t_case; f_case })
    | _ -> None
end

(** A (semi-direct?) product domain that simultaneously finds flags and uses
    those flags to identify PC values. *)
module PcDomain = struct
  open Cfg_analysis

  let name = "TODO"

  type t = {
    flags : FlagDomain.t;
        [@printer fun fmt -> fprintf fmt "%s" % FlagDomain.show]
    pc : Rewriter.t PcValue.t option;
  }
  [@@deriving show { with_path = false }, ord, eq]

  let pretty = Containers_pp.text % show
  let top = { flags = FlagDomain.top; pc = None }
  let bottom = { flags = FlagDomain.bottom; pc = None }

  let join a b =
    {
      flags = FlagDomain.join a.flags b.flags;
      pc =
        (if Option.equal (PcValue.equal Rewriter.equal) a.pc b.pc then a.pc
         else None);
    }

  let leq a b = FlagDomain.leq a.flags b.flags
  let widening = join
  let narrowing = const

  let init ?vertex _ =
    match vertex with Some (Some Procedure.Vert.Entry) -> top | _ -> bottom

  let transfer state stmt =
    match stmt with
    | Stmt.Instr_Assign { al } ->
        let flags = FlagDomain.transfer state.flags stmt in
        let pc =
          List.fold_left
            (fun pc (_v, e) ->
              (* HACK: the variable is ignored here... we assume that any
                 assignment that looks like a PC ite is a PC ite... *)
              PcValue.extract_value
                (fun cond ->
                  match
                    Rewriter.extract_condition flags (Expr.BasilExpr.unfix cond)
                  with
                  | Top -> None
                  | a -> Some a)
                e
              |> Option.map (fun pc -> Some pc)
              |> Option.get_or ~default:pc)
            state.pc al
        in
        { flags; pc }
    | _ -> state

  let transfer_phi state (p : Var.t Block.phi) =
    let flags = FlagDomain.transfer_phi state.flags p in
    { flags; pc = None }
end

module PcAnalysis = Analysis.Intra_analysis.Forwards (PcDomain)

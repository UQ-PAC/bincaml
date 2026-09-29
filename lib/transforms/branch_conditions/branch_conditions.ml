open Bincaml_util.Common
open Lang

(* TODO:
    - Handle ccmp instructions (where branch conditions depend on branch conditions, needing a depth 1 path sensitive analysis)
    - Handle registers being overwritten before branching (SSA):
        there was an instance of
        cmn w0, #1
        mov w0, #0
        b.ne #0xfffffffffffffff0
        in cntlm. Here w0 gets overwritten before we can identify a branch condition in terms of w0's current value...
  every failing branch condition in cntlm is of one of these two forms!
    - adcs (add with carry set flags) and sbcs
*)

module Flags = Flags
module Analysis = Cfg_analysis
module Rewriter = Rewriter
module Pc_ite = Pc_ite

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
            let o = Flags.extract_semantics e in
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
              (`String (Flags.show s))
              attrib)
          attrib annotations
      in
      Instr_Assign { attrib; al }
  | _ -> stmt

let annotate_flag_assign_stmts (p : Program.proc) =
  Procedure.map_blocks_nondet
    (fun (bid, block) -> Block.map ~phi:id annotate_flag_assigns block)
    p

let annotate_stmt_flags m stmt =
  let open Stmt in
  match stmt with
  | Instr_Assume { attrib; body; branch } ->
      let annotations =
        Analysis.FlagDomain.to_list m
        |> snd
        |> List.filter_map (fun (v, s) ->
            match s with Analysis.FlagLattice.V s -> Some (v, s) | _ -> None)
      in
      let attrib =
        List.fold_left
          (fun attrib (v, s) ->
            StringMap.add
              (".flag_semantics_" ^ Var.name v)
              (`String (Flags.show s))
              attrib)
          attrib annotations
      in
      Instr_Assume { attrib; body; branch }
  | _ -> stmt

let rewrite_stmt_conditions m =
  Stmt.map ~f_lvar:id ~f_rvar:id ~f_expr:(Rewriter.rewrite_expr m)

(** Map statements of a procedure given FlagAnalysis results *)
let stmt_transform trans (p : Program.proc) =
  let open Analysis in
  let a = FlagAnalysis.analyse p in
  Procedure.map_blocks_nondet
    (fun (bid, b) ->
      let r =
        FlagAnalysis.A.M.find_opt (Procedure.Vert.Begin bid) a
        |> Option.get_or ~default:FlagDomain.top
      in
      Block.map_fold_forwards
        ~phi:(fun m phi -> (List.fold_left FlagDomain.transfer_phi m phi, phi))
        ~f:(fun m stmt -> (FlagDomain.transfer m stmt, trans m stmt))
        r b
      |> snd)
    p

(** Add flag annotations to assume statements based on flag variables prior
    (debugging) *)
let annotate_assume_flags = stmt_transform annotate_stmt_flags

(** Rewrite boolean expressions of flags into numerical conditions *)
let rewrite_conditions = stmt_transform rewrite_stmt_conditions

let transform = rewrite_conditions %> Pc_ite.transform

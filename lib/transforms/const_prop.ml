(** Constant propagation

    Currently we only do interprocedural constant propagation of linear
    expressions.*)

open Bincaml_util.Common
open Lang
open Analysis.Linear_const
open Expr

(* TODO can write an intra const prop that uses interproc function summaries
   (would depend on analysis context values passed to transfer functions) *)

let prop_expr (prop : Var.t -> Bitvec.t option) =
  let open BasilExpr in
  let open Expr_rewrite in
  rewrite ~rw_fun:(function
    | RVar v -> (
        match prop v.id with
        | Some x -> replace [%here] (const (`Bitvector x))
        | _ -> Keep)
    | _ -> Keep)

let transform_proc r keep =
  let prop v =
    if keep v then None
    else VarMap.find_opt v r |> Option.flat_map LinearIDE.Value.get_val
  in
  Procedure.map_blocks_topo_fwd (fun _ ->
      Block.map ~phi:id
        (Stmt.map ~f_lvar:id ~f_expr:(prop_expr prop) ~f_rvar:id))

let linear_transform (prog : Program.t) =
  let _, r = LinearConstAnalysis.solve prog in

  Program.map_procedures
    (fun pid proc -> transform_proc (IDMap.find pid r) (fun _ -> false) proc)
    prog

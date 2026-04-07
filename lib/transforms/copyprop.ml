(** Copy propagation *)

open Bincaml_util.Common
open Lang
open Analysis.Inter_copy

let transform_proc (p : Program.t) g (proc : Program.proc) =
  let parent v =
    VarMap.get v g
    |> Option.get_lazy (fun _ -> CopyNode.init v)
    |> CopyNode.find |> CopyNode.var
  in

  Procedure.map_blocks_nondet
    (fun (bid, block) ->
      Block.map
        ~phi:
          (List.map (fun (p : Var.t Block.phi) ->
               { p with rhs = List.map (fun (bid, v) -> (bid, parent v)) p.rhs }))
        (Stmt.map ~f_lvar:id ~f_expr:id ~f_rvar:parent)
        block)
    proc

let transform (p : Program.t) =
  let gs = Solver.solve p in

  let procs =
    IDMap.mapi
      (fun pid proc -> transform_proc p (Hashtbl.find gs pid) proc)
      p.procs
  in

  { p with procs }

(** Copy propagation *)

open Bincaml_util.Common
open Lang
open Analysis.Inter_copy

let transform_proc (p : Program.t) g (proc : Program.proc) =
  let copied_by v =
    VarMap.get v g
    |> Option.map (CopyNode.var % CopyNode.find)
    |> Option.get_or ~default:v
  in

  Procedure.map_blocks_nondet
    (fun (bid, block) ->
      Block.map
        ~phi:
          (List.map (fun (p : Var.t Block.phi) ->
               {
                 p with
                 rhs = List.map (fun (bid, v) -> (bid, copied_by v)) p.rhs;
               }))
        (Stmt.map ~f_lvar:id
           ~f_expr:
             Expr.BasilExpr.(substitute (fun v -> Some (rvar @@ copied_by v)))
           ~f_rvar:copied_by)
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

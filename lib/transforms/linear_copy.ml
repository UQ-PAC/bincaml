(** Linear expression copy propagation *)

open Bincaml_util.Common
open Lang
open Analysis.Linear_const

let expr_of f v =
  let open LF in
  let open Expr.BasilExpr in
  match f with
  | IdEdge -> Some (rvar v)
  | Linear (a, b) ->
      Some
        (applyintrin ~op:`BVADD
           [ applyintrin ~op:`BVMUL [ rvar v; bvconst a ]; bvconst b ])
  | _ -> None

let transform_proc (p : Program.t) g (proc : Program.proc) =
  let copied_by v =
    VarMap.get v g
    |> Option.map CopyNode.(var % find_copy)
    |> Option.get_or ~default:v
  in
  let trans v =
    VarMap.get v g
    |> Option.flat_map (fun n ->
        let f, n = CopyNode.find n in
        match f with IdEdge | Linear _ -> Some (f, CopyNode.var n) | _ -> None)
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
             Expr.BasilExpr.(
               substitute (fun v ->
                   trans v |> Option.flat_map (fun (f, v') -> expr_of f v')))
           ~f_rvar:copied_by)
        block)
    proc

let transform (p : Program.t) =
  let gs = Solver.solve p in

  Trace_core.with_span ~__FILE__ ~__LINE__ "transform" @@ fun _ ->
  Program.map_procedures
    (fun pid proc ->
      Hashtbl.find_opt gs pid
      |> Option.map_or ~default:proc (flip (transform_proc p) proc))
    p

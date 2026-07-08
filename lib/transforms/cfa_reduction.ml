open Lang
open Lang.Common

(* Assumptions: SSA form probably? seems good to me! *)
(* Also that the program is pure and lacks loops... *)
let reduce_procedure (proc : Program.proc) : Program.proc =
  (* Liveness of variables at start of edge. *)
  (* let live : (Procedure.Edge.block, VarSet.t) Hashtbl.t = *)
  (* Procedure.blocks_to_list proc *)
  (* |> List.map (fun (v, b) -> (b, Block.free_vars b)) *)
  (* |> Hashtbl.of_list *)
  (* in *)

  (* Termination condition for each edge. *)
  let term : (IDSet.elt, Var.t) Hashtbl.t = Hashtbl.create 30 in

  (* Constructed reduced edge to replace procedure edges. *)
  let final_edge =
    Procedure.fold_blocks_topo_fwd
      (fun final_edge id block ->
        let preds = Procedure.blocks_pred proc id |> Iter.to_list in

        (* Compute reachability of this block. *)
        let reachable =
          (* Always reachable if no predecessors. *)
          if List.is_empty preds then Expr.BasilExpr.boolconst true
          (* Otherwise, reachability is ANY of the predecessors reachability. *)
            else
            Expr.BasilExpr.applyintrin ~op:`OR
              (preds
              |> List.filter_map (fst %> Hashtbl.get term)
              |> List.map Expr.BasilExpr.rvar)
        in

        (* Create ITE statements from phi nodes. *)
        let ites : Program.stmt =
          let al =
            block.phis
            |> List.map (function
              | ({ lhs; rhs = hd :: tl } : Var.t Block.phi) ->
                  let ite =
                    List.fold_left
                      (fun acc (in_edge, var) ->
                        Expr.BasilExpr.ifthenelse
                          (Expr.BasilExpr.rvar @@ Hashtbl.find term in_edge)
                          (Expr.BasilExpr.rvar var) acc)
                      (Expr.BasilExpr.rvar @@ snd hd)
                      tl
                  in
                  (lhs, ite)
              | _ -> failwith "Encountered phi node with no rhs.")
          in
          Stmt.Instr_Assign { attrib = Attrib.empty; al }
        in

        (* Construct our termination condition by combining
          initial reachability with any assumes along this edge. *)
        let termination_var =
          Procedure.fresh_var proc ~pure:true Types.Boolean
        in
        Hashtbl.add term id termination_var;
        let termination_cond = reachable in
        let termination =
          Stmt.Instr_Assign
            {
              attrib = Attrib.empty;
              al = [ (termination_var, termination_cond) ];
            }
        in

        final_edge
        @ List.concat
            [ [ ites ]; block.stmts |> Vector.to_list; [ termination ] ])
      List.empty proc
  in

  failwith ""

(* module Reduction = struct *)
(* type t = { *)
(* Variables live at the start of an edge. *)
(* TODO: should be Edge -> Varset.t *)
(* live : (Procedure.Edge.block, VarSet.t) Hashtbl.t; *)
(* Terminating condition variable for each edge. *)
(* term : (Procedure.Edge.block, Var.t) Hashtbl.t; *)
(* Variable renaming at termination of an edge. *)
(* names : (Procedure.Edge.block, Var.t) Hashtbl.t; *)
(* Statement list of the new single-edge procedure. *)
(* final_edge : Program.stmt list; *)
(* } *)

(* let create (proc : Program.proc) : t = *)
(* { *)
(* live = *)
(* Procedure.blocks_to_list proc *)
(* |> List.map (fun (v, b) -> (b, Block.free_vars b)) *)
(* |> Hashtbl.of_list; *)
(* term = Hashtbl.create 30; *)
(* names = Hashtbl.create 30; *)
(* final_edge = List.empty; *)
(* } *)
(* end *)

(* Assumptions: SSA form probably? seems good to me! *)
(* Also that the program is pure and lacks loops... *)
(* let reduce_procedure (proc : Program.proc) : Program.proc = *)
(* let reduction = Reduction.create proc in *)
(* let reduction = *)
(* Procedure.fold_blocks_topo_fwd *)
(* (fun final_edge id block -> *)
(* let preds = () in *)
(* let reachable = () in *)
(* Hashtbl.add (reduction.live) *)
(* final_edge) *)
(* reduction proc *)
(* in *)
(* failwith "" *)

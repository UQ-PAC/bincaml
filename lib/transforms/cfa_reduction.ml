open Lang
open Lang.Common

(* Assumptions: SSA form probably? seems good to me! *)
(* Also that the program is pure and lacks loops... *)
let construct_final_edge proc =
  (* Termination condition for each edge. *)
  let term : (IDSet.elt, Var.t) Hashtbl.t = Hashtbl.create 30 in
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

      (* Add a fresh termination variable to assign the condition. *)
      let termination_var = Procedure.fresh_var proc ~pure:true Types.Boolean in
      Hashtbl.add term id termination_var;

      (* Construct our termination condition by combining
          initial reachability with any assumes along this edge. *)
      let termination_cond =
        Expr.BasilExpr.applyintrin ~op:`AND
          ([ reachable ]
          @ (Block.stmts_iter block
            |> Iter.filter_map (function
              | Stmt.Instr_Assume { body; branch } -> Some body
              | _ -> None)
            |> Iter.to_list))
      in
      let termination =
        Stmt.Instr_Assign
          {
            attrib = Attrib.empty;
            al = [ (termination_var, termination_cond) ];
          }
      in

      (* Final edge is existing statements plus:
          1. the ites for the new edge being merged in.
          2. the statements for the new edge body.
          3. an assignment to the termination variable.
        *)
      final_edge
      @ List.concat [ [ ites ]; block.stmts |> Vector.to_list; [ termination ] ])
    List.empty proc

let reduce_procedure (proc : Program.proc) : Program.proc =
  (* Constructed reduced edge to replace procedure blocks. *)
  let final_edge = construct_final_edge proc in

  let out_proc =
    proc |> Procedure.iter_blocks |> Iter.map fst
    |> Iter.fold (fun acc id -> Procedure.remove_block acc id) proc
  in
  let out_proc, id = Procedure.fresh_block out_proc ~stmts:final_edge () in

  (* Make this the entry and return block. *)
  let out_proc = Procedure.set_entry_block out_proc id in
  Procedure.PG.map_graph
    (fun g ->
      Procedure.G.add_edge g (Procedure.Vert.End id) Procedure.Vert.Return)
    out_proc

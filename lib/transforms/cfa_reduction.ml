(** A transform which reduces the CFA (control-flow automaton) to a single edge,
    representing control flow through linear if-then-else expressions rather
    than phi nodes. This is useful for the SMT backend.

    This is done by propagating reachability and termination conditions for
    blocks forwards in topological order. Phi-node variables then be assigned
    from an ite-chain on the termination condition of each source block.

    The original algorithm assumes no SSA, however this does as it simplifies it
    greatly. Also requires that the CFA is acyclic and pure. *)

open Lang
open Lang.Common
open Expr

let construct_final_edge proc =
  (* Termination condition for each edge. *)
  let termination_condition : (IDSet.elt, Var.t) Hashtbl.t =
    Hashtbl.create 30
  in

  (* final_edge accumulates as one large edge containing
     all statements from existing edges with additional
     predicate variables and ite statements/assignments
     filling in for phi-nodes. 
  *)
  Procedure.fold_blocks_topo_fwd
    (fun final_edge id block ->
      (* Compute reachability of this block. *)
      let reachable =
        match Procedure.blocks_pred proc id |> Iter.to_list with
        (* Always reachable if no predecessors. *)
        | [] -> Expr.BasilExpr.boolconst true
        (* Otherwise, reachability is ANY of the predecessors reachability. *)
        | preds ->
            Expr.BasilExpr.applyintrin ~op:`OR
              (preds
              |> List.filter_map (fst %> Hashtbl.get termination_condition)
              |> List.map Expr.BasilExpr.rvar)
      in

      (* Create ITE statements from phi nodes. *)
      let ites : Program.stmt =
        let al =
          block.phis
          |> List.map (function
            | ({ lhs; rhs = (_, hd_var) :: tl } : Var.t Block.phi) ->
                (* Head id is unused as it is the negation of everything. *)
                let ite =
                  List.fold_left
                    (fun acc (in_edge, var) ->
                      let cond = Hashtbl.find termination_condition in_edge in
                      BasilExpr.(ifthenelse (rvar @@ cond) (rvar var) acc))
                    (BasilExpr.rvar @@ hd_var) tl
                in
                (lhs, ite)
            | _ -> failwith "Encountered phi node with no rhs.")
        in
        Stmt.Instr_Assign { attrib = Attrib.empty; al }
      in

      (* Add a fresh termination variable to assign the condition. *)
      let termination_var = Procedure.fresh_var proc ~pure:true Types.Boolean in
      Hashtbl.add termination_condition id termination_var;

      (* Isolate the guard statements. *)
      let guard_expressions, non_guard_stmts =
        Block.stmts_iter block |> Iter.to_list
        |> List.partition_map_either (function
          | Stmt.Instr_Assume { body; branch = _ } -> Left body
          | stmt -> Right stmt)
      in

      (* Construct our termination condition by combining
          initial reachability with any guards along this edge. *)
      let termination_cond =
        BasilExpr.applyintrin ~op:`AND (reachable :: guard_expressions)
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
      final_edge @ List.concat [ [ ites ]; non_guard_stmts; [ termination ] ])
    [] proc

let reduce_procedure (proc : Program.proc) : Program.proc =
  (* Constructed reduced edge to replace procedure blocks. *)
  let final_edge = construct_final_edge proc in

  let proc =
    proc |> Procedure.iter_blocks |> Iter.map fst
    |> Iter.fold (fun acc id -> Procedure.remove_block acc id) proc
  in
  let proc, id = Procedure.fresh_block proc ~stmts:final_edge () in

  (* Make this the entry and return block. *)
  let proc = Procedure.set_entry_block proc id in
  Procedure.PG.map_graph
    (fun g ->
      Procedure.G.add_edge g (Procedure.Vert.End id) Procedure.Vert.Return)
    proc

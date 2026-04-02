(** verify acyclic code *)

open Bincaml_util.Common
open Lang
open Expr
module MinCut = Graph.Mincut.Make (Procedure.G)
module VertMap = Map.Make (Procedure.Vert)

let replace_src_in_succs v ~new_src p =
  let outgoing =
    Procedure.graph p |> Option.to_list
    |> List.flat_map (fun g -> Procedure.G.succ_e g v)
  in
  let new_outgoing =
    outgoing |> List.map (function _, l, d -> (new_src, l, d))
  in
  p
  |> Procedure.map_graph (fun g ->
      outgoing |> List.fold_left Procedure.G.remove_edge_e g)
  |> Procedure.map_graph (fun g ->
      new_outgoing |> List.fold_left Procedure.G.add_edge_e g)

let replace_dest_in_preds v ~new_dest p =
  let incoming =
    Procedure.graph p |> Option.to_list
    |> List.flat_map (fun g -> Procedure.G.pred_e g v)
  in
  let new_incoming =
    incoming |> List.map (function p, l, _ -> (p, l, new_dest))
  in
  p
  |> Procedure.map_graph (fun g ->
      incoming |> List.fold_left Procedure.G.remove_edge_e g)
  |> Procedure.map_graph (fun g ->
      new_incoming |> List.fold_left Procedure.G.add_edge_e g)

let print_vert (v : Procedure.Vert.t) =
  match v with
  | Begin id -> "bg" ^ String.replace ~sub:"%" ~by:"block" (ID.to_string id)
  | End id -> "ed" ^ String.replace ~sub:"%" ~by:"block" (ID.to_string id)
  | Entry -> "ORIGentryblock"
  | Exit -> "ORIGexitblock"
  | Return -> "ORIGretbl"

module E = struct
  type t = { entry : ID.t list; return : ID.t list }
end

module M = Monad (E)

let cuts (p : Program.proc) =
  let g = Procedure.graph p |> Option.get_exn_or "no graph" in
  let cuts = MinCut.min_cutset g Entry in
  print_endline @@ (ID.to_string @@ Procedure.id p) ^ " cuts";
  cuts |> List.iter (print_vert %> print_endline);
  let pc_width = Z.of_int (List.length cuts) |> Z.numbits %> ( + ) 1 in
  let pc_var =
    Procedure.fresh_var p ~name:"cut_pc" (Types.Bitvector pc_width)
  in
  let p =
    p |> Procedure.map_formal_in_params (StringMap.add (Var.name pc_var) pc_var)
  in

  let pcs =
    Procedure.Vert.Entry :: Exit :: Return :: cuts
    |> List.to_iter
    |> Iter.mapi (fun i v -> (v, Bitvec.of_int i ~size:pc_width))
    |> VertMap.of_iter
  in

  let spec = Procedure.specification p in
  let pc_guard i =
    BasilExpr.binexp ~op:`EQ (BasilExpr.rvar pc_var)
      (BasilExpr.bvconst @@ VertMap.find i pcs)
  in
  let spec =
    {
      spec with
      requires = pc_guard Entry :: spec.requires;
      ensures = pc_guard Return :: spec.ensures;
    }
  in
  let p = Procedure.set_specification p spec in
  let p, new_entry = Procedure.fresh_block ~stmts:[] ~name:"cut_entry" p () in
  let p, new_return = Procedure.fresh_block ~stmts:[] ~name:"cut_return" p () in
  let p =
    cuts
    |> List.fold_left
         (fun p v ->
           let p, b_begin =
             Procedure.fresh_block
               ~name:(print_vert v ^ "guard")
               ~stmts:[ Instr_Assume { body = pc_guard v; branch = false } ]
               p ()
           in
           let p, b_return =
             Procedure.fresh_block
               ~name:(print_vert v ^ "set_pc")
               ~stmts:
                 [
                   Instr_Assign
                     [ (pc_var, Expr.BasilExpr.bvconst @@ VertMap.find v pcs) ];
                 ]
               ~successors:[ new_return ] p ()
           in
           let p =
             p
             |> replace_src_in_succs v ~new_src:(Procedure.Vert.End b_begin)
             |> replace_dest_in_preds v
                  ~new_dest:(Procedure.Vert.Begin new_return)
             |> Procedure.add_goto ~from:new_entry ~targets:[ b_begin ]
             |> Procedure.add_goto ~from:b_return ~targets:[ new_return ]
           in
           p)
         p
  in
  let p = replace_src_in_succs Entry ~new_src:(End new_entry) p in
  let p = replace_dest_in_preds Return ~new_dest:(Begin new_return) p in
  let p =
    Procedure.map_graph
      (fun g -> Procedure.G.add_edge g Entry (Begin new_entry))
      p
    |> Procedure.map_graph (fun g ->
        Procedure.G.add_edge g (End new_return) Return)
  in
  p

type ftype = {
  reach_end : BasilExpr.t list;
  assigns : (Var.t * BasilExpr.t) list;
  reach_failure : BasilExpr.t list;
}

let extract p =
  let entry_block =
    Procedure.graph p |> Option.get_exn_or "" |> fun g ->
    Procedure.G.succ g Entry
    |> List.filter_map (function
      | Procedure.Vert.Begin id -> Some id
      | End id -> Some id
      | _ -> None)
  in
  let block_done id =
    Var.create ("block_done_" ^ ID.to_string id) Types.Boolean
  in
  let stmt e (s : Program.stmt) =
    match s with
    | Instr_Assert { body } ->
        let rfail =
          BasilExpr.binexp ~op:`IMPLIES
            (BasilExpr.applyintrin ~op:`AND e.reach_end)
            (BasilExpr.unexp ~op:`BoolNOT body)
        in
        {
          e with
          reach_end = body :: e.reach_end;
          reach_failure = rfail :: e.reach_failure;
        }
    | Instr_Assume { body } -> { e with reach_end = body :: e.reach_end }
    | Instr_Assign assigns -> { e with assigns = assigns @ e.assigns }
    | _ -> failwith "unsupported"
  in
  let phi e (s : 'a Block.phi) =
    match s with
    | { lhs; rhs } ->
        let rhs =
          rhs
          |> List.map (fun (bid, v) ->
              BasilExpr.binexp ~op:`IfThen
                (BasilExpr.rvar (block_done bid))
                (BasilExpr.rvar v))
        in
        let cases = BasilExpr.applyintrin ~op:`Cases rhs in
        { e with assigns = (lhs, cases) :: e.assigns }
  in
  let phi = List.fold_left phi in
  let g = Procedure.graph p |> Option.get_exn_or "" in
  let assigns =
    Procedure.fold_blocks_topo_fwd
      (fun acc id b ->
        print_endline (ID.to_string id);
        let r_fail, prog = acc in
        let e =
          if List.exists (ID.equal id) entry_block then BasilExpr.boolconst true
          else
            let preds =
              Procedure.blocks_pred p id
              |> Iter.map (block_done %> BasilExpr.rvar)
              |> Iter.to_list
            in
            BasilExpr.applyintrin ~op:`OR preds
        in

        let st = { assigns = []; reach_end = [ e ]; reach_failure = [] } in
        let st = Block.fold_forwards ~phi ~f:stmt st b in
        let st =
          {
            st with
            assigns =
              (block_done id, BasilExpr.applyintrin ~op:`AND st.reach_end)
              :: st.assigns;
          }
        in
        (st.reach_failure, Iter.cons (e, st.assigns) prog))
      ([], Iter.empty) p
  in
  let exits = Procedure.get_returning_blocks p in
  let terminates =
    BasilExpr.applyintrin ~op:`OR
    @@ List.map (block_done %> BasilExpr.rvar) exits
  in
  let fails = BasilExpr.applyintrin ~op:`OR (fst assigns) in
  let spec = Procedure.specification p in
  let requires = BasilExpr.applyintrin ~op:`AND spec.requires in
  let ensures = BasilExpr.applyintrin ~op:`AND spec.ensures in
  let cond =
    BasilExpr.binexp ~op:`IMPLIES requires
      (BasilExpr.applyintrin ~op:`AND
         [ BasilExpr.unexp ~op:`BoolNOT fails; terminates; ensures ])
  in
  (cond, snd assigns)

let to_smt (cond, assigns) =
  let open Expr_smt.SMTLib2 in
  let open Bincaml_util.Smt in
  let query =
    assigns
    |> Iter.fold
         (fun (acc : builder) (cond, assigns) ->
           let assigns =
             List.map
               (fun (l, r) -> BasilExpr.binexp ~op:`EQ (BasilExpr.rvar l) r)
               assigns
           in
           let b =
             Expr_smt.SMTLib2.assert_bexpr
               (BasilExpr.binexp ~op:`IMPLIES cond
               @@ BasilExpr.applyintrin ~op:`AND assigns)
           in
           snd @@ b acc)
         Expr_smt.SMTLib2.empty
  in
  let _, b = (assert_bexpr (BasilExpr.unexp ~op:`BoolNOT cond)) query in
  let sexp = to_sexp ~set_logic:true b in
  sexp

let succ e =
  match e with
  | `Atom "success" -> ()
  | e -> failwith ("not success: " ^ Sexp.to_string e)

let check s i e =
  let open Bincaml_util.Smt in
  Solver.push s;
  e |> Iter.iter (fun x -> Bincaml_util.Smt.Solver.add_command s x);
  let e = Solver.check s in
  let m =
    match e with
    | Unsat -> "ok"
    | Sat -> "failed: " ^ (Solver.get_model s |> Sexp.to_string)
    | Unknown -> "unkown"
  in
  Printf.printf "%s : %s\n" (ID.to_string i) m;
  Solver.pop s;
  e

(* Need to perform check at prog level to resolve inteprocedural effects; calls


(1) lift to lambda parameter form
(2) interpreocedural effects
(2) per procedure:

  2.1 identify cut points & introduce PC assignments and guards
  2.2 perform ssa and stash result
  2.3 compute liveness result
  2.4 add the live variables at each entry cut in params and exit cut to out params. 

  2.5 chop cut points and redirect through entry/exit, add loop ssa-rewritten invariant 
      assertion 

    (can we do the loop invariant vc insertion earlier - at 2.1?)
        while (c) invariant q {x}; ~>
        assert q; while (c) (assume q ; x; assert q) assert q; 
        
    at entry assume:
      (1) pc = entry => precondition
      (2) pc = header => header inv[ssa(header)]

    at exit assert:
      (1) pc = header => header inv[ssa(header)]
      (2) pc = backedge => header inv[ssa(backedge)]
      (3) pc = return => postcondition

  2.6 perform reachability reduction of now DAG procedure





*)
let check (p : Program.t) =
  let op = p in
  let p = Ssa.set_params ~skip_observable:false ~skip_maps:false p in
  let p = { p with procs = IDMap.map cuts p.procs } in
  (*
  let fixed =
    IDMap.map Cleanup_cfg.remove_blocks_unreachable_from_entry fixed
  in
  *)

  let p = Ssa.ssa_prog ~skip_observable:false ~skip_maps:false p in
  IDMap.iter
    (fun k p ->
      CCIO.with_out
        (ID.to_string k ^ "dotgraph.dot")
        (fun v ->
          Viscfg.Dot.output_graph v
            (Procedure.graph p |> Option.get_exn_or "procedure has no graph")))
    p.procs;

  let smts = IDMap.map extract p.procs in
  let s =
    Bincaml_util.Smt.Solver.create
      {
        Bincaml_util.Smt.Config.cvc5 with
        log = Bincaml_util.Smt.Config.printf_log;
      }
  in
  let _ = IDMap.map to_smt smts |> IDMap.mapi (check s) in
  op

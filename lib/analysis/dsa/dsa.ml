open Lang
open Common
open Wrapped_intervals
module Interval = Interval
module FormalDSGraph = Formal

(* TODO add flags for later analyses/transforms to use *)

module NodeFlags = Node_flags

module Constraint = struct
  type 'e t =
    | Mem of { addr : 'e; value : 'e; size : int }
    (* Actual * Formal pairs *)
    | Call of { lhs : ('e * 'e) list; args : ('e * 'e) list; callee_id : ID.t }
  [@@deriving eq]

  (** Special funky map where the second function evaluates within a procedure
      id for call constraint callee formal arguments *)
  let map (f : 'a -> 'b) ~(per_proc_f : ID.t -> 'a -> 'b) (c : 'a t) : 'b t =
    match c with
    | Mem { addr; value; size } -> Mem { addr = f addr; value = f value; size }
    | Call { lhs; args; callee_id } ->
        let lhs =
          List.map
            (fun (actual, formal) -> (f actual, per_proc_f callee_id formal))
            lhs
        in
        let args =
          List.map
            (fun (actual, formal) -> (f actual, per_proc_f callee_id formal))
            args
        in
        Call { lhs; args; callee_id }

  let show s = function
    | Mem { addr; value } -> Printf.sprintf "[|%s|] -> %s" (s addr) (s value)
    | Call { lhs; args } ->
        Printf.sprintf "in: %s, out: %s"
          (List.to_string ~sep:", " (fun (a, f) -> s a ^ " <-> " ^ s f) args)
          (List.to_string ~sep:", " (fun (a, f) -> s a ^ " <-> " ^ s f) lhs)

  let gen_constraints (prog : Program.t) (p : Program.proc) =
    let open Stmt in
    Procedure.iter_blocks_topo_fwd p
    |> Iter.flat_map (fun (bid, block) -> Block.stmts_iter block)
    |> Iter.filter_map (fun stmt ->
        match stmt with
        | Instr_Load { lhs; addr = Addr { addr; size } } ->
            Some (Mem { addr; value = Expr.BasilExpr.rvar lhs; size })
        | Instr_Store { value; addr = Addr { addr; size } } ->
            Some (Mem { addr; value; size })
        | Instr_Call { lhs; args; procid } ->
            let callee = Program.proc prog procid in
            let fin = Procedure.formal_in_params callee in
            let fout = Procedure.formal_out_params callee in
            let lhs =
              StringMap.to_list lhs
              |> List.map (fun (s, actual) ->
                  ( Expr.BasilExpr.rvar actual,
                    Expr.BasilExpr.rvar @@ StringMap.find s fout ))
            in
            let args =
              StringMap.to_list args
              |> List.map (fun (s, actual) ->
                  (actual, Expr.BasilExpr.rvar @@ StringMap.find s fin))
            in
            Some (Call { lhs; args; callee_id = procid })
        | _ -> None)
end

module DSGraph = Dsgraph

(** Construct the local-phase graph of the given procedure. It will be ensured
    that all loaded/stored addresses, and all formal in/out params are unified,
    however actual params of calls will not be unified for precision and should
    be unified at use in the BU/TD phases. *)
let make_local_graph proc sva
    (constraints : Sva.SymAddrSetLattice.t Constraint.t Iter.t) : DSGraph.t =
  let g = DSGraph.empty_graph () in
  let cells = Vector.create () in
  (* Add cells to the graph based on sva results *)
  let add_cells size sv =
    Sva.SymAddrSetLattice.to_iter sv
    |> Iter.filter (not % Sva.SymBase.equal Sva.SymBase.Constant % fst)
    |> Iter.map (fun (b, i) ->
        let f =
          match b with
          | Sva.SymBase.Stack _ -> NodeFlags.(set_flag stack empty)
          | Sva.SymBase.Heap _ -> NodeFlags.(set_flag heap empty)
          | GlobSym -> NodeFlags.(set_flag global empty)
          | Constant | Par _ | Ret _ | Loaded _ ->
              NodeFlags.(set_flag unknown empty)
        in
        let i = Interval.of_wint i |> Interval.pad_with_size size in
        let c = DSGraph.add_cell g ~sb:(Some b) i f in
        Vector.push cells c;
        c)
    |> Iter.to_list
  in

  (* Construct base graph *)
  Iter.iter
    (fun constr ->
      match constr with
      | Constraint.Mem { addr; value; size } ->
          let ptrs = add_cells size addr in
          let vals = add_cells size value in
          List.iter (DSGraph.add_pointees vals) ptrs
      | Constraint.Call { lhs; args } -> ())
    constraints;

  (* Join formal in params *)
  Procedure.formal_in_params proc
  |> StringMap.values
  |> Iter.iter (fun v ->
      let v = Sva.StateAbstraction.read v sva in
      DSGraph.merge_vs v g);

  (* Unify all pointees *)
  Vector.iter DSGraph.unify_pointees cells;

  List.iter (fun n -> DSGraph.check_valid_node n) (DSGraph.nodes g);
  DSGraph.check_unique_pointee g;

  g

(** Get all callees called by the given procedure *)
let callees p =
  Procedure.blocks_to_list p |> List.to_iter |> Iter.map snd
  |> Iter.flat_map Block.stmts_iter
  |> Iter.filter_map (function
    | Stmt.Instr_Call { procid } -> Some procid
    | _ -> None)
  |> IDSet.of_iter |> IDSet.to_iter

(** Unify the cell specified by the formal sb with the actual sbs, within a
    single graph (recursion). *)
let resolve_arguments graph actual formal =
  ignore
    (let open Option.Infix in
     let open DSGraph in
     let* formal_cell = cell_of formal graph in
     let* actual_cell = cell_of actual graph in
     join actual_cell formal_cell;
     unify_node_of actual_cell;
     check_unique_pointee graph;
     None)

(** Copy and merge the formal cell from the callee graph with the actual cells
    of the caller graph. *)
let resolve_callee old_to_new caller_graph callee_graph actual formal =
  ignore
    (let open Option.Infix in
     let open DSGraph in
     (* Only do the joining if a caller cell actually exists *)
     let* caller_cell = cell_of actual caller_graph in
     unify_node_of caller_cell;
     let* callee_cell_copy =
       copy_cells_of ~old_to_new ~clear_stack:true formal callee_graph
         caller_graph
     in
     unify_node_of callee_cell_copy;
     check_unique_pointee caller_graph;
     join caller_cell callee_cell_copy;
     unify_node_of caller_cell;
     check_unique_pointee caller_graph;
     None)

(** Copy and merge the actual cells from the callee graph with the formal cell
    of the caller graph. *)
let resolve_caller old_to_new caller_graph callee_graph actual formal =
  ignore
    (let open Option.Infix in
     let open DSGraph in
     let* callee_cell = cell_of formal callee_graph in
     (* Copy all cells of the actual param over and join them (only if the callee cell exists of course) *)
     let* caller_cell_copy =
       copy_cells_of ~old_to_new actual caller_graph callee_graph
     in
     join callee_cell caller_cell_copy;
     unify_node_of callee_cell;
     check_unique_pointee caller_graph;
     None)

(** Perform the bottom up phase, which interprocedurally propagates information
    upwards from the leaves of the call stack. *)
let bottom_up prog graphs =
  (* Perform an inline Tarjan's algorithm that dynamically grows the call graph when resolving indirect calls (currently unimplemented) *)
  let graphs = ref graphs in
  let stack = Stack.create () in
  let entry = Program.entry_proc_exn prog in
  let cur_id = ref 0 in
  let get_id () =
    let id = !cur_id in
    cur_id := succ !cur_id;
    id
  in
  let ids = Hashtbl.create 100 in

  let iter_calls f scc =
    IDSet.iter
      (fun pid ->
        let constraints, caller_graph = IDMap.find pid !graphs in
        Iter.iter
          Constraint.(
            function
            | Call { lhs; args; callee_id } -> f caller_graph lhs args callee_id
            | _ -> ())
          constraints)
      scc
  in

  (* This is pretty much exactly taken from Latner's thesis, it computes sccs
     in the call graph and calls `process_scc` on them. It needs to be mutually
     recursive because the indirect call resolution code will call `visit` from
     `process_scc` *)
  let rec visit proc =
    let id = get_id () in
    let min_id = ref id in
    let proc_id = Procedure.id proc in
    Hashtbl.add ids proc_id id;
    Stack.push proc_id stack;

    callees proc
    |> Iter.iter (fun callee_pid ->
        match Hashtbl.get ids callee_pid with
        | None ->
            let callee = Program.proc prog callee_pid in
            visit callee
        | Some id -> min_id := min !min_id id);
    if !min_id = id then (
      let scc = ref @@ IDSet.singleton proc_id in
      while not @@ Option.equal ID.equal (Some proc_id) (Stack.top_opt stack) do
        scc := IDSet.add (Stack.pop stack) !scc
      done;
      let top = Stack.pop stack in
      assert (ID.equal proc_id top);
      (* Hopefully there aren't more than Int.max_int procedures in the call graph! *)
      IDSet.iter (fun id -> Hashtbl.add ids id Int.max_int) !scc;
      process_scc !scc)
  (* Propagate information across function calls both out and within the scc. *)
  and process_scc scc =
    assert (not @@ IDSet.is_empty scc);
    (* Resolve all out-of-scc calls *)
    iter_calls
      (fun caller_graph lhs args callee_id ->
        if not @@ IDSet.mem callee_id scc then
          let old_to_new = Hashtbl.create 100 in
          let _, callee_graph = IDMap.find callee_id !graphs in
          args @ lhs
          |> List.iter (fun (a, f) ->
              resolve_callee old_to_new caller_graph callee_graph a f))
      scc;
    (* Combine all graphs in this scc into one *)
    let scc_graph =
      match IDSet.to_list scc with
      | [] -> failwith "assert catches this"
      | id :: idss ->
          let _, g = IDMap.find id !graphs in
          idss
          |> List.iter (fun id' ->
              let constrs, g' = IDMap.find id !graphs in
              let old_to_new = Hashtbl.create 100 in
              (* Copy g' into g *)
              DSGraph.node_map g'
              |> DSGraph.SBMap.iter (fun sb n ->
                  ignore @@ DSGraph.copy_node g ~sbs:[ sb ] ~old_to_new n);
              (* we need to copy nodes that are not assigned a symbolic base as
                 well, ones that are already copied are skipped by the memo
                 table. *)
              DSGraph.nodes g'
              |> List.iter (fun n ->
                  ignore @@ DSGraph.copy_node g ~old_to_new n);
              (* Finally replace this procedure's graph with the new one (yay mutability) *)
              graphs := IDMap.add id' (constrs, g) !graphs);
          g
    in
    (* Resolve all in-scc calls *)
    iter_calls
      (fun _ lhs args callee_id ->
        if IDSet.mem callee_id scc then
          args @ lhs
          |> List.iter (fun (a, f) -> resolve_arguments scc_graph a f))
      scc;
    (* TODO Indirect call stuff *)
    ()
  in

  visit entry;

  IDMap.iter
    (fun _ (_, (g : DSGraph.t)) ->
      List.iter
        (fun n ->
          List.iter (fun c -> assert (DSGraph.unique_pointee c))
          @@ DSGraph.cells n)
        (DSGraph.nodes g))
    !graphs;

  !graphs

(** Perform the top down phase, which interprocedurally propagates information
    downwards from callers to callees. It is assumed that the bottom up phase
    has already been run (it doesn't make much sense to call this otherwise). *)
let top_down prog graphs =
  (* The indirect calls should be resolved by now, so we can do a simpler SCC iteration algorithm. *)
  let iter_calls f scc =
    IDSet.iter
      (fun pid ->
        let constraints, caller_graph = IDMap.find pid graphs in
        Iter.iter
          Constraint.(
            function
            | Call { lhs; args; callee_id } -> f caller_graph lhs args callee_id
            | _ -> ())
          constraints)
      scc
  in
  let cg = Program.CallGraph.make_call_graph prog in
  let sccs = Program.CallGraph.Scc.scc_list cg in
  List.rev sccs
  |> List.iter (fun scc ->
      let scc =
        List.filter_map
          Program.CallGraph.Vert.(
            function
            | ProcBegin i | ProcReturn i | ProcExit i -> Some i
            | _ -> None)
          scc
        |> IDSet.of_list
      in
      (* Resolve calls *)
      iter_calls
        (fun caller_graph lhs args callee_id ->
          if not @@ IDSet.mem callee_id scc then
            let old_to_new = Hashtbl.create 100 in
            let _, callee_graph = IDMap.find callee_id graphs in
            args @ lhs
            |> List.iter (fun (a, f) ->
                resolve_caller old_to_new caller_graph callee_graph a f)
          else
            (* `caller_graph` will be the scc graph of this scc. *)
            args @ lhs
            |> List.iter (fun (a, f) -> resolve_arguments caller_graph a f))
        scc;
      ());
  graphs

(** Perform data structure analysis and return the graphs for each procedure. *)
let dsa (p : Program.t) =
  let sva_r =
    Trace_core.with_span ~__FILE__ ~__LINE__ "sva" @@ fun _ ->
    Sva.sva p |> IDMap.of_list
  in
  let translate pid e =
    Sva.(
      Eval.EV.eval (flip StateAbstraction.read (IDMap.find pid sva_r)) e
      |> SymAddrSetLattice.to_list |> snd
      |> List.map (try_make_global p)
      |> SymAddrSetLattice.of_list_bot)
  in
  let local_graphs =
    Trace_core.with_span ~__FILE__ ~__LINE__ "local phase" @@ fun _ ->
    IDMap.to_list sva_r
    |> List.map (fun (pid, sva) ->
        let proc = Program.proc p pid in
        let constraints =
          Constraint.gen_constraints p proc
          |> Iter.map (Constraint.map (translate pid) ~per_proc_f:translate)
          |> Iter.persistent
        in
        (pid, (constraints, make_local_graph proc sva constraints)))
    |> IDMap.of_list
  in
  let bu_graphs =
    Trace_core.with_span ~__FILE__ ~__LINE__ "bottom up phase" @@ fun _ ->
    bottom_up p local_graphs
  in
  let td_graphs =
    Trace_core.with_span ~__FILE__ ~__LINE__ "top down phase" @@ fun _ ->
    top_down p bu_graphs
  in
  td_graphs

(** Manual dot string construction because ocamlgraph doesn't seem to support
    record nodes. *)
let dot_string (graph : DSGraph.t) =
  let cur_cid = ref 0 in
  let take_id ids () =
    let id = !ids in
    ids := succ !ids;
    id
  in

  let nid_map = Hashtbl.create 100 in
  let node_sbs = Hashtbl.create 100 in

  (* Populate the symbase strings per node *)
  DSGraph.SBMap.iter
    (fun sb n ->
      let s =
        Hashtbl.get_or node_sbs (ID.index @@ DSGraph.node_id n) ~default:""
      in
      Hashtbl.add node_sbs
        (ID.index @@ DSGraph.node_id n)
        (s ^ "\\n"
        ^ (Sva.SymBase.show sb
          |> String.replace ~sub:"\"" ~by:"\\\""
          |> String.replace ~sub:"{" ~by:"\\{"
          |> String.replace ~sub:"}" ~by:"\\}")))
    (DSGraph.node_map graph);

  let nodes =
    DSGraph.nodes graph
    |> List.map DSGraph.(fun n -> (node_id n, fst @@ find_node n))
    |> IDMap.of_list |> IDMap.to_list |> List.map snd
  in

  let node_contents =
    nodes
    |> List.map (fun node ->
        let nid = ID.index @@ DSGraph.node_id node in
        ( nid,
          DSGraph.flags node,
          List.map
            (fun cell ->
              let cid = take_id cur_cid () in
              Hashtbl.add nid_map cid nid;
              (cid, DSGraph.find_cell cell))
            (DSGraph.cells node) ))
  in
  let cells = List.flat_map (fun (_, _, cells) -> cells) node_contents in
  let pointees = Hashtbl.create 100 in
  List.iter
    (fun (cid, cell) ->
      let ps =
        List.map
          (fun c' ->
            let c' = DSGraph.find_cell c' in
            (* Cursed O(n) lookup with physical equality *)
            List.find_map
              (fun (id, c'') -> Option.return_if (CCEqual.physical c' c'') id)
              cells
            |> Option.get_exn_or "pointing to cell that doesn't exist")
          (DSGraph.pointees cell)
      in
      Hashtbl.add pointees cid ps)
    cells;

  (* Header *)
  "digraph G {\n  rankdir=\"LR\"\n  node[shape=record]\n"
  (* Vertices *)
  ^ List.to_string ~sep:"\n"
      (fun (nid, flags, cids) ->
        Printf.sprintf "  \"node%d\"[label=\"node%d %s %s |{%s}\"];" nid nid
          (NodeFlags.show flags)
          (Hashtbl.get_or node_sbs nid ~default:"")
          (List.to_string ~sep:"|"
             (fun (id, cell) ->
               Printf.sprintf "<%d>%s" id (Interval.show @@ DSGraph.offsets cell))
             cids))
      node_contents
  ^ "\n"
  (* Edges *)
  ^ (Hashtbl.to_iter pointees
    |> Iter.flat_map (fun (cid, ps) ->
        let nid = Hashtbl.find nid_map cid in
        List.to_iter ps |> Iter.map (fun id -> (nid, cid, id)))
    |> Iter.to_string ~sep:"\n" (fun (nid, cid, id) ->
        let nid2 = Hashtbl.find nid_map id in
        Printf.sprintf "  \"node%d\":%d -> \"node%d\":%d" nid cid nid2 id))
  ^ "\n}"

(** Perform data structure analysis and print the dsgraphs as dot graphs to
    stdout. *)
let dsa_dots (p : Program.t) =
  let gs = dsa p in
  List.iter
    (fun (id, graph) ->
      print_endline @@ ID.show id;
      print_endline @@ dot_string graph)
    (List.map
       (fun (pid, (_, (graph : DSGraph.t))) -> (pid, graph))
       (IDMap.to_list gs));
  p

(** An idea for interprocedural copy propagation using ... symmetric
    multicategories?! We form union find relations of copies of variables, but
    for phis, we introduce multi-edges! These are edges with multiple sources.
    We can view relations as arrows in a category that can compose, and these
    multi-edges can also compose (as in a symmetric multicategory (with each
    target vertex distinct)), allowing us to make concise summaries of
    procedures, being the composite of relations going from input to output
    variables! We can then substitute a summary into the union find graph of a
    caller, replacing input variables with caller variables if they are copied
    (and replacing them with top otherwise). If any multi-edge summary collapses
    into a single edge (by having multiple of the same source), we get a copy
    relation edge! This could have been seen as a multi-target union find data
    structure kind of thing without the category nonsense either I suppose.

    Example:
    ```
    f(x) -> (o) {
        if (_) {
            a1 = x;
        } else {
            a2, _ = g(x);
        }
        a = phi(a1, a2);
        return a;
    }

    g(x) -> (o, p) {
        if (_) {
            b1 = x;
        } else {
            b2 = f(x);
        }
        b = phi(b1, b2);
        return (x, b);
    }
    ```
    Here we build intraprocedural relations
    `x -> a1, {x, a2} -> a, {x, a2} -> o` for `f` and
    `x -> b1, {x, b2} -> b, x -> o, {x, b2} -> p` for `g`.
    Notice that "multi edge" unification is performed (I do NOT want to figure
    out the time complexity of such a data structure...). From here we can substitute all of `g`'s relations of input to output vars into `f`, and obtain
    `x -> a1, {x, a2} -> a, {x, a2} -> o, x -> a2` ->
    `x -> a1, {x, x} -> a, {x, x} -> o, x -> a2` ->
    `x -> a1, x -> a, x -> o, x -> a2`
    From this, we can propagate `x -> o` into `g` to obtain
    `x -> b1, {x, b2} -> b, x -> o, {x, b2} -> p, x -> b2` ->
    `x -> b1, x -> b, x -> o, x -> p, x -> b2`
    and then we can propagate again into f to obtain
    `x -> a1, {x, a2} -> a, {x, a2} -> o, x -> a2, {x, x} -> _` ->
    `x -> a1, {x, a2} -> a, {x, a2} -> o, x -> a2, x -> _`
    which is redundant.

    To efficiently update relations from calls, we can update pointers of all output variables.
    Hopefully this is fast... but it's linear in the number of target edges so we shall see...
    Maybe having a map to all outvars related to a variable could help somehow?

    Now to implement this... *)

open Bincaml_util.Common
open Lang
open Common

module CopyNode = struct
  type content = {
    (* The variable this node represents *)
    v : Var.t;
    (* The variables this variable is copied from, through a phi. This field
       should only be read on parent nodes, in which case the list has either
       no elements or >=2 elements.*)
    copied_from : t list;
    (* The union find parent node. Parent nodes have this set to None (avoid
       cycles). *)
    parent : t option;
  }

  and t = content ref

  let init v : t = ref { v; copied_from = []; parent = None }

  (** Get the parent of this node (basically constant time because of path
      compression) *)
  let rec find v : t =
    match !v.parent with
    | Some v' ->
        let p = find v' in
        (* We can clear the copied_from field whenever setting the parent for
           the garbage collector to gobble on (yum) *)
        v := { v = !v.v; copied_from = []; parent = Some p };
        v'
    | None -> v

  (** `join v v'` sets the parent of `v'` to `v` (mod transitivity) *)
  let join v v' : unit = v' := { v = !v'.v; copied_from = []; parent = Some v }

  let eq (n : t) (m : t) = Var.equal !n.v !m.v

  (** Set out edges of a given vertex (think `v := phi(a, b, c)` defining edges
      `v -> a, v -> b, v -> c`) *)
  let set_copied v copied_from =
    assert (Option.is_none !v.parent);
    (* Slow ... *)
    assert (not @@ Int.equal (List.length copied_from) 1);
    v := { v = !v.v; copied_from; parent = None }

  (** Returns all reachable leaves from the given node *)
  let rec leaves =
    let visited = ref VarSet.empty in
    let rec dfs v : t list =
      let v = find v in
      if VarSet.mem !v.v !visited then []
      else (
        visited := VarSet.add !v.v !visited;
        match !v.copied_from with [] -> [ v ] | ls -> List.flat_map dfs ls)
    in
    dfs
  (* TODO possible optimisation where we abort this search if a leaf node is
     not an input variable (want to benchmark) *)

  let var (n : t) = !n.v
end

(** Ocamlgraph representation of the above for debug utilities *)
module CopyGraph = struct
  module Vert = Var

  module Edge = struct
    include Unit

    let default = ()
  end

  module G = Graph.Persistent.Digraph.ConcreteBidirectionalLabeled (Vert) (Edge)

  module Dot = Graph.Graphviz.Dot (struct
    include G
    open Vert
    open Edge

    let default_vertex_attributes _ = []
    let graph_attributes _ = []
    let edge_attributes _ = []
    let default_edge_attributes _ = []
    let get_subgraph _ = None

    let vertex_attributes v =
      let n = Var.name v in
      [ `Shape `Box; `Fontname "Mono"; `Label n ]

    let vertex_name = Var.name
  end)

  let make_graph nodes =
    Iter.fold
      (fun g (n : CopyNode.t) ->
        match !n.parent with
        | Some n' -> G.add_edge_e g (!n.v, (), !n'.v)
        | None ->
            List.fold_left
              (fun g (n' : CopyNode.t) -> G.add_edge_e g (!n.v, (), !n'.v))
              g !n.copied_from)
      G.empty nodes
end

type call_info = {
  caller_id : ID.t;
  lhs : Var.t StringMap.t;
  args : Program.e StringMap.t;
}

module Solver = struct
  let add_phi node_of (phi : Var.t Block.phi) =
    let l = node_of phi.lhs in
    let copied = List.map (uncurry @@ const node_of) phi.rhs in
    CopyNode.set_copied l copied

  let copy_of e =
    let open Expr.AbstractExpr in
    let open Expr.BasilExpr in
    match unfix e with RVar { id } -> Some id | _ -> None

  let add_intra_stmt callers node_of pid component stmt =
    let open Stmt in
    match stmt with
    | Instr_Assign a ->
        List.iter
          (fun (v, e) ->
            match copy_of e with
            | Some v' ->
                let v, v' = (node_of v, node_of v') in
                (* v := v', draw edge from v to v' *)
                CopyNode.join v' v
            | None -> ())
          a
    | Instr_Call c ->
        (* We at the same time create a list of all callers of each procedure in the scc. *)
        if List.mem ~eq:ID.equal c.procid component then
          Hashtbl.update callers
            ~f:(fun _ l ->
              let c = { caller_id = pid; lhs = c.lhs; args = c.args } in
              match l with Some cs -> Some (c :: cs) | None -> Some [ c ])
            ~k:c.procid
    | _ -> ()

  module Worklist = Worklist.Make (ID)

  let solve_component (prog : Program.t) call_graph
      (graphs : (ID.t, CopyNode.t VarMap.t) Hashtbl.t) component =
    let node_of pid v =
      let vm = Hashtbl.get_or_add graphs ~f:(const VarMap.empty) ~k:pid in
      match VarMap.find_opt v vm with
      | Some n -> n
      | None ->
          let n = CopyNode.init v in
          let vm = VarMap.add v n vm in
          Hashtbl.replace graphs pid vm;
          n
    in
    (* Initialise the graph with all intraprocedural copies *)
    let callers = Hashtbl.create 10 in
    List.iter
      (fun pid ->
        IDMap.find pid prog.procs |> Procedure.iter_blocks
        |> Iter.iter (fun (bid, b) ->
            Block.stmts_iter b
            |> Iter.iter (add_intra_stmt callers (node_of pid) pid component);
            List.iter (add_phi (node_of pid)) b.phis))
      component;
    (* The interproc part *)
    let worklist = Worklist.create () in
    Worklist.add_list worklist component;
    while Worklist.non_empty worklist do
      let pid = Worklist.pop worklist in
      let proc = IDMap.find pid prog.procs in
      Procedure.formal_out_params proc
      |> StringMap.values
      |> Iter.map (node_of pid)
      |> Iter.filter_map (fun node ->
          let leaves = CopyNode.leaves node in
          ((not (List.is_empty leaves))
          && List.for_all
               (fun (n : CopyNode.t) ->
                 StringMap.mem (Var.name !n.v) (Procedure.formal_in_params proc))
               leaves)
          |> flip Option.return_if (node, leaves))
      |> Iter.iter (fun ((node : CopyNode.t), leaves) ->
          Hashtbl.get_or callers pid ~default:[]
          |> List.iter (fun (call : call_info) ->
              let open List.Traverse (Option) in
              leaves
              |> List.map (fun (n : CopyNode.t) ->
                  StringMap.find (Var.name !n.v) call.args)
              |> map_m copy_of
              |> Option.iter (fun leaves ->
                  match leaves with
                  | v :: vs -> (
                      if List.for_all (Var.equal v) vs then
                        let assigned =
                          node_of call.caller_id
                          @@ StringMap.find (Var.name !node.v) call.lhs
                        in
                        match !assigned.parent with
                        | Some _ -> ()
                        | None ->
                            CopyNode.join (node_of call.caller_id v) assigned;
                            (* Update worklist (i'm lazy) *)
                            Iter.of_list component
                            |> Iter.filter (not % ID.equal pid)
                            |> Worklist.add_iter worklist)
                  | [] -> failwith "leaves should never be empty!")))
    done

  let collapse_composites graph =
    let searched = ref VarSet.empty in
    let rec search (node : CopyNode.t) =
      if not @@ VarSet.mem !node.v !searched then (
        searched := VarSet.add !node.v !searched;
        let copied_from = List.filter (fun (n : CopyNode.t) -> not @@ Var.equal !node.v !n.v) !node.copied_from in
        match copied_from with
        | l :: ls ->
            List.iter (search % CopyNode.find) (l :: ls);
            let p = CopyNode.find l in
            if List.for_all (fun p' -> Var.equal !p.v !(CopyNode.find p').v) ls
            then CopyNode.join p node
        | _ -> ())
    in
    VarMap.iter (const (search % CopyNode.find)) graph;
    VarMap.iter (const (ignore % CopyNode.find)) graph

  let solve (prog : Program.t) =
    let graphs : (ID.t, CopyNode.t VarMap.t) Hashtbl.t = Hashtbl.create 100 in
    let call_graph = Program.CallGraph.make_call_graph prog in
    Program.CallGraph.Scc.scc_list call_graph
    |> List.map
         (List.filter_map (function
           | Program.CallGraph.Vert.ProcBegin id -> Some id
           | _ -> None))
    |> List.iter (solve_component prog call_graph graphs);
    Hashtbl.iter (const collapse_composites) graphs;
    graphs
end

let test_transform (p : Program.t) =
  let gs = Solver.solve p in
  Hashtbl.iter
    (fun pid g ->
      print_endline @@ "Graphvis for " ^ ID.show pid ^ ":";
      let g = CopyGraph.make_graph (VarMap.values g) in
      CopyGraph.Dot.output_graph stdout g)
    gs;
  p

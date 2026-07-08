open Lang
open Common
open Interval

module Cell = struct
  type t = { offsets : Interval.t; node : int }
  [@@deriving eq, ord, show { with_path = false }]
end

module Edge = struct
  type t = Cell.t * Cell.t [@@deriving eq, ord, show { with_path = false }]
end

module CellSet = Set.Make (Cell)
module CellSetSet = Set.Make (CellSet)
module CellMap = Map.Make (Cell)
module EdgeSet = Set.Make (Edge)
module IntervalSet = Set.Make (Interval)

type t = {
  cells : CellSet.t;
  edges : EdgeSet.t;
  next_nid : int;
  old_to_new : Cell.t CellMap.t;
}
(** A graph consists of a bunch of cells and a bunch of edges between them. We
    also maintain a list of old-to-new cell mappings, for when a cell is
    replaced with a new one when e.g. being joined. *)

(** An empty graph *)
let empty : t =
  {
    cells = CellSet.empty;
    edges = EdgeSet.empty;
    next_nid = 0;
    old_to_new = CellMap.empty;
  }

(** Get the most up to date version of the given cell through the old-to-new
    mapping *)
let rec find (g : t) (c : Cell.t) =
  if CellSet.mem c g.cells then (
    assert (not @@ CellMap.mem c g.old_to_new);
    c)
  else find g (CellMap.find c g.old_to_new)

(** Join a set of intervals such that none of them overlap. *)
let join_invervals s =
  (* (mu S . {s1 join s2 | s1, s2 in S and overlap(s1, s2)} union {s | s in S and forall s' in S, not overlap(s, s')}) *)
  let step s =
    let o =
      IntervalSet.filter
        (fun i ->
          IntervalSet.for_all
            (fun i' -> Interval.equal i i' || (not @@ Interval.overlap i i'))
            s)
        s
    in
    let sl = IntervalSet.to_list s in
    List.product Pair.make sl sl
    |> List.filter (fun (s1, s2) ->
        Interval.((not @@ equal s1 s2) && overlap s1 s2))
    |> List.map (uncurry Interval.join)
    |> IntervalSet.of_list |> IntervalSet.union o
  in
  let rec fix s = if IntervalSet.equal s (step s) then s else fix (step s) in
  fix s

(** Update an old-to-new mapping after a join of overlapping cells is performed.
*)
let extend_old_to_new_join old_cells new_cells m =
  List.product Pair.make (CellSet.to_list old_cells) (CellSet.to_list new_cells)
  |> List.filter (fun ((c : Cell.t), (c' : Cell.t)) ->
      (not @@ Interval.equal c.offsets c'.offsets)
      && c.node = c'.node
      && Interval.overlap c.offsets c'.offsets)
  |> List.map
       (tap (fun (c, c') ->
            assert (not @@ CellMap.mem c m);
            assert (not @@ CellMap.mem c' m);
            assert (not @@ CellSet.mem c new_cells)))
  |> CellMap.add_list m

let cleq (c : Cell.t) (c' : Cell.t) =
  c.node = c'.node && Interval.subset c.offsets c'.offsets

let edges_flat_map f es =
  EdgeSet.fold (fun e acc -> EdgeSet.union acc (f e)) es EdgeSet.empty

(** Join cells in the same nodes that overlap *)
let join_overlapping_cells (g : t) =
  (* C^join* = {(n, s) | s in join*{c.s | c.n = n && c in C} && n in N } *)
  let nodes =
    CellSet.to_list g.cells
    |> List.map (fun (c : Cell.t) -> c.node)
    |> IntSet.of_list
  in
  let cells =
    IntSet.to_list nodes
    |> List.map (fun n ->
        CellSet.to_list g.cells
        |> List.filter_map (fun (c' : Cell.t) ->
            Option.return_if (c'.node = n) c'.offsets)
        |> IntervalSet.of_list |> join_invervals |> IntervalSet.to_list
        |> List.map (fun i -> ({ offsets = i; node = n } : Cell.t))
        |> CellSet.of_list)
    |> List.fold_left CellSet.union CellSet.empty
  in
  let old_to_new = extend_old_to_new_join g.cells cells g.old_to_new in
  (* E^join* = {(c1, c2) | (c3, c4) in E && c3 <= c1 && c4 <= c2 && c1 in C^join* && c2 in C^join*} *)
  let edges =
    edges_flat_map
      (fun (c3, c4) ->
        let cl = CellSet.to_list cells in
        List.product (fun c1 c2 -> (c1, c2)) cl cl
        |> List.filter (fun (c1, c2) -> cleq c3 c1 && cleq c4 c2)
        |> EdgeSet.of_list)
      g.edges
  in
  { g with cells; edges; old_to_new }

(** Get a new, unused node id (assuming all nodes in the graph came from
    make_node prior) *)
let make_node (g : t) : t * int =
  let nid = g.next_nid in
  ({ g with next_nid = nid + 1 }, nid)

(** Insert a cell into the node of the graph with the provided offsets *)
let add_cell (g : t) (nid : int) offsets : t =
  let cell : Cell.t = { offsets; node = nid } in
  if not @@ CellMap.mem cell g.old_to_new then
    let cells = CellSet.add cell g.cells in
    join_overlapping_cells { g with cells }
  else g

(** Add an edge between two given cells. *)
let rec add_edge (g : t) f t =
  if not @@ CellSet.mem f g.cells then
    add_edge g (CellMap.find f g.old_to_new) t
  else if not @@ CellSet.mem t g.cells then
    add_edge g f (CellMap.find t g.old_to_new)
  else (
    assert (not @@ CellMap.mem f g.old_to_new);
    assert (not @@ CellMap.mem t g.old_to_new);
    let edges = EdgeSet.add (f, t) g.edges in
    { g with edges })

(** Extend the old to new after unifying based on the returned map function *)
let extend_old_to_new_map old_cells map m =
  CellSet.to_list old_cells
  |> List.filter_map (fun c ->
      let c' = map c in
      if Cell.equal c c' then None else Some (c, c'))
  |> CellMap.add_list m

(** Unify all cells in the given set. If cells are in different nodes, the nodes
    are joined together into a single node with offsets corrected. This node is
    returned with the new graph along with the map function from the paper. *)
let unify_cells (g : t) (cs : CellSet.t) =
  assert (not @@ CellSet.is_empty cs);
  (* this shouldn't be called publicly (call unify_all) so this invariant can be enforced *)
  assert (CellSet.subset cs g.cells);
  let nodes =
    CellSet.to_list cs
    |> List.map (fun (c : Cell.t) -> c.node)
    |> IntSet.of_list
  in
  let j =
    IntSet.to_list nodes
    |> List.map (fun n ->
        let is =
          CellSet.to_list cs
          |> List.filter_map (fun (c : Cell.t) ->
              Option.return_if (c.node = n) c.offsets)
        in
        let offsets = List.fold_left Interval.join Interval.Bot is in
        ({ offsets; node = n } : Cell.t))
    |> CellSet.of_list
  in
  let ufy_cells =
    CellSet.filter
      (fun (c : Cell.t) -> IntSet.mem c.node nodes && (not @@ CellSet.mem c cs))
      g.cells
    |> CellSet.union j
  in
  let open List.Traverse (Option) in
  let starts =
    IntSet.to_list nodes
    |> map_m (fun n ->
        let starts =
          CellSet.filter (fun (c : Cell.t) -> c.node = n) j
          |> CellSet.to_list
          |> List.filter_map (fun (c : Cell.t) -> Interval.start c.offsets)
        in
        match starts with
        | [] -> None
        | s :: ss -> Some (n, List.fold_left Z.min s ss))
  in
  match starts with
  | Some starts ->
      let start_max =
        match starts with
        | [] -> failwith "no cells despite assertion"
        | (_, s) :: ss -> List.fold_left Z.max s (List.map snd ss)
      in
      let deltas =
        List.map (fun (n, s) -> (n, Z.sub start_max s)) starts |> IntMap.of_list
      in
      let adj_offs =
        CellSet.to_list ufy_cells
        |> List.map (fun (c : Cell.t) ->
            Interval.shift
              (IntMap.get_or c.node deltas ~default:Z.zero)
              c.offsets)
        |> IntervalSet.of_list
      in
      let g, nid = make_node g in
      let n =
        join_invervals adj_offs |> IntervalSet.to_list
        |> List.map (fun offsets -> ({ offsets; node = nid } : Cell.t))
        |> CellSet.of_list
      in
      let map (c : Cell.t) =
        if IntSet.mem c.node nodes then
          let d = IntMap.find c.node deltas in
          let o = Interval.shift d c.offsets in
          CellSet.filter (fun (c' : Cell.t) -> Interval.subset o c'.offsets) n
          |> CellSet.choose
        else c
      in
      let cells = CellSet.map map g.cells in
      assert (CellSet.cardinal cells <= CellSet.cardinal g.cells);
      let old_to_new = extend_old_to_new_map g.cells map g.old_to_new in
      let edges = EdgeSet.map (Pair.map_same map) g.edges in
      ({ g with cells; edges; old_to_new }, (n, map))
  | None ->
      (* Collapsed *)
      let g, nid = make_node g in
      let c : Cell.t = { node = nid; offsets = Interval.Top } in
      let map (c' : Cell.t) = if IntSet.mem c'.node nodes then c else c' in
      let cells = CellSet.map map g.cells in
      assert (CellSet.cardinal cells <= CellSet.cardinal g.cells);
      let old_to_new = extend_old_to_new_map g.cells map g.old_to_new in
      let edges = EdgeSet.map (Pair.map_same map) g.edges in
      ({ g with cells; edges; old_to_new }, (CellSet.singleton c, map))

(** Join two cells together, if they are in different nodes the nodes will be
    joined into one with offsets adjusted. *)
let rec join_cell_pair (g : t) (a : Cell.t) (b : Cell.t) =
  if not @@ CellSet.mem a g.cells then
    join_cell_pair g (CellMap.find a g.old_to_new) b
  else if not @@ CellSet.mem b g.cells then
    join_cell_pair g a (CellMap.find b g.old_to_new)
  else (
    assert (not @@ CellMap.mem a g.old_to_new);
    assert (not @@ CellMap.mem b g.old_to_new);
    fst @@ unify_cells g @@ CellSet.of_list [ a; b ])

(** Get sets of cells pointed to by the cells in the cell set *)
let pointees (cs : CellSet.t) (es : EdgeSet.t) =
  EdgeSet.to_list es
  |> List.fold_left
       (fun acc (c, c') ->
         if CellSet.mem c cs then
           CellMap.update c
             (function
               | Some cur -> Some (CellSet.add c' cur)
               | None -> Some (CellSet.singleton c'))
             acc
         else acc)
       CellMap.empty
  |> CellMap.values |> CellSetSet.of_iter

(** Unify all pointees of cells so that each cell has a unique pointee. *)
let unify_all (g : t) =
  let rec iter uc g =
    match CellSetSet.choose_opt uc with
    | None -> g
    | Some s ->
        let g', (n, map) = unify_cells g s in
        let p =
          pointees n g'.edges
          |> CellSetSet.filter (fun s -> CellSet.cardinal s > 1)
        in
        let uc' =
          CellSetSet.remove s uc
          |> CellSetSet.map (CellSet.map map)
          |> CellSetSet.union p
        in
        iter uc' g'
  in
  let g = iter (pointees g.cells g.edges) g in
  pointees g.cells g.edges
  |> CellSetSet.iter (fun cs -> assert (CellSet.cardinal cs = 1));
  g

(** Copy cells from the second graph into the first, with their corresponding
    nodes copied along. The returned graph is the new first graph, and a mapping
    of second-graph-cell to copied-cells is returned with it *)
let rec copy (g : t) (g' : t) (cs : CellSet.t) =
  if not @@ CellSet.subset cs g'.cells then
    copy g g'
      (CellSet.map
         (fun c ->
           (* Implicit assert that c is in old_to_new yay *)
           if CellSet.mem c g'.cells then c else CellMap.find c g'.old_to_new)
         cs)
  else (
    assert (CellSet.for_all (fun c -> not @@ CellMap.mem c g'.old_to_new) cs);
    let rec iter g ns done_ns nm =
      match IntSet.choose_opt ns with
      | None -> (g, nm)
      | Some n ->
          assert (not @@ IntSet.mem n done_ns);
          let g, n' = make_node g in
          let cs =
            g'.cells |> CellSet.filter (fun (c : Cell.t) -> c.node = n)
          in
          let cells =
            CellSet.union
              (cs |> CellSet.map (fun (c : Cell.t) -> { c with node = n' }))
              g.cells
          in
          (* old_to_new should not change as we are only adding new cells *)
          let g = { g with cells } in
          let ptee_ns =
            pointees cs g'.edges |> CellSetSet.to_iter
            |> Iter.flat_map (fun cs ->
                CellSet.to_iter cs |> Iter.map (fun (c : Cell.t) -> c.node))
            |> IntSet.of_iter
          in
          let done_ns = IntSet.add n done_ns in
          let ns = ns |> IntSet.union ptee_ns |> flip IntSet.diff done_ns in
          (* The graph with all pointed-to cells copied, and the node mapping *)
          let nm = IntMap.add n n' nm in
          let g, nm = iter g ns done_ns nm in
          (* Add the edges *)
          let edges =
            g'.edges
            |> EdgeSet.filter (fun ((c : Cell.t), _) -> c.node = n)
            |> EdgeSet.map
                 (Pair.map_same (fun (c : Cell.t) ->
                      { c with node = IntMap.find c.node nm }))
            |> EdgeSet.union g.edges
          in
          ({ g with edges }, nm)
    in
    let ns =
      CellSet.to_list cs
      |> List.map (fun (c : Cell.t) -> c.node)
      |> IntSet.of_list
    in
    let g, nm = iter g ns IntSet.empty IntMap.empty in
    let cm =
      CellSet.to_list cs
      |> List.map (fun (c : Cell.t) ->
          assert (IntMap.mem c.node nm);
          (c, { c with node = IntMap.find c.node nm }))
      |> CellMap.of_list
    in
    (g, cm))

open Lang
open Common
open Interval
module SBMap = Map.Make (Sva.SymBase)

(** A path compressed cell. Cells store a set of offsets from an abstract base
    address, the node that it belongs to, and a list of cells it points to (that
    will be a singleton or empty after unification). *)
type content =
  | Cell of {
      mutable offsets : Interval.t;
      mutable node : node;
      mutable pointees : cell list;
    }
  | Path of cell

and cell = content ref

(** Nodes are represented as sorted lists of cells, ordered by the low end of
    the intervals of each cell. This allows for linear time algorithms that
    naively would be quadratic. They are also given a tagged union find for
    representing nodes joined at offsets into other nodes. *)
and node_content =
  (* ID's CAN change when nodes are mutated (e.g. when replaced with a
       path)!! Make sure that if ids are ever used, the nodes with ids are
       being used won't change!!!! *)
  | Node of {
      mutable cells : cell list;
      mutable flags : Node_flags.t;
      id : ID.t;
    }
  | NodePath of node * Z.t

and node = node_content ref

type t = { mutable nodes : node list; mutable node_map : node SBMap.t }
(** A graph, which keeps track of all nodes and also which nodes come from each
    symbolic base (there is duplicate information). *)

let empty_graph () = { nodes = []; node_map = SBMap.empty }
let nodes (g : t) = g.nodes
let node_map (g : t) = g.node_map
let id_gen = ID.make_gen ()

(** Get the union find parent of this cell *)
let rec find_cell (c : cell) =
  match !c with
  | Path c' ->
      let p = find_cell c' in
      c := Path p;
      p
  | Cell _ -> c

(** Get the union find parent of this node *)
let rec find_node (n : node) =
  match !n with
  | NodePath (n', off) ->
      let p, off' = find_node n' in
      n := NodePath (p, Z.add off off');
      (p, Z.add off off')
  | Node _ -> (n, Z.zero)

(** Get the offsets interval of this cell's parent *)
let offsets (c : cell) =
  match !(find_cell c) with
  | Path _ -> failwith "find_cell returned non terminal"
  | Cell { offsets } -> offsets

(** Get the node of this cell's parent *)
let node_of (c : cell) =
  match !(find_cell c) with
  | Path _ -> failwith "find_cell returned non terminal"
  | Cell { node } -> node

(** Get the pointees of this cell's parent *)
let pointees (c : cell) =
  match !(find_cell c) with
  | Path _ -> failwith "find_cell returned non terminal"
  | Cell { pointees } -> pointees

(** Shift the interval of the cell's parent by the given offset *)
let shift off (c : cell) =
  match !(find_cell c) with
  | Path _ -> failwith "find_cell returned non terminal"
  | Cell r -> r.offsets <- Interval.shift off r.offsets

(** Set the node of this cell's parent *)
let set_node node (c : cell) =
  match !(find_cell c) with
  | Path _ -> failwith "find_cell returned non terminal"
  | Cell r -> r.node <- node

(** Set the pointees of this cell's parent *)
let set_pointees pointees (c : cell) =
  match !(find_cell c) with
  | Path _ -> failwith "find_cell returned non terminal"
  | Cell r -> r.pointees <- pointees

(** Add to the list of pointees of this cell's parent *)
let add_pointees pointees (c : cell) =
  match !(find_cell c) with
  | Path _ -> failwith "find_cell returned non terminal"
  | Cell r ->
      r.pointees <-
        List.fold_left
          (flip (List.add_nodup ~eq:CCEqual.physical))
          r.pointees
          (List.map find_cell pointees)

(** Get the cells of this node's parent *)
let cells (n : node) =
  match !(fst @@ find_node n) with
  | NodePath _ -> failwith "find_node returned non terminal"
  | Node r -> r.cells

(** Get the flags of this node's parent *)
let flags (n : node) =
  match !(fst @@ find_node n) with
  | NodePath _ -> failwith "find_node returned non terminal"
  | Node r -> r.flags

(** Get the id of this node's parent *)
let node_id (n : node) =
  match !(fst @@ find_node n) with
  | NodePath _ -> failwith "find_node returned non terminal"
  | Node r -> r.id

(** Set the cells of this node *)
let set_cells cells (n : node) =
  match !(fst @@ find_node n) with
  | NodePath _ -> failwith "find_node returned non terminal"
  | Node r -> r.cells <- cells

(** Join the flags of this node with the new flags *)
let join_flags flags (n : node) =
  match !(fst @@ find_node n) with
  | NodePath _ -> failwith "find_node returned non terminal"
  | Node r -> r.flags <- Node_flags.join r.flags flags

(** Make the second cell point to the first *)
let join_paths (c1 : cell) (c2 : cell) =
  match (!(find_cell c1), !(find_cell c2)) with
  | Path _, _ | _, Path _ -> failwith "find_node returned non terminal"
  | Cell r, Cell { pointees = p } ->
      if not @@ CCEqual.physical c1 c2 then c2 := Path c1

(** Returns whether the node has its cell intervals sorted and disjoint *)
let is_sorted node =
  let is = List.map offsets (cells node) in
  let rec aux = function
    | [] | [ _ ] -> true
    | i :: j :: xs -> Interval.left_of i j && aux (j :: xs)
  in
  aux is

(** Returns whether every cell of this node has its node set to this. *)
let valid_cell_nodes node =
  let f, _ = find_node node in
  List.for_all (CCEqual.physical f % node_of) (cells f)

(** Check that the node satisfies its invariants *)
let check_valid_node node =
  assert (is_sorted node);
  assert (valid_cell_nodes node)

(** Check whether a cell has a unique pointer. *)
let unique_pointee cell =
  match pointees cell with [] | [ _ ] -> true | _ -> false

(** Check whether all cells have a unique pointer. *)
let check_unique_pointee g =
  List.iter
    (fun n -> List.iter (fun c -> assert (unique_pointee c)) @@ cells n)
    (nodes g)

(** Collapse all cells in the node into a single cell, with offsets Top *)
let collapse node =
  match !(fst @@ find_node node) with
  | NodePath _ -> failwith "find_node returned non terminal"
  | Node r ->
      let pointees =
        List.fold_left
          (fun acc c ->
            List.fold_left
              (flip (List.add_nodup ~eq:CCEqual.physical))
              acc (pointees c))
          [] (cells node)
      in
      let c = ref (Cell { offsets = Top; node; pointees }) in
      List.iter (fun c' -> join_paths c c') r.cells;
      let flags = Node_flags.(set_flag collapsed r.flags) in
      r.cells <- [ c ];
      r.flags <- flags

(** Join c2 into c1 under the assumption that they are in the same node. It is
    left to the caller to preserve node structure. *)
let rec join_cells_only c1 c2 =
  match (!(find_cell c1), !(find_cell c2)) with
  | Path _, _ | _, Path _ -> failwith "find_cell returned non terminal"
  | Cell a, Cell b -> (
      assert (CCEqual.physical a.node b.node);
      let pointees =
        List.fold_left
          (flip (List.add_nodup ~eq:CCEqual.physical))
          a.pointees b.pointees
      in
      let offsets = Interval.join a.offsets b.offsets in
      a.pointees <- pointees;
      a.offsets <- offsets;
      join_paths c1 c2;
      match offsets with Top -> collapse a.node | _ -> ())

(** Join the two nodes, with the second shifted by the given offset. The second
    node becomes a NodePath and the first is kept *)
and join_nodes_at off n1 n2 =
  check_valid_node n1;
  check_valid_node n2;
  match (!n1, !n2) with
  | NodePath _, _ ->
      let p, off' = find_node n1 in
      join_nodes_at (Z.( - ) off off') p n2
  | _, NodePath _ ->
      let p, off' = find_node n2 in
      join_nodes_at (Z.( + ) off off') n1 p
  | Node r1, Node r2 ->
      if CCEqual.physical n1 n2 then assert (Z.equal Z.zero off)
      else (
        assert (not @@ CCEqual.physical n1 n2);
        List.iter (shift off) r2.cells;
        List.iter (set_node n1) r2.cells;
        let flags = Node_flags.join r1.flags r2.flags in
        (* To a simultaneous walk along both sorted lists to avoid an O(n^2) algorithm *)
        let rec join_nodes' n1' n2' =
          match (n1', n2') with
          | [], cs | cs, [] -> Some cs
          | c :: cs, c' :: cs' -> (
              match (offsets c, offsets c') with
              | Bot, _ | _, Bot -> failwith "Bottom cells should not exist."
              | Top, _ | _, Top ->
                  n1 := Node { r1 with cells = r1.cells @ r2.cells; flags };
                  n2 := NodePath (n1, off);
                  collapse n1;
                  check_valid_node n1;
                  check_valid_node n2;
                  None
              | (Interval _ as i), (Interval _ as j) when Interval.left_of i j
                ->
                  Option.map (List.cons c) @@ join_nodes' cs n2'
              | (Interval _ as i), (Interval _ as j) when Interval.right_of i j
                ->
                  Option.map (List.cons c') @@ join_nodes' n1' cs'
              | Interval (a, b), Interval (x, y) when Z.leq b y ->
                  (* first cell is left of second cell, so join first cell into second to preserve order *)
                  join_cells_only c' c;
                  join_nodes' cs n2'
              | Interval (a, b), Interval (x, y) ->
                  (* second cell is left of first cell, so join second cell into first to preserve order *)
                  join_cells_only c c';
                  join_nodes' n1' cs')
        in
        match join_nodes' r1.cells r2.cells with
        | Some n ->
            n1 := Node { r1 with cells = n; flags };
            n2 := NodePath (n1, off);
            check_valid_node n1;
            check_valid_node n2
        | _ -> ())

(** Inserts the cell into the node. *)
let rec insert node cell =
  match !node with
  | NodePath _ ->
      let p, off = find_node node in
      shift off cell;
      insert p cell
  | Node r -> (
      match !cell with
      | Path _ -> insert node (find_cell cell)
      | Cell { offsets = Interval.Bot } -> failwith "Bot cells should not exist"
      | Cell { offsets = Top } ->
          r.cells <- cell :: r.cells;
          collapse node
      | Cell ({ offsets = Interval _ as i } as cr) -> (
          check_valid_node node;
          set_node node cell;
          cr.node <- node;
          let rec insert' = function
            | [] -> Some [ cell ]
            | c :: cs -> (
                match !c with
                | Path _ -> insert' (find_cell c :: cs)
                | Cell { offsets = Top } ->
                    node := Node { r with cells = cell :: r.cells };
                    collapse node;
                    None
                | Cell { offsets = Bot } ->
                    failwith "Bot cells should not exist"
                | Cell { offsets = Interval _ as j } when Interval.left_of i j
                  ->
                    Some (cell :: c :: cs)
                | Cell { offsets = Interval _ as j } when Interval.right_of i j
                  ->
                    Option.map (List.cons c) @@ insert' cs
                | Cell { offsets = Interval _ } ->
                    (* If `cell` overlaps with `c`, join `cell` and `c`
                         together and drop `c` from the list *)
                    join_cells_only cell c;
                    insert' cs)
          in
          match insert' r.cells with Some n -> r.cells <- n | None -> ()))

(** Creates an empty node *)
let empty_node ?(flags = Node_flags.empty) () =
  ref (Node { cells = []; flags; id = ID.fresh id_gen () })

(** Make a new cell with no pointees and add it to the graph *)
let add_cell (g : t) ?(sb = None) offsets flags : cell =
  let node =
    sb
    |> Option.map (fun sb ->
        SBMap.get sb g.node_map
        |> Option.get_lazy (fun () ->
            let n = empty_node () in
            g.node_map <- SBMap.add sb n g.node_map;
            g.nodes <- n :: g.nodes;
            n))
    |> Option.get_lazy (fun () ->
        let n = empty_node () in
        g.nodes <- n :: g.nodes;
        n)
  in
  join_flags flags node;
  let cell = ref (Cell { offsets; node; pointees = [] }) in
  insert node cell;
  cell

(** Merge the two given cells together. If they belong to different nodes then
    the nodes are merged so that the cell offsets line up. *)
let join (c1 : cell) (c2 : cell) =
  if CCEqual.physical c1 c2 then ()
  else
    match (!(find_cell c1), !(find_cell c2)) with
    | Path _, _ | _, Path _ -> failwith "find_cell returned non terminal"
    | ( Cell { offsets = i; node = n1; pointees = p' },
        Cell { offsets = i'; pointees = p; node = n2 } ) ->
        (* Note that cells know their up to date interval relative to the
                 unification offset, so the intervals should not be updated. *)
        let n1, _ = find_node n1 in
        let n2, _ = find_node n2 in
        if not @@ CCEqual.physical n1 n2 then
          match Interval.(start i, start i') with
          | Some a, Some b when Z.lt a b -> join_nodes_at (Z.sub a b) n1 n2
          | Some a, Some b -> join_nodes_at (Z.sub b a) n2 n1
          | _ -> join_nodes_at Z.zero n1 n2
        else
          let offsets = Interval.join i i' in
          let fill = ref (Cell { offsets; node = n1; pointees = [] }) in
          insert n1 fill

(** Unify the pointees of this cell and recurse *)
let rec unify_pointees cell =
  let rec aux = function
    | [] -> ()
    | [ _ ] -> ()
    | a :: (b :: cs as tail) ->
        join a b;
        aux tail
  in
  (* Join the cells belonging to the same node, and then join each node
       together. This avoids imprecision from joining cells from other nodes,
        and residual cells around the rest of the node getting merged. *)
  let join_pointees ps =
    let node_cells =
      List.fold_left
        (fun acc c ->
          let id = node_id (node_of c) in
          IDMap.update id
            (function Some cur -> Some (c :: cur) | None -> Some [ c ])
            acc)
        IDMap.empty ps
    in
    IDMap.iter (fun _ cs -> aux cs) node_cells;
    IDMap.values node_cells
    |> Iter.filter_map List.head_opt
    |> Iter.to_list |> aux
  in
  let p = pointees cell in
  match p with
  | [] -> ()
  | [ _ ] -> ()
  | c :: cs ->
      join_pointees p;
      (* p' can be non-empty still if cell ended up merged with something in
           the process of unification. *)
      let p' =
        pointees cell
        |> List.filter (fun c' ->
            not @@ CCEqual.physical (find_cell c') (find_cell c))
      in
      assert (
        List.for_all
          (fun c' -> CCEqual.physical (find_cell c') (find_cell c))
          cs);
      set_pointees (find_cell c :: p') cell;
      (* Need to unify all of the cells in their new node, since the new cell
           or cells in other parts of the node may have been joined together *)
      unify_node_of c

(** Unify all cells of a node *)
and unify_node_of c = node_of c |> cells |> List.iter unify_pointees

(** Find a cell corresponding to an interval in a node. If the interval overlaps
    with multiple cells, they are merged, and if it overlaps with no cells None
    is returned. *)
let rec get_cell i (n : node) : cell option =
  match !n with
  | NodePath _ ->
      let p, off = find_node n in
      get_cell (Interval.shift off i) p
  | Node r -> (
      let rec aux = function
        | [] -> []
        | x :: xs when Interval.subset i (offsets x) -> x :: aux xs
        | x :: xs -> aux xs
      in
      let cells = aux r.cells in
      match cells with
      | [] -> None
      | [ c ] -> Some c
      | c :: cs ->
          List.iter (join c) cs;
          Some c)

(** Get all cells corresponding to a value set. *)
let cells_of (v : Sva.SymAddrSetLattice.t) (g : t) : cell list =
  snd @@ Sva.SymAddrSetLattice.to_list v
  |> List.filter_map (fun (sb, i) ->
      let i = Interval.of_wint i in
      SBMap.get sb g.node_map |> Option.flat_map (fun n -> get_cell i n))

(** Merge all of the cells in a graph corresponding to an SVA term *)
let merge_vs (v : Sva.SymAddrSetLattice.t) (g : t) : unit =
  match cells_of v g with [] -> () | x :: xs -> List.iter (join x) xs

(** Get the/a cell corresponding to the given expression, following the logic of
    `get_cell` applied to the results of the SVA analysis. If uniq, then it is
    expected that a unique symbolic base corresponds to the expr, and no cells
    will be merged. Note that since this method can merge cells, unification may
    need to be re-performed. *)
let cell_of (v : Sva.SymAddrSetLattice.t) (g : t) : cell option =
  match cells_of v g with
  | [ x ] -> Some x
  | x :: xs ->
      List.iter (join x) xs;
      Some x
  | [] -> None

(** Create a copy of the given node with all reachable nodes and cells from
    pointees copied recursively. The copy of the given node is returned.

    [sbs] will update the graph's node_map with the newly copied node assigned
    said symbolic bases. It is assumed that no node with any of the given
    symbolic bases exists in the graph prior. *)
let copy_node (graph : t) ?(clear_stack = false) ?old_to_new ?(sbs = [])
    (n : node) =
  List.iter (fun n -> check_valid_node n) graph.nodes;
  (* Mappings of old nodes (in the copied-from graph) to new nodes. Since the
       old nodes won't be modified, this is safe. *)
  let old_to_new = Option.get_lazy (fun _ -> Hashtbl.create 100) old_to_new in
  let stack = Stack.create () in
  SBMap.iter (fun s n -> check_valid_node n) graph.node_map;
  (* Create a copy of the given node, with cells initialised except for their pointees *)
  let create_new_node n =
    Hashtbl.get old_to_new (node_id @@ n)
    |> Option.get_lazy (fun _ ->
        assert (not @@ Hashtbl.mem old_to_new @@ node_id n);
        let flags =
          if clear_stack then Node_flags.(clear_flag stack) (flags n)
          else flags n
        in
        let new_n = empty_node ~flags () in
        let new_cells =
          cells n
          |> List.map (fun c ->
              ref (Cell { offsets = offsets c; node = new_n; pointees = [] }))
        in
        set_cells new_cells new_n;
        Hashtbl.add old_to_new (node_id n) new_n;
        graph.nodes <- new_n :: graph.nodes;
        Stack.push (n, new_n) stack;
        new_n)
  in
  let new_n = create_new_node n in
  (* Recursively update the pointees of cells and create copies for what they point to *)
  while not @@ Stack.is_empty stack do
    let old_n, new_n = Stack.pop stack in
    List.combine (cells old_n) (cells new_n)
    |> List.iter (fun (old_c, new_c) ->
        let pointees =
          pointees old_c
          |> List.filter_map (fun old_c' ->
              let new_pointee_node = create_new_node @@ node_of old_c' in
              get_cell (offsets old_c') new_pointee_node)
        in
        set_pointees pointees new_c)
  done;
  List.iter (fun n -> check_valid_node n) graph.nodes;
  List.iter
    (fun sb ->
      if SBMap.mem sb graph.node_map then
        failwith "The old sb should not exist in the graph";
      check_valid_node new_n;
      graph.node_map <- SBMap.add sb new_n graph.node_map)
    sbs;
  new_n

(** Copy the cells corresponding to an sva value from one graph into another,
    and merge the copied cells into a single cell. Note unification needs to be
    performed afterwards. *)
let copy_cells_of ?old_to_new ?(clear_stack = false) sb from_graph to_graph =
  let old_to_new = Option.get_lazy (fun _ -> Hashtbl.create 100) old_to_new in
  let cells = cells_of sb from_graph in
  let nodes = List.map node_of cells in
  let nodes_copy =
    List.map (copy_node ~clear_stack ~old_to_new to_graph) nodes
  in
  let cells_copy =
    List.map2 (fun c n -> get_cell (offsets c) n) cells nodes_copy
    |> List.filter_map id
  in
  List.fold_left
    (fun cur c ->
      match cur with
      | None -> Some c
      | Some c' ->
          join c c';
          Some c')
    None cells_copy

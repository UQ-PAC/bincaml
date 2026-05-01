open Lang
open Common

module Constraint = struct
  type 'e t =
    | Mem of { addr : 'e; value : 'e }
    | Call of { lhs : 'e StringMap.t; args : 'e StringMap.t }
  [@@deriving eq, map]

  let show s = function
    | Mem { addr; value } -> Printf.sprintf "[|%s|] -> %s" (s addr) (s value)
    | Call _ -> "todo"

  let gen_constraints (p : Program.proc) =
    let open Stmt in
    Procedure.iter_blocks_topo_fwd p
    |> Iter.flat_map (fun (bid, block) -> Block.stmts_iter block)
    |> Iter.filter_map (fun stmt ->
        match stmt with
        | Instr_Load { lhs; addr = Addr { addr } } ->
            Some (Mem { addr; value = Expr.BasilExpr.rvar lhs })
        | Instr_Store { value; addr = Addr { addr } } ->
            Some (Mem { addr; value })
        | Instr_Call { lhs; args } ->
            Some (Call { lhs = StringMap.map Expr.BasilExpr.rvar lhs; args })
        | _ -> None)
end

open Wrapped_intervals

(* Offset interval should never overflow in userspace code, so it is fine not to use wrapped intervals (can use signed intervals that go to top on overflow instead) *)
module Interval = struct
  type t = Top | Interval of Z.t * Z.t | Bot
  [@@deriving eq, ord, show { with_path = false }]

  open Z

  let start = function Top | Bot -> None | Interval (a, _) -> Some a

  let of_wint (i : WrappedIntervalsLattice.t) =
    match i with
    | Bot -> Bot
    | Interval { lower; upper } when Bitvec.slt lower upper ->
        Interval (Bitvec.value lower, Bitvec.value upper)
    | _ -> Top

  let left_of i j =
    match (i, j) with
    | Bot, _ | Top, _ | _, Bot | _, Top -> false
    | Interval (_, b), Interval (c, _) -> lt b c

  let right_of i j =
    match (i, j) with
    | Bot, _ | Top, _ | _, Bot | _, Top -> false
    | Interval (a, _), Interval (_, d) -> lt d a

  let disjoint i j = left_of i j || right_of i j
  let overlap i j = not @@ disjoint i j

  let join i j =
    match (i, j) with
    | Bot, i | i, Bot -> i
    | Top, _ | _, Top -> Top
    | Interval (a, b), Interval (c, d) -> Interval (min a c, max b d)

  let shift off = function
    | Bot -> Bot
    | Top -> Top
    | Interval (a, b) -> Interval (a + off, b + off)
end

module DSGraph = struct
  (* A path compressed cell. Cells store a set of offsets from an abstract base
     address, and the node that it belongs to. *)
  type content =
    | Cell of { offsets : Interval.t; node : node; pointees : cell list }
    | Path of cell

  and cell = content ref

  (* Nodes are represented as sorted lists of cells, ordered by the low end of the intervals of each cell *)
  and node = cell list ref

  (** Get the union find parent of this cell *)
  let rec find (c : cell) =
    match !c with
    | Path c' ->
        let p = find c' in
        c := Path p;
        p
    | Cell _ -> c

  (** Get the offsets interval of this cell's parent *)
  let offsets (c : cell) =
    match !(find c) with
    | Cell { offsets } -> offsets
    | _ -> failwith "Union find returned non terminal cell"

  (** Get the node of this cell's parent *)
  let node_of (c : cell) =
    match !(find c) with
    | Cell { node } -> node
    | _ -> failwith "Union find returned non terminal cell"

  (** Get the pointees of this cell's parent *)
  let pointees (c : cell) =
    match !(find c) with
    | Cell { pointees } -> pointees
    | _ -> failwith "Union find returned non terminal cell"

  (** Shift the interval of the cell's parent by the given offset *)
  let shift off (c : cell) =
    let f = find c in
    match !f with
    | Cell r -> f := Cell { r with offsets = Interval.shift off r.offsets }
    | _ -> failwith "Union find returned non terminal cell"

  (** Set the node of this cell's parent *)
  let set_node node (c : cell) =
    let f = find c in
    match !f with
    | Cell r -> f := Cell { r with node }
    | _ -> failwith "Union find returned non terminal cell"

  (** Set the pointees of this cell's parent *)
  let set_pointees pointees (c : cell) =
    let f = find c in
    match !f with
    | Cell r -> f := Cell { r with pointees }
    | _ -> failwith "Union find returned non terminal cell"

  (** Merge the two given cells together. If they belong to different nodes then
      the nodes are merged so that the cell offsets line up. *)
  let rec join (c1 : cell) (c2 : cell) =
    match !c2 with
    | Path _ -> failwith "Attempted to join old cell"
    | Cell { offsets = i; pointees = p; node = n2 } -> (
        match !c1 with
        | Path _ -> join (find c1) c2
        | Cell { offsets = i'; node; pointees = p' } ->
            if not @@ CCEqual.physical node n2 then
              match Interval.(start i', start i) with
              | Some a, Some b when Z.lt a b ->
                  join_nodes_at (Z.sub b a) node n2
              | Some a, Some b -> join_nodes_at (Z.sub a b) n2 node
              | _ -> failwith "TODO"
            else (
              c2 := Path c1;
              (* TODO make O(1) also collapse pointees maybe?! something needs to be worked out for that *)
              let pointees = p @ p' in
              let offsets = Interval.join i i' in
              c1 := Cell { node; pointees; offsets };
              match offsets with Top -> collapse node | _ -> ()))

  (** Collapse all cells in the node into a single cell (its interval being Top)
  *)
  and collapse node =
    let pointees = List.fold_left (fun acc c -> acc @ pointees c) [] !node in
    let c = ref (Cell { offsets = Top; node; pointees }) in
    List.iter (fun c' -> join c c') !node;
    node := [ c ]

  (** Inserts the cell into the node. It is assumed that the cell has set (or
      will set) its node pointer outside of this call *)
  and insert node cell =
    match !cell with
    | Path _ -> insert node (find cell)
    | Cell { offsets = Interval.Bot } -> ()
    | Cell { offsets = Top } ->
        node := cell :: !node;
        collapse node
    | Cell { offsets = Interval _ as i } -> (
        let rec insert' = function
          | [] -> Some [ cell ]
          | c :: cs -> (
              match !c with
              | Path _ -> insert' (find c :: cs)
              | Cell { offsets = Top } ->
                  node := cell :: !node;
                  collapse node;
                  None
              | Cell { offsets = Bot } -> insert' cs
              | Cell { offsets = Interval _ as j } when Interval.left_of i j ->
                  Some (cell :: c :: cs)
              | Cell { offsets = Interval _ as j } when Interval.right_of i j ->
                  Option.map (List.cons c) @@ insert' cs
              | Cell { offsets = Interval _ } ->
                  join c cell;
                  Some (c :: cs))
        in
        match insert' !node with Some n -> node := n | None -> ())

  (** Join the two nodes, with the second shifted by the given offset *)
  and join_nodes_at off n1 n2 =
    assert (not @@ CCEqual.physical n1 n2);
    List.iter (shift off) !n2;
    (* Update n2 cell nodes so we never have the slow path of join *)
    List.iter (set_node n1) !n2;
    let rec join_nodes' n1' n2' =
      match (n1', n2') with
      | [], cs | cs, [] -> Some cs
      | c :: cs, c' :: cs' -> (
          match (offsets c, offsets c') with
          (* TODO Bot cases shouldn't happen i think?! please confirm this, future worker *)
          | Bot, Bot -> join_nodes' cs cs'
          | Bot, _ -> join_nodes' cs n2'
          | _, Bot -> join_nodes' n1' cs'
          | Top, _ | _, Top ->
              n1 := !n1 @ !n2;
              collapse n1;
              None
          | (Interval _ as i), (Interval _ as j) when Interval.left_of i j ->
              Option.map (List.cons c) @@ join_nodes' cs n2'
          | (Interval _ as i), (Interval _ as j) when Interval.right_of i j ->
              Option.map (List.cons c) @@ join_nodes' n1' cs'
          | Interval (a, b), Interval (x, y) when Z.leq b y ->
              (* first cell is left of second cell, so join first cell into second to preserve order *)
              join c' c;
              join_nodes' n1' cs'
          | Interval (a, b), Interval (x, y) ->
              (* second cell is left of first cell, so join second cell into first to preserve order *)
              join c c';
              join_nodes' cs n2')
    in
    match join_nodes' !n1 !n2 with Some n -> n1 := n | _ -> ()

  (** Check that the node has its cell intervals sorted and disjoint *)
  let check_sorted node =
    let is = List.map offsets !node in
    let rec aux = function
      | [] | [ _ ] -> true
      | i :: (j :: _ as tail) -> Interval.left_of i j && aux tail
    in
    assert (aux is)

  (** Create a single cell belonging to its own node *)
  let init offsets : cell =
    let node = ref [] in
    let c = ref (Cell { offsets; node; pointees = [] }) in
    insert node c;
    c
end

module SBMap = Map.Make (Sva.SymBase)

let make_local_graph (constraints : Sva.SymAddrSetLattice.t Constraint.t Iter.t)
    =
  (* Create just the cells *)
  let add_cells sv m = failwith "todo" in

  let g =
    Iter.fold
      (fun acc constr ->
        match constr with
        | Constraint.Mem { addr; value } ->
            let acc, ptrs = add_cells addr acc in
            let acc, vals = add_cells value acc in
            (* TODO Add edges between (unify later) *)
            acc
        | Constraint.Call { lhs; args } -> failwith "todo")
      SBMap.empty constraints
    |> SBMap.values |> Iter.to_list
  in

  (* make joining nodes unify with union find

     solve:
     join overlapping cells in nodes
     init workist to sets of codomains of cells greater than 1 in size
     // maybe worklist isn't needed and we can just iterate over all cells
     // no but maybe if you recursively unify joined codomain cells it works (tail recurse?!)
     // if we do this then no operations *create* new cells with multiple out edges
     // should be good but also does iteration order matter?!
     for each:
         unify set
         grow worklist

     unify set S:
     compute offsets per node
     // what if we used a funky data structure that encoded a union of intervals, instead of imprecisely joining them and deleting their holes?!
     make all nodes of cells to be unified point to a single node (offsets adjusted)
     fix overlapping intervals

     the union of intervals data structure (might not work) alternatively this is a data structure to represent nodes:
     leaves: intervals that are all disjoint
     binary branches:
         leaves are all disjoint intervals with ordering invariant
         approximates a whole interval (join of all leaves)
         the left branch has its own interval range
         the right too
         store on the branch the interval between the left branch's right point and right branches left point
     element of queries are log n
     does there exist an efficient algorithm to join two trees?! what about n trees? what if we want to add offsets to trees we are joining?
     looks like yes, since such algorithms exist for various balanced bsts
     offsets can probably be handled too as edges in the tree
     *)
  g

let dsa (p : Program.t) =
  let _sva_r = Sva.sva p in
  (*
  let _local_graphs =
    IDMap.mapi
      (fun pid r ->
        let proc = Program.proc p pid in
        let constraints =
          Constraint.gen_constraints proc
          |> Iter.map
               (Constraint.map
                  (Sva.Eval.EV.eval (flip Sva.StateAbstraction.read r)))
        in
        make_local_graph constraints)
      sva_r
  in
  *)
  p

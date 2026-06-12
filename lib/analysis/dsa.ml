open Lang
open Common
open Wrapped_intervals

(* TODO flags so that the analysis results can actually be used *)

(* Offset interval should never overflow in userspace code, so it is fine to
   not use wrapped intervals within the DS graph itself. *)
module Interval = struct
  type t = Top | Interval of Z.t * Z.t | Bot
  [@@deriving eq, ord, show { with_path = false }]

  open Z

  let show = function
    | Top -> "Top"
    | Bot -> "Bot"
    | Interval (a, b) ->
        Printf.sprintf "[%s, %s]" (Z.to_string a) (Z.to_string b)

  let dbg = function
    | Top -> "Top"
    | Bot -> "Bot"
    | Interval (a, b) ->
        Printf.sprintf "Interval.Interval (Z.of_int (%s), Z.of_int (%s))"
          (Z.to_string a) (Z.to_string b)

  let start = function Top | Bot -> None | Interval (a, _) -> Some a

  let of_wint (i : WrappedIntervalsLattice.t) =
    match i with
    | Bot -> Bot
    | Interval { lower; upper } when Bitvec.sle lower upper ->
        Interval (Bitvec.to_signed_bigint lower, Bitvec.to_signed_bigint upper)
    | _ -> Top

  let pad_with_size size = function
    | Interval (a, b) -> Interval (a, b + Z.of_int (Int.( / ) size 8) - Z.one)
    | otherwise -> otherwise

  let left_of i j =
    match (i, j) with
    | Bot, _ | Top, _ | _, Bot | _, Top -> false
    | Interval (_, b), Interval (c, _) -> lt b c

  let right_of i j = left_of j i
  let disjoint i j = left_of i j || right_of i j
  let overlap i j = not @@ disjoint i j

  let elem x i =
    match i with
    | Bot -> false
    | Top -> true
    | Interval (a, b) -> Z.leq a x && Z.leq x b

  let subset i j =
    match (i, j) with
    | Bot, Bot | Top, Top | Bot, _ | _, Top -> true
    | _, Bot | Top, _ -> false
    | Interval (a, b), Interval (c, d) ->
        Z.leq c a && Z.leq a d && Z.leq c b && Z.leq b d

  let join i j =
    match (i, j) with
    | Bot, i | i, Bot -> i
    | Top, _ | _, Top -> Top
    | Interval (a, b), Interval (c, d) -> Interval (min a c, max b d)

  let shift off = function
    | Bot -> Bot
    | Top -> Top
    | Interval (a, b) -> Interval (a + off, b + off)

  let width = function
    | Bot -> None
    | Top -> None
    | Interval (a, b) -> Some (Z.to_int (b - a + one))
end

module NodeFlags = struct
  (* A bool uses 64 bits of memory and we're storing flags per node so it's probably worth using bitflags *)
  type t = int

  let empty = 0
  let ( >> ) = Int.shift_right_logical
  let ( << ) = Int.shift_left
  let ( || ) = Int.logor
  let ( & ) = Int.logand
  let ( != ) a b = not @@ (a = b)
  let get_flag idx f = (f >> idx & 1) != 0
  let set_flag idx f = f || 1 << idx
  let clear_flag idx f = f & Int.lognot (1 << idx)

  (* CCBitField didn't have a join function :( *)
  let join f f' = f || f'

  (* Should be used like `get_flag heap f` or `clear_flag unknown f` *)
  let heap = 0
  let stack = 1
  let global = 2
  let unknown = 3
  let modified = 4
  let read = 5
  let complete = 6
  let collapsed = 7

  let show f =
    (if get_flag heap f then "H" else "")
    ^ (if get_flag stack f then "S" else "")
    ^ (if get_flag global f then "G" else "")
    ^ (if get_flag unknown f then "U" else "")
    ^ (if get_flag modified f then "M" else "")
    ^ (if get_flag read f then "R" else "")
    ^ (if get_flag complete f then "C" else "")
    ^ if get_flag collapsed f then "O" else ""
end

module Constraint = struct
  type 'e t =
    | Mem of { addr : 'e; value : 'e; size : int }
    (* Actual * Formal pairs *)
    | Call of { lhs : ('e * 'e) list; args : ('e * 'e) list; callee_id : ID.t }
  [@@deriving eq]

  (** Special funky map where the second function evaluates within a procedure
      id for call constraint callee formal arguments *)
  let map f g c =
    match c with
    | Mem { addr; value; size } -> Mem { addr = f addr; value = f value; size }
    | Call { lhs; args; callee_id } ->
        let lhs =
          List.map (fun (actual, formal) -> (f actual, g callee_id formal)) lhs
        in
        let args =
          List.map (fun (actual, formal) -> (f actual, g callee_id formal)) args
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

module SBMap = Map.Make (Sva.SymBase)

(* TODO decide on how flags should be tested (if at all) maybe only test in expect tests
          and also symbolic bases probably*)
(* TODO put this in a separate file somehow *)

(** A purely functional (and less efficient) representation of DSGraphs to be
    used as a model for testing against, which is based on the DSA paper! It's
    also very ugly because it is based on lots of giant set comprehensions but
    oh well... *)
module FormalDSGraph = struct
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

  (** Update an old-to-new mapping after a join of overlapping cells is
      performed. *)
  let extend_old_to_new_join old_cells new_cells m =
    CellSet.to_list old_cells
    |> List.product Pair.make (CellSet.to_list new_cells)
    |> List.filter (fun ((c : Cell.t), (c' : Cell.t)) ->
        (not @@ Interval.equal c.offsets c'.offsets)
        && c.node = c'.node
        && Interval.subset c.offsets c'.offsets)
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
    assert (not @@ CellMap.mem cell g.old_to_new);
    let cells = CellSet.add cell g.cells in
    join_overlapping_cells { g with cells }

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

  (** Unify all cells in the given set. If cells are in different nodes, the
      nodes are joined together into a single node with offsets corrected. This
      node is returned with the new graph along with the map function from the
      paper. *)
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
        (fun (c : Cell.t) ->
          IntSet.mem c.node nodes && (not @@ CellSet.mem c cs))
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
          List.map (fun (n, s) -> (n, Z.sub start_max s)) starts
          |> IntMap.of_list
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
            CellSet.find_first
              (fun (c' : Cell.t) -> Interval.subset o c'.offsets)
              n
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
             let cur = CellMap.get_or c acc ~default:CellSet.empty in
             CellMap.add c (CellSet.add c' cur) acc
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
    iter (pointees g.cells g.edges) g

  (** Copy cells from the second graph into the first, with their corresponding
      nodes copied along. The returned graph is the new first graph, and a
      mapping of second-graph-cell to copied-cells is returned with it *)
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
end

module DSGraph = struct
  (** A path compressed cell. Cells store a set of offsets from an abstract base
      address, the node that it belongs to, and a list of cells it points to
      (that will be a singleton or empty after unification). *)
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
        mutable flags : NodeFlags.t;
        id : ID.t;
      }
    | NodePath of node * Z.t

  and node = node_content ref

  type t = { mutable nodes : node list; mutable node_map : node SBMap.t }
  (** A graph, which keeps track of all nodes and also which nodes come from
      each symbolic base (there is duplicate information). *)

  let empty_graph () = { nodes = []; node_map = SBMap.empty }
  let nodes (g : t) = g.nodes
  let node_map (g : t) = g.node_map
  let id_gen = ID.make_gen ()

  (** Get the union find parent of this cell *)
  let rec find (c : cell) =
    match !c with
    | Path c' ->
        let p = find c' in
        c := Path p;
        p
    | Cell _ -> c

  (** Get the union find parent of this cell *)
  let rec find_node (n : node) =
    match !n with
    | NodePath (n', off) ->
        let p, off' = find_node n' in
        n := NodePath (p, Z.add off off');
        (p, Z.add off off')
    | Node _ -> (n, Z.zero)

  (** Get the offsets interval of this cell's parent *)
  let rec offsets (c : cell) =
    match !c with Path _ -> offsets (find c) | Cell { offsets } -> offsets

  (** Get the node of this cell's parent *)
  let rec node_of (c : cell) =
    match !c with Path _ -> node_of (find c) | Cell { node } -> node

  (** Get the pointees of this cell's parent *)
  let rec pointees (c : cell) =
    match !c with Path _ -> pointees (find c) | Cell { pointees } -> pointees

  (** Shift the interval of the cell's parent by the given offset *)
  let rec shift off (c : cell) =
    match !c with
    | Path _ -> shift off (find c)
    | Cell r -> r.offsets <- Interval.shift off r.offsets

  (** Set the node of this cell's parent *)
  let rec set_node node (c : cell) =
    match !c with Path _ -> set_node node (find c) | Cell r -> r.node <- node

  (** Set the pointees of this cell's parent *)
  let rec set_pointees pointees (c : cell) =
    match !c with
    | Path _ -> set_pointees pointees (find c)
    | Cell r -> r.pointees <- pointees

  (** Add to the list of pointees of this cell's parent *)
  let rec add_pointees pointees (c : cell) =
    match !c with
    | Path _ -> add_pointees pointees (find c)
    | Cell r ->
        r.pointees <-
          List.fold_left
            (flip (List.add_nodup ~eq:CCEqual.physical))
            r.pointees (List.map find pointees)

  (** Get the cells of this node's parent *)
  let rec cells (n : node) =
    match !n with NodePath _ -> cells (fst @@ find_node n) | Node r -> r.cells

  (** Get the flags of this node's parent *)
  let rec flags (n : node) =
    match !n with NodePath _ -> flags (fst @@ find_node n) | Node r -> r.flags

  (** Get the id of this node's parent *)
  let rec id (n : node) =
    match !n with NodePath _ -> id (fst @@ find_node n) | Node r -> r.id

  (** Set the cells of this node *)
  let rec set_cells cells (n : node) =
    match !n with
    | NodePath _ -> set_cells cells (fst @@ find_node n)
    | Node r -> r.cells <- cells

  (** Join the flags of this node with the new flags *)
  let rec join_flags flags (n : node) =
    match !n with
    | NodePath _ -> join_flags flags (fst @@ find_node n)
    | Node r -> r.flags <- NodeFlags.join r.flags flags

  (** Make the second cell point to the first *)
  let rec join_paths (c1 : cell) (c2 : cell) =
    match (!c1, !c2) with
    | Path _, Path _ -> join_paths (find c1) (find c2)
    | Path _, _ -> join_paths (find c1) c2
    | _, Path _ -> join_paths c1 (find c2)
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
  let rec collapse node =
    match !node with
    | NodePath _ -> collapse (fst @@ find_node node)
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
        let flags = NodeFlags.(set_flag collapsed r.flags) in
        r.cells <- [ c ];
        r.flags <- flags

  (** Join c2 into c1 under the assumption that they are in the same node. It is
      left to the caller to preserve node structure. *)
  let rec join_cells_only c1 c2 =
    match (!c1, !c2) with
    | Path _, Path _ -> join_cells_only (find c1) (find c2)
    | Path _, _ -> join_cells_only (find c1) c2
    | _, Path _ -> join_cells_only c1 (find c2)
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

  (** Join the two nodes, with the second shifted by the given offset. The
      second node becomes a NodePath and the first is kept *)
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
          let flags = NodeFlags.join r1.flags r2.flags in
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
                | (Interval _ as i), (Interval _ as j)
                  when Interval.right_of i j ->
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
        | Path _ -> insert node (find cell)
        | Cell { offsets = Interval.Bot } ->
            failwith "Bot cells should not exist"
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
                  | Path _ -> insert' (find c :: cs)
                  | Cell { offsets = Top } ->
                      node := Node { r with cells = cell :: r.cells };
                      collapse node;
                      None
                  | Cell { offsets = Bot } ->
                      failwith "Bot cells should not exist"
                  | Cell { offsets = Interval _ as j } when Interval.left_of i j
                    ->
                      Some (cell :: c :: cs)
                  | Cell { offsets = Interval _ as j }
                    when Interval.right_of i j ->
                      Option.map (List.cons c) @@ insert' cs
                  | Cell { offsets = Interval _ } ->
                      (* If `cell` overlaps with `c`, join `cell` and `c`
                         together and drop `c` from the list *)
                      join_cells_only cell c;
                      insert' cs)
            in
            match insert' r.cells with Some n -> r.cells <- n | None -> ()))

  (** Creates an empty node *)
  let empty_node ?(flags = NodeFlags.empty) () =
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
  let rec join (c1 : cell) (c2 : cell) =
    if CCEqual.physical c1 c2 then ()
    else
      match !c2 with
      | Path _ -> join c1 (find c2)
      | Cell { offsets = i'; pointees = p; node = n2 } -> (
          match !c1 with
          | Path _ -> join (find c1) c2
          | Cell { offsets = i; node = n1; pointees = p' } ->
              (* Note that cells know their up to date interval relative to the
                 unification offset, so the intervals should not be updated. *)
              let n1, _ = find_node n1 in
              let n2, _ = find_node n2 in
              if not @@ CCEqual.physical n1 n2 then
                match Interval.(start i, start i') with
                | Some a, Some b when Z.lt a b ->
                    join_nodes_at (Z.sub a b) n1 n2
                | Some a, Some b -> join_nodes_at (Z.sub b a) n2 n1
                | _ -> join_nodes_at Z.zero n1 n2
              else
                let offsets = Interval.join i i' in
                let fill = ref (Cell { offsets; node = n1; pointees = [] }) in
                insert n1 fill)

  (** Unify the pointees of this cell and recurse *)
  let rec unify_pointees cell =
    let rec aux a = function
      | [] -> ()
      | b :: cs ->
          join a b;
          aux a cs
    in
    let p = pointees cell in
    match p with
    | [] -> ()
    | [ _ ] -> ()
    | c :: cs ->
        aux c cs;
        (* p' is non-empty only if `cell` pointed to itself, in which case it
           would have been merged with its other pointees and recursed on *)
        let p' =
          pointees cell
          |> List.filter (fun c' -> not @@ CCEqual.physical (find c') (find c))
        in
        if not @@ List.is_empty p' then
          assert (CCEqual.physical (find cell) (find c));
        assert (List.for_all (fun c' -> CCEqual.physical (find c') (find c)) cs);
        set_pointees (find c :: p') cell;
        (* Need to unify all of the cells in their new node, since cells in
           other parts of the node may have been joined together *)
        node_of c |> cells |> List.iter unify_pointees

  (** Find a cell corresponding to an interval in a node. If the interval
      overlaps with multiple cells, they are merged, and if it overlaps with no
      cells None is returned. *)
  let rec get_cell ?(uniq = false) i (n : node) : cell option =
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
        | c :: cs when uniq -> failwith "Non unique cell given"
        | c :: cs ->
            List.iter (join c) cs;
            Some c)

  (** Get all cells corresponding to a value set. *)
  let cells_of ?(uniq = false) (v : Sva.SymAddrSetLattice.t) (g : t) : cell list
      =
    snd @@ Sva.SymAddrSetLattice.to_list v
    |> List.filter_map (fun (sb, i) ->
        let i = Interval.of_wint i in
        SBMap.get sb g.node_map |> Option.flat_map (fun n -> get_cell ~uniq i n))

  (** Merge all of the cells in a graph corresponding to an SVA term *)
  let merge_vs (v : Sva.SymAddrSetLattice.t) (g : t) : unit =
    match cells_of v g with [] -> () | x :: xs -> List.iter (join x) xs

  (** Get the/a cell corresponding to the given expression, following the logic
      of `get_cell` applied to the results of the SVA analysis. If uniq, then it
      is expected that a unique symbolic base corresponds to the expr, and no
      cells will be merged. *)
  let cell_of ?(uniq = false) (v : Sva.SymAddrSetLattice.t) (g : t) :
      cell option =
    match cells_of ~uniq v g with
    | [ x ] -> Some x
    | x :: xs when not uniq ->
        List.iter (join x) xs;
        (* TODO should this unify_pointees? *)
        Some x
    | x :: xs when List.for_all (CCEqual.physical (find x) % find) xs -> Some x
    | x :: xs -> failwith "Non unique cell given"
    | [] -> None

  (** Create a copy of the given node with all reachable nodes and cells from
      pointees copied recursively. The copy of the given node is returned.

      `sbs` will update the graph's node_map with the newly copied node assigned
      said symbolic bases. It is assumed that no node with any given sb exists
      in the graph prior. *)
  let copy_node (graph : t) ?(clear_stack = false) ?old_to_new ?(sbs = [])
      (n : node) =
    (* Mappings of old nodes (in the copied-from graph) to new nodes. Since the
       old nodes won't be modified, this is safe. *)
    let old_to_new = Option.get_lazy (fun _ -> Hashtbl.create 100) old_to_new in
    let stack = Stack.create () in
    SBMap.iter (fun s n -> check_valid_node n) graph.node_map;
    (* Create a copy of the given node, with cells initialised except for their pointees *)
    let create_new_node n =
      Hashtbl.get old_to_new (id @@ n)
      |> Option.get_lazy (fun _ ->
          assert (not @@ Hashtbl.mem old_to_new @@ id n);
          let flags =
            if clear_stack then NodeFlags.(clear_flag stack) (flags n)
            else flags n
          in
          let new_n = empty_node ~flags () in
          let new_cells =
            cells n
            |> List.map (fun c ->
                ref (Cell { offsets = offsets c; node = new_n; pointees = [] }))
          in
          set_cells new_cells new_n;
          Hashtbl.add old_to_new (id n) new_n;
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
end

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

  (* Unify all pointees *)
  Vector.iter DSGraph.unify_pointees cells;

  (* Join formal in/out params while preserving unification *)
  Procedure.formal_in_params proc
  |> StringMap.values
  |> Iter.append (Procedure.formal_out_params proc |> StringMap.values)
  |> Iter.iter (fun v ->
      let v = Sva.StateAbstraction.read v sva in
      (* TODO I think this needs to be run in a fixed point loop since unifying
              and merging can break each other :(( *)
      DSGraph.merge_vs v g;
      DSGraph.(Option.iter unify_pointees @@ cell_of ~uniq:true v g));

  (* Check formal in/out params are unique (there is an assert in cell_of) *)
  Procedure.formal_in_params proc
  |> StringMap.values
  |> Iter.append (Procedure.formal_out_params proc |> StringMap.values)
  |> Iter.iter (fun v ->
      let v = Sva.StateAbstraction.read v sva in
      ignore @@ DSGraph.cell_of ~uniq:true v g);

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
     let* formal_cell = cell_of ~uniq:true formal graph in
     let* actual_cell = cell_of actual graph in
     join actual_cell formal_cell;
     node_of actual_cell |> cells |> List.iter unify_pointees;
     check_unique_pointee graph;
     None)

(** Copy and merge the formal cell from the callee graph with the actual cells
    of the caller graph. *)
let resolve_callee old_to_new caller_graph callee_graph actual formal =
  ignore
    (let open Option.Infix in
     let open DSGraph in
     let* callee_cell = cell_of ~uniq:true formal callee_graph in
     (* Only do the joining if a caller cell actually exists *)
     let* caller_cell = cell_of actual caller_graph in
     node_of caller_cell |> cells |> List.iter unify_pointees;
     let callee_node = node_of callee_cell in
     (* We copy with no symbases to avoid merging copied graphs from different calls to the same callee *)
     let callee_node_copy =
       copy_node ~clear_stack:true ~old_to_new caller_graph callee_node
     in
     let* callee_cell_copy = get_cell (offsets callee_cell) callee_node_copy in
     (* TODO clean this up by calling resolve_arguments or something *)
     unify_pointees callee_cell_copy;
     join caller_cell callee_cell_copy;
     node_of caller_cell |> cells |> List.iter unify_pointees;
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

  (* This is pretty much exactly taken from Latner's thesis, it computes sccs in the call graph and calls `process_scc` on them. *)
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
    (* TODO this feels like it should be simplified a lot... *)
    (* Resolve all out-of-scc calls *)
    IDSet.iter
      (fun pid ->
        let constraints, caller_graph = IDMap.find pid !graphs in
        SBMap.iter
          (fun s n -> DSGraph.check_valid_node n)
          (DSGraph.node_map caller_graph);
        Iter.iter
          Constraint.(
            function
            | Call { lhs; args; callee_id } when not @@ IDSet.mem callee_id scc
              ->
                let old_to_new = Hashtbl.create 100 in
                let _, callee_graph = IDMap.find callee_id !graphs in
                args @ lhs
                |> List.iter (fun (a, f) ->
                    resolve_callee old_to_new caller_graph callee_graph a f)
            | _ -> ())
          constraints)
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
              |> SBMap.iter (fun sb n ->
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
    IDSet.iter
      (fun pid ->
        let constraints, _ = IDMap.find pid !graphs in
        SBMap.iter
          (fun s n -> DSGraph.check_valid_node n)
          (DSGraph.node_map scc_graph);
        Iter.iter
          Constraint.(
            function
            | Call { lhs; args; callee_id } when IDSet.mem callee_id scc ->
                args @ lhs
                |> List.iter (fun (a, f) -> resolve_arguments scc_graph a f)
            | _ -> ())
          constraints)
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
  SBMap.iter
    (fun sb n ->
      let s = Hashtbl.get_or node_sbs (ID.index @@ DSGraph.id n) ~default:"" in
      Hashtbl.add node_sbs
        (ID.index @@ DSGraph.id n)
        (s ^ "\\n"
        ^ (Sva.SymBase.show sb
          |> String.replace ~sub:"\"" ~by:"\\\""
          |> String.replace ~sub:"{" ~by:"\\{"
          |> String.replace ~sub:"}" ~by:"\\}")))
    (DSGraph.node_map graph);

  let nodes =
    DSGraph.nodes graph
    |> List.map DSGraph.(fun n -> (id n, fst @@ find_node n))
    |> IDMap.of_list |> IDMap.to_list |> List.map snd
  in

  let node_contents =
    nodes
    |> List.map (fun node ->
        let nid = ID.index @@ DSGraph.id node in
        ( nid,
          DSGraph.flags node,
          List.map
            (fun cell ->
              let cid = take_id cur_cid () in
              Hashtbl.add nid_map cid nid;
              (cid, DSGraph.find cell))
            (DSGraph.cells node) ))
  in
  let cells = List.flat_map (fun (_, _, cells) -> cells) node_contents in
  let pointees = Hashtbl.create 100 in
  List.iter
    (fun (cid, cell) ->
      let ps =
        List.map
          (fun c' ->
            let c' = DSGraph.find c' in
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
        print_endline @@ ID.show pid;
        let proc = Program.proc p pid in
        let constraints =
          Constraint.gen_constraints p proc
          |> Iter.map (Constraint.map (translate pid) translate)
          |> Iter.persistent
        in
        (pid, (constraints, make_local_graph proc sva constraints)))
    |> IDMap.of_list
  in
  print_endline "local phase done";
  let bu_graphs =
    Trace_core.with_span ~__FILE__ ~__LINE__ "bottom up phase" @@ fun _ ->
    bottom_up p local_graphs
  in
  List.iter
    (fun (id, graph) ->
      print_endline @@ ID.show id;
      print_endline @@ dot_string graph)
    (List.map
       (fun (pid, (_, (graph : DSGraph.t))) -> (pid, graph))
       (IDMap.to_list bu_graphs));
  p

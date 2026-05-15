open Lang
open Common
open Wrapped_intervals

(* Offset interval should never overflow in userspace code, so it is fine not to use wrapped intervals (can use signed intervals that go to top on overflow instead) *)
module Interval = struct
  type t = Top | Interval of Z.t * Z.t | Bot
  [@@deriving eq, ord, show { with_path = false }]

  open Z

  let show = function
    | Top -> "Top"
    | Bot -> "Bot"
    | Interval (a, b) ->
        Printf.sprintf "[%s, %s]" (Z.to_string a) (Z.to_string b)

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

  let right_of i j =
    match (i, j) with
    | Bot, _ | Top, _ | _, Bot | _, Top -> false
    | Interval (a, _), Interval (_, d) -> lt d a

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
    | Join of 'e
  [@@deriving eq]

  (** Special funky map where the second function evaluates within a procedure
      id *)
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
    | Join e -> Join (f e)

  let show s = function
    | Mem { addr; value } -> Printf.sprintf "[|%s|] -> %s" (s addr) (s value)
    | Call { lhs; args } ->
        (*
        Printf.sprintf "in: %s, out: %s"
          (StringMap.to_iter args
          |> Iter.to_string ~sep:", " (fun (str, e) -> str ^ " -> " ^ s e))
          (StringMap.to_iter lhs
          |> Iter.to_string ~sep:", " (fun (str, e) -> str ^ " -> " ^ s e))*)
        "noisy"
    | Join e -> Printf.sprintf "Join %s" (s e)

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

module DSGraph = struct
  (* TODO mutable keyword *)
  (* A path compressed cell. Cells store a set of offsets from an abstract base
     address, and the node that it belongs to. *)
  type content =
    | Cell of { offsets : Interval.t; node : node; pointees : cell list }
    | Path of cell

  and cell = content ref

  (* Nodes are represented as sorted lists of cells, ordered by the low end of the intervals of each cell *)
  and node_content =
    (* ID's CAN change when nodes are mutated!! Make sure that if ids are ever used, the nodes whos ids are being used won't change!!!! *)
    | Node of { cells : cell list; flags : NodeFlags.t; id : ID.t }
    (* Node was joined into parent at the given offset *)
    | NodePath of node * Z.t

  and node = node_content ref

  type t = {
    mutable nodes : node list;
    mutable node_map : node SBMap.t;
    sva : Sva.StateAbstraction.t;
  }

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
        n := NodePath (p, off');
        (p, off')
    | Node _ -> (n, Z.zero)

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
    | Node r -> n := Node { r with cells }

  (** Set the flags of this node *)
  let rec set_flags flags (n : node) =
    match !n with
    | NodePath _ -> set_flags flags (fst @@ find_node n)
    | Node r -> n := Node { r with flags }

  (** Make the second cell point to the first *)
  let rec join_paths (c1 : cell) (c2 : cell) =
    match (!c1, !c2) with
    | Path _, Path _ -> join_paths (find c1) (find c2)
    | Path _, _ -> join_paths (find c1) c2
    | _, Path _ -> join_paths c1 (find c2)
    | Cell r, Cell { pointees = p } ->
        if not @@ CCEqual.physical c1 c2 then c2 := Path c1

  (** Collapse all cells in the node into a single cell (its interval being Top)
  *)
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
        node := Node { r with cells = [ c ]; flags }

  (** Merge the two given cells together. If they belong to different nodes then
      the nodes are merged so that the cell offsets line up. *)
  let rec join (c1 : cell) (c2 : cell) =
    if CCEqual.physical c1 c2 then ()
    else
      match !c2 with
      | Path _ -> join c1 (find c2)
      | Cell { offsets = i; pointees = p; node = n2 } -> (
          match !c1 with
          | Path _ -> join (find c1) c2
          | Cell { offsets = i'; node; pointees = p' } ->
              if not @@ CCEqual.physical node n2 then
                match Interval.(start i', start i) with
                | Some a, Some b when Z.lt a b ->
                    join_nodes_at (Z.sub b a) node n2
                | Some a, Some b -> join_nodes_at (Z.sub a b) n2 node
                | _ -> join_nodes_at Z.zero node n2
              else (
                c2 := Path c1;
                (* TODO make better algorithm for this *)
                let pointees =
                  List.fold_left
                    (flip (List.add_nodup ~eq:CCEqual.physical))
                    p p'
                in
                let offsets = Interval.join i i' in
                c1 := Cell { node; pointees; offsets };
                match offsets with Top -> collapse node | _ -> ()))

  (** Join the two nodes, with the second shifted by the given offset. The
      second node is deleted and the first is kept *)
  and join_nodes_at off n1 n2 =
    match (!n1, !n2) with
    | NodePath _, _ ->
        let p, off' = find_node n1 in
        join_nodes_at (Z.( - ) off off') p n2
    | _, NodePath _ ->
        let p, off' = find_node n2 in
        join_nodes_at (Z.( + ) off off') n1 p
    | Node r1, Node r2 -> (
        assert (not @@ CCEqual.physical n1 n2);
        List.iter (shift off) r2.cells;
        (* Update n2 cell nodes so we never have the slow path of join *)
        (* This could technically be redundant though hmmmm *)
        List.iter (set_node n1) r2.cells;
        let flags = NodeFlags.join r1.flags r2.flags in
        let rec join_nodes' n1' n2' =
          match (n1', n2') with
          | [], cs | cs, [] -> Some cs
          | c :: cs, c' :: cs' -> (
              match (offsets c, offsets c') with
              (* TODO Bot cases shouldn't happen i think?! please confirm this *)
              | Bot, Bot -> join_nodes' cs cs'
              | Bot, _ -> join_nodes' cs n2'
              | _, Bot -> join_nodes' n1' cs'
              | Top, _ | _, Top ->
                  n1 := Node { r1 with cells = r1.cells @ r2.cells; flags };
                  n2 := NodePath (n1, off);
                  collapse n1;
                  None
              | (Interval _ as i), (Interval _ as j) when Interval.left_of i j
                ->
                  Option.map (List.cons c) @@ join_nodes' cs n2'
              | (Interval _ as i), (Interval _ as j) when Interval.right_of i j
                ->
                  Option.map (List.cons c') @@ join_nodes' n1' cs'
              | Interval (a, b), Interval (x, y) when Z.leq b y ->
                  (* first cell is left of second cell, so join first cell into second to preserve order *)
                  join c' c;
                  join_nodes' cs n2'
              | Interval (a, b), Interval (x, y) ->
                  (* second cell is left of first cell, so join second cell into first to preserve order *)
                  join c c';
                  join_nodes' n1' cs')
        in
        match join_nodes' r1.cells r2.cells with
        | Some n ->
            n1 := Node { r1 with cells = n; flags };
            n2 := NodePath (n1, off)
        | _ -> ())

  (** Inserts the cell into the node. It is assumed that the cell has set (or
      will set) its node pointer outside of this call *)
  let rec insert node cell =
    match !node with
    | NodePath _ ->
        let p, off = find_node node in
        shift off cell;
        insert p cell
    | Node r -> (
        match !cell with
        | Path _ -> insert node (find cell)
        | Cell { offsets = Interval.Bot } -> ()
        | Cell { offsets = Top } ->
            node := Node { r with cells = cell :: r.cells };
            collapse node
        | Cell { offsets = Interval _ as i } -> (
            let rec insert' = function
              | [] -> Some [ cell ]
              | c :: cs -> (
                  match !c with
                  | Path _ -> insert' (find c :: cs)
                  | Cell { offsets = Top } ->
                      node := Node { r with cells = cell :: r.cells };
                      collapse node;
                      None
                  | Cell { offsets = Bot } -> insert' cs
                  | Cell { offsets = Interval _ as j } when Interval.left_of i j
                    ->
                      Some (cell :: c :: cs)
                  | Cell { offsets = Interval _ as j }
                    when Interval.right_of i j ->
                      Option.map (List.cons c) @@ insert' cs
                  | Cell { offsets = Interval _ } ->
                      join c cell;
                      Some (c :: cs))
            in
            match insert' r.cells with
            | Some n -> node := Node { r with cells = n }
            | None -> ()))

  (** Check that the node has its cell intervals sorted and disjoint *)
  let check_sorted node =
    let is = List.map offsets !node in
    let rec aux = function
      | [] | [ _ ] -> true
      | i :: (j :: _ as tail) -> Interval.left_of i j && aux tail
    in
    assert (aux is)

  (** Creates an empty node *)
  let empty_node () =
    ref (Node { cells = []; flags = NodeFlags.empty; id = ID.fresh id_gen () })

  (** Create a single cell belonging to its own node *)
  let init offsets flags : cell =
    let node = ref (Node { cells = []; flags; id = ID.fresh id_gen () }) in
    let c = ref (Cell { offsets; node; pointees = [] }) in
    insert node c;
    c

  (** Unify all pointees of this cell so that it points to only one cell, then
      recurse on that cell *)
  let rec unify_pointees cell =
    let rec aux = function
      | [] | [ _ ] -> ()
      | a :: (b :: cs as tail) ->
          join a b;
          aux tail
    in
    let p = pointees cell in
    aux p;
    match p with
    | [] -> ()
    | c :: cs ->
        set_pointees [ find c ] cell;
        if not @@ List.is_empty cs then unify_pointees (find c)

  (** Create a node from a list of singleton cells by effectively performing
      merge sort *)
  let merge_init cells : node =
    let rec sort n cs =
      match (n, cs) with
      | 0, cs -> (empty_node (), cs)
      | 1, c :: cs -> (node_of c, cs)
      | n, cs ->
          let a = n / 2 in
          let l, rem = sort a cs in
          let r, cs = sort (n - a) rem in
          join_nodes_at Z.zero l r;
          (l, cs)
    in
    let l = List.length cells in
    fst @@ sort l cells

  (** Find a cell corresponding to an interval in a node. If the interval
      overlaps with multiple cells, they are merged, and if it overlaps with no
      cells a new cell is created. *)
  let rec get_cell ?(uniq = false) i (n : node) =
    match !n with
    | NodePath _ ->
        let p, off = find_node n in
        get_cell (Interval.shift off i) p
    | Node r -> (
        (* TODO switch to another data structure to log(n)-ify this *)
        let rec aux = function
          | [] -> []
          | x :: xs when Interval.subset i (offsets x) -> x :: aux xs
          | x :: xs -> aux xs
        in
        let cells = aux r.cells in
        match cells with
        | [] ->
            (* TODO this is suboptimal and traverses the node list twice *)
            let cell = ref (Cell { offsets = i; node = n; pointees = [] }) in
            insert n cell;
            cell
        | [ c ] -> c
        | c :: cs when uniq -> failwith "TODO"
        | c :: cs ->
            ignore
            @@ List.fold_left
                 (fun c c' ->
                   join c c';
                   c)
                 c cs;
            c)

  (** Get the/a cell corresponding to the given expression, following the logic
      of `get_cell` applied to the results of the SVA analysis. If uniq, then it
      is expected that a unique symbolic base corresponds to the expr, and no
      cells will be merged. TODO rewrite this because it can return none too *)
  let cell_of ?(uniq = false) (v : Sva.SymAddrSetLattice.t) (g : t) :
      cell option =
    let v = snd @@ Sva.SymAddrSetLattice.to_list v in
    (*if uniq then assert (List.length v <= 1);*)
    let open Option.Infix in
    let cells =
      List.filter_map
        (fun (sb, i) ->
          let i = Interval.of_wint i in
          let* n = SBMap.get sb g.node_map in
          Some (get_cell ~uniq i n))
        v
    in
    match cells with
    | [ x ] -> Some x
    | x :: xs when not uniq ->
        List.iter (join x) xs;
        Some x
    | [] -> None
    | _ -> failwith "Expr without a unique cell was given"

  (** Create a copy of the given node with all reachable nodes and cells from
      pointees copied. The previous (given) list of nodes will then be updated
      with all new nodes after the copy and returned. *)
  let copy_node (graph : t) ?(sb = None) (n : node) =
    (* Mappings of old nodes (in the copied-from graph) to new nodes. Since the
       old nodes won't be modified, this is safe. *)
    let old_to_new = Hashtbl.create 100 in
    let stack = Stack.create () in
    (* Create a copy of the given node, with cells initialised except for their pointees *)
    let create_new_node n =
      assert (not @@ Hashtbl.mem old_to_new @@ id n);
      let new_n =
        ref (Node { cells = []; flags = flags n; id = ID.fresh id_gen () })
      in
      let new_cells =
        cells n
        |> List.map (fun c ->
            ref (Cell { offsets = offsets c; node = new_n; pointees = [] }))
      in
      set_cells new_cells new_n;
      Hashtbl.add old_to_new (id n) new_n;
      graph.nodes <- new_n :: graph.nodes;
      Stack.push (n, new_n) stack;
      new_n
    in
    let new_n = create_new_node n in
    (* Recursively update the pointees of cells and create copies for what they point to *)
    while not @@ Stack.is_empty stack do
      let old_n, new_n = Stack.pop stack in
      List.combine (cells old_n) (cells new_n)
      |> List.iter (fun (old_c, new_c) ->
          let pointees =
            pointees old_c
            |> List.map (fun old_c' ->
                let new_pointee_node =
                  Hashtbl.get old_to_new (id @@ node_of old_c')
                  |> Option.get_lazy (fun _ ->
                      create_new_node @@ node_of old_c')
                in
                get_cell (offsets old_c') new_pointee_node)
          in
          set_pointees pointees new_c)
    done;
    match sb with
    | Some sb -> (
        (* TODO maybe this isn't needed (should be thoroughly docuemnted why! scala DSA doesn't do this) *)
        match SBMap.get sb graph.node_map with
        | Some n' ->
            join_nodes_at Z.zero n' new_n;
            n'
        | None ->
            graph.node_map <- SBMap.add sb new_n graph.node_map;
            new_n)
    | _ -> new_n
end

let make_local_graph sva
    (constraints : Sva.SymAddrSetLattice.t Constraint.t Iter.t) : DSGraph.t =
  let cells = Vector.create () in
  let add_cells size sv m =
    let cells =
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
          let c =
            DSGraph.init (Interval.of_wint i |> Interval.pad_with_size size) f
          in
          Vector.push cells c;
          (b, c))
    in
    Iter.fold
      (fun (cs, m) (b, c) ->
        let l = SBMap.get_or b m ~default:[] in
        let m = SBMap.add b (c :: l) m in
        (c :: cs, m))
      ([], m) cells
  in
  (* Construct base graph *)
  (* For each base make a list of cells, then do a merge sort-esque construction of a single node for that base yay nlogn *)
  let m =
    Iter.fold
      (fun acc constr ->
        match constr with
        | Constraint.Mem { addr; value; size } ->
            let ptrs, acc = add_cells size addr acc in
            let vals, acc = add_cells size value acc in
            List.iter (DSGraph.set_pointees vals) ptrs;
            acc
        | _ -> acc)
      SBMap.empty constraints
  in
  let nodes =
    SBMap.fold
      (fun b cs m -> SBMap.add b (DSGraph.merge_init cs) m)
      m SBMap.empty
  in

  (* Unify all pointees (i hope a worklist can be avoided) *)
  Vector.iter DSGraph.unify_pointees cells;

  let node_map =
    SBMap.filter
      (fun b node ->
        match !node with
        | DSGraph.NodePath _ -> false
        | _ -> not @@ List.is_empty @@ DSGraph.cells node)
      nodes
  in

  let (g : DSGraph.t) =
    { nodes = SBMap.values node_map |> Iter.to_list; node_map; sva }
  in

  (* Merge return values and paramater values *)
  Iter.iter
    (function
      | Constraint.Join sbs ->
          let _ = DSGraph.cell_of sbs g in
          ()
      | _ -> ())
    constraints;

  g

let callees p =
  Procedure.blocks_to_list p |> List.to_iter |> Iter.map snd
  |> Iter.flat_map Block.stmts_iter
  |> Iter.filter_map (function
    | Stmt.Instr_Call { procid } -> Some procid
    | _ -> None)
  |> IDSet.of_iter |> IDSet.to_iter

let call_sites p =
  Procedure.blocks_to_list p |> List.to_iter |> Iter.map snd
  |> Iter.flat_map Block.stmts_iter
  |> Iter.filter_map (function
    | Stmt.Instr_Call { lhs; args; procid } -> Some (lhs, args, procid)
    | _ -> None)

let resolve_callee caller_sva caller_graph callee_sva callee_graph actual formal
    =
  ignore
    (let open Option.Infix in
     let open DSGraph in
     let* caller_cell = cell_of actual caller_graph in
     print_endline @@ "Thingy: " ^ Sva.SymAddrSetLattice.show formal;
     let* callee_cell = cell_of ~uniq:true formal callee_graph in
     let callee_node = node_of callee_cell in
     let callee_node_copy = copy_node caller_graph callee_node in
     let flags = flags callee_node_copy in
     let flags = NodeFlags.(clear_flag stack flags) in
     set_flags flags callee_node_copy;
     let callee_cell_copy = get_cell (offsets callee_cell) callee_node_copy in
     print_endline "Joining";
     print_endline @@ "Caller node size: " ^ Int.to_string @@ List.length
     @@ DSGraph.cells
     @@ DSGraph.node_of caller_cell;
     print_endline @@ "Callee node size: " ^ Int.to_string @@ List.length
     @@ DSGraph.cells @@ callee_node;
     join caller_cell callee_cell_copy;
     print_endline "Joined";
     unify_pointees caller_cell;
     None)

let bottom_up prog nodess =
  (* Perform an inlined tarjan's algorithm that dynamically grows the call graph when resolving indirect calls (later) *)
  let stack = Stack.create () in
  let entry = Program.entry_proc_exn prog in
  let cur_id = ref 0 in
  let get_id () =
    let id = !cur_id in
    cur_id := succ !cur_id;
    id
  in
  let ids = Hashtbl.create 100 in

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
  and process_scc scc =
    (* TODO:
       1. Merge callees for each out-of-scc call
       2. Merge all graphs in the scc into one
       3. Merge callees within the scc

       1:
          a) get sva results for both procedures
          b) for each formal in/out, copy its callee node, then merge it with the actual in/out *)
    print_endline @@ "scc: " ^ IDSet.to_string ID.show scc;
    IDSet.iter
      (fun pid ->
        let constraints, sva, nodes = IDMap.find pid nodess in
        Iter.iter
          Constraint.(
            function
            | Call { lhs; args; callee_id } ->
                print_endline @@ "Calling: " ^ ID.show callee_id;
                let _, callee_sva, callee_nodes = IDMap.find callee_id nodess in
                List.iter
                  (fun (a, f) ->
                    resolve_callee sva nodes callee_sva callee_nodes a f)
                  args;
                List.iter
                  (fun (a, f) ->
                    resolve_callee sva nodes callee_sva callee_nodes a f)
                  lhs
            | _ -> ())
          constraints)
      scc;
    ()
  in

  visit entry;

  ()

(** Manual dot string construction because I couldn't see a way to do record
    nodes in ocamlgraph *)
let dot_string (graph : DSGraph.t) =
  let cur_nid = ref 0 in
  let cur_cid = ref 0 in
  let take_id ids () =
    let id = !ids in
    ids := succ !ids;
    id
  in

  (* TODO nodes have an ID.t field now so those should be used instead *)
  let nid_map = Hashtbl.create 100 in

  let nodes =
    graph.nodes
    |> List.map DSGraph.(fun n -> (id n, fst @@ find_node n))
    |> IDMap.of_list |> IDMap.to_list |> List.map snd
  in

  let nids =
    nodes
    |> List.map (fun node ->
        let nid = take_id cur_nid () in
        ( nid,
          DSGraph.flags node,
          List.map
            (fun cell ->
              let cid = take_id cur_cid () in
              Hashtbl.add nid_map cid nid;
              (cid, DSGraph.find cell))
            (DSGraph.cells node) ))
  in
  let cells = List.flat_map (fun (_, _, cells) -> cells) nids in
  let pointees = Hashtbl.create 100 in
  List.iter
    (fun (cid, cell) ->
      let ps =
        List.map
          (fun c' ->
            List.find_map
              (fun (id, c'') ->
                Option.return_if (CCEqual.physical (DSGraph.find c') c'') id)
              cells
            |> Option.get_exn_or "pointing to cell that doesn't exist")
          (DSGraph.pointees cell)
      in
      Hashtbl.add pointees cid ps)
    cells;

  "digraph G {\n  rankdir=\"LR\"\n  node[shape=record]\n"
  ^ List.to_string ~sep:"\n"
      (fun (nid, flags, cids) ->
        Printf.sprintf "  \"node%d\"[label=\"node%d %s |{%s}\"];" nid nid
          (NodeFlags.show flags)
          (List.to_string ~sep:"|"
             (fun (id, cell) ->
               Printf.sprintf "<%d>%s" id (Interval.show @@ DSGraph.offsets cell))
             cids))
      nids
  ^ "\n"
  ^ (Hashtbl.to_iter pointees
    |> Iter.flat_map (fun (cid, ps) ->
        let nid = Hashtbl.find nid_map cid in
        List.to_iter ps |> Iter.map (fun id -> (nid, cid, id)))
    |> Iter.to_string ~sep:"\n" (fun (nid, cid, id) ->
        let nid2 = Hashtbl.find nid_map id in
        Printf.sprintf "  \"node%d\":%d -> \"node%d\":%d" nid cid nid2 id))
  ^ "\n}"

let dsa (p : Program.t) =
  let sva_r = Sva.sva p |> IDMap.of_list in
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
    |> List.map (fun (pid, r) ->
        print_endline @@ ID.show pid;
        let proc = Program.proc p pid in
        let constraints =
          Constraint.gen_constraints p proc
          |> Iter.map (Constraint.map (translate pid) translate)
          |> Iter.persistent
        in
        print_endline
        @@ Iter.to_string
             (Constraint.show Sva.SymAddrSetLattice.show)
             constraints;
        (pid, (constraints, r, make_local_graph r constraints)))
    |> IDMap.of_list
  in
  print_endline "local phase done";
  ( Trace_core.with_span ~__FILE__ ~__LINE__ "bottom up phase" @@ fun _ ->
    bottom_up p local_graphs );
  List.iter
    (fun (id, graph) ->
      print_endline @@ ID.show id;
      print_endline @@ dot_string graph)
    (List.map
       (fun (pid, (_, _, (graph : DSGraph.t))) -> (pid, graph))
       (IDMap.to_list local_graphs));
  p

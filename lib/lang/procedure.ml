open Common
open Containers
open Expr

module Vert = struct
  type t = Begin of ID.t | End of ID.t | Entry | Return | Exit
  [@@deriving show { with_path = false }, eq, ord]

  let hash (v : t) =
    let h = Hash.pair Hash.int Hash.int in
    Hash.map
      (function
        | Entry -> (1, 1)
        | Return -> (3, 1)
        | Exit -> (5, 1)
        | Begin i -> (31, ID.hash i)
        | End i -> (37, ID.hash i))
      h v

  let block_id_string = function
    | Begin i -> ID.to_string i
    | End i -> ID.to_string i
    | Entry -> "proc_entry"
    | Return -> "return"
    | Exit -> "exit"
end

module Edge = struct
  type block = (Var.t, BasilExpr.t) Block.t [@@deriving eq, ord]
  type t = Block of block | Jump [@@deriving eq, ord]

  let show = function Block b -> Block.to_string b | Jump -> "goto"
  let to_string = function Block b -> Block.to_string b | Jump -> "goto"
  let default = Jump
end

module Loc = Int

module G = struct
  include Graph.Persistent.Digraph.ConcreteBidirectionalLabeled (Vert) (Edge)
end

module RevG = struct
  open G

  type t = G.t

  module E = struct
    include G.E

    let src = G.E.dst
    let dst = G.E.src
  end

  module V = G.V

  let iter_succ = G.iter_pred
  let iter_vertex = G.iter_vertex
  let fold_pred_e = G.fold_succ_e
end

module WTO = Graph.WeakTopological.Make (G)
module RevWTO = Graph.WeakTopological.Make (RevG)

type ('v, 'e) proc_spec = {
  requires : BasilExpr.t list;
  ensures : BasilExpr.t list;
  captures_globs : 'v list;
  modifies_globs : 'v list;
}

module PG : sig
  type ('v, 'e) t
  (** type of procedures *)

  val compare : ('a, 'b) t -> ('c, 'd) t -> int
  (** compare procedure names only *)

  val id : ('a, 'b) t -> ID.t
  (** Get procedure ID *)

  val map_graph : (G.t -> G.t) -> ('a, 'b) t -> ('a, 'b) t
  (** modify graph *)

  val set_graph : G.t -> ('a, 'b) t -> ('a, 'b) t
  (** set graph *)

  val graph : ('a, 'b) t -> G.t option
  (** return graph of procedure *)

  val make_stub : ('a, 'b) t -> ('a, 'b) t
  (** delete implementation (CF Graph) of procedure to make it an external/stub
      repr *)

  val add_empty_impl : ('a, 'b) t -> ('a, 'b) t
  (** create default implementation implementation (CF Graph) for procedure *)

  val create :
    ID.t ->
    ?is_stub:bool ->
    ?formal_in_params:'a StringMap.t ->
    ?formal_out_params:'a StringMap.t ->
    ?captures_globs:'a list ->
    ?modifies_globs:'a list ->
    ?requires:BasilExpr.t list ->
    ?ensures:BasilExpr.t list ->
    unit ->
    ('a, 'b) t

  val set_specification : ('a, 'b) t -> ('a, 'c) proc_spec -> ('a, 'c) t
  (** set the procedure's specification/contract *)

  val specification : ('a, 'b) t -> ('a, 'b) proc_spec
  (** return the procedure's specification/contract if defined *)

  val block_ids : ('a, 'b) t -> ID.generator
  (** return mutable generator for fresh block IDS *)

  val local_ids : ('a, 'b) t -> ID.generator
  (** return mutable generator for fresh local variable IDS *)

  val local_decls : ('a, 'b) t -> 'a Var.Decls.t
  (** return mutable declaration map for local var IDS *)

  val formal_in_params : ('a, 'b) t -> 'a StringMap.t
  (** return formal in parameters *)

  val formal_out_params : ('a, 'b) t -> 'a StringMap.t
  (** return formal out parameters *)

  val map_formal_in_params :
    ('a StringMap.t -> 'a StringMap.t) -> ('a, 'b) t -> ('a, 'b) t
  (** modify formal in parameters *)

  val map_formal_out_params :
    ('a StringMap.t -> 'a StringMap.t) -> ('a, 'b) t -> ('a, 'b) t
  (** modify formal out parameters *)

  val topo_fwd : ('a, 'b) t -> Vert.t Graph.WeakTopological.t
  (** return SCCs in forwards weak topological order from entry *)

  val topo_rev : ('a, 'b) t -> Vert.t Graph.WeakTopological.t
  (** return SCCs in reverse weak topological order from return *)
end = struct
  type ('v, 'e) t = {
    id : ID.t;
    formal_in_params : 'v StringMap.t;
    formal_out_params : 'v StringMap.t;
    graph : G.t option;
    locals : 'v Var.Decls.t;
    topo_fwd : Vert.t Graph.WeakTopological.t lazy_t;
    topo_rev : Vert.t Graph.WeakTopological.t lazy_t;
    local_ids : ID.generator;
    block_ids : ID.generator;
    specification : ('v, 'e) proc_spec;
  }

  let set_specification p specification = { p with specification }
  let specification p = p.specification
  let id p = p.id
  let graph p = p.graph
  let block_ids p = p.block_ids
  let local_ids p = p.local_ids
  let local_decls p = p.locals
  let formal_in_params p = p.formal_in_params
  let formal_out_params p = p.formal_out_params
  let topo_fwd p = Lazy.force p.topo_fwd
  let topo_rev p = Lazy.force p.topo_rev
  let compare a b = ID.compare (id a) (id b)

  let map_graph f p =
    let np =
      Option.map
        (fun g ->
          let graph = f g in
          {
            p with
            graph = Some graph;
            topo_fwd = lazy (WTO.recursive_scc graph Entry);
            topo_rev = lazy (RevWTO.recursive_scc graph Return);
          })
        p.graph
    in
    Option.get_or ~default:p np

  let set_graph g p = map_graph (fun _ -> g) p

  let map_formal_in_params f p =
    { p with formal_in_params = f p.formal_in_params }

  let map_formal_out_params f p =
    { p with formal_out_params = f p.formal_out_params }

  let set_formal_in_params f p = map_formal_in_params (fun _ -> f) p
  let set_formal_out_params f p = map_formal_in_params (fun _ -> f) p

  let empty_graph =
    let graph = G.empty in
    let graph = G.add_vertex graph Entry in
    let graph = G.add_vertex graph Exit in
    let graph = G.add_vertex graph Return in
    graph

  let create id ?(is_stub = false) ?(formal_in_params = StringMap.empty)
      ?(formal_out_params = StringMap.empty) ?(captures_globs = [])
      ?(modifies_globs = []) ?(requires = []) ?(ensures = []) () =
    let specification = { captures_globs; modifies_globs; requires; ensures } in
    let graph = if is_stub then None else Some empty_graph in
    {
      id;
      formal_in_params;
      formal_out_params;
      graph;
      locals = Var.Decls.empty ();
      local_ids = ID.make_gen ();
      block_ids = ID.make_gen ();
      specification;
      topo_fwd =
        lazy
          (WTO.recursive_scc
             (Option.get_exn_or "no graph to iterate" graph)
             Entry);
      topo_rev =
        lazy
          (RevWTO.recursive_scc
             (Option.get_exn_or "no graph to iterate" graph)
             Return);
    }

  let make_stub p =
    {
      p with
      graph = None;
      topo_fwd = lazy (WTO.recursive_scc G.empty Entry);
      topo_rev = lazy (RevWTO.recursive_scc G.empty Return);
    }

  let add_empty_impl p =
    let graph = empty_graph in
    {
      p with
      graph = Some graph;
      topo_fwd = lazy (WTO.recursive_scc graph Entry);
      topo_rev = lazy (RevWTO.recursive_scc graph Return);
    }
end

include PG

let add_goto p ~(from : ID.t) ~(targets : ID.t list) =
  let open Vert in
  p
  |> map_graph (fun g ->
      let fr = End from in
      List.fold_left (fun g t -> G.add_edge g fr (Begin t)) g targets)

let remove_block p id =
  map_graph
    (fun g ->
      let g = G.remove_vertex g (End id) in
      G.remove_vertex g (Begin id))
    p

let add_block_graph graph id ?(phis = [])
    ~(stmts : ('var, 'var, 'expr) Stmt.t list) ?(successors = []) () =
  let stmts = Vector.of_list stmts in
  let b = Edge.(Block { phis; stmts }) in
  let open Vert in
  let existing = G.find_all_edges graph (Begin id) (End id) in
  let graph = List.fold_left G.remove_edge_e graph existing in
  let graph = G.add_edge_e graph (Begin id, b, End id) in
  let graph =
    List.fold_left
      (fun graph i -> G.add_edge graph (End id) (Begin i))
      graph successors
  in
  graph

let add_block p id ?(phis = []) ~(stmts : ('var, 'var, 'expr) Stmt.t list)
    ?(successors = []) () =
  assert (Option.is_some (graph p));
  map_graph
    (fun graph -> add_block_graph graph id ~phis ~stmts ~successors ())
    p

let fresh_block_graph p graph ?name ?(phis = [])
    ~(stmts : ('var, 'var, 'expr) Stmt.t list) ?(successors = []) () =
  let open Block in
  let name = Option.get_or ~default:"block" name in
  let id = (block_ids p).fresh ~name () in
  (add_block_graph graph id ~phis ~stmts ~successors (), id)

let fresh_block p ?name ?(phis = []) ~(stmts : ('var, 'var, 'expr) Stmt.t list)
    ?(successors = []) () =
  let open Block in
  let name = Option.get_or ~default:"block" name in
  let id = (block_ids p).fresh ~name () in
  (add_block p id ~phis ~stmts ~successors (), id)

let get_entry_block p id =
  let open Edge in
  let open G in
  try
    graph p
    |> Option.flat_map (fun g ->
        let id = G.find_edge g Entry (Begin id) in
        Some id)
  with Not_found -> None

let get_block p id =
  let open Edge in
  let open G in
  try
    graph p
    |> Option.flat_map (fun g ->
        let _, e, _ = G.find_edge g (Begin id) (End id) in
        match e with Block b -> Some b | Jump -> None)
  with Not_found -> None

let decl_block_exn p name ?(phis = [])
    ~(stmts : ('var, 'var, 'expr) Stmt.t list) ?(successors = []) () =
  let open Block in
  let id = (block_ids p).decl_or_get name in
  assert (Option.is_none (get_block p id));
  let p = add_block p id ~phis ~stmts ~successors () in
  (p, id)

let update_block p id (block : (Var.t, BasilExpr.t) Block.t) =
  let open Edge in
  let open G in
  p
  |> map_graph (fun g ->
      let g = G.remove_edge g (Begin id) (End id) in
      let g = G.add_edge_e g (Begin id, Block block, End id) in
      g)

let replace_edge p id (block : (Var.t, BasilExpr.t) Block.t) =
  update_block p id block

let decl_local p v =
  let _ = (local_ids p).decl_or_get (Var.name v) in
  Var.Decls.add (local_decls p) v;
  v

let fresh_var p ?(pure = true) ?name typ : Var.t =
  let name = Option.map (String.drop_while (Char.equal '$')) name in
  let name = Option.get_or ~default:"v" name in
  let n = ID.name @@ (local_ids p).fresh ~name () in
  let v = Var.create n typ ~pure in
  Var.Decls.add (local_decls p) v;
  v

let blocks_to_list p =
  let collect_edge edge acc =
    let id = G.V.label (G.E.src edge) in
    let edge = G.E.label edge in
    match edge with Edge.(Block b) -> (id, b) :: acc | _ -> acc
  in
  graph p
  |> Option.map (fun g -> G.fold_edges_e collect_edge g [])
  |> Option.get_or ~default:[]

(** Fold over blocks in forwards weak topological order (boundocle). The order
    is *not* stable *)
let fold_blocks_topo_fwd (f : 'a -> ID.t -> Edge.block -> 'a) init p =
  let open Graph.WeakTopological in
  let f acc e =
    match e with
    | Vert.Begin id ->
        Option.map (f acc id) (get_block p id) |> Option.get_or ~default:acc
    | _ -> acc
  in
  let rec ff acc e =
    match e with
    | Vertex a -> f acc a
    | Component (a, e) ->
        let acc = f acc a in
        Graph.WeakTopological.fold_left ff acc e
  in
  if graph p |> Option.is_some then
    let topo = topo_fwd p in
    Graph.WeakTopological.fold_left ff init topo
  else init

(** Fold over blocks in reverse weak topological order (boundocle). The order is
    *not* stable *)
let fold_blocks_topo_rev (f : 'a -> ID.t -> Edge.block -> 'a) init p =
  let open Graph.WeakTopological in
  let f acc e =
    match e with
    | Vert.Begin id ->
        Option.map (f acc id) (get_block p id) |> Option.get_or ~default:acc
    | _ -> acc
  in
  let rec ff acc e =
    match e with
    | Vertex a -> f acc a
    | Component (a, e) ->
        let acc = Graph.WeakTopological.fold_left ff acc e in
        f acc a
  in
  if graph p |> Option.is_some then
    let topo = topo_rev p in
    Graph.WeakTopological.fold_left ff init topo
  else init

let map_blocks_topo_fwd f p =
  fold_blocks_topo_fwd
    (fun p id b ->
      let updated = f id b in
      if not @@ Equal.physical updated b then update_block p id updated else p)
    p p

let blocks_succ p i =
  Option.to_iter (graph p)
  |> Iter.flat_map (fun graph ->
      Iter.from_iter (fun f -> G.iter_succ f graph (End i))
      |> Iter.flat_map (function
        | Vert.Begin i ->
            Iter.singleton
              (i, get_block p i |> Option.get_exn_or "bad cfg sturcture")
        | Return -> Iter.empty
        | Exit -> Iter.empty
        | v -> failwith @@ "bad graph structure " ^ Vert.show v))

let blocks_pred p i =
  Option.to_iter (graph p)
  |> Iter.flat_map (fun graph ->
      Iter.from_iter (fun f -> G.iter_pred f graph (Begin i))
      |> Iter.flat_map (function
        | Vert.End i ->
            Iter.singleton
              (i, get_block p i |> Option.get_exn_or "bad cfg sturcture")
        | Entry -> Iter.empty
        | v -> failwith @@ "bad graph structure  " ^ Vert.show v))

let iter_blocks_topo_fwd p =
  Iter.from_iter (fun f -> fold_blocks_topo_fwd (fun acc a b -> f (a, b)) () p)

let iter_blocks_topo_rev p =
  Iter.from_iter (fun f -> fold_blocks_topo_rev (fun acc a b -> f (a, b)) () p)

let pretty show_lvar show_var show_expr p =
  let open Containers_pp in
  let open Containers_pp.Infix in
  let params m =
    StringMap.to_list m |> List.map (function i, p -> show_var p) |> fun s ->
    bracket "(" (fill (text "," ^ newline_or_spaces 1) s) ")"
  in
  let header =
    text "proc "
    ^ text (ID.to_string (id p))
    ^ nest 2
        (fill
           (newline ^ text " -> ")
           [ params (formal_in_params p); params (formal_out_params p) ])
  in
  let return_stmt = text "return" in
  let pretty_block graph block_id block =
    let succ = G.succ_e graph (Vert.End block_id) in
    let succ =
      match succ with
      | [] -> [ text "unreachable" ]
      | [ (b, re, Return) ] -> (
          match re with
          | Block { stmts } ->
              let stmts =
                Vector.map
                  (fun s ->
                    Stmt.pretty show_lvar show_var show_expr s ^ text ";")
                  stmts
                |> Vector.to_list
              in
              stmts @ [ return_stmt ]
          | Jump -> [ return_stmt ])
      | succ ->
          let succ =
            List.map
              (fun (b, label, e) ->
                match G.V.label e with
                | Begin i -> text @@ ID.to_string i
                | _ -> failwith "bad graph structure: goto targets non-block")
              succ
          in
          [ text "goto " ^ (fun s -> bracket "(" (fill (text ",") s) ")") succ ]
    in
    Block.pretty show_lvar show_var show_expr ~block_id ~terminator:succ block
  in
  let module StableTopoSort = Graph.Topological.Make_stable (G) in
  let blocks =
    Option.to_iter (graph p)
    |> Iter.flat_map (fun g ->
        Iter.from_iter (fun f -> StableTopoSort.iter f g)
        |> Iter.filter_map (function Vert.Begin id -> Some id | _ -> None)
        |> Iter.map (fun id ->
            (id, get_block p id |> Option.get_exn_or "bad graph"))
        |> Iter.map (fun (id, block) -> pretty_block g id block))
    |> Iter.to_list
  in
  let blocks =
    surround (text "[")
      (nest 2 @@ newline ^ append_l ~sep:(text ";" ^ newline) blocks)
      (newline ^ text "]")
  in
  header ^ nl ^ blocks

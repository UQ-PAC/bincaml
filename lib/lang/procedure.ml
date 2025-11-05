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

  module V = G.V

  let iter_succ = G.iter_pred
  let iter_vertex = G.iter_vertex
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

  val id : ('a, 'b) t -> ID.t
  (** Get procedure ID *)

  val map_graph : (G.t -> G.t) -> ('a, 'b) t -> ('a, 'b) t
  (** modify graph *)

  val set_graph : G.t -> ('a, 'b) t -> ('a, 'b) t
  (** set graph *)

  val graph : ('a, 'b) t -> G.t
  (** return graph of procedure *)

  val create :
    ID.t ->
    ?formal_in_params:'a StringMap.t ->
    ?formal_out_params:'a StringMap.t ->
    ?captures_globs:'a list ->
    ?modifies_globs:'a list ->
    ?requires:BasilExpr.t list ->
    ?ensures:BasilExpr.t list ->
    unit ->
    ('a, 'b) t

  val block_ids : ('a, 'b) t -> ID.generator
  (** return mutable generator for fresh block IDS *)

  val local_ids : ('a, 'b) t -> ID.generator
  (** return mutable generator for fresh local variable IDS *)

  val locals : ('a, 'b) t -> 'a Var.Decls.t
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
    graph : G.t;
    locals : 'v Var.Decls.t;
    topo_fwd : Vert.t Graph.WeakTopological.t lazy_t;
    topo_rev : Vert.t Graph.WeakTopological.t lazy_t;
    local_ids : ID.generator;
    block_ids : ID.generator;
    specification : ('v, 'e) proc_spec option;
  }

  let id p = p.id
  let graph p = p.graph
  let block_ids p = p.block_ids
  let local_ids p = p.local_ids
  let locals p = p.locals
  let formal_in_params p = p.formal_in_params
  let formal_out_params p = p.formal_out_params
  let topo_fwd p = Lazy.force p.topo_fwd
  let topo_rev p = Lazy.force p.topo_rev

  let map_graph f p =
    let graph = f p.graph in
    {
      p with
      graph;
      topo_fwd = lazy (WTO.recursive_scc graph Entry);
      topo_rev = lazy (RevWTO.recursive_scc graph Return);
    }

  let set_graph g p = map_graph (fun _ -> g) p

  let map_formal_in_params f p =
    { p with formal_in_params = f p.formal_in_params }

  let map_formal_out_params f p =
    { p with formal_out_params = f p.formal_out_params }

  let set_formal_in_params f p = map_formal_in_params (fun _ -> f) p
  let set_formal_out_params f p = map_formal_in_params (fun _ -> f) p

  let create id ?(formal_in_params = StringMap.empty)
      ?(formal_out_params = StringMap.empty) ?(captures_globs = [])
      ?(modifies_globs = []) ?(requires = []) ?(ensures = []) () =
    let graph = G.empty in
    let specification =
      Some { captures_globs; modifies_globs; requires; ensures }
    in
    let graph = G.add_vertex graph Entry in
    let graph = G.add_vertex graph Exit in
    let graph = G.add_vertex graph Return in
    {
      id;
      formal_in_params;
      formal_out_params;
      graph;
      locals = Var.Decls.empty ();
      local_ids = ID.make_gen ();
      block_ids = ID.make_gen ();
      specification;
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

let add_block p id ?(phis = []) ~(stmts : ('var, 'var, 'expr) Stmt.t list)
    ?(successors = []) () =
  let stmts = Vector.of_list stmts in
  let b = Edge.(Block { phis; stmts }) in
  let open Vert in
  let graph = graph p in
  let existing = G.find_all_edges graph (Begin id) (End id) in
  let graph = List.fold_left G.remove_edge_e graph existing in
  let graph = G.add_edge_e graph (Begin id, b, End id) in
  let graph =
    List.fold_left
      (fun graph i -> G.add_edge graph (End id) (Begin i))
      graph successors
  in
  p |> map_graph (fun _ -> graph)

let decl_block_exn p name ?(phis = [])
    ~(stmts : ('var, 'var, 'expr) Stmt.t list) ?(successors = []) () =
  let open Block in
  let id = (block_ids p).decl_exn name in
  let p = add_block p id ~phis ~stmts ~successors () in
  (p, id)

let fresh_block p ?name ?(phis = []) ~(stmts : ('var, 'var, 'expr) Stmt.t list)
    ?(successors = []) () =
  let open Block in
  let name = Option.get_or ~default:"block" name in
  let id = (block_ids p).fresh ~name () in
  (add_block p id ~phis ~stmts ~successors (), id)

let add_return p ~(from : ID.t) ~(args : BasilExpr.t StringMap.t) =
  let open Vert in
  let fr = End from in
  let b =
    Edge.(
      Block
        { phis = []; stmts = Vector.of_list [ Stmt.(Instr_Return { args }) ] })
  in
  p |> map_graph (fun g -> G.add_edge_e g (fr, b, Return))

let get_entry_block p id =
  let open Edge in
  let open G in
  try
    let id = G.find_edge (graph p) Entry (Begin id) in
    Some id
  with Not_found -> None

let get_block p id =
  let open Edge in
  let open G in
  try
    let _, e, _ = G.find_edge (graph p) (Begin id) (End id) in
    match e with Block b -> Some b | Jump -> None
  with Not_found -> None

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
  Var.Decls.add (locals p) v;
  v

let fresh_var p ?(pure = true) typ =
  let n, _ = (local_ids p).fresh ~name:"v" () in
  let v = Var.create n typ ~pure in
  Var.Decls.add (locals p) v;
  v

let blocks_to_list p =
  let collect_edge edge acc =
    let id = G.V.label (G.E.src edge) in
    let edge = G.E.label edge in
    match edge with Edge.(Block b) -> (id, b) :: acc | _ -> acc
  in
  G.fold_edges_e collect_edge (graph p) []

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
    | Component (a, e) -> f (Graph.WeakTopological.fold_left ff acc e) a
  in
  let topo = topo_fwd p in
  Graph.WeakTopological.fold_left ff init topo

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
    | Component (a, e) -> f (Graph.WeakTopological.fold_left ff acc e) a
  in
  let topo = topo_rev p in
  Graph.WeakTopological.fold_left ff init topo

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
  let collect_edge b ende acc =
    let vert = G.V.label b in
    let edge = G.E.label (G.find_edge (graph p) b ende) in
    match (vert, edge) with
    | Vert.Begin block_id, Edge.(Block b) ->
        let succ = G.succ (graph p) ende in
        let succ =
          match succ with
          | [ Return ] -> (
              let _, re, _ = G.find_edge (graph p) ende Return in
              match re with
              | Block { stmts } ->
                  Vector.map
                    (fun s ->
                      Stmt.pretty show_lvar show_var show_expr s ^ text ";")
                    stmts
                  |> Vector.to_list
              | _ -> failwith "bad return")
          | [] -> [ text "unreachable;" ]
          | succ ->
              let succ =
                List.map
                  (fun f ->
                    match G.V.label f with
                    | Begin i -> text @@ ID.to_string i
                    | _ -> failwith "unsupp")
                  succ
              in
              [
                text "goto "
                ^ (fun s -> bracket "(" (fill (text ",") s) ")") succ
                ^ text ";";
              ]
        in
        let b =
          Block.pretty show_lvar show_var show_expr ~block_id ~terminator:succ b
        in
        b :: acc
    | _ -> acc
  in
  let blocks = G.fold_edges collect_edge (graph p) [] in
  let blocks =
    surround (text "[")
      (nest 2 @@ newline ^ append_l ~sep:(text ";" ^ newline) (List.rev blocks))
      (newline ^ text "]")
  in
  header ^ nl ^ blocks

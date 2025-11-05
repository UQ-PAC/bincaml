open Common
open Containers
open Expr

type ident = Proc of int [@@unboxed]

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

type ('v, 'e) proc_spec = {
  requires : BasilExpr.t list;
  ensures : BasilExpr.t list;
  captures_globs : 'v list;
  modifies_globs : 'v list;
}

type ('v, 'e) t = {
  id : ID.t;
  formal_in_params : 'v StringMap.t;
  formal_out_params : 'v StringMap.t;
  graph : G.t;
  locals : 'v Var.Decls.t;
  local_ids : ID.generator;
  block_ids : ID.generator;
  specification : ('v, 'e) proc_spec option;
}

let add_goto p ~(from : ID.t) ~(targets : ID.t list) =
  let open Vert in
  let g = p.graph in
  let fr = End from in
  let g = List.fold_left (fun g t -> G.add_edge g fr (Begin t)) g targets in
  { p with graph = g }

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
  }

let add_block p id ?(phis = []) ~(stmts : ('var, 'var, 'expr) Stmt.t list)
    ?(successors = []) () =
  let stmts = Vector.of_list stmts in
  let b = Edge.(Block { phis; stmts }) in
  let open Vert in
  let existing = G.find_all_edges p.graph (Begin id) (End id) in
  let graph = List.fold_left G.remove_edge_e p.graph existing in
  let graph = G.add_edge_e graph (Begin id, b, End id) in
  let graph =
    List.fold_left
      (fun graph i -> G.add_edge graph (End id) (Begin i))
      graph successors
  in
  { p with graph }

let decl_block_exn p name ?(phis = [])
    ~(stmts : ('var, 'var, 'expr) Stmt.t list) ?(successors = []) () =
  let open Block in
  let id = p.block_ids.decl_exn name in
  let p = add_block p id ~phis ~stmts ~successors () in
  (p, id)

let fresh_block p ?name ?(phis = []) ~(stmts : ('var, 'var, 'expr) Stmt.t list)
    ?(successors = []) () =
  let open Block in
  let name = Option.get_or ~default:"block" name in
  let id = p.block_ids.fresh ~name () in
  (add_block p id ~phis ~stmts ~successors (), id)

let add_return p ~(from : ID.t) ~(args : BasilExpr.t StringMap.t) =
  let open Vert in
  let fr = End from in
  let b =
    Edge.(
      Block
        { phis = []; stmts = Vector.of_list [ Stmt.(Instr_Return { args }) ] })
  in
  { p with graph = G.add_edge_e p.graph (fr, b, Return) }

let get_entry_block p id =
  let open Edge in
  let open G in
  try
    let id = G.find_edge p.graph Entry (Begin id) in
    Some id
  with Not_found -> None

let get_block p id =
  let open Edge in
  let open G in
  try
    let _, e, _ = G.find_edge p.graph (Begin id) (End id) in
    match e with Block b -> Some b | Jump -> None
  with Not_found -> None

let update_block p id (block : (Var.t, BasilExpr.t) Block.t) =
  let open Edge in
  let open G in
  let g = p.graph in
  let g = G.remove_edge g (Begin id) (End id) in
  let g = G.add_edge_e g (Begin id, Block block, End id) in
  { p with graph = g }

let replace_edge p id (block : (Var.t, BasilExpr.t) Block.t) =
  update_block p id block

let decl_local p v =
  let _ = p.local_ids.decl_or_get (Var.name v) in
  Var.Decls.add p.locals v;
  v

let fresh_var p ?(pure = true) typ =
  let n, _ = p.local_ids.fresh ~name:"v" () in
  let v = Var.create n typ ~pure in
  Var.Decls.add p.locals v;
  v

let blocks_to_list p =
  let collect_edge edge acc =
    let id = G.V.label (G.E.src edge) in
    let edge = G.E.label edge in
    match edge with Edge.(Block b) -> (id, b) :: acc | _ -> acc
  in
  G.fold_edges_e collect_edge p.graph []

let pretty show_lvar show_var show_expr p =
  let open Containers_pp in
  let open Containers_pp.Infix in
  let params m =
    StringMap.to_list m |> List.map (function i, p -> show_var p) |> fun s ->
    bracket "(" (fill (text "," ^ newline_or_spaces 1) s) ")"
  in
  let header =
    text "proc "
    ^ text (ID.to_string p.id)
    ^ nest 2
        (fill
           (newline ^ text " -> ")
           [ params p.formal_in_params; params p.formal_out_params ])
  in
  let collect_edge b ende acc =
    let vert = G.V.label b in
    let edge = G.E.label (G.find_edge p.graph b ende) in
    match (vert, edge) with
    | Vert.Begin block_id, Edge.(Block b) ->
        let succ = G.succ p.graph ende in
        let succ =
          match succ with
          | [ Return ] -> (
              let _, re, _ = G.find_edge p.graph ende Return in
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
  let blocks = G.fold_edges collect_edge p.graph [] in
  let blocks =
    surround (text "[")
      (nest 2 @@ newline ^ append_l ~sep:(text ";" ^ newline) (List.rev blocks))
      (newline ^ text "]")
  in
  header ^ nl ^ blocks

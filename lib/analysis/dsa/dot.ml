open struct
  module DSGraph = Dsgraph
  module NodeFlags = Node_flags
end

open Bincaml_util.Common

module Dsgraph_ocamlgraph = struct
  type t = DSGraph.t

  module V = struct
    type t =

    end

  end


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
    |> List.map DSGraph.(fun n -> (node_id n, snd @@ find_node n))
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
               let interval = DSGraph.offsets cell in
               let wd =
                 match interval with
                 | Interval (lo, hi) -> Z.(to_string (hi - lo + ~$1))
                 | _ -> "?"
               in
               Printf.sprintf "<%d>%s:%sB" id (Interval.show interval) wd)
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

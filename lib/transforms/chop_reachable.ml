open Lang
open Common
module G = Program.CallGraph.G

module Reachability =
  Graph.Fixpoint.Make
    (G)
    (struct
      type vertex = G.E.vertex
      type edge = G.E.t
      type g = G.t
      type data = bool

      let direction = Graph.Fixpoint.Forward
      let equal = Bool.equal
      let join = ( || )
      let analyze _ = fun x -> x
    end)

let transform p =
  let g = Program.CallGraph.make_call_graph p in
  let reachable =
    Reachability.analyze
      (function Program.CallGraph.Vert.Entry -> true | _ -> false)
      g
  in
  let unreachable =
    Iter.from_iter (fun f -> G.iter_vertex f g)
    |> Iter.filter_map (function
      | Program.CallGraph.Vert.ProcBegin id as v when not (reachable v) ->
          Some id
      | _ -> None)
    |> IDSet.of_iter
  in
  Program.filter_map_decls
    (fun id e -> if IDSet.mem id unreachable then None else Some e)
    p

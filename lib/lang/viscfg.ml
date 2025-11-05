open Containers

module type Labelling = sig
  val labelling : Procedure.Vert.t -> string option
end

module type ProcPrinter = sig
  val fprint_graph : Format.formatter -> Procedure.G.t -> unit
  val output_graph : out_channel -> Procedure.G.t -> unit
end

module Make (L : Labelling) = Graph.Graphviz.Dot (struct
  open Procedure
  include G
  include Graph.Pack

  let addind ind = if ind <= 4 then 4 else 2

  let safe_label (s : string) =
    let wrap = 100 in
    let slack = 30 in
    let wrap_p = [ ';'; ')'; '('; ' ' ] in
    "\\l"
    ^ (String.to_list s
      |> List.fold_left_map
           (fun (l, ind) c ->
             match c with
             | '\n' -> ((0, 0), "\\l")
             | '"' -> ((l, ind), "\\\"")
             | c
               when l >= wrap - slack
                    && List.find_opt (function y -> Char.equal y c) wrap_p
                       |> Option.is_some ->
                 let ind = addind ind in
                 ((0, ind), String.of_char c ^ "\\l" ^ String.make ind ' ')
             | c when l >= wrap ->
                 let ind = addind ind in
                 ((0, ind), "\\l" ^ String.make ind ' ' ^ String.of_char c)
             | c -> ((l + 1, ind), String.make 1 c))
           (0, 0)
      |> snd |> String.concat "")
    ^ "\\l"

  let edge_attributes (e : E.t) =
    [ `Label (safe_label @@ Edge.to_string (E.label e)); `Fontname "Mono" ]

  let default_edge_attributes _ = []
  let get_subgraph _ = None

  let vertex_name (v : Vert.t) =
    let open Vert in
    let n =
      match v with
      | Begin v -> Printf.sprintf "beg%d" (ID.index v)
      | End v -> Printf.sprintf "end%d" (ID.index v)
      | Entry -> "entry"
      | Exit -> "exit"
      | Return -> "return"
    in
    n

  let vertex_attributes v =
    let n = vertex_name v in
    let l =
      match L.labelling v with
      | Some x ->
          let l = n ^ "\\l :     " ^ x ^ "\\l" in
          [ `Label (safe_label l) ]
      | _ -> [ `Label n ]
    in
    [ `Shape `Box; `Fontname "Mono" ] @ l

  let default_vertex_attributes _ = []
  let graph_attributes _ = []
end)

let dot_labels label_fun =
  (module Make (struct
    let labelling = label_fun
  end) : ProcPrinter)

module Dot = Make (struct
  let labelling v = None
end)

module PrintCallgraph = Graph.Graphviz.Dot (struct
  include Program.CallGraph.G
  open Program.CallGraph.Vert
  open Program.CallGraph.Edge

  let default_vertex_attributes _ = []
  let graph_attributes _ = []

  let edge_attributes (e : E.t) =
    match e with
    | _, Proc id, _ -> [ `Label ("proc " ^ ID.to_string id); `Fontname "Mono" ]
    | _ -> [ `Fontname "Mono" ]

  let default_edge_attributes _ = []
  let get_subgraph _ = None

  let vertex_attributes v =
    let n =
      match v with
      | ProcBegin i -> "begin" ^ ID.to_string i
      | ProcReturn i -> "return" ^ ID.to_string i
      | ProcExit i -> "exit" ^ ID.to_string i
      | Entry -> "entry"
      | Return -> "return"
    in
    [ `Shape `Box; `Fontname "Mono"; `Label n ]

  let vertex_name (v : Program.CallGraph.Vert.t) =
    match v with
    | ProcBegin i -> "begin" ^ (ID.index i |> Int.to_string)
    | ProcReturn i -> "return" ^ (ID.index i |> Int.to_string)
    | ProcExit i -> "exit" ^ (ID.index i |> Int.to_string)
    | Entry -> "entry"
    | Return -> "return"
end)

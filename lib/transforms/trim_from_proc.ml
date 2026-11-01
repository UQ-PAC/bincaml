open Lang
open Common

open struct
  let get_id procid prog =
    Program.get_decl_by_name procid prog |> function
    | Some (Program.Procedure { definition }) -> Procedure.id definition
    | _ -> failwith ("not a proc id:" ^ procid)
end

let set_entry procid prog = Program.set_entry_proc (get_id procid prog) prog

module TrimMain = struct
  module BFS = Graph.Path.Bfs01 (Program.CallGraph.G)

  let filter_connected ?(procid = []) prog =
    let g = Program.CallGraph.make_call_graph ~returns:false prog in
    let seen = ref IDSet.empty in
    let visit v i =
      match v with
      | Program.CallGraph.Vert.ProcBegin i -> seen := IDSet.add i !seen
      | _ -> ()
    in

    if List.is_empty procid then
      BFS.iter visit g ~zero:(fun _ -> false) Program.CallGraph.Vert.Entry;
    List.iter
      (fun procid ->
        let start = Program.CallGraph.Vert.ProcBegin (get_id procid prog) in
        BFS.iter visit g ~zero:(fun _ -> false) start)
      procid;
    let p =
      Program.filter_decls
        (fun i -> function
          | Procedure _ when not @@ IDSet.mem i !seen -> false | _ -> true)
        prog
    in
    p
end

open Value
open Common
open Types
open Expr
open Containers

type e = BasilExpr.t
type proc = (Var.t, BasilExpr.t) Procedure.t
type bloc = (Var.t, BasilExpr.t) Block.t
type stmt = (Var.t, Var.t, e) Stmt.t

type t = {
  modulename : string;
  globals : Var.t Var.Decls.t;
  entry_proc : ID.t option;
  procs : proc ID.Map.t;
  proc_names : ID.generator;
}

let proc_pretty p =
  let show_lvar v = Containers_pp.text @@ Var.to_string_il_lvar v in
  let show_var v = Containers_pp.text @@ Var.to_string_il_rvar v in
  let show_expr e = BasilExpr.pretty e in
  Procedure.pretty show_lvar show_var show_expr p

let output_proc_pretty chan p =
  output_string chan @@ Containers_pp.Pretty.to_string ~width:80 (proc_pretty p)

let prog_pretty (p : t) =
  let open Containers_pp in
  let open Containers_pp.Infix in
  let globs =
    Var.Decls.to_list p.globals
    |> List.map (fun (n, v) -> text @@ Var.to_decl_string_il v)
  in
  let n =
    p.entry_proc
    |> Option.map (fun i -> text "prog entry " ^ text @@ ID.to_string i)
    |> Option.to_list
  in
  let pretty =
    append_l ~sep:(text ";\n")
    @@ globs @ n
    @ List.map (fun (_, p) -> proc_pretty p) (ID.Map.to_list p.procs)
  in
  pretty

let pretty_to_chan chan (p : t) =
  let p = prog_pretty p in
  output_string chan @@ Containers_pp.Pretty.to_string ~width:80 p;
  output_string chan ";"

let decl_global p = Var.Decls.add p.globals

let empty ?name () =
  let modulename = Option.get_or ~default:"<module>" name in
  {
    modulename;
    entry_proc = None;
    globals = Var.Decls.empty ();
    procs = ID.Map.empty;
    proc_names = ID.make_gen ();
  }

module CallGraph = struct
  module Vert = struct
    type t =
      | ProcBegin of ID.t
      | ProcReturn of ID.t
      | ProcExit of ID.t
      | Entry
      | Return (*| Exit*)
    [@@deriving show { with_path = false }, eq, ord]

    let hash (v : t) =
      let h = Hash.pair Hash.int Hash.int in
      Hash.map
        (function
          | ProcBegin i -> (31, ID.hash i)
          | ProcReturn i -> (37, ID.hash i)
          | ProcExit i -> (41, ID.hash i)
          | o -> (Hashtbl.hash o, 1))
        h v
  end

  module Edge = struct
    type t = Proc of ID.t | Nop
    [@@deriving show { with_path = false }, eq, ord]

    let default = Nop
  end

  module G = Graph.Imperative.Digraph.ConcreteBidirectionalLabeled (Vert) (Edge)

  let make_call_graph t =
    let called_by (p : proc) =
      Procedure.blocks_to_list p |> List.to_iter |> Iter.map snd
      |> Iter.flat_map Block.stmts_iter
      |> Iter.filter_map (function
        | Stmt.Instr_Call { procid } -> Some procid
        | _ -> None)
      |> ID.Set.of_iter
    in
    let calls =
      ID.Map.to_iter t.procs
      |> Iter.map (function pid, proc -> (pid, called_by proc))
    in
    let graph = G.create ~size:(ID.Map.cardinal t.procs) () in
    let open Edge in
    let open Vert in
    let proc_edges =
      Iter.map
        (function id -> (ProcBegin id, Proc id, ProcReturn id))
        (ID.Map.keys t.procs)
    in
    Iter.iter (G.add_edge_e graph) proc_edges;
    t.entry_proc
    |> Option.iter (fun entry ->
        List.iter (G.add_edge_e graph)
          [ (Entry, Nop, ProcBegin entry); (ProcReturn entry, Nop, Return) ]);
    let call_dep caller callee =
      Iter.of_list
        [
          (ProcBegin caller, Nop, ProcBegin callee);
          (ProcReturn callee, Nop, ProcBegin caller);
        ]
    in
    let call_dep_edges =
      Iter.flat_map
        (function
          | proc, called ->
              Iter.append
                (Iter.singleton (ProcBegin proc, Proc proc, ProcReturn proc))
                (Iter.flat_map
                   (function c -> call_dep proc c)
                   (ID.Set.to_iter called)))
        calls
    in
    Iter.iter (G.add_edge_e graph) call_dep_edges;
    graph
end

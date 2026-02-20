open Common
open Types
open Expr
open Containers

type e = BasilExpr.t
type proc = (Var.t, BasilExpr.t) Procedure.t
type bloc = (Var.t, BasilExpr.t) Block.t
type stmt = (Var.t, Var.t, e) Stmt.t

module Proc = struct
  type t = proc

  let compare a b = Procedure.compare a b
end

let equal_stmt = Stmt.equal Var.equal Var.equal BasilExpr.equal
let compare_stmt = Stmt.compare Var.compare Var.compare BasilExpr.compare

let show_stmt =
  let show_lvar v = Containers_pp.text @@ Var.to_string_il_lvar v in
  let show_var v = Containers_pp.text @@ Var.to_string_il_rvar v in
  let show_expr e = BasilExpr.pretty e in
  Stmt.to_string show_lvar show_var show_expr

let pp_stmt fmt s = Format.pp_print_string fmt (show_stmt s)

type prog_spec = { rely : BasilExpr.t list; guarantee : BasilExpr.t list }
type func_type = Axiom of e | Uninterpreted | Function of e

type declaration =
  | Function of {
      binding : Var.t;
      attrib : Expr.BasilExpr.t Attrib.attrib_map;
      definition : func_type;
    }  (** pure functions *)
  | Variable of { binding : Var.t; attrib : Expr.BasilExpr.t Attrib.attrib_map }
      (** mutable state *)

let pretty_declaration d =
  let open Containers_pp in
  match d with
  | Variable { binding } -> text @@ Var.to_decl_string_il binding
  | Function { binding; attrib; definition = Axiom body } ->
      text "axiom "
      ^ text (Var.name binding)
      ^ text " " ^ Expr.BasilExpr.pretty body
  | Function { binding; attrib; definition = Uninterpreted } ->
      text "val " ^ text (Var.to_string binding)
  | Function { binding; attrib; definition = Function body } ->
      text "let "
      ^ text (Var.to_string binding)
      ^ text " = "
      ^ nest 2 (Expr.BasilExpr.pretty body)

(*match definition with
      | Some d -> 
      let param, rt = Types.uncurry (Var.typ binding) in
      let param = 
      text "let " ^ text (Var.name binding) ^ text (Var.to_decl_string_il binding)
      | None -> text @@ Var.to_decl_string_il binding)
      *)

type t = {
  modulename : string;
  globals : declaration StringMap.t;
  entry_proc : ID.t option;
  procs : proc ID.Map.t;
  proc_names : ID.generator;
  attrib : e Attrib.attrib_map;
  spec : prog_spec;
}

let proc g p = ID.Map.find p g.procs

let proc_pretty p =
  let show_lvar v = Containers_pp.text @@ Var.to_string_il_lvar v in
  let show_var v = Containers_pp.text @@ Var.to_string_il_rvar v in
  let show_expr e = BasilExpr.pretty e in
  Procedure.pretty show_lvar show_var show_expr p

let global_vars prog =
  StringMap.values prog.globals
  |> Iter.filter_map (function
    | Variable { binding } -> Some binding
    | _ -> None)

let global_constants prog =
  StringMap.values prog.globals
  |> Iter.filter_map (function
    | Function { binding } -> Some binding
    | _ -> None)

let output_proc_pretty chan p =
  output_string chan @@ Containers_pp.Pretty.to_string ~width:80 (proc_pretty p)

let prog_pretty (p : t) =
  let open Containers_pp in
  let open Containers_pp.Infix in
  let globs =
    StringMap.bindings p.globals
    |> List.map (fun (n, v) -> pretty_declaration v)
  in
  let n =
    p.entry_proc
    |> Option.map (fun i -> text "prog entry " ^ text @@ ID.to_string i)
    |> Option.to_list
  in
  let decls =
    globs @ n
    @ List.map
        (fun (_, p) -> proc_pretty p)
        (ID.Map.to_list p.procs
        |> List.sort (fun (i, _) (j, _) -> ID.compare i j))
  in

  append_l ~sep:(text ";\n") decls ^ text ";\n"

let pretty_to_chan chan (p : t) =
  let p = prog_pretty p in
  flush chan;
  let fmt = Format.formatter_of_out_channel chan in
  Containers_pp.Pretty.to_format ~width:80 fmt p;
  Format.flush fmt ()

let decl_global ?(attrib = StringMap.empty) p v =
  let decl = Variable { binding = v; attrib } in
  { p with globals = StringMap.add (Var.name v) decl p.globals }

let add_decl ?(attrib = StringMap.empty) p v decl =
  { p with globals = StringMap.add (Var.name v) decl p.globals }

let create_single_proc ?(name = "<module>") () =
  let proc_names = ID.make_gen () in
  let procname = proc_names.fresh ~name () in
  let proc = Procedure.create procname () in
  let prog =
    {
      modulename = name;
      entry_proc = Some procname;
      globals = StringMap.empty;
      procs = ID.Map.singleton procname proc;
      proc_names;
      attrib = StringMap.empty;
      spec = { rely = []; guarantee = [] };
    }
  in
  (prog, proc)

let empty ?name () =
  let modulename = Option.get_or ~default:"<module>" name in
  {
    modulename;
    entry_proc = None;
    globals = StringMap.empty;
    procs = ID.Map.empty;
    proc_names = ID.make_gen ();
    attrib = StringMap.empty;
    spec = { rely = []; guarantee = [] };
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

  module G = Graph.Persistent.Digraph.ConcreteBidirectionalLabeled (Vert) (Edge)

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
    let graph = G.empty in
    let open Edge in
    let open Vert in
    let proc_edges =
      Iter.map
        (function id -> (ProcBegin id, Proc id, ProcReturn id))
        (ID.Map.keys t.procs)
    in
    let graph = Iter.fold G.add_edge_e graph proc_edges in
    let graph =
      match t.entry_proc with
      | Some entry ->
          List.fold_left G.add_edge_e graph
            [ (Entry, Nop, ProcBegin entry); (ProcReturn entry, Nop, Return) ]
      | None -> graph
    in
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
    Iter.fold G.add_edge_e graph call_dep_edges
end

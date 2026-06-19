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

type implicit_declaration =
  | VariantCase of {
      variant : string;
      belongs_to : Types.t;
      constructor : Var.t; (* function to construct a value of this case *)
    }

type declaration =
  | Type of { binding : string; typ : Types.t }
  | Function of {
      binding : Var.t;
      attrib : Attrib.attrib_map;
      definition : func_type;
    }  (** pure functions *)
  | Variable of {
      binding : Var.t;
      attrib : Attrib.attrib_map;
      classification : e option;
    }
  | Procedure of { definition : proc }

let decl_binding = function
  | Type { binding } -> binding
  | Variable { binding } -> Var.name binding
  | Function { binding } -> Var.name binding
  | Procedure { definition } -> ID.name (Procedure.id definition)

let pretty_proc p =
  let show_lvar v = Containers_pp.text @@ Var.to_string_il_lvar v in
  let show_var v = Containers_pp.text @@ Var.to_string_il_rvar v in
  let show_expr e = BasilExpr.pretty e in
  Procedure.pretty show_lvar show_var show_expr p

let pretty_declaration d =
  let open Containers_pp in
  match d with
  | Variable { binding; attrib; classification } ->
      let classification =
        classification |> Option.to_list
        |> List.map (fun e -> text " classification " ^ Expr.BasilExpr.pretty e)
        |> append_l
      in
      text (Var.to_decl_string_il binding) ^ classification
  | Function { binding; attrib; definition = Axiom body } ->
      text "axiom "
      ^ text (Var.name binding)
      ^ text " " ^ Expr.BasilExpr.pretty body
  | Function { binding; attrib; definition = Uninterpreted } ->
      text "val " ^ text (Var.to_string binding)
  | Function { binding; attrib; definition = Function body } -> (
      let open AbstractExpr in
      match BasilExpr.unfix body with
      | Lambda _ -> Expr.BasilExpr.pretty_let_single binding body None
      | _ ->
          let args, body, rtype = (text "", body, Var.typ binding) in
          text "let "
          ^ text (Var.name binding)
          ^ args ^+ text ":"
          ^+ text (Types.to_string rtype)
          ^+ text "="
          ^+ nest 2 (Expr.BasilExpr.pretty body))
  | Type { binding; typ } -> text "type " ^ text (Types.to_string_decl typ)
  | Procedure { definition } -> pretty_proc definition

(*match definition with
      | Some d -> 
      let param, rt = Types.uncurry (Var.typ binding) in
      let param = 
      text "let " ^ text (Var.name binding) ^ text (Var.to_decl_string_il binding)
      | None -> text @@ Var.to_decl_string_il binding)
      *)

type t = {
  modulename : string;
  declarations : declaration IDMap.t;
  implicit_decls : implicit_declaration IDMap.t;
  entry_proc : ID.t option;
  global_names : ID.generator;
  attrib : Attrib.attrib_map;
  spec : prog_spec;
}

let spec (p : t) = p.spec
let set_spec spec (p : t) = { p with spec }
let set_entry_proc e (p : t) = { p with entry_proc = Some e }
let attrib (p : t) = p.attrib
let set_attrib attrib (p : t) = { p with attrib }
let modulename (p : t) = p.modulename

let entry_proc_exn p =
  p.entry_proc |> function
  | None -> raise Not_found
  | Some i -> (
      IDMap.get i p.declarations |> function
      | Some (Procedure { definition }) -> definition
      | _ -> raise Not_found)

let entry_proc_opt p = try Some (entry_proc_exn p) with Not_found -> None

let map_procedures f p =
  {
    p with
    declarations =
      p.declarations
      |> IDMap.mapi (fun i -> function
        | Procedure { definition } -> Procedure { definition = f i definition }
        | o -> o);
  }

let proc prog p =
  IDMap.find p prog.declarations |> function
  | Procedure { definition } -> definition
  | _ -> raise Not_found

let proc_opt prog p = try Some (proc prog p) with Not_found -> None

let procs p =
  IDMap.to_iter p.declarations
  |> Iter.filter_map (function
    | k, Procedure { definition } -> Some (k, definition)
    | _ -> None)

let global_vars prog =
  IDMap.values prog.declarations
  |> Iter.filter_map (function
    | Variable { binding } -> Some binding
    | _ -> None)

let global_constants prog =
  IDMap.values prog.declarations
  |> Iter.filter_map (function
    | Function { binding } -> Some binding
    | _ -> None)

let get_decl_by_name_id name prog =
  try
    let id = prog.global_names.get_id name in
    IDMap.find_opt id prog.declarations |> Option.map (fun v -> (id, v))
  with Not_found -> None

let get_decl_by_name name prog = get_decl_by_name_id name prog |> Option.map snd

let get_proc_by_name name prog =
  get_decl_by_name name prog |> function
  | Some (Procedure { definition }) -> definition
  | _ -> raise Not_found

let get_implicit_decl_by_name name prog =
  try
    let id = prog.global_names.get_id name in
    IDMap.find_opt id prog.implicit_decls
  with Not_found -> None

let declare_name_exn name prog = prog.global_names.decl_exn name
let declare_name name prog = prog.global_names.decl_or_get name
let get_id_by_name name prog = prog.global_names.get_id name

let remove_decl p decl =
  let d = p.global_names.decl_or_get (decl_binding decl) in
  { p with declarations = IDMap.remove d p.declarations }

let update_decl ?(attrib = StringMap.empty) prog decl =
  let d = p.global_names.decl_or_get (decl_binding decl) in
  { p with declarations = IDMap.add id decl p.declarations }

  add_decl ~attrib prog decl

let add_proc p prog =
  let id = Procedure.id p in
  {
    prog with
    declarations = IDMap.add id (Procedure { definition = p }) prog.declarations;
  }

let update_proc id f (prog : t) =
  proc_opt prog id |> f |> function
  | Some proc ->
      (if not @@ ID.equal (Procedure.id proc) id then
         { prog with declarations = IDMap.remove id prog.declarations }
       else prog)
      |> add_proc proc
  | None -> { prog with declarations = IDMap.remove id prog.declarations }

let output_proc_pretty chan p =
  output_string chan @@ Containers_pp.Pretty.to_string ~width:80 (pretty_proc p)

let prog_pretty (p : t) =
  let open Containers_pp in
  let open Containers_pp.Infix in
  let globs =
    IDMap.bindings p.declarations
    |> List.sort (fun (_, decl) (_, decl2) ->
        (* NOTE: Recursive types might require more logic here *)
        match (decl, decl2) with
        | Type _, Type _ | Variable _, Variable _ | Function _, Function _ -> 0
        | Type _, _ -> -1
        | _, Type _ -> 1
        | _ -> 0)
    |> List.map (fun (n, v) -> pretty_declaration v)
  in
  let n =
    p.entry_proc
    |> Option.map (fun i -> text "prog entry " ^ text @@ ID.to_string i)
    |> Option.to_list
  in
  (* hopefullly ID map is sorted by id generator *)
  let decls = globs @ n in

  append_l ~sep:(text ";\n") decls ^ text ";\n"

let declarations p = p.declarations |> IDMap.to_iter

let filter_decls f p =
  declarations p
  |> Iter.fold
       (fun prog (i, d) ->
         match f i d with
         | true -> prog
         | false ->
             { prog with declarations = IDMap.remove i prog.declarations })
       p

let filter_map_decls f p =
  declarations p
  |> Iter.fold
       (fun prog (i, d) ->
         match f i d with
         | Some d -> update_decl prog d
         | None -> { prog with declarations = IDMap.remove i prog.declarations })
       p

let map_decls f p = filter_map_decls (fun id p -> Some (f id p)) p

let flat_map_decls f p =
  declarations p
  |> Iter.fold
       (fun prog (i, decl) ->
         let ex = ref false in
         let update_decl prog decl =
           get_decl_by_name_id (decl_binding decl) prog
           |> Option.iter (fun (id, _) -> if ID.equal id i then ex := true);
           update_decl prog decl
         in
         let next = f i decl in
         let prog = Iter.fold update_decl prog next in
         if !ex then prog
         else { prog with declarations = IDMap.remove i prog.declarations })
       p

let pretty_to_chan chan (p : t) =
  let p = prog_pretty p in
  flush chan;
  let fmt = Format.formatter_of_out_channel chan in
  Containers_pp.Pretty.to_format ~width:80 fmt p;
  Format.flush fmt ()

  (*

Variable { binding = v; attrib; classification }

  *)

let decl_global p name f =
  let id : ID.t = p.global_names.decl_exn name in
  let decl = f id in
  { p with declarations = IDMap.add id decl p.declarations }

let add_decl  p name decl =
  let id : ID.t = p.global_names.decl_exn name in
  let decl = f id in
  { p with declarations = IDMap.add id decl p.declarations }


let decl_global_var p  ?(attrib = StringMap.empty) ?(classification = None) name scope typ  =
  let f v = let r = ref None in match r with Some v -> v | None -> r := Some v ; v in
  let p = decl_global p name (fun id -> Variable { binding = f (Var.create id ~scope typ) ; attrib; classification }) in
  (p, f (failwith ""))


let decl_typ ?(attrib = StringMap.empty) p t =
  match t with
  | Sort (type_name, []) as s ->
      let id : ID.t = p.global_names.decl_exn type_name in
      {
        p with
        declarations =
          IDMap.add id (Type { binding = type_name; typ = s }) p.declarations;
      }
  | Sort (name, variants) as s ->
      let id : ID.t = p.global_names.decl_exn name in
      {
        p with
        declarations =
          IDMap.add id (Type { binding = name; typ = s }) p.declarations;
        implicit_decls =
          IDMap.add_list p.implicit_decls
            (variants
            |> List.map (function { variant; fields } ->
                let variant = p.global_names.decl_exn variant in
                let args = List.map (function { field; typ } -> typ) fields in
                let ty = Types.curry args s in
                let constructor =
                  Var.create (variant) ty ~scope:GlobalConst
                in
                ( variant,
                  VariantCase
                    { variant = ID.name variant; belongs_to = s; constructor }
                )));
      }
  | _ -> failwith "not declarable type"

let create_single_proc ?(name = "<module>") () =
  let global_names = ID.make_gen () in
  let procname = global_names.fresh ~name () in
  let proc = Procedure.create procname () in
  let prog =
    {
      modulename = name;
      entry_proc = Some procname;
      declarations = IDMap.singleton procname (Procedure { definition = proc });
      implicit_decls = IDMap.empty;
      global_names;
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
    declarations = IDMap.empty;
    implicit_decls = IDMap.empty;
    global_names = ID.make_gen ();
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

  module Scc = Graph.Components.Make (struct
    include G

    (* Don't include return edges *)
    let iter_succ f g = function
      | Vert.ProcReturn proc as v ->
          G.iter_succ
            (fun v' -> if Vert.equal v' Vert.Return then f v' else ())
            g v
      | v -> G.iter_succ f g v
  end)

  let make_call_graph t =
    let called_by (p : proc) =
      Procedure.blocks_to_list p |> List.to_iter |> Iter.map snd
      |> Iter.flat_map Block.stmts_iter
      |> Iter.filter_map (function
        | Stmt.Instr_Call { procid } -> Some procid
        | _ -> None)
      |> IDSet.of_iter
    in
    let calls =
      procs t |> Iter.map (function pid, proc -> (pid, called_by proc))
    in
    let graph = G.empty in
    let open Edge in
    let open Vert in
    let proc_edges =
      Iter.map
        (function id -> (ProcBegin id, Proc id, ProcReturn id))
        (procs t |> Iter.map fst)
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
                   (IDSet.to_iter called)))
        calls
    in
    Iter.fold G.add_edge_e graph call_dep_edges
end

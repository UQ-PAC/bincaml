(** Prototype IDE solver: proof of concept for the design for a generic ish ide
    solver.

    WARN: the implemented live variables analysis here is not correct and the
    solver is likely wrong; particularly with regard to context sensitivity *)

open Lang
open Containers
open Common

module Loc = struct
  type stmt_id = { proc_id : ID.t; block : ID.t; offset : int }
  [@@deriving eq, ord, show { with_path = false }]

  type t =
    | IntraVertex of { proc_id : ID.t; v : Procedure.Vert.t }
    | CallSite of stmt_id
    | AfterCall of stmt_id
    | Entry
    | Exit
  [@@deriving eq, ord, show]

  let hash = Hashtbl.hash
end

type ret_info = {
  rhs : (Var.t * Expr.BasilExpr.t) list;
  lhs : (Var.t * Var.t) list;
  call_from : Program.stmt; (* stmt must be variable Instr_Call*)
  caller : ID.t;
  callee : ID.t;
}
[@@deriving eq, ord, show { with_path = false }]

type call_info = {
  rhs : (Var.t * Expr.BasilExpr.t) list;
  lhs : (Var.t * Var.t) list;
  call_from : Program.stmt; (* stmt must be variable Instr_Call*)
  aftercall : Loc.stmt_id;
  caller : ID.t;
  callee : ID.t;
  ret : ret_info;
}
[@@deriving eq, ord, show { with_path = false }]
(** (target.formal_in, rhs arg) assignment to call formal params *)

module LSet = Set.Make (Loc)
module LM = Map.Make (Loc)

let direction : [ `Forwards | `Backwards ] = `Backwards

module IDEGraph = struct
  module Vert = struct
    include Loc
  end

  open Vert

  module Edge = struct
    type t =
      | Stmts of Var.t Block.phi list * Program.stmt list
      | InterCall of call_info
      | InterReturn of ret_info
      | Call of Program.stmt
      | Nop
    [@@deriving eq, ord, show]

    let default = Nop
  end

  module StmtLabel = struct
    type 'a t = 'a Iter.t
  end

  module G = Graph.Imperative.Digraph.ConcreteBidirectionalLabeled (Vert) (Edge)
  module GB = Graph.Builder.I (G)

  type t = {
    prog : Program.t;
    callgraph : Program.CallGraph.G.t;
    vertices : Loc.t Iter.t Lazy.t;
  }

  type bstate = {
    graph : G.t;
    last_vert : Loc.t;
    stmts : Var.t Block.phi list * Program.stmt list;
  }

  let add_edge_e_dir dir g (v1, e, v2) =
    match dir with
    | `Forwards -> GB.add_edge_e g (v1, e, v2)
    | `Backwards -> GB.add_edge_e g (v2, e, v1)

  let push_edge dir (ending : Loc.t) (g : bstate) =
    match g with
    | { graph; last_vert; stmts } ->
        let phi, stmts = (fst stmts, List.rev (snd stmts)) in
        let e1 = (last_vert, Edge.Stmts (phi, stmts), ending) in
        {
          graph = add_edge_e_dir `Forwards graph e1;
          stmts = ([], []);
          last_vert = ending;
        }

  let add_call dir p (st : bstate) (origin : stmt_id) (callstmt : Program.stmt)
      =
    let lhs, rhs, target =
      match callstmt with
      | Stmt.(Instr_Call { lhs; procid; args }) ->
          let target_proc = Program.proc p procid in
          let formal_in =
            Procedure.formal_in_params target_proc |> StringMap.to_iter
          in
          let actual_in = args |> StringMap.to_iter in
          let actual_rhs =
            Iter.join_by fst fst
              ~merge:(fun id a b -> Some (snd a, snd b))
              formal_in actual_in
            |> Iter.to_list
          in
          let formal_out =
            Procedure.formal_out_params target_proc |> StringMap.to_iter
          in
          let actual_out = lhs |> StringMap.to_iter in
          let actual_lhs =
            Iter.join_by fst fst
              ~merge:(fun id a b -> Some (snd a, snd b))
              actual_out formal_out
            |> Iter.to_list
          in
          (actual_lhs, actual_rhs, procid)
      | _ -> failwith "not a call"
    in
    let caller, callee = (origin.proc_id, target) in
    let g = push_edge dir (CallSite origin) st in
    let graph = g.graph in
    let graph =
      GB.add_edge_e graph (CallSite origin, Call callstmt, AfterCall origin)
    in
    let call_entry = IntraVertex { proc_id = target; v = Entry } in
    let call_return = IntraVertex { proc_id = target; v = Return } in
    let call_entry, call_return =
      match dir with
      | `Forwards -> (call_entry, call_return)
      | `Backwards -> (call_return, call_entry)
    in
    let ret_info = { lhs; rhs; call_from = callstmt; caller; callee } in
    let graph =
      GB.add_edge_e graph
        ( CallSite origin,
          InterCall
            {
              rhs;
              lhs;
              call_from = callstmt;
              aftercall = origin;
              caller;
              callee;
              ret = ret_info;
            },
          call_entry )
    in
    let graph =
      GB.add_edge_e graph (call_return, InterReturn ret_info, AfterCall origin)
    in
    { g with graph; last_vert = AfterCall origin }

  let proc_graph prog g p dir =
    let proc_id = Procedure.id p in
    let add_block_edge b graph =
      match b with
      | v1, Procedure.Edge.Jump, v2 ->
          add_edge_e_dir dir g
            Loc.
              ( IntraVertex { proc_id; v = v1 },
                Nop,
                IntraVertex { proc_id; v = v2 } )
      | ( Procedure.Vert.Begin block,
          Procedure.Edge.Block b,
          Procedure.Vert.End b2 ) ->
          assert (ID.equal b2 block);
          let is =
            {
              graph;
              last_vert =
                IntraVertex
                  {
                    proc_id;
                    v =
                      (match dir with
                      | `Forwards -> Begin block
                      | `Backwards -> End block);
                  };
              stmts = (b.phis, []);
            }
          in
          (match dir with
            | `Forwards -> Block.stmts_iter_i b
            | `Backwards -> Block.stmts_iter_i b |> Iter.rev)
          |> Iter.fold
               (fun st (i, s) ->
                 let stmt_id : Loc.stmt_id = { proc_id; block; offset = i } in
                 match s with
                 | Stmt.Instr_Call _ as c -> add_call dir prog st stmt_id c
                 | stmt ->
                     { st with stmts = (fst st.stmts, stmt :: snd st.stmts) })
               is
          |> push_edge dir
               (IntraVertex
                  {
                    proc_id;
                    v =
                      (match dir with
                      | `Forwards -> End block
                      | `Backwards -> Begin block);
                  })
          |> fun x -> x.graph
      | _, _, _ -> failwith "bad proc edge"
    in
    (* add all vertices *)
    (* TODO: missing stub procedure edges probably *)
    let intra_verts =
      Option.to_iter (Procedure.graph p)
      |> Iter.flat_map (fun graph ->
          Procedure.G.fold_vertex
            (fun v acc -> Iter.cons (Loc.IntraVertex { proc_id; v }) acc)
            graph Iter.empty)
    in
    let g = Iter.fold GB.add_vertex g intra_verts in
    let g =
      if Option.equal ID.equal prog.entry_proc (Some proc_id) then
        add_edge_e_dir dir g (Entry, Nop, IntraVertex { proc_id; v = Entry })
        |> fun g ->
        add_edge_e_dir dir g (IntraVertex { proc_id; v = Return }, Nop, Exit)
      else g
    in
    Procedure.graph p
    |> Option.map (fun procg -> Procedure.G.fold_edges_e add_block_edge procg g)
    |> Option.get_or ~default:g

  let create (prog : Program.t) dir =
    ID.Map.to_iter prog.procs |> Iter.map snd
    |> Iter.fold (fun g p -> proc_graph prog g p dir) (GB.empty ())

  let proc_call_table dir g (prog : Program.t) =
    let tbl = Hashtbl.create 100 in
    G.iter_vertex
      (fun l ->
        match l with
        | CallSite s ->
            let cur = Hashtbl.get_or tbl s.proc_id ~default:Iter.empty in
            Hashtbl.add tbl s.proc_id (Iter.cons (CallSite s) cur)
        | _ -> ())
      g;
    tbl

  module RevTop = Graph.Topological.Make (struct
    type t = G.t

    module V = G.V

    module E = struct
      include G.E

      let src = G.E.dst
      let dst = G.E.src
    end

    let iter_vertex = G.iter_vertex
    let iter_succ = G.iter_pred
  end)

  module Top = Graph.Topological.Make (G)

  module Vis = Graph.Graphviz.Dot (struct
    include G
    open G.V
    open G.E

    let graph_attributes _ = []

    let vertex_name (v : Loc.t) =
      match v with
      | IntraVertex { proc_id; v } ->
          "\""
          ^ Procedure.Vert.block_id_string v
          ^ "@" ^ ID.to_string proc_id ^ "\""
      | Entry -> "\"Entry\""
      | Exit -> "\"Exit\""
      | CallSite s ->
          "\"" ^ "CallSite" ^ ID.to_string s.block ^ "."
          ^ Int.to_string s.offset ^ "\""
      | AfterCall s ->
          "\"" ^ "AfterCall" ^ ID.to_string s.block ^ "."
          ^ Int.to_string s.offset ^ "\""

    let vertex_attributes (v : Loc.t) =
      let l =
        match v with
        | IntraVertex { proc_id; v } ->
            Procedure.Vert.block_id_string v
            ^ "@" ^ Int.to_string @@ ID.index proc_id
        | Entry -> "Entry"
        | Exit -> "Exit"
        | CallSite s ->
            "CallSite" ^ ID.to_string s.block ^ "." ^ Int.to_string s.offset
        | AfterCall s ->
            "AfterCall" ^ ID.to_string s.block ^ "." ^ Int.to_string s.offset
      in
      [ `Label l ]

    let default_vertex_attributes _ = []

    let edge_attributes (e : E.t) =
      let l =
        match e with
        | _, Stmts _, _ -> "Stmts"
        | _, InterCall _, _ -> "InterCall"
        | _, InterReturn _, _ -> "InterReturn"
        | _, Call _, _ -> "Call"
        | _, Nop, _ -> ""
      in
      [ `Label l ]

    let default_edge_attributes _ = []
    let get_subgraph _ = None
  end)
end

module type Lattice = sig
  include ORD_TYPE

  val join : t -> t -> t
  val bottom : t

  (*val eval : (Var.t -> t option) -> Expr.BasilExpr.t -> t*)
  (*val transfer : (Var.t -> t option) -> Program.stmt -> (Var.t * t) Iter.t*)
end

(* TODO rename these types !!!!!!!!!!!!! *)

(** blah blah blah *)
type 'a dl = Label of 'a | Lambda [@@deriving eq, ord, show]

module Lambda = struct
  (* TODO not Var.t (want more generality e.g. dsa uses symbolic addresses in scala code) *)
  type t = Var.t dl [@@deriving eq, ord, show]
  (** blah blah blah *)
end

module Lambda2 = struct
  type t = Lambda.t * Lambda.t [@@deriving eq, ord, show]
end

module DlMap = Map.Make (Lambda)

type 'a state_update = (Var.t dl * 'a) Iter.t

module type IDEDomain = sig
  include Lattice

  (* idk how to document this but the ordering of this domain should be of the edge functions
   so t = EdgeFunction ... would it be better for the module to be edge functions? *)
  module Value : Lattice

  val identity : t
  (** identity edge function *)

  val compose : t -> t -> t
  (** the composite of edge functions *)

  val eval : t -> Value.t -> Value.t
  (** evaluate an edge function *)

  val compose_call : call_info -> Var.t dl -> t state_update
  (** edge calling a procedure *)

  val compose_return : ret_info -> Var.t dl -> t state_update
  (** edge return to after a call *)

  val compose_call_to_aftercall : Program.stmt -> Var.t dl -> t state_update
  (** edge from a call to its aftercall statement *)

  val transfer : Program.stmt -> Var.t dl -> t state_update
  (** update the state for a program statement *)
end

module IDELive = struct
  module Value = struct
    type t = bool [@@deriving eq, ord, show]

    let bottom = false
    let live : t = true
    let dead : t = false

    let join a b =
      match (a, b) with
      | true, _ -> true
      | _, true -> true
      | false, false -> false
  end

  let show_state s =
    s
    |> Iter.filter_map (function c, true -> Some c | _ -> None)
    |> Iter.to_string ~sep:", " (fun v -> Var.to_string v)

  open Value

  (*type t = Live | Dead | CondLive of Var.t [@@deriving eq, ord]*)
  type t = IdEdge | ConstEdge of Value.t [@@deriving eq, ord]

  let bottom = ConstEdge bottom

  let show v =
    match v with IdEdge -> "IdEdge" | ConstEdge v -> "ConstEdge " ^ show v

  let pp fmt v = Format.pp_print_string fmt (show v)
  let identity = IdEdge

  (** compose (\lambda v . a) (\lambda v . b) *)
  let compose a b =
    match (a, b) with
    | IdEdge, b -> b
    | a, IdEdge -> a
    | ConstEdge v, ConstEdge v' -> ConstEdge v

  let join a b =
    match (a, b) with
    | ConstEdge v, ConstEdge v' -> ConstEdge (join v v')
    | ConstEdge true, IdEdge -> ConstEdge true
    | ConstEdge false, IdEdge -> IdEdge
    | IdEdge, ConstEdge true -> ConstEdge true
    | IdEdge, ConstEdge false -> IdEdge
    | IdEdge, IdEdge -> IdEdge

  let eval f v = match f with IdEdge -> v | ConstEdge v -> v

  let compose_call (c : call_info) d =
    match d with
    | Lambda ->
        List.fold_left
          (fun i (_, out) -> Iter.cons (Label out, IdEdge) i)
          (Iter.singleton (d, IdEdge))
          c.lhs
    | Label v when Var.is_global v -> Iter.empty
    | Label v -> Iter.empty

  let compose_return r d = Iter.singleton (d, IdEdge)

  let compose_call_to_aftercall stmt d =
    match d with Lambda -> Iter.singleton (d, IdEdge) | Label _ -> Iter.empty

  let transfer stmt d =
    let open Stmt in
    match d with
    | Lambda -> (
        match stmt with
        | Instr_Assign _ -> Iter.singleton (d, IdEdge)
        | _ ->
            Stmt.free_vars_iter stmt
            |> Iter.fold
                 (fun i v -> Iter.cons (Label v, ConstEdge live) i)
                 (Iter.singleton (d, IdEdge)))
    | Label v -> (
        match stmt with
        | Instr_Assign assigns ->
            List.fold_left
              (fun i (v', ex) ->
                Iter.flat_map
                  (fun (d, e) ->
                    if Lambda.equal d (Label v') then
                      Expr.BasilExpr.free_vars_iter ex
                      |> Iter.map (fun v' -> (Label v', IdEdge))
                    else Iter.singleton (d, e))
                  i)
              (Iter.singleton (d, IdEdge))
              assigns
        (*
            Iter.of_list assigns
            |> Iter.filter (fun (v', _) -> Var.equal v v')
            |> Iter.flat_map (fun (v, e) -> Expr.BasilExpr.free_vars_iter e)
            |> Iter.fold (fun i v' -> Iter.cons (Label v', IdEdge) i) Iter.empty
            *)
        (* The index variables of a memory read are always live regardless of if
           the lhs was dead, since there are still side effects of reading
           memory ? *)
        | Instr_Load l when Var.equal l.lhs v -> Iter.empty
        | Instr_IntrinCall c
          when StringMap.exists (fun _ v' -> Var.equal v v') c.lhs ->
            Iter.empty
        | Instr_Call c when StringMap.exists (fun _ v' -> Var.equal v v') c.lhs
          ->
            Iter.empty
        (*| Instr_IndirectCall c
          when StringMap.exists (fun _ v' -> Var.equal v v') c.lhs ->
            DlMap.empty*)
        | _ -> Iter.singleton (Label v, IdEdge))
end

(** FIXME:
    - properly handle global variables / local variables across procedure calls;
      procedure summaries should be in terms of globals and formal paramters
      only ; composition across calls should include the globals
    - phis *)

module IDE (D : IDEDomain) = struct
  type summary = D.t DlMap.t DlMap.t [@@deriving eq, ord]
  (** A summary associated to a location gives us all edge functions from the
      start/end of the procedure this location is in, to this location.

      Non membership in the map means v v' -> const bottom *)

  let show_summary v =
    DlMap.to_iter v
    |> Iter.flat_map (fun (d1, m) ->
        DlMap.to_iter m |> Iter.map (fun x -> (d1, x)))
    |> Iter.to_string ~sep:", " (fun (v, (v', i)) ->
        "(" ^ Lambda.show v ^ "," ^ Lambda.show v' ^ "->" ^ D.show i ^ ")")

  let empty_summary = DlMap.empty

  type analysis_state = D.Value.t VarMap.t [@@deriving eq, ord]

  let join_state_with st v x =
    let j =
      VarMap.get v st |> Option.map (D.Value.join x) |> Option.get_or ~default:x
    in
    VarMap.add v j st

  (** Determine composites of edge functions through an intravertex block *)
  let tf_stmts dir phi bs i =
    (*let bs = match dir with `Forwards -> bs | `Backwards -> List.rev bs in*)
    let stmts i =
      List.fold_left
        (fun om stmt ->
          DlMap.fold
            (fun d2 e1 m ->
              D.transfer stmt d2
              |> Iter.fold
                   (fun m (d3, e2) ->
                     let e = D.compose e2 e1 in
                     let j = D.join e (DlMap.get_or d3 m ~default:D.bottom) in
                     if not (D.equal j D.bottom) then DlMap.add d3 j m else m)
                   m)
            om DlMap.empty)
        (* TODO Should be joining i *)
        (DlMap.of_iter i)
        bs
      |> DlMap.to_iter
    in
    (* TODO this might be more imprecise than joining on the opposite side of the phi node
                 https://link.springer.com/chapter/10.1007/978-3-642-11970-5_8 reckons so *)
    let phis i =
      match dir with
      | `Forwards ->
          List.fold_left
            (fun i (p : Var.t Block.phi) ->
              Iter.map
                (fun (d2, e) ->
                  if List.exists (fun (_, v) -> Lambda.equal (Label v) d2) p.rhs
                  then (Label p.lhs, e)
                  else (d2, e))
                i)
            i phi
      | `Backwards ->
          List.fold_left
            (fun i (p : Var.t Block.phi) ->
              Iter.flat_map
                (fun (d2, e) ->
                  if Lambda.equal (Label p.lhs) d2 then
                    Iter.of_list p.rhs
                    |> Iter.map (fun (_, d3) -> (Label d3, e))
                  else Iter.singleton (d2, e))
                i)
            i phi
    in
    match dir with `Forwards -> stmts (phis i) | `Backwards -> phis (stmts i)

  type edge = Loc.t * IDEGraph.Edge.t * Loc.t

  let dldlget d1 d2 summary =
    DlMap.get d1 summary
    |> Option.flat_map (DlMap.get d2)
    |> Option.get_or ~default:D.bottom

  let propagate worklist summaries priority summary loc updates =
    let module Q = IntPQueue.Plain in
    Iter.filter_map
      (fun ((d1, d3), e) ->
        let l = dldlget d1 d3 summary in
        let j = D.join l e in
        (not (D.equal l j)) |> flip Option.return_if ((d1, d3), j))
      updates
    |> Iter.fold
         (fun acc ((d1, d3), e) ->
           Q.add worklist (loc, (d1, d3)) (priority loc);
           let m = DlMap.get_or d1 acc ~default:DlMap.empty in
           DlMap.add d1 (DlMap.add d3 e m) acc)
         summary
    |> Hashtbl.add summaries loc

  let phase1_solve order dir start graph globals default =
    Trace.with_span ~__FILE__ ~__LINE__ "ide-phase1" @@ fun _ ->
    let module Q = IntPQueue.Plain in
    let (worklist : (Loc.t * Lambda2.t) Q.t) = Q.create () in
    let summaries : (Loc.t, summary) Hashtbl.t = Hashtbl.create 100 in
    Hashtbl.add summaries start
      (DlMap.singleton Lambda (DlMap.singleton Lambda D.identity));
    (* Stores edge functions from the first procedure's entry to the second
       procedure's entry where the d value of the second procedure's entry is
       the given dl. *)
    let entry_to_call_entry_cache :
        (ID.t * Lambda.t * ID.t, D.t DlMap.t) Hashtbl.t =
      Hashtbl.create 100
    in
    (* Stores edge functions from the entry of a procedure to the end of said procedure for a given d value at the entry *)
    let entry_to_exit_cache : (ID.t * Lambda.t, D.t DlMap.t) Hashtbl.t =
      Hashtbl.create 100
    in
    let get_summary loc = Hashtbl.get summaries loc |> Option.get_or ~default in
    let priority l = LM.find l order in
    (*IDEGraph.G.fold_edges_e (fun e a -> Q.add worklist (e, (Lambda, Lambda) (priority e))) graph ();*)
    Q.add worklist (start, (Lambda, Lambda)) (priority start);
    while not (Q.is_empty worklist) do
      let (x : Loc.t * Lambda2.t) =
        Q.extract worklist |> Option.get_exn_or "queue empty"
      in
      let l, (d1, d2) = x in
      let ost = get_summary l in
      let e1 = dldlget d1 d2 ost in
      IDEGraph.G.succ_e graph l |> Iter.of_list
      |> Iter.iter (fun e ->
          let from, target = match e with from, _, target -> (from, target) in
          match IDEGraph.G.E.label e with
          | Stmts (phi, bs) ->
              tf_stmts dir phi bs (Iter.singleton (d2, e1))
              |> Iter.map (fun (d3, e) -> ((d1, d3), e))
              |> propagate worklist summaries priority (get_summary target)
                   target
          | InterCall callinfo ->
              D.compose_call callinfo d2
              |> Iter.iter (fun (d3, e2) ->
                  propagate worklist summaries priority (get_summary target)
                    target
                    (Iter.singleton ((d3, d3), D.identity));
                  let e21 = D.compose e2 e1 in
                  let k = (callinfo.caller, d3, callinfo.callee) in
                  let m =
                    Hashtbl.get_or entry_to_call_entry_cache k
                      ~default:DlMap.empty
                    |> DlMap.add d1 e21
                  in
                  Hashtbl.add entry_to_call_entry_cache k m;
                  (* Surely there's a better way to do this... *)
                  let aftercall = Loc.AfterCall callinfo.aftercall in
                  let _ =
                    Hashtbl.get entry_to_exit_cache (callinfo.callee, d3)
                    |> Option.map (fun m ->
                        DlMap.to_iter m
                        |> Iter.iter (fun (d4, e3) ->
                            let e321 = D.compose e3 e21 in
                            D.compose_return callinfo.ret d4
                            |> Iter.map (fun (d5, e4) ->
                                ((d1, d5), D.compose e4 e321))
                            |> propagate worklist summaries priority
                                 (get_summary aftercall) aftercall))
                  in
                  ())
          | InterReturn retinfo ->
              (* Duplicate work warning!! we're saving the summary of the procedure we're returning from multiple times!! *)
              let k = (retinfo.callee, d1) in
              let m =
                Hashtbl.get_or entry_to_exit_cache k ~default:DlMap.empty
                |> DlMap.add d2 e1
              in
              Hashtbl.add entry_to_exit_cache k m;

              let k = (retinfo.caller, d1, retinfo.callee) in
              let _ =
                Hashtbl.get entry_to_call_entry_cache k
                |> Option.map (fun m ->
                    DlMap.to_iter m
                    |> Iter.iter (fun (d3, e2) ->
                        let e12 = D.compose e1 e2 in
                        D.compose_return retinfo d2
                        |> Iter.map (fun (d4, e3) ->
                            ((d3, d4), D.compose e3 e12))
                        |> propagate worklist summaries priority
                             (get_summary target) target))
              in
              ()
          | Call callstmt ->
              D.compose_call_to_aftercall callstmt d2
              |> Iter.map (fun (d3, e2) -> ((d1, d3), D.compose e2 e1))
              |> propagate worklist summaries priority (get_summary target)
                   target
          | Nop ->
              propagate worklist summaries priority (get_summary target) target
                (Iter.singleton ((d1, d2), e1)))
    done;
    summaries

  let phase2_solve order dir prog start_proc graph globals
      (summaries : (Loc.t, summary) Hashtbl.t) =
    (* FIXME: use summaries ; propertly evaluate call edges first then fill in between*)
    Trace.with_span ~__FILE__ ~__LINE__ "ide-phase2" @@ fun _ ->
    let module Q = IntPQueue.Plain in
    let states : (Loc.t, analysis_state) Hashtbl.t = Hashtbl.create 100 in
    let get_st l = Hashtbl.get_or states l ~default:VarMap.empty in
    let priority l = LM.find l order in
    let get_summary loc =
      Hashtbl.get summaries loc |> function
      | Some e -> e
      | None ->
          print_endline @@ "summary undefined " ^ Loc.show loc;
          DlMap.empty
    in
    (* The first step is to initialise the entry nodes of each procedure with
       their initial value based on the entry procedure being initialised to
       top, using the summary functions. *)
    let (worklist : (Loc.t * Lambda.t) Q.t) = Q.create () in
    let calls_table = IDEGraph.proc_call_table dir graph prog in
    Hashtbl.get_or calls_table start_proc ~default:Iter.empty
    |> Iter.iter (fun l -> Q.add worklist (l, Lambda) (priority l));
    while not (Q.is_empty worklist) do
      let l, d = Q.extract worklist |> Option.get_exn_or "queue empty" in
      let ost = get_st l in
      let md =
        match d with
        | Label v -> VarMap.get_or v ost ~default:D.Value.bottom
        | _ -> D.Value.bottom
      in
      IDEGraph.G.succ_e graph l |> Iter.of_list
      |> Iter.iter (fun e ->
          let target = match e with _, _, target -> target in
          match IDEGraph.G.E.label e with
          | InterCall callinfo ->
              let summary = get_summary l in
              DlMap.get d summary |> Iter.of_opt
              |> Iter.flat_map DlMap.to_iter
              |> Iter.iter (fun (d2, e1) ->
                  D.compose_call callinfo d2
                  |> Iter.iter (fun (d3, e2) ->
                      (match d3 with
                      | Label v ->
                          let st =
                            Hashtbl.get_or states target ~default:VarMap.empty
                          in
                          let fd = D.eval e2 (D.eval e1 md) in
                          let y = VarMap.get_or v st ~default:D.Value.bottom in
                          let j = D.Value.join y fd in
                          if not (D.Value.equal j y) then (
                            let st' = VarMap.add v (D.Value.join y fd) st in
                            Hashtbl.add states target st';
                            (* This should really add all calls in the target procedure to the worklist *)
                            Hashtbl.get_or calls_table callinfo.callee
                              ~default:Iter.empty
                            |> Iter.iter (fun c ->
                                Q.add worklist (c, d3) (priority c)))
                          else ()
                      | _ -> ());
                      ()))
          | _ -> ())
    done;
    (* We then apply all summary functions to each location *)
    let entry_of (l : Loc.t) =
      match l with
      | IntraVertex { proc_id; v } -> Loc.IntraVertex { proc_id; v = Entry }
      | CallSite stmt_id -> IntraVertex { proc_id = stmt_id.proc_id; v = Entry }
      | AfterCall stmt_id ->
          IntraVertex { proc_id = stmt_id.proc_id; v = Entry }
      | Entry -> Entry
      | Exit -> Entry
    in
    flip IDEGraph.G.iter_vertex graph (fun l ->
        let pst = get_st (entry_of l) in
        get_summary l
        |> DlMap.iter (fun d1 ->
            let x =
              match d1 with
              | Label v -> VarMap.get_or v pst ~default:D.Value.bottom
              | _ -> D.Value.bottom
            in
            DlMap.iter (fun d2 e ->
                match d2 with
                | Label v ->
                    let st = get_st l in
                    let y = D.eval e x in
                    Hashtbl.add states l (join_state_with st v y)
                | _ -> ())));
    states

  let query r ~proc_id vert =
    Hashtbl.get r (Loc.IntraVertex { proc_id; v = vert })

  let solve dir (prog : Program.t) =
    Trace.with_span ~__FILE__ ~__LINE__ "ide-solve" @@ fun _ ->
    let globals = prog.globals |> Var.Decls.to_iter |> Iter.map snd in
    let graph = IDEGraph.create prog dir in
    let order =
      Iter.from_iter (fun f -> IDEGraph.Top.iter f graph)
      |> Iter.zip_i
      |> Iter.map (fun (i, v) -> (v, i))
      |> LM.of_iter
    in
    let start =
      match dir with `Forwards -> Loc.Entry | `Backwards -> Loc.Exit
    in
    let start_proc =
      prog.entry_proc |> Option.get_exn_or "Missing entry procedure"
    in
    let summary = phase1_solve order dir start graph globals DlMap.empty in
    ( query @@ summary,
      query @@ phase2_solve order dir prog start_proc graph globals summary )

  module G = Procedure.RevG
  module ResultMap = Map.Make (G.V)

  module type LocalPhaseProcAnalysis = sig
    val recurse :
      G.t ->
      G.V.t Graph.WeakTopological.t ->
      (G.V.t -> summary) ->
      G.V.t Graph.ChaoticIteration.widening_set ->
      int ->
      summary ResultMap.t
  end
end

module IDELiveAnalysis = IDE (IDELive)

let show_state (v : IDELiveAnalysis.analysis_state) =
  VarMap.to_iter v |> IDELive.show_state

let print_live_vars_dot sum r fmt prog proc_id =
  let label (v : Procedure.G.vertex) = r v |> Option.map (fun s -> sum s) in
  let p = Program.proc prog proc_id in
  Trace.with_span ~__FILE__ ~__LINE__ "dot-printer" @@ fun _ ->
  let (module M : Viscfg.ProcPrinter) = Viscfg.dot_labels label in
  Option.iter (fun g -> M.fprint_graph fmt g) (Procedure.graph p)

let transform (prog : Program.t) =
  (*
  let g = IDEGraph.create prog `Backwards in
  CCIO.with_out "idegraph.dot" (fun s ->
      IDEGraph.Vis.fprint_graph (Format.of_chan s) g);*)
  let summary, r = IDELiveAnalysis.solve `Backwards prog in
  ID.Map.to_iter prog.procs
  |> Iter.iter (fun (proc, proc_n) ->
      let n = ID.to_string proc in
      CCIO.with_out
        ("idelive" ^ n ^ ".dot")
        (fun s ->
          print_live_vars_dot IDELiveAnalysis.show_summary
            (summary ~proc_id:proc) (Format.of_chan s) prog proc);
      CCIO.with_out
        ("idelive-const" ^ n ^ ".dot")
        (fun s ->
          print_live_vars_dot show_state (r ~proc_id:proc) (Format.of_chan s)
            prog proc));
  prog

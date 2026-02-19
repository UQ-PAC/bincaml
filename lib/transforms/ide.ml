(** Prototype IDE solver: proof of concept for the design for a generic ish ide
    solver.

    WARN: the implemented live variables analysis here is not correct and the
    solver is likely wrong; particularly with regard to context sensitivity *)

open Lang
open Containers
open Common

type call_info = {
  rhs : (Var.t * Expr.BasilExpr.t) list;
  lhs : (Var.t * Var.t) list;
  call_from : Program.stmt; (* stmt must be variable Instr_Call*)
}
[@@deriving eq, ord, show { with_path = false }]
(** (target.formal_in, rhs arg) assignment to call formal params *)

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

module IDEGraph = struct
  module Vert = struct
    include Loc
  end

  open Vert

  module Edge = struct
    type t =
      | Stmts of Var.t Block.phi list * Program.stmt list
      | InterCall of call_info
      | InterReturn of call_info
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

  let push_edge (ending : Loc.t) (g : bstate) =
    match g with
    | { graph; last_vert; stmts } ->
        let phi, stmts = (fst stmts, List.rev (snd stmts)) in
        let e1 = (last_vert, Edge.Stmts (phi, stmts), ending) in
        { graph = GB.add_edge_e graph e1; stmts = ([], []); last_vert = ending }

  let add_call p (st : bstate) (origin : stmt_id) (callstmt : Program.stmt) =
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
    let g = push_edge (CallSite origin) st in
    let graph = g.graph in
    (*let graph =
      GB.add_edge_e graph (CallSite origin, Call callstmt, AfterCall origin)
    in*)
    let call_entry = IntraVertex { proc_id = target; v = Entry } in
    let call_return = IntraVertex { proc_id = target; v = Return } in
    let graph =
      GB.add_edge_e graph
        ( CallSite origin,
          InterCall { rhs; lhs; call_from = callstmt },
          call_entry )
    in
    let graph =
      GB.add_edge_e graph
        ( call_return,
          InterReturn { lhs; rhs; call_from = callstmt },
          AfterCall origin )
    in
    { g with graph }

  let proc_graph prog g p =
    let proc_id = Procedure.id p in
    let add_block_edge b graph =
      match b with
      | v1, Procedure.Edge.Jump, v2 ->
          GB.add_edge_e g
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
              last_vert = IntraVertex { proc_id; v = Begin block };
              stmts = (b.phis, []);
            }
          in
          Block.stmts_iter_i b
          |> Iter.fold
               (fun st (i, s) ->
                 let stmt_id : Loc.stmt_id = { proc_id; block; offset = i } in
                 match s with
                 | Stmt.Instr_Call _ as c -> add_call prog st stmt_id c
                 | stmt ->
                     { st with stmts = (fst st.stmts, stmt :: snd st.stmts) })
               is
          |> push_edge (IntraVertex { proc_id; v = End block })
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
    Procedure.graph p
    |> Option.map (fun procg -> Procedure.G.fold_edges_e add_block_edge procg g)
    |> Option.get_or ~default:g

  let proc_vertices p =
    let proc_id = Procedure.id p in
    let intra_verts =
      Option.to_iter (Procedure.graph p)
      |> Iter.flat_map (fun graph ->
          Procedure.G.fold_vertex
            (fun v acc -> Iter.cons (Loc.IntraVertex { proc_id; v }) acc)
            graph Iter.empty)
    in
    let b =
      Procedure.blocks_to_list p |> List.to_iter
      |> Iter.flat_map (function
        | Procedure.Vert.Begin block, (b : Program.bloc) ->
            Block.stmts_iter_i b
            |> Iter.flat_map (fun (i, s) ->
                let stmt_id : Loc.stmt_id = { proc_id; block; offset = i } in
                match s with
                | Stmt.Instr_Call _ ->
                    Loc.(Iter.doubleton (AfterCall stmt_id) (CallSite stmt_id))
                | _ -> Iter.empty)
        | _, _ -> Iter.empty)
    in
    Iter.append intra_verts b

  let create (prog : Program.t) =
    ID.Map.to_iter prog.procs |> Iter.map snd
    |> Iter.fold (fun g p -> proc_graph prog g p) (GB.empty ())

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
end

module type Domain = sig
  include ORD_TYPE

  val join : t -> t -> t
  val bottom : t

  (*val eval : (Var.t -> t option) -> Expr.BasilExpr.t -> t*)
  (*val transfer : (Var.t -> t option) -> Program.stmt -> (Var.t * t) Iter.t*)
end

type 'a state_update = (Var.t * 'a) Iter.t

module type IDEDomain = sig
  include ORD_TYPE
  module Const : Domain

  val identity : Var.t -> t
  val compose : (Var.t -> t) -> t -> t
  val join : t -> t -> t
  val eval : Expr.BasilExpr.t -> t
  val bottom : t

  val compose_call : (Var.t -> t) -> call_info -> t state_update
  (** edge calling a procedure *)

  val compose_return : (Var.t -> t) -> call_info -> t state_update
  (** edge return to after a call *)

  val transfer : Program.stmt -> t state_update
  (** update the state for a program statement *)

  val transfer_const :
    (Var.t -> Const.t) -> (Var.t * t) Iter.t -> Const.t state_update
  (** update the constant state for each edge in the microfunction *)
end

module IDELive = struct
  module Const = struct
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

  let show_const_state s =
    s
    |> Iter.filter_map (function c, true -> Some c | _ -> None)
    |> Iter.to_string ~sep:", " (fun v -> Var.to_string v)

  open Const

  type t = Live | Dead | CondLive of Var.t [@@deriving eq, ord]

  let bottom = Dead

  let show v =
    match v with
    | Live -> "Live"
    | Dead -> "Dead"
    | CondLive v -> Var.to_string v

  let pp fmt v = Format.pp_print_string fmt (show v)
  let identity v = CondLive v

  (** compose (\lambda v . a) (\lambda v . b) *)
  let compose read b =
    match b with
    | Live -> Live
    | Dead -> Dead
    | CondLive v1 -> (
        match read v1 with
        | Live -> Live
        | Dead -> Dead
        | CondLive v2 -> CondLive v2)
  (** not representible *)

  let join a b =
    match (a, b) with
    | _, Live -> Live
    | Live, _ -> Live
    | CondLive v1, CondLive v2 when Var.equal v1 v2 -> CondLive v1
    | CondLive _, CondLive _ -> Live
    | Dead, CondLive v -> CondLive v
    | CondLive v, Dead -> CondLive v
    | Dead, Dead -> Dead

  let eval e =
    let free = Expr.BasilExpr.free_vars_iter e in
    if Iter.length free = 1 then CondLive (Iter.head_exn free) else Live

  let compose_call read (c : call_info) =
    Iter.of_list c.rhs
    |> Iter.flat_map (fun (formal, e) ->
        Expr.BasilExpr.free_vars_iter e |> Iter.map (fun fv -> (formal, fv)))
    |> Iter.map (fun (formal, v) ->
        ( v,
          match read v with
          | Live -> Live
          | Dead -> Dead
          | CondLive v when Var.is_global v -> CondLive v
          | CondLive _ -> Live ))
    |> Iter.group_by ~eq:(fun a b -> Var.equal (fst a) (fst b))
    |> Iter.map (function
      | [ a ] -> a
      | a :: tl -> (fst a, Live)
      | [] -> failwith "unreachable")
    |> Iter.append
         (Iter.of_list c.lhs |> Iter.map (fun (lhs, rhs) -> (lhs, Dead)))

  let compose_return read (c : call_info) =
    Iter.of_list c.lhs
    |> Iter.map (fun (lhs, rhs) ->
        let mf =
          match read lhs with
          | Live -> Live
          | Dead -> Dead
          | CondLive v when Var.is_global v -> CondLive v
          | CondLive _ -> Live
        in
        (rhs, mf))
    |> Iter.append
         (Iter.of_list c.lhs |> Iter.map (fun (lhs, rhs) -> (lhs, Dead)))

  let transfer s =
    let open Livevars in
    let open Stmt in
    let assigned = Stmt.assigned VarSet.empty s |> VarSet.to_iter in
    let read = Stmt.free_vars VarSet.empty s |> VarSet.to_iter in
    let rhs =
      match s with
      | Instr_Load _ | Instr_Store _ | Instr_Assert _ | Instr_Assume _
      | Instr_IntrinCall _ | Instr_IndirectCall _ ->
          Iter.map (fun v -> (v, Live)) read
      | Instr_Call _ -> failwith "unreachable"
      | Instr_Assign assigns ->
          List.to_iter assigns
          |> Iter.flat_map (fun (l, r) ->
              Iter.cons (l, Dead)
                (Expr.BasilExpr.free_vars_iter r
                |> Iter.map (fun rv -> (rv, CondLive l))))
    in
    Iter.append rhs (Iter.map (fun v -> (v, Dead)) assigned)

  let transfer_const (read : Var.t -> Const.t) (es : (Var.t * t) Iter.t) :
      (Var.t * Const.t) Iter.t =
    es
    |> Iter.map (fun (v, e) ->
        (v, match e with Live -> true | Dead -> false | CondLive v -> read v))
end

(** FIXME:
    - properly handle global variables / local variables across procedure calls;
      procedure summaries should be in terms of globals and formal paramters
      only ; composition across calls should include the globals
    - phis *)

module IDE (D : IDEDomain) = struct
  type summary = D.t VarMap.t [@@deriving eq, ord]
  (** Edge function type: map from variables to lambda functions of at most one
      other variable (implicit)

      Non membership in the map means v -> \l l . bot *)

  let show_summary v =
    VarMap.to_iter v
    |> Iter.to_string ~sep:", " (fun (v, i) ->
        Var.to_string v ^ "->" ^ D.show i)

  type constant_state = D.Const.t VarMap.t [@@deriving eq, ord]

  let empty_summary = VarMap.empty

  (** composition of an assignment var := mfun', where var |-> mfun in st: i.e.
      becomes compose mfun compose mfun' *)
  let compose_assigns st1 st vars =
    Iter.fold
      (fun acc (v, mf) ->
        let r = D.compose (fun v -> VarMap.get_or ~default:D.bottom v st1) mf in
        if D.equal r D.bottom then VarMap.remove v acc else VarMap.add v r acc)
      st vars

  let update_state st1 st vars =
    Iter.fold
      (fun acc (v, mf) ->
        if D.equal mf D.bottom then VarMap.remove v acc else VarMap.add v mf acc)
      st vars

  let join_summaries a b =
    (* keeps everything present in a and not b, does that make sense?*)
    VarMap.union (fun v a b -> Some (D.join a b)) a b

  let join_constant_summary (s0 : constant_state) (s1 : constant_state) :
      constant_state =
    (* keeps everything present in a and not b, does that make sense?*)
    VarMap.union (fun v a b -> Some (D.Const.join a b)) s0 s1

  (* compose bot f = f ? *)
  let compose_state_updates (updates : D.t state_update) st1 st =
    compose_assigns st1 st updates

  let direction : [ `Forwards | `Backwards ] = `Backwards

  let proc_entry (prog : Program.t) (proc : Program.proc) =
    let globals =
      prog.globals |> Hashtbl.to_list |> List.map snd
      |> List.map (fun v -> (v, D.identity v))
    in
    let locals = Procedure.formal_in_params proc in
    let locals =
      StringMap.bindings locals |> List.map snd
      |> List.map (fun v -> (v, D.identity v))
    in
    globals @ locals

  let proc_return (prog : Program.t) (proc : Program.proc) =
    let globals =
      prog.globals |> Hashtbl.to_list |> List.map snd
      |> List.map (fun v -> (v, D.identity v))
    in
    let locals = Procedure.formal_out_params proc in
    let locals =
      StringMap.to_list locals |> List.map snd
      |> List.map (fun v -> (v, D.identity v))
    in
    globals @ locals

  let tf_phis phis : (Var.t * D.t) Iter.t = Iter.empty

  type edge = Loc.t * IDEGraph.Edge.t * Loc.t

  let tf_edge_phase_2 st summary globals edge =
    let open IDEGraph.Edge in
    let read v = VarMap.get_or ~default:D.Const.bottom v st in
    let update k v st =
      if D.Const.equal D.Const.bottom v then VarMap.remove k st
      else VarMap.add k v st
    in
    match IDEGraph.G.E.label edge with
    | Stmts (phi, bs) ->
        let updates = D.transfer_const read (VarMap.to_iter summary) in
        let st' = Iter.fold (fun m (v, t) -> update v t m) st updates in
        st'
    | InterCall args ->
        let args =
          List.to_iter args.rhs
          |> Iter.map (function formal, _ -> formal)
          |> Iter.append globals
          |> Iter.map (fun v -> (v, VarMap.get_or ~default:D.bottom v summary))
        in
        let updates = D.transfer_const read args in
        let st' = Iter.fold (fun m (v, t) -> update v t m) st updates in
        st'
    | InterReturn args ->
        let args =
          List.to_iter args.rhs
          |> Iter.map (function formal, _ -> formal)
          |> Iter.append globals
          |> Iter.map (fun v -> (v, VarMap.get_or ~default:D.bottom v summary))
        in
        let updates = D.transfer_const read args in
        let st' = Iter.fold (fun m (v, t) -> update v t m) st updates in
        st'
    | Nop -> st

  let tf_edge_phase_1 dir globals get_summary st edge =
    let open IDEGraph.Edge in
    let orig, target =
      match (dir, edge) with
      | `Forwards, (a, _, b) -> (a, b)
      | `Backwards, (a, _, b) -> (b, a)
    in
    match IDEGraph.G.E.label edge with
    | Stmts (phi, bs) -> (
        let stmts st =
          match dir with
          | `Forwards ->
              List.fold_left
                (fun st s -> compose_state_updates (D.transfer s) st st)
                st bs
          | `Backwards ->
              List.fold_right
                (fun s st -> compose_state_updates (D.transfer s) st st)
                bs st
        in
        let phis st = compose_state_updates (tf_phis phi) st st in
        match dir with
        | `Forwards -> phis (stmts st)
        | `Backwards -> stmts (phis st))
    | InterCall args ->
        let target = get_summary target in
        update_state st target
          (D.compose_call
             (fun v -> VarMap.get_or v ~default:D.bottom target)
             args)
        |> compose_state_updates
             (globals |> Iter.map (fun v -> (v, D.identity v)))
             st
    | InterReturn args ->
        let target = get_summary target in
        update_state st target
          (D.compose_return
             (fun v -> VarMap.get_or ~default:D.bottom v target)
             args)
        |> compose_state_updates
             (globals |> Iter.map (fun v -> (v, D.identity v)))
             st
    | Nop -> st

  module LM = Map.Make (Loc)

  let phase1_solve order dir graph globals default =
    (* FIXME: this doesn't maintain context sensitivity because there is only one edgefunction
       for each procedure entry, therefore joining all the contexts*)
    Trace_core.with_span ~__FILE__ ~__LINE__ "ide-phase1" @@ fun _ ->
    let module Q = IntPQueue.Plain in
    let (worklist : edge Q.t) = Q.create () in
    let summaries : (Loc.t, summary) Hashtbl.t = Hashtbl.create 100 in
    let get_summary loc = Hashtbl.get summaries loc |> Option.get_or ~default in
    let priority (edge : edge) =
      match dir with
      | `Forwards -> ( match edge with l, _, _ -> LM.find l order)
      | `Backwards -> ( match edge with _, _, l -> LM.find l order)
    in
    IDEGraph.G.fold_edges_e (fun e a -> Q.add worklist e (priority e)) graph ();
    while not (Q.is_empty worklist) do
      let (p : edge) = Q.extract worklist |> Option.get_exn_or "queue empty" in
      let st, vend, ost', siblings =
        match (p, dir) with
        | (b, _, e), `Forwards ->
            (get_summary b, e, get_summary e, IDEGraph.G.pred graph e)
        | (b, _, e), `Backwards ->
            (get_summary e, b, get_summary b, IDEGraph.G.succ graph b)
      in
      let st' = tf_edge_phase_1 dir globals get_summary st p in
      let st' = VarMap.filter (fun v i -> not (D.equal D.bottom i)) st' in
      let st' =
        if List.length siblings > 1 then join_summaries ost' st' else st'
      in
      if not (equal_summary ost' st') then (
        Hashtbl.add summaries vend st';
        let succ =
          match dir with
          | `Forwards -> IDEGraph.G.succ_e graph vend
          | `Backwards -> IDEGraph.G.pred_e graph vend
        in
        List.iter (fun v -> Q.add worklist v (priority v)) succ;
        ())
    done;
    summaries

  let phase2_solve order dir graph globals
      (summaries : (Loc.t, summary) Hashtbl.t) =
    (* FIXME: use summaries ; propertly evaluate call edges first then fill in between*)
    Trace_core.with_span ~__FILE__ ~__LINE__ "ide-phase2" @@ fun _ ->
    let module Q = IntPQueue.Plain in
    let (worklist : edge Q.t) = Q.create () in
    let constants : (Loc.t, constant_state) Hashtbl.t = Hashtbl.create 100 in
    let get_st l = Hashtbl.get_or constants l ~default:VarMap.empty in
    let priority (edge : edge) =
      match dir with
      | `Forwards -> ( match edge with l, _, _ -> LM.find l order)
      | `Backwards -> ( match edge with _, _, l -> LM.find l order)
    in
    let get_summary loc =
      Hashtbl.get summaries loc |> function
      | Some e -> e
      | None ->
          print_endline @@ "summary undefined " ^ Loc.show loc;
          VarMap.empty
    in
    IDEGraph.G.fold_edges_e (fun e a -> Q.add worklist e (priority e)) graph ();
    while not (Q.is_empty worklist) do
      let (p : edge) = Q.extract worklist |> Option.get_exn_or "queue empty" in
      let b, e, summary, st, ost', siblings =
        match (p, dir) with
        | (b, _, e), `Forwards ->
            (b, e, get_summary b, get_st b, get_st e, IDEGraph.G.pred graph e)
        | (b, _, e), `Backwards ->
            (e, b, get_summary e, get_st e, get_st b, IDEGraph.G.succ graph b)
      in
      let st' = tf_edge_phase_2 st summary globals p in
      let st' =
        if List.length siblings > 1 then join_constant_summary st' ost' else st'
      in
      if not (equal_constant_state ost' st') then (
        Hashtbl.add constants e st';
        let succ =
          match dir with
          | `Forwards -> IDEGraph.G.succ_e graph e
          | `Backwards -> IDEGraph.G.pred_e graph e
        in
        List.iter (fun v -> Q.add worklist v (priority v)) succ;
        ())
    done;
    constants

  let query (r : (Loc.t, 'a VarMap.t) Hashtbl.t) ~proc_id vert =
    Hashtbl.get r (IntraVertex { proc_id; v = vert })

  let solve dir (prog : Program.t) =
    Trace_core.with_span ~__FILE__ ~__LINE__ "ide-solve" @@ fun _ ->
    let globals = prog.globals |> Var.Decls.to_iter |> Iter.map snd in
    let graph = IDEGraph.create prog in
    let order =
      (match dir with
        | `Forwards -> Iter.from_iter (fun f -> IDEGraph.Top.iter f graph)
        | `Backwards -> Iter.from_iter (fun f -> IDEGraph.RevTop.iter f graph))
      |> Iter.zip_i
      |> Iter.map (fun (i, v) -> (v, i))
      |> LM.of_iter
    in
    let summary = phase1_solve order dir graph globals VarMap.empty in
    (query @@ summary, query @@ phase2_solve order dir graph globals summary)

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

let show_const_summary (v : IDELiveAnalysis.constant_state) =
  VarMap.to_iter v |> IDELive.show_const_state

let print_live_vars_dot sum r fmt prog proc_id =
  let label (v : Procedure.G.vertex) = r v |> Option.map (fun s -> sum s) in
  let p = Program.proc prog proc_id in
  Trace_core.with_span ~__FILE__ ~__LINE__ "dot-priner" @@ fun _ ->
  let (module M : Viscfg.ProcPrinter) = Viscfg.dot_labels (fun v -> label v) in
  Option.iter (fun g -> M.fprint_graph fmt g) (Procedure.graph p)

let transform (prog : Program.t) =
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
          print_live_vars_dot show_const_summary (r ~proc_id:proc)
            (Format.of_chan s) prog proc));
  prog

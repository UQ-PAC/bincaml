open Lang
open Containers
open Common

type call_info = {
  args : (Var.t * Expr.BasilExpr.t) list;
  call_from : Program.stmt; (* stmt must be variable Instr_Call*)
}
[@@deriving eq, ord, show { with_path = false }]
(** (target.formal_in, rhs arg) assignment to call formal params *)

type return_info = {
  args : (Var.t * Var.t) list;
  return_to_after : Program.stmt; (* stmt must be variable Instr_Call*)
}
[@@deriving eq, ord, show]
(** (call lhs out, target formal_out) assignment of returns to call lhs *)

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
      | InterReturn of return_info
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
      | Stmt.(Instr_Call { lhs; procid; args }) -> begin
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
        end
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
          InterCall { args = rhs; call_from = callstmt },
          call_entry )
    in
    let graph =
      GB.add_edge_e graph
        ( call_return,
          InterReturn { args = lhs; return_to_after = callstmt },
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
    let intra_verts =
      Procedure.G.fold_vertex
        (fun v acc -> Iter.cons (Loc.IntraVertex { proc_id; v }) acc)
        (Procedure.graph p) Iter.empty
    in
    let g = Iter.fold GB.add_vertex g intra_verts in
    Procedure.G.fold_edges_e add_block_edge (Procedure.graph p) g

  let proc_vertices p =
    let proc_id = Procedure.id p in
    let intra_verts =
      Procedure.G.fold_vertex
        (fun v acc -> Iter.cons (Loc.IntraVertex { proc_id; v }) acc)
        (Procedure.graph p) Iter.empty
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
    module E = G.E

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
  val compose : t -> t -> t
  val join : t -> t -> t
  val eval : Expr.BasilExpr.t -> t
  val bottom : t

  val transfer_call : call_info -> t state_update
  (** edge calling a procedure *)

  val transfer_return : return_info -> t state_update
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
  let compose a b =
    match (a, b) with
    | _, Live -> Live
    | _, Dead -> Dead
    | CondLive v1, CondLive v2 when Var.equal v1 v2 -> CondLive v1
    | CondLive _, CondLive _ -> Live
    | _, CondLive v -> CondLive v
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

  let transfer_call (c : call_info) =
    Iter.of_list c.args |> Iter.map (fun (formal, expr) -> (formal, eval expr))

  let transfer_return (c : return_info) =
    Iter.of_list c.args |> Iter.map (fun (lhs, rhs) -> (rhs, CondLive lhs))

  let transfer s =
    let open Livevars in
    let open Stmt in
    let assigned = Livevars.assigned_stmt V.empty s |> V.to_iter in
    let read = Livevars.free_vars_stmt V.empty s |> V.to_iter in
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
  module VM = Map.Make (Var)

  type summary = D.t VM.t [@@deriving eq, ord]
  (** Edge function type: map from variables to lambda functions of at most one
      other variable (implicit)

      Non membership in the map means v -> \l l . bot *)

  let show_summary v =
    VM.to_iter v
    |> Iter.to_string ~sep:", " (fun (v, i) ->
        Var.to_string v ^ "->" ^ D.show i)

  type constant_state = D.Const.t VM.t [@@deriving eq, ord]

  let empty_summary = VM.empty

  (** compose the summary for all variables in the two summaries *)
  let compose_summaries st st' =
    VM.merge
      (fun v a b ->
        match (a, b) with
        | Some a, Some b -> Some (D.compose a b)
        | Some _, None -> None (* saturating bot *)
        | None, Some _ -> None (* saturatin gbot *)
        | None, None -> None)
      st st'

  (** compose the edge functions for a set of pairs of vars updating the first,
      e.g. v1 := mf2 ~> v1 |-> st1(v) compose st2(v2) *)
  let compose_var_states st vars =
    List.fold_left
      (fun acc (v1, mf1, mf2) -> VM.add v1 (D.compose mf1 mf2) acc)
      st vars

  (** composition of an assignment var := mfun', where var |-> mfun in st: i.e.
      becomes compose mfun compose mfun' *)
  let compose_assigns st vars =
    let updates =
      List.map
        (fun (v, mf) ->
          (v, VM.find_opt v st |> Option.get_or ~default:(D.identity v), mf))
        vars
    in
    compose_var_states st updates

  let join_summaries a b =
    (* keeps everything present in a and not b, does that make sense?*)
    VM.union (fun v a b -> Some (D.join a b)) a b

  let join_constant_summary (s0 : constant_state) (s1 : constant_state) :
      constant_state =
    (* keeps everything present in a and not b, does that make sense?*)
    VM.union (fun v a b -> Some (D.Const.join a b)) s0 s1

  (* compose bot f = f ? *)
  let compose_state_updates (updates : D.t state_update) st =
    Iter.map
      (fun (v, ex) ->
        let e = VM.find_opt v st in
        let c = Option.map (fun e -> D.compose e ex) e in
        let c = Option.get_or ~default:ex c in
        (v, c))
      updates
    |> Iter.fold (fun a (v, c) -> VM.add v c a) st

  let direction : [ `Forwards | `Backwards ] = `Backwards

  let proc_entry (prog : Program.t) (proc : Program.proc) =
    let globals =
      prog.globals |> Hashtbl.to_list |> List.map snd
      |> List.map (fun v -> (v, D.identity v))
    in
    let locals = Procedure.formal_in_params proc in
    let locals =
      StringMap.to_list locals |> List.map snd
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

  let tf_edge_phase_2 st summary edge =
    let open IDEGraph.Edge in
    let read v =
      VM.get v st |> function Some v -> v | None -> D.Const.bottom
    in
    match IDEGraph.G.E.label edge with
    | Stmts (phi, bs) ->
        let updates = D.transfer_const read (VM.to_iter summary) in
        let st' = Iter.fold (fun m (v, t) -> VM.add v t m) st updates in
        st'
    | InterCall args ->
        let args =
          List.map
            (function
              | formal, _ -> (formal, VM.get_or ~default:D.bottom formal summary))
            args.args
        in
        let updates = D.transfer_const read (List.to_iter args) in
        let st' = Iter.fold (fun m (v, t) -> VM.add v t m) st updates in
        st'
    | InterReturn args ->
        let args =
          List.map
            (function
              | formal, _ -> (formal, VM.get_or ~default:D.bottom formal summary))
            args.args
        in
        let updates = D.transfer_const read (List.to_iter args) in
        let st' = Iter.fold (fun m (v, t) -> VM.add v t m) st updates in
        st'
    | Nop -> st

  let tf_edge_phase_1 dir get_summary st edge =
    let open IDEGraph.Edge in
    let orig, target =
      match (dir, edge) with
      | `Forwards, (a, _, b) -> (a, b)
      | `Backwards, (a, _, b) -> (b, a)
    in

    match IDEGraph.G.E.label edge with
    | Stmts (phi, bs) -> begin
        let stmts st =
          match dir with
          | `Forwards ->
              List.fold_left
                (fun st s -> compose_state_updates (D.transfer s) st)
                st bs
          | `Backwards ->
              List.fold_right
                (fun s st -> compose_state_updates (D.transfer s) st)
                bs st
        in
        let phis = compose_state_updates (tf_phis phi) in
        match dir with
        | `Forwards -> phis (stmts st)
        | `Backwards -> stmts (phis st)
      end
    | InterCall args ->
        let target = get_summary target in
        let c = compose_state_updates (D.transfer_call args) target in
        let args =
          List.map
            (function
              | formal, _ -> (formal, VM.get_or ~default:D.bottom formal c))
            args.args
        in
        compose_assigns st args
    | InterReturn args ->
        let target = get_summary target in
        let c = compose_state_updates (D.transfer_return args) target in
        let args =
          List.map
            (function
              | formal, _ -> (formal, VM.get_or ~default:D.bottom formal c))
            args.args
        in
        compose_assigns st args
    | Nop -> st

  module LM = Map.Make (Loc)

  let naive_summary_worklist order dir graph default edge_transfer_function =
    (*TODO: abstract the graph iteration direction stuff *)
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

      let n = Loc.show vend in
      Trace.with_span ~__FILE__ ~__LINE__ ("ide-phase1" ^ n) @@ fun _ ->
      let st' = edge_transfer_function get_summary st p in
      let st' = VM.filter (fun v i -> not (D.equal D.bottom i)) st' in

      let st' =
        if List.length siblings > 1 then join_summaries ost' st' else st'
      in

      if not (equal_summary ost' st') then begin
        Hashtbl.add summaries vend st';
        let succ =
          match dir with
          | `Forwards -> IDEGraph.G.succ_e graph vend
          | `Backwards -> IDEGraph.G.pred_e graph vend
        in
        (*print_endline @@ show_summary st';*)
        List.iter (fun v -> Q.add worklist v (priority v)) succ;
        ()
      end
    done;
    summaries

  let phase1_solve order dir graph default =
    Trace.with_span ~__FILE__ ~__LINE__ "ide-phase1" @@ fun _ ->
    naive_summary_worklist order dir graph default (tf_edge_phase_1 dir)

  let phase2_solve order dir graph (summaries : (Loc.t, summary) Hashtbl.t) =
    let module Q = IntPQueue.Plain in
    Trace.with_span ~__FILE__ ~__LINE__ "ide-phase2" @@ fun _ ->
    let (worklist : edge Q.t) = Q.create () in
    let constants : (Loc.t, constant_state) Hashtbl.t = Hashtbl.create 100 in
    let get_st l = Hashtbl.get_or constants l ~default:VM.empty in
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
          VM.empty
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
      let n = Loc.show e in
      Trace.with_span ~__FILE__ ~__LINE__ ("ide-phase2" ^ n) @@ fun _ ->
      let st' = tf_edge_phase_2 st summary p in
      let st' =
        if List.length siblings > 1 then join_constant_summary st' ost' else st'
      in
      if not (equal_constant_state ost' st') then begin
        Hashtbl.add constants e st';
        let succ =
          match dir with
          | `Forwards -> IDEGraph.G.succ_e graph e
          | `Backwards -> IDEGraph.G.pred_e graph e
        in
        List.iter (fun v -> Q.add worklist v (priority v)) succ;
        ()
      end
    done;
    constants

  let query (r : (Loc.t, 'a VM.t) Hashtbl.t) ~proc_id vert =
    Hashtbl.get r (IntraVertex { proc_id; v = vert })

  let solve dir prog =
    Trace.with_span ~__FILE__ ~__LINE__ "ide-solve" @@ fun _ ->
    let graph = IDEGraph.create prog in
    let order =
      (match dir with
        | `Forwards -> Iter.from_iter (fun f -> IDEGraph.Top.iter f graph)
        | `Backwards -> Iter.from_iter (fun f -> IDEGraph.RevTop.iter f graph))
      |> Iter.zip_i
      |> Iter.map (fun (i, v) -> (v, i))
      |> LM.of_iter
    in
    let summary = phase1_solve order dir graph VM.empty in
    (query @@ summary, query @@ phase2_solve order dir graph summary)

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
  IDELiveAnalysis.VM.to_iter v |> IDELive.show_const_state

let print_live_vars_dot sum r fmt prog proc_id =
  let label (v : Procedure.G.vertex) = r v |> Option.map (fun s -> sum s) in
  let p = Program.proc prog proc_id in
  Trace.with_span ~__FILE__ ~__LINE__ "dot-priner" @@ fun _ ->
  let (module M : Viscfg.ProcPrinter) = Viscfg.dot_labels (fun v -> label v) in
  M.fprint_graph fmt (Procedure.graph p)

let transform (prog : Program.t) =
  let summary, r = IDELiveAnalysis.solve `Backwards prog in
  ()
(*ID.Map.to_iter prog.procs
  |> Iter.iter (fun (proc, proc_n) ->
      let n = ID.to_string proc in
      begin
        CCIO.with_out
          ("idelive" ^ n ^ ".dot")
          (fun s ->
            print_live_vars_dot IDELiveAnalysis.show_summary
              (summary ~proc_id:proc) (Format.of_chan s) prog proc);
        CCIO.with_out
          ("idelive-const" ^ n ^ ".dot")
          (fun s ->
            print_live_vars_dot show_const_summary (r ~proc_id:proc)
              (Format.of_chan s) prog proc)
      end)
    *)

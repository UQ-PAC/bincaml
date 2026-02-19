(** IDE solver *)

open Lang
open Containers
open Common

(* TODO (perf)
   Nop edges create duplicate states that are redundant (we store the same
   state before and after the edge). It may be more efficient to collapse these
   edges somehow. I suspect this won't give a huge performance improvement since
   mose of the time in the solver is spent on evaluating transfer functions. *)
(* TODO write a sample forwards analysis to test forwards correctness *)
(* TODO perhaps rewrite both phases to solve like how chaotic iteration is
   implemented? I tried this already once for phase 1 and the bottleneck seemed
   to be on wto creation :( *)

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

  let hash (l : t) = Hashtbl.hash l
end

type ret_info = {
  rhs : (Var.t * Expr.BasilExpr.t) list;
  lhs : (Var.t * Var.t) list;
  call_from : Program.stmt; (* stmt must be variable Instr_Call*)
  caller : ID.t;
  callee : ID.t;
}
[@@deriving eq, ord, show { with_path = false }]
(** (target.formal_in, rhs arg) assignment to call formal params *)

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

type stub_info = { formal_in : Var.t list; globals : Var.t list }
[@@deriving eq, ord, show { with_path = false }]

module LSet = Set.Make (Loc)
module LM = Map.Make (Loc)

module type Lattice = sig
  include ORD_TYPE

  val join : t -> t -> t
  val bottom : t
end

(** An IDE domain where values are edge functions *)
module type IDEDomain = sig
  include Lattice
  module Data : Map.OrderedType

  module DL : sig
    type t = Label of Data.t | Lambda [@@deriving eq, ord, show]
  end

  type 'a state_update = (DL.t * 'a) Iter.t

  val direction : [ `Forwards | `Backwards ]
  (** The direction this analysis should be performed in *)

  module Value : Lattice
  (** The underlying lattice the edge functions operate on *)

  val identity : t
  (** identity edge function *)

  val compose : t -> t -> t
  (** the composite of edge functions *)

  val eval : t -> Value.t -> Value.t
  (** evaluate an edge function *)

  val transfer_call : call_info -> DL.t -> t state_update
  (** edge calling a procedure (to the return block when backwards) *)

  val transfer_return : ret_info -> DL.t -> t state_update
  (** edge return from a call (from the entry block when backwards) *)

  val transfer_call_to_aftercall : call_info -> DL.t -> t state_update
  (** edge from a call to its aftercall statement (or reversed when backwards)
  *)

  val transfer_stub : stub_info -> DL.t -> t state_update
  (** edge from entry to exit (or reversed when backwards) of stub procedure *)

  val transfer : Program.stmt -> DL.t -> t state_update
  (** update the state for a program statement *)

  val transfer_phi : Var.t Block.phi -> DL.t -> t state_update
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
      | InterReturn of ret_info
      | Call of call_info
      | StubProc of stub_info
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
    let call_entry = IntraVertex { proc_id = target; v = Entry } in
    let call_return = IntraVertex { proc_id = target; v = Return } in
    let call_entry, call_return =
      match dir with
      | `Forwards -> (call_entry, call_return)
      | `Backwards -> (call_return, call_entry)
    in
    let ret_info = { lhs; rhs; call_from = callstmt; caller; callee } in
    let call_info =
      {
        rhs;
        lhs;
        call_from = callstmt;
        aftercall = origin;
        caller;
        callee;
        ret = ret_info;
      }
    in
    let graph =
      GB.add_edge_e graph (CallSite origin, InterCall call_info, call_entry)
    in
    let graph =
      GB.add_edge_e graph (CallSite origin, Call call_info, AfterCall origin)
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
                 | Stmt.Instr_Call _ -> add_call dir prog st stmt_id s
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
    |> Option.get_lazy (fun _ ->
        let formal_in =
          Procedure.formal_in_params p |> StringMap.bindings |> List.map snd
        in
        let globals = prog.globals |> Hashtbl.to_list |> List.map snd in
        add_edge_e_dir dir g
          ( IntraVertex { proc_id; v = Entry },
            StubProc { formal_in; globals },
            IntraVertex { proc_id; v = Return } ))

  let create (prog : Program.t) dir =
    ID.Map.to_iter prog.procs |> Iter.map snd
    |> Iter.fold (fun g p -> proc_graph prog g p dir) (GB.empty ())

  (** a table giving, to each procedure, all of its call sites to other
      procedures *)
  let proc_call_table dir g (prog : Program.t) =
    let tbl = Hashtbl.create 100 in
    G.iter_vertex
      (fun l ->
        match l with
        | CallSite s ->
            let cur = Hashtbl.get_or tbl s.proc_id ~default:Iter.empty in
            Hashtbl.replace tbl s.proc_id (Iter.cons (CallSite s) cur)
        | _ -> ())
      g;
    tbl

  module Vis = Graph.Graphviz.Dot (struct
    include G
    open G.V
    open G.E

    let graph_attributes _ = []

    let vertex_name (v : Loc.t) =
      match v with
      | IntraVertex { proc_id; v } ->
          "\""
          ^ (match v with
            | Begin _ -> Procedure.Vert.block_id_string v
            | End _ -> Procedure.Vert.block_id_string v
            | _ -> Procedure.Vert.block_id_string v)
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
            (match v with
              | Begin _ -> "Begin " ^ Procedure.Vert.block_id_string v
              | End _ -> "End " ^ Procedure.Vert.block_id_string v
              | _ -> Procedure.Vert.block_id_string v)
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
        | _, StubProc _, _ -> "StubProc"
      in
      [ `Label l ]

    let default_edge_attributes _ = []
    let get_subgraph _ = None
  end)
end

module IDE (D : IDEDomain) = struct
  module DL = D.DL
  module DlMap = Map.Make (DL)
  module DataMap = Map.Make (D.Data)

  type summary = D.t DlMap.t DlMap.t [@@deriving eq, ord]
  (** A summary associated to a location gives us all edge functions from the
      start/end of the procedure this location is in, to this location.

      Non membership in the map means v v' -> const bottom *)

  let dir = D.direction

  open DL

  let show_summary v =
    DlMap.to_iter v
    |> Iter.flat_map (fun (d1, m) ->
        DlMap.to_iter m |> Iter.map (fun x -> (d1, x)))
    |> Iter.to_string ~sep:", " (fun (v, (v', i)) ->
        "(" ^ DL.show v ^ "," ^ DL.show v' ^ "->" ^ D.show i ^ ")")

  let empty_summary = DlMap.empty

  type analysis_state = D.Value.t DataMap.t [@@deriving eq, ord]

  module Worklist (D : Heap.TOTAL_ORD) = struct
    module PQ = Heap.Make_from_compare (D)

    type t = PQ.t ref

    let create : t = ref PQ.empty
    let cardinal (q : t) = PQ.size !q
    let non_empty (q : t) = not @@ PQ.is_empty !q
    let add (q : t) d = q := PQ.add !q d

    let pop (q : t) =
      let q', d = PQ.take_exn !q in
      q := q';
      while non_empty q && D.compare (PQ.find_min_exn !q) d = 0 do
        q := fst @@ PQ.take_exn !q
      done;
      d
  end

  let join_state_with st v x =
    let j =
      DataMap.get v st
      |> Option.map (D.Value.join x)
      |> Option.get_or ~default:x
    in
    DataMap.add v j st

  let join_add m d e =
    let j = D.join e (DlMap.get_or d m ~default:D.bottom) in
    if not (D.equal j D.bottom) then DlMap.add d j m else m

  let ( @. ) = D.compose

  (** Determine composites of edge functions through an intravertex block *)
  let tf_stmts phi bs i =
    let stmts i =
      List.fold_left
        (fun om stmt ->
          DlMap.fold
            (fun d2 e1 m ->
              D.transfer stmt d2
              |> Iter.fold (fun m (d3, e2) -> join_add m d3 (e2 @. e1)) m)
            om DlMap.empty)
        (Iter.fold (fun m (d, e) -> join_add m d e) DlMap.empty i)
        bs
      |> DlMap.to_iter
    in
    (* TODO this might be more imprecise than joining on the opposite side of the phi node
       https://link.springer.com/chapter/10.1007/978-3-642-11970-5_8 reckons so *)
    (* TODO this also might be really inefficient or wrong it hasn't been tested *)
    let phis i =
      List.fold_left
        (fun i p ->
          Iter.flat_map
            (fun (d2, e1) ->
              D.transfer_phi p d2 |> Iter.map (fun (d3, e2) -> (d3, e2 @. e1)))
            i)
        i phi
    in
    match dir with `Forwards -> stmts (phis i) | `Backwards -> phis (stmts i)

  type edge = Loc.t * IDEGraph.Edge.t * Loc.t

  let dldlget d1 d2 summary =
    DlMap.get d1 summary
    |> Option.flat_map (DlMap.get d2)
    |> Option.get_or ~default:D.bottom

  (** Obtain all out edges following the ide edge (d1, e1, d2) after the
      IDEGraph edge e. *)
  let phase1_transfer entry2call entry2exit d1 d2 e1 e =
    match IDEGraph.G.E.label e with
    | Stmts (phi, bs) ->
        tf_stmts phi bs (Iter.singleton (d2, e1))
        |> Iter.map (fun (d3, e) -> ((d1, d3), e))
    | InterCall callinfo ->
        D.transfer_call callinfo d2
        |> Iter.flat_map (fun (d3, e2) ->
            (* Update the entry to call entry cache *)
            let k = (callinfo.caller, d3, callinfo.callee) in
            Hashtbl.get_or entry2call k ~default:DlMap.empty
            |> DlMap.add d1 (e2 @. e1)
            |> Hashtbl.replace entry2call k;
            (* Add the callee to the worklist with an id edge at its entry
               so that the entry_to_exit cache eventually summarises it. *)
            Iter.singleton ((d3, d3), D.identity))
    | InterReturn retinfo ->
        (* Since we have reached the return block of a procedure, we
           have a complete summary of it! Store this in the entry exit cache *)
        let k = (retinfo.callee, d1) in
        Hashtbl.get_or entry2exit k ~default:DlMap.empty
        |> DlMap.add d2 e1
        |> Hashtbl.replace entry2exit k;
        (* If we have an edge from the caller's entry to the callee's
           entry, we can propagate the same big composite as described
           in the InterCall branch.

           Note that we do not propagate to aftercalls of callers if the
           caller never propagated through its own InterCall edge *)
        let k = (retinfo.caller, d1, retinfo.callee) in
        Hashtbl.get entry2call k |> Option.to_iter
        |> Iter.flat_map DlMap.to_iter
        |> Iter.flat_map (fun (d3, e2) ->
            D.transfer_return retinfo d2
            |> Iter.map (fun (d4, e3) -> ((d3, d4), e3 @. e1 @. e2)))
    | Call callinfo ->
        let summarised =
          D.transfer_call callinfo d2
          |> Iter.flat_map (fun (d3, e2) ->
              (* If we have entry to exit edge functions stored, propagate
               the composite of
               1. the edge function from the caller entry to callee entry
               2. edge functions through the callee procedure
               3. edge functions from the return of the callee to the caller *)
              Hashtbl.get entry2exit (callinfo.callee, d3)
              |> Option.to_iter
              |> Iter.flat_map DlMap.to_iter
              |> Iter.flat_map (fun (d4, e3) ->
                  D.transfer_return callinfo.ret d4
                  |> Iter.map (fun (d5, e4) -> ((d1, d5), e4 @. e3 @. e2 @. e1))))
        in
        let direct =
          D.transfer_call_to_aftercall callinfo d2
          |> Iter.map (fun (d3, e2) -> ((d1, d3), e2 @. e1))
        in
        Iter.append summarised direct
    | StubProc stubinfo ->
        D.transfer_stub stubinfo d2
        |> Iter.map (fun (d3, e2) -> ((d1, d3), e2 @. e1))
    | Nop -> Iter.singleton ((d1, d2), e1)

  module P1K = struct
    type t = Loc.t * DL.t * DL.t

    let compare = Ord.triple Loc.compare DL.compare DL.compare
  end

  module W1 = Worklist (P1K)

  (** Propagate summaries into a new location and update the worklist *)
  let propagate worklist summaries summary loc updates =
    Iter.filter_map
      (fun ((d1, d3), e) ->
        let l = dldlget d1 d3 summary in
        let j = D.join l e in
        (not (D.equal l j)) |> flip Option.return_if ((d1, d3), j))
      updates
    |> Iter.fold
         (fun acc ((d1, d3), e) ->
           W1.add worklist (loc, d1, d3);
           let m = DlMap.get_or d1 acc ~default:DlMap.empty in
           DlMap.add d1 (DlMap.add d3 e m) acc)
         summary
    |> Hashtbl.replace summaries loc

  (** Computes a table of summary edge functions

      A summary edge function is an edge function from the start of a procedure
      to some location in the procedure that is equal to the join of all
      composite edge functions through paths to this location. *)
  let phase1_solve start graph globals default =
    Trace_core.with_span ~__FILE__ ~__LINE__ "ide-phase1" @@ fun _ ->
    let worklist = W1.create in
    let summaries : (Loc.t, summary) Hashtbl.t = Hashtbl.create 100 in
    Hashtbl.replace summaries start
      (DlMap.singleton Lambda (DlMap.singleton Lambda D.identity));
    (* Stores edge functions from the first procedure's entry to the second
       procedure's entry, with a fixed dl value at the second procedure *)
    let entry_to_call_entry_cache : (ID.t * DL.t * ID.t, D.t DlMap.t) Hashtbl.t
        =
      Hashtbl.create 100
    in
    (* Stores edge functions from the entry of a procedure to the end of said
       procedure for a given d value at the entry *)
    let entry_to_exit_cache : (ID.t * DL.t, D.t DlMap.t) Hashtbl.t =
      Hashtbl.create 100
    in
    let get_summary loc = Hashtbl.get summaries loc |> Option.get_or ~default in
    W1.add worklist (start, Lambda, Lambda);
    while W1.non_empty worklist do
      let l, d1, d2 = W1.pop worklist in
      let ost = get_summary l in
      let e1 = dldlget d1 d2 ost in
      IDEGraph.G.succ_e graph l |> Iter.of_list
      |> Iter.iter (fun e ->
          let _, _, t = e in
          phase1_transfer entry_to_call_entry_cache entry_to_exit_cache d1 d2 e1
            e
          |> propagate worklist summaries (get_summary t) t)
    done;
    summaries

  let phase2_call_transfer get_summary add_q states calls_table d md e =
    let l, _, target = e in
    match IDEGraph.G.E.label e with
    | InterCall callinfo ->
        let summary = get_summary l in
        DlMap.get d summary |> Iter.of_opt
        |> Iter.flat_map DlMap.to_iter
        |> Iter.flat_map (fun (d2, e1) ->
            D.transfer_call callinfo d2
            |> Iter.map (fun (d3, e2) -> (d3, e2 @. e1)))
        |> Iter.iter (fun (d3, e21) ->
            match d3 with
            | Label v ->
                let st = Hashtbl.get_or states target ~default:DataMap.empty in
                let fd = D.eval e21 md in
                let y = DataMap.get_or v st ~default:D.Value.bottom in
                let j = D.Value.join y fd in
                if not (D.Value.equal j y) then (
                  DataMap.add v (D.Value.join y fd) st
                  |> Hashtbl.replace states target;
                  Hashtbl.get_or calls_table callinfo.callee ~default:Iter.empty
                  |> Iter.iter (fun c -> add_q (c, d3)))
            | _ -> ())
    | _ -> ()

  module P2K = struct
    type t = Loc.t * DL.t

    let compare = Pair.compare Loc.compare DL.compare
  end

  module W2 = Worklist (P2K)

  (** Compute the analysis result using summaries from phase 1 *)
  let phase2_solve prog start_proc graph globals
      (summaries : (Loc.t, summary) Hashtbl.t) =
    Trace_core.with_span ~__FILE__ ~__LINE__ "ide-phase2" @@ fun _ ->
    let states : (Loc.t, analysis_state) Hashtbl.t = Hashtbl.create 100 in
    let get_st l = Hashtbl.get_or states l ~default:DataMap.empty in
    let get_summary loc =
      Hashtbl.get summaries loc |> function
      | Some e -> e
      | None ->
          (*print_endline @@ "summary undefined " ^ Loc.show loc;*)
          DlMap.empty
    in
    (* The first step is to initialise the entry nodes of each procedure with
       their initial value based on the entry procedure being initialised to
       bottom, using the summary functions. This is done by looking at all call
       sites in a procedure and evaluating the composite of the summary to the
       callsite and the transfer of the call edge (and reaching a fixpoint). *)
    let worklist = W2.create in
    let calls_table = IDEGraph.proc_call_table dir graph prog in
    Hashtbl.get_or calls_table start_proc ~default:Iter.empty
    |> Iter.iter (fun l -> W2.add worklist (l, Lambda));
    while W2.non_empty worklist do
      let l, d = W2.pop worklist in
      let ost = get_st l in
      let md =
        match d with
        | Label v -> DataMap.get_or v ost ~default:D.Value.bottom
        | _ -> D.Value.bottom
      in
      IDEGraph.G.succ_e graph l |> Iter.of_list
      |> Iter.iter
           (phase2_call_transfer get_summary
              (fun (c, d) -> W2.add worklist (c, d))
              states calls_table d md)
    done;
    (* We then apply all summary functions to each location to the initial
       values of each procedure *)
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
              | Label v -> DataMap.get_or v pst ~default:D.Value.bottom
              | _ -> D.Value.bottom
            in
            DlMap.iter (fun d2 e ->
                match d2 with
                | Label v ->
                    let st = get_st l in
                    let y = D.eval e x in
                    Hashtbl.replace states l (join_state_with st v y)
                | _ -> ())));
    states

  let query r ~proc_id vert =
    Hashtbl.get r (Loc.IntraVertex { proc_id; v = vert })

  let solve (prog : Program.t) =
    Trace_core.with_span ~__FILE__ ~__LINE__ "ide-solve" @@ fun _ ->
    let globals = prog.globals |> Var.Decls.to_iter |> Iter.map snd in
    let graph = IDEGraph.create prog dir in
    let start =
      match dir with `Forwards -> Loc.Entry | `Backwards -> Loc.Exit
    in
    let start_proc =
      prog.entry_proc |> Option.get_exn_or "Missing entry procedure"
    in
    let summary = phase1_solve start graph globals DlMap.empty in
    ( query @@ summary,
      query @@ phase2_solve prog start_proc graph globals summary )

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

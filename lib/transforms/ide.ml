open Lang
open Containers
open Common

type 'e microfunction = F of 'e | Constant of 'e | ID

type call_info = {
  args : (Var.t * Expr.BasilExpr.t) list;
  call_from : Program.stmt; (* stmt must be variable Instr_Call*)
}
[@@deriving eq, ord, show]
(** (target.formal_in, rhs arg) assignment to call formal params *)

type return_info = {
  args : (Var.t * Var.t) list;
  return_to_after : Program.stmt; (* stmt must be variable Instr_Call*)
}
[@@deriving eq, ord, show]
(** (call lhs out, target formal_out) assignment of returns to call lhs *)

module Loc = struct
  type stmt_id = { proc_id : ID.t; block : ID.t; offset : int }
  [@@deriving eq, ord, show]

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
  val eval : (Var.t -> t option) -> Expr.BasilExpr.t -> t

  val transfer_call : (Var.t -> t option) -> call_info -> t state_update
  (** edge calling a procedure *)

  val transfer_return : (Var.t -> t option) -> return_info -> t state_update
  (** edge return to after a call *)

  val transfer : (Var.t -> t option) -> Program.stmt -> t state_update
  (** update the state for a program statement *)

  val transfer_const :
    (Var.t -> Const.t option) -> (Var.t * t) Iter.t -> Const.t state_update
  (** update the constant state for each edge in the microfunction *)
end

module IDELive : IDEDomain = struct
  module Const : Domain = struct
    type t = bool option [@@deriving eq, ord, show]

    let bottom = None

    let join a b =
      match (a, b) with
      | Some a, Some b when Bool.equal a b -> None
      | Some _, Some _ -> None
      | Some a, None -> Some a
      | None, Some a -> Some a
      | None, None -> None
  end

  type t = Live | Dead | CondLive of Var.t [@@deriving eq, ord, show]

  let identity v = CondLive v

  (** compose (\lambda v . a) (\lambda v . b) *)
  let compose a b =
    match (a, b) with
    | Live, _ -> Live
    | Dead, _ -> Dead
    | CondLive v, Live -> CondLive v
    | CondLive v, Dead -> CondLive v
    | CondLive v1, CondLive v2 when Var.equal v1 v2 -> CondLive v1
    | CondLive _, CondLive _ -> Live
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

  let eval read e =
    let free = Expr.BasilExpr.free_vars_iter e in
    if Iter.length free = 1 then CondLive (Iter.head_exn free) else Live

  let transfer_call read (c : call_info) =
    Iter.of_list c.args
    |> Iter.map (fun (formal, expr) -> (formal, eval read expr))

  let transfer_return read (c : return_info) =
    Iter.of_list c.args |> Iter.map (fun (lhs, rhs) -> (rhs, CondLive lhs))

  let transfer read s =
    let open Livevars in
    let assigned = Livevars.assigned_stmt V.empty s |> V.to_iter in
    let read = Livevars.free_vars_stmt V.empty s |> V.to_iter in
    let rhs =
      match assigned |> Iter.take 2 |> Iter.to_list with
      | h :: [] -> Iter.map (fun r -> (r, CondLive h)) read
      | _ -> Iter.map (fun r -> (r, Live)) read
    in
    Iter.append (Iter.map (fun v -> (v, Dead)) assigned) rhs

  let transfer_const read es = failwith ""
end

module LVD (D : IDEDomain) = struct
  module VM = Map.Make (Var)

  type summary = D.t VM.t [@@deriving eq, ord]
  (** Edge function type: map from variables to lambda functions of at most one
      other variable (implicit)

      Non membership in the map means v -> \l l . bot *)

  type constant_state = D.Const.t VM.t [@@deriving eq, ord]

  let empty_summary = VM.empty

  let eval_constant_summary (state : constant_state) (summary : summary) :
      constant_state =
    failwith "unimplemented"

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

  let tf_phis phis : (Var.t * D.t) Iter.t = failwith "unimplemented"

  (*


  let eval_summary (s : summary) (e : Expr.BasilExpr.t) : D.t =
    failwith "unimplemented"

  let compose_return prog (proc : Program.proc) loc st stmt =
    let rhs =
      Stmt.(
        match stmt with
        | Instr_Return { args } -> args
        | _ -> failwith "not a return")
    in
    StringMap.to_list (Procedure.formal_out_params proc)
    |> List.map (fun (n, param) ->
        let mf = D.identity param in
        let rvar = eval_summary st (StringMap.find n rhs) in
        (param, D.compose mf rvar))
    |> List.fold_left (fun acc (p, rv) -> VM.add p rv acc) st

  let compose_call summaries (prog : Program.t) proc lhs args st stmt =
    let summary =
      Hashtbl.find summaries
      @@
      match direction with
      | `Forwards ->
          Loc.(
            IntraVertex
              { proc_id = Procedure.id proc; v = Procedure.Vert.Return })
      | `Backwards ->
          Loc.(
            IntraVertex
              { proc_id = Procedure.id proc; v = Procedure.Vert.Return })
    in
    let globs = prog.globals |> Hashtbl.to_list in
    let globs =
      List.map
        (fun (_, glob) -> (glob, VM.find glob st, VM.find glob summary))
        globs
    in
    let sglob = compose_var_states st globs in
    let locals = Procedure.formal_in_params proc in
    let summary =
      StringMap.to_list locals
      |> List.map (fun (i, v) ->
          (v, eval_summary summary @@ StringMap.find i args))
      |> List.fold_left (fun acc (v, mfun) -> VM.add v mfun acc) summary
    in
    let outs =
      StringMap.to_list (Procedure.formal_out_params proc)
      |> List.map (fun (n, param) ->
          let lvar = StringMap.find n lhs in
          (lvar, VM.find lvar st, VM.find param summary))
      |> compose_var_states sglob
    in
    outs

  let tf_stmt summaries (proc : Program.proc) (prog : Program.t) block_id
      stmt_offset st s =
    let open Lang.Stmt in
    let proc_id = Procedure.id proc in
    let r =
      match s with
      | Instr_Call { lhs; procid; args } as c ->
          let proc = ID.Map.find procid prog.procs in
          let after_call =
            (* FIXME: assumes fwd analysis*)
            Loc.(
              CallSite { proc_id; block = block_id; offset = stmt_offset + 1 })
          in
          let call_site =
            Loc.(CallSite { proc_id; block = block_id; offset = stmt_offset })
          in
          Hashtbl.add summaries call_site st;
          let call_s = compose_call summaries prog proc lhs args st c in
          Hashtbl.add summaries after_call call_s;
          call_s
      | Instr_Return _ as c -> compose_return prog proc stmt_offset st c
      | ( Instr_Assign _ | Instr_Assert _ | Instr_Assume _ | Instr_Load _
        | Instr_Store _ | Instr_IntrinCall _ | Instr_IndirectCall _ ) as stmt ->
          compose_state_updates (D.transfer (fun v -> None) stmt) st
    in
    r

  let tf_block summaries proc prog block_id st edge =
    Block.foldi_backwards
      ~f:(fun a (id, stmt) -> tf_stmt summaries proc prog block_id id a stmt)
      ~phi:(fun a p -> a)
      edge ~init:st

  let tf_block_from summaries proc prog block_id st_id st edge =
    Block.foldi_backwards
      ~f:(fun a (id, stmt) ->
        if id > st_id then a else tf_stmt summaries proc prog block_id id a stmt)
      ~phi:(fun a p -> a)
      edge ~init:st
      *)

  type edge = Loc.t * IDEGraph.Edge.t * Loc.t

  let tf_edge_phase_1 dir get_summary st edge =
    let open IDEGraph.Edge in
    match edge with
    | _, Stmts (phi, bs), _ -> begin
        let stmts st =
          List.fold_left
            (fun st s ->
              compose_state_updates (D.transfer (fun v -> VM.get v st) s) st)
            st bs
        in
        let phis = compose_state_updates (tf_phis phi) in
        match dir with
        | `Forwards -> phis (stmts st)
        | `Backwards -> stmts (phis st)
      end
    | _, InterCall args, target ->
        let target = get_summary target in
        let c = D.transfer_call (fun v -> VM.get v target) args |> VM.of_iter in
        let args =
          List.map
            (function formal, _ -> (formal, VM.find formal c))
            args.args
        in
        compose_assigns st args
    | _, InterReturn args, target ->
        let target = get_summary target in
        let c =
          D.transfer_return (fun v -> VM.get v target) args |> VM.of_iter
        in
        let args =
          List.map
            (function formal, _ -> (formal, VM.find formal c))
            args.args
        in
        compose_assigns st args
    | _, Nop, _ -> st

  let naive_summary_worklist dir graph default roots edge_transfer_function =
    (*TODO: abstract the graph iteration direction stuff *)
    let module Q = Fix.CompactQueue in
    let (worklist : edge Q.t) = Q.create () in
    let summaries : (Loc.t, summary) Hashtbl.t = Hashtbl.create 100 in
    let get_summary loc = Hashtbl.get summaries loc |> Option.get_or ~default in
    List.iter (fun v -> Q.add v worklist) roots;
    IDEGraph.G.fold_edges_e (fun e a -> Q.add e worklist) graph ();
    while not (Q.is_empty worklist) do
      let (p : edge) = Q.take worklist in
      let st, vend, ost' =
        match (p, dir) with
        | (b, _, e), `Forwards -> (get_summary b, e, get_summary e)
        | (b, _, e), `Backwards -> (get_summary e, b, get_summary b)
      in
      let st' = edge_transfer_function get_summary st p in
      let st' = join_summaries ost' st' in
      if not (equal_summary ost' st') then begin
        Hashtbl.add summaries vend st';
        let succ =
          match dir with
          | `Forwards -> IDEGraph.G.succ_e graph vend
          | `Backwards -> IDEGraph.G.pred_e graph vend
        in
        List.iter (fun v -> Q.add v worklist) succ;
        ()
      end
    done;
    summaries

  let phase1_solve dir graph default roots =
    naive_summary_worklist dir graph default roots (tf_edge_phase_1 dir)

  let phase2_solve default dir graph summaries roots =
    let module Q = Fix.CompactQueue in
    let (worklist : edge Q.t) = Q.create () in
    let constants : (Loc.t, constant_state) Hashtbl.t = Hashtbl.create 100 in
    let get_st l = Hashtbl.get_or constants l ~default in
    let get_summary loc =
      Hashtbl.get summaries loc |> Option.get_exn_or "summary undefined"
    in
    List.iter (fun v -> Q.add v worklist) roots;
    IDEGraph.G.fold_edges_e (fun e a -> Q.add e worklist) graph ();
    while not (Q.is_empty worklist) do
      let (p : edge) = Q.take worklist in
      let b, e, summary, st, ost' =
        match (p, dir) with
        | (b, _, e), `Forwards -> (b, e, get_summary b, get_st b, get_st e)
        | (b, _, e), `Backwards -> (e, b, get_summary e, get_st e, get_st b)
      in
      let updates = D.transfer_const (fun v -> VM.get v st) summary in
      let st' = Iter.fold (fun m (v, t) -> VM.add v t m) st updates in
      let st' = join_constant_summary st' ost' in
      if not (equal_constant_state ost' st') then begin
        Hashtbl.add constants e st';
        let succ =
          match dir with
          | `Forwards -> IDEGraph.G.succ_e graph e
          | `Backwards -> IDEGraph.G.pred_e graph e
        in
        List.iter (fun v -> Q.add v worklist) succ;
        ()
      end
    done;
    summaries

  let solve prog =
    let graph = IDEGraph.create prog in
    phase1_solve `Backwards graph VM.empty

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

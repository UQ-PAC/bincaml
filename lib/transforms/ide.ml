open Lang
open Containers
open Common

type 'e microfunction = F of 'e | Constant of 'e | ID

module Loc = struct
  type stmt_id = { proc_id : ID.t; block : ID.t; offset : int }
  [@@deriving eq, ord, show]

  type t =
    | IntraVertex of { proc_id : ID.t; v : Procedure.Vert.t }
    | CallSite of stmt_id
    | AfterCall of stmt_id
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
      | Call of Program.stmt (* fallthrough *)
      | Stmts of Var.t Block.phi list * Program.stmt list
      | InterCall of (Var.t * Expr.BasilExpr.t) list
          (** (target.formal_in, rhs arg) assignment to call formal params*)
      | InterReturn of (Var.t * Var.t) list
          (** (call lhs out, target formal_out) assignment of returns to call
              lhs *)
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
    let graph =
      GB.add_edge_e graph (CallSite origin, Call callstmt, AfterCall origin)
    in
    let call_entry = IntraVertex { proc_id = target; v = Entry } in
    let call_return = IntraVertex { proc_id = target; v = Return } in
    let graph =
      GB.add_edge_e graph (CallSite origin, InterCall rhs, call_entry)
    in
    let graph =
      GB.add_edge_e graph (call_return, InterReturn lhs, AfterCall origin)
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

module LVD = struct
  type mfun = Live | Dead | CondLive of Var.t [@@deriving eq, ord]

  module VM = Map.Make (Var)

  type idest
  type read_state = idest -> Var.t -> mfun
  type update = Var.t * mfun
  type compose = mfun -> mfun -> mfun

  let mfun_identity v = CondLive v

  type summary = mfun VM.t [@@deriving eq, ord]

  let empty_summary = VM.empty

  let eval_summary (s : summary) (e : Expr.BasilExpr.t) : mfun =
    failwith "unimplemented"

  (** backwards sequential composition *)
  let compose a b =
    match (a, b) with
    | _, Live -> Live
    | _, Dead -> Dead
    | Dead, CondLive v -> CondLive v
    | Live, CondLive v -> CondLive v
    | CondLive v1, CondLive v2 when Var.equal v1 v2 -> CondLive v1
    | CondLive _, CondLive _ -> Live

  (** compose the summary for all variables in the two summaries *)
  let compose_summaries st st' =
    VM.union (fun v a b -> Some (compose a b)) st st'

  (** compose the edge functions for a set of pairs of vars updating the first,
      e.g. v1 := mf2 ~> v1 |-> st1(v) compose st2(v2) *)
  let compose_var_states st vars =
    List.fold_left
      (fun acc (v1, mf1, mf2) -> VM.add v1 (compose mf1 mf2) acc)
      st vars

  (** composition of an assignment var := mfun', where var |-> mfun in st: i.e.
      becomes compose mfun compose mfun' *)
  let compose_assigns st vars =
    let updates =
      List.map
        (fun (v, mf) ->
          (v, VM.find_opt v st |> Option.get_or ~default:(mfun_identity v), mf))
        vars
    in
    compose_var_states st updates

  let join a b =
    match (a, b) with
    | _, Live -> Live
    | Live, _ -> Live
    | CondLive v1, CondLive v2 when Var.equal v1 v2 -> CondLive v1
    | CondLive _, CondLive _ -> Live
    | Dead, CondLive v -> CondLive v
    | CondLive v, Dead -> CondLive v
    | Dead, Dead -> Dead

  let join_summaries a b = VM.union (fun v a b -> Some (join a b)) a b

  let compose_state_updates updates st =
    List.fold_left
      (fun st (v, ex) ->
        let e = VM.find_opt v st in
        let c = Option.map (fun e -> compose e ex) e in
        let c = Option.get_or ~default:ex c in
        VM.add v c st)
      st updates

  let direction : [ `Forwards | `Backwards ] = `Backwards

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

  let proc_entry (prog : Program.t) (proc : Program.proc) =
    let globals =
      prog.globals |> Hashtbl.to_list |> List.map snd
      |> List.map (fun v -> (v, mfun_identity v))
    in
    let locals = Procedure.formal_in_params proc in
    let locals =
      StringMap.to_list locals |> List.map snd
      |> List.map (fun v -> (v, mfun_identity v))
    in
    globals @ locals

  let proc_return (prog : Program.t) (proc : Program.proc) =
    let globals =
      prog.globals |> Hashtbl.to_list |> List.map snd
      |> List.map (fun v -> (v, mfun_identity v))
    in
    let locals = Procedure.formal_out_params proc in
    let locals =
      StringMap.to_list locals |> List.map snd
      |> List.map (fun v -> (v, mfun_identity v))
    in
    globals @ locals

  let compose_return prog (proc : Program.proc) loc st stmt =
    let rhs =
      Stmt.(
        match stmt with
        | Instr_Return { args } -> args
        | _ -> failwith "not a return")
    in
    StringMap.to_list (Procedure.formal_out_params proc)
    |> List.map (fun (n, param) ->
        let mf = mfun_identity param in
        let rvar = eval_summary st (StringMap.find n rhs) in
        (param, compose mf rvar))
    |> List.fold_left (fun acc (p, rv) -> VM.add p rv acc) st

  let tf_phis phis : (Var.t * mfun) list = failwith "unimplemented"

  let tf_local_stmt s =
    let open Livevars in
    let assigned = Livevars.assigned_stmt V.empty s |> V.to_list in
    let read = Livevars.free_vars_stmt V.empty s |> V.to_list in
    match assigned with
    | h :: [] -> List.map (fun r -> (r, CondLive h)) read
    | _ -> List.map (fun r -> (r, Live)) read

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
          compose_state_updates (tf_local_stmt stmt) st
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

  type edge = Loc.t * IDEGraph.Edge.t * Loc.t

  let phase1_solve dir graph (prog : Program.t) default roots =
    let module Q = Fix.CompactQueue in
    let (worklist : edge Q.t) = Q.create () in
    let summaries : (Loc.t, summary) Hashtbl.t = Hashtbl.create 100 in
    let get_summary loc = Hashtbl.get summaries loc |> Option.get_or ~default in
    List.iter (fun v -> Q.add v worklist) roots;
    IDEGraph.G.fold_edges_e (fun e a -> Q.add e worklist) graph ();
    while not (Q.is_empty worklist) do
      let (p : edge) = Q.take worklist in
      let st' =
        let pred =
          match (p, dir) with
          | (b, _, e), `Forwards -> IDEGraph.G.pred graph b
          | (b, _, e), `Backwards -> IDEGraph.G.succ graph e
        in
        let st =
          match List.map get_summary pred with
          | h :: tl -> List.fold_left (fun i j -> join_summaries i j) h tl
          | [] -> failwith ""
        in
        match p with
        | bedge, Stmts (phi, bs), endedge ->
            List.fold_left
              (fun st s -> compose_state_updates (tf_local_stmt s) st)
              st bs
            |> compose_state_updates (tf_phis phi)
        | origin, InterCall args, target ->
            let target = get_summary target in
            let args =
              List.map
                (function
                  | formal, actual -> (formal, eval_summary target actual))
                args
            in
            compose_assigns st args
        | origin, InterReturn args, target ->
            let target = get_summary target in
            let args =
              List.map
                (function formal, actual -> (formal, VM.find actual target))
                args
            in
            compose_assigns st args
        | origin, Call args, target -> st
        | origin, Nop, target -> st
      in
      let v =
        match dir with
        | `Backwards -> IDEGraph.G.E.src p
        | `Forwards -> IDEGraph.G.E.dst p
      in
      let o = get_summary v in
      if not (equal_summary o st') then begin
        Hashtbl.add summaries v st';
        let succ =
          match dir with
          | `Forwards -> IDEGraph.G.succ_e graph v
          | `Backwards -> IDEGraph.G.pred_e graph v
        in
        List.iter (fun v -> Q.add v worklist) succ;
        ()
      end
    done;
    summaries

  let phase2_solve graph = ()

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

  (*
  module Phase1ProcSolver (P : sig
    val proc : Program.proc
    val prog : Program.t
    val summaries : ('a, summary) Hashtbl.t
  end) =
    Graph.ChaoticIteration.Make
      (G)
      (struct
        type vertex = G.E.vertex
        type edge = G.E.t
        type g = G.t
        type t = summary

        let equal = equal_summary
        let join = failwith "nojoin"
        let widening a b = failwith "no"

        let analyze (e : edge) d =
          let id = G.E.src e in
          let id =
            match id with
            | Begin i -> i
            | End i -> i
            | _ -> failwith "Not a block"
          in
          match G.E.label e with
          | Block b -> tf_block P.summaries P.proc P.prog id d b
          | _ -> d
      end)

  let solve_proc summaries (prog : Program.t) (p : Program.proc) =
    let module M : LocalPhaseProcAnalysis = Phase1ProcSolver (struct
      let prog = prog
      let proc = p
      let summaries = summaries
    end) in
    let result =
      M.recurse (Procedure.graph p) (Procedure.topo_rev p)
        (fun i -> empty_summary)
        (Graph.ChaoticIteration.Predicate (fun _ -> false))
        0
    in
    let init_summary = ResultMap.find Procedure.Vert.Entry result in
    Hashtbl.add summaries (Procedure (Procedure.id p)) init_summary;
    ()
    *)
end

(*
module type Domain = sig
  type stmt
  type v = Var.t
  type t

  val apply : t -> t option -> t
  (** substitute second arg into first arg for the free variable and return
      value *)

  val tf_stmt : Program.stmt -> t
  val compose : t -> t -> t
  val join : t -> t -> t
  val identity : t
  val equal : t -> t -> bool
  val compare : t -> t -> int
end

module Phase1 (D : Domain) = struct
  module Tbl = Map.Make (Loc)
  module State = Map.Make (Var)

  module MicroFunction = struct
    (** var -> value(var) mapping ; represents a single microfunction *)
    type t = F of Var.t * D.t | C of D.t | ID [@@deriving eq, ord]

    let default = ID
  end

  module StateDomain = struct
    module M = Map.Make (Var)

    type t = MicroFunction.t M.t [@@deriving eq, ord]

    let default = M.empty
  end


  let worklist = CCDeque.create ()

  module G =
    Graph.Persistent.Digraph.ConcreteBidirectionalLabeled (Loc) (StateDomain)
end

module Phase2 = struct end
*)

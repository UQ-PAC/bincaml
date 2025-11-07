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
    | Procedure of ID.t  (** summary for a procedure *)
    | AfterCall of stmt_id
  [@@deriving eq, ord, show]

  let hash = Hashtbl.hash
end

module IDEGraph = struct
  module V = struct
    include Loc
  end

  type t = { prog : Program.t; vertices : Loc.t Iter.t Lazy.t }

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
            |> Iter.filter_map (fun (i, s) ->
                let stmt_id : Loc.stmt_id = { proc_id; block; offset = i } in
                match s with
                | Stmt.Instr_Call _ -> Some Loc.(CallSite stmt_id)
                | _ -> None)
        | _, _ -> Iter.empty)
    in
    Iter.cons Loc.(Procedure proc_id) @@ Iter.append intra_verts b

  let prog_vertices (prog : Program.t) =
    ID.Map.values prog.procs
    |> Iter.flat_map (fun p -> proc_vertices p)
    |> Iter.persistent

  let create (p : Program.t) = { prog = p; vertices = lazy (prog_vertices p) }
  let iter_vertex p = Lazy.force p.vertices |> Iter.iter
end

module LVD = struct
  type mfun = Live | Dead | CondLive of Var.t [@@deriving eq, ord]

  module VM = Map.Make (Var)

  let st = VM.empty

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

  let update_state st updates =
    List.fold_left
      (fun st (v, ex) ->
        let e = VM.find_opt v st in
        let c = Option.map (fun e -> compose e ex) e in
        let c = Option.get_or ~default:ex c in
        VM.add v c st)
      st updates

  let compose_call (prog : Program.t) proc lhs args st stmt =
    let summary = Hashtbl.find summaries Loc.(Procedure (Procedure.id proc)) in
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

  let tf_local_stmt prog st id s =
    let open Livevars in
    let assigned = Livevars.assigned_stmt V.empty s |> V.to_list in
    let read = Livevars.free_vars_stmt V.empty s |> V.to_list in
    let updates =
      match assigned with
      | h :: [] -> List.map (fun r -> (r, CondLive h)) read
      | _ -> List.map (fun r -> (r, Live)) read
    in
    update_state st updates

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
          let call_s = compose_call prog proc lhs args st c in
          Hashtbl.add summaries after_call call_s;
          call_s
      | Instr_Return _ as c -> compose_return prog proc stmt_offset st c
      | ( Instr_Assign _ | Instr_Assert _ | Instr_Assume _ | Instr_Load _
        | Instr_Store _ | Instr_IntrinCall _ | Instr_IndirectCall _ ) as stmt ->
          tf_local_stmt prog st stmt_offset stmt
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

  let solve dir (prog : Program.t) =
    let worklist = CCDeque.create () in
    let summaries : (Loc.t, summary) Hashtbl.t = Hashtbl.create 100 in
    let callgraph = Program.CallGraph.make_call_graph prog in
    let c v = Program.CallGraph.G.succ callgraph v in
    while not (CCDeque.is_empty worklist) do
      let (p : Loc.t) = CCDeque.take_back worklist in
      let proc id = ID.Map.find id prog.procs in
      let st = failwith "" in
      let st =
        match p with
        | IntraVertex { proc_id; v = Begin i } ->
            let block =
              Procedure.get_block (proc proc_id) i
              |> Option.get_exn_or "block does not exist"
            in
            tf_block summaries (proc proc_id) prog i st block
        | IntraVertex { proc_id; v = End i } ->
            let p = proc proc_id in
            let succ = Procedure.G.succ (Procedure.graph p) (End i) in
            let succ =
              List.map (fun v -> Loc.IntraVertex { proc_id; v }) succ
              |> List.to_iter
            in
            CCDeque.add_iter_back worklist succ;
            st
        | IntraVertex { proc_id; v = Entry } -> st
        | IntraVertex { proc_id; v = Return } -> st
        | IntraVertex { proc_id; v = Exit } -> st
        | Procedure p -> st
        | CallSite p ->
            let proc = proc p.proc_id in
            let block =
              Procedure.get_block proc p.block
              |> Option.get_exn_or "block not exist"
            in
            tf_block_from summaries proc prog p.block p.offset st block
        | AfterCall p -> failwith "" (* continue analysing procedure *)
      in
      ()
    done

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

  module Phase1ProcSolver (P : sig
    val proc : Program.proc
    val prog : Program.t
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
          | Block b -> tf_block P.proc P.prog id d b
          | _ -> d
      end)

  let solve_proc (prog : Program.t) (p : Program.proc) =
    let module M : LocalPhaseProcAnalysis = Phase1ProcSolver (struct
      let prog = prog
      let proc = p
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

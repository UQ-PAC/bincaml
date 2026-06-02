(** An IDE solver which uses SSI information for efficiency *)

(* We create edge functions along the def-use or use-def graph instead of along the cfg.
 * We also only store one summary per variable in each procedure!
 * Finally we explicitly work over the sscs of the call graph of the program we're working on to skip redundant propagation. *)

open Lang
open Containers
open Common
open Dataflow_graph

type call_info = Expr.BasilExpr.t StringMap.t
type param_info = Var.t StringMap.t

module type Lattice = sig
  include ORD_TYPE

  val join : t -> t -> t
  val bottom : t
end

module type IDESSIDomain = sig
  include Lattice

  module DL : sig
    type t = Lambda | Label of Var.t
    [@@deriving eq, ord, show { with_path = false }]
  end

  val direction : [ `Forwards | `Backwards ]
  (** The direction this analysis should be performed in *)

  module Value : Lattice
  (** The underlying lattice the edge functions operate on *)

  val identity : t
  (** identity edge function *)

  val top : t
  (** top edge function *)

  val compose : t -> t -> t
  (** the composite of edge functions *)

  val eval : Value.t -> t -> Value.t
  (** evaluate an edge function *)

  type state_update = (DL.t * t) Iter.t

  val init_data : Program.proc -> Var.t Iter.t
  (** data that each procedure should summarise *)

  val transfer_call : call_info -> param_info -> DL.t -> state_update
  val transfer : Program.stmt -> DL.t -> state_update
  val transfer_phi : Var.t -> Var.t list -> DL.t -> state_update
  val init_p2 : Program.proc -> (Var.t * Value.t) Iter.t
  val pp : Format.formatter -> t -> unit
end

module IDESSI (D : IDESSIDomain) = struct
  module DL = D.DL
  module DlMap = Map.Make (DL)
  open DL

  type summary = D.t DlMap.t DlMap.t
  (** Edge function from an input variable (first argument) to any variable in
      the procedure (second argument) *)

  let show_summary s =
    DlMap.to_iter s
    |> Iter.flat_map (fun (d1, m) ->
        DlMap.to_iter m |> Iter.map (fun x -> (d1, x)))
    |> Iter.to_string ~sep:", " (fun (v, (v', i)) ->
        "(" ^ DL.show v ^ "," ^ DL.show v' ^ "->" ^ D.show i ^ ")")

  let ( @. ) = D.compose

  module W1 = Worklist.Make (struct
    type t = DL.t * ID.t * DL.t

    let compare = Ord.triple DL.compare ID.compare DL.compare
  end)

  let propagate worklist summaries get_summary update_summary =
    Iter.iter (fun (d1, pid, i) ->
        let summary = Hashtbl.find summaries pid in
        let entry = DlMap.get_or d1 summary ~default:DlMap.empty in
        let lambda = DlMap.get_or Lambda summary ~default:DlMap.empty in
        let entry =
          Iter.fold
            (fun entry (d2, e) ->
              let e' = DlMap.get_or d2 entry ~default:D.bottom in
              let j = D.join e e' in
              if D.equal e' j then entry
              else
                let base = DlMap.get_or d2 lambda ~default:D.bottom in
                if
                  match d1 with
                  (* If Lambda already propagates something >= this, remove this from the summary. *)
                  | Label v when D.equal base (D.join e base) -> false
                  | _ -> true
                then (
                  W1.add worklist (d1, pid, d2);
                  DlMap.add d2 j entry)
                else entry)
            entry i
        in
        let summary = DlMap.add d1 entry summary in
        Hashtbl.replace summaries pid summary)

  let is_output proc v =
    match D.direction with
    | `Forwards ->
        Procedure.formal_out_params proc |> StringMap.mem (Var.name v)
    | `Backwards ->
        Procedure.formal_in_params proc |> StringMap.mem (Var.name v)

  let p1_transfer (prog : Program.t) summaries entry2call entry2exit pid
      (v : Vertex.t) d1 d2 e1 : (DL.t * ID.t * (DL.t * D.t) Iter.t) Iter.t =
    let proc = Program.proc prog pid in
    let open Stmt in
    match v with
    | _, Vertex.Stmt (_, (Instr_Call c as s)) ->
        let caller = Program.proc prog c.procid in
        Iter.singleton
          ( d1,
            pid,
            (match D.direction with
              | `Forwards ->
                  D.transfer_call c.args (Procedure.formal_in_params caller) d2
                  |> Iter.map (fun (d, e2) -> (d, e2 @. e1))
              | `Backwards -> (
                  match d2 with
                  | Lambda -> Iter.singleton (Lambda, D.identity)
                  | Label v ->
                      StringMap.to_iter c.lhs
                      |> Iter.filter (fun (s, v') -> Var.equal v v')
                      |> Iter.map (fun (s, _) ->
                          ( Label
                              (Procedure.formal_out_params caller
                              |> StringMap.find s),
                            e1 ))))
            |> Iter.flat_map (fun (d, e1) ->
                (* update the entry2call cache *)
                let k = (d, c.procid) in
                Hashtbl.get_or entry2call k ~default:IDMap.empty
                |> IDMap.update pid (function
                  | Some m -> Some (DlMap.add d1 (e1, s) m)
                  | None -> Some (DlMap.singleton d1 (e1, s)))
                |> Hashtbl.replace entry2call k;
                (* If a summary of the caller exists, propagate through it *)
                Hashtbl.get_or entry2exit (c.procid, d) ~default:VarMap.empty
                |> VarMap.to_iter
                |> Iter.flat_map (fun (v3, e2) ->
                    (match D.direction with
                      | `Forwards ->
                          StringMap.get (Var.name v3) c.lhs
                          |> Option.to_iter
                          |> Iter.map (fun v4 -> (Label v4, D.identity))
                      | `Backwards ->
                          D.transfer_call c.args
                            (Procedure.formal_in_params proc)
                            (Label v3))
                    |> Iter.map (fun (d4, e3) -> (d4, e3 @. e2 @. e1)))) )
    | _, Vertex.Stmt (_, s) ->
        Iter.singleton
        @@ ( d1,
             pid,
             D.transfer s d2 |> Iter.map (fun (d3, e2) -> (d3, e2 @. e1)) )
    | _, Vertex.Phi p ->
        Iter.singleton
        @@ ( d1,
             pid,
             D.transfer_phi p.lhs p.rhs d2
             |> Iter.map (fun (d3, e2) -> (d3, e2 @. e1)) )
    | _, Vertex.Entry | _, Vertex.Return -> (
        match d2 with
        | Label v2 when is_output proc v2 ->
            (* d2 is an output variable, so e1 is a summary of pid. We first
             * update the entry2exit cache *)
            let k = (pid, d1) in
            Hashtbl.get_or entry2exit k ~default:VarMap.empty
            |> VarMap.add v2 e1
            |> Hashtbl.replace entry2exit k;
            (* We now propagate to all callees of this procedure that are
             * stored in the cache *)
            Hashtbl.get_or entry2call (d1, pid) ~default:IDMap.empty
            |> IDMap.to_iter
            |> Iter.flat_map (fun (callee_id, m) ->
                DlMap.to_iter m
                |> Iter.map (fun (d0, (e0, s)) ->
                    ( d0,
                      callee_id,
                      match s with
                      | Instr_Call c ->
                          (match D.direction with
                            | `Forwards ->
                                StringMap.get (Var.name v2) c.lhs
                                |> Option.to_iter
                                |> Iter.map (fun v3 -> (Label v3, D.identity))
                            | `Backwards ->
                                D.transfer_call c.args
                                  (Procedure.formal_in_params proc)
                                  (Label v2))
                          |> Iter.map (fun (d3, e2) -> (d3, e2 @. e1 @. e0))
                      | _ -> Iter.empty )))
        | _ -> Iter.empty)

  let p1_solve_scc (prog : Program.t) (defuses : (ID.t, MDeps.t) Hashtbl.t)
      (entry_to_exit_cache : (ID.t * DL.t, D.t VarMap.t) Hashtbl.t)
      (summaries : (ID.t, summary) Hashtbl.t) scc =
    let get_summary pid d1 d2 =
      Hashtbl.get_or summaries pid ~default:DlMap.empty
      |> DlMap.get_or d1 ~default:DlMap.empty
      |> DlMap.get_or d2 ~default:D.bottom
    in
    let update_summary pid d1 d2 e =
      let summary = Hashtbl.get_or summaries pid ~default:DlMap.empty in
      let m = DlMap.get_or d1 summary ~default:DlMap.empty in
      let m = DlMap.add d2 e m in
      let summary = DlMap.add d1 m summary in
      Hashtbl.replace summaries pid summary
    in
    (* Stores edge functions from some procedure's entry to the given
       procedure's entry along with the call it comes from, with a fixed dl
       value at the start of the second procedure *)
    let entry_to_call_entry_cache :
        (DL.t * ID.t, (D.t * Program.stmt) DlMap.t IDMap.t) Hashtbl.t =
      Hashtbl.create 20
    in
    let worklist = W1.create () in
    List.iter
      (fun pid ->
        let proc = Program.proc prog pid in
        let init =
          D.init_data proc |> Iter.map (fun v -> Label v) |> Iter.cons Lambda
        in
        init |> Iter.map (fun v -> (v, pid, v)) |> W1.add_iter worklist;
        init |> Iter.iter (fun v -> update_summary pid v v D.identity))
      scc;
    while W1.non_empty worklist do
      let d1, pid, d2 = W1.pop worklist in
      let e1 = get_summary pid d1 d2 in
      let def_use = Hashtbl.find defuses pid in
      (match d2 with
        | Lambda ->
            Program.proc prog pid |> get_dfg_vertices ~direction:D.direction
        | Label v2 -> MDeps.find_iter def_use v2)
      |> Iter.iter (fun v ->
          p1_transfer prog summaries entry_to_call_entry_cache
            entry_to_exit_cache pid v d1 d2 e1
          |> propagate worklist summaries get_summary update_summary)
    done

  let p2_solve_proc (summary : summary) proc : D.Value.t VarMap.t =
    D.init_p2 proc |> VarMap.of_iter
    |> DlMap.fold
         (fun d ->
           DlMap.fold (fun d2 ef m ->
               match d2 with
               | Label v ->
                   let x =
                     match d with
                     | Lambda -> D.eval D.Value.bottom ef
                     | Label v' ->
                         D.eval (VarMap.get_or v' m ~default:D.Value.bottom) ef
                   in
                   let j =
                     D.Value.join (VarMap.get_or v m ~default:D.Value.bottom) x
                   in
                   VarMap.add v j m
               | Lambda -> m))
         summary

  (** Compute a defuse graph for all procedures in a given program, in the
      direction of the analysis. This can be kept to reuse with the solver
      functions. *)
  let compute_defuses (prog : Program.t) : (ID.t, MDeps.t) Hashtbl.t =
    let defuses = Hashtbl.create 20 in
    Program.procs prog
    |> Iter.iter (fun (pid, proc) ->
        Hashtbl.add defuses pid
          (match D.direction with
          | `Forwards -> def_to_use_map proc
          | `Backwards -> use_to_def_map proc));
    defuses

  let gen_stub_summaries (prog : Program.t) summaries entry2exit =
    let update_summary pid d1 d2 e =
      let summary = Hashtbl.get_or summaries pid ~default:DlMap.empty in
      let m = DlMap.get_or d1 summary ~default:DlMap.empty in
      let m = DlMap.add d2 e m in
      let summary = DlMap.add d1 m summary in
      Hashtbl.replace summaries pid summary
    in
    Program.procs prog
    |> Iter.iter (fun (pid, proc) ->
        match Procedure.graph proc with
        | Some _ -> ()
        | None ->
            let init =
              D.init_data proc
              |> Iter.map (fun v -> Label v)
              |> Iter.cons Lambda
            in
            Iter.for_each init (fun d ->
                (match D.direction with
                  | `Forwards -> Procedure.formal_out_params proc
                  | `Backwards -> Procedure.formal_in_params proc)
                |> StringMap.values
                |> Iter.iter (fun out ->
                    let k = (pid, d) in
                    Hashtbl.get_or entry2exit k ~default:VarMap.empty
                    |> VarMap.add out D.top
                    |> Hashtbl.replace entry2exit k;
                    update_summary pid d (Label out) D.top)))

  (** Generates edge function summaries for every procedure in the given
      program. *)
  let solve_summaries ?(defuses : (ID.t, MDeps.t) Hashtbl.t option)
      (prog : Program.t) : (ID.t, summary) Hashtbl.t =
    let call_graph_sccs =
      Program.CallGraph.make_call_graph prog
      |> Program.CallGraph.Scc.scc_list
      |> List.map
           (List.filter_map (function
             | Program.CallGraph.Vert.ProcBegin id -> Some id
             | _ -> None))
    in
    let defuses = Option.get_lazy (fun _ -> compute_defuses prog) defuses in
    (* Stores summaries of a procedure (for this scc) about only input-output relations *)
    let entry_to_exit_cache = Hashtbl.create 20 in
    let summaries = Hashtbl.create 20 in
    (* Initialise stub summaries *)
    gen_stub_summaries prog summaries entry_to_exit_cache;
    (* Solve p1 *)
    List.iter
      (fun scc -> p1_solve_scc prog defuses entry_to_exit_cache summaries scc)
      call_graph_sccs;
    summaries

  (** Compute edge function summaries and analysis results for every procedure
      in the given program. *)
  let solve ?(defuses : (ID.t, MDeps.t) Hashtbl.t option) (prog : Program.t) :
      (ID.t, summary) Hashtbl.t * D.Value.t VarMap.t IDMap.t =
    (* Solve phase 1 *)
    let summaries = solve_summaries ?defuses prog in
    (* Solve phase 2 *)
    let p2_res =
      Program.procs prog
      |> Iter.map (fun (pid, proc) ->
          let summary = Hashtbl.get_or summaries pid ~default:DlMap.empty in
          (pid, p2_solve_proc summary proc))
      |> IDMap.of_iter
    in
    (summaries, p2_res)
end

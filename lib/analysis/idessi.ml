(** An IDE solver which uses SSI information for efficiency *)

(* We create edge functions along the def-use or use-def graph instead of along the cfg.
 * We also only store one summary per variable in each procedure!
 * Finally we explicitly work over the sscs of the call graph of the program we're working on to skip redundant propagation. *)

open Lang
open Containers
open Common
open Dataflow_graph

type call_info = (Var.t * Expr.BasilExpr.t) list

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

  val compose : t -> t -> t
  (** the composite of edge functions *)

  val eval : t -> Value.t -> Value.t
  (** evaluate an edge function *)

  type state_update = (DL.t * t) Iter.t

  val init_data : Program.proc -> Var.t Iter.t
  (** data that each procedure should summarise *)

  val transfer_call : call_info -> DL.t -> state_update
  val transfer : Program.stmt -> DL.t -> state_update
  val transfer_phi : Var.t -> Var.t list -> DL.t -> state_update
end

module IDESSI (D : IDESSIDomain) = struct
  module DL = D.DL
  module DlMap = Map.Make (DL)
  open DL

  type summary = D.t DlMap.t DlMap.t

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

  let propagate worklist summaries get_summary update_summary updates =
    Iter.filter_map
      (fun (d1, pid, d2, e) ->
        let e' = get_summary pid d1 d2 in
        let j = D.join e e' in
        (not (D.equal e' j)) |> flip Option.return_if (d1, pid, d2, j))
      updates
    |> Iter.iter (fun (d1, pid, d2, e) ->
        W1.add worklist (d1, pid, d2);
        update_summary pid d1 d2 e)

  let is_output proc v =
    match D.direction with
    | `Forwards ->
        Procedure.formal_out_params proc |> StringMap.mem (Var.name v)
    | `Backwards ->
        Procedure.formal_in_params proc |> StringMap.mem (Var.name v)

  let p1_transfer (prog : Program.t) summaries entry2call pid (v : Vertex.t) d1
      d2 e1 =
    let proc = ID.Map.find pid prog.procs in
    let open Stmt in
    match v with
    | _, Vertex.Stmt (_, (Instr_Call c as s)) ->
        let caller = ID.Map.find c.procid prog.procs in
        let ci =
          c.args |> StringMap.to_list
          |> List.map (fun (s, e) ->
              (Procedure.formal_in_params caller |> StringMap.find s, e))
        in
        (match D.direction with
          | `Forwards -> D.transfer_call ci d2
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
            print_endline @@ DL.show d1 ^ DL.show d ^ ID.show pid ^ ID.show c.procid;
            Hashtbl.get_or entry2call k ~default:ID.Map.empty
            |> ID.Map.update pid (function
                | Some m -> Some(DlMap.add d1 (e1, s) m)
                | None -> Some(DlMap.singleton d1 (e1, s)))
            |> Hashtbl.replace entry2call k;
            (* If a summary of the caller exists, propagate through it *)
            Hashtbl.get_or summaries c.procid ~default:DlMap.empty
            |> DlMap.get_or d ~default:DlMap.empty
            |> DlMap.to_iter
            |> Iter.filter_map (fun (d', e') ->
                print_endline @@ DL.show d';
                match d' with
                | Lambda -> None
                | Label v -> is_output proc v |> flip Option.return_if (v, e'))
            |> Iter.flat_map (fun (v3, e2) ->
                (match D.direction with
                  | `Forwards ->
                      StringMap.get (Var.name v3) c.lhs
                      |> Option.to_iter
                      |> Iter.map (fun v4 -> (Label v4, D.identity))
                  | `Backwards -> D.transfer_call ci (Label v3))
                |> Iter.map (fun (d4, e3) -> (d1, pid, d4, e3 @. e2 @. e1))))
    | _, Vertex.Stmt (_, s) ->
        D.transfer s d2 |> Iter.map (fun (d3, e2) -> (d1, pid, d3, e2 @. e1))
    | _, Vertex.Phi p ->
        D.transfer_phi p.lhs p.rhs d2
        |> Iter.map (fun (d3, e2) -> (d1, pid, d3, e2 @. e1))
    | _, Vertex.Entry | _, Vertex.Return -> (
        match d2 with
        | Label v2 when is_output proc v2 ->
            (* d3 is an output variable, so e2 is a summary of pid. We now
             * propagate to all callees of this procedure that are stored in
             * the cache *)
            Hashtbl.get_or entry2call (d1, pid) ~default:ID.Map.empty
            |> ID.Map.to_iter
            |> Iter.flat_map (fun (callee_id, m) ->
                print_endline @@ DL.show d2 ^ ID.show pid;
                DlMap.to_iter m
                |> Iter.flat_map (fun (d1, (e1, s)) ->
                    match s with
                    | Instr_Call c ->
                        let ci =
                          c.args |> StringMap.to_list
                          |> List.map (fun (s, e) ->
                              ( Procedure.formal_in_params proc
                                |> StringMap.find s,
                                e ))
                        in
                        (match D.direction with
                          | `Forwards ->
                              StringMap.get (Var.name v2) c.lhs
                              |> Option.to_iter
                              |> Iter.map (fun v3 -> (Label v3, D.identity))
                          | `Backwards -> D.transfer_call ci (Label v2))
                        |> Iter.map (fun (d3, e2) ->
                            (d1, callee_id, d3, e2 @. e1))
                    | _ -> Iter.empty))
        | _ -> Iter.empty)

  let p1_solve_scc (prog : Program.t) (defuses : (ID.t, MDeps.t) Hashtbl.t)
      (summaries : (ID.t, summary) Hashtbl.t) scc : (ID.t, summary) Hashtbl.t =
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
        (DL.t * ID.t, (D.t * Program.stmt) DlMap.t ID.Map.t) Hashtbl.t =
      Hashtbl.create 100
    in
    let worklist = W1.create () in
    List.iter
      (fun pid ->
        let proc = ID.Map.find pid prog.procs in
        let init =
          D.init_data proc |> Iter.map (fun v -> Label v) |> Iter.cons Lambda
        in
        init |> Iter.map (fun v -> (v, pid, v)) |> W1.add_iter worklist;
        let summary = Hashtbl.get_or summaries pid ~default:DlMap.empty in
        let summary =
          Iter.fold
            (fun summary v ->
              DlMap.add v (DlMap.singleton v D.identity) summary)
            summary init
        in
        Hashtbl.replace summaries pid summary)
      scc;
    while W1.non_empty worklist do
      let d1, pid, d2 = W1.pop worklist in
      let e1 = get_summary pid d1 d2 in
      let def_use = Hashtbl.find defuses pid in
      (match d2 with
        | Lambda ->
            ID.Map.find pid prog.procs
            |> get_dfg_vertices ~direction:D.direction
        | Label v2 -> MDeps.find_iter def_use v2)
      |> Iter.iter (fun v ->
          p1_transfer prog summaries entry_to_call_entry_cache pid v d1 d2 e1
          |> propagate worklist summaries get_summary update_summary)
    done;
    summaries

  let compute_defuses (prog : Program.t) : (ID.t, MDeps.t) Hashtbl.t =
    let relevant_stmts = Hashtbl.create 20 in
    ID.Map.iter
      (fun pid proc ->
        Hashtbl.add relevant_stmts pid
          (let defuse = def_use_maps proc in
           match D.direction with
           | `Forwards -> defuse.var_to_use
           | `Backwards -> defuse.var_to_def))
      prog.procs;
    relevant_stmts

  let solve (prog : Program.t) =
    let call_graph_sccs =
      Program.CallGraph.make_call_graph prog
      |> Program.CallGraph.Scc.scc_list
      |> List.map
           (List.filter_map (function
             | Program.CallGraph.Vert.ProcBegin id -> Some id
             | _ -> None))
    in
    let defuses = compute_defuses prog in
    let p1_summaries =
      List.fold_left
        (fun summaries scc -> p1_solve_scc prog defuses summaries scc)
        (Hashtbl.create 20) call_graph_sccs
    in
    p1_summaries
end

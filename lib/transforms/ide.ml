(** IDE test transforms *)

open Lang
open Containers
open Common
open Analysis.Ide

module IDELive = struct
  let direction = `Backwards

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

  type t = IdEdge | ConstEdge of Value.t [@@deriving eq, ord]

  let bottom = ConstEdge bottom

  let show v =
    match v with IdEdge -> "IdEdge" | ConstEdge v -> "ConstEdge " ^ show v

  let pp fmt v = Format.pp_print_string fmt (show v)
  let identity = IdEdge

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

  open DL

  let transfer_call (c : call_info) d =
    match d with
    | Lambda ->
        List.fold_left
          (fun i (_, out) -> Iter.cons (Label out, IdEdge) i)
          (Iter.singleton (d, IdEdge))
          c.lhs
    | Label v when Var.is_global v -> Iter.empty
    | Label v -> Iter.empty

  let transfer_return r d = Iter.singleton (d, IdEdge)

  (* TODO preserve locals that aren't involved in the call *)
  let transfer_call_to_aftercall stmt d =
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
                    if DL.equal d (Label v') then
                      Expr.BasilExpr.free_vars_iter ex
                      |> Iter.map (fun v' -> (Label v', IdEdge))
                    else Iter.singleton (d, e))
                  i)
              (Iter.singleton (d, IdEdge))
              assigns
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
  let summary, r = IDELiveAnalysis.solve prog in
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

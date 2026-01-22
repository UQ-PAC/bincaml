(** IDE test transforms *)

open Lang
open Containers
open Common
open Analysis.Ide_live

let show_state (v : IDELiveAnalysis.analysis_state) =
  VarMap.to_iter v |> IDELive.show_state

let print_live_vars_dot sum r fmt prog proc_id =
  let label (v : Procedure.G.vertex) = r v |> Option.map (fun s -> sum s) in
  let p = Program.proc prog proc_id in
  Trace_core.with_span ~__FILE__ ~__LINE__ "dot-printer" @@ fun _ ->
  let (module M : Viscfg.ProcPrinter) = Viscfg.dot_labels label in
  Option.iter (fun g -> M.fprint_graph fmt g) (Procedure.graph p)

let transform (prog : Program.t) =
  let g = Analysis.Ide.IDEGraph.create prog `Backwards in
  CCIO.with_out "idegraph.dot" (fun s ->
      Analysis.Ide.IDEGraph.Vis.fprint_graph (Format.of_chan s) g);
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

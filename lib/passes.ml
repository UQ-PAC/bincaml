open Lang
open Containers
open Lang

(** TODO: pass program to procedure-local passes

    TODO: structured errors for checks *)

module PassManager = struct
  type transform =
    | Prog of (Program.t -> Program.t)
    | Proc of (Program.proc -> Program.proc)
    | ProcCheck of (Program.proc -> bool)

  type pass = { name : string; apply : transform }

  module SMap = Map.Make (String)

  type t = { avail : pass SMap.t }

  let passes =
    [
      { name = "simple-params"; apply = Prog Transforms.Ssa.set_params };
      { name = "simple-ssa"; apply = Proc Transforms.Ssa.ssa };
      {
        name = "check-read-uninitialised";
        apply = ProcCheck Transforms.May_read_uninit.check;
      };
      {
        name = "remove-unreachable-block";
        apply = Proc Transforms.Cleanup_cfg.remove_blocks_unreachable_from_entry;
      };
      {
        name = "cf-expressions";
        apply = Proc Transforms.Cf_tx.simplify_proc_exprs;
      };
      {
        name = "intra-dead-store-elim";
        apply = Proc Transforms.Livevars.DSE.sane_transform;
      };
      { name = "ide-live"; apply = Prog Transforms.Ide.transform };
    ]

  let batch_of_list pass =
    List.map (fun n -> List.find (fun t -> String.equal t.name n) passes) pass

  let run_transform (p : Program.t) (tf : pass) =
    Trace.with_span ~__FILE__ ~__LINE__ ("transform-prog::" ^ tf.name)
    @@ fun _ ->
    match tf.apply with
    | Prog tf -> tf p
    | ProcCheck app ->
        let _ =
          ID.Map.mapi
            (fun id proc ->
              Trace.with_span ~__FILE__ ~__LINE__
                ("check-proc::" ^ tf.name ^ "::" ^ ID.to_string id)
              @@ fun _ ->
              match app proc with
              | false -> ()
              | true -> print_endline @@ "Check failed: " ^ ID.to_string id)
            p.procs
        in
        p
    | Proc app ->
        let procs =
          ID.Map.mapi
            (fun id proc ->
              Trace.with_span ~__FILE__ ~__LINE__
                ("transform-proc::" ^ tf.name ^ "::" ^ ID.to_string id)
              @@ fun _ -> app proc)
            p.procs
        in
        { p with procs }

  let construct_batch (s : t) (passes : string list) =
    List.map (fun p -> SMap.find p s.avail) passes

  let run_batch (batch : pass list) prog =
    List.fold_left run_transform prog batch
end

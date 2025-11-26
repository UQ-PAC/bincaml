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
    | Batch of pass list

  and pass = { name : string; apply : transform; doc : string }

  module SMap = Map.Make (String)

  type t = { avail : pass SMap.t }

  let sparams =
    {
      name = "simple-params";
      apply = Prog Transforms.Ssa.set_params;
      doc =
        "Pull all global variables into the parameter list, discarding initial \
         parameter list (i.e. assuming its empty)";
    }

  let read_uninit locals =
    {
      name =
        ("check-read-uninitialised-"
        ^ if locals then "globals" else "withlocals");
      apply =
        ProcCheck (Transforms.May_read_uninit.check ~include_locals:locals);
      doc = "Fail if the program contains read-uninitialised variables";
    }

  let sssa =
    {
      name = "simple-ssa";
      apply = Proc Transforms.Ssa.ssa;
      doc =
        "Naive SSA transform assuming all variable uses are dominated by \
         definitions from parameters";
    }

  let full_ssa =
    {
      name = "ssa";
      apply = Batch [ sparams; read_uninit true; sssa ];
      doc =
        "Complete SSA pipeline for early IR (global register parameterless \
         form)";
    }

  let passes =
    [
      sparams;
      read_uninit false;
      read_uninit true;
      sssa;
      full_ssa;
      {
        name = "remove-unreachable-block";
        apply = Proc Transforms.Cleanup_cfg.remove_blocks_unreachable_from_entry;
        doc = "Remove blocks unreachable from entry";
      };
      {
        name = "cf-expressions";
        apply = Proc Transforms.Cf_tx.simplify_proc_exprs;
        doc =
          "Perform intra-expression simplificatinos and constant folding for \
           whole program";
      };
      {
        name = "intra-dead-store-elim";
        apply = Proc Transforms.Livevars.DSE.sane_transform;
        doc =
          "Remove store assignments to pure local variables which are never \
           read ";
      };
      {
        name = "ide-live";
        apply = Prog Transforms.Ide.transform;
        doc = "broken ide test analysis";
      };
    ]

  let print_passes =
    let open Containers_pp in
    let open Containers_pp.Infix in
    passes
    |> List.map (fun p ->
        text p.name ^ newline
        ^ (text @@ String.init (String.length p.name) (fun i -> '-'))
        ^ newline ^ newline ^ text "    " ^ text p.doc)
    |> fill (newline ^ newline)

  let batch_of_list pass =
    List.map (fun n -> List.find (fun t -> String.equal t.name n) passes) pass

  let rec run_transform (p : Program.t) (tf : pass) =
    Trace.with_span ~__FILE__ ~__LINE__ ("transform-prog::" ^ tf.name)
    @@ fun _ ->
    match tf.apply with
    | Prog tf -> tf p
    | Batch tf -> List.fold_left run_transform p tf
    | ProcCheck app ->
        let _ =
          ID.Map.mapi
            (fun id proc ->
              Trace.with_span ~__FILE__ ~__LINE__
                ("check-proc::" ^ tf.name ^ "::" ^ ID.to_string id)
              @@ fun _ ->
              match app proc with
              | false -> ()
              | true -> failwith @@ "Check failed: " ^ ID.to_string id)
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

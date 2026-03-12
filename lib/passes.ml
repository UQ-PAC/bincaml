open Lang
open Lang.Common

(** TODO: pass program to procedure-local passes

    TODO: structured errors for checks *)

module PassManager = struct
  type transform =
    | Prog of (Program.t -> Program.t)
        (** A transform over the whole program *)
    | Proc of (Program.proc -> Program.proc)
        (** A transform over each procedure *)
    | ProcCheck of (Program.t -> Program.proc -> bool)
        (** A check over a procedure, throw exception if false is returned
            (function should log diagnostic information) *)
    | Batch of pass list  (** Run passes in sequence *)
    | DFGAnalysis of (module Analysis.Dataflow_graph.AnalysisType)
        (** Run an analysis over SSA-form DSG and print output *)

  and pass = { name : string; apply : transform; doc : string }

  type t = { avail : pass StringMap.t }

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
        ProcCheck
          (fun _ proc ->
            Transforms.May_read_uninit.check ~include_locals:locals proc);
      doc = "Fail if the program contains read-uninitialised variables";
    }

  let dfg_bool =
    {
      name = "demo-dfg-bool-analysis";
      apply = DFGAnalysis (module Analysis.Defuse_bool.Analysis);
      doc = "runs truthiness analysis on dataflow graph and prints results";
    }

  let dfg_ival_wint_product =
    {
      name = "demoprint-dfg-ivalbits-product";
      apply =
        DFGAnalysis (module Analysis.Tnum_wint_reduced_product.DFGAnalysis);
      doc = "runs interavl analysis on dataflow graph and prints results";
    }

  let demo_ival_wint_cfg =
    {
      name = "demo-ivalwint-product-cfg";
      apply =
        Proc
          (fun p ->
            ignore @@ Analysis.Wrapped_intervals.analyse p;
            (*Analysis.Wrapped_intervals.Analysis.print_dot
              (Format.of_chan stdout) p r;*)
            p);
      doc =
        "Runs wrapped interval analysis on control flow graph and prints \
         results";
    }

  let demo_ival_wint_dfg =
    {
      name = "demo-ivalwint-product-dfg";
      apply =
        Proc
          (fun p ->
            let _ = Analysis.Wrapped_intervals.DFGAnalysis.flow_insensitive p in
            (*Analysis.Wrapped_intervals.Analysis.print_dot
              (Format.of_chan stdout) p r;*)
            p);
      doc =
        "Runs wrapped interval analysis on control flow graph and prints \
         results";
    }

  let cfg_wrapped_int =
    {
      name = "demo-cfg-wrapped-int-analysis";
      apply =
        Proc
          (fun p ->
            let _ =
              Trace_core.with_span ~__FILE__ ~__LINE__ "dfg_flow_sensitive"
              @@ fun _ -> Analysis.Wrapped_intervals.analyse p
            in
            (*Analysis.Wrapped_intervals.Analysis.print_dot
              (Format.of_chan stdout) p r;*)
            p);
      doc =
        "Runs wrapped interval analysis on control flow graph and prints \
         results";
    }

  let cfg_tnum_wint_reduced =
    {
      name = "demo-cfg-tnum-wint-reduced-analysis";
      apply =
        Proc
          (fun p ->
            let r = Analysis.Tnum_wint_reduced_product.analyse p in
            Analysis.Tnum_wint_reduced_product.Analysis.print_dot
              (Format.of_chan stdout) p r;
            p);
      doc =
        "Runs known bits and wrapped interval reduced product analysis on \
         control flow graph and prints results";
    }

  let remove_unused =
    {
      name = "remove-unused-decls";
      apply = Prog Transforms.Ssa.drop_unused_var_declarations_prog;
      doc =
        "Removes all unused variable declarations (globals and locals on each \
         procedure) from the IR program";
    }

  let sssa =
    {
      name = "simple-ssa";
      apply = Proc Transforms.Ssa.ssa;
      doc =
        "Naive SSA transform assuming all variable uses are dominated by \
         definitions from parameters";
    }

  let cleanup_cfg =
    {
      name = "remove-unreachable-block";
      apply = Proc Transforms.Cleanup_cfg.remove_blocks_unreachable_from_entry;
      doc = "Remove blocks unreachable from entry";
    }

  let full_ssa =
    {
      name = "ssa";
      apply = Batch [ cleanup_cfg; sparams; sssa; remove_unused ];
      doc =
        "Complete SSA pipeline for early IR (global register parameterless \
         form)";
    }

  let type_check =
    {
      name = "type-check";
      apply = ProcCheck Transforms.Type_check.check;
      doc = "Fail if the IR program is not type correct";
    }

  let intra_function_summaries =
    {
      name = "intra-function-summaries";
      apply = Proc Transforms.Function_summaries.intraproc_transform;
      doc = "Generate function summaries for each procedure";
    }

  let inter_function_summaries =
    {
      name = "inter-function-summaries";
      apply = Prog Transforms.Function_summaries.interproc_transform;
      doc = "Generate function summaries for each procedure";
    }

  let passes =
    [
      cleanup_cfg;
      dfg_bool;
      dfg_ival_wint_product;
      demo_ival_wint_cfg;
      demo_ival_wint_dfg;
      cfg_wrapped_int;
      cfg_tnum_wint_reduced;
      sparams;
      read_uninit false;
      read_uninit true;
      sssa;
      full_ssa;
      type_check;
      intra_function_summaries;
      inter_function_summaries;
      {
        name = "cf-expressions-smtcheck";
        apply = Prog Transforms.Cf_tx.simplify_prog_with_smt_check;
        doc =
          "Perform intra-expression simplifications and constant folding for \
           whole program and write smt log of rewrites to a file.";
      };
      {
        name = "cf-expressions";
        apply = Proc Transforms.Cf_tx.simplify_proc_exprs;
        doc =
          "Perform intra-expression simplifications and constant folding for \
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
        doc =
          "Write the results of an ide based live variable analysis to .dot \
           files";
      };
      remove_unused;
      {
        name = "lambda-lifting";
        apply =
          Prog (Transforms.Ssa.set_params ~skip_observable:false ~skip_maps:false);
        doc = "Replaces captured global variables with explicit parameters";
      };
    ]

  let print_passes =
    let open Containers_pp in
    let open Containers_pp.Infix in
    passes
    |> List.map (fun p ->
        let body =
          match p.apply with
          | Prog _ -> text "prog transform"
          | Proc _ -> text "intraproc transform"
          | ProcCheck _ -> text "proc check"
          | DFGAnalysis _ -> text "dataflow graph analysis"
          | Batch bs ->
              text "batch of "
              ^ bracket "("
                  (fill newline
                     (List.map (fun i -> bracket "\"" (text i.name) "\"") bs))
                  ")"
        in
        let doc =
          fill newline (String.split_on_char ' ' p.doc |> List.map text)
        in
        Term_color.style_l [ `Underline ] (text p.name ^ newline)
        ^ nest 2 (newline ^ text "type: " ^ body)
        ^ newline
        ^ nest 2 (newline ^ nest 2 doc))
    |> fill (newline ^ newline)

  let batch_of_list pass =
    List.map
      (fun n ->
        Option.get_exn_or ("not found: " ^ n)
        @@ List.find_opt (fun t -> String.equal t.name n) passes)
      pass

  let rec run_transform (p : Program.t) (tf : pass) =
    Trace_core.with_span ~__FILE__ ~__LINE__ ("transform-prog::" ^ tf.name)
    @@ fun _ ->
    match tf.apply with
    | Prog tf -> tf p
    | Batch tf -> List.fold_left run_transform p tf
    | DFGAnalysis (module D : Analysis.Dataflow_graph.AnalysisType) ->
        ID.Map.to_iter p.procs
        |> Iter.filter (fun (_, p) -> Procedure.graph p |> Option.is_some)
        |> Iter.iter (fun (pn, p) ->
            (*let r =
              D.analyse ~widen_set:Graph.ChaoticIteration.FromWto
                ~delay_widen:10 g
            in*)
            let r = D.flow_insensitive p in
            print_endline (D.D.name ^ " :: " ^ ID.to_string pn);
            print_endline
              Containers_pp.(
                Pretty.to_string ~width:80 @@ nest 4 (D.D.pretty r));
            (*
            print_endline "insens";
            print_endline
              Containers_pp.(
                Pretty.to_string ~width:80 @@ nest 4 (D.D.pretty r2)) *)
            ());
        p
    | ProcCheck app ->
        let _ =
          ID.Map.mapi
            (fun id proc ->
              Trace_core.with_span ~__FILE__ ~__LINE__
                ("check-proc::" ^ tf.name ^ "::" ^ ID.to_string id)
              @@ fun _ ->
              match app p proc with
              | false -> ()
              | true -> failwith @@ "Check failed: " ^ ID.to_string id)
            p.procs
        in
        p
    | Proc app ->
        let procs =
          ID.Map.mapi
            (fun id proc ->
              Trace_core.with_span ~__FILE__ ~__LINE__
                ("transform-proc::" ^ tf.name ^ "::" ^ ID.to_string id)
              @@ fun _ -> app proc)
            p.procs
        in
        { p with procs }

  let construct_batch (s : t) (passes : string list) =
    List.map (fun p -> StringMap.find p s.avail) passes

  let run_batch (batch : pass list) prog =
    List.fold_left run_transform prog batch
end

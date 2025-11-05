open Lang
open Containers
open Lang

module PassManager = struct
  type transform =
    | Prog of (Program.t -> unit)
    | Proc of (Program.proc -> unit)

  type pass = { name : string; apply : transform }

  module SMap = Map.Make (String)

  type t = { avail : pass SMap.t }

  let passes =
    [
      {
        name = "cf-expressions";
        apply = Proc Transforms.Cf_tx.simplify_proc_exprs;
      };
      {
        name = "intra-dead-store-elim";
        apply = Proc Transforms.Livevars.DSE.sane_transform;
      };
    ]

  let batch_of_list pass =
    List.map (fun n -> List.find (fun t -> String.equal t.name n) passes) pass

  let run_transform (p : Program.t) (tf : pass) =
    Trace.with_span ~__FILE__ ~__LINE__ ("transform-prog::" ^ tf.name)
    @@ fun _ ->
    match tf.apply with
    | Prog tf -> tf p
    | Proc app ->
        ID.Map.iter
          (fun id proc ->
            Trace.with_span ~__FILE__ ~__LINE__
              ("transform-proc::" ^ tf.name ^ "::" ^ ID.to_string id)
            @@ fun _ -> app proc)
          p.procs

  let construct_batch (s : t) (passes : string list) =
    List.map (fun p -> SMap.find p s.avail) passes

  let run_batch (batch : pass list) prog = List.iter (run_transform prog) batch
end

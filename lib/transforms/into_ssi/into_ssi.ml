open Bincaml_util.Common
open Lang
open Lang.Common
open Containers
open Datastructures
open Live_range_splitting
module Datastructures = Datastructures
module Renaming = Renaming
open Datastructures

(** Perform SSIfy on a specific variable in a specific procedure *)
let ssify ?splitting_strategy (v : Var.t) proc cfg dom_functions
    rev_dom_functions =
  let pv =
    match splitting_strategy with
    | None -> create_range_analysis_splitting_strategy proc v cfg
    | Some ss -> ss
  in
  let bot_var =
    Var.create Bincaml_util.Unicode.bot_char (Var.typ v) ~scope:(Var.scope v)
  in
  (* We pass the same cfg into split and rename, which should be ok, since the only
    operation on the cfg in rename is to get the second successors of a vertex, which is
    unchanged from split because we do not add or remove any vertices. *)
  SplitLiveRange.split v pv proc cfg dom_functions rev_dom_functions
  |> Renaming.rename v bot_var cfg dom_functions
  |> DeadCodeElim.clean v bot_var

(** Perform SSIfy on a procedure *)
let ssify_proc ?splitting_strategy (og_vars : Var.t Var.Decls.t)
    (proc : (Var.t, Program.e) Procedure.t) =
  match Procedure.graph proc with
  | None -> proc
  | Some cfg ->
      let dom_functions = Dom.compute_all cfg Procedure.Vert.Entry in
      let rev_dom_functions = RevDom.compute_all cfg Procedure.Vert.Return in
      Var.Decls.fold
        (fun name var p ->
          ssify ?splitting_strategy var p cfg dom_functions rev_dom_functions)
        og_vars proc

(** Perform SSIfy on a program *)
let ssify_prog ?splitting_strategy (prog : Program.t) =
  Program.map_procedures
    (fun id proc ->
      let og_vars = Var.Decls.copy (Procedure.local_decls proc) in
      ssify_proc ?splitting_strategy og_vars proc)
    prog

(** Perform SSIfy on a specific variable with a specific name in a specific
    procedure *)
let ssify_name ?splitting_strategy (v_name : String.t) proc cfg dom_functions
    rev_dom_functions =
  match Procedure.lookup_local_decl proc v_name with
  | Some v ->
      ssify ?splitting_strategy v proc cfg dom_functions rev_dom_functions
  | None -> proc

(** Perform SSIfy on a process for the variable with the given name *)
let ssify_proc_var_name ?splitting_strategy (og_vars : Var.t Var.Decls.t)
    (v_name : String.t) (proc : (Var.t, Program.e) Procedure.t) =
  match Procedure.graph proc with
  | None -> proc
  | Some cfg ->
      let dom_functions = Dom.compute_all cfg Procedure.Vert.Entry in
      let rev_dom_functions = RevDom.compute_all cfg Procedure.Vert.Return in
      if Var.Decls.mem og_vars v_name then
        ssify_name ?splitting_strategy v_name proc cfg dom_functions
          rev_dom_functions
      else proc

(** Perform SSIfy on a program for the variable with the given name *)
let ssify_prog_var_name ?splitting_strategy (v_name : String.t)
    (prog : Program.t) =
  Program.map_procedures
    (fun id proc ->
      let og_vars = Var.Decls.copy (Procedure.local_decls proc) in
      ssify_proc_var_name ?splitting_strategy og_vars v_name proc)
    prog

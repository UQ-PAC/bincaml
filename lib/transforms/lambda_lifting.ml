(** Lambda lifting: remove [Variable] globals by converting them into explicit
    in/out parameters, driven by each procedure's captures/modifies spec.
    [Function] globals are left unchanged.

    Delegates to {!Ssa.set_params} with [~skip_observable:false] and
    [~skip_maps:false], which:
    - Adds [g_in] / [g_out] parameters for every captured/modified global.
    - Inserts [%inputs] and [%returns] blocks to copy globals in and out.
    - Rewrites [Old(g)] in [ensures] and the procedure body.
    - Rewrites [requires] to replace captured globals with their in-params.
    - Updates all call sites per callee spec.

    After transformation [captures_globs]/[modifies_globs] are cleared of
    lifted globals, and all [Variable] globals are removed from the program. *)

open Lang
open Lang.Common
open Containers

let transform (p : Program.t) : Program.t =
  let p = Ssa.set_params ~skip_observable:false ~skip_maps:false p in
  let globals =
    StringMap.filter
      (fun _ decl -> match decl with Program.Variable _ -> false | _ -> true)
      p.globals
  in
  { p with globals }

open Lang
open Lang.Common
open Lang.Expr
open Ops

(* specifies memory? *)
(* memory_encoding produces the memory encoding declarations for a particular implementation *)
(* memory_specification uses the encoding to specify memory, adding in asserts/assumes and procedure specifications *)

let transform_proc (p : Program.proc) =
  let name = ID.name (Procedure.id p) in
  match name with
  | "@malloc" ->
      Procedure.set_specification p
        {
          requires = [];
          ensures = List.repeat 10 [BasilExpr.boolconst true];
          rely = [];
          guarantee = [];
          captures_globs = [];
          modifies_globs = [];
        }
  | _ -> p

let transform (p : Program.t) =
  let procs = ID.Map.map transform_proc p.procs in
  { p with procs }

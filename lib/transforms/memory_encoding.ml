open Lang
open Lang.Common
open Lang.Expr
open Ops

let transform (p : Program.proc) =
  (* print_string *)
  (* (match ID.name (Procedure.id p) with "main" -> "magic" | x -> x); *)
  (* let p' = *)
  (* Procedure.set_specification p *)
  (* { *)
  (* requires = *)
  (* [ BasilExpr.binexp ~op:`EQ (BasilExpr.const (`Bool true)) (BasilExpr.const (`Bool true)) ]; *)
  (* ensures = []; *)
  (* captures_globs = []; *)
  (* modifies_globs = []; *)
  (* rely = []; *)
  (* guarantee = []; *)
  (* } *)
  (* in *)
  (* (print_string (Containers_pp.Pretty.to_string 10 (Procedure.pretty Var.pretty Var.pretty BasilExpr.pretty p'))); *)
  (* p' *)
  p

(* type ('v, 'e) proc_spec = { *)
(* requires : BasilExpr.t list; *)
(* ensures : BasilExpr.t list; *)
(* captures_globs : 'v list; *)
(* modifies_globs : 'v list; *)
(* } *)

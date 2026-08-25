open Common
open Types
open Expr
open Containers

type e = Expr.BasilExpr.t [@@deriving show]
type proc = (Var.t, e) Procedure.t
type bloc = (Var.t, e) Block.t
type stmt = (Var.t, Var.t, e) Stmt.t
type prog_spec = { rely : e list; guarantee : e list }
type func_type = Axiom of e | Uninterpreted | Function of e [@@deriving show]

type implicit_declaration =
  | VariantCase of {
      variant : string;
      belongs_to : Types.t;
      constructor : Var.t;
    }
[@@deriving show]

type declaration =
  | Type of { binding : string; typ : Types.t }
  | Function of {
      binding : Var.t;
      attrib : Attrib.attrib_map; [@opaque]
      definition : func_type;
    }  (** pure functions *)
  | Variable of {
      binding : Var.t;
      attrib : Attrib.attrib_map; [@opaque]
      classification : e option;
    }
  | Procedure of { definition : proc [@opaque] }
  | Implicit of implicit_declaration
      (** A declaration which is not explicitly present in the ir program, but
          created by another construct, e.g. type constructors. *)
[@@deriving show]

(** {1 Printers (for debugging only)} *)

let show_e = show_e
let pp_e = pp_e
let show_func_type = show_func_type
let pp_func_type = pp_func_type
let show_implicit_declaration = show_implicit_declaration
let pp_implicit_declaration = pp_implicit_declaration
let show_declaration = show_declaration
let pp_declaration = pp_declaration

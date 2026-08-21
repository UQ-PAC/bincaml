open Common
open Types
open Expr
open Containers

type e = Expr.BasilExpr.t
type proc = (Var.t, e) Procedure.t
type bloc = (Var.t, e) Block.t
type stmt = (Var.t, Var.t, e) Stmt.t
type prog_spec = { rely : e list; guarantee : e list }
type func_type = Axiom of e | Uninterpreted | Function of e

type implicit_declaration =
  | VariantCase of {
      variant : string;
      belongs_to : Types.t;
      constructor : Var.t;
    }

type declaration =
  | Type of { binding : string; typ : Types.t }
  | Function of {
      binding : Var.t;
      attrib : Attrib.attrib_map;
      definition : func_type;
    }  (** pure functions *)
  | Variable of {
      binding : Var.t;
      attrib : Attrib.attrib_map;
      classification : e option;
    }
  | Procedure of { definition : proc }
  | Implicit of implicit_declaration
      (** A declaration which is not explicitly present in the ir program, but
          created by another construct, e.g. type constructors. *)

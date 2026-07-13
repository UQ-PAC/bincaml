(** Solve constraint system of dependently width typed bitvectors *)

open Common
open UnionFind
open Abstract_expr
open Hm_types

module Make (T : TypeExpr.TypeContext) = struct
  include Unification.Make (T)

  (** Naive solver *)

  (** Constraints between nat val types. *)
  type dependent_bv_constraints =
    | Add of { a : Typ.t; b : Typ.t; equ : Typ.t }  (** a + b = equ*)
    | AddConst of { a : Typ.t; b : int; equ : Typ.t }  (** a + b = equ*)

  let show_dependent_bv_constraints = function
    | Add { a; b; equ } ->
        Printf.sprintf "%s + %s = %s" (type_to_string a) (type_to_string b)
          (type_to_string equ)
    | AddConst { a; b; equ } ->
        Printf.sprintf "%s + (const %d) = %s" (type_to_string a) b
          (type_to_string equ)

  (** Deduce the width if two values of the constraint have inferred widths *)
  let unify_bv_constraint a : Typ.t option =
    match a with
    | Add { a; b; equ } -> (
        match List.map is_nat_val_type [ find a; find b; find equ ] with
        | [ Some _; Some _; Some _ ] -> Some equ
        | [ Some a; Some b; None ] ->
            Some (unify ~pos:[%here] (fix @@ nat_val_type (a + b)) equ)
        | [ Some a; None; Some b ] ->
            Some (unify ~pos:[%here] (fix @@ nat_val_type (b - a)) equ)
        | [ None; Some a; Some b ] ->
            Some (unify ~pos:[%here] (fix @@ nat_val_type (b - a)) equ)
        | _ -> None)
    | AddConst { a; b; equ } -> (
        match (is_nat_val_type (find a), is_nat_val_type (find equ)) with
        | Some i, None ->
            Some (unify ~pos:[%here] (fix @@ nat_val_type (i + b)) equ)
        | Some i, Some equ_c ->
            Some (unify ~pos:[%here] (fix @@ nat_val_type (i + b)) equ)
        | None, Some e ->
            Some (unify ~pos:[%here] (fix @@ nat_val_type (e - b)) a)
        | _ -> None)

  (** Naive solver; loop over constraints and unify until everything is solved.
  *)
  let solve_constraints ~max_iters cls =
    let show = List.to_string ~sep:"\n" show_dependent_bv_constraints in
    let rec solve tries cs =
      match cs with
      | [] -> ()
      | _ when tries > max_iters ->
          raise
            (TypeErr
               ("Gave up solving bitvec constraints with remaining:\n" ^ show cs))
      | cs ->
          let remaining =
            List.filter_map
              (fun c ->
                match unify_bv_constraint c with
                | Some e -> None
                | None -> Some c)
              cs
          in
          solve (tries + 1) remaining
    in
    solve 0 cls
end

(** Solve constraint system of dependently width typed bitvectors *)

open Common
open Abstract_expr
open Hm_types

module Make (Ctx : TypeExpr.TypeContext) = struct
  open Unification.Make (Ctx)
  open Hm_types.Make (Ctx)
  open Ctx
  open Ctx.Typ

  (** Naive solver *)

  (** Constraints between nat val types. *)
  type dependent_bv_constraints =
    | Add of { a : Ctx.Typ.t; b : Ctx.Typ.t; equ : Ctx.Typ.t }
        (** a + b = equ*)
    | AddConst of { a : Ctx.Typ.t; b : int; equ : Ctx.Typ.t }  (** a + b = equ*)

  let show_dependent_bv_constraints = function
    | Add { a; b; equ } ->
        Printf.sprintf "%s + %s = %s" (type_to_string a) (type_to_string b)
          (type_to_string equ)
    | AddConst { a; b; equ } ->
        Printf.sprintf "%s + (const %d) = %s" (type_to_string a) b
          (type_to_string equ)

  (** Deduce the width if two values of the constraint have inferred widths *)
  let unify_bv_constraint constr : Ctx.Typ.t option =
    match constr with
    | Add { a; b; equ } -> (
        match List.map is_nat_val_type [ find a; find b; find equ ] with
        | [ Some a_n; Some b_n; Some e_n ] ->
            (* check constraint  *)
            if a_n + b_n <> e_n then type_error (nat_val_type (a_n + b_n)) equ;
            Some equ
        | [ Some a_n; Some b_n; None ] ->
            Some (unify ~pos:[%here] (nat_val_type (a_n + b_n)) equ)
        | [ Some a_n; None; Some e_n ] ->
            Some (unify ~pos:[%here] (nat_val_type (e_n - a_n)) b)
        | [ None; Some b_n; Some e_n ] ->
            Some (unify ~pos:[%here] (nat_val_type (e_n - b_n)) a)
        | _ -> None)
    | AddConst { a; b; equ } -> (
        match (is_nat_val_type (find a), is_nat_val_type (find equ)) with
        | Some a_n, Some e_n ->
            (* check constraint  *)
            let e = nat_val_type (a_n + b) in
            Some (unify ~pos:[%here] e equ)
        | Some a_n, None ->
            Some (unify ~pos:[%here] (nat_val_type (a_n + b)) equ)
        | None, Some e_n -> Some (unify ~pos:[%here] (nat_val_type (e_n - b)) a)
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

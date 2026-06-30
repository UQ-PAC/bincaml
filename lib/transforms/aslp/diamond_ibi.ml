(** Implements control flow functionality for the IBI by using
    {!Diamond_zipper.zipper}. *)

open CCFun

(** Necessary parameters to provide IBI control flow functions. *)
module type Params = sig
  type expr

  type state
  (** Type of the state stored inside each control-flow point of the
      {!Diamond_zipper.zipper}. *)

  val diamond_get : unit -> state Diamond_zipper.zipper
  val diamond_set : state Diamond_zipper.zipper -> unit

  val diamond_make_branch : expr -> state * state * state
  (** Should return [(t,f,m)]. *)

  val equal_state : state -> state -> bool
end

(** Implements control flow functionality for the IBI by using
    {!Diamond_zipper.zipper}. See {!module-Diamond_zipper} for more details. *)
module Make (S : Params) = struct
  type branch = [ `T | `F | `M ] * S.state
  (** Branch switches are a path into the diamond.

      For downstream uses, this also records the branch direction and the state
      value at the branch merge point. *)

  let f_true_branch : branch * branch * branch -> branch = fun (t, f, m) -> t
  let f_false_branch : branch * branch * branch -> branch = fun (t, f, m) -> f
  let f_merge_branch : branch * branch * branch -> branch = fun (t, f, m) -> m

  let f_gen_branch : S.expr -> branch * branch * branch =
   fun cond ->
    let t, f, m = S.diamond_make_branch cond in

    let diamond = S.diamond_get () in
    (match Diamond_zipper.path diamond with
    | Pred _ :: _ ->
        failwith "invariant violation: f_gen_branch twice without switching"
    | _ -> ());

    diamond
    |> Diamond_zipper.append_diamond ~value:m ~left:(Diamond.empty t)
         ~right:(Diamond.empty f)
    |> S.diamond_set;

    ((`T, t), (`F, f), (`M, m))

  let f_switch_context (_, ctx) =
    S.diamond_get () |> Diamond_zipper.to_diamond
    |> Diamond_zipper.iter_zippers_backwards
    |> Iter.find_pred (S.equal_state ctx % Diamond_zipper.focus)
    |> CCOption.get_exn_or "f_switch_context: cannot find matching position"
    |> S.diamond_set
end

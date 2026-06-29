(** Implements control flow functionality for the IBI by using
    {!Diamond_zipper.diamond_zipper}. *)

(** Necessary parameters to provide IBI control flow functions. *)
module type Params = sig
  type expr

  type state
  (** Type of the state stored inside each control-flow point of the
      {!Diamond_zipper.diamond_zipper}. *)

  val diamond_get : unit -> state Diamond_zipper.diamond_zipper
  val diamond_set : state Diamond_zipper.diamond_zipper -> unit

  val diamond_make_branch : expr -> state * state * state
  (** Should return [(t,f,m)] *)
end

(** Implements control flow functionality for the IBI by using
    {!Diamond_zipper.diamond_zipper}. See {!module-Diamond_zipper} for more
    details. *)
module Make (S : Params) = struct
  type branch = Diamond_zipper.skeleton * [ `T | `F | `M ] * S.state
  (** Branch switches are a path into the diamond.

      For downstream uses, this also records the branch direction and the state
      value at the branch merge point. *)

  let f_true_branch : branch * branch * branch -> branch = fun (t, f, m) -> t
  let f_false_branch : branch * branch * branch -> branch = fun (t, f, m) -> f
  let f_merge_branch : branch * branch * branch -> branch = fun (t, f, m) -> m

  let f_gen_branch : S.expr -> branch * branch * branch =
   fun cond ->
    let diamond = S.diamond_get () in
    let t, f, m = S.diamond_make_branch cond in
    (match diamond with
    | _, Pred _ :: _ ->
        failwith "invariant violation: f_gen_branch twice without switching"
    | _ -> ());

    let t = Diamond.empty t and f = Diamond.empty f in
    let diamond =
      diamond |> Diamond_zipper.append_diamond ~left:t ~right:f ~value:m
    in
    S.diamond_set diamond;

    let t = diamond |> Diamond_zipper.move_adjacent `L |> Result.get_ok
    and f = diamond |> Diamond_zipper.move_adjacent `R |> Result.get_ok in
    let m = t |> Diamond_zipper.move_out_of |> Result.get_ok in
    let s = Diamond_zipper.focus m in
    Diamond_zipper.
      ((skeleton t, `T, s), (skeleton f, `F, s), (skeleton m, `M, s))

  let f_switch_context (skel, d, _) =
    let show b = "when moving to branch" ^ [%derive.show: [ `T | `F | `M ]] b in
    S.diamond_get () |> Diamond_zipper.to_diamond
    |> Diamond_zipper.resolve_skeleton skel
    |> Result.map_error (fun _ -> show d)
    |> CCResult.get_or_failwith |> S.diamond_set
end

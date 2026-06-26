(** Implements control flow functionality for the IBI by using
    {!Diamond.diamond_zipper}. *)

(** Necessary parameters to provide IBI control flow functions. *)
module type Params = sig
  type expr

  type state
  (** Type of the state stored inside each control-flow point of the
      {!Diamond.diamond_zipper}. *)

  val diamond_get : unit -> state Diamond.diamond_zipper
  val diamond_set : state Diamond.diamond_zipper -> unit

  val diamond_make_branch : expr -> state * state * state
  (** Should return [(t,f,m)] *)
end

(** Implements control flow functionality for the IBI by using
    {!Diamond.diamond_zipper}. See {!module-Diamond} for more details. *)
module Make (S : Params) = struct
  type branch = Diamond.skeleton * [ `T | `F | `M ] * S.state
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
    let diamond = diamond |> Diamond.append_diamond ~left:t ~right:f ~value:m in
    S.diamond_set diamond;

    let t = diamond |> Diamond.move_adjacent `L |> Result.get_ok
    and f = diamond |> Diamond.move_adjacent `R |> Result.get_ok in
    let m = t |> Diamond.move_out_of |> Result.get_ok in
    let s = Diamond.focus m in
    Diamond.((skeleton t, `T, s), (skeleton f, `F, s), (skeleton m, `M, s))

  let f_switch_context (skel, d, _) =
    let show b = "when moving to branch" ^ [%derive.show: [ `T | `F | `M ]] b in
    CCResult.guard (fun () ->
        S.diamond_get () |> Diamond.of_zipper
        |> Diamond.resolve_skeleton skel
        |> S.diamond_set)
    |> Result.map_error (fun _ -> show d)
    |> CCResult.get_or_failwith
end

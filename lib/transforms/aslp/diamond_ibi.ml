(** Implements control flow functionality for the IBI by using
    {!Diamond_zipper.zipper}. *)

open CCFun

(** Necessary parameters to provide IBI control flow functions. *)
module type Params = sig
  type expr

  type state
  (** Type of the state stored inside each control-flow point of the
      {!Diamond_zipper.zipper}.

      This is used to represent context-switch positions, so it should contain
      some inner data that is not changed by generating new branches or emitting
      ASLp statements. *)

  val diamond_get : unit -> state Diamond_zipper.zipper
  val diamond_set : state Diamond_zipper.zipper -> unit

  val diamond_make_branch : expr -> state * state * state
  (** Should return [(t,f,m)]. *)

  val equal_state : state -> state -> bool
  (** Used to locate context switch targets. This should compute equality by
      using some stable identifier within {!state}. *)
end

(** Implements control flow functionality for the IBI by using
    {!Diamond_zipper.zipper}. See {!module-Diamond_zipper} for more details. *)
module Make (S : Params) = struct
  type branch = [ `T | `F | `M ] * S.state
  (** Branch switches are a {!S.state} as returned by {!S.diamond_make_branch}.

      For downstream use, this also records the branch direction. *)

  let f_true_branch (t, f, m) = t
  let f_false_branch (t, f, m) = f
  let f_merge_branch (t, f, m) = m

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
    let zipper = S.diamond_get () in

    (* Exhaustive search, but run in breadth-first order. This is
       probably fast enough since we are always moving near the current position. *)
    Diamond_zipper.iter_bfs zipper
    |> Iter.find_pred (S.equal_state ctx % Diamond_zipper.focus)
    |> CCOption.get_exn_or "f_switch_context: cannot find matching position"
    |> S.diamond_set
end

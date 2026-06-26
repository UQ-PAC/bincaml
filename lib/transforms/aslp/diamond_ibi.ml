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
  type branch = [ `T | `F | `M ]
  (** Branch switches are identified {b relatively} at the moment.

      TODO: this is wrong in the presence of elided intermediate context
      switches (and other non-trivial cases)! *)

  let f_true_branch : branch * branch * branch -> branch = fun (t, f, m) -> t
  let f_false_branch : branch * branch * branch -> branch = fun (t, f, m) -> f
  let f_merge_branch : branch * branch * branch -> branch = fun (t, f, m) -> m

  let f_gen_branch : S.expr -> branch * branch * branch =
   fun cond ->
    let t, f, m = S.diamond_make_branch cond in
    let t = Diamond.empty t and f = Diamond.empty f in

    S.diamond_get ()
    |> Diamond.append_diamond ~left:t ~right:f ~value:m
    |> S.diamond_set;
    (`T, `F, `M)

  let f_switch_context : branch -> unit =
   fun b ->
    (b, S.diamond_get ())
    |> ( function
    | `T, diamond -> diamond |> Diamond.move_adjacent `L |> Result.get_ok
    | `F, diamond -> diamond |> Diamond.move_adjacent `R |> Result.get_ok
    | `M, diamond -> diamond |> Diamond.move_out_of |> Result.get_ok )
    |> S.diamond_set
end

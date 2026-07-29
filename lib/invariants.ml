(** Invariants (properties) which describe certain well-known states of the IR.
    Transforms can {i presuppose}, {i establish}, or {i invalidate} invariants.
    Generally, invariants are just a guide to the user and an invariant
    violation will be reported as a warning rather than an error. Additionally,
    bincaml will assume that the invariant configs specified on each pass are
    correct and complete. *)

open Lang.Common

(** Invariants (properties) which describe certain well-known states of the IR.
*)
type t =
  | SSA
  | DSA
  | NoPhis
  | Params
  | LambdaLift
  | MemoryEncoding
  | GtirbArm
  | ReducibleLoops
      (** All loops are reducible. That is, there are no {i irreducible} loops.
      *)
[@@deriving show { with_path = false }, eq, ord]

let read s =
  match s with
  | "GtirbArm" -> GtirbArm
  | "SSA" -> SSA
  | "DSA" -> DSA
  | "NoPhis" -> NoPhis
  | "Params" -> Params
  | "LambdaLift" -> LambdaLift
  | "ReducibleLoops" -> ReducibleLoops
  | "MemoryEncoding" -> MemoryEncoding
  | _ -> failwith (Printf.sprintf "cannot parse string into Invariants.t: %s" s)

let show_list xs = "[" ^ CCString.concat ", " (List.map show xs) ^ "]"

open struct
  (** Unions the two invariant lists. *)
  let ( +++ ) a b : t list =
    let a = List.sort compare a and b = List.sort compare b in
    List.sorted_merge_uniq ~cmp:compare a b

  (** Subtracts the second invariant list from the first. *)
  let ( --- ) a b : t list =
    let a = List.sort compare a and b = List.sort compare b in
    List.sorted_diff_uniq ~cmp:compare a b
end

type config = {
  presupposes : t list;
      (** Invariants which are required to hold {i before} this transform can be
          applied. *)
  establishes : t list;
      (** Invariants which are known to hold this transform. [establishes] and
          [invalidates] must be disjoint. Invariants which are not present in
          [establishes] or [invalidates] are assumed to be unchanged. *)
  invalidates : t list;
      (** Invariants which are known to {i not} hold after this transform.
          [establishes] and [invalidates] must be disjoint. *)
}
[@@deriving show]
(** Invariant specification for a particular transform pass.

    TODO: require the absence of some invariants (e.g., !SSA)?? or is this
    adequately expressed just the {!DSA} state and an [invalidates:[SSA]]
    config? *)

let make ?(presupposes = []) ?(establishes = []) ?(invalidates = []) () =
  let overlap = List.inter ~eq:equal establishes invalidates in
  if not (List.is_empty overlap) then
    invalid_arg
    @@ Printf.sprintf
         "invariant config has overlapping 'invalidates' and 'establishes': %s"
         (show_list overlap);
  { presupposes; establishes; invalidates }

let empty = make ()

let presupposes ?(establishes = []) ?(invalidates = []) presupposes =
  make ~presupposes ~establishes ~invalidates ()

let establishes ?(needs = []) ?(invalidates = []) establishes =
  let presupposes = needs in
  make ~presupposes ~establishes ~invalidates ()

(** Computes the invariant config from applying [x1] then [x2]. *)
let sequence x1 x2 =
  let presupposes = x1.presupposes +++ (x2.presupposes --- x1.establishes) in
  let establishes = x2.establishes +++ (x1.establishes --- x2.invalidates) in
  let invalidates = x2.invalidates +++ (x1.invalidates --- x2.establishes) in
  make ~presupposes ~establishes ~invalidates ()

(** Computes the invariant config from a list of values, extracting the config
    from each list using the given function. The extracted invariant configs are
    composed in {!sequence}. *)
let from_list f xs = List.fold_left sequence empty (List.map f xs)

(** Applies the given invariant config to the given current invariant state,
    emitting a warning if the necessary invariants are not satisfied. *)
let apply ~msg ~config x =
  let unsatisfied = config.presupposes --- x in
  if not (List.is_empty unsatisfied) then
    Logs.warn (fun m ->
        m "Invariants not satisfied during '%s'. Needs %s but only have %s." msg
          (show_list config.presupposes)
          (show_list x));
  x +++ config.establishes --- config.invalidates

let of_attrib (attrib_map : Lang.Attrib.attrib_map) =
  let attrib = StringMap.find_opt ".invariants" attrib_map in
  match attrib with
  | Some (`List xs) ->
      xs
      |> List.filter_map (function `String x -> Some x | _ -> None)
      |> List.map read
  | _ -> []

let to_attrib xs : Lang.Attrib.attrib_map =
  let vals = List.map (fun x -> `String (show x)) xs in
  StringMap.singleton ".invariants" (`List vals)

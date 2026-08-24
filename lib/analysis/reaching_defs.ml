open Lang
open Containers
open Common

module ProgramPoint = struct
  type block = ID.t [@@deriving ord, eq, show { with_path = false }]

  type index = Phi of int | Stmt of int
  [@@deriving ord, eq, show { with_path = false }]

  type t = block * index [@@deriving ord, eq, show { with_path = false }]
  (** a program point is a pair of block identifier plus instruction or phi node
      index. Sensitive to change in instruction counts. *)
end

module PPSet = Set.Make (ProgramPoint)

module ReachingDefDomain = struct
  let name = "defUse"

  type map =
    (PPSet.t VarMap.t
    [@printer
      fun fmt (m : map) ->
        VarMap.to_iter m
        |> Iter.to_string (fun (v, pp) ->
            Var.show v ^ " -> "
            ^ PPSet.to_string ~start:"(" ~stop:")" ~sep:", " ProgramPoint.show
                pp)
        |> Format.pp_print_string fmt])
  [@@deriving ord, eq, show { with_path = false }]

  type t = map option [@@deriving ord, eq, show { with_path = false }]

  let top = None
  let bottom = Some VarMap.empty
  let pretty t = Containers_pp.text (show t)

  let join (a : t) (b : t) : t =
    match (a, b) with
    | None, _ | _, None -> None
    | Some a, Some b ->
        Some
          (VarMap.merge
             (fun v a b ->
               match (a, b) with
               | Some a, Some b -> Some (PPSet.union a b)
               | Some a, _ | _, Some a -> Some a
               | _ -> None)
             a b)

  let leq = raise (Failure "leq unimplemmented for defUse")
  let widening a b = join a b
  let narrowing a b = a
  let init ?vertex proc = bottom

  let transfer (m : t) (stmt : Program.stmt) =
    match m with
    | Some m -> Some (match stmt with Stmt.Instr_Assign _ -> m | _ -> m)
    | _ -> m

  let transfer_phi m (p : Var.t Lang.Block.phi) = failwith ""

  type s = int * Program.stmt
end

module IntraAnalysis = Intra_analysis.Forwards (ReachingDefDomain)

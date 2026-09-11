open Lang
open Common

module FlagLattice = struct
  include Analysis.Lattice_types.FlatLattice (struct
    include Flags

    let name = "flag"
  end)

  module E = Lang.Expr.BasilExpr

  let eval_const op =
    match op with
    | `Bitvector k when Bitvec.equal k (Bitvec.zero ~size:1) -> V (Const Never)
    | `Bitvector k when Bitvec.equal k (Bitvec.one ~size:1) -> V (Const Always)
    | _ -> Top

  let eval_unop _ _ = Top
  let eval_binop _ _ _ = Top
  let eval_intrin _ _ = Top

  let contains_var v x =
    match x with Top -> false | Bot -> false | V f -> Flags.contains_var v f
end

(** Assigns flag meaning values to flag variables at each code point. If a flag
    assumes a value of a variable that gets updated, that flags value will get
    dropped and set to top. This should be precise enough still as branches
    probably only occur direct after flags are set (probably). Note that none of
    this is a problem if ssa is run prior to this transform. *)
module FlagDomain = struct
  include Analysis.Intra_analysis.MapState (FlagLattice)

  let name = "pstate-flag-analysis"

  (* Assume nothing about the initial state *)
  let init ?vertex _ =
    match vertex with Some (Some Procedure.Vert.Entry) -> top | _ -> bottom

  (** Remove flags from state that referred to [v] (e.g. if [v] was updated) *)
  let drop_modified v =
    mapi (fun v' x ->
        if FlagLattice.contains_var v x then FlagLattice.top else x)

  let transfer m stmt =
    match stmt with
    | Stmt.Instr_Assign { al } ->
        List.fold_left
          (fun m (v, e) ->
            let m = drop_modified v m in
            let f =
              Flags.extract_semantics e
              |> Option.map (fun f -> FlagLattice.V f)
              |> Option.get_or ~default:FlagLattice.top
            in
            update v f m)
          m al
    | _ -> m

  let transfer_phi m (p : Var.t Block.phi) =
    match p with
    | { lhs; rhs } ->
        (* assume phis never assign to in use variables (yikes) *)
        rhs
        |> List.map (fun (_, k) -> read k m)
        |> List.fold_left FlagLattice.join FlagLattice.bottom
        |> fun v -> drop_modified lhs m |> update lhs v
end

module FlagAnalysis = Analysis.Intra_analysis.Forwards (FlagDomain)
module Eval = Analysis.Intra_analysis.EvalExpr (FlagLattice)

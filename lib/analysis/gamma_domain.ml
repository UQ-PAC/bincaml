(* The forwards overapproximating gamma domain. *)

include Lang
include Common

module GammaSet = struct
  let name = "Gamma set"

  type t = Fin of VarSet.t | Top [@@deriving eq, ord]

  let show = function
    | Fin a -> "Fin " ^ VarSet.to_string ~start:"{" ~stop:"}" Var.show a
    | Top -> "Top"

  let pretty = Containers_pp.text % show
  let bottom = Fin VarSet.empty
  let top = Top

  let join a b =
    match (a, b) with
    | Top, _ -> Top
    | _, Top -> Top
    | Fin a, Fin b -> Fin (VarSet.union a b)

  let widening = join
end

module Domain = struct
  include Lattice_collections.LatticeMapState (GammaSet)

  let name = "Gamma domain"

  (* TODO globals *)
  let init proc =
    Procedure.formal_in_params proc
    |> StringMap.values
    |> Iter.map (fun v -> (v, GammaSet.Fin (VarSet.singleton v)))
    |> Iter.fold (fun m (v, d) -> update v d m) bottom

  let transfer m (stmt : Program.stmt) =
    let open Stmt in
    match stmt with
    | Instr_Assign a ->
        List.fold_left
          (fun m (v, e) ->
            update v
              (Expr.BasilExpr.free_vars_iter e
              |> Iter.fold (fun s v' -> V.join (read v' m) s) V.bottom)
              m)
          m a
    (* TODO calls can be more precise with modifies information (only send outputs + modifies to top) *)
    | Instr_Call _ | Instr_IntrinCall _ | Instr_IndirectCall _ ->
        TopMap KM.empty
    | _ -> m
end

module Analysis = Intra_analysis.Forwards (Domain)

let transform proc =
  let r = Analysis.analyse proc in
  let n = Procedure.id proc |> ID.to_string in
  CCIO.with_out
    ("gammadomain" ^ n ^ ".dot")
    (fun s -> Analysis.print_dot (Format.of_chan s) proc r);
  proc

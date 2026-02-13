(* The forwards overapproximating gamma domain. *)

include Lang
include Common

module Domain = struct
  include Intra_analysis.MapState (struct
    let name = "Gamma set"

    type t = VarSet.t

    let show = VarSet.to_string Var.to_string
    let pretty = Containers_pp.text % show
    let bottom = VarSet.empty
    let equal = VarSet.equal
    let compare = VarSet.compare
    let join = VarSet.union
    let widening = join
  end)

  let name = "Gamma domain"

  (* TODO globals *)
  let init proc =
    Procedure.formal_in_params proc
    |> StringMap.values
    |> Iter.map (fun v -> (v, VarSet.singleton v))
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
    (* TODO go to top *)
    | Instr_Call _ | Instr_IndirectCall _ -> m
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

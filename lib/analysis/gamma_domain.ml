(* The forwards overappraximating gamma domain. *)

include Lang
include Common
include Intra_analysis
include Lattice_collections

module GammaSet = struct
  include LatticeSet (struct
    include Var

    let show = name
    let name = "variable"
  end)

  let name = "Gamma set"
  let pp fmt v = Format.pp_print_string fmt (show v)
end

module Domain = struct
  include MapState (GammaSet)

  let name = "Gamma domain"

  (* TODO globals *)
  let init proc =
    Procedure.formal_in_params proc
    |> StringMap.values
    |> Iter.map (fun v -> (v, GammaSet.singleton v))
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
    | Instr_Call _ | Instr_IntrinCall _ | Instr_IndirectCall _ -> top
    | _ -> m
end

module Analysis = Forwards (Domain)
open Ide

module IDEDomain = struct
  let direction = `Forwards

  module Data = Var

  module DL = struct
    type t = Label of Var.t | Lambda [@@deriving eq, ord, show]
  end

  type 'a state_update = (DL.t * 'a) Iter.t

  module Value = GammaSet

  let show_state s =
    s
    |> Iter.to_string ~sep:", " (fun (v, s) ->
        Var.to_string v ^ "->" ^ GammaSet.show s)

  type t = IdEdge | ConstEdge of Value.t | JoinEdge of Value.t
  [@@deriving eq, ord, show]

  let bottom = ConstEdge Value.bottom
  let pp fmt v = Format.pp_print_string fmt (show v)
  let identity = IdEdge

  let compose a b =
    match (a, b) with
    | IdEdge, b -> b
    | a, IdEdge -> a
    | ConstEdge c, _ -> ConstEdge c
    | JoinEdge c, ConstEdge c' -> ConstEdge (Value.join c c')
    | JoinEdge c, JoinEdge c' -> JoinEdge (Value.join c c')

  let join a b =
    match (a, b) with
    | JoinEdge c, ConstEdge c'
    | JoinEdge c, JoinEdge c'
    | ConstEdge c', JoinEdge c ->
        JoinEdge (Value.join c c')
    | JoinEdge c, IdEdge
    | IdEdge, JoinEdge c
    | ConstEdge c, IdEdge
    | IdEdge, ConstEdge c ->
        JoinEdge c
    | ConstEdge c, ConstEdge c' -> ConstEdge (Value.join c c')
    | IdEdge, IdEdge -> IdEdge

  let eval s = function
    | IdEdge -> s
    | ConstEdge s' -> s'
    | JoinEdge s' -> Value.join s s'

  open DL

  let tranfer_call (c : call_info) d =
    match d with
    | Lambda -> Iter.singleton (d, IdEdge)
    | Label v when Var.is_global v -> Iter.singleton (d, IdEdge)
    | Label v ->
        Iter.of_list c.rhs
        |> Iter.filter_map (fun (d, e) ->
            Expr.BasilExpr.free_vars e |> VarSet.mem v
            |> flip Option.return_if (Label d, IdEdge))

  let transfer_return (r : ret_info) d =
    match d with
    | Lambda -> Iter.singleton (d, IdEdge)
    | Label v when Var.is_global v -> Iter.singleton (d, IdEdge)
    | Label v ->
        Iter.of_list r.lhs
        |> Iter.filter_map (fun (a, f) ->
            Var.equal f v |> flip Option.return_if (Label a, IdEdge))

  let transfer_call_to_aftercall (c : call_info) d =
    match d with
    | Lambda -> Iter.singleton (d, IdEdge)
    | Label v
      when Var.is_local v
           && (not @@ List.exists (fun (a, _) -> Var.equal a v) c.lhs) ->
        Iter.singleton (d, IdEdge)
    | _ -> Iter.empty

  let transfer_stub (s : stub_info) d =
    match d with
    | Lambda ->
        Iter.singleton (d, IdEdge)
        |> Iter.append
             (Iter.of_list s.formal_in
             |> Iter.append (Iter.of_list s.globals)
             |> Iter.map (fun v -> (Label v, ConstEdge Value.top)))
    | _ -> Iter.empty

  let transfer stmt d =
    let open Stmt in
    match stmt with
    | Instr_Assign a ->
        Iter.of_list a
        |> Iter.flat_map (fun (v', e) ->
            match d with
            | Lambda -> Iter.singleton (d, IdEdge)
            | Label v when Var.equal v v' -> Iter.empty
            | Label v when VarSet.mem v (Expr.BasilExpr.free_vars e) ->
                Iter.singleton (d, IdEdge)
            | Label v -> Iter.singleton (d, IdEdge))
    | Instr_Assume { body; branch } when branch -> (
        match d with
        (* If a variable has to be low, force it to bottom *)
        | Label v when VarSet.mem v (Expr.BasilExpr.free_vars body) ->
            Iter.empty
        | _ -> Iter.singleton (d, IdEdge))
    | Instr_Load { lhs; mem } -> (
        match d with
        | Label v when Var.equal v mem ->
            Iter.of_list [ (d, IdEdge); (Label lhs, IdEdge) ]
        | Label v when Var.equal v lhs -> Iter.empty
        | _ -> Iter.singleton (d, IdEdge))
    | Instr_Store { lhs; mem; value } -> (
        match d with
        | Label v when Var.equal v mem -> Iter.singleton (Label lhs, IdEdge)
        | Label v when VarSet.mem v (Expr.BasilExpr.free_vars value) ->
            Iter.of_list [ (d, IdEdge); (Label lhs, IdEdge) ]
        | _ -> Iter.singleton (d, IdEdge))
    | Instr_Assume _ | Instr_Assert _ -> Iter.singleton (d, IdEdge)
    | Instr_Call _ | Instr_IntrinCall _ | Instr_IndirectCall _ -> Iter.empty

  let transfer_phi (phi : Var.t Block.phi) d =
    match d with
    | Label v when List.exists (fun (_, v') -> Var.equal v v') phi.rhs ->
        Iter.singleton (Label phi.lhs, IdEdge)
    | _ -> Iter.singleton (d, IdEdge)
end

let transform proc =
  let r = Analysis.analyse proc in
  let n = Procedure.id proc |> ID.to_string in
  CCIO.with_out
    ("gammadomain" ^ n ^ ".dot")
    (fun s -> Analysis.print_dot (Format.of_chan s) proc r);
  proc

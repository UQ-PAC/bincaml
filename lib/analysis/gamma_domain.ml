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
    |> Iter.append
         ((Procedure.specification proc).captures_globs |> Iter.of_list)
    |> Iter.map (fun v -> (v, GammaSet.singleton v))
    |> Iter.fold (fun m (v, d) -> update v d m) bottom

  let transfer_state m stmt =
    let open Stmt in
    let eval_expr e =
      Expr.BasilExpr.free_vars_iter e
      |> Iter.fold (fun s v' -> V.join (m v') s) V.bottom
    in
    match stmt with
    | Instr_Assign a ->
        Iter.of_list a |> Iter.map (fun (v, e) -> (v, eval_expr e))
    | Instr_Assert _ -> Iter.empty
    | Instr_Assume _ -> Iter.empty
    | Instr_Load { lhs; rhs; addr = Scalar } -> Iter.singleton (lhs, m rhs)
    | Instr_Store { lhs; value; addr = Scalar } ->
        Iter.singleton (lhs, eval_expr value)
    | Instr_Load { lhs; rhs } -> Iter.singleton (lhs, m rhs)
    | Instr_Store { lhs; value } ->
        Iter.singleton (lhs, V.join (m lhs) (eval_expr value))
    | Instr_Call { lhs } | Instr_IntrinCall { lhs } ->
        StringMap.values lhs |> Iter.map (fun v -> (v, GammaSet.top))
    (* need to globally go to top which the transfer_state api doesn't support *)
    (*| Instr_IndirectCall c -> raise (Failure "unsupported")*)
    | Instr_IndirectCall _ -> Iter.empty

  let transfer m (stmt : Program.stmt) =
    let open Stmt in
    match stmt with
    (* TODO calls can be more precise with modifies information (only send outputs + modifies to top) but this requires spec info *)
    | Instr_Call _ | Instr_IntrinCall _ | Instr_IndirectCall _ -> top
    | s ->
        transfer_state (fun v -> read v m) s
        |> Iter.fold (fun m (v, s) -> update v s m) m
end

module CFGAnalysis = Forwards (Domain)
module DFGAnalysis = Dataflow_graph.AnalysisFwd (Domain)
open Ide

(* TODO modifies set on statements to avoid doing lots of trivial id transfers
   on unchanged ssa vars alternatively summaries for dead variables (referring
   to a live var analysis) could be dropped *)
module IDEDomain = struct
  let direction = `Forwards

  module Data = Var

  module DL = struct
    type t = Label of Var.t | Lambda
    [@@deriving eq, ord, show { with_path = false }]
  end

  type 'a state_update = (DL.t * 'a) Iter.t

  module Value = GammaSet

  let show_state s =
    s
    |> Iter.to_string ~sep:", " (fun (v, s) ->
        Var.to_string v ^ "->" ^ GammaSet.show s)

  type t = BottomEdge | IdEdge | TopEdge
  [@@deriving eq, ord, show { with_path = false }]

  let bottom = BottomEdge
  let pp fmt v = Format.pp_print_string fmt (show v)
  let identity = IdEdge

  let compose a b =
    match (a, b) with
    | IdEdge, b -> b
    | a, IdEdge -> a
    | BottomEdge, _ -> BottomEdge
    | TopEdge, _ -> TopEdge

  let join a b =
    match (a, b) with
    | BottomEdge, e | e, BottomEdge -> e
    | TopEdge, _ | _, TopEdge -> TopEdge
    | IdEdge, IdEdge -> IdEdge

  let eval s = function
    | BottomEdge -> Value.bottom
    | IdEdge -> s
    | TopEdge -> Value.top

  open DL

  let transfer_call (c : call_info) d =
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
             |> Iter.map (fun v -> (Label v, TopEdge)))
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
    | Instr_Load { lhs; rhs } -> (
        match d with
        | Label v when Var.equal v rhs ->
            Iter.of_list [ (d, IdEdge); (Label lhs, IdEdge) ]
        | Label v when Var.equal v lhs -> Iter.empty
        | _ -> Iter.singleton (d, IdEdge))
    | Instr_Store { lhs; rhs; value } -> (
        match d with
        | Label v when Var.equal v rhs -> Iter.singleton (Label lhs, IdEdge)
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

module IDEAnalysis = IDE (IDEDomain)

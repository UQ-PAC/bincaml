(** The forwards overapproximating gamma domain. It is assumed that the program
    is in ssa form. *)

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
  let[@warning "-32"] pp fmt v = Format.pp_print_string fmt (show v)
end

module Domain = struct
  include MapState (GammaSet)

  let name = "Gamma domain"

  let init ?(vertex = None) proc =
    Procedure.formal_in_params proc
    |> StringMap.values
    |> Iter.append
         ((Procedure.specification proc).captures_globs |> Iter.of_list)
    |> Iter.map (fun v -> (v, GammaSet.singleton v))
    |> Iter.fold (fun m (v, d) -> update v d m) bottom

  let transfer_phi m (p : Var.t Block.phi) =
    match p with
    | { lhs; rhs } ->
        rhs
        |> List.map (fun (_, k) -> read k m)
        |> List.fold_left GammaSet.join GammaSet.bottom
        |> fun v -> update lhs v m

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
    (* could use IDE summaries, but that requires access to formal in params of caller *)
    | Instr_Call { lhs } ->
        StringMap.values lhs |> Iter.map (fun v -> (v, GammaSet.top))
    (* need to globally go to top which the transfer_state api doesn't support *)
    | Instr_IntrinCall { lhs } ->
        List.to_iter lhs |> Iter.map (fun v -> (v, GammaSet.top))
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
open Idessi

(* TODO handle memory nicely *)
module IDEDomain : IDESSIDomain = struct
  let direction = `Forwards

  module DL = struct
    type t = Lambda | Label of Var.t
    [@@deriving eq, ord, show { with_path = false }]

    let show = function Lambda -> "L" | Label v -> Var.name v
  end

  module Value = GammaSet

  let[@warning "-32"] show_state s =
    s
    |> Iter.to_string ~sep:", " (fun (v, s) ->
        Var.to_string v ^ "->" ^ GammaSet.show s)

  type t = BottomEdge | IdEdge | TopEdge
  [@@deriving eq, ord, show { with_path = false }]

  let[@warning "-32"] pp fmt v = Format.pp_print_string fmt (show v)
  let identity = IdEdge
  let bottom = BottomEdge
  let top = TopEdge

  let compose a b =
    match a with IdEdge -> b | BottomEdge -> BottomEdge | TopEdge -> TopEdge

  let join a b =
    match (a, b) with
    | BottomEdge, e | e, BottomEdge -> e
    | TopEdge, _ | _, TopEdge -> TopEdge
    | IdEdge, IdEdge -> IdEdge

  let eval s = function
    | BottomEdge -> Value.bottom
    | IdEdge -> s
    | TopEdge -> Value.top

  let init_data (proc : Program.proc) =
    Procedure.formal_in_params proc |> StringMap.values

  type state_update = (DL.t * t) Iter.t

  open DL

  let transfer_call call params d =
    match d with
    | Lambda -> Iter.singleton (d, IdEdge)
    | Label v ->
        StringMap.to_iter call
        |> Iter.filter (fun (_, e) ->
            Expr.BasilExpr.free_vars e |> VarSet.mem v)
        |> Iter.map (fun (s, _) -> (Label (StringMap.find s params), IdEdge))

  let transfer stmt d =
    let open Stmt in
    match d with
    | Lambda -> (
        match stmt with
        | Instr_Load l -> Iter.singleton (Label l.lhs, TopEdge)
        | _ -> Iter.empty)
    | Label v -> (
        match stmt with
        | Instr_Assign a ->
            Iter.of_list a
            |> Iter.flat_map (fun (v', e) ->
                if VarSet.mem v (Expr.BasilExpr.free_vars e) then
                  Iter.singleton (Label v', IdEdge)
                else Iter.empty)
        | _ -> Iter.empty)

  let transfer_phi lhs rhs d =
    match d with
    | Lambda -> Iter.empty
    | Label v -> Iter.singleton (Label lhs, IdEdge)

  let init_p2 (proc : Program.proc) =
    Procedure.formal_in_params proc
    |> StringMap.values
    |> Iter.map (fun v -> (v, Value.singleton v))
end

module IDEAnalysis = IDESSI (IDEDomain)

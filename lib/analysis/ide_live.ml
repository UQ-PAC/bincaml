(** Interprocedural live variable analysis using the IDE solver *)

open Lang
open Containers
open Common
open Ide

module IDELive = struct
  let direction = `Backwards

  module Data = Var

  (* DL and state_update were already defined! Is there a way to avoid
     redefining them? *)
  module DL = struct
    type t = Label of Var.t | Lambda [@@deriving eq, ord, show]
  end

  type 'a state_update = (DL.t * 'a) Iter.t

  module Value = struct
    type t = bool [@@deriving eq, ord, show]

    let bottom = false
    let live : t = true
    let dead : t = false

    let join a b =
      match (a, b) with
      | true, _ -> true
      | _, true -> true
      | false, false -> false
  end

  let show_state s =
    s
    |> Iter.filter_map (function c, true -> Some c | _ -> None)
    |> Iter.to_string ~sep:", " (fun v -> Var.to_string v)

  open Value

  type t = IdEdge | ConstEdge of Value.t [@@deriving eq, ord]

  let bottom = ConstEdge bottom

  let show v =
    match v with IdEdge -> "IdEdge" | ConstEdge v -> "ConstEdge " ^ show v

  let pp fmt v = Format.pp_print_string fmt (show v)
  let identity = IdEdge

  let compose a b =
    match (a, b) with
    | IdEdge, b -> b
    | a, IdEdge -> a
    | ConstEdge v, ConstEdge v' -> ConstEdge v

  let join a b =
    match (a, b) with
    | ConstEdge v, ConstEdge v' -> ConstEdge (join v v')
    | ConstEdge true, IdEdge -> ConstEdge true
    | ConstEdge false, IdEdge -> IdEdge
    | IdEdge, ConstEdge true -> ConstEdge true
    | IdEdge, ConstEdge false -> IdEdge
    | IdEdge, IdEdge -> IdEdge

  let eval f v = match f with IdEdge -> v | ConstEdge v -> v

  open DL

  let transfer_call (c : call_info) d =
    match d with
    | Lambda -> Iter.singleton (d, IdEdge)
    | Label v when Var.is_global v -> Iter.singleton (d, IdEdge)
    | Label v when List.exists (fun (a, _) -> Var.equal a v) c.lhs ->
        Iter.of_list c.lhs
        |> Iter.filter (fun (a, _) -> Var.equal a v)
        |> Iter.map (fun (_, f) -> (Label f, IdEdge))
    | Label v -> Iter.empty

  let transfer_return (r : ret_info) d =
    match d with
    | Lambda -> Iter.singleton (d, IdEdge)
    | Label v when Var.is_global v -> Iter.singleton (d, IdEdge)
    | Label v when List.exists (fun (f, _) -> Var.equal f v) r.rhs ->
        Iter.of_list r.rhs
        |> Iter.filter (fun (a, _) -> Var.equal a v)
        |> Iter.flat_map (fun (_, e) ->
            Expr.BasilExpr.free_vars_iter e
            |> Iter.map (fun v' -> (Label v', IdEdge)))
    | _ -> Iter.empty

  let transfer_call_to_aftercall c d =
    match d with
    | Lambda -> Iter.singleton (d, IdEdge)
    | Label v
      when Var.is_local v
           && (not @@ List.exists (fun (a, _) -> Var.equal a v) c.lhs) ->
        Iter.singleton (d, IdEdge)
    | Label _ -> Iter.empty

  let transfer_stub (s : stub_info) d =
    match d with
    | Lambda ->
        Iter.singleton (d, IdEdge)
        |> Iter.append
             (Iter.of_list s.formal_in
             |> Iter.map (fun v -> (Label v, ConstEdge live)))
        |> Iter.append
             (Iter.of_list s.globals
             |> Iter.map (fun v -> (Label v, ConstEdge live)))
    | _ -> Iter.empty

  let transfer stmt d =
    let open Stmt in
    match d with
    | Lambda -> (
        match stmt with
        | Instr_Assign _ -> Iter.singleton (d, IdEdge)
        | _ ->
            Stmt.free_vars_iter stmt
            |> Iter.map (fun v -> (Label v, ConstEdge live))
            |> Iter.cons (d, IdEdge))
    | Label v -> (
        match stmt with
        | Instr_Assign assigns ->
            List.fold_left
              (fun i (v', ex) ->
                Iter.flat_map
                  (fun (d, e) ->
                    if DL.equal d (Label v') then
                      Expr.BasilExpr.free_vars_iter ex
                      |> Iter.map (fun v' -> (Label v', IdEdge))
                    else Iter.singleton (d, e))
                  i)
              (Iter.singleton (d, IdEdge))
              assigns
        (* The index variables of a memory read are always live regardless of if
           the lhs was dead, since there are still side effects of reading
           memory ? *)
        | Instr_Load l when Var.equal l.lhs v -> Iter.empty
        | Instr_IntrinCall c
          when StringMap.exists (fun _ v' -> Var.equal v v') c.lhs ->
            Iter.empty
        | Instr_Call c when StringMap.exists (fun _ v' -> Var.equal v v') c.lhs
          ->
            Iter.empty
        (*| Instr_IndirectCall c -> top *)
        | Instr_IndirectCall c -> Iter.singleton (Label v, IdEdge) (* Unsound *)
        | Instr_Assert _ | Instr_Assume _ | Instr_Load _ | Instr_Store _
        | Instr_Call _ | Instr_IntrinCall _ ->
            Iter.singleton (Label v, IdEdge))

  (* TODO test*)
  let transfer_phi (phi : Var.t Block.phi) d =
    match d with
    | Label v when Var.equal phi.lhs v ->
        Iter.of_list phi.rhs |> Iter.map (fun (_, v) -> (Label v, IdEdge))
    | _ -> Iter.singleton (d, IdEdge)
end

module IDELiveAnalysis = IDE (IDELive)

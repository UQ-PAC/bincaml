open Lang
open Common

module Constraint = struct
  type 'e t =
    | Mem of { addr : 'e; value : 'e }
    | Call of { lhs : 'e StringMap.t; args : 'e StringMap.t }
  [@@deriving eq, map]

  let show s = function
    | Mem { addr; value } -> Printf.sprintf "[|%s|] -> %s" (s addr) (s value)
    | Call _ -> "todo"

  let gen_constraints (p : Program.proc) =
    let open Stmt in
    Procedure.fold_blocks_topo_fwd
      (fun acc bid ->
        Block.fold_forwards ~phi:const
          ~f:(fun acc stmt ->
            match stmt with
            | Instr_Load { lhs; addr = Addr { addr } } ->
                Mem { addr; value = Expr.BasilExpr.rvar lhs } :: acc
            | Instr_Store { value; addr = Addr { addr } } ->
                Mem { addr; value } :: acc
            | Instr_Call { lhs; args } ->
                Call { lhs = StringMap.map Expr.BasilExpr.rvar lhs; args }
                :: acc
            | _ -> acc)
          acc)
      [] p
end

open Wrapped_intervals
module Interval = WrappedIntervalsLattice

module DSGraph = struct
  (* A path compressed cell. Cells store a set of offsets from an abstract base
     address, and the node that it belongs to. *)
  type content =
    | Cell of { offsets : Interval.t; node : node ref; pointees : cell list }
    | Path of cell

  and cell = content ref
  and node = unit

  let init offsets node : cell = ref (Cell { offsets; node; pointees = [] })

  let join (c1 : cell) (c2 : cell) =
    match !c2 with
    | Path _ -> failwith "Attempted to join old cell"
    | _ -> c2 := Path c1

  let rec find (c : cell) =
    match !c with
    | Path c' ->
        let p = find c' in
        c := Path p;
        p
    | Cell _ -> c

  let offsets (c : cell) =
    match !(find c) with
    | Cell { offsets } -> offsets
    | _ -> failwith "Union find returned non terminal cell"

  let node (c : cell) =
    match !(find c) with
    | Cell { node } -> node
    | _ -> failwith "Union find returned non terminal cell"

  let pointees (c : cell) =
    match !(find c) with
    | Cell { pointees } -> pointees
    | _ -> failwith "Union find returned non terminal cell"
end

module SBMap = Map.Make (Sva.SymBase)

let make_local_graph (constraints : Sva.SymAddrSetLattice.t Constraint.t list) =
  (* Create just the cells *)
  let add_cells sv m = failwith "todo" in

  let g =
    List.fold_left
      (fun acc constr ->
        match constr with
        | Constraint.Mem { addr; value } ->
            let acc, ptrs = add_cells addr acc in
            let acc, vals = add_cells value acc in
            (* TODO Add edges between (unify later) *)
            acc
        | Constraint.Call { lhs; args } -> failwith "todo")
      SBMap.empty constraints
    |> SBMap.values |> Iter.to_list
  in

  g

let dsa (p : Program.t) =
  let sva_r = Sva.sva p in
  let _local_graphs =
    IDMap.mapi
      (fun pid r ->
        let proc = IDMap.find pid p.procs in
        let constraints =
          Constraint.gen_constraints proc
          |> List.map
               (Constraint.map
                  (Sva.Eval.EV.eval (flip Sva.StateAbstraction.read r)))
        in
        make_local_graph constraints)
      sva_r
  in
  p

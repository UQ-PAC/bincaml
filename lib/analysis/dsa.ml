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
    Procedure.iter_blocks_topo_fwd p
    |> Iter.flat_map (fun (bid, block) -> Block.stmts_iter block)
    |> Iter.filter_map (fun stmt ->
        match stmt with
        | Instr_Load { lhs; addr = Addr { addr } } ->
            Some (Mem { addr; value = Expr.BasilExpr.rvar lhs })
        | Instr_Store { value; addr = Addr { addr } } ->
            Some (Mem { addr; value })
        | Instr_Call { lhs; args } ->
            Some (Call { lhs = StringMap.map Expr.BasilExpr.rvar lhs; args })
        | _ -> None)
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

let make_local_graph (constraints : Sva.SymAddrSetLattice.t Constraint.t Iter.t)
    =
  (* Create just the cells *)
  let add_cells sv m = failwith "todo" in

  let g =
    Iter.fold
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

  (* make joining nodes unify with union find

     solve:
     join overlapping cells in nodes
     init workist to sets of codomains of cells greater than 1 in size
     // maybe worklist isn't needed and we can just iterate over all cells
     // wrapped intervals i think might make the join order not invariant
     for each:
         unify set
         grow worklist

     unify set S:
     compute offsets per node
     // what if we used a funky data structure that encoded a union of intervals, instead of imprecisely joining them and deleting their holes?!
     make all nodes of cells to be unified point to a single node (offsets adjusted)
     fix overlapping intervals

     the union of intervals data structure (might not work) alternatively this is a data structure to represent nodes:
     leaves: intervals that are all disjoint
     binary branches:
         leaves are all disjoint intervals with ordering invariant
         approximates a whole interval (join of all leaves)
         the left branch has its own interval range
         the right too
         store on the branch the interval between the left branch's right point and right branches left point
     element of queries are log n
     does there exist an efficient algorithm to join two trees?! what about n trees? what if we want to add offsets to trees we are joining?
     looks like yes, since such algorithms exist for various balanced bsts
     offsets can probably be handled too as edges in the tree
     *)
  g

let dsa (p : Program.t) =
  let sva_r = Sva.sva p in
  (*
  let _local_graphs =
    IDMap.mapi
      (fun pid r ->
        let proc = Program.proc p pid in
        let constraints =
          Constraint.gen_constraints proc
          |> Iter.map
               (Constraint.map
                  (Sva.Eval.EV.eval (flip Sva.StateAbstraction.read r)))
        in
        make_local_graph constraints)
      sva_r
  in
  *)
  p

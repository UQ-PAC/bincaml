open Wrapped_intervals
module Interval = WrappedIntervalsLattice

module DSGraph = struct
  type content =
    | Cell of { offsets : Interval.t; node : node ref; pointees : cell list }
    | Path of cell

  and cell = content ref
  and node = unit

  let init offsets node = ref (Cell { offsets; node; pointees = [] })

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

  let pointees (c : cell) =
    match !(find c) with
    | Cell { pointees } -> pointees
    | _ -> failwith "Union find returned non terminal cell"
end

let compose f g x = f (g x)
let get_or_else x default = match x with Some x -> x | None -> default ()
let or_else default x = match x with Some x -> x | None -> default ()

module IntMap = Map.Make (Int)
module IntSet = Set.Make (Int)
module StringMap = Map.Make (String)

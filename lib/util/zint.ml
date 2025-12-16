type t = Z.t

let pp = Z.pp_print
let show i = Z.to_string i
let to_string i = show i
let equal i j = Z.equal i j
let compare i j = Z.compare i j
let hash i = Z.hash i

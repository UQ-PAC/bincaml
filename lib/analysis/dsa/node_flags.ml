(* A bool uses 64 bits of memory and we're storing flags per node so it's probably worth using bitflags *)
type t = int

let empty = 0
let ( >> ) = Int.shift_right_logical
let ( << ) = Int.shift_left
let ( || ) = Int.logor
let ( & ) = Int.logand
let[@inline] ( != ) a b = not @@ (a = b)
let[@inline] get_flag idx f = (f >> idx & 1) != 0
let[@inline] set_flag idx f = f || 1 << idx
let[@inline] clear_flag idx f = f & Int.lognot (1 << idx)

(* CCBitField didn't have a join function :( *)
let join = ( || )

(* Should be used like `get_flag heap f` or `clear_flag unknown f` *)

(** Whether this node may store heap memory *)
let heap = 0

(** Whether this node may store stack memory *)
let stack = 1

(** Whether this node may store globals *)
let global = 2

(** Whether this node holds memory from an unknown source *)
let unknown = 3

(** Whether complete information is known about this node (TODO set this flag)
*)
let complete = 4

(** Whether the node has collapsed and lost field sensitivity *)
let collapsed = 5

let show f =
  (if get_flag heap f then "H" else "")
  ^ (if get_flag stack f then "S" else "")
  ^ (if get_flag global f then "G" else "")
  ^ (if get_flag unknown f then "U" else "")
  ^ (if get_flag complete f then "C" else "")
  ^ if get_flag collapsed f then "O" else ""

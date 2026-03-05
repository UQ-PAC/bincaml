type t = field list [@@deriving eq, ord]
and field = { offset : Z.t; value : Bitvec.t }

let show_field { offset; value } =
  Z.to_string offset ^ " : " ^ Bitvec.to_string value

let show (record : t) =
  List.fold_left (fun acc field -> acc ^ show_field field ^ ", ") "" record

let to_string v = show v
let pp fmt b = Format.pp_print_string fmt (show b)

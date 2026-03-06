module ZMap = Map.Make (Z)

type t = field ZMap.t [@@deriving eq, ord]
and field = { value : Bitvec.t; typ : Types.t }

let get_field offset record : field =
  match ZMap.find_opt offset record with
  | None -> failwith @@ "No field at offset " ^ Z.to_string offset
  | Some f -> f

let set_field offset record value =
  let { typ; _ } = get_field offset record in
  ZMap.add offset { typ; value } record

let show_field { value; typ } =
  Printf.sprintf "(%s, %s)" (Bitvec.to_string value) @@ Types.to_string typ

let show (record : t) =
  ZMap.fold
    (fun offset field acc ->
      acc ^ Z.to_string offset ^ " : " ^ show_field field ^ ", ")
    record ""

let to_string v = show v
let pp fmt b = Format.pp_print_string fmt (show b)

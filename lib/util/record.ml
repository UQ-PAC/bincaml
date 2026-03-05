type t = field list [@@deriving eq, ord]
and field = { offset : Z.t; value : Bitvec.t }

let get_field offset1 fields : Bitvec.t =
  match List.find_opt (fun { offset; _ } -> Z.equal offset offset1) fields with
  | None -> failwith @@ "No field at offset " ^ Z.to_string offset1
  | Some { value; _ } -> value

let set_field offset1 (value1 : Bitvec.t) fields : t =
  List.map
    (fun { offset; value } ->
      if Z.equal offset offset1 then { offset; value = value1 }
      else { offset; value })
    fields

let show_field { offset; value } =
  Z.to_string offset ^ " : " ^ Bitvec.to_string value

let show (record : t) =
  List.fold_left (fun acc field -> acc ^ show_field field ^ ", ") "" record

let to_string v = show v
let pp fmt b = Format.pp_print_string fmt (show b)

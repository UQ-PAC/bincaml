type 'a t = 'a Array.t

let to_list = Array.to_list
let to_size = Array.length

let make = Array.make
let get = Array.get

let set xs i x =
  if not (0 <= i && i < Array.length xs) then
    invalid_arg "";
  Array.set xs i x

module Type = struct
  type t =
    | BVVar of string
    | Int
    | BV of int
    | Bool
    | Var of string
    | Sort of string
    | Fun of t * t
end

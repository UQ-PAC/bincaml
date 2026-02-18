type parsed =
  | Keyword of ((int * int) * string)
  | Comment of ((int * int) * string)
[@@deriving show]

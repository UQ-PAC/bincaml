let make_of_string ?(case_sensitive = true) ~min ~max ~of_int ~show =
  let map =
    Iter.int_range ~start:min ~stop:max
    |> Iter.filter_map of_int
    |> Iter.map (CCPair.dup_map show)
    |> Iter.map CCPair.swap
    |> Iter.map
         (if case_sensitive then Fun.id
          else CCPair.map String.lowercase_ascii Fun.id)
    |> Common.StringMap.of_iter
  in
  fun s ->
    let s = if case_sensitive then s else String.lowercase_ascii s in
    Common.StringMap.find_opt s map

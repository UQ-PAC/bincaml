let make_of_string ~min ~max ~of_int ~show =
  let map =
    Iter.int_range ~start:min ~stop:max
    |> Iter.filter_map of_int
    |> Iter.map (CCPair.dup_map show)
    |> Iter.map CCPair.swap |> Common.StringMap.of_iter
  in
  Fun.flip Common.StringMap.find_opt map

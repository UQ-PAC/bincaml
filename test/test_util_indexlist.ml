(* TODO decide on how flags should be tested (if at all) maybe only test in
        expect tests and also symbolic bases probably*)

module M = Bincaml_util.Indexed_list.Make (struct
  include Int

  let show = Int.to_string
end)

let ppair (a, b) = "(" ^ Int.to_string a ^ "," ^ Int.to_string b ^ ")"
let pr msg m = print_endline @@ msg ^ ": " ^ Iter.to_string ppair (M.to_iter m)

let%expect_test "app" =
  let m = M.of_list [ (1, 1); (2, 2) ] in
  pr "of list [1,1; 2,2]    " m;
  let m = M.of_iter (CCList.to_iter [ (1, 1); (2, 2) ]) in
  pr "of iter [1,1; 2,2]    " m;
  let m = M.append 10 10 m in
  pr "10,10 appended        " m;
  let m = M.prepend 5 5 m in
  pr "5,5 prepended         " m;
  let m = M.prepend 1 2 m in
  pr "1,1 replaced w. 1,2   " m;
  let m = M.append 1 3 m in
  pr "1,2 replaced w. 1,3   " m;
  let m = M.insert_before ~before:(fun k v -> k = 2) 50 50 m in
  pr "50,50 ins before (2,_)" m;
  let m = M.insert_before_key ~before:50 11 11 m in
  pr "11,11 ins before (50,)" m;
  let m = M.insert_at_index ~before_index:1 12 12 m in
  pr "12,12 ins at index 1  " m;
  let m =
    M.insert_list_before ~before:(fun k v -> k = 11) [ (21, 21); (22, 22) ] m
  in
  pr "[21,21;22,22]ins bf11," m;
  let m = M.append_list [ (31, 31); (32, 32) ] m in
  pr "[31,31;32,32] appended" m;
  let m = M.map (fun v -> v + 1) m in
  pr "map adding 1          " m;
  let m = M.mapi (fun idx k v -> v + 1) m in
  pr "mapi adding 1         " m;
  let m = M.remove 21 m in
  pr "remove 21             " m;
  let m = M.remove 5 m in
  pr "remove 5              " m;
  let ms = M.sort (fun (_, a) (_, b) -> Int.compare a b) m in
  pr "sort values           " ms;
  let ms = M.sort_by_keys Int.compare m in
  pr "sort keys             " ms;
  ();
  [%expect
    {|
    of list [1,1; 2,2]    : (1,1), (2,2)
    of iter [1,1; 2,2]    : (1,1), (2,2)
    10,10 appended        : (1,1), (2,2), (10,10)
    5,5 prepended         : (5,5), (1,1), (2,2), (10,10)
    1,1 replaced w. 1,2   : (5,5), (1,2), (2,2), (10,10)
    1,2 replaced w. 1,3   : (5,5), (1,3), (2,2), (10,10)
    50,50 ins before (2,_): (5,5), (1,3), (50,50), (2,2), (10,10)
    11,11 ins before (50,): (5,5), (1,3), (11,11), (50,50), (2,2), (10,10)
    12,12 ins at index 1  : (5,5), (12,12), (1,3), (11,11), (50,50), (2,2), (10,10)
    [21,21;22,22]ins bf11,: (5,5), (12,12), (1,3), (21,21), (22,22), (11,11), (50,50), (2,2), (10,10)
    [31,31;32,32] appended: (5,5), (12,12), (1,3), (21,21), (22,22), (11,11), (50,50), (2,2), (10,10), (31,31), (32,32)
    map adding 1          : (5,6), (12,13), (1,4), (21,22), (22,23), (11,12), (50,51), (2,3), (10,11), (31,32), (32,33)
    mapi adding 1         : (5,7), (12,14), (1,5), (21,23), (22,24), (11,13), (50,52), (2,4), (10,12), (31,33), (32,34)
    remove 21             : (5,7), (12,14), (1,5), (22,24), (11,13), (50,52), (2,4), (10,12), (31,33), (32,34)
    remove 5              : (12,14), (1,5), (22,24), (11,13), (50,52), (2,4), (10,12), (31,33), (32,34)
    sort values           : (2,4), (1,5), (10,12), (11,13), (12,14), (22,24), (31,33), (32,34), (50,52)
    sort keys             : (1,5), (2,4), (10,12), (11,13), (12,14), (22,24), (31,33), (32,34), (50,52)
    |}]

let%expect_test "append" =
  let m = M.of_list [] in
  let m = M.append_list [ (31, 31); (32, 32) ] m in
  pr "[31,31;32,32] appended" m;
  ();
  [%expect {| [31,31;32,32] appended: (31,31), (32,32) |}]

let%expect_test "remove empty" =
  let m = M.remove 5 M.empty in
  pr "remove from empty" m;
  let m = M.append_list [ (31, 31); (32, 32) ] M.empty in
  let m = M.remove 5 m in
  pr "remove nonexistent" m;
  let m = M.update 31 (function _ -> None) m in
  pr "update rm  31     " m;
  let m = M.update 32 (function Some k -> Some 33 | _ -> None) m in
  pr "update 32->33     " m;
  [%expect
    {|
    remove from empty:
    remove nonexistent: (31,31), (32,32)
    update rm  31     : (32,32)
    update 32->33     : (32,33)
    |}]

let%expect_test "empty" =
  let m = M.remove 5 M.empty in
  pr "remove from empty" m;
  let m = M.append_list [ (31, 31); (32, 32) ] M.empty in
  let m = M.remove 5 m in
  pr "remove nonexistent" m;
  [%expect
    {|
    remove from empty:
    remove nonexistent: (31,31), (32,32)
    |}]

open Containers

let%expect_test "invalid from list" =
  try
    let m = M.of_list [ (1, 31); (1, 32) ] in
    pr "remove nonexistent" m
  with Assert_failure _ ->
    print_endline "assert failure";
    [%expect {| assert failure |}]

let%expect_test "index off by one?" =
  let m = M.of_list [ (0, 0); (1, 1); (2, 2) ] in
  m
  |> M.insert_at_index ~before_index:0 101 101
  |> M.to_list |> [%derive.show: (int * int) list] |> print_endline;
  m
  |> M.insert_at_index ~before_index:1 102 102
  |> M.to_list |> [%derive.show: (int * int) list] |> print_endline;
  m
  |> M.insert_at_index ~before_index:2 103 103
  |> M.to_list |> [%derive.show: (int * int) list] |> print_endline;
  m
  |> M.insert_at_index ~before_index:3 104 104
  |> M.to_list |> [%derive.show: (int * int) list] |> print_endline;
  m
  |> M.insert_at_index ~before_index:4 105 105
  |> M.to_list |> [%derive.show: (int * int) list] |> print_endline;
  m
  |> M.insert_at_index ~before_index:(-1) 101 101
  |> M.to_list |> [%derive.show: (int * int) list] |> print_endline;
  m
  |> M.insert_at_index ~before_index:(-2) 101 101
  |> M.to_list |> [%derive.show: (int * int) list] |> print_endline;
  ();
  [%expect {|
    [(101, 101); (0, 0); (1, 1); (2, 2)]
    [(0, 0); (102, 102); (1, 1); (2, 2)]
    [(0, 0); (1, 1); (103, 103); (2, 2)]
    [(0, 0); (1, 1); (2, 2); (104, 104)]
    [(0, 0); (105, 105); (1, 1); (2, 2)]
    [(101, 101); (0, 0); (1, 1); (2, 2)]
    [(101, 101); (0, 0); (1, 1); (2, 2)]
    |}]

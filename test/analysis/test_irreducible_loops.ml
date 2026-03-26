open Bincaml_util.Common
open Analysis.Irreducible_loop

type test_comparison = {
  iloop_headers : string StringMap.t;
  headers : StringSet.t StringMap.t;
}
[@@deriving eq, show]

let id_map equal str =
  Alcotest.testable
    (fun f p ->
      Format.pp_print_string f
        (StringMap.to_iter p
        |> Iter.to_string ~sep:", " (fun (k, v) -> k ^ "->" ^ str v)))
    (StringMap.equal equal)

let id_set =
  Alcotest.testable
    (fun f p -> Format.pp_print_string f (ID.Set.to_string ID.to_string p))
    ID.Set.equal

let check_test_comparison a b =
  Alcotest.(check @@ id_map String.equal Fun.id)
    "loop participant->header ptrs equal" a.iloop_headers b.iloop_headers;
  Alcotest.(
    check
      (id_map StringSet.equal (StringSet.to_string ~stop:"}" ~start:"{" Fun.id)))
    "loop header->participant sets equal" a.headers b.headers

let assert_loop_detector p iloop_headers headers =
  let loops = TraverseLoops.analyse p in
  let headers =
    List.map (Pair.map Fun.id StringSet.of_list) headers |> StringMap.of_list
  in
  let iloop_headers = StringMap.of_list iloop_headers in
  let expect = { iloop_headers; headers } in
  let open IrreducibleLoops in
  let headers =
    List.filter_map
      (function
        | { block; loop = LoopParticipant { primary_header }; _ } ->
            Some (block, primary_header)
        | { block; loop = PrimaryHeader { primary_header = Some h; _ }; _ } ->
            Some (block, h)
        | _ -> None)
      loops
    |> List.map (Pair.map ID.to_string ID.to_string)
    |> StringMap.of_list
  in
  let members =
    List.filter_map
      (function
        | { block; loop = PrimaryHeader { headers; _ }; _ } ->
            Some (block, headers)
        | _ -> None)
      loops
    |> List.map (fun (k, v) ->
        ( ID.to_string k,
          ID.Set.to_iter v |> Iter.map ID.to_string |> StringSet.of_iter ))
    |> StringMap.of_list
  in
  let checked = { iloop_headers = headers; headers = members } in
  check_test_comparison expect checked

let check_loop_result name prog ~header_ptrs ~all_loop_headers =
  let p = (Loader.Loadir.ast_of_string prog).prog in
  let p =
    ID.Map.find (Option.get_exn_or "no entry proc" p.entry_proc) p.procs
  in
  let c = fun () -> assert_loop_detector p header_ptrs all_loop_headers in
  Alcotest.test_case name `Quick c

let paper_fig2 =
  let p =
    {|
prog entry @main;

proc @main () -> ()
  { .name = "main"; .returnBlock = "E" }
[
  block %S [
    goto(%a, %e);
  ];
  block %a [
    goto(%b);
  ];
  block %b [
    goto(%c);
  ];
  block %c [
    goto(%d, %b);
  ];
  block %d [
    goto(%E, %a);
  ];
  block %e [
    goto(%f);
  ];
  block %f [
    goto(%g);
  ];
  block %g [
    goto(%f, %h);
  ];
  block %h [
    goto(%i);
  ];
  block %i [
    goto(%h, %e, %E);
  ];
  block %E [
    return ();
  ]
];


|}
  in
  let header_ptrs =
    [
      ("%f", "%e");
      ("%b", "%a");
      ("%g", "%f");
      ("%c", "%b");
      ("%d", "%a");
      ("%h", "%e");
      ("%i", "%h");
    ]
  in
  let all_loop_headers =
    [
      ("%e", [ "%e" ]);
      ("%f", [ "%f" ]);
      ("%a", [ "%a" ]);
      ("%b", [ "%b" ]);
      ("%h", [ "%h" ]);
    ]
  in
  check_loop_result "paper fig2" p ~header_ptrs ~all_loop_headers

let paper_fig3 =
  let p =
    {|
prog entry @main;

proc @main () -> ()
  { .name = "main"; .returnBlock = "E" }
[
  block %S [
    goto(%a, %d);
  ];
  block %a [
    goto(%b);
  ];
  block %b [
    goto(%a, %c, %E);
  ];
  block %c [
    goto(%b, %d, %E);
  ];
  block %d [
    goto(%c);
  ];
  block %E [
    return ();
  ]
];
|}
  in
  let name = "paper fig3" in
  let header_ptrs = [ ("%b", "%a"); ("%c", "%b"); ("%d", "%c") ] in
  let all_loop_headers =
    [ ("%a", [ "%a"; "%d" ]); ("%b", [ "%b"; "%d" ]); ("%c", [ "%c"; "%d" ]) ]
  in
  check_loop_result name p ~header_ptrs ~all_loop_headers

let multiple_entries =
  let p =
    {|
prog entry @main;

proc @main () -> ()
  { .name = "main"; .returnBlock = "end" }
[
  block %S [
    goto(%a, %loopexit);
  ];
  block %a [
    goto(%loop);
  ];
  block %b [
    goto(%loop);
  ];
  block %loop [
    goto(%loopexit);
  ];
  block %loopexit [
    goto(%loop, %end);
  ];
  block %end [
    return ();
  ]
];


|}
  in
  let header_ptrs = [ ("%loopexit", "%loop") ] in
  let all_loop_headers = [ ("%loop", [ "%loop"; "%loopexit" ]) ] in
  check_loop_result "multiple entries - irreducible" p ~header_ptrs
    ~all_loop_headers

let one_long_loop =
  let p =
    {|
prog entry @main;

proc @main () -> ()
  { .name = "main"; .returnBlock = "end" }
[
  block %S [
    goto(%preloop);
  ];
  block %preloop [
    goto(%loop);
  ];
  block %loop [
    goto(%loop2);
  ];
  block %loop2 [
    goto(%loop3);
  ];
  block %loop3 [
    goto(%loop, %end);
  ];
  block %end [
    return ();
  ]
];


|}
  in
  let name = "one long loop" in
  let header_ptrs = [ ("%loop2", "%loop"); ("%loop3", "%loop") ] in
  let all_loop_headers = [ ("%loop", [ "%loop" ]) ] in
  check_loop_result name p ~header_ptrs ~all_loop_headers

let nested_loop =
  let p =
    {|
prog entry @main;

proc @main () -> ()
  { .name = "main"; .returnBlock = "end" }
[
  block %S [
    goto(%loop);
  ];
  block %loop [
    goto(%loop2);
  ];
  block %loop2 [
    goto(%loop3);
  ];
  block %loop3 [
    goto(%loop2, %loop4);
  ];
  block %loop4 [
    goto(%loop, %end);
  ];
  block %end [
    return ();
  ]
];


|}
  in
  let name = "nested loop" in
  let header_ptrs =
    [ ("%loop2", "%loop"); ("%loop3", "%loop2"); ("%loop4", "%loop") ]
  in
  let all_loop_headers = [ ("%loop", [ "%loop" ]); ("%loop2", [ "%loop2" ]) ] in
  check_loop_result name p ~header_ptrs ~all_loop_headers

let nested_self_loop =
  let p =
    {|
prog entry @main;

proc @main () -> ()
  { .name = "main"; .returnBlock = "end" }
[
  block %S [
    goto(%loop);
  ];
  block %loop [
    goto(%loop2);
  ];
  block %loop2 [
    goto(%loop3, %loop2);
  ];
  block %loop3 [
    goto(%loop, %end);
  ];
  block %end [
    return ();
  ]
];


|}
  in
  let name = "nested self-loop" in
  let header_ptrs = [ ("%loop2", "%loop"); ("%loop3", "%loop") ] in
  let all_loop_headers = [ ("%loop", [ "%loop" ]); ("%loop2", [ "%loop2" ]) ] in
  check_loop_result name p ~header_ptrs ~all_loop_headers

let tests =
  [
    ( "loop identification",
      [
        paper_fig2;
        paper_fig3;
        multiple_entries;
        one_long_loop;
        nested_loop;
        nested_self_loop;
      ] );
  ]

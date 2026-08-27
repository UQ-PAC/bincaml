open Bincaml_util.Common
open Analysis.Irreducible_loops.ProcIntra

(** Tests for irreducible loop forest analysis and transform. Here "paper"
    refers to T. Wei et al. {:http://dx.doi.org/10.1007/978-3-540-74061-2_11}.
*)

open struct
  (* Put all the implementation in a hidden struct so not exported and we get
      unused function warnings if we define a test and dont add it to the suite
  *)

  type test_comparison = {
    iloop_headers : string StringMap.t;
    headers : StringSet.t StringMap.t;
  }

  let block_info = Alcotest.testable pp_block_info equal_block_info

  let id_map equal str =
    Alcotest.testable
      (fun f p ->
        Format.pp_print_string f
          (StringMap.to_iter p
          |> Iter.to_string ~sep:", " (fun (k, v) -> k ^ "->" ^ str v)))
      (StringMap.equal equal)

  let assert_loop_detector here loops iloop_headers headers =
    let headers =
      List.map (Pair.map Fun.id StringSet.of_list) headers |> StringMap.of_list
    in
    let iloop_headers = StringMap.of_list iloop_headers in
    let expect = { iloop_headers; headers } in
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
            IDSet.to_iter v |> Iter.map ID.to_string |> StringSet.of_iter ))
      |> StringMap.of_list
    in
    let checked = { iloop_headers = headers; headers = members } in
    (let open Alcotest in
     check ~here @@ id_map String.equal Fun.id)
      "loop participant->header ptrs equal" expect.iloop_headers
      checked.iloop_headers;
    (let open Alcotest in
     check ~here
       (id_map StringSet.equal
          (StringSet.to_string ~stop:"]" ~start:"[" ~sep:";" Fun.id)))
      "loop header->participant sets equal" expect.headers checked.headers

  let run_transform prog =
    let p = (Loader.Loadir.ast_of_string prog).prog in
    let p = Lang.Program.entry_proc_exn p in
    let before = solve_proc p in
    let p' = Transforms.Irreducible_loop.transform p in
    let after = solve_proc p' in
    (before, after)

  let check_loop_result name prog ~header_ptrs ~all_loop_headers =
    let p = (Loader.Loadir.ast_of_string prog).prog in
    let p = Lang.Program.entry_proc_exn p in
    let c =
     fun () ->
      let loops = solve_proc p in
      assert_loop_detector [%here] loops header_ptrs all_loop_headers
    in
    Alcotest.test_case name `Quick c

  let paper_fig2 =
    let p =
      {|
prog entry @main;

proc @main () -> ()
  { .name = "main"; .returnBlock = "E" }
[
 
  block %S [ goto(%a, %e); ]; 
  block %a [ goto(%b); ]; 
  block %b [ goto(%c); ]; 
  block %c [ goto(%d, %b); ]; 
  block %d [ goto(%E, %a); ]; 
  block %e [ goto(%f); ]; 
  block %f [ goto(%g); ]; 
  block %g [ goto(%f, %h); ]; 
  block %h [ goto(%i); ]; 
  block %i [ goto(%h, %e, %E); ]; 
  block %E [ return (); ]
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
[
  block %S [ goto(%a, %d); ]; 
  block %a [ goto(%b); ]; 
  block %b [ goto(%a, %c, %E); ]; 
  block %c [ goto(%b, %d, %E); ]; 
  block %d [ goto(%c); ]; 
  block %E [ return (); ]
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
[
  block %S [ goto(%a, %loopexit); ]; 
  block %a [ goto(%loop); ]; 
  block %b [ goto(%loop); ]; 
  block %loop [ goto(%loopexit); ]; 
  block %loopexit [ goto(%loop, %end); ]; 
  block %end [ return (); ]
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
[
  block %S [ goto(%preloop); ]; 
  block %preloop [ goto(%loop); ]; 
  block %loop [ goto(%loop2); ]; 
  block %loop2 [ goto(%loop3); ]; 
  block %loop3 [ goto(%loop, %end); ]; 
  block %end [ return (); ]
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
[
  block %S [ goto(%loop); ]; 
  block %loop [ goto(%loop2); ]; 
  block %loop2 [ goto(%loop3); ]; 
  block %loop3 [ goto(%loop2, %loop4); ]; 
  block %loop4 [ goto(%loop, %end); ]; 
  block %end [ return (); ]
];
|}
    in
    let name = "nested loop" in
    let header_ptrs =
      [ ("%loop2", "%loop"); ("%loop3", "%loop2"); ("%loop4", "%loop") ]
    in
    let all_loop_headers =
      [ ("%loop", [ "%loop" ]); ("%loop2", [ "%loop2" ]) ]
    in
    check_loop_result name p ~header_ptrs ~all_loop_headers

  let nested_self_loop =
    let p =
      {|
prog entry @main;
proc @main () -> ()
[
  block %S [ goto(%loop); ]; 
  block %loop [ goto(%loop2); ]; 
  block %loop2 [ goto(%loop3, %loop2); ]; 
  block %loop3 [ goto(%loop, %end); ]; 
  block %end [ return (); ]
];
|}
    in
    let name = "nested self-loop" in
    let header_ptrs = [ ("%loop2", "%loop"); ("%loop3", "%loop") ] in
    let all_loop_headers =
      [ ("%loop", [ "%loop" ]); ("%loop2", [ "%loop2" ]) ]
    in
    check_loop_result name p ~header_ptrs ~all_loop_headers

  let loops_reducible p =
    List.filter
      (fun b ->
        match classify_block b with
        | `IrreducibleHeader -> false
        | `ReducibleHeader -> true
        | `LoopNode -> false
        | `NonLoop -> false)
      p

  let loops_irreducible p =
    List.filter
      (fun b ->
        match classify_block b with `IrreducibleHeader -> true | _ -> false)
      p

  let check_transform_fixed here name ~num_irr_loops ~num_red_loops ?header_ptrs
      ?all_headers p =
    let checks () =
      let before, after = run_transform p in

      let check_x =
        let open Option in
        let* hdrs = header_ptrs in
        let* headers = all_headers in
        Some (fun () -> assert_loop_detector here before hdrs headers)
      in
      print_endline @@ "before transform: ";
      Implementation.dbg_show_r before;
      print_endline @@ "after transform: ";
      Implementation.dbg_show_r after;
      print_endline @@ "irreducible before: "
      ^ List.to_string show_block_info (loops_irreducible before);
      print_endline @@ "reducible before: "
      ^ List.to_string show_block_info (loops_reducible before);
      print_endline @@ "irreducible after: "
      ^ List.to_string show_block_info (loops_irreducible after);
      print_endline @@ "reducible after: "
      ^ List.to_string show_block_info (loops_reducible after);
      Alcotest.(check ~here int)
        "number of irreducible loops present" num_irr_loops
        (List.length @@ loops_irreducible before);
      Alcotest.(check ~here int)
        "number of reducible loops present" num_red_loops
        (List.length @@ loops_reducible before);
      Option.iter (fun x -> x ()) check_x;
      Alcotest.(check ~here (list block_info))
        "all irreducible loops fixed" [] (loops_irreducible after);
      Alcotest.(check ~here bool)
        "have at least one loop left"
        (num_irr_loops + num_red_loops > 0)
        (List.length @@ loops_reducible after > 0)
    in
    Alcotest.test_case name `Quick checks

  let sub_cycles_transform =
    check_transform_fixed [%here] "subcycles applying transform"
      ~num_irr_loops:1 ~num_red_loops:1
      {|
prog entry @main;                           
                                            
proc @main () -> ()                         
  { .name = "main"; .returnBlock = "exit" } 
[                                           
  block %S [                                
    goto(%h1, %h2);                         
  ];                                        
  block %h1 [                               
    goto(%h2);                              
  ];                                        
  block %h2 [                               
    goto(%h1, %h3);                         
  ];                                        
  block %h3 [                               
    goto(%h2, %exit);                       
  ];                                        
  block %exit [                             
    return ();                              
  ]                                         
];                                          
    |}

  let crossover =
    check_transform_fixed [%here] "crossover" ~num_irr_loops:2 ~num_red_loops:0
      {|
prog entry @main;
proc @main () -> ()
  { .name = "main"; .returnBlock = "exit" }
[
  block %S [
    goto(%h1, %h2);
  ];
  block %h1 [
    goto(%x);
  ];
  block %x [
    goto(%h2, %h1);
  ];
  block %h2 [
    goto(%y);
  ];
  block %y [
    goto(%x, %exit);
  ];
  block %exit [
    return ();
  ]
];
    |}

  let paper_fig4a =
    check_transform_fixed [%here] "paper fig4a" ~num_irr_loops:0
      ~num_red_loops:0
      {|
prog entry @main;

proc @main () -> ()
  { .name = "main"; .returnBlock = "exit" }
[
  block %S [
    goto(%1);
  ];
  block %1 [
    goto(%2);
  ];
  block %2 [
    goto(%b0);
  ];
  block %b0 [
    goto(%b);
  ];
  block %b [
    goto(%exit);
  ];
  block %exit [
    return ();
  ]
];

    |}

  let paper_fig4b =
    check_transform_fixed [%here] "paper fig4b" ~num_irr_loops:0
      ~num_red_loops:1
      ~header_ptrs:[ ("%b0", "%b"); ("%x", "%b") ]
      ~all_headers:[ ("%b", [ "%b" ]) ]
      {|
prog entry @main;

proc @main () -> ()
  { .name = "main"; .returnBlock = "exit" }
[
  block %S [
    goto(%1);
  ];
  block %1 [
    goto(%b);
  ];
  block %b [
    goto(%x);
  ];
  block %x [
    goto(%b0);
  ];
  block %b0 [
    goto(%exit, %b);
  ];
  block %exit [
    return ();
  ]
];
    |}

  let paper_fig4c =
    check_transform_fixed [%here] "paper fig4c" ~num_irr_loops:0
      ~num_red_loops:0
      {|
prog entry @main;

proc @main () -> ()
  { .name = "main"; .returnBlock = "exit" }
[
  block %S [
    goto(%1);
  ];
  block %1 [
    goto(%h);
  ];
  block %h [
    goto(%x, %b0);
  ];
  block %x [
    goto(%b);
  ];
  block %b0 [
    goto(%b);
  ];
  block %b [
    goto(%z);
  ];
  block %z [
    goto(%exit);
  ];
  block %exit [
    return ();
  ]
];
  |}

  let paper_fig4d =
    check_transform_fixed [%here] "paper fig4d" ~num_irr_loops:0
      ~num_red_loops:1
      ~header_ptrs:
        [
          ("%b", "%h"); ("%b0", "%h"); ("%x", "%h"); ("%y", "%h"); ("%z", "%h");
        ]
      ~all_headers:[ ("%h", [ "%h" ]) ]
      {|
prog entry @main;

proc @main () -> ()
  { .name = "main"; .returnBlock = "exit" }
[
  block %S [
    goto(%1);
  ];
  block %1 [
    goto(%h);
  ];
  block %h [
    goto(%x);
  ];
  block %x [
    goto(%b0, %y);
  ];
  block %y [
    goto(%b);
  ];
  block %b0 [
    goto(%b);
  ];
  block %b [
    goto(%z);
  ];
  block %z [
    goto(%exit, %h);
  ];
  block %exit [
    return ();
  ]
];

    |}

  let paper_fig6a =
    (* FIXME: scala impl identifies 2 irreducible loops 

  + BlockLoopInfo(%h2,Some(%h3),4,Set(%h2, %b),HashSet(%b, %h1, %h2, %z, %a)) 
  + BlockLoopInfo(%h1,Some(%h2),5,Set(%h1, %b),Set(%h1, %z, %b)) 

       *)
    check_transform_fixed [%here] "paper fig6a" ~num_irr_loops:1
      ~num_red_loops:1
      {|
prog entry @main;

proc @main () -> ()
  { .name = "main"; .returnBlock = "exit" }
[
  block %S [
    goto(%h3);
  ];
  block %h3 [
    goto(%x);
  ];
  block %x [
    goto(%h2, %y);
  ];
  block %y [
    goto(%b0);
  ];
  block %b0 [
    goto(%b);
  ];
  block %h2 [
    goto(%h1);
  ];
  block %h1 [
    goto(%b);
  ];
  block %b [
    goto(%z);
  ];
  block %z [
    goto(%h1, %a);
  ];
  block %a [
    goto(%h2, %back);
  ];
  block %back [
    goto(%h3, %exit);
  ];
  block %exit [
    return ();
  ]
];

    |}

  let paper_fig6b =
    check_transform_fixed [%here] "paper fig6b" ~num_irr_loops:0
      ~num_red_loops:4
      {|
prog entry @main;

proc @main () -> ()
  { .name = "main"; .returnBlock = "exit" }
[
  block %S [
    goto(%h4);
  ];
  block %h4 [
    goto(%h3);
  ];
  block %h3 [
    goto(%h2);
  ];
  block %h2 [
    goto(%h1);
  ];
  block %h1 [
    goto(%x);
  ];
  block %x [
    goto(%y, %h4);
  ];
  block %y [
    goto(%z, %h3);
  ];
  block %z [
    goto(%back, %h2);
  ];
  block %back [
    goto(%h1, %exit);
  ];
  block %exit [
    return ();
  ]
];
|}

  let paper_fig4e =
    check_transform_fixed [%here] "paper fig4e" ~num_irr_loops:1
      ~num_red_loops:1
      ~header_ptrs:
        [
          ("%a", "%h");
          ("%b", "%h");
          ("%b0", "%h1");
          ("%h", "%h1");
          ("%y", "%h1");
          ("%z", "%h1");
        ]
      ~all_headers:[ ("%h", [ "%b"; "%h" ]); ("%h1", [ "%h1" ]) ]
      {|
prog entry @main;

proc @main () -> ()
  { .name = "main"; .returnBlock = "exit" }
[
  block %S [
    goto(%h1);
  ];
  block %h1 [
    goto(%y, %z);
  ];
  block %y [
    goto(%h);
  ];
  block %h [
    goto(%b);
  ];
  block %z [
    goto(%b0);
  ];
  block %b0 [
    goto(%b);
  ];
  block %b [
    goto(%a);
  ];
  block %a [
    goto(%h, %h1, %exit);
  ];
  block %exit [
    return ();
  ]
];
    |}
end

let triforce =
  check_transform_fixed [%here] "triforce" ~num_irr_loops:2 ~num_red_loops:1
    {|
prog entry @main;

proc @main () -> ()
  { .name = "main"; .returnBlock = "exit" }
[
  block %S [
    goto(%h1, %h2, %h3);
  ];
  block %h1 [
    goto(%h1, %h2, %h3);
  ];
  block %h2 [
    goto(%h1, %h2, %h3);
  ];
  block %h3 [
    goto(%h1, %h2, %h3, %exit);
  ];
  block %exit [
    return ();
  ]
];


  |}

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
        sub_cycles_transform;
        crossover;
        paper_fig4a;
        paper_fig4b;
        paper_fig4c;
        paper_fig4d;
        paper_fig6b;
        paper_fig6a;
        paper_fig4e;
        triforce;
      ] );
  ]

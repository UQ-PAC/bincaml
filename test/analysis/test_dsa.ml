open Lang.Common
open Analysis.Dsa

(* TODO decide on how flags should be tested (if at all) maybe only test in
        expect tests and also symbolic bases probably*)

open struct
  open STM

  (* 1. Property tests for invariants of the DSGraph representation *)

  (** Generates cells, nodes, graphs and things *)
  module DSGraphGen = struct
    (** Generates small zarith integers *)
    let small_z = QCheck.Gen.(int_small |> map Z.of_int)

    (** Generates an arbitrary interval with the given zarith generator.
        Occasionally will generate a Top interval but never a Bot interval. *)
    let interval zgen =
      QCheck.Gen.(
        oneof_weighted
          [
            ( 30,
              pair zgen zgen
              |> map (fun (a, b) ->
                  if Z.leq a b then Interval.Interval (a, b)
                  else Interval.Interval (b, a)) );
            (1, pure Interval.Top);
          ])
  end

  (* TODO
     - IMPORTANT nodes with multiple cells
     - Test symbase stuff
     - Test get_cell
     - Test joining means get_cell returns a unique cell *)

  (** Stores state for comparing with the formal model *)
  module DSGraphHandle = struct
    type graph = { g : DSGraph.t; mutable cells : DSGraph.cell list }
    type t = graph list ref

    let empty () = ref []

    let add_graph (l : t) =
      l := List.append !l [ { g = DSGraph.empty_graph (); cells = [] } ]

    let make_node (l : t) n is =
      let g = List.nth !l n in
      let n = DSGraph.empty_node () in
      let cs =
        List.map
          (fun i -> ref (DSGraph.Cell { offsets = i; node = n; pointees = [] }))
          is
      in
      g.g.nodes <- n :: g.g.nodes;
      List.iter (DSGraph.insert n) cs;
      List.iter (fun n -> DSGraph.check_valid_node n) g.g.nodes;
      g.cells <- cs @ g.cells

    let count_cells (l : t) n =
      let g = List.nth !l n in
      List.length g.cells

    let cell_widths (l : t) n =
      let g = List.nth !l n in
      List.map (Interval.width % DSGraph.offsets) g.cells

    let add_edge (l : t) n a b =
      let g = List.nth !l n in
      let a = List.nth g.cells a in
      let b = List.nth g.cells b in
      DSGraph.add_pointees [ b ] a

    let join (l : t) n a b =
      let g = List.nth !l n in
      let a = List.nth g.cells a in
      let b = List.nth g.cells b in
      DSGraph.join a b;
      let g = List.nth !l n in
      g.cells <- a :: g.cells

    let unify_all (l : t) n =
      let g = List.nth !l n in
      let cells = g.g |> DSGraph.nodes |> List.flat_map DSGraph.cells in
      cells |> List.iter DSGraph.unify_pointees;
      DSGraph.check_unique_pointee g.g

    let copy (l : t) f t cs =
      let f = List.nth !l f in
      let t = List.nth !l t in
      let old_to_new = Hashtbl.create 100 in
      let cs' =
        cs
        |> List.filter_map (fun c ->
            let c = List.nth f.cells c in
            let n = DSGraph.node_of c in
            let n' = DSGraph.copy_node ~old_to_new t.g n in
            DSGraph.get_cell (DSGraph.offsets c) n')
      in
      t.cells <- cs' @ t.cells
  end

  (** Stores state for comparing with the implementation *)
  module FormalDSGraphHandle = struct
    type graph = { g : FormalDSGraph.t; cells : FormalDSGraph.Cell.t list }
    type t = graph list

    let empty = []

    let add_graph l : t =
      List.append l [ { g = FormalDSGraph.empty; cells = [] } ]

    let mapn l n f = List.mapi (fun n' gr -> if n = n' then f gr else gr) l

    let make_node l n is =
      mapn l n (fun gr ->
          let g, nid = FormalDSGraph.make_node gr.g in
          let cs, g =
            List.fold_right
              (fun i (acc, g) ->
                ( ({ offsets = i; node = nid } : FormalDSGraph.Cell.t) :: acc,
                  FormalDSGraph.add_cell g nid i ))
              is ([], g)
          in
          let cells = cs @ gr.cells in
          { g; cells })

    let count_cells l n =
      let g = List.nth l n in
      List.length g.cells

    let cell_widths l n =
      let g = List.nth l n in
      g.cells
      |> List.map (FormalDSGraph.find g.g)
      |> List.map (fun (c : FormalDSGraph.Cell.t) -> Interval.width c.offsets)

    let add_edge l n a b =
      mapn l n (fun gr ->
          let a = List.nth gr.cells a in
          let b = List.nth gr.cells b in
          { gr with g = FormalDSGraph.add_edge gr.g a b })

    let join l n a b =
      mapn l n (fun gr ->
          let a = List.nth gr.cells a in
          let b = List.nth gr.cells b in
          let g = FormalDSGraph.join_cell_pair gr.g a b in
          let c = FormalDSGraph.find g a in
          let cells = c :: gr.cells in
          { g; cells })

    let unify_all l n =
      mapn l n (fun gr ->
          let g = FormalDSGraph.unify_all gr.g in
          { gr with g })

    let copy l f t cs =
      mapn l t (fun tgr ->
          let fgr = List.nth l f in
          let cs = cs |> List.map (List.nth fgr.cells) in
          let cs' = FormalDSGraph.CellSet.of_list cs in
          let tgr', m = FormalDSGraph.copy tgr.g fgr.g cs' in
          let cells' =
            cs
            |> List.map (fun c -> FormalDSGraph.find fgr.g c)
            |> List.map (fun c ->
                assert (FormalDSGraph.CellMap.mem c m);
                FormalDSGraph.CellMap.find c m)
          in
          let cells = cells' @ tgr.cells in
          { g = tgr'; cells })
  end

  module DSGraphSpec = struct
    type sut = DSGraphHandle.t

    let init_sut = DSGraphHandle.empty
    let cleanup _ = ()

    type cmd =
      | AddGraph
      | MakeNode of int * Interval.t list
      | CountCells of int
      | CellWidths of int
      | MakeEdge of int * int * int
      | Join of int * int * int
      | UnifyAll of int
      | Copy of int * int * int list

    let show_cmd = function
      | AddGraph -> "AddGraph"
      | MakeNode (n, is) ->
          Printf.sprintf "MakeNode (%d, %s)" n
            (List.to_string ~start:"[" ~stop:"]" ~sep:"; " Interval.dbg is)
      | CountCells n -> Printf.sprintf "CountCells %d" n
      | CellWidths n -> Printf.sprintf "CellWidths %d" n
      | MakeEdge (n, a, b) -> Printf.sprintf "MakeEdge (%d, %d, %d)" n a b
      | Join (n, a, b) -> Printf.sprintf "Join (%d, %d, %d)" n a b
      | UnifyAll n -> Printf.sprintf "UnifyAll %d" n
      | Copy (f, t, cs) ->
          Printf.sprintf "Copy (%d, %d, [%s])" f t
            (List.to_string ~sep:"; " Int.to_string cs)

    let run cmd sut =
      match cmd with
      | AddGraph -> Res (unit, DSGraphHandle.add_graph sut)
      | MakeNode (n, is) -> Res (unit, DSGraphHandle.make_node sut n is)
      | CountCells n -> Res (int, DSGraphHandle.count_cells sut n)
      | CellWidths n -> Res (list (option int), DSGraphHandle.cell_widths sut n)
      | MakeEdge (n, a, b) -> Res (unit, DSGraphHandle.add_edge sut n a b)
      | Join (n, a, b) -> Res (unit, DSGraphHandle.join sut n a b)
      | UnifyAll n -> Res (unit, DSGraphHandle.unify_all sut n)
      | Copy (f, t, cs) -> Res (unit, DSGraphHandle.copy sut f t cs)

    type state = FormalDSGraphHandle.t

    let init_state = FormalDSGraphHandle.empty

    let next_state cmd state =
      match cmd with
      | AddGraph -> FormalDSGraphHandle.add_graph state
      | MakeNode (n, is) -> FormalDSGraphHandle.make_node state n is
      | CountCells _ -> state
      | CellWidths _ -> state
      | MakeEdge (n, a, b) -> FormalDSGraphHandle.add_edge state n a b
      | Join (n, a, b) -> FormalDSGraphHandle.join state n a b
      | UnifyAll n -> FormalDSGraphHandle.unify_all state n
      | Copy (f, t, cs) -> FormalDSGraphHandle.copy state f t cs

    let precond cmd state =
      match cmd with
      | AddGraph -> true
      | MakeNode (n, _) -> List.length state > n
      | CountCells n -> List.length state > n
      | CellWidths n -> List.length state > n
      | MakeEdge (n, a, b) ->
          List.length state > n
          && FormalDSGraphHandle.count_cells state n > Int.max a b
      | Join (n, a, b) ->
          List.length state > n
          && FormalDSGraphHandle.count_cells state n > Int.max a b
          && not (a = b)
      | UnifyAll n -> List.length state > n
      | Copy (f, t, cs) ->
          List.length state > Int.max f t
          && List.for_all
               (fun i -> FormalDSGraphHandle.count_cells state f > i)
               cs

    let postcond cmd state res =
      match (cmd, res) with
      | AddGraph, Res ((Unit, _), _) -> true
      | MakeNode _, Res ((Unit, _), _) -> true
      | CountCells i, Res ((Int, _), n) ->
          FormalDSGraphHandle.count_cells state i = n
      | CellWidths i, Res ((List (Option Int), _), l) ->
          List.equal (Option.equal Int.equal) l
            (FormalDSGraphHandle.cell_widths state i)
      | MakeEdge _, Res ((Unit, _), _) -> true
      | Join _, Res ((Unit, _), _) -> true
      | UnifyAll _, Res ((Unit, _), _) -> true
      | Copy (_, _, _), Res ((Unit, _), _) -> true
      | _ -> false

    let arb_cmd state =
      let open QCheck.Gen in
      let add_graph = Some (pure AddGraph) in
      let make_node =
        if not @@ List.is_empty state then
          Some
            ( int_range 0 (List.length state - 1) >>= fun g ->
              map
                (fun i -> MakeNode (g, i))
                (list_small DSGraphGen.(interval small_z)) )
        else None
      in
      let arb_cell_idx g =
        if FormalDSGraphHandle.count_cells state g > 0 then
          Some
            ( int_range 0 (FormalDSGraphHandle.count_cells state g - 1)
            >|= fun ci -> (g, ci) )
        else None
      in
      let _count_cells =
        if not @@ List.is_empty state then
          Some
            (let* g = int_range 0 (List.length state - 1) in
             pure (CountCells g))
        else None
      in
      let _cell_widths =
        if not @@ List.is_empty state then
          Some
            (let* g = int_range 0 (List.length state - 1) in
             pure (CellWidths g))
        else None
      in
      let make_edge =
        (if not @@ List.is_empty state then
           Some (List.init (List.length state) id)
         else None)
        |> Option.map (List.filter_map arb_cell_idx)
        |> Option.filter (not % List.is_empty)
        |> Option.map (fun is ->
            is
            |> List.map (fun gen ->
                pair gen gen >|= fun ((g, c1), (_, c2)) -> MakeEdge (g, c1, c2))
            |> oneof)
      in
      let join =
        Option.return_if
          (not @@ List.is_empty state)
          (List.init (List.length state) id)
        |> Option.map
             (List.filter (fun g -> FormalDSGraphHandle.count_cells state g > 1))
        |> Option.filter (not % List.is_empty)
        |> Option.map (fun is ->
            is
            |> List.map (fun g ->
                let n = FormalDSGraphHandle.count_cells state g in
                let* c1 = 0 -- (n - 1) in
                let* c2 =
                  List.init n id |> List.filter (not % ( = ) c1) |> oneof_list
                in
                return (Join (g, c1, c2)))
            |> oneof)
      in
      let unify_all =
        if not @@ List.is_empty state then
          Some
            (let* g = int_range 0 (List.length state - 1) in
             pure (UnifyAll g))
        else None
      in
      let copy =
        Option.return_if
          (not @@ List.is_empty state)
          (List.init (List.length state) id)
        |> Option.map
             (List.filter (fun g -> FormalDSGraphHandle.count_cells state g > 0))
        |> Option.filter (not % List.is_empty)
        |> Option.map (fun fs ->
            let* f = oneof_list fs in
            let* t = 0 -- (List.length state - 1) in
            let n = FormalDSGraphHandle.count_cells state f in
            let* cs = list_small (0 -- (n - 1)) in
            return (Copy (f, t, cs)))
      in
      QCheck.make ~print:show_cmd
        (oneof
        @@ List.filter_map id
             [
               add_graph;
               make_node;
               (*_count_cells;*)
               (* Unused, see NOTE under the unification edge case test. *)
               (*_cell_widths;*)
               make_edge;
               join;
               unify_all;
               copy;
             ])

    (*
    (* NOTE: the above counterexample shows that equality checking cell widths
       is incorrect, as different correct implementations of unification can
       produce different cell widths based on the order pointees are unified.
       This kinda makes model comparisons with cell widths useless, so the
       proptests will exist to check assertions. *)
    let unification_edge_case () =
      let steps =
        [
          AddGraph;
          MakeNode
            ( 0,
              [
                Interval.Interval (Z.of_int (-61), Z.of_int (-1));
                Interval.Interval (Z.of_int 2, Z.of_int 89);
              ] );
          MakeEdge (0, 1, 1);
          MakeEdge (0, 1, 0);
          Copy (0, 0, [ 1 ]);
          (* The SUT says widths are 151 and state says 214, but if we reverse this edge they say what the other said *)
          MakeEdge (0, 0, 2);
          UnifyAll 0;
          CellWidths 0;
        ]
      in
      let s = init_sut () in
      let state = init_state in
      ignore
      @@ List.fold_left
           (fun state step ->
             if not @@ List.is_empty state then (
               (print_endline
               @@ FormalDSGraph.(
                    EdgeSet.to_string Edge.show
                      (List.nth state 0 : FormalDSGraphHandle.graph).g.edges));
               print_endline
               @@ FormalDSGraph.(
                    CellSet.to_string Cell.show
                      (List.nth state 0 : FormalDSGraphHandle.graph).g.cells));
             print_endline @@ show_cmd step;
             let res = run step s in
             (match (step, res) with
             | CountCells i, Res ((Int, _), n) ->
                 print_endline @@ Int.to_string n;
                 print_endline @@ Int.to_string
                 @@ FormalDSGraphHandle.count_cells state i
             | CellWidths i, Res ((List (Option Int), _), l) ->
                 print_endline
                 @@ Format.to_string (List.pp (Option.pp Int.pp)) l;
                 print_endline
                 @@ Format.to_string
                      (List.pp (Option.pp Int.pp))
                      (FormalDSGraphHandle.cell_widths state i)
             | _ -> ());
             assert (postcond step state res);
             print_endline @@ dot_string @@ (List.nth !s 0).g;
             next_state step state)
           state steps;
      ()
      *)
  end

  module DSGraphSequential = STM_sequential.Make (DSGraphSpec)

  module DSGraphTests = struct
    let tests =
      [
        DSGraphSequential.agree_test ~count:100
          ~name:"DSGraph STM Sequential tests";
      ]
      |> List.map (QCheck_alcotest.to_alcotest ~verbose:true)
  end
end

let tests =
  [
    (*( "unification_edge_case", [ Alcotest.test_case "unification_edge_case" `Quick DSGraphSpec.unification_edge_case; ] );*)
    ("dsa_invariants", DSGraphTests.tests);
  ]

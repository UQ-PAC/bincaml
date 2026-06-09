open Lang.Common
open Analysis.Dsa

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

  module DSGraphGen2 = struct
    (** Generates small zarith integers *)
    let small_z = QCheck2.Gen.(int_small |> map Z.of_int)

    (** Generates an arbitrary interval with the given zarith generator.
        Occasionally will generate a Top interval but never a Bot interval. *)
    let interval zgen =
      QCheck2.Gen.(
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
     - DONE Method to refer to old cells in formal model ? So we can test performing operations on Path cells/nodes
     - Comparison data structure obtainable from either handle (intervals become relative / based at 0 maybe)
     - DONEish? Figure out a way to represent copies/multiple graphs
     - Test symbase stuff *)

  (** Stores state for comparing with the formal model *)
  module DSGraphHandle = struct
    type graph = { g : DSGraph.t; mutable cells : DSGraph.cell list }
    type t = graph list ref

    let empty () = ref []

    let add_graph (l : t) =
      l :=
        List.append !l
          [
            {
              g = DSGraph.empty_graph Analysis.Sva.StateAbstraction.bottom;
              cells = [];
            };
          ]

    let make_cell (l : t) n i =
      let g = List.nth !l n in
      let c = DSGraph.new_add_cell g.g i 0 in
      g.cells <- c :: g.cells

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

    let extend_cells cur possible =
      List.fold_left
        (fun cur c -> List.add_nodup ~eq:CCEqual.physical (DSGraph.find c) cur)
        cur possible

    let join (l : t) n a b =
      let g = List.nth !l n in
      let a = List.nth g.cells a in
      let b = List.nth g.cells b in
      DSGraph.join a b;
      let g = List.nth !l n in
      g.cells <- a :: g.cells

    let unify_all (l : t) n =
      let g = List.nth !l n in
      List.iter DSGraph.unify_pointees g.cells;
      g.cells <- extend_cells g.cells g.cells
  end

  (** Stores state for comparing with the implementation *)
  module FormalDSGraphHandle = struct
    type graph = { g : FormalDSGraph.t; cells : FormalDSGraph.Cell.t list }
    type t = graph list

    let empty = []

    let add_graph l : t =
      List.append l [ { g = FormalDSGraph.empty; cells = [] } ]

    let mapn l n f = List.mapi (fun n' gr -> if n = n' then f gr else gr) l

    let make_cell l n i : t =
      mapn l n (fun gr ->
          let g, nid = FormalDSGraph.make_node gr.g in
          let cells : FormalDSGraph.Cell.t list =
            { offsets = i; node = nid } :: gr.cells
          in
          { g = FormalDSGraph.add_cell g nid i; cells })

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
          let cells =
            List.fold_left
              (fun cur c ->
                List.add_nodup ~eq:FormalDSGraph.Cell.equal
                  (FormalDSGraph.find g c) cur)
              gr.cells gr.cells
          in
          { g; cells })
  end

  module DSGraphSpec = struct
    type sut = DSGraphHandle.t

    let init_sut = DSGraphHandle.empty
    let cleanup _ = ()

    type cmd =
      | AddGraph
      | MakeCell of int * Interval.t
      | CountCells of int
      | CellWidths of int
      | MakeEdge of int * int * int
      | Join of int * int * int
      | UnifyAll of int
    (*| Copy*)

    let show_cmd = function
      | AddGraph -> "AddGraph"
      | MakeCell (n, i) ->
          Printf.sprintf "MakeCell (%d, %s)" n (Interval.show i)
      | CountCells n -> Printf.sprintf "CountCells %d" n
      | CellWidths n -> Printf.sprintf "CellWidths %d" n
      | MakeEdge (n, a, b) -> Printf.sprintf "MakeEdge (%d, %d, %d)" n a b
      | Join (n, a, b) -> Printf.sprintf "Join (%d, %d, %d)" n a b
      | UnifyAll n -> Printf.sprintf "UnifyAll %d" n

    let run cmd sut =
      match cmd with
      | AddGraph -> Res (unit, DSGraphHandle.add_graph sut)
      | MakeCell (n, i) -> Res (unit, DSGraphHandle.make_cell sut n i)
      | CountCells n -> Res (int, DSGraphHandle.count_cells sut n)
      | CellWidths n -> Res (list (option int), DSGraphHandle.cell_widths sut n)
      | MakeEdge (n, a, b) -> Res (unit, DSGraphHandle.add_edge sut n a b)
      | Join (n, a, b) -> Res (unit, DSGraphHandle.join sut n a b)
      | UnifyAll n -> Res (unit, DSGraphHandle.unify_all sut n)

    type state = FormalDSGraphHandle.t

    let init_state = FormalDSGraphHandle.empty

    let next_state cmd state =
      match cmd with
      | AddGraph -> FormalDSGraphHandle.add_graph state
      | MakeCell (n, i) -> FormalDSGraphHandle.make_cell state n i
      | CountCells _ -> state
      | CellWidths _ -> state
      | MakeEdge (n, a, b) -> FormalDSGraphHandle.add_edge state n a b
      | Join (n, a, b) -> FormalDSGraphHandle.join state n a b
      | UnifyAll n -> FormalDSGraphHandle.unify_all state n

    let precond cmd state =
      match cmd with
      | AddGraph -> true
      | MakeCell (n, _) -> List.length state > n
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

    let postcond cmd state res =
      match (cmd, res) with
      | AddGraph, Res ((Unit, _), _) -> true
      | MakeCell _, Res ((Unit, _), _) -> true
      | CountCells i, Res ((Int, _), n) ->
          FormalDSGraphHandle.count_cells state i = n
      | CellWidths i, Res ((List (Option Int), _), l) ->
          List.equal (Option.equal Int.equal) l
            (FormalDSGraphHandle.cell_widths state i)
      | MakeEdge _, Res ((Unit, _), _) -> true
      | Join _, Res ((Unit, _), _) -> true
      | UnifyAll _, Res ((Unit, _), _) -> true
      | _ -> false

    let arb_cmd state =
      let open QCheck.Gen in
      let add_graph = Some (pure AddGraph) in
      let make_cell =
        if not @@ List.is_empty state then
          Some
            ( int_range 0 (List.length state - 1) >>= fun g ->
              map (fun i -> MakeCell (g, i)) DSGraphGen.(interval small_z) )
        else None
      in
      let arb_cell_idx g =
        if FormalDSGraphHandle.count_cells state g > 0 then
          Some
            ( int_range 0 (FormalDSGraphHandle.count_cells state g - 1)
            >|= fun ci -> (g, ci) )
        else None
      in
      let count_cells =
        if not @@ List.is_empty state then
          Some
            (let* g = int_range 0 (List.length state - 1) in
             pure (CountCells g))
        else None
      in
      let cell_widths =
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
      let make_join =
        (if not @@ List.is_empty state then
           Some (List.init (List.length state) id)
         else None)
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
      let _unify_all =
        if not @@ List.is_empty state then
          Some
            (let* g = int_range 0 (List.length state - 1) in
             pure (UnifyAll g))
        else None
      in
      QCheck.make ~print:show_cmd
        (oneof
        @@ List.filter_map id
             [
               add_graph;
               make_cell;
               count_cells;
               cell_widths;
               make_edge;
               make_join;
               (*_unify_all;*)
             ])

    (* For recreating failing tests *)
    let dsa_specific_stm () =
      let steps =
        [
          AddGraph;
          MakeCell (0, Interval.Interval (Z.of_int (-5), Z.of_int 5));
          AddGraph;
          MakeCell (0, Interval.Interval (Z.of_int 0, Z.of_int 1));
          AddGraph;
          AddGraph;
          Join (0, 0, 1);
          CellWidths 0;
        ]
      in
      let s = init_sut () in
      let state = init_state in
      ignore
      @@ List.fold_left
           (fun state step ->
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
             next_state step state)
           state steps;
      ()
  end

  module DSGraphSequential = STM_sequential.Make (DSGraphSpec)

  module DSGraphTests = struct
    let _join_intervals =
      QCheck2.(
        Test.make ~name:"join_intervals"
          ~print:Print.(contramap (CCList.to_string Interval.show) string)
          (QCheck2.Gen.list_small @@ DSGraphGen2.(interval small_z))
          (fun is ->
            let open FormalDSGraph in
            let is = IntervalSet.of_list is |> join_invervals in
            IntervalSet.for_all
              (fun i ->
                IntervalSet.for_all
                  (fun i' ->
                    Interval.equal i i' || (not @@ Interval.overlap i i'))
                  is)
              is))

    (*
    let widths cells = List.map (fun c -> (c, DSGraph.offsets c)) cells
    let cell_subset (c, i) = Interval.subset i (DSGraph.offsets c)
    let valid n = DSGraph.is_sorted n && DSGraph.valid_cell_nodes n
    let show_cell = Interval.show % DSGraph.offsets

    (* TODO generate cell paths *)
    (* TODO generate nodes with paths / generally make a node generator? *)
    (* NOTE generating things that use references sucks!!!! don't do it!!!!!! *)

    (** merge_init ensures invariants *)
    let merge_init =
      QCheck.(
        Test.make ~name:"merge_init" ~count:1000
          ~print:Print.(contramap (CCList.to_string Interval.show) string)
          DSGraphGen.(Gen.list (interval small_z))
          (fun is ->
            let cells = List.map (fun i -> DSGraph.init i 0) is in
            let widths = widths cells in
            let node = DSGraph.merge_init cells in
            List.for_all cell_subset widths && valid node))

    (** join_nodes_at ensures invariants *)
    let join_nodes_at =
      QCheck2.(
        Test.make ~name:"join_nodes_at" ~count:1000
          ~print:
            Print.(
              contramap
                (fun (i1, i2, o) ->
                  CCList.to_string Interval.show i1
                  ^ " "
                  ^ CCList.to_string Interval.show i2
                  ^ " " ^ Z.to_string o)
                string)
          DSGraphGen.(
            Gen.(
              triple (list (interval small_z)) (list (interval small_z)) small_z))
          (fun (i1, i2, o) ->
            let c1 = List.map (fun i -> DSGraph.init i 0) i1 in
            let c2 = List.map (fun i -> DSGraph.init i 0) i2 in
            let w1 = widths c1 in
            let w2 =
              widths c2 |> List.map (CCPair.map_snd (Interval.shift o))
            in
            let n1 = DSGraph.merge_init c1 in
            let n2 = DSGraph.merge_init c2 in
            DSGraph.join_nodes_at o n1 n2;
            List.for_all cell_subset w1
            && List.for_all cell_subset w2
            && valid n1 && valid n2))

    (** insert ensures invariants *)
    let insert =
      QCheck2.(
        Test.make ~name:"insert" ~count:1000
          ~print:
            Print.(
              contramap
                (fun (c1, c2) ->
                  CCList.to_string Interval.show c1 ^ "&" ^ Interval.show c2)
                string)
          DSGraphGen.(Gen.(pair (list (interval small_z)) (interval small_z)))
          (fun (is, i) ->
            let cs = List.map (fun i -> DSGraph.init i 0) is in
            let c = DSGraph.init i 0 in
            print_endline @@ "Cell list: " ^ CCList.to_string show_cell cs;
            let w1 = widths cs in
            let w2 = (c, DSGraph.offsets c) in
            let n = DSGraph.merge_init cs in
            print_endline "Merge done";
            DSGraph.insert n c;
            List.for_all cell_subset w1 && cell_subset w2 && valid n))

    (** TODO unify_pointees, copy_node, get_cell, cell_of *)

    let tests =
      [ merge_init; join_nodes_at; insert ]
      |> List.map QCheck_alcotest.to_alcotest
      *)
    let tests =
      [
        DSGraphSequential.agree_test ~count:100
          ~name:"DSGraph STM Sequential tests";
        (*_join_intervals*)
      ]
      |> List.map (QCheck_alcotest.to_alcotest ~verbose:true)
  end
end

let tests =
  [
    ("dsa_invariants", DSGraphTests.tests);
    ("blah", [ Alcotest.test_case "blah" `Quick DSGraphSpec.dsa_specific_stm ]);
  ]

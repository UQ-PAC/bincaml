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

  (* TODO
     - Method to refer to old cells in formal model ? So we can test performing operations on Path cells/nodes
     - Comparison data structure obtainable from either handle (intervals become relative / based at 0 maybe)
     - Figure out a way to represent copies/multiple graphs *)

  (** Stores state for comparing with the formal model *)
  module DSGraphHandle = struct
    type t = DSGraph.t list

    let empty = []
    (* TODO asdkfdlhgsf the DSGraph like never works over DSGraph.t-s so nothing works ahsdlkjhsdhfdsakjghdlgkjs *)
  end

  (** Stores state for comparing with the implementation *)
  module FormalDSGraphHandle = struct
    type t = FormalDSGraph.t list

    let empty = []

    (** Add a new graph *)
    let add_graph l = FormalDSGraph.empty :: l
  end

  module DSGraphSpec : Spec = struct
    type sut = DSGraphHandle.t

    let init_sut () = DSGraphHandle.empty
    let cleanup _ = ()

    type cmd = AddGraph | MakeCell of int * Interval.t
    (*| MakeEdge
      | Join
      | UnifyAll
      | Copy*)

    let show_cmd = function AddGraph -> "AddGraph" | _ -> failwith "todo"
    let run cmd _sut = match cmd with _ -> Res (unit, failwith "todo")

    type state = FormalDSGraphHandle.t

    let init_state = FormalDSGraphHandle.empty

    let next_state cmd state =
      match cmd with
      | AddGraph -> FormalDSGraphHandle.add_graph state
      | _ -> failwith "todo"

    let precond _cmd _state = true
    let postcond _cmd _state _res = true

    let arb_cmd state =
      let open QCheck.Gen in
      let add_graph = Some (pure AddGraph) in
      let make_cell =
        Option.return_if
          (not @@ List.is_empty state)
          ( int_range 0 (List.length state - 1) >>= fun g ->
            map (fun i -> MakeCell (g, i)) DSGraphGen.(interval small_z) )
      in
      QCheck.make ~print:show_cmd
        (oneof @@ List.filter_map id [ add_graph; make_cell ])
  end

  module DSGraphTests = struct
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
    let tests = []
  end
end

let tests = [ ("dsa_invariants", DSGraphTests.tests) ]

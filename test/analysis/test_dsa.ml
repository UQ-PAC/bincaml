open Lang.Common
open Analysis.Dsa

open struct
  (* 1. Property tests for invariants of the DSGraph representation *)

  (** Generates cells, nodes, graphs and things *)
  module DSGraphGen = struct
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

  module DSGraphTests = struct
    let widths cells = List.map (fun c -> (c, DSGraph.offsets c)) cells
    let cell_subset (c, i) = Interval.subset i (DSGraph.offsets c)
    let valid n = DSGraph.is_sorted n && DSGraph.valid_cell_nodes n
    let show_cell = Interval.show % DSGraph.offsets

    (* TODO generate cell paths *)
    (* TODO generate nodes with paths / generally make a node generator? *)
    (* NOTE generating things that use references sucks!!!! don't do it!!!!!! *)

    (** merge_init ensures invariants *)
    let merge_init =
      QCheck2.(
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
  end
end

let tests = [ ("dsa_invariants", DSGraphTests.tests) ]

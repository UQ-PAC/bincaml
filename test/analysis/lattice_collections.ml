include Lang.Common
include Analysis.Lattice_collections

module TestKey = struct
  include Int

  let to_int = id
  let show = to_string
  let pretty = Containers_pp.int
end

module TestLattice = struct
  include LatticeSet (struct
    include Int

    let name = "Int"
    let show = to_string
    let pretty = Containers_pp.int
  end)

  let generator =
    QCheck.Gen.(
      oneof
        [
          return Top;
          (list_size nat_small int >|= TSet.of_list >|= fun s -> Fin s);
        ])

  let size = function Top -> 1 | Fin s -> TSet.cardinal s + 1

  let shrink = function
    | Top -> Iter.empty
    | Fin s ->
        QCheck.Shrink.(
          TSet.to_list s |> list ~shrink:int
          |> Iter.map (fun l -> Fin (TSet.of_list l)))

  let arbitrary =
    QCheck.(
      make generator |> set_print show |> set_small size |> set_shrink shrink)

  let idem =
    QCheck.Test.make ~name:"idempotent" arbitrary (fun s -> equal (join s s) s)

  let union_prop =
    QCheck.Test.make ~name:"union" (QCheck.tup3 arbitrary arbitrary QCheck.int)
      (fun (a, b, x) -> Bool.equal (mem x (join a b)) (mem x a || mem x b))

  let join_leq =
    QCheck.Test.make ~name:"join_leq" (QCheck.pair arbitrary arbitrary)
      (fun (a, b) -> Bool.equal (leq a b) (equal (join a b) b))

  let _ = QCheck_base_runner.run_tests [ idem; union_prop; join_leq ]
end

module TestMap = struct
  include LatticeMap (TestKey) (TestLattice)

  let topmake m = TopMap (KM.filter (fun _ x -> not @@ V.equal x V.top) m)
  let botmake m = BotMap (KM.filter (fun _ x -> not @@ V.equal x V.bottom) m)

  let generator =
    QCheck.Gen.(
      pair nat_small TestLattice.generator
      |> list_size nat_small |> map KM.of_list
      |> fun f -> oneof [ f >|= topmake; f >|= botmake ])

  let size = function TopMap m | BotMap m -> KM.cardinal m

  let shrink lm =
    let m = match lm with TopMap m | BotMap m -> m in
    QCheck.Shrink.(
      KM.to_list m
      |> list ~shrink:(pair int TestLattice.shrink)
      |> Iter.map KM.of_list
      |> Iter.map (fun m ->
          match lm with TopMap _ -> topmake m | BotMap _ -> botmake m))

  let arbitrary =
    QCheck.(
      make generator |> set_print show |> set_small size |> set_shrink shrink)

  let idem =
    QCheck.Test.make ~name:"idempotent" arbitrary (fun m -> equal m (join m m))

  let pointwise_join =
    QCheck.Test.make ~name:"pointwise_join"
      (QCheck.tup3 arbitrary arbitrary QCheck.nat_small) (fun (a, b, k) ->
        TestLattice.equal
          (read k (join a b))
          (TestLattice.join (read k a) (read k b)))

  let pointwise_update =
    QCheck.Test.make ~name:"pointwise_update"
      (QCheck.tup4 arbitrary QCheck.nat_small QCheck.nat_small
         TestLattice.arbitrary) (fun (a, k, k', s) ->
        let b = update k s a in
        match k = k' with
        | true -> TestLattice.equal s (read k' b)
        | false -> TestLattice.equal (read k' a) (read k' b))

  let join_leq =
    QCheck.Test.make ~name:"join_leq" (QCheck.pair arbitrary arbitrary)
      (fun (a, b) -> Bool.equal (leq a b) (equal (join a b) b))

  let _ =
    QCheck_base_runner.run_tests
      [ idem; pointwise_join; pointwise_update; join_leq ]
end

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
      oneof [ return Top; (list int >|= TSet.of_list >|= fun s -> Fin s) ])

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

  let set_idem =
    QCheck.Test.make ~name:"set_idempotent" arbitrary (fun s ->
        equal (join s s) s)

  let union_prop =
    QCheck.Test.make ~name:"union" (QCheck.tup3 arbitrary arbitrary QCheck.int)
      (fun (a, b, x) -> Bool.equal (mem x (join a b)) (mem x a || mem x b))

  let _ = QCheck_base_runner.run_tests [ set_idem; union_prop ]
end

module TestMap = LatticeMap (TestKey) (TestLattice)

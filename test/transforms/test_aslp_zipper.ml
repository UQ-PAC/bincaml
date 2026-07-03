open Lang
open Common
open Transforms.Aslp

let%expect_test "diamond bfs" =
  let d n =
    Diamond.Diamond
      {
        value = n ^ "_merge";
        pred = Leaf (n ^ "_pred");
        left = Leaf (n ^ "_left");
        right = Leaf (n ^ "_right");
      }
  in
  let main =
    Diamond.Diamond
      {
        value = "merge";
        pred = Leaf "pred";
        left = Leaf "left";
        right = Leaf "right";
      }
  in
  let zip =
    Diamond_zipper.(of_diamond main |> move_in_to `L |> Result.get_ok)
  in
  let dup = Diamond_zipper.Lazy.duplicate zip in
  assert (
    Diamond_zipper.to_diamond dup
    |> Diamond.iter_forwards
    |> Iter.for_all
         (Diamond.equal_diamond String.equal main % Diamond_zipper.to_diamond));

  let pp = Diamond_zipper.pp_zipper (Diamond_zipper.pp_zipper CCString.pp) in

  CCFormat.output Format.stdout pp dup;
  [%expect
    {|
    (Diamond_zipper.Zipper (
       (Leaf
          (Diamond_zipper.Zipper ((Leaf "left"),
             [Left {value = "merge"; right = (Leaf "right"); pred = (Leaf "pred")}
               ]
             ))),
       [Left {
          value =
          (Diamond_zipper.Zipper ((Leaf "left"),
             [Left {value = "merge"; right = (Leaf "right"); pred = (Leaf "pred")}
               ]
             ));
          right =
          (Leaf
             (Diamond_zipper.Zipper ((Leaf "right"),
                [Right {value = "merge"; left = (Leaf "left");
                   pred = (Leaf "pred")}
                  ]
                )));
          pred =
          (Leaf
             (Diamond_zipper.Zipper ((Leaf "pred"),
                [Pred {value = "merge"; left = (Leaf "left");
                   right = (Leaf "right")}
                  ]
                )))}
         ]
       ))
    |}]

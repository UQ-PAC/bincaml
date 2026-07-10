open Lang
open Common

let make_big_program n =
  let lst =
    Loader.Loadir.ast_of_string
      {|
memory shared $mem : (bv64 -> bv8);
var $PC:bv64;
prog entry @main;

proc @main()  -> () {  }
[
  block %main_code  [
    call @_aarch64_eval(0xaa1f03ff:bv32, 0x100:bv64) { .asm = "mov xzr, xzr" };
    goto (%ret_1);
  ];
  block %ret_1 [ return; ]
];
    |}
  in
  lst.prog
  |> Program.map_procedures (fun _ ->
      Procedure.map_blocks_nondet (fun (_, block) ->
          let stmts =
            block.stmts |> CCVector.to_iter |> Iter.repeat |> Iter.take n
            |> Iter.flatten |> CCVector.of_iter |> CCVector.freeze
          in
          { block with stmts }))

let millis_runtime_of f arg =
  let start = Sys.time () in
  ignore (f arg);
  let t = (Sys.time () -. start) *. 1000. in
  (* Printf.fprintf stderr "runtime millis: %f\n" t; *)
  t

let find_base_size ~target_millis f arg =
  Iter.int_range_by ~step:100 100 10_000
  |> Iter.find_map (fun n ->
      Some (millis_runtime_of f (arg n))
      |> Option.filter (fun t -> t >=. target_millis)
      |> Option.map (CCPair.make n))
  |> Option.get_exn_or "couldn't get to target_millis"

let%expect_test "lifting is sub-quadratic" =
  let base_size, base_t =
    find_base_size ~target_millis:10. Transforms.Aslp.transform_program
      make_big_program
  in

  let scale = 6 and threshold = 8 in
  let big_t =
    millis_runtime_of Transforms.Aslp.transform_program
      (make_big_program (scale * base_size))
  in
  let actual_scale = big_t /. base_t in
  if big_t <=. Float.of_int threshold *. base_t then
    Printf.printf "Pass: %dx bigger input took less than %x longer.\n" scale threshold
  else begin
    Printf.printf "Found base_size of %d taking base_t of %fms.\n" base_size
      base_t;
    Printf.printf "If linear, %dx bigger should take approx %dx longer.\n" scale
      scale;
    Printf.printf
      {|We found it actually took %fx longer (%fms), which is
bigger than the allowed test threshold of %dx. Therefore, we fail this
test which aims to ensure it's approximately linear.|}
      actual_scale big_t threshold
  end;
  [%expect
    {|
    Found base_size of 200 taking base_t of 12.154000ms.
    If linear, 6x bigger should take approx 6x longer.
    We found it actually took 9.639213x longer (117.155000ms), which is
    bigger than the allowed test threshold of 8x. Therefore, we fail this
    test which aims to ensure it's approximately linear.
    |}]

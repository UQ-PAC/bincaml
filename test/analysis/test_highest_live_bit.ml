open Bincaml_util.Common
open Analysis.Highest_live_bit

let%expect_test "test1_basic" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
prog entry @main;

proc @main() -> (out1:bv64)
[
    block %main_entry [
      var v1:bv64 := 99:bv64;

      var a:bv64 := bvashr(v1, 2:bv64);

      return (a);
    ];
];

proc @f() -> (f_out:bv32)
[
    block %f_entry [
      var v1:bv64 := 99:bv64;

      var f_a:bv32 := extract(32,0,v1);

      return (f_a);
    ];
];

proc @g() -> (g_out:bv1)
[
    block %g_entry [
      var v1:bv64 := 99:bv64;

      var g_a:bv1 := extract(1,0,extract(32,0,v1));

      return (g_a);
    ];

    block %g_entry_2 [
      var v1:bv32 := 99:bv32;

      var g_a:bv1 := extract(1,0,v1);

      return (g_a);
    ];
];

proc @h() -> (h_out:bv1)
[
    block %h_entry [
      var v1:bv64 := 99:bv64;

      var h_a:bv32 := extract(32,0,v1);
      var h_b:bv1 := extract(1,0,h_a);

      return (h_b);
    ];
];

proc @shift() -> (left_out:bv64, right_out:bv64)
[
    block %shift_entry [
      var v1:bv64 := 999:bv64;

      var left:bv64 := bvshl(v1:bv64, 32:bv32);
      var right:bv64 := bvlshr(v1:bv64, 32:bv64);

      return (left, right);
    ];
];

proc @shift2() -> (left_out:bv64, right_out:bv64)
[
    block %shift_entry [
      var v1:bv64 := 999:bv64;

      var left:bv64 := bvlshr(bvshl(v1:bv64, 32:bv64),32:bv64);
      var right:bv64 := bvshl(bvlshr(v1:bv64, 32:bv64), 32:bv64);

      return (left, right);
    ];
];

proc @trans(b:bv64) -> (out:bv32) {}
[
    block %trans [
      (var v1:bv64=out1) := call @binary_expr(0xffffffff:bv64);
      var v2:bv32 := extract(32, 0, v1:bv64);
      return (v2);
    ];
];

proc @binary_expr(c:bv64) -> (out1:bv64) {}
[
    block %binary_expr [
      var v1:bv64 := c:bv64;
      var v2:bv8 := extract(8, 0, v1:bv64);
      var v3:bv8 := extract(16, 8, v1:bv64);
      var v4:bv64 := zero_extend(56, bvand(v2:bv8, v3:bv8));
      return (v4);
    ];
];
    |}
  in
  let program = lst.prog in
  let results, p2_results = IDELiveBitSSIAnalysis.solve program in
  IDMap.iter
    (fun id vars ->
      Printf.printf "ID: %s\n" (ID.show id);

      let s =
        VarMap.to_iter vars
        |> Iter.to_string ~sep:", " (function var, value ->
            Printf.sprintf "%s -> %s" (Var.to_string var)
              (IDESSI_LB.Value.show value))
      in
      print_endline @@ "  " ^ s)
    p2_results;
  [%expect
    {|
    ID: ("@main", 0)
      out1:bv64 -> ⊤, v1:bv64 -> ⊤, a:bv64 -> ⊤
    ID: ("@f", 1)
      f_out:bv32 -> ⊤, v1:bv64 -> ⊤, f_a:bv32 -> ⊤
    ID: ("@g", 2)
      g_out:bv1 -> ⊤, v1:bv64 -> ⊤, g_a:bv1 -> ⊤
    ID: ("@h", 3)
      h_out:bv1 -> ⊤, v1:bv64 -> ⊤, h_a:bv32 -> ⊤, h_b:bv1 -> ⊤
    ID: ("@shift", 4)
      left_out:bv64 -> ⊤, right_out:bv64 -> ⊤, v1:bv64 -> ⊤, left:bv64 -> ⊤, right:bv64 -> ⊤
    ID: ("@shift2", 5)
      left_out:bv64 -> ⊤, right_out:bv64 -> ⊤, v1:bv64 -> ⊤, left:bv64 -> ⊤, right:bv64 -> ⊤
    ID: ("@trans", 6)
      out:bv32 -> ⊤, v1:bv64 -> ⊤, v2:bv32 -> ⊤
    ID: ("@binary_expr", 7)
      out1:bv64 -> ⊤, c:bv64 -> ⊤, v1:bv64 -> ⊤, v2:bv8 -> ⊤, v3:bv8 -> ⊤, v4:bv64 -> ⊤
    |}]

let%expect_test "sqrt" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
var $stack:(bv64->bv8);
prog entry @Sqrt_4196228;
proc @Sqrt_4196228(R0_in:bv64, R31_in:bv64)  -> (R0_out:bv64, R1_out:bv64) { .address = 4196228;
    .name = "Sqrt"; .returnBlock = "Sqrt_return" }
  modifies $stack:(bv64->bv8)
  captures $stack:(bv64->bv8)

[
   block %Sqrt_entry [
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xffffffffffffffd8:bv64) R0_in:bv64 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xfffffffffffffff8:bv64) 0x0:bv64 64;
      var var1_4196240_bv64_2:bv64 := load le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xffffffffffffffd8:bv64) 64;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xfffffffffffffff0:bv64) bvadd(var1_4196240_bv64_2:bv64, 0x1:bv64) 64;
      goto (%Sqrt_loop1_18);
   ];
   block %Sqrt_loop1_18 [
      var var1_4196328_bv64_2:bv64 := load le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xfffffffffffffff8:bv64) 64;
      var var1_4196336_bv64_2:bv64 := load le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xfffffffffffffff0:bv64) 64;
      goto (%phi_3,%phi_2);
   ];
   block %phi_2 [
      guard boolnot(eq(var1_4196336_bv64_2:bv64,
        bvadd(var1_4196328_bv64_2:bv64, 0x1:bv64)));
      var var1_4196256_bv64_2:bv64 := load le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xfffffffffffffff8:bv64) 64;
      var var1_4196260_bv64_2:bv64 := load le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xfffffffffffffff0:bv64) 64;
      var R0_9:bv64 := bvadd(var1_4196256_bv64_2:bv64, var1_4196260_bv64_2:bv64);
      var R1_7:bv64 := bvand(bvor(bvlshr(R0_9:bv64, 0x3f:bv64),
        bvshl(R0_9:bv64, 0x1:bv64)), 0x1:bv64);
      var R0_10:bv64 := bvadd(R1_7:bv64, R0_9:bv64);
      var R0_11:bv64 := bvor(bvand(sign_extend(63, extract(64,63, R0_10:bv64)),
        0x8000000000000000:bv64),
       bvand(bvor(bvlshr(R0_10:bv64, 0x1:bv64), bvshl(R0_10:bv64, 0x3f:bv64)),
        0x7fffffffffffffff:bv64));
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xffffffffffffffec:bv64) extract(32,0, R0_11:bv64) 32;
      var var1_4196284_bv32_2:bv32 := load le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xffffffffffffffec:bv64) 32;
      var R0_13:bv64 := zero_extend(32,
      bvmul(var1_4196284_bv32_2:bv32, var1_4196284_bv32_2:bv32));
      var R0_14:bv64 := bvor(bvand(sign_extend(63, extract(32,31, R0_13:bv64)),
        0xffffffff00000000:bv64),
       bvand(bvand(R0_13:bv64, 0xffffffff:bv64), 0xffffffff:bv64));
      var var1_4196296_bv64_2:bv64 := load le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xffffffffffffffd8:bv64) 64;
      goto (%phi_6,%phi_5);
   ];
   block %phi_5 [
      guard bvslt(var1_4196296_bv64_2:bv64, R0_14:bv64);
      var var1_4196320_bv32_2:bv32 := load le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xffffffffffffffec:bv64) 32;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xfffffffffffffff0:bv64) sign_extend(32, var1_4196320_bv32_2:bv32) 64;
      goto (%Sqrt_loop1_18);
   ];
   block %phi_6 [
      guard boolnot(bvslt(var1_4196296_bv64_2:bv64, R0_14:bv64));
      var var1_4196308_bv32_2:bv32 := load le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xffffffffffffffec:bv64) 32;
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xfffffffffffffff8:bv64) sign_extend(32, var1_4196308_bv32_2:bv32) 64;
      goto (%Sqrt_loop1_18);
   ];
   block %phi_3 [
      guard eq(var1_4196336_bv64_2:bv64, bvadd(var1_4196328_bv64_2:bv64, 0x1:bv64));
      var var1_4196348_bv64_2:bv64 := load le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xfffffffffffffff8:bv64) 64;
      goto (%Sqrt_return);
   ];
   block %Sqrt_return [
      (var R0_out:bv64 := var1_4196348_bv64_2:bv64,
       var R1_out:bv64 := var1_4196336_bv64_2:bv64);
      return;
   ]
];
    |}
  in
  let program = lst.prog in
  let results, p2_results = IDELiveBitSSIAnalysis.solve program in
  Hashtbl.iter
    (fun pid summary ->
      print_endline @@ ID.name pid;
      print_endline @@ IDELiveBitSSIAnalysis.show_summary summary;
      print_endline
      @@ Iter.to_string (fun (v, r) -> Var.name v)
      @@ VarMap.to_iter
      @@ IDMap.get_or pid p2_results ~default:VarMap.empty)
    results;
  [%expect
    {|
    @Sqrt_4196228
    (Λ,Λ->IdEdge), (Λ,$stack->⊤), (Λ,R0_in->NumEdge 63), (Λ,R31_in->NumEdge 63), (Λ,var1_4196240_bv64_2->NumEdge 63), (Λ,var1_4196328_bv64_2->NumEdge 63), (Λ,var1_4196336_bv64_2->NumEdge 63), (Λ,var1_4196256_bv64_2->NumEdge 63), (Λ,var1_4196260_bv64_2->NumEdge 63), (Λ,R0_9->NumEdge 63), (Λ,R1_7->NumEdge 63), (Λ,R0_10->NumEdge 63), (Λ,R0_11->NumEdge 31), (Λ,var1_4196284_bv32_2->NumEdge 63), (Λ,R0_13->NumEdge 63), (Λ,R0_14->NumEdge 63), (Λ,var1_4196296_bv64_2->NumEdge 63), (Λ,var1_4196320_bv32_2->NumEdge 31), (Λ,var1_4196308_bv32_2->NumEdge 31), (R0_out,R0_out->IdEdge), (R0_out,var1_4196348_bv64_2->NumEdge 63), (R1_out,R1_out->IdEdge)
    $stack, R0_in, R31_in, R0_out, R1_out, var1_4196240_bv64_2, var1_4196328_bv64_2, var1_4196336_bv64_2, var1_4196256_bv64_2, var1_4196260_bv64_2, R0_9, R1_7, R0_10, R0_11, var1_4196284_bv32_2, R0_13, R0_14, var1_4196296_bv64_2, var1_4196320_bv32_2, var1_4196308_bv32_2, var1_4196348_bv64_2
    |}]

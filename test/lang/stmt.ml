open Lang
open Lang.Stmt
open Lang.Common
open Expr

let%expect_test "frees" =
  let s =
    Instr_Assign
      [
        ( Var.create "v1" Types.Boolean,
          BasilExpr.rvar @@ Var.create "v2" Types.Boolean );
        ( Var.create "v3" Types.Boolean,
          BasilExpr.rvar @@ Var.create "v4" Types.Boolean );
      ]
  in
  print_endline (to_string ~width:80 Var.pretty Var.pretty BasilExpr.pretty s);
  print_string "Rvars: ";
  print_endline @@ Iter.to_string ~sep:"," Var.to_string (free_vars_iter s);
  print_string "Lvars: ";
  print_endline @@ Iter.to_string ~sep:"," Var.to_string (iter_lvar s);
  [%expect
    {|
    (v1:bool := v2:bool, v3:bool := v4:bool)
    Rvars: v2:bool,v4:bool
    Lvars: v1:bool,v3:bool |}]

let%expect_test "fold_block" =
  let block =
    Loader.Loadir.parse_single_block
      {|
   block %main_entry [
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xfffffffffffffffc:bv64) extract(32,0, R0_in:bv64) 32;
      var load45_1:bv32 := load le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xfffffffffffffffc:bv64) 32;
      var R1_4:bv64 := zero_extend(32, load45_1:bv32);
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) 0x420034:bv64 extract(32,0, R1_4:bv64) 32;
      var load46_1:bv32 := load le $mem:(bv64->bv8) 0x42002c:bv64 32;
      var R0_10:bv64 := zero_extend(32, load46_1:bv32);
      goto (%phi_4,%phi_3);
      ]
    |}
  in
  Block.fold_forwards
    ~f:(fun a i -> print_endline (Stmt.show_stmt_basil i))
    ~phi:(fun a i -> a)
    () block;
  print_endline (Block.to_string block);
  ();
  [%expect
    {|
    $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(R31_in:bv64,
     0xfffffffffffffffc:bv64) extract(32,0, R0_in:bv64) 32
    var load45_1:bv32 := load le $stack:(bv64->bv8) bvadd(R31_in:bv64,
     0xfffffffffffffffc:bv64) 32
    var R1_4:bv64 := zero_extend(32, load45_1:bv32)
    $mem:(bv64->bv8) := store le $mem:(bv64->bv8) 0x420034:bv64 extract(32,0, R1_4:bv64) 32
    var load46_1:bv32 := load le $mem:(bv64->bv8) 0x42002c:bv64 32
    var R0_10:bv64 := zero_extend(32, load46_1:bv32)
    [
       $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(R31_in:bv64, 0xfffffffffffffffc:bv64) extract(32, 0, R0_in:bv64) 32;
       load45_1:bv32 := load le $stack:(bv64->bv8) bvadd(R31_in:bv64, 0xfffffffffffffffc:bv64) 32;
       R1_4:bv64 := zero_extend(32, load45_1:bv32);
       $mem:(bv64->bv8) := store le $mem:(bv64->bv8) 0x420034:bv64 extract(32, 0, R1_4:bv64) 32;
       load46_1:bv32 := load le $mem:(bv64->bv8) 0x42002c:bv64 32;
       R0_10:bv64 := zero_extend(32, load46_1:bv32);
    ]
    |}]

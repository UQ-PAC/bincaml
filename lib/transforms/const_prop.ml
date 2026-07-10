(** Constant propagation

    Currently we only do interprocedural constant propagation of linear
    expressions.*)

open Bincaml_util.Common
open Lang
open Analysis.Linear_const
open Expr

(* TODO can write an intra const prop that uses interproc function summaries
   (would depend on analysis context values passed to transfer functions) *)

let prop_expr (prop : Var.t -> Bitvec.t option) =
  let open BasilExpr in
  rewrite ~rw_fun:(function
    | RVar v -> (
        match prop v.id with
        | Some x -> replace [%here] (const (`Bitvector x))
        | _ -> Keep)
    | _ -> Keep)

let transform_proc r keep =
  let prop v =
    if keep v then None
    else VarMap.find_opt v r |> Option.flat_map LinearIDE.Value.get_val
  in
  Procedure.map_blocks_topo_fwd (fun _ ->
      Block.map ~phi:id
        (Stmt.map ~f_lvar:id ~f_expr:(prop_expr prop) ~f_rvar:id))

let linear_transform (prog : Program.t) =
  let _, r = LinearConstAnalysis.solve prog in

  Program.map_procedures
    (fun pid proc -> transform_proc (IDMap.find pid r) (fun _ -> false) proc)
    prog

    (**
     ID: ("@trans", 0)
+      { Var.V.name = "out"; typ = bv32; scope = Var.LocalVar } -> ⊤
+      { Var.V.name = "v1"; typ = bv64; scope = Var.LocalVar } -> 0xffffffff:bv64
+      { Var.V.name = "v2"; typ = bv32; scope = Var.LocalVar } -> ⊤
+    ID: ("@binary_expr", 1)
+      { Var.V.name = "out1"; typ = bv32; scope = Var.LocalVar } -> ⊤
+      { Var.V.name = "v1"; typ = bv64; scope = Var.LocalVar } -> 0xffffffff:bv64
+      { Var.V.name = "v2"; typ = bv8; scope = Var.LocalVar } -> ⊤
+      { Var.V.name = "v3"; typ = bv8; scope = Var.LocalVar } -> ⊤
+      { Var.V.name = "v4"; typ = bv8; scope = Var.LocalVar } -> ⊤
    *)
    
let%expect_test "test1_basic_shifts" =
  let lst =
    Loader.Loadir.ast_of_string
      {|

proc @trans() -> (out:bv32)
[
    block %trans [
      var v1:bv64 := 0xffffffff:bv64;
      var v2:bv32 := extract(32, 0, v1:bv64);
      return (v2);
    ];
];

proc @binary_expr() -> (out1:bv32)
[
    block %trans [
      var v1:bv64 := 0xffffffff:bv64;
      var v2:bv8 := extract(8, 0, v1:bv64);
      var v3:bv8 := extract(16, 8, v1:bv64);
      var v4:bv8 := bvand(v2:bv8, v3:bv8);
      return (v4);
    ];
];
    |}
  in

  let program = lst.prog in
  
  let res = linear_transform program in
  Program.pretty_to_chan  stdout res;
  [%expect
  {|
    proc @trans()  -> (out:bv32) {  }


    [
       block %trans [
         var v1:bv64 := 0xffffffff:bv64;
         var v2:bv32 := extract(32,0, 0xffffffff:bv64);
         var out:bv32 := v2:bv32;
         return;
       ]
    ];
    proc @binary_expr()  -> (out1:bv32) {  }


    [
       block %trans [
         var v1:bv64 := 0xffffffff:bv64;
         var v2:bv8 := extract(8,0, 0xffffffff:bv64);
         var v3:bv8 := extract(16,8, 0xffffffff:bv64);
         var v4:bv8 := bvand(v2:bv8, v3:bv8);
         var out1:bv32 := v4:bv8;
         return;
       ]
    ];
    |}]
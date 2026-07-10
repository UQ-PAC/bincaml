open Bincaml_util.Common
open Lang
open Analysis.Highest_live_bit_simple
open Expr

(* Adds zero_extend(old_width - hi, var:bvhi) where Some hi is IDESSI_LB.Value.get_hi*)
let extend_sub_expr (prop : Var.t -> int option) =
  let open BasilExpr in
  rewrite_typed (function
    | RVar { id = v } -> (
        match prop v with 
          | Some hi -> (
              match Types.bit_width (Var.typ v) with
                | Some w -> (if w = (hi + 1) then None
                else Some ( unexp ~op:(`ZeroExtend (w - (hi + 1))) (rvar (Var.create (Var.name v) (Types.bv (hi + 1)))) ) 
                (* TODO: Make map at start that declares all new vars *)
                )
                | _ -> None
            )
          | _ -> None
      )
    | _ -> None
    )



let transform_proc procRes proc =
  let prop var = VarMap.find_opt var procRes |> Option.flat_map IDESSI_LB.Value.get_hi in
  Procedure.flat_map_stmts_topo_fwd (fun stmt ->
    Iter.pure (Stmt.map ~f_lvar:id ~f_expr:(extend_sub_expr prop) ~f_rvar:id stmt)) proc
(* LHS function will need to take the iterator from iter_rexpr as well*)

let highest_live_bit_transform (prog : Program.t) =
  let _, p2res = 
    Trace_core.with_span ~__FILE__ ~__LINE__ "ide highest live bit" @@ fun _ ->
    IDELiveBitSSIAnalysis.solve prog 
  in

  Program.map_procedures
    (fun pid proc -> transform_proc (IDMap.find pid p2res) proc) prog

(*
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

  [%expect
    {|
    ID: ("@trans", 0)
      { Var.V.name = "out"; typ = bv32; scope = Var.LocalVar } -> ⊤
      { Var.V.name = "v1"; typ = bv64; scope = Var.LocalVar } -> (31, 0, true)
      { Var.V.name = "v2"; typ = bv32; scope = Var.LocalVar } -> (31, 0, true)
    ID: ("@binary_expr", 1)
      { Var.V.name = "out1"; typ = bv32; scope = Var.LocalVar } -> ⊤
      { Var.V.name = "v1"; typ = bv64; scope = Var.LocalVar } -> (15, 0, true)
      { Var.V.name = "v2"; typ = bv8; scope = Var.LocalVar } -> (7, 0, true)
      { Var.V.name = "v3"; typ = bv8; scope = Var.LocalVar } -> (7, 0, true)
      { Var.V.name = "v4"; typ = bv8; scope = Var.LocalVar } -> (7, 0, true)
    |}]

  *)

(*
we want
proc @trans() -> (out:bv32)
[
    block %trans [
      var v1:bv32 := extract(32, 0, 0xffffffff:bv64);
      var v2:bv32 := extract(32, 0, zero_extend(32, v1:bv32));
      return (v2);
    ];
];

proc @binary_expr() -> (out1:bv32)
[
    block %trans [
      var v1:bv16 := extract(16, 0, 0xffffffff:bv64);
      var v2:bv8 := extract(8, 0, zero_extend(48, v1:bv16));
      var v3:bv8 := extract(16, 8, zero_extend(48, v1:bv16));
      var v4:bv8 := bvand(v2:bv8, v3:bv8);
      return (v4);
    ];
];

*)
let%expect_test "test1_basic_extracts" =
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
  
  let res = highest_live_bit_transform program in
  Program.pretty_to_chan  stdout res;
  [%expect
  {|
    |}]
open Bincaml_util.Common
open Lang
open Analysis.Highest_live_bit
open Expr

(** Transforms a program using information gained from the Highest Live Bit
    analysis. Any variables that were determined to contain dead bits are
    shortened to their respective size according to the highest live bit
    analysis.

    To maintain the types of the expressions, for any occurence of the shortened
    variable on the right hand side of an expression, a zero_extend is wrapped
    around the variable, to widen it to its original width.

    For an occurence on the left hand side of an assignment, an extract is
    wrapped around the entire right hand side expression of the assignment,
    where the size of the extract is the size of the shortened variable.

    For an occurence on the left hand side of a call, a temporary variable is
    made, where the size of the temporary variable is the same as the original
    variable. An assignment to the shortened variable is created immediately
    after the call, which extracts the highest live bits from the temporary
    variable.

    Currently, the lhs and rhs of stores and intrinsic calls are mapped
    individually.

    After these first steps, the statement is mapped over again, and for any
    extracts operating on an extend that are of the same width as the extend's
    expression, both the extract and extend are removed *)

let v_width v = Types.bit_width (Var.typ v)

let create_tmp_var proc v =
  Procedure.fresh_var ~pure:true ~name:"tmp" proc (Var.typ v)
  |> Procedure.decl_local proc

let create_new_proc_var_map procRes proc =
  let get_hi_lb = IDESSI_LB.Value.get_hi in
  VarMap.fold
    (fun v edge (acc : Var.t VarMap.t) ->
      match v_width v with
      | Some w -> (
          match get_hi_lb edge with
          | Some hi when hi < w - 1 ->
              let v' =
                Var.create (Var.name v) (Types.bv (hi + 1)) ~scope:(Var.scope v)
                |> Procedure.decl_local proc
              in
              VarMap.add v v' acc
          | _ -> acc)
      | _ -> acc)
    procRes VarMap.empty

(** When an extract on 'hi, 0' bits is used on a zero_extend that operates on an
    instruction of 'hi' width, then remove both redundant operations *)
let extract_extend_rewriter ?visit =
  let open BasilExpr in
  rewrite_typed_two ?visit (function
    | UnaryExpr
        {
          op = `Extract (hi, 0);
          arg = UnaryExpr { op = `ZeroExtend w; arg }, _;
        } -> (
        match type_of arg |> Types.bit_width with
        | Some width when hi = width -> replace [%here] arg
        | _ -> Keep)
    | UnaryExpr { op = `Extract (hi, 0); arg = a, ty } -> (
        match Types.bit_width ty with
        | Some width when hi = width -> replace [%here] (fix a)
        | _ -> Keep)
    | _ -> Keep)

let remove_extract_extend stmt =
  Stmt.map ~f_lvar:id ~f_expr:extract_extend_rewriter ~f_rvar:id stmt

(** Adds zero_extend(old_width - hi, var:bvhi) where Some hi is
    IDESSI_LB.Value.get_hi + 1*)
let transform_subexpr_rvar (get_new_var : Var.t -> Var.t option) =
  let open BasilExpr in
  rewrite_typed (function
    | RVar { id = v; attrib = a } -> (
        match get_new_var v with
        | Some new_var -> (
            match (v_width v, v_width new_var) with
            | Some w, Some w' ->
                Some (unexp ~attrib:a ~op:(`ZeroExtend (w - w')) (rvar new_var))
            | _, _ -> None)
        | _ -> None)
    | _ -> None)

(** Replaces a variable with a shortened one, if required *)
let transform_var (get_new_var : Var.t -> Var.t option) v =
  Option.value (get_new_var v) ~default:v

(** Replaces the original lvar with the new lvar, and wraps an extract for the
    width of the new lvar around the rhs expression *)
let transform_lvar_and_expr lvar expr (get_new_var : Var.t -> Var.t option) =
  let nv = get_new_var lvar in
  match nv with
  | Some new_lvar -> (
      match v_width new_lvar with
      | None -> (lvar, expr)
      | Some w' ->
          let new_expr = BasilExpr.extract ~hi_excl:w' ~lo_incl:0 expr in
          (new_lvar, new_expr))
  | None -> (lvar, expr)

let transform_proc procRes proc =
  let old_to_new_var_map = create_new_proc_var_map procRes proc in
  let get_new_var old_var = VarMap.find_opt old_var old_to_new_var_map in

  Procedure.flat_map_stmts_topo_fwd
    (fun stmt ->
      match stmt with
      | Stmt.Instr_Assign { al; attrib } ->
          let new_al =
            List.map
              (fun (lvar, expr) ->
                let new_expr = (transform_subexpr_rvar get_new_var) expr in
                transform_lvar_and_expr lvar new_expr get_new_var)
              al
          in
          Stmt.Instr_Assign { al = new_al; attrib }
          |> remove_extract_extend |> Iter.pure
      | Stmt.Instr_Load { attrib; lhs = lvar; rhs = rvar; addr = nama } as
        load_stmt ->
          let tmp_var = create_tmp_var proc lvar in
          let updated_load =
            Stmt.map
              ~f_lvar:(fun v -> tmp_var)
              ~f_expr:(transform_subexpr_rvar get_new_var)
              ~f_rvar:(transform_var get_new_var)
              load_stmt
            |> remove_extract_extend
          in
          let new_al =
            let new_lvar = transform_var get_new_var lvar in
            let expr = BasilExpr.rvar tmp_var in
            let total_expr =
              match v_width new_lvar with
              | Some w' -> BasilExpr.extract ~hi_excl:w' ~lo_incl:0 expr
              | _ -> expr
            in
            [ (new_lvar, total_expr) ]
          in
          let updated_assign =
            Stmt.Instr_Assign { al = new_al; attrib = Attrib.empty }
            |> remove_extract_extend
          in
          Iter.doubleton updated_load updated_assign
      (* | Stmt.Instr_Store { attrib ; lhs ; rhs ; value ; addr } -> stmt *)
      (* | Stmt.Instr_IntrinCall { attrib ; lhs ; name ; args } -> stmt *)
      | Stmt.Instr_Call { attrib; lhs = lvar_map; procid; args } ->
          let tmp_smap = StringMap.map (create_tmp_var proc) lvar_map in
          let updated_call =
            Stmt.Instr_Call { attrib; lhs = tmp_smap; procid; args }
            |> remove_extract_extend
          in
          let new_al =
            StringMap.fold
              (fun key tmp_var (al : (Var.t * BasilExpr.t) list) ->
                let lvar =
                  transform_var get_new_var (StringMap.find key lvar_map)
                in
                let expr = BasilExpr.rvar tmp_var in
                let total_expr =
                  match v_width lvar with
                  | Some w' -> BasilExpr.extract ~hi_excl:w' ~lo_incl:0 expr
                  | _ -> expr
                in
                al @ [ (lvar, total_expr) ])
              tmp_smap List.empty
          in
          let updated_assign =
            Stmt.Instr_Assign { al = new_al; attrib = Attrib.empty }
            |> remove_extract_extend
          in
          Iter.doubleton updated_call updated_assign
      | _ ->
          Stmt.map
            ~f_lvar:(transform_var get_new_var)
            ~f_expr:(transform_subexpr_rvar get_new_var)
            ~f_rvar:(transform_var get_new_var)
            stmt
          |> remove_extract_extend |> Iter.pure)
    proc

let highest_live_bit_transform (prog : Program.t) =
  let _, p2res =
    Trace_core.with_span ~__FILE__ ~__LINE__ "ide highest live bit" @@ fun _ ->
    IDELiveBitSSIAnalysis.solve prog
  in
  Program.map_procedures
    (fun pid proc -> transform_proc (IDMap.find pid p2res) proc)
    prog

let%expect_test "test1_basic_extracts" =
  let lst =
    Loader.Loadir.ast_of_string
      {|

proc @trans() -> (out:bv32)
[
    block %trans [
      var R0_2:bv64 := 0xffffffff:bv64;
      var R0_1:bv64 := zero_extend(32, bvadd(1:bv32, extract(32, 0, R0_2:bv64)));
      var v2:bv32 := extract(32, 0, R0_1:bv64);
      return (v2);
    ];
];

proc @binary_expr() -> (out1:bv64)
[
    block %binary_expr [
      var v1:bv64 := 0xffffffff:bv64;
      var v2:bv8 := extract(8, 0, v1:bv64);
      var v3:bv8 := extract(16, 8, v1:bv64);
      var v4:bv64 := zero_extend(56, bvand(v2:bv8, v3:bv8));
      return (v4);
    ];
];
    |}
  in
  let program = lst.prog in
  let res = highest_live_bit_transform program in
  Program.pretty_to_chan stdout res;
  [%expect
    {|
    proc @trans()  -> (out:bv32) {  }


    [
       block %trans [
         var R0_2:bv32 := extract(32,0, 0xffffffff:bv64);
         var R0_1:bv32 := bvadd(0x1:bv32, R0_2:bv32);
         var v2:bv32 := R0_1:bv32;
         var out:bv32 := v2:bv32;
         return;
       ]
    ];
    proc @binary_expr()  -> (out1:bv64) {  }


    [
       block %binary_expr [
         var v1:bv16 := extract(16,0, 0xffffffff:bv64);
         var v2:bv8 := extract(8,0, zero_extend(48, v1:bv16));
         var v3:bv8 := extract(16,8, zero_extend(48, v1:bv16));
         var v4:bv64 := zero_extend(56, bvand(v2:bv8, v3:bv8));
         var out1:bv64 := v4:bv64;
         return;
       ]
    ];
    |}]

let%expect_test "test2_basic_shifts" =
  let lst =
    Loader.Loadir.ast_of_string
      {|

proc @right_shift() -> (out:bv64)
[
    block %right_shift [
      var v1:bv64 := 0xffffffff:bv64;
      var v2:bv64 := bvlshr(v1:bv64, 10:bv64);
      return (v2);
    ];
];

proc @left_shift() -> (out1:bv64)
[
    block %left_shift [
      var v3:bv64 := 0xffffffff:bv64;
      var v4:bv64 := bvshl(v3:bv64, 10:bv64);
      return (v4);
    ];
];
    |}
  in

  let program = lst.prog in

  let res = highest_live_bit_transform program in
  Program.pretty_to_chan stdout res;
  [%expect
    {|
    proc @right_shift()  -> (out:bv64) {  }


    [
       block %right_shift [
         var v1:bv54 := extract(54,0, 0xffffffff:bv64);
         var v2:bv64 := bvlshr(zero_extend(10, v1:bv54), 0xa:bv64);
         var out:bv64 := v2:bv64;
         return;
       ]
    ];
    proc @left_shift()  -> (out1:bv64) {  }


    [
       block %left_shift [
         var v3:bv64 := 0xffffffff:bv64;
         var v4:bv64 := bvshl(v3:bv64, 0xa:bv64);
         var out1:bv64 := v4:bv64;
         return;
       ]
    ];
    |}]

let%expect_test "test3_basic_calls" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
prog entry @trans;
proc @trans(b:bv64)  -> (out:bv30) {  }
[
   block %trans [
      var b:bv64 := 0xffffffff:bv64;
      (var v1:bv64=out1) := call @binary_expr(b:bv64);

      var v2:bv30 := extract(30, 0, v1:bv64);
      (var v3:bv64, var v4:bv64) := call @double_out();
      var v5:bv30 := bvand(extract(30, 0, b:bv64), bvand(v2:bv30, bvor(extract(30, 0, v3:bv64), extract(30, 0, v4:bv64))));
      return (v5);
   ]
];
proc @binary_expr(c:bv64)  -> (out1:bv64) {  }
[
   block %binary_expr [
    var v:bv64 := bvand(0xffffffff:bv64, c:bv64);
     var out1:bv64 := v:bv64;
     return;
   ]
];

proc @double_out() -> (dout1:bv64, dout2:bv64) { }
[
    block %double_main [
      var dout1:bv64 := 111:bv64;
      var dout2:bv64 := 222:bv64;
      return;
    ];
];
    |}
  in

  let program = lst.prog in

  let res = highest_live_bit_transform program in
  Program.pretty_to_chan stdout res;
  let results, p2_results = IDELiveBitSSIAnalysis.solve program in
  IDMap.iter
    (fun id vars ->
      Printf.printf "ID: %s\n" (ID.show id);
      Printf.printf "\n\n";
      VarMap.iter
        (fun var value ->
          Printf.printf "  %s -> %s\n" (Var.show var)
            (IDESSI_LB.Value.show value))
        vars)
    p2_results;
  [%expect
    {|
    proc @trans(b:bv64)  -> (out:bv30) {  }


    [
       block %trans [
         var b:bv64 := 0xffffffff:bv64;
         (var tmp:bv64=out1) := call @binary_expr(c=b:bv64);
         var v1:bv30 := extract(30,0, tmp:bv64);
         var v2:bv30 := v1:bv30;
         (var tmp_1:bv64=dout1, var tmp_2:bv64=dout2) := call @double_out();
         (var v3:bv30 := extract(30,0, tmp_1:bv64),
          var v4:bv30 := extract(30,0, tmp_2:bv64));
         var v5:bv30 := bvand(extract(30,0, b:bv64),
          bvand(v2:bv30, bvor(v3:bv30, v4:bv30)));
         var out:bv30 := v5:bv30;
         return;
       ]
    ];
    proc @binary_expr(c:bv64)  -> (out1:bv64) {  }


    [
       block %binary_expr [
         var v:bv64 := bvand(0xffffffff:bv64, c:bv64);
         var out1:bv64 := v:bv64;
         return;
       ]
    ];
    proc @double_out()  -> (dout1:bv64, dout2:bv64) {  }


    [
       block %double_main [
         var dout1:bv64 := 0x6f:bv64;
         var dout2:bv64 := 0xde:bv64;
         return;
       ]
    ];
    prog entry @trans;ID: ("@trans", 0)


      { Var.V.name = "v1"; typ = bv64; scope = Var.LocalVar } -> (Var 29)
      { Var.V.name = "v4"; typ = bv64; scope = Var.LocalVar } -> (Var 29)
      { Var.V.name = "v3"; typ = bv64; scope = Var.LocalVar } -> (Var 29)
      { Var.V.name = "b"; typ = bv64; scope = Var.LocalVar } -> ⊤
      { Var.V.name = "out"; typ = bv30; scope = Var.LocalVar } -> ⊤
      { Var.V.name = "v2"; typ = bv30; scope = Var.LocalVar } -> (Var 29)
      { Var.V.name = "v5"; typ = bv30; scope = Var.LocalVar } -> (Var 29)
    ID: ("@binary_expr", 1)


      { Var.V.name = "out1"; typ = bv64; scope = Var.LocalVar } -> ⊤
      { Var.V.name = "c"; typ = bv64; scope = Var.LocalVar } -> (Var 63)
      { Var.V.name = "v"; typ = bv64; scope = Var.LocalVar } -> (Var 63)
    ID: ("@double_out", 2)


      { Var.V.name = "dout1"; typ = bv64; scope = Var.LocalVar } -> ⊤
      { Var.V.name = "dout2"; typ = bv64; scope = Var.LocalVar } -> ⊤
    |}]

let%expect_test "test4_basic_load_and_store" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
prog entry @main;

var $mem: (bv64 -> bv8);
var $i: bv64;

proc @main() -> (out:bv16)
[
  block %entry [
    $i := 0x0:bv64;
    goto(%loop);
  ];
  block %loop [
    goto(%loop_body, %loop_exit);
  ];
  block %loop_body [
    guard (bvult($i, 1));
    $mem := store le $mem 0x100:bv64 extract(16, 0, $i) 16;
    var a:bv16 := bvadd(extract(16, 0, $i), 0x1:bv16);
    goto(%loop);
  ];
  block %loop_exit [
    guard (bvuge($i, 0));
    var x:bv64 := load le $mem 0x100:bv64 64;
    assert bvule($i, 0);
    var y:bv16 := bvor(extract(16, 0, x), a);
    return (y);
  ]
];
    |}
  in

  let program = lst.prog in

  let res = highest_live_bit_transform program in
  Program.pretty_to_chan stdout res;
  let results, p2_results = IDELiveBitSSIAnalysis.solve program in
  IDMap.iter
    (fun id vars ->
      Printf.printf "ID: %s\n" (ID.show id);
      Printf.printf "\n\n";
      VarMap.iter
        (fun var value ->
          Printf.printf "  %s -> %s\n" (Var.show var)
            (IDESSI_LB.Value.show value))
        vars)
    p2_results;
  [%expect
    {|
    var $mem:(bv64->bv8);
    var $i:bv64;
    proc @main()  -> (out:bv16) {  }
      modifies $mem:(bv64->bv8), $i:bv64
      captures $mem:(bv64->bv8), $i:bv64

    [
       block %entry [ $i:bv64 := 0x0:bv64; goto (%loop); ];
       block %loop [ goto (%loop_exit,%loop_body); ];
       block %loop_body [
         guard bvult($i, 1);
         $mem:(bv64->bv8) := store le $mem:(bv64->bv8) 0x100:bv64 extract(16,0, $i) 16;
         var a:bv16 := bvadd(extract(16,0, $i), 0x1:bv16);
         goto (%loop);
       ];
       block %loop_exit [
         guard boolnot(bvult($i, 0));
         var tmp:bv64 := load le $mem:(bv64->bv8) 0x100:bv64 64;
         var x:bv16 := extract(16,0, tmp:bv64);
         assert bvule($i, 0);
         var y:bv16 := bvor(x:bv16, a:bv16);
         var out:bv16 := y:bv16;
         return;
       ]
    ];
    prog entry @main;ID: ("@main", 2)


      { Var.V.name = "$mem"; typ = (bv64->bv8); scope = Var.GlobalVar } -> ⊤
      { Var.V.name = "$i"; typ = bv64; scope = Var.GlobalVar } -> (Var 63)
      { Var.V.name = "out"; typ = bv16; scope = Var.LocalVar } -> ⊤
      { Var.V.name = "a"; typ = bv16; scope = Var.LocalVar } -> (Var 15)
      { Var.V.name = "x"; typ = bv64; scope = Var.LocalVar } -> (Var 15)
      { Var.V.name = "y"; typ = bv16; scope = Var.LocalVar } -> (Var 15)
    |}]

open Bincaml_util.Common
open Lang
open Analysis.Highest_live_bit_simple
open Expr

(**
  WIP transform for highest live bit. Currently only works intraprocedurally with assignments
*)

let v_width v = Types.bit_width (Var.typ v)

let create_tmp_var proc v =
  Procedure.fresh_var ~pure:true ~name:"tmp" proc (Var.typ v) 
  |> Procedure.decl_local proc

let create_new_proc_var_map procRes proc =
  let get_hi_lb = IDESSI_LB.Value.get_hi in
  VarMap.fold (
    fun v edge (acc : Var.t VarMap.t) -> 
      match v_width v with
      | Some w -> (
        match get_hi_lb edge with
        | Some hi when hi < w - 1 -> 
            let v' = Var.create (Var.name v) (Types.bv (hi + 1)) ~scope:(Var.scope v)
            |> Procedure.decl_local proc in
            VarMap.add v v' acc
        | _ -> acc
      )
      | _ -> acc
  ) procRes VarMap.empty


(* Adds zero_extend(old_width - hi, var:bvhi) where Some hi is IDESSI_LB.Value.get_hi + 1*)
let transform_subexpr_rvar (get_new_var : Var.t -> Var.t option) =
  let open BasilExpr in
  rewrite_typed (function
    | RVar { id = v ; attrib = a } -> (
        match get_new_var v with
        | Some new_var -> (
          match v_width new_var with
          | Some w' -> (
            match v_width v with
            | Some w -> Some (unexp ~attrib:a ~op:(`ZeroExtend (w - w')) (rvar new_var))
            | _ -> None
          )
          | _ -> None
        )
        | _ -> None
      )
    | _ -> None
  )


let transform_rvar (get_new_var : Var.t -> Var.t option) v =
  Option.value (get_new_var v) ~default:v
            
let transform_lvar_and_expr lvar expr (get_new_var : Var.t -> Var.t option) =
  let nv = get_new_var lvar in
  match nv with
  | Some new_lvar ->
    (match v_width new_lvar with
    | None -> lvar,expr
    | Some w' -> let new_expr = BasilExpr.extract ~hi_excl:w' ~lo_incl:0 expr in 
        new_lvar, new_expr)
  | None -> lvar,expr

let transform_proc procRes proc =
  let old_to_new_var_map = create_new_proc_var_map procRes proc in
  let get_new_var old_var = VarMap.find_opt old_var old_to_new_var_map in

  Procedure.flat_map_stmts_topo_fwd (fun stmt ->
    (* Iter.pure ( *)
      match stmt with
      | Stmt.Instr_Assign { al ; attrib } -> (
        let new_al =
          List.map (fun (lvar, expr) ->
            let new_expr = (transform_subexpr_rvar get_new_var) expr in
            transform_lvar_and_expr lvar new_expr get_new_var
            ) al
          in
          Iter.pure (Stmt.Instr_Assign { al = new_al ; attrib })
      )
      (* | Stmt.Instr_Load { attrib ; lhs ; rhs ; addr } -> stmt *)
      (* | Stmt.Instr_Store { attrib ; lhs ; rhs ; value ; addr } -> stmt *)
      (* | Stmt.Instr_IntrinCall { attrib ; lhs ; name ; args } -> stmt *)
      | Stmt.Instr_Call { attrib ; lhs = lvar_map ; procid ; args } -> 
        let tmp_smap = StringMap.map (create_tmp_var proc) lvar_map in
        let updated_call = 
        Stmt.Instr_Call { attrib ; lhs = tmp_smap ; procid ; args }
        in
        let new_al =
        StringMap.fold (fun key tmp_var (al : (Var.t * BasilExpr.t) list) -> 
          let lvar = transform_rvar get_new_var (StringMap.find key lvar_map) in 
          let expr = BasilExpr.rvar tmp_var in
          let total_expr = 
            match v_width lvar with
            | Some w' -> BasilExpr.extract ~hi_excl:w' ~lo_incl:0 expr
            | _ -> expr
          in
          al @ [(lvar, total_expr)]
          ) tmp_smap List.empty
        in
        let updated_assign = 
          Stmt.Instr_Assign {al = new_al ; attrib } (* TODO: reusing attrib is probably not good *)
        in
        Iter.doubleton updated_call updated_assign
      | _ -> Iter.pure (Stmt.map ~f_lvar:(transform_rvar get_new_var) 
                      ~f_expr:(transform_subexpr_rvar get_new_var) 
                      ~f_rvar:(transform_rvar get_new_var) 
                      stmt)
    )
     proc

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
  Program.pretty_to_chan  stdout res;
  [%expect {|
    proc @trans()  -> (out:bv32) {  }


    [
       block %trans [
         var v1:bv32 := extract(32,0, 0xffffffff:bv64);
         var v2:bv32 := extract(32,0, zero_extend(32, v1:bv32));
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
  Program.pretty_to_chan  stdout res;
  [%expect {|
    proc @right_shift()  -> (out:bv64) {  }


    [
       block %right_shift [
         var v1:bv64 := 0xffffffff:bv64;
         var v2:bv64 := bvlshr(v1:bv64, 0xa:bv64);
         var out:bv64 := v2:bv64;
         return;
       ]
    ];
    proc @left_shift()  -> (out1:bv64) {  }


    [
       block %left_shift [
         var v3:bv54 := extract(54,0, 0xffffffff:bv64);
         var v4:bv64 := bvshl(zero_extend(10, v3:bv54), 0xa:bv64);
         var out1:bv64 := v4:bv64;
         return;
       ]
    ];
    |}]

(* 
     
let%expect_test "test1_basic_shifts" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
prog entry @trans;
proc @trans(b:bv64)  -> (out:bv32) {  }
[
   block %trans [
      (var v1:bv64=out1) := call @binary_expr(0xffffffff:bv64);

      var v2:bv32 := extract(32, 0, v1:bv64);
      return (v2);
   ]
];
proc @binary_expr(c:bv64)  -> (out1:bv64) {  }
[
   block %binary_expr [
    var v:bv64 := 0xffffffff:bv64;
     var out1:bv64 := v:bv64;
     return;
   ]
];
    |}
  in

  let program = lst.prog in
  
  let res = highest_live_bit_transform program in
  Program.pretty_to_chan  stdout res;
   let results, p2_results = IDELiveBitSSIAnalysis.solve program in
  IDMap.iter (fun id vars ->
  Printf.printf "ID: %s\n" (ID.show id);
    Printf.printf "\n\n";
  VarMap.iter (fun var value ->
    Printf.printf "  %s -> %s\n"
      (Var.show var)
      (IDESSI_LB.Value.show value))
    vars
) p2_results;
  [%expect
  {|
    proc @trans(b:bv64)  -> (out:bv32) {  }


    [
       block %trans [
         (var v1:bv64=out1) := call @binary_expr(c=0xffffffff:bv64);
         var v2:bv32 := extract(32,0, zero_extend(32, v1:bv32));
         var out:bv32 := v2:bv32;
         return;
       ]
    ];
    proc @binary_expr(c:bv64)  -> (out1:bv64) {  }


    [
       block %binary_expr [
         var v:bv64 := 0xffffffff:bv64;
         var out1:bv64 := v:bv64;
         return;
       ]
    ];
    prog entry @trans;ID: ("@trans", 0)


      { Var.V.name = "out"; typ = bv32; scope = Var.LocalVar } -> ⊤
      { Var.V.name = "v1"; typ = bv64; scope = Var.LocalVar } -> (31, 0, true)
      { Var.V.name = "v2"; typ = bv32; scope = Var.LocalVar } -> (31, 0, true)
    ID: ("@binary_expr", 1)


      { Var.V.name = "out1"; typ = bv64; scope = Var.LocalVar } -> ⊤
      { Var.V.name = "v"; typ = bv64; scope = Var.LocalVar } -> (63, 0, true)
    |}] *)
let%expect_test "test3_basic_calls" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
prog entry @trans;
proc @trans(b:bv64)  -> (out:bv30) {  }
[
   block %trans [
      (var v1:bv64=out1) := call @binary_expr(0xffffffff:bv64);

      var v2:bv30 := extract(30, 0, v1:bv64);
      (var v3:bv64, var v4:bv64) := call @double_out();
      var v5:bv30 := bvand(v2:bv30, bvor(extract(30, 0, v3:bv64), extract(30, 0, v4:bv64)));
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
  Program.pretty_to_chan  stdout res;
   let results, p2_results = IDELiveBitSSIAnalysis.solve program in
  IDMap.iter (fun id vars ->
  Printf.printf "ID: %s\n" (ID.show id);
    Printf.printf "\n\n";
  VarMap.iter (fun var value ->
    Printf.printf "  %s -> %s\n"
      (Var.show var)
      (IDESSI_LB.Value.show value))
    vars
) p2_results;
  [%expect
  {|
    proc @trans(b:bv64)  -> (out:bv30) {  }


    [
       block %trans [
         (var tmp:bv64=out1) := call @binary_expr(c=0xffffffff:bv64);
         var v1:bv30 := extract(30,0, tmp:bv64);
         var v2:bv30 := extract(30,0, zero_extend(34, v1:bv30));
         (var tmp_1:bv64=dout1, var tmp_2:bv64=dout2) := call @double_out();
         (var v3:bv30 := extract(30,0, tmp_1:bv64),
          var v4:bv30 := extract(30,0, tmp_2:bv64));
         var v5:bv30 := bvand(v2:bv30,
          bvor(extract(30,0, zero_extend(34, v3:bv30)),
           extract(30,0, zero_extend(34, v4:bv30))));
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


      { Var.V.name = "v1"; typ = bv64; scope = Var.LocalVar } -> (29, 0, true)
      { Var.V.name = "v4"; typ = bv64; scope = Var.LocalVar } -> (29, 0, true)
      { Var.V.name = "v3"; typ = bv64; scope = Var.LocalVar } -> (29, 0, true)
      { Var.V.name = "out"; typ = bv30; scope = Var.LocalVar } -> ⊤
      { Var.V.name = "v2"; typ = bv30; scope = Var.LocalVar } -> (29, 0, true)
      { Var.V.name = "v5"; typ = bv30; scope = Var.LocalVar } -> (29, 0, true)
    ID: ("@binary_expr", 1)


      { Var.V.name = "out1"; typ = bv64; scope = Var.LocalVar } -> ⊤
      { Var.V.name = "c"; typ = bv64; scope = Var.LocalVar } -> (63, 0, true)
      { Var.V.name = "v"; typ = bv64; scope = Var.LocalVar } -> (63, 0, true)
    ID: ("@double_out", 2)


      { Var.V.name = "dout1"; typ = bv64; scope = Var.LocalVar } -> ⊤
      { Var.V.name = "dout2"; typ = bv64; scope = Var.LocalVar } -> ⊤
    |}]
    
let%expect_test "test4_load_and_store" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
prog entry @main;

var $mem: (bv64 -> bv8);
var $i: bv64;

proc @main() -> (out:bv64)
[
  block %entry [
    $i := 0x0:bv64;
    goto(%loop);
  ];
  block %loop [
    goto(%loop_body, %loop_exit);
  ];
  block %loop_body [
    guard (bvult($i, 0xa:bv64));
    $mem := store le $mem 0x100:bv64 $i 64;
    $i := bvadd($i, 0x1:bv64);
    goto(%loop);
  ];
  block %loop_exit [
    guard (bvuge($i, 0xa:bv64));
    var x:bv64 := load le $mem 0x100:bv64 64;
    assert bvule($i, 0x14:bv64);
    return (x);
  ]
];
    |}
  in

  let program = lst.prog in
  
  let res = highest_live_bit_transform program in
  Program.pretty_to_chan  stdout res;
   let results, p2_results = IDELiveBitSSIAnalysis.solve program in
  IDMap.iter (fun id vars ->
  Printf.printf "ID: %s\n" (ID.show id);
    Printf.printf "\n\n";
  VarMap.iter (fun var value ->
    Printf.printf "  %s -> %s\n"
      (Var.show var)
      (IDESSI_LB.Value.show value))
    vars
) p2_results;
  [%expect
  {|
    var $mem:(bv64->bv8);
    var $i:bv64;
    proc @main()  -> (out:bv64) {  }
      modifies $mem:(bv64->bv8), $i:bv64
      captures $mem:(bv64->bv8), $i:bv64

    [
       block %entry [ $i:bv64 := 0x0:bv64; goto (%loop); ];
       block %loop [ goto (%loop_exit,%loop_body); ];
       block %loop_body [
         guard bvult($i, 0xa:bv64);
         $mem:(bv64->bv8) := store le $mem:(bv64->bv8) 0x100:bv64 $i 64;
         $i:bv64 := bvadd($i, 0x1:bv64);
         goto (%loop);
       ];
       block %loop_exit [
         guard boolnot(bvult($i, 0xa:bv64));
         var x:bv64 := load le $mem:(bv64->bv8) 0x100:bv64 64;
         assert bvule($i, 0x14:bv64);
         var out:bv64 := x:bv64;
         return;
       ]
    ];
    prog entry @main;ID: ("@main", 2)


      { Var.V.name = "out"; typ = bv64; scope = Var.LocalVar } -> ⊤
      { Var.V.name = "$i"; typ = bv64; scope = Var.GlobalVar } -> (63, 0, true)
      { Var.V.name = "x"; typ = bv64; scope = Var.LocalVar } -> (63, 0, true)
    |}]

(*      
let%expect_test "test1_basic_shifts" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
prog entry @main;
proc @main(b:bv64, global_in:bv64, y:bv64)  -> () {  }
  

[
   block %inputs [ var global_1:bv64 := global_in:bv64; goto (%main_entry); ];
   block %main_entry [
     (var a:bv64=out2) := 
     call @fun2(f=b:bv64, global_in=global_1:bv64);
     var a_2:bv64 := zero_extend(32, extract(32, 0, a:bv64));
     (var x:bv64=out) := 
     call @fun1(c=a_1:bv64, d=b:bv64, global_in=global_1:bv64);
     (var b_1:bv64 := b:bv64, var x_1:bv64 := x:bv64);
     assert eq(x_1:bv64, bvadd(b_1:bv64, b_1:bv64));
     var y_1:bv64 := y:bv64;
     assert eq(y_1:bv64, 0);
     nop;
     return;
   ]
];
proc @fun1(c:bv64, d:bv64, global_in:bv64)  -> (out:bv64) {  }
  

[
   block %inputs [ var global_1:bv64 := global_in:bv64; goto (%fun1_entry); ];
   block %fun1_entry [
     (var e:bv64=out2) := 
     call @fun2(f=d:bv64, global_in=global_1:bv64);
     var out:bv64 := bvsub(c:bv64, zero_extend(32, extract(32, 0, e:bv64)));
     return;
   ]
];
proc @fun2(f:bv64, global_in:bv64)  -> (out2:bv64) {  }
  

[
   block %inputs [ var global_1:bv64 := global_in:bv64; goto (%fun2_entry); ];
   block %fun2_entry [ goto (%fun2_b,%fun2_a); ];
   block %fun2_a [
     var f_2:bv64 := f:bv64;
     guard bvsle(f_2:bv64, 0);
     (var g_2:bv64=out) := 
     call @fun1(c=f_2:bv64, d=1, global_in=global_1:bv64);
     goto (%fun2_return);
   ];
   block %fun2_b [
     var f_1:bv64 := f:bv64;
     guard boolnot(bvsle(f_1:bv64, 0));
     var g_1:bv64 := global_1:bv64;
     goto (%fun2_return);
   ];
   block %fun2_return (
     var f_3:bv64 := phi(%fun2_b -> f_1:bv64, %fun2_a -> f_2:bv64),
     var g_3:bv64 := phi(%fun2_b -> g_1:bv64, %fun2_a -> g_2:bv64)
   ) [ var out2:bv64 := bvadd(f_3:bv64, g_3:bv64); return; ]
];
    |}
  in

  let program = lst.prog in
  
  let res = highest_live_bit_transform program in
  Program.pretty_to_chan  stdout res;
   let results, p2_results = IDELiveBitSSIAnalysis.solve program in
  IDMap.iter (fun id vars ->
  Printf.printf "ID: %s\n" (ID.show id);
    Printf.printf "\n\n";
  VarMap.iter (fun var value ->
    Printf.printf "  %s -> %s\n"
      (Var.show var)
      (IDESSI_LB.Value.show value))
    vars
) p2_results;
  [%expect
  {|
    proc @main(b:bv64, global_in:bv64, y:bv64)  -> () {  }


    [
       block %inputs [ var global_1:bv64 := global_in:bv64; goto (%main_entry); ];
       block %main_entry [
         (var a:bv64=out2) := call @fun2(f=b:bv64, global_in=global_1:bv64);
         var a_2:bv64 := zero_extend(32, extract(32,0, zero_extend(32, a:bv32)));
         (var x:bv64=out) := call @fun1(c=a_1:bv64, d=b:bv64, global_in=global_1:bv64);
         (var b_1:bv64 := b:bv64, var x_1:bv64 := x:bv64);
         assert eq(x_1:bv64, bvadd(b_1:bv64, b_1:bv64));
         var y_1:bv64 := y:bv64;
         assert eq(y_1:bv64, 0);
         return;
       ]
    ];
    proc @fun1(c:bv64, d:bv64, global_in:bv64)  -> (out:bv64) {  }


    [
       block %inputs [ var global_1:bv64 := global_in:bv64; goto (%fun1_entry); ];
       block %fun1_entry [
         (var e:bv64=out2) := call @fun2(f=d:bv64, global_in=global_1:bv64);
         var out:bv64 := bvsub(c:bv64,
          zero_extend(32, extract(32,0, zero_extend(32, e:bv32))));
         return;
       ]
    ];
    proc @fun2(f:bv64, global_in:bv64)  -> (out2:bv64) {  }


    [
       block %inputs [ var global_1:bv64 := global_in:bv64; goto (%fun2_entry); ];
       block %fun2_entry [ goto (%fun2_a,%fun2_b); ];
       block %fun2_b [
         var f_1:bv64 := f:bv64;
         guard boolnot(bvsle(f_1:bv64, 0));
         var g_1:bv64 := global_1:bv64;
         goto (%fun2_return);
       ];
       block %fun2_a [
         var f_2:bv64 := f:bv64;
         guard bvsle(f_2:bv64, 0);
         (var g_2:bv64=out) := call @fun1(c=f_2:bv64, d=1, global_in=global_1:bv64);
         goto (%fun2_return);
       ];
       block %fun2_return (
         var f_3:bv64 := phi(%fun2_b -> f_1:bv64, %fun2_a -> f_2:bv64),
         var g_3:bv64 := phi(%fun2_b -> g_1:bv64, %fun2_a -> g_2:bv64)
       ) [ var out2:bv64 := bvadd(f_3:bv64, g_3:bv64); return; ]
    ];
    prog entry @main;ID: ("@main", 0)


      { Var.V.name = "b"; typ = bv64; scope = Var.LocalVar } -> (63, 0, true)
      { Var.V.name = "global_in"; typ = bv64; scope = Var.LocalVar } -> (63, 0, true)
      { Var.V.name = "y"; typ = bv64; scope = Var.LocalVar } -> (63, 0, true)
      { Var.V.name = "a"; typ = bv64; scope = Var.LocalVar } -> (31, 0, true)
      { Var.V.name = "x"; typ = bv64; scope = Var.LocalVar } -> (63, 0, true)
      { Var.V.name = "b_1"; typ = bv64; scope = Var.LocalVar } -> (63, 0, true)
      { Var.V.name = "x_1"; typ = bv64; scope = Var.LocalVar } -> (63, 0, true)
      { Var.V.name = "y_1"; typ = bv64; scope = Var.LocalVar } -> (63, 0, true)
    ID: ("@fun1", 1)


      { Var.V.name = "global_in"; typ = bv64; scope = Var.LocalVar } -> (63, 0, true)
      { Var.V.name = "c"; typ = bv64; scope = Var.LocalVar } -> (63, 0, true)
      { Var.V.name = "out"; typ = bv64; scope = Var.LocalVar } -> ⊤
      { Var.V.name = "e"; typ = bv64; scope = Var.LocalVar } -> (31, 0, true)
    ID: ("@fun2", 2)


      { Var.V.name = "global_in"; typ = bv64; scope = Var.LocalVar } -> (63, 0, true)
      { Var.V.name = "f"; typ = bv64; scope = Var.LocalVar } -> (63, 0, true)
      { Var.V.name = "out2"; typ = bv64; scope = Var.LocalVar } -> ⊤
      { Var.V.name = "global_1"; typ = bv64; scope = Var.LocalVar } -> (63, 0, true)
      { Var.V.name = "f_2"; typ = bv64; scope = Var.LocalVar } -> (63, 0, true)
      { Var.V.name = "g_2"; typ = bv64; scope = Var.LocalVar } -> (63, 0, true)
      { Var.V.name = "f_1"; typ = bv64; scope = Var.LocalVar } -> (63, 0, true)
      { Var.V.name = "g_1"; typ = bv64; scope = Var.LocalVar } -> (63, 0, true)
      { Var.V.name = "f_3"; typ = bv64; scope = Var.LocalVar } -> (63, 0, true)
      { Var.V.name = "g_3"; typ = bv64; scope = Var.LocalVar } -> (63, 0, true)
    |}]  *)
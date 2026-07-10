open Bincaml_util.Common
open Lang
open Analysis.Highest_live_bit_simple
open Expr

let v_width v = Types.bit_width (Var.typ v)

let create_new_proc_var_map proc procRes =
  let get_hi_lb = IDESSI_LB.Value.get_hi in
  let smaller_highBits = VarMap.filter (fun var edge -> 
      match v_width var with
      | Some w -> (match get_hi_lb edge with
          | Some hi -> if hi < w - 1 then true else false
          | _ -> false)
      | _ -> false
    ) procRes
  in
  smaller_highBits

let create_new_proc_var_map2 proc procRes =
  let get_hi_lb = IDESSI_LB.Value.get_hi in
  VarMap.fold (
    fun v edge (acc : Var.t VarMap.t ) -> 
      match v_width v with
      | Some w -> (
        match get_hi_lb edge with
        | Some hi -> if hi < w - 1 then (
          let v' = Var.create (Var.name v) (Types.bv (hi + 1)) ~scope:(Var.scope v) in 
          ignore (Procedure.decl_local proc v');
          VarMap.add v v' acc) else acc
        | _ -> acc
      )
      | _ -> acc
  ) procRes VarMap.empty


(* Adds zero_extend(old_width - hi, var:bvhi) where Some hi is IDESSI_LB.Value.get_hi*)
let extend_sub_expr (get_new_var : Var.t -> Var.t option) =
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
  | Some new_var ->
    (match v_width new_var with
    | None -> lvar,expr
    | Some w' -> let new_expr = BasilExpr.extract ~hi_excl:w' ~lo_incl:0 expr in new_var, new_expr)
  | None -> lvar,expr

let transform_proc procRes proc =
  let old_to_new_var_map = create_new_proc_var_map2 proc procRes in
  let get_new_var old_var = VarMap.find_opt old_var old_to_new_var_map in

  Procedure.flat_map_stmts_topo_fwd (fun stmt ->
    Iter.pure (
      match stmt with
      | Stmt.Instr_Assign { al ; attrib } -> (
        let new_al =
          List.map (fun (lvar, expr) ->
            let new_expr = (extend_sub_expr get_new_var) expr in
            transform_lvar_and_expr lvar new_expr get_new_var
            ) al
          in
          Stmt.Instr_Assign { al = new_al ; attrib }
      )
      (* | Stmt.Instr_Load { attrib ; lhs ; rhs ; addr } -> Iter.pure (stmt) *)
      (* | Stmt.Instr_Store { attrib ; lhs ; rhs ; value ; addr } -> Iter.pure (stmt) *)
      (* | Stmt.Instr_IntrinCall { attrib ; lhs ; name ; args } -> Iter.pure (stmt) *)
      (* | Stmt.Instr_Call { attrib ; lhs ; procid ; args } -> Iter.pure (stmt) *)
      | _ -> Stmt.map ~f_lvar:id ~f_expr:(extend_sub_expr get_new_var ) ~f_rvar:(transform_rvar get_new_var) stmt
    )
    ) proc
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
    proc @trans()  -> (out:bv32) {  }


    [
       block %trans [
         var v1:bv32 := extract(32,0, 0xffffffff:bv64);
         var v2:bv32 := extract(32,0, zero_extend(32, v1:bv32));
         var out:bv32 := v2:bv32;
         return;
       ]
    ];
    proc @binary_expr()  -> (out1:bv32) {  }


    [
       block %trans [
         var v1:bv16 := extract(16,0, 0xffffffff:bv64);
         var v2:bv8 := extract(8,0, zero_extend(48, v1:bv16));
         var v3:bv8 := extract(16,8, zero_extend(48, v1:bv16));
         var v4:bv8 := bvand(v2:bv8, v3:bv8);
         var out1:bv32 := v4:bv8;
         return;
       ]
    ];
    |}]
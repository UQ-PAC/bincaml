open Lang.Common
open Lang
open Expr
module EMap = Map.Make (Expr.BasilExpr.ExprHashCons)
module ESet = Set.Make (Expr.BasilExpr.ExprHashCons)

let to_basil e = Expr.BasilExpr.ExprHashCons.cata Expr.BasilExpr.fix e
let of_basil e = Expr.BasilExpr.ExprHashCons.of_expr e

let show_he (e : ESet.elt) =
  let i = Fix.HashCons.id e in
  let h = Fix.HashCons.hash e in
  let ihash = Hashtbl.hash e in
  let full =
    Expr.BasilExpr.HashExprFix.unfix e
    |> Expr.BasilExpr.show_abstract (fun f e ->
        Format.fprintf f "%d" @@ Fix.HashCons.id e)
  in
  let t =
    Expr.BasilExpr.ExprHashCons.cata Expr.BasilExpr.fix e
    |> Expr.BasilExpr.to_string_annot
  in
  Printf.sprintf "%d:%d:%d=%s==%s" i h ihash t full

let compl e =
  AbstractExpr.(
    match e with RVar _ -> 1 | Constant _ -> 1 | _ -> fold ( + ) 1 e)

let visit_block st ~thresh s =
  let open Stmt in
  let vstmt st s =
    Stmt.iter_rexpr s
    |> Iter.filter_map (function `Expr e -> Some e | _ -> None)
    |> Iter.flat_map Expr.BasilExpr.children_iter
    |> Iter.fold
         (fun a k ->
           let k = BasilExpr.fix k in
           let e = of_basil k in
           EMap.update e
             (function
               | Some (compl, count) -> Some (compl, count + 1)
               | None ->
                   let c = BasilExpr.cata compl k in
                   Some (c, 1))
             a)
         st
  in
  Block.stmts_iter s |> Iter.fold vstmt st

let subst_expr substs e =
  BasilExpr.rewrite_down
    ~rw_fun:(fun e ->
      match EMap.find_opt (of_basil @@ BasilExpr.fix e) substs with
      | Some v -> BasilExpr.replace [%here] (BasilExpr.rvar v)
      | None -> BasilExpr.replace [%here] (BasilExpr.fix e))
    e

type substituting = {
  allowed : ESet.t;
  avail : Var.t EMap.t;
  defined : VarSet.t;
}

let new_subst_expr st e =
  let alg e =
    let hc =
      Expr.BasilExpr.ExprHashCons.fix @@ AbstractExpr.drop_attrib
      @@ AbstractExpr.map fst e
    in
    let x = AbstractExpr.map snd e |> AbstractExpr.fold ESet.union ESet.empty in
    let x =
      if ESet.mem hc st.allowed && not (EMap.mem hc st.avail) then ESet.add hc x
      else x
    in
    (hc, x)
  in
  let to_add = BasilExpr.cata alg e in
  snd to_add

let tf_stmt st ~thresh p s =
  let open Stmt in
  let new_substs st =
    ESet.diff st.allowed (ESet.of_iter @@ EMap.keys st.avail)
    |> ESet.filter (fun v ->
        VarSet.is_empty
        @@ VarSet.diff (BasilExpr.ExprHashCons.free_vars v) st.defined)
    |> ESet.to_iter
    |> Iter.uniq ~eq:Expr.BasilExpr.ExprHashCons.equal
    |> Iter.map (fun e ->
        let v =
          Procedure.fresh_var ~pure:true ~name:"cse" p
            (BasilExpr.ExprHashCons.get_typ e)
        in
        (e, v))
    |> Iter.persistent (* needed because of fresh_var *)
  in
  let new_bef = new_substs st in
  let df = Stmt.iter_lvar s |> VarSet.add_iter st.defined in
  let st = { st with defined = df } in
  let substs =
    new_bef |> EMap.of_iter |> EMap.union (fun k v1 v2 -> Some v2) st.avail
  in
  let st = { st with avail = substs } in
  let stmt' =
    Stmt.map ~f_lvar:Fun.id ~f_rvar:Fun.id ~f_expr:(subst_expr st.avail) s
  in
  let new_after = new_substs st in
  let substs_bef' =
    Iter.map (fun (e, v) -> Instr_Assign [ (v, to_basil e) ]) new_bef
  in
  let substs_after =
    new_after |> EMap.of_iter |> EMap.union (fun k v1 v2 -> Some v2) st.avail
  in
  let substs_after' =
    Iter.map (fun (e, v) -> Instr_Assign [ (v, to_basil e) ]) new_after
  in
  let st = { st with avail = substs_after } in
  ( st,
    Iter.append substs_bef' @@ Iter.append (Iter.singleton stmt') substs_after'
  )

let cse_block st ~thresh p i b =
  Logs.debug (fun m ->
      m "cse : %s: avail:%d allow:%d" (ID.to_string i) (EMap.cardinal st.avail)
        (ESet.cardinal st.allowed));

  let d = Block.(b.phis |> List.map (function { lhs } -> lhs)) in
  let st = { st with defined = VarSet.add_list st.defined d } in

  let e = ref st in
  let new_block =
    Block.flat_map ~phi:Fun.id (fun stmt ->
        let ne, s = tf_stmt !e ~thresh p stmt in
        e := ne;
        s)
  in
  (!e, new_block b)

let visit_proc ?(count_thresh = 2) ~thresh st p =
  let st =
    Procedure.iter_blocks_topo_fwd p
    |> Iter.fold (fun a (_, b) -> visit_block ~thresh a b) st
  in
  let subst =
    st
    |> EMap.filter (fun _ (compl, count) ->
        compl >= thresh && count >= count_thresh)
    |> EMap.keys |> ESet.of_iter
  in
  subst

let block_defs p =
  Procedure.iter_blocks p
  |> Iter.flat_map (fun (id, b) ->
      Block.assigned_vars_iter b |> Iter.map (fun v -> (v, b)))

let do_proc ~thresh p =
  let module Dom = Graph.Dominator.Make (Procedure.BlockGraph.G) in
  let g = Procedure.BlockGraph.of_proc p in
  let st = visit_proc ~thresh EMap.empty p in
  let sub =
    {
      allowed = st;
      avail = EMap.empty;
      defined = VarSet.of_iter (Procedure.formal_in_params p |> StringMap.values);
    }
  in
  if ESet.is_empty st then p
  else
    match g with
    | None -> p
    | Some g ->
        let dom = Dom.compute_idom g Entry in
        let succs = Dom.idom_to_dom_tree g dom in

        let rec iter vert acc p =
          let acc, p =
            match vert with
            | Procedure.BlockGraph.Vert.Block id ->
                let bl =
                  Procedure.get_block p id |> Option.get_exn_or "unrch"
                in
                let acc, b = cse_block acc ~thresh p id bl in
                let p = Procedure.update_block p id b in
                (acc, p)
            | _ -> (acc, p)
          in

          let p = List.fold_left (fun p i -> iter i acc p) p (succs vert) in
          p
        in
        iter Procedure.BlockGraph.Vert.Entry sub p

let transform p = do_proc ~thresh:3 p

let%expect_test "cse1" =
  Printf.printf "%d %d %d\nnn" (Hashtbl.hash `BVNOT) (Hashtbl.hash `BVNOT)
    (Hashtbl.hash `BVNOT);
  Printf.printf "%s \nnn"
    (if Ops.AllOps.equal_unary `BVNOT `BVNOT then "true" else "false");

  let eq =
    List.init 5 (fun _ ->
        BasilExpr.unexp ~op:`BVNOT
          (BasilExpr.bvconst (Bitvec.of_int ~size:32 5))
        |> BasilExpr.ExprHashCons.of_expr
        |> fun id ->
        Printf.sprintf "%d %d" (Fix.HashCons.id id) (Fix.HashCons.hash id))
    |> List.to_string ~sep:", " Fun.id
  in
  print_endline eq;

  let bl =
    {|
   block %scanner_hook_333 (
     var R0_179:bv64 := phi(%scanner_hook_337 -> var1_4247200_bv64_1:bv64,
        %scanner_hook_335 -> R0_176:bv64)
   ) [
     var A:bv64 := bvnot(1:bv64);
     var B:bv64 := bvnot(1:bv64);
     var C:bv64 := bvnot(1:bv64);
     var D:bv64 := bvnot(1:bv64);
     return;
   ]
    |}
  in
  let prog, proc, b = Loader.Loadir.parse_single_block_proc bl in
  Program.output_proc_pretty stdout proc;
  let p2 = do_proc ~thresh:2 proc in
  Program.output_proc_pretty stdout p2;
  [%expect
    {|
    215962290 215962290 215962290
    nntrue
    nn1 883721435, 1 883721435, 1 883721435, 1 883721435, 1 883721435
    proc <proc>()  -> () {  }


    [
       block blah [
         var A:bv64 := bvnot(0x1:bv64);
         var B:bv64 := bvnot(0x1:bv64);
         var C:bv64 := bvnot(0x1:bv64);
         var D:bv64 := bvnot(0x1:bv64);
         return;
       ]
    ]proc <proc>()  -> () {  }


    [
       block blah [
         var cse:bv64 := bvnot(0x1:bv64);
         var A:bv64 := cse:bv64;
         var B:bv64 := cse:bv64;
         var C:bv64 := cse:bv64;
         var D:bv64 := cse:bv64;
         return;
       ]
    ]
    |}]

let%expect_test "hash" =
  let a0 = Loader.Loadir.parse_expr_string "bvnot(1:bv64)" in
  let a = BasilExpr.ExprHashCons.of_expr a0 in
  let b0 = Loader.Loadir.parse_expr_string "bvnot(0x1:bv64)" in
  let b = BasilExpr.ExprHashCons.of_expr b0 in
  Printf.printf "%s =\n%s\n" (show_he a) (show_he b);
  if BasilExpr.ExprHashCons.equal a b then print_endline "equal"
  else print_endline "not_equal";
  if BasilExpr.equal a0 b0 then print_endline "o equal"
  else print_endline "o not_equal";
  [%expect
    {|
    3:152507349:359444824=bvnot(0x1:bv64: bv64): bv64==Expr.AbstractExpr.UnaryExpr {attrib = {  }; op = `BVNOT; arg = 2; typ = bv64} =
    3:152507349:359444824=bvnot(0x1:bv64: bv64): bv64==Expr.AbstractExpr.UnaryExpr {attrib = {  }; op = `BVNOT; arg = 2; typ = bv64}
    equal
    o not_equal
    |}]

let%expect_test "z hash" =
  let a = Z.of_string "1" in
  let b = Z.of_string "0x1" in
  assert (String.equal (Z.to_string a) (Z.to_string b));
  ()

let%expect_test "cse mid" =
  let bl =
    {|
   block %scanner_hook_333 (
     var R0_179:bv64 := phi(%scanner_hook_337 -> var1_4247200_bv64_1:bv64,
        %scanner_hook_335 -> R0_176:bv64)
   ) [
     var VF_110:bv1 := bvnot(booltobv1(eq(sign_extend(64,
        bvadd(R22_85:bv64, bvnot(bvashr(R0_179:bv64, 0xa:bv64)), 0x1:bv64)),
        bvadd(sign_extend(64, R22_85:bv64),
         sign_extend(64, bvnot(bvashr(R0_179:bv64, 0xa:bv64))), 0x1:bv128))));
     return;
   ]
    |}
  in
  let prog, proc, b = Loader.Loadir.parse_single_block_proc bl in
  Program.output_proc_pretty stdout proc;
  let p2 = do_proc ~thresh:2 proc in
  Program.output_proc_pretty stdout p2;
  [%expect
    {|
    proc <proc>(R0_179:bv64, R22_85:bv64)  -> () {  }


    [
       block blah [
         var VF_110:bv1 := bvnot(booltobv1(eq(sign_extend(64,
            bvadd(R22_85:bv64, bvnot(bvashr(R0_179:bv64, 0xa:bv64)), 0x1:bv64)),
            bvadd(sign_extend(64, R22_85:bv64),
             sign_extend(64, bvnot(bvashr(R0_179:bv64, 0xa:bv64))), 0x1:bv128))));
         return;
       ]
    ]proc <proc>(R0_179:bv64, R22_85:bv64)  -> () {  }


    [
       block blah [
         var cse:bv64 := bvashr(R0_179:bv64, 0xa:bv64);
         var cse_1:bv64 := bvnot(bvashr(R0_179:bv64, 0xa:bv64));
         var VF_110:bv1 := bvnot(booltobv1(eq(sign_extend(64,
            bvadd(R22_85:bv64, cse_1:bv64, 0x1:bv64)),
            bvadd(sign_extend(64, R22_85:bv64), sign_extend(64, cse_1:bv64), 0x1:bv128))));
         return;
       ]
    ]
    |}]

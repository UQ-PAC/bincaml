open Lang.Common
open Lang
open Expr
open Expr_hashcons
module EMap = Map.Make (ExprHashCons)
module ESet = Set.Make (ExprHashCons)

let src = Logs.Src.create ~doc:("common subexpr elim: " ^ __FILE__) "cse"

module Logs = (val Logs.src_log src : Logs.LOG)

open struct
  let to_basil e = ExprHashCons.cata Expr.BasilExpr.fix e
  let of_basil e = ExprHashCons.of_expr e

  let count_candidates_block st ~thresh s =
    let count_subexpr e =
      AbstractExpr.(
        match e with RVar _ -> 1 | Constant _ -> 1 | _ -> fold ( + ) 1 e)
    in
    let vstmt st s =
      Stmt.iter_rexpr s
      |> Iter.filter_map (function `Expr e -> Some e | _ -> None)
      |> Iter.flat_map BasilExpr.children_iter
      |> Iter.fold
           (fun a k ->
             let k = BasilExpr.fix k in
             let e = of_basil k in
             EMap.update e
               (function
                 | Some (compl, count) -> Some (compl, count + 1)
                 | None ->
                     let c = BasilExpr.cata count_subexpr k in
                     Some (c, 1))
               a)
           st
    in
    Block.stmts_iter s |> Iter.fold vstmt st

  type substituting = {
    allowed : ESet.t;  (** candidate expressions *)
    avail : Var.t EMap.t;  (** defined expressions cse we can substitute for *)
    defined : VarSet.t;  (** set of variables defined at this program point *)
    dirty : bool; (* are there new defs we need to process? *)
  }

  let subst_expr substs e =
    let open Expr_rewrite in
    rewrite_down
      ~rw_fun:(fun e ->
        match EMap.find_opt (of_basil @@ BasilExpr.fix e) substs with
        | Some v -> replace [%here] (BasilExpr.rvar v)
        | None -> replace [%here] (BasilExpr.fix e))
      e

  (** introduce new definitions for every cse candidate expression which (i)
      does not already have a definition available and, (ii) has all its
      dependencies defined

      return new st moving these defs from allowed to avail, and assignments to
      introduce *)
  let cse_make_avail st p =
    if not st.dirty then (st, Iter.empty)
    else
      let new_substs =
        ESet.diff st.allowed (ESet.of_iter @@ EMap.keys st.avail)
        |> ESet.filter (fun v ->
            VarSet.is_empty @@ VarSet.diff (ExprHashCons.free_vars v) st.defined)
        |> ESet.to_iter
        |> Iter.map (fun e ->
            let v =
              Procedure.fresh_var ~pure:true ~name:"cse" p
                (ExprHashCons.get_typ e)
            in
            (e, v))
        |> Iter.persistent (* needed because of fresh_var side-effect *)
      in
      let allowed =
        ESet.diff st.allowed (Iter.map fst new_substs |> ESet.of_iter)
      in
      let st =
        {
          st with
          allowed;
          dirty = false;
          avail =
            new_substs |> EMap.of_iter
            |> EMap.union (fun k v1 v2 -> Some v2) st.avail;
        }
      in
      ( st,
        new_substs
        |> Iter.map (fun (e, v) ->
            Stmt.Instr_Assign
              { al = [ (v, to_basil e) ]; attrib = Attrib.empty }) )

  let cse_substitute_stmt st p s =
    let st, substs_bef = cse_make_avail st p in
    let st =
      {
        st with
        defined = Stmt.iter_lvar s |> VarSet.add_iter st.defined;
        dirty = not (Iter.is_empty (Stmt.iter_lvar s));
      }
    in
    let stmt' =
      Stmt.map ~f_lvar:Fun.id ~f_rvar:Fun.id ~f_expr:(subst_expr st.avail) s
    in
    (* introduce defs for cse exprs which become defined due to this stmt's LHS *)
    let st, substs_after = cse_make_avail st p in
    (st, Iter.append substs_bef (Iter.cons stmt' substs_after))

  let cse_subst_block st p i b =
    Logs.debug (fun m ->
        m "cse : %s: avail:%d allow:%d" (ID.to_string i)
          (EMap.cardinal st.avail) (ESet.cardinal st.allowed));

    (* add phis to defs *)
    let d = Block.(b.phis |> List.map (function { lhs } -> lhs)) in
    let st =
      {
        st with
        defined = VarSet.add_list st.defined d;
        dirty = st.dirty || not (List.is_empty d);
      }
    in

    (* subst stmts *)
    let e = ref st in
    let new_block =
      Block.flat_map ~phi:Fun.id (fun stmt ->
          let ne, s = cse_substitute_stmt !e p stmt in
          e := ne;
          s)
    in
    (!e, new_block b)

  let get_cse_candidates_proc ?(count_thresh = 2) ~thresh st p =
    let st =
      Procedure.iter_blocks_topo_fwd p
      |> Iter.fold (fun a (_, b) -> count_candidates_block ~thresh a b) st
    in
    let subst =
      st
      |> EMap.filter (fun _ (compl, count) ->
          compl >= thresh && count >= count_thresh)
      |> EMap.keys |> ESet.of_iter
    in
    subst

  let cse_tf_proc ?(min_subexprs = 2) ?(min_occurances = 2) p =
    let module Dom = Graph.Dominator.Make (Procedure.BlockGraph.G) in
    let g = Procedure.BlockGraph.of_proc p in
    let st =
      get_cse_candidates_proc ~thresh:min_subexprs ~count_thresh:min_occurances
        EMap.empty p
    in
    let sub =
      {
        allowed = st;
        avail = EMap.empty;
        dirty = true;
        defined =
          VarSet.of_iter (Procedure.formal_in_params p |> StringMap.values);
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
                  let acc, b = cse_subst_block acc p id bl in
                  let p = Procedure.update_block p id b in
                  (acc, p)
              | _ -> (acc, p)
            in

            let p = List.fold_left (fun p i -> iter i acc p) p (succs vert) in
            p
          in
          iter Procedure.BlockGraph.Vert.Entry sub p
end

let transform p = cse_tf_proc ~min_subexprs:3 ~min_occurances:2 p

let%expect_test "cse1" =
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
  print_endline "";
  let p2 = cse_tf_proc ~min_subexprs:2 proc in
  Program.output_proc_pretty stdout p2;
  [%expect
    {|
    proc <proc>()  -> () {  }


    [
       block blah [
         var A:bv64 := bvnot(0x1:bv64);
         var B:bv64 := bvnot(0x1:bv64);
         var C:bv64 := bvnot(0x1:bv64);
         var D:bv64 := bvnot(0x1:bv64);
         return;
       ]
    ]
    proc <proc>()  -> () {  }


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
  print_endline "";
  let p2 = cse_tf_proc ~min_subexprs:2 ~min_occurances:2 proc in
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
    ]
    proc <proc>(R0_179:bv64, R22_85:bv64)  -> () {  }


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

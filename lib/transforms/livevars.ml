(** Dead code elimination based on intraprocedural live local-variables analysis
*)

open Bincaml_util.Common
open Lang
open Expr
open Types

(** Bourdoncle live-variable analysis using ocamlgraph's chaotic iteration *)
module LV =
  Graph.ChaoticIteration.Make
    (Procedure.RevG)
    (struct
      open Procedure

      type vertex = RevG.E.vertex
      type edge = RevG.E.t
      type g = RevG.t
      type t = VarSet.t

      let equal = VarSet.equal
      let join = VarSet.union
      let widening a b = VarSet.union a b

      let analyze (e : edge) d =
        match G.E.label e with Block b -> Block.free_vars ~init:d b | _ -> d
    end)

let run (p : Program.proc) =
  let analyse graph =
    let wto =
      Trace_core.with_span ~__FILE__ ~__LINE__ "WTO" @@ fun _ ->
      Procedure.RevWTO.recursive_scc graph Procedure.Vert.Return
    in
    Trace_core.with_span ~__FILE__ ~__LINE__ "live-vars-analysis" @@ fun _ ->
    LV.recurse graph wto
      (function
        | Return ->
            Procedure.formal_out_params p
            |> Common.StringMap.values |> VarSet.of_iter
        | _ -> VarSet.empty)
      (Graph.ChaoticIteration.Predicate (fun _ -> false))
      10
  in
  let res = Procedure.graph p |> Option.map analyse in
  fun v ->
    Option.get_or ~default:VarSet.empty (Option.flat_map (LV.M.find_opt v) res)

let label (r : Procedure.G.vertex -> VarSet.t) (v : Procedure.G.vertex) =
  let show_v b =
    let open Containers_pp in
    let open Containers_pp.Infix in
    let x =
      fill
        (text "," ^ newline)
        (VarSet.to_list b |> List.map (fun v -> Containers_pp.text (Var.name v)))
    in
    Pretty.to_string ~width:80 x
  in
  show_v (r v)

let print_g res = Viscfg.dot_labels (fun v -> Some (label res v))

let print_live_vars_dot fmt p =
  let r = run p in
  Trace_core.with_span ~__FILE__ ~__LINE__ "dot-priner" @@ fun _ ->
  let (module M : Viscfg.ProcPrinter) =
    Viscfg.dot_labels (fun v -> Some (label r v))
  in
  Procedure.graph p |> Option.iter (fun g -> M.fprint_graph fmt g)

let%expect_test _ =
  let open BasilExpr in
  let v1 = Var.create "v1" (Types.bv 0x1) in
  let v2 = Var.create "v2" (Types.bv 0x1) in
  let v3 = Var.create "v3" (Types.bv 0x1) in

  let e1 =
    BasilExpr.forall ~bound:[ v2 ]
      (applyintrin ~op:`AND [ rvar v1; rvar v2; rvar v3 ])
  in
  let exp = BasilExpr.forall ~bound:[ v1 ] (binexp ~op:`EQ (rvar v2) e1) in
  print_endline (to_string exp);
  let sub v = Some (bvconst (Bitvec.of_int ~size:5 150)) in
  let e2 = BasilExpr.substitute sub exp in
  print_endline (to_string e2);
  [%expect
    {|
    forall (v1:bv1) :: (eq(v2, forall (v2:bv1) :: (booland(v1, v2, v3))))
    forall (v1:bv1) :: (eq(0x16:bv5, forall (v2:bv1) :: (booland(v1, v2, 0x16:bv5))))
    |}]

module DSE = struct
  (** Dead-store elimination for local variables based on intraprocedural live
      variables analysis *)

  let filter_dead (live : VarSet.t) (b : (Var.t, BasilExpr.t) Block.t) =
    let r =
      Block.fold_backwards
        ~f:(fun (live, acc) s ->
          let is_assign =
            match s with Stmt.Instr_Assign _ -> true | _ -> false
          in
          let dead_store =
            is_assign
            && Stmt.iter_lvar s
               |> Iter.for_all (fun v ->
                   Var.is_local v && (not @@ VarSet.mem v live))
          in
          let live =
            VarSet.filter Var.is_local @@ Stmt.free_vars ~init:live s
          in
          let s = if dead_store then acc else s :: acc in
          (live, s))
        b
        ~phi:(fun x a -> x)
        ~init:(live, [])
    in
    Vector.of_list (snd r)

  let sane_transform (p : Program.proc) =
    let live = run p in
    let blocks = Procedure.blocks_to_list p in
    List.fold_left
      (fun p b ->
        match b with
        | Procedure.Vert.Begin id, (b : (Var.t, Expr.BasilExpr.t) Block.t) ->
            let stmts = filter_dead (live (End id)) b in
            Procedure.update_block p id { b with stmts }
        | _ -> p)
      p blocks
end

module InterprocDSE = struct
  (** Dead store elimination based on an interprocedural live var analysis using
      the IDE solver *)

  open Analysis.Ide_live

  let filter_dead prog keep live (block : Program.bloc) : Program.bloc =
    let phis, s =
      Block.fold_backwards
        ~f:(fun (p, acc) s ->
          let omit, new_s =
            match s with
            | Stmt.Instr_Assign a ->
                let a =
                  List.filter (fun (v, e) -> keep v || VarSet.mem v live) a
                in
                (List.is_empty a, Stmt.Instr_Assign a)
            | _ -> (false, s)
          in
          (p, if omit then acc else new_s :: acc)) (* TODO remove dead phis *)
        ~phi:(fun (acc, s) a ->
          ( List.filter_map
              (fun (p : Var.t Block.phi) ->
                Option.return_if (keep p.lhs || VarSet.mem p.lhs live) p)
              a
            @ acc,
            s ))
        ~init:([], []) block
    in
    { phis; stmts = Vector.of_list s }

  let transform_proc prog keep live_param_strs results proc =
    (* Remove dead parameters *)
    let live_params =
      IDMap.get_or (Procedure.id proc) live_param_strs ~default:StringSet.empty
    in
    let proc =
      Procedure.map_formal_in_params
        (StringMap.filter (fun s _ -> StringSet.mem s live_params))
        proc
    in
    (* Remove dead parameters from calls *)
    let blocks = Procedure.blocks_to_list proc in
    let proc =
      List.fold_left
        (fun p b ->
          match b with
          | Procedure.Vert.Begin bid, (b : (Var.t, Expr.BasilExpr.t) Block.t) ->
              let b =
                Block.map ~phi:id
                  (function
                    | Stmt.Instr_Call f ->
                        let live_params =
                          IDMap.get_or f.procid live_param_strs
                            ~default:StringSet.empty
                        in
                        let args =
                          StringMap.filter
                            (fun s _ -> StringSet.mem s live_params)
                            f.args
                        in
                        Stmt.Instr_Call { f with args }
                    | s -> s)
                  b
              in
              Procedure.update_block p bid b
          | _ -> p)
        proc blocks
    in
    (* Remove dead stores. We don't need to use any interprocedural results
       here as all interprocedural results come from input parameters being
       dead, which we have removed. *)
    let live =
      IDMap.find (Procedure.id proc) results
      |> VarMap.to_iter
      |> Iter.filter_map (fun (v, t) -> Option.return_if t v)
      |> VarSet.of_iter
    in
    let blocks = Procedure.blocks_to_list proc in
    let proc =
      List.fold_left
        (fun p b ->
          match b with
          | Procedure.Vert.Begin id, (b : (Var.t, Expr.BasilExpr.t) Block.t) ->
              let block = filter_dead prog keep live b in
              Procedure.update_block p id block
          | _ -> p)
        proc blocks
    in
    proc

  let transform (keep : Var.t -> bool) (p : Program.t) =
    let _, results =
      Trace_core.with_span ~__FILE__ ~__LINE__ "ide live vars" @@ fun _ ->
      IDELiveSSIAnalysis.solve p
    in

    let live_param_strs : StringSet.t IDMap.t =
      IDMap.mapi
        (fun pid proc ->
          let res = IDMap.find pid results in
          Procedure.formal_in_params proc
          |> StringMap.filter (fun _ v -> VarMap.get_or v res ~default:false)
          |> StringMap.keys |> StringSet.of_iter)
        p.procs
    in

    let procs =
      IDMap.map
        (fun proc -> transform_proc p keep live_param_strs results proc)
        p.procs
    in

    { p with procs }
end

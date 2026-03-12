(** Dead code elimination based on intraprocedural live local-variables analysis
*)

open Bincaml_util.Common
open Lang
open Expr
open Types

(** live vars transfer function for a statement *)
let tf_stmt_live init s =
  let assigns = VarSet.diff init (Stmt.assigned VarSet.empty s) in
  Stmt.free_vars assigns s

(** live vars transfer function for a block *)
let tf_block (init : VarSet.t) (b : (Var.t, BasilExpr.t) Block.t) =
  Block.fold_backwards ~f:tf_stmt_live ~phi:(fun f _ -> f) ~init b

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
        match G.E.label e with Block b -> tf_block d b | _ -> d
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
    forall (v1:bv1) :: (eq(v2:bv1,
      forall (v2:bv1) :: (booland(v1:bv1, v2:bv1, v3:bv1))))
    forall (v1:bv1) :: (eq(0x16:bv5,
      forall (v2:bv1) :: (booland(v1:bv1, v2:bv1, 0x16:bv5))))
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
          let live = VarSet.filter Var.is_local @@ tf_stmt_live live s in
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

  let transfer_call prog summaries pid lhs rhs live =
    let open IDELiveAnalysis in
    let summary = summaries pid |> Option.get_or ~default:DlMap.empty in
    let proc = Program.proc prog pid in
    let live =
      DlMap.get_or DL.Lambda summary ~default:DlMap.empty |> fun m ->
      DlMap.fold
        (fun d _ live ->
          match d with Lambda -> live | Label v -> VarSet.add v live)
        m live
    in
    StringMap.fold
      (fun s v live ->
        if VarSet.mem v live then
          let live = VarSet.remove v live in
          match StringMap.get s (Procedure.formal_out_params proc) with
          | Some formal_out ->
              let live = VarSet.remove v live in
              DlMap.get_or (Label formal_out) summary ~default:DlMap.empty
              |> fun m ->
              DlMap.fold
                (fun k _ live ->
                  let formal_in =
                    Procedure.formal_in_params proc
                    |> StringMap.bindings
                    |> List.find_opt (fun (s, v') -> DL.equal (Label v) k)
                  in
                  match formal_in with
                  | Some (s, formal_in) ->
                      StringMap.get s rhs
                      |> Option.map (fun e ->
                          VarSet.union live (BasilExpr.free_vars e))
                      |> Option.get_or ~default:live
                  | None -> live)
                m live
          | None -> live
        else live)
      lhs live

  let transfer_stmt s live = tf_stmt_live live s

  let filter_dead prog keep summaries live (block : Program.bloc) =
    Block.fold_backwards
      ~f:(fun (live, acc) s ->
        let omit =
          match s with
          | Stmt.Instr_Assign _ ->
              Stmt.iter_lvar s
              |> Iter.for_all (fun v -> not (keep v || VarSet.mem v live))
          | _ -> false
        in
        let live =
          match s with
          | Stmt.Instr_Call { procid; lhs; args } ->
              transfer_call prog summaries procid lhs args live
          | _ -> transfer_stmt s live
        in
        if omit then (live, acc) else (live, s :: acc))
      ~phi:(fun x a -> x)
      ~init:(live, []) block
    |> snd |> Vector.of_list

  let transform_proc prog keep summaries results proc =
    let blocks = Procedure.blocks_to_list proc in
    List.fold_left
      (fun p b ->
        match b with
        | Procedure.Vert.Begin id, (b : (Var.t, Expr.BasilExpr.t) Block.t) ->
            let v = Procedure.Vert.End id in
            let stmts =
              filter_dead prog keep summaries
                (results ~proc_id:(Procedure.id proc) v
                |> Option.map (fun m ->
                    IDELiveAnalysis.DataMap.to_iter m
                    |> Iter.filter_map (fun (v, x) ->
                        if x then Some v else None)
                    |> VarSet.of_iter)
                |> Option.get_or ~default:VarSet.empty)
                b
            in
            Procedure.update_block p id { b with stmts }
        | _ -> p)
      proc blocks

  let transform (keep : Var.t -> bool) (p : Program.t) =
    let summaries, results =
      Trace_core.with_span ~__FILE__ ~__LINE__ "ide live vars" @@ fun _ ->
      IDELiveAnalysis.solve p
    in

    let procs =
      ID.Map.map
        (fun proc -> transform_proc p keep summaries results proc)
        p.procs
    in

    { p with procs }
end

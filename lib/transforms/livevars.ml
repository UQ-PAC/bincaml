open Containers
open Lang
open Expr
open Types
module V = Set.Make (Var)
module B = Map.Make (Var)

let show_v b =
  let open Containers_pp in
  let open Containers_pp.Infix in
  let x =
    fill
      (text "," ^ newline)
      (V.to_list b |> List.map (fun v -> Containers_pp.text (Var.name v)))
  in
  Pretty.to_string ~width:80 x

let assigned_stmt (init : V.t) s : V.t =
  let f_lvar a v = V.add v a in
  Stmt.iter_lvar s |> Iter.fold f_lvar init

let free_vars_stmt (init : V.t) (s : (Var.t, Var.t, BasilExpr.t) Stmt.t) : V.t =
  let f_expr a v = V.union (BasilExpr.free_vars v) a in
  Stmt.iter_rexpr s |> Iter.fold f_expr init

let tf_stmt_live init s =
  let assigns = V.diff init (assigned_stmt V.empty s) in
  free_vars_stmt assigns s

let tf_block (init : V.t) (b : (Var.t, BasilExpr.t) Block.t) =
  Block.fold_backwards ~f:tf_stmt_live ~phi:(fun f _ -> f) ~init b

module G = Procedure.G

module WTO = Graph.WeakTopological.Make (struct
  open G

  type t = G.t

  module V = G.V

  let iter_succ = G.iter_pred
  let iter_vertex = G.iter_vertex
end)

module LV =
  Graph.ChaoticIteration.Make
    (G)
    (struct
      type vertex = G.E.vertex
      type edge = G.E.t
      type g = G.t
      type t = V.t

      let equal = V.equal
      let join = V.union
      let widening a b = V.union a b

      let analyze (e : edge) d =
        match G.E.label e with Block b -> tf_block d b | _ -> d
    end)

let run (p : Program.proc) =
  let wto =
    Trace.with_span ~__FILE__ ~__LINE__ "WTO" @@ fun _ ->
    WTO.recursive_scc (Procedure.graph p) Procedure.Vert.Return
  in
  let r =
    Trace.with_span ~__FILE__ ~__LINE__ "live-vars-analysis" @@ fun _ ->
    LV.recurse (Procedure.graph p) wto
      (fun v -> V.empty)
      (Graph.ChaoticIteration.Predicate (fun _ -> false))
      10
  in
  fun v -> Option.get_or ~default:V.empty (LV.M.find_opt v r)

let label (r : G.vertex -> V.t) (v : G.vertex) = show_v (r v)
let print_g res = Viscfg.dot_labels (fun v -> Some (label res v))

let print_live_vars_dot fmt p =
  let r = run p in
  Trace.with_span ~__FILE__ ~__LINE__ "dot-priner" @@ fun _ ->
  let (module M : Viscfg.ProcPrinter) =
    Viscfg.dot_labels (fun v -> Some (label r v))
  in
  M.fprint_graph fmt (Procedure.graph p)

let%expect_test _ =
  let open BasilExpr in
  let v1 = Var.create "v1" (Types.bv 0x1) in
  let v2 = Var.create "v2" (Types.bv 0x1) in
  let v3 = Var.create "v3" (Types.bv 0x1) in

  let e1 =
    BasilExpr.forall
      ~bound:[ rvar v2 ]
      (applyintrin ~op:`AND [ rvar v1; rvar v2; rvar v3 ])
  in
  let exp = BasilExpr.forall ~bound:[ rvar v1 ] (binexp ~op:`EQ (rvar v2) e1) in
  print_endline (to_string exp);
  let sub v = Some (bvconst (Value.PrimQFBV.of_int ~size:5 150)) in
  let e2 = BasilExpr.substitute sub exp in
  print_endline (to_string e2);
  [%expect
    {|
    forall(v1:bv1 :: eq(v2:bv1, forall(v2:bv1 :: booland(v1:bv1, v2:bv1, v3:bv1))))
    forall(v1:bv1 :: eq(0x16:bv5, forall(v2:bv1 :: booland(v1:bv1, v2:bv1, 0x16:bv5)))) |}]

module Interproc = struct
  type value = { proc_summary : V.t ID.Map.t; lives : V.t }

  (** fairly inefficient inter-procedural live-variables analysis; takes 7s on
      cntlm early IR.

      Solves over the call-graph and re-solves each procedure
      (intra-procedurally) every time a dependency is changed.

      Passes the summary through the abstract domain of the intra-procedural
      solve so that the transfer function can inspect it to handle calls. This
      is pretty janky, I would like a better solution. *)

  let free_vars_stmt summary (init : V.t)
      (s : (Var.t, Var.t, BasilExpr.t) Stmt.t) : V.t =
    let f_expr a v = V.union (BasilExpr.free_vars v) a in
    let filter_glob =
      V.filter (function (v : Var.t) ->
          Var.equal_declaration_scope (Var.scope v) Global)
    in
    let free = Stmt.iter_rexpr s |> Iter.fold f_expr init |> filter_glob in
    let open Iter.Infix in
    match s with
    | Stmt.(Instr_Call { procid }) -> (
        ID.Map.get procid summary |> function
        | None -> free
        | Some es ->
            let globs = filter_glob es in
            V.union free globs)
    | _ -> free

  let tf_block summary (init : V.t) (b : (Var.t, BasilExpr.t) Block.t) =
    let tf_stmt init s =
      let assigns = V.diff init (assigned_stmt V.empty s) in
      free_vars_stmt summary assigns s
    in
    Block.fold_backwards ~f:tf_stmt ~phi:(fun f _ -> f) ~init b

  let tf_block (st : value) b =
    let lives = tf_block st.proc_summary st.lives b in
    { st with lives }

  let join a b = V.union a.lives b.lives

  module ILV =
    Graph.Fixpoint.Make
      (G)
      (struct
        type vertex = G.E.vertex
        type edge = G.E.t
        type g = G.t
        type data = value

        let direction = Graph.Fixpoint.Backward
        let equal a b = V.equal a.lives b.lives

        let join (a : data) (b : data) =
          { a with lives = V.union a.lives b.lives }

        let analyze (e : edge) d : data =
          match G.E.label e with Block b -> tf_block d b | _ -> d
      end)

  let tf_proc (prog : Program.t) proc_summary (pid : ID.t) =
    Trace.with_span ~__FILE__ ~__LINE__ "liveness-solve-proc" @@ fun _ ->
    let proc = ID.Map.find pid prog.procs in
    let res =
      ILV.analyze
        (function e -> { proc_summary; lives = V.empty })
        (Procedure.graph proc)
    in
    let entry = res Procedure.Vert.Entry in
    let n = ID.Map.add pid entry.lives proc_summary in
    n

  module CG = Program.CallGraph.G

  module type InterLVAnalysis = sig
    val analyze :
      (CG.vertex -> V.t ID.Map.t) -> CG.t -> CG.vertex -> V.t ID.Map.t
  end

  module InterprocLV (Prog : sig
    val prog : Program.t
  end) =
    Graph.Fixpoint.Make
      (CG)
      (struct
        type vertex = CG.E.vertex
        type edge = CG.E.t
        type g = CG.t
        type data = V.t ID.Map.t [@@deriving eq]

        let direction = Graph.Fixpoint.Backward
        let equal = equal_data

        let join (a : data) (b : data) : data =
          ID.Map.union (fun id a b -> Some (V.union a b)) a b

        let analyze (e : edge) d : data =
          match CG.E.label e with Proc id -> tf_proc Prog.prog d id | _ -> d
      end)

  let analyse_prog p =
    let open Program in
    let default = ID.Map.map (fun _ -> V.empty) p.procs in
    let callgraph = Program.CallGraph.make_call_graph p in
    let module M : InterLVAnalysis = InterprocLV (struct
      let prog = p
    end) in
    Trace.with_span ~__FILE__ ~__LINE__ "liveness-solve-callgraph" @@ fun _ ->
    M.analyze (fun v -> default) callgraph
end

module DSE = struct
  let filter_dead (live : V.t) (b : (Var.t, BasilExpr.t) Block.t) =
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
                   Var.is_local v && (not @@ V.mem v live))
          in
          let live = V.filter Var.is_local @@ tf_stmt_live live s in
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
        | ( (Procedure.Vert.Begin id as v),
            (b : (Var.t, Expr.BasilExpr.t) Block.t) ) ->
            let stmts = filter_dead (live v) b in
            Procedure.update_block p id { b with stmts }
        | _ -> p)
      p blocks
end

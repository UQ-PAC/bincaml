(** Interprocedural linear expression constant propagation.

    Performs constant propagation for assignments of the form y := a * x + b;
    where a and b are constants. *)

open Lang
open Common
open Idessi
open Lattice_types

module LF = struct
  let direction = `Forwards

  module Value = FlatLattice (struct
    (* TODO maybe (terrifying possibilty) we could support multiple types ?!?!?!?! *)
    type t = Bitvec.t [@@deriving eq, ord, show { with_path = false }]

    let name = "Bitvec"
  end)

  module DL = struct
    type t = Lambda | Label of Var.t
    [@@deriving eq, ord, show { with_path = false }]

    let show = function Lambda -> "L" | Label v -> Var.name v
  end

  type t =
    (* \x . Bottom *)
    | BotEdge
    (* \x . x *)
    | IdEdge
    (* \x . Top *)
    | TopEdge
    (* Linear (a, b) = \x. a * x + b *)
    | Linear of Bitvec.t * Bitvec.t
    (* Join (a, b, c) = \x. (a * x + b) join c *)
    | Join of Bitvec.t * Bitvec.t * Value.t
  [@@deriving eq, ord]

  let show e =
    let open Bincaml_util.Unicode in
    match e with
    | BotEdge -> bot_char
    | IdEdge -> "Id"
    | TopEdge -> top_char
    | Linear (a, b) -> "\\x . " ^ Bitvec.show a ^ " * x + " ^ Bitvec.show b
    | Join (a, b, c) ->
        "\\x . (" ^ Bitvec.show a ^ " * x + " ^ Bitvec.show b ^ ") " ^ join_char
        ^ " " ^ Value.show c

  let bottom = BotEdge
  let identity = IdEdge
  let top = TopEdge

  (* This is the worst thing ever *)

  let is_id a b =
    Z.equal (Bitvec.value a) Z.one && Z.equal (Bitvec.value b) Z.zero

  let compute_join a b c d =
    let bd = Bitvec.value (Bitvec.sub b d) in
    let g, s, t = Z.gcdext (Bitvec.value (Bitvec.sub c a)) bd in
    if Z.divisible g bd then
      let l0 = Bitvec.create ~size:(Bitvec.size a) (Z.mul s bd) in
      let j = Bitvec.add (Bitvec.mul a l0) b in
      Some (Value.V j)
    else None

  let compute_join_id a b =
    let bd = Bitvec.value b in
    let g, s, t = Z.gcdext (Z.sub Z.one (Bitvec.value a)) bd in
    if Z.divisible g bd then
      let l0 = Bitvec.create ~size:(Bitvec.size a) (Z.mul s bd) in
      let j = Bitvec.add (Bitvec.mul a l0) b in
      Some (Value.V j)
    else None

  (* Should make join edges with top become TopEdges (and probably similar for effectively id Linear and Join edges...) *)
  let join a b =
    match (a, b) with
    | BotEdge, b -> b
    | a, BotEdge -> a
    | TopEdge, _ -> TopEdge
    | _, TopEdge -> TopEdge
    | Join (a, b, c), Join (d, e, f) when Bitvec.equal a d && Bitvec.equal b e
      ->
        Join (a, b, Value.join c f)
    | Linear (a, b), Linear (c, d) when Bitvec.equal a c && Bitvec.equal b d ->
        Linear (a, b)
    | IdEdge, IdEdge -> IdEdge
    | IdEdge, Linear (a, b) when is_id a b -> IdEdge
    | Linear (a, b), IdEdge when is_id a b -> IdEdge
    | IdEdge, Join (a, b, c) when is_id a b -> Join (a, b, c)
    | Join (a, b, c), IdEdge when is_id a b -> Join (a, b, c)
    | Linear (a, b), Linear (c, d) -> (
        match compute_join a b c d with
        | Some j -> Join (a, b, j)
        | None -> TopEdge)
    | Linear (a, b), Join (c, d, e) -> (
        match compute_join a b c d with
        | Some j -> Join (a, b, Value.join j e)
        | None -> TopEdge)
    | Join (a, b, c), Linear (d, e) -> (
        match compute_join a b d e with
        | Some j -> Join (a, b, Value.join j c)
        | None -> TopEdge)
    | Join (a, b, c), Join (d, e, f) -> (
        match compute_join a b d e with
        | Some j -> Join (a, b, Value.join j (Value.join c f))
        | None -> TopEdge)
    | IdEdge, Linear (a, b) -> (
        match compute_join_id a b with
        | Some j -> Join (a, b, j)
        | None -> TopEdge)
    | Linear (a, b), IdEdge -> (
        match compute_join_id a b with
        | Some j -> Join (a, b, j)
        | None -> TopEdge)
    | IdEdge, Join (a, b, c) -> (
        match compute_join_id a b with
        | Some j -> Join (a, b, Value.join j c)
        | None -> TopEdge)
    | Join (a, b, c), IdEdge -> (
        match compute_join_id a b with
        | Some j -> Join (a, b, Value.join j c)
        | None -> TopEdge)

  let compose a b =
    match (a, b) with
    | IdEdge, b -> b
    | a, IdEdge -> a
    | BotEdge, _ -> BotEdge
    | TopEdge, _ -> TopEdge
    | _, BotEdge -> BotEdge
    | _, TopEdge -> TopEdge
    | Linear (a, b), Linear (c, d) ->
        Linear (Bitvec.mul a c, Bitvec.add (Bitvec.mul a d) b)
    | Join (a, b, c), Linear (d, e) ->
        Join (Bitvec.mul a d, Bitvec.add (Bitvec.mul a e) b, c)
    | Linear (a, b), Join (c, d, V e) ->
        Join
          ( Bitvec.mul a c,
            Bitvec.add (Bitvec.mul a d) b,
            V (Bitvec.add (Bitvec.mul a e) b) )
    | Linear (a, b), Join (c, d, Top) -> TopEdge
    | Linear (a, b), Join (c, d, Bot) ->
        Linear (Bitvec.mul a c, Bitvec.add (Bitvec.mul a d) b)
    | Join (a, b, c), Join (d, e, V f) ->
        Join
          ( Bitvec.mul a d,
            Bitvec.add (Bitvec.mul a e) b,
            Value.join (V (Bitvec.add (Bitvec.mul a f) b)) c )
    | Join (a, b, c), Join (d, e, Top) ->
        Join (Bitvec.mul a d, Bitvec.add (Bitvec.mul a e) b, Top)
    | Join (a, b, c), Join (d, e, Bot) ->
        Join (Bitvec.mul a d, Bitvec.add (Bitvec.mul a e) b, c)

  let eval x f =
    match (f, x) with
    | BotEdge, _ -> Value.Bot
    | IdEdge, x -> x
    | TopEdge, _ -> Top
    | Linear (a, b), _ when Z.equal Z.zero (Bitvec.value a) -> V b
    | Join (a, b, _), _ when Z.equal Z.zero (Bitvec.value a) -> V b
    | Linear (a, b), Value.V x -> V (Bitvec.add (Bitvec.mul a x) b)
    | Linear _, Bot -> Bot
    | Linear _, Top -> Top
    | Join (a, b, c), V x -> Value.join (V (Bitvec.add (Bitvec.mul a x) b)) c
    | Join _, Bot -> Bot
    | Join _, Top -> Top

  let const_expr e =
    let open Expr.AbstractExpr in
    let open Expr.BasilExpr in
    match e with E (Constant { const = `Bitvector x }) -> Some x | _ -> None

  module Extract = struct
    open Option

    let liftA2 f a b =
      let* a = a in
      let* b = b in
      pure @@ f a b

    let liftJoin2 f a b =
      let* a = a in
      let* b = b in
      f a b

    module Lin = struct
      type t = Bitvec.t option * Var.t option * Bitvec.t

      let var v =
        match Var.typ v with
        | Bitvector size ->
            Some (Some (Bitvec.one ~size), Some v, Bitvec.zero ~size)
        | _ -> None

      let const x = (None, None, x)

      let add a b =
        match (a, b) with
        | (a, v, b), (None, None, c) | (None, None, b), (a, v, c) ->
            Some (a, v, Bitvec.add b c)
        | (Some a, Some v, b), (Some c, Some v', d) when Var.equal v v' ->
            Some (Some (Bitvec.add a c), Some v, Bitvec.add b d)
        | _ -> None

      let mul a b =
        match (a, b) with
        | (None, None, b), (None, None, d) -> Some (None, None, Bitvec.mul b d)
        | (Some a, Some v, b), (None, None, d)
        | (None, None, d), (Some a, Some v, b) ->
            Some (Some (Bitvec.mul a d), Some v, Bitvec.mul b d)
        | _ -> None
    end

    let extract_alg e =
      let open Expr.AbstractExpr in
      match e with
      | RVar { id } -> Lin.var id
      | Constant { const = `Bitvector c } -> Some (Lin.const c)
      | ApplyIntrin { op = `BVADD; args = a :: rest } ->
          List.fold_left (liftJoin2 Lin.add) a rest
      | ApplyIntrin { op = `BVMUL; args = a :: rest } ->
          List.fold_left (liftJoin2 Lin.mul) a rest
      | _ -> None

    let extract_expr e =
      match Expr.BasilExpr.cata extract_alg e with
      | Some (Some a, Some v, b)
        when Z.equal Z.one (Bitvec.value a) && Z.equal Z.zero (Bitvec.value b)
        ->
          (IdEdge, Some v)
      | Some (Some a, Some v, b) -> (Linear (a, b), Some v)
      | _ -> (TopEdge, None)
  end
end

module LinearDomain = struct
  include LF

  type state_update = (DL.t * t) Iter.t

  let init_data (proc : Program.proc) =
    Procedure.formal_in_params proc |> StringMap.values

  open DL

  let transfer_call call param d =
    match d with
    | Lambda -> Iter.singleton (Lambda, IdEdge)
    | Label v ->
        StringMap.to_iter call
        |> Iter.filter (fun (s, e) -> VarSet.mem v (Expr.BasilExpr.free_vars e))
        |> Iter.map (fun (s, e) ->
            let v' = StringMap.find s param in
            (Label v', fst @@ Extract.extract_expr e))

  let transfer stmt d =
    let open Stmt in
    match d with
    | Lambda -> (
        match stmt with
        | Instr_Assign a ->
            Iter.of_list a
            |> Iter.flat_map (fun (v, e) ->
                match const_expr e with
                | Some x ->
                    Iter.singleton
                      (Label v, Linear (Bitvec.zero ~size:(Bitvec.size x), x))
                | None -> Iter.empty)
        | _ -> Iter.empty)
    | Label v -> (
        match stmt with
        | Instr_Assign a ->
            Iter.of_list a
            |> Iter.filter (fun (s, e) ->
                VarSet.mem v (Expr.BasilExpr.free_vars e))
            |> Iter.map (fun (v', e) ->
                (Label v', fst @@ Extract.extract_expr e))
        | _ -> Iter.empty)

  (* RHS will contain d because ssa *)
  let transfer_phi lhs _ d =
    match d with
    | Lambda -> Iter.empty
    | Label _ -> Iter.singleton (Label lhs, IdEdge)

  let init_p2 (proc : Program.proc) =
    (* TODO could enforce in vars to be const based on requires clause *)
    Procedure.formal_in_params proc
    |> StringMap.values
    |> Iter.map (fun v -> (v, Value.Top))
end

module LinearConstAnalysis = IDESSI (LinearDomain)

(* This is just the copyprop copy pasted... hopefully we can just remove the
   normal copyprop eventually (currently this analysis is not a superset of
   copy prop, probably due to some imprecision) *)

module CopyNode = struct
  type content = {
    (* The variable this node represents *)
    v : Var.t;
    (* The variables this variable is copied from, through a phi. This field
       should only be read on parent nodes, in which case the list has either
       no elements or >=2 elements.*)
    copied_from : edge list;
    (* The union find parent node. Parent nodes have this set to None (avoid
       cycles). *)
    parent : edge option;
  }

  and edge = LF.t * t
  and t = content ref

  let var (n : t) = !n.v

  (** Target of an edge *)
  let target : edge -> t = snd

  let ( @. ) = LF.compose
  let init v : t = ref { v; copied_from = []; parent = None }

  (** Get the parent of this node (basically constant time because of path
      compression) *)
  let rec find v : edge =
    match !v.parent with
    | Some (f1, v') ->
        let f2, v'' = find v' in
        let p = (f1 @. f2, v'') in
        (* We can clear the copied_from field whenever setting the parent for
           the garbage collector to gobble on (yum) *)
        v := { v = !v.v; copied_from = []; parent = Some p };
        p
    | None -> (LF.identity, v)

  (** `join v f v'` points `v'` to `v` through f *)
  let join v f v' : unit =
    v' := { !v' with copied_from = []; parent = Some (f, v) }

  let eq (n : t) (m : t) = Var.equal !n.v !m.v

  (** Set out edges of a given vertex (think `v := phi(a, b, c)` defining edges
      `v -> a, v -> b, v -> c`). All cycles are trimmed (think v2 := phi(v1,
      v2)) *)
  let set_copied v copied_from =
    assert (Option.is_none !v.parent);
    let copied_from = List.filter (not % eq v % target) copied_from in
    v := { v = !v.v; copied_from; parent = None }

  (** Returns all reachable leaves from the given node, but aborts if the
      predicate is violated *)
  let leaves (keep : t -> bool) v : edge list option =
    let memo = ref VarMap.empty in
    let rec dfs v =
      let f, v = find v in
      match VarMap.get (var v) !memo with
      | Some l -> Some l
      | None -> (
          memo := VarMap.add (var v) [] !memo;
          match !v.copied_from with
          | [] -> if keep v then Some [ (f, v) ] else None
          | ls ->
              let open List.Traverse (Option) in
              let ans =
                Option.map List.concat
                @@ map_m
                     (fun (f', v') ->
                       dfs v'
                       |> Option.map
                            (List.map (fun (f'', v'') -> (f @. f' @. f'', v''))))
                     ls
              in
              Option.iter (fun a -> memo := VarMap.add (var v) a !memo) ans;
              ans)
    in
    dfs v
end

(** Ocamlgraph representation of the above for debug utilities *)
module CopyGraph = struct
  module Vert = Var

  module Edge = struct
    include LF

    let default = identity
  end

  module G = Graph.Persistent.Digraph.ConcreteBidirectionalLabeled (Vert) (Edge)

  module Dot = Graph.Graphviz.Dot (struct
    include G
    open Vert
    open Edge

    let default_vertex_attributes _ = []
    let graph_attributes _ = []
    let default_edge_attributes _ = []
    let get_subgraph _ = None

    let edge_attributes (_, f, _) =
      match f with
      | IdEdge -> []
      | f ->
          let n = LF.show f in
          [ `Label n ]

    let vertex_attributes v =
      let n = Var.name v in
      [ `Shape `Box; `Fontname "Mono"; `Label n ]

    let vertex_name = String.replace ~sub:"#" ~by:"hash" % Var.name
  end)

  let make_graph nodes =
    Iter.fold
      (fun g (n : CopyNode.t) ->
        match !n.parent with
        | Some (f, n') -> G.add_edge_e g (!n.v, f, !n'.v)
        | None ->
            List.fold_left
              (fun g (f, (n' : CopyNode.t)) -> G.add_edge_e g (!n.v, f, !n'.v))
              g !n.copied_from)
      G.empty nodes
end

type call_info = {
  caller_id : ID.t;
  lhs : Var.t StringMap.t;
  args : Program.e StringMap.t;
}

module Solver = struct
  let add_phi node_of (phi : Var.t Block.phi) =
    let l = node_of phi.lhs in
    let copied = List.map (fun (_, v) -> (LF.identity, node_of v)) phi.rhs in
    CopyNode.set_copied l copied

  let copy_of e =
    let open Expr.AbstractExpr in
    let open Expr.BasilExpr in
    match unfix e with RVar { id } -> Some id | _ -> None

  let add_intra_stmt callers node_of pid component stmt =
    let open Stmt in
    match stmt with
    | Instr_Assign a ->
        List.iter
          (fun (v, e) ->
            match LF.Extract.extract_expr e with
            | f, Some v' ->
                let v, v' = (node_of v, node_of v') in
                (* v := f(v'), draw edge from v to v' with f *)
                CopyNode.join v' f v
            | _, None -> ())
          a
    | Instr_Call c ->
        (* We at the same time create a list of all callers of each procedure in the scc. *)
        if List.mem ~eq:ID.equal c.procid component then
          Hashtbl.update callers
            ~f:(fun _ l ->
              let c = { caller_id = pid; lhs = c.lhs; args = c.args } in
              match l with Some cs -> Some (c :: cs) | None -> Some [ c ])
            ~k:c.procid
    | _ -> ()

  module Worklist = Worklist.Make (ID)

  let solve_component (prog : Program.t) call_graph
      (graphs : (ID.t, CopyNode.t VarMap.t) Hashtbl.t) component =
    let open CopyNode in
    let node_of pid v =
      let vm = Hashtbl.get_or_add graphs ~f:(const VarMap.empty) ~k:pid in
      match VarMap.find_opt v vm with
      | Some n -> n
      | None ->
          let n = init v in
          let vm = VarMap.add v n vm in
          Hashtbl.replace graphs pid vm;
          n
    in
    (* Initialise the graph with all intraprocedural copies *)
    let callers = Hashtbl.create 10 in
    List.iter
      (fun pid ->
        IDMap.find pid prog.procs |> Procedure.iter_blocks
        |> Iter.iter (fun (bid, b) ->
            Block.stmts_iter b
            |> Iter.iter (add_intra_stmt callers (node_of pid) pid component);
            List.iter (add_phi (node_of pid)) b.phis))
      component;
    (* The interproc part *)
    let worklist = Worklist.create () in
    Worklist.add_list worklist component;
    while Worklist.non_empty worklist do
      let pid = Worklist.pop worklist in
      let proc = IDMap.find pid prog.procs in
      Procedure.formal_out_params proc
      |> StringMap.values
      |> Iter.map (node_of pid)
      |> Iter.filter_map (fun node ->
          leaves
            (fun (n : t) ->
              StringMap.mem (Var.name !n.v) (Procedure.formal_in_params proc))
            node
          |> Option.flat_map (fun leaves ->
              (not (List.is_empty leaves))
              |> flip Option.return_if (node, leaves)))
      |> Iter.iter (fun ((node : CopyNode.t), leaves) ->
          Hashtbl.get_or callers pid ~default:[]
          |> List.iter (fun (call : call_info) ->
              let open List.Traverse (Option) in
              leaves
              |> List.map (fun (f, (n : CopyNode.t)) ->
                  (f, StringMap.find (Var.name !n.v) call.args))
              |> map_m (fun (f, e) ->
                  let f', v = LF.Extract.extract_expr e in
                  Option.map (fun v -> (f @. f', v)) v)
              |> Option.iter (fun leaves ->
                  match leaves with
                  | (f, v) :: vs -> (
                      if List.for_all (Var.equal v % snd) vs then
                        let assigned =
                          node_of call.caller_id
                          @@ StringMap.find (Var.name !node.v) call.lhs
                        in
                        match !assigned.parent with
                        | Some _ -> ()
                        | None -> (
                            (* i had so much fun writing this...
                            match List.fold_left (( %> ) fst % LF.join) f vs with
                            but alas it was 81 characters *)
                            match
                              List.fold_left (fun f (g, _) -> LF.join f g) f vs
                            with
                            | TopEdge | BotEdge -> ()
                            | f ->
                                join (node_of call.caller_id v) f assigned;
                                (* We have updated the caller's graph so we
                                   should recompute it *)
                                Worklist.add worklist call.caller_id))
                  | [] -> failwith "leaves should never be empty!")))
    done

  (** Collapse copies through phis into copies *)
  let collapse_composites g =
    let open CopyNode in
    let searched = ref VarSet.empty in
    let findn = snd % find % snd in
    let findf = fst % find in
    let rec search (node : t) =
      if not @@ VarSet.mem !node.v !searched then (
        searched := VarSet.add !node.v !searched;
        let copied_from = !node.copied_from in
        match copied_from with
        | (f, n) :: ls -> (
            List.iter (search % findn) ((f, n) :: ls);
            let f', p = find n in
            let f = f' @. f in
            if List.for_all (Var.equal !p.v % var % findn) ls then
              match
                List.fold_left (fun f (g, p) -> LF.join f (g @. findf p)) f ls
              with
              | TopEdge | BotEdge -> ()
              | f -> join p f node)
        | _ -> ())
    in
    VarMap.iter (const (search % snd % find)) g

  let solve (prog : Program.t) =
    let graphs : (ID.t, CopyNode.t VarMap.t) Hashtbl.t = Hashtbl.create 100 in
    let call_graph = Program.CallGraph.make_call_graph prog in
    Program.CallGraph.Scc.scc_list call_graph
    |> List.map
         (List.filter_map (function
           | Program.CallGraph.Vert.ProcBegin id -> Some id
           | _ -> None))
    |> List.iter (solve_component prog call_graph graphs);
    Hashtbl.iter (const collapse_composites) graphs;
    graphs
end

let test_transform (p : Program.t) =
  let gs = Solver.solve p in
  Hashtbl.iter
    (fun pid g ->
      print_endline @@ "Graphvis for " ^ ID.show pid ^ ":";
      let g = CopyGraph.make_graph (VarMap.values g) in
      CopyGraph.Dot.output_graph stdout g)
    gs;
  p

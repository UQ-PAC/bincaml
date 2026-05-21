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

  let is_id_coeff a b =
    Z.equal Z.one (Bitvec.value a) && Z.equal Z.zero (Bitvec.value b)

  let canonical = function
    | Linear (a, b) when is_id_coeff a b -> false
    (* In theory we could not have Join represent Bot or Top values but that means we can't call join *)
    | Join (_, _, Value.(Bot | Top)) -> false
    (* Join of two constants shouldn't be represented, as it would either be Top or just a linear function *)
    | Join (a, _, _) when Z.equal Z.zero (Bitvec.value a) -> false
    | _ -> true

  let is_id f =
    assert (canonical f);
    match f with IdEdge -> true | _ -> false

  (* Definitions from https://doi.org/10.1016/0304-3975(96)00072-2 with gcdext modifications coming from computing inverses mod 2^n *)

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

  let make_linear a b = if is_id_coeff a b then IdEdge else Linear (a, b)

  let make_join a b c =
    match c with
    | Value.Top -> TopEdge
    | Bot -> make_linear a b
    | _ -> Join (a, b, c)

  (* Should make join edges with top become TopEdges (and probably similar for effectively id Linear and Join edges...) *)
  let join a b =
    assert (canonical a && canonical b);
    match (a, b) with
    | BotEdge, b -> b
    | a, BotEdge -> a
    | TopEdge, _ -> TopEdge
    | _, TopEdge -> TopEdge
    | Join (a, b, c), Join (d, e, f) when Bitvec.equal a d && Bitvec.equal b e
      ->
        make_join a b (Value.join c f)
    | Linear (a, b), Linear (c, d) when Bitvec.equal a c && Bitvec.equal b d ->
        make_linear a b
    | IdEdge, IdEdge -> IdEdge
    | IdEdge, Join (a, b, c) when is_id_coeff a b -> make_join a b c
    | Join (a, b, c), IdEdge when is_id_coeff a b -> make_join a b c
    | Linear (a, b), Linear (c, d) -> (
        match compute_join a b c d with
        | Some j -> make_join a b j
        | None -> TopEdge)
    | Linear (a, b), Join (c, d, e) -> (
        match compute_join a b c d with
        | Some j -> make_join a b (Value.join j e)
        | None -> TopEdge)
    | Join (a, b, c), Linear (d, e) -> (
        match compute_join a b d e with
        | Some j -> make_join a b (Value.join j c)
        | None -> TopEdge)
    | Join (a, b, c), Join (d, e, f) -> (
        match compute_join a b d e with
        | Some j -> make_join a b (Value.join j (Value.join c f))
        | None -> TopEdge)
    | IdEdge, Linear (a, b) -> (
        match compute_join_id a b with
        | Some j -> make_join a b j
        | None -> TopEdge)
    | Linear (a, b), IdEdge -> (
        match compute_join_id a b with
        | Some j -> make_join a b j
        | None -> TopEdge)
    | IdEdge, Join (a, b, c) -> (
        match compute_join_id a b with
        | Some j -> make_join a b (Value.join j c)
        | None -> TopEdge)
    | Join (a, b, c), IdEdge -> (
        match compute_join_id a b with
        | Some j -> make_join a b (Value.join j c)
        | None -> TopEdge)

  let compose a b =
    assert (canonical a && canonical b);
    match (a, b) with
    | IdEdge, b -> b
    | a, IdEdge -> a
    | BotEdge, _ -> BotEdge
    | TopEdge, _ -> TopEdge
    | _, BotEdge -> BotEdge
    | _, TopEdge -> TopEdge
    | Linear (a, b), Linear (c, d) ->
        make_linear (Bitvec.mul a c) (Bitvec.add (Bitvec.mul a d) b)
    | Join (a, b, c), Linear (d, e) ->
        make_join (Bitvec.mul a d) (Bitvec.add (Bitvec.mul a e) b) c
    | Linear (a, b), Join (c, d, V e) ->
        make_join (Bitvec.mul a c)
          (Bitvec.add (Bitvec.mul a d) b)
          (V (Bitvec.add (Bitvec.mul a e) b))
    | Linear (a, b), Join (c, d, Top) -> TopEdge
    | Linear (a, b), Join (c, d, Bot) ->
        make_linear (Bitvec.mul a c) (Bitvec.add (Bitvec.mul a d) b)
    | Join (a, b, c), Join (d, e, V f) ->
        make_join (Bitvec.mul a d)
          (Bitvec.add (Bitvec.mul a e) b)
          (Value.join (V (Bitvec.add (Bitvec.mul a f) b)) c)
    | Join (a, b, c), Join (d, e, Top) ->
        make_join (Bitvec.mul a d) (Bitvec.add (Bitvec.mul a e) b) Top
    | Join (a, b, c), Join (d, e, Bot) ->
        make_join (Bitvec.mul a d) (Bitvec.add (Bitvec.mul a e) b) c

  let eval x f =
    assert (canonical f);
    match (f, x) with
    | BotEdge, _ -> Value.Bot
    | IdEdge, x -> x
    | TopEdge, _ -> Top
    | Linear (a, b), _ when Z.equal Z.zero (Bitvec.value a) -> V b
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
      let neg (a, v, c) = (Option.map Bitvec.neg a, v, Bitvec.neg c)

      let add a b =
        match (a, b) with
        | (a, v, b), (None, None, c) | (None, None, b), (a, v, c) ->
            Some (a, v, Bitvec.add b c)
        | (Some a, Some v, b), (Some c, Some v', d) when Var.equal v v' ->
            Some (Some (Bitvec.add a c), Some v, Bitvec.add b d)
        | _ -> None

      let sub a b = add a (neg b)

      (* ~a = -a - 1 *)
      let not (a, v, c) =
        ( Option.map Bitvec.neg a,
          v,
          Bitvec.sub (Bitvec.neg c) (Bitvec.one ~size:(Bitvec.size c)) )

      let mul a b =
        match (a, b) with
        | (None, None, b), (None, None, d) -> Some (None, None, Bitvec.mul b d)
        | (Some a, Some v, b), (None, None, d)
        | (None, None, d), (Some a, Some v, b) ->
            Some (Some (Bitvec.mul a d), Some v, Bitvec.mul b d)
        | _ -> None

      let shl a b =
        match b with
        | None, None, b ->
            mul a (None, None, Bitvec.shl (Bitvec.one ~size:(Bitvec.size b)) b)
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
      | BinaryExpr { op = `BVSUB; arg1 = a; arg2 = b } -> liftJoin2 Lin.sub a b
      | BinaryExpr { op = `BVSHL; arg1 = a; arg2 = b } -> liftJoin2 Lin.shl a b
      | UnaryExpr { op = `BVNEG; arg } -> Option.map Lin.neg arg
      | UnaryExpr { op = `BVNOT; arg } -> Option.map Lin.not arg
      | _ -> None

    let copy_of e =
      let open Expr.AbstractExpr in
      let open Expr.BasilExpr in
      match unfix e with RVar { id } -> Some id | _ -> None

    let extract_expr e =
      match copy_of e with
      | Some v -> (IdEdge, Some v)
      | _ -> (
          match Expr.BasilExpr.cata extract_alg e with
          | Some (Some a, Some v, b) -> (make_linear a b, Some v)
          | _ -> (TopEdge, None))
  end
end

module LinearIDE = struct
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
        | Instr_Assign { al } ->
            Iter.of_list al
            |> Iter.flat_map (fun (v, e) ->
                match const_expr e with
                | Some x ->
                    Iter.singleton
                      ( Label v,
                        make_linear (Bitvec.zero ~size:(Bitvec.size x)) x )
                | None -> Iter.empty)
        | _ -> Iter.empty)
    | Label v -> (
        match stmt with
        | Instr_Assign { al } ->
            Iter.of_list al
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

module LinearConstAnalysis = IDESSI (LinearIDE)

(* For each linear assign and phi node, we create edges from the lhs to all
   copied-from variables. For assignments we associate a function encoding the
   linear expression. The function should be thought of pointing opposite to
   the direction of the edge, so we compose functions backwards (opposite
   category). We perform path compression (with composition) on linear paths of
   this graph to get a partial intraprocedural copy propagation analysis!
   However with just this, we miss out on propagation through phi nodes, where
   every variable in a phi is a function, and the same function, from the same
   source. To fix this, we recursively check whether the copied-from (parent)
   variables and functions for all successor vertices are all equal, and if so
   we create a path from the parent of these successors. (This is probably hard
   to follow with words, so here is an example:
   ```
   if ( * ) { x1 = a + 1 } else { x2 = a + 1 } x3 = phi(x1, x2)
   ```
   in this hypothetical program, x3 points to x1 and x2, which both point to a
   with (+1), so we can update x3 to point to a with (+1). This gives an
   analysis that works through phi nodes!

   To make it interprocedural, we perform a some small iteration steps. For
   each output variable of each procedure, we see whether it is a function of
   only input variables, by doing an all-path-tracking dfs on the path
   compressed graph. If this is the case, we go to every caller of this
   procedure, and see whether all input variables that map into the output
   variable are linear expressions such that their composite functions are all
   equal. (Example:
   ```
   proc f(x) = { return g(x + 1, x) }
   proc g(x, y) = { if ( * ) { z1 = x - 1 } else { z2 = y } return phi(z1, x2) }
   ```
   here the return value of g is the same from the call of f! Hence f's output
   is a function of x. In this case, we can create an edge from the output
   variable in the caller graph to the input variable that copies into it. If
   this ever actually happens, we'll want to re-iterate on this procedure as we
   may have new edges to propagate to other procedures. *)

module CopyNode = struct
  type content = {
    (* The variable this node represents *)
    v : Var.t;
    (* The variables this variable is copied from, through a phi. This field
       should only be read on parent nodes, in which case the list has either
       no elements or >=2 elements. Note that phis are always copies, so we
       don't need to store a function per edge *)
    copied_from : t list;
    (* The union find parent node. Parent nodes have this set to None (avoid
       cycles). *)
    parent : edge option;
    copy_parent : t option;
  }

  and edge = LF.t * t
  and t = content ref

  let var (n : t) = !n.v

  (** Target of an edge *)
  let target : edge -> t = snd

  let ( @. ) = LF.compose

  let init v : t =
    ref { v; copied_from = []; parent = None; copy_parent = None }

  (** Get the parent of this node (basically constant time because of path
      compression) *)
  let rec find v : edge =
    match !v.parent with
    | Some (f1, v') ->
        let f2, v'' = find v' in
        let f = f1 @. f2 in
        let p = (f, v'') in
        v := { !v with parent = Some p };
        p
    | None -> (LF.identity, v)

  (** Get the copy parent of a node with path compression *)
  let rec find_copy v : t =
    match !v.copy_parent with
    | Some v' ->
        let p = find_copy v' in
        v := { !v with copy_parent = Some p };
        p
    | None -> v

  (** Get the parent of this edge, with functions composed *)
  let finde ((f1, n) : edge) : edge =
    let f2, n' = find n in
    (f1 @. f2, n')

  (** `join v f v'` points `v'` to `v` through f *)
  let join v f v' : unit =
    assert (Option.is_none !v'.parent);
    let copy_parent = if LF.is_id f then Some v else None in
    v' := { !v' with parent = Some (f, v); copy_parent }

  (** `join_copy v v'` points `v'` to `v` in the copy graph *)
  let join_copy v v' : unit =
    assert (Option.is_none !v'.copy_parent);
    v' := { !v' with copy_parent = Some v }

  let eq (n : t) (m : t) = Var.equal !n.v !m.v

  (** Set out edges of a given vertex (think `v := phi(a, b, c)` defining edges
      `v -> a, v -> b, v -> c`). All cycles are trimmed (think v2 := phi(v1,
      v2)) *)
  let set_copied v copied_from =
    assert (Option.is_none !v.parent);
    assert (Option.is_none !v.copy_parent);
    let copied_from = List.filter (not % eq v) copied_from in
    v := { !v with copied_from; parent = None; copy_parent = None }

  (** Returns all reachable leaves from the given node, but aborts if the
      predicate is violated or if a top edge cycle is found *)
  let leaves (keep : t -> bool) v : edge list option =
    let memo = ref VarMap.empty in
    (* Determines whether all cycles through the node `root` are copy cycles *)
    let is_id_cycle root =
      let searching = ref VarSet.empty in
      let searched = ref VarSet.empty in
      let rec dfs f n =
        if VarSet.mem (var n) !searched then true
        else if VarSet.mem (var n) !searching then LF.is_id f
        else
          match !n.copied_from with
          | [] -> true
          | ls ->
              searching := VarSet.add (var n) !searching;
              let ans =
                List.for_all
                  (fun n' ->
                    let f', n' = finde (f, n) in
                    match VarMap.get (var n') !memo with
                    | Some None -> if eq root n' then LF.is_id f' else dfs f' n'
                    | _ -> true)
                  ls
              in
              searched := VarSet.add (var n) !searched;
              ans
      in
      dfs LF.identity root
    in
    let rec dfs v f =
      let f, v = finde (f, v) in
      match VarMap.get (var v) !memo with
      | Some (Some l) -> Some l
      (* If there's a cycle, ignore it if the composite of the cycle is id and
         abort otherwise *)
      | Some None when is_id_cycle v -> Some VarMap.empty
      | Some None ->
          print_endline @@ Var.name !v.v;
          None
      | None -> (
          match !v.copied_from with
          | [] -> if keep v then Some (VarMap.singleton !v.v (f, v)) else None
          | l :: ls ->
              memo := VarMap.add (var v) None !memo;
              let open Option.Infix in
              let ans : _ option =
                List.fold_left
                  (fun acc l ->
                    let* acc = acc in
                    let* b = dfs l f in
                    Some
                      (VarMap.fold
                         (fun v (f, n) acc ->
                           match VarMap.get v acc with
                           | Some (f', n') -> VarMap.add v (LF.join f f', n) acc
                           | None -> VarMap.add v (f, n) acc)
                         b acc))
                  (dfs l f) ls
              in
              Option.iter
                (fun a -> memo := VarMap.add (var v) (Some a) !memo)
                ans;
              ans)
    in
    dfs v LF.identity |> Option.map (VarMap.values %> Iter.to_list)
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
              (fun g (n' : CopyNode.t) ->
                G.add_edge_e g (!n.v, LF.identity, !n'.v))
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
    let copied = List.map (fun (_, v) -> node_of v) phi.rhs in
    CopyNode.set_copied l copied

  let propagate_call node_of update_worklist s c ls =
    let open CopyNode in
    let open List.Traverse (Option) in
    ls
    |> List.map (fun (f, (n : CopyNode.t)) ->
        (f, StringMap.find (Var.name !n.v) c.args))
    |> map_m (fun (f, e) ->
        let f', v = LF.Extract.extract_expr e in
        Option.map (fun v -> (f @. f', v)) v)
    |> Option.iter (fun leaves ->
        match leaves with
        | (f, v) :: vs -> (
            if List.for_all (Var.equal v % snd) vs then
              let assigned = node_of c.caller_id @@ StringMap.find s c.lhs in
              match !assigned.parent with
              | Some _ -> ()
              | None -> (
                  (* i had so much fun writing this...
                  match List.fold_left (( %> ) fst % LF.join) f vs with *)
                  match List.fold_left (fun f (g, _) -> LF.join f g) f vs with
                  | TopEdge | LF.Join _ -> ()
                  | f ->
                      join (node_of c.caller_id v) f assigned;
                      (* We have updated the caller's graph so we
                                   should recompute it *)
                      update_worklist c.caller_id))
        | [] -> failwith "leaves should never be empty!")

  let add_intra_stmt summaries callers node_of pid component stmt =
    let open Stmt in
    match stmt with
    | Instr_Assign { al } ->
        al
        |> List.iter (fun (v, e) ->
            match LF.Extract.extract_expr e with
            | f, Some v' ->
                let v, v' = (node_of pid v, node_of pid v') in
                (* v := f(v'), draw edge from v to v' with f *)
                CopyNode.join v' f v
            | _, None -> ())
    | Instr_Call c ->
        (* We at the same time create a list of all callers of each procedure in the scc. *)
        if List.mem ~eq:ID.equal c.procid component then
          Hashtbl.update callers
            ~f:(fun _ l ->
              let c = { caller_id = pid; lhs = c.lhs; args = c.args } in
              match l with Some cs -> Some (c :: cs) | None -> Some [ c ])
            ~k:c.procid
        else
          Hashtbl.get summaries c.procid
          |> Option.iter (fun m ->
              let c = { caller_id = pid; lhs = c.lhs; args = c.args } in
              StringMap.iter
                (fun s v ->
                  StringMap.get s m
                  |> Option.iter (fun leaves ->
                      propagate_call node_of ignore s c leaves))
                c.lhs)
    | _ -> ()

  let exits = [ "@__assert_fail"; "@exit" ]

  let add_stub node_of proc =
    let open Option.Infix in
    let fin, fout =
      (Procedure.formal_in_params proc, Procedure.formal_out_params proc)
    in
    if
      List.exists
        (fun s -> Procedure.id proc |> ID.name |> String.starts_with ~prefix:s)
        exits
    then
      (* Put everything to bottom *)
      StringMap.iter
        (fun sin vin ->
          ignore
            (let* var = String.chop_suffix ~suf:"in" sin in
             let sout = var ^ "out" in
             let* vout = StringMap.get sout fout in
             Some (CopyNode.join (node_of vin) LF.bottom (node_of vout))))
        fin
    else
      (* ARM abi tell us that R19..R29 and R31 are preserved through calls https://github.com/ARM-software/abi-aa/blob/main/aapcs64/aapcs64.rst#611general-purpose-registers *)
      let regs =
        List.range 19 29 @ [ 31 ] |> List.map (fun n -> "R" ^ Int.to_string n)
      in
      let fin, fout =
        (Procedure.formal_in_params proc, Procedure.formal_out_params proc)
      in
      List.iter
        (fun r ->
          ignore
            (let* inp = StringMap.get (r ^ "_in") fin in
             let* out = StringMap.get (r ^ "_out") fout in
             Some (CopyNode.join (node_of inp) LF.identity (node_of out))))
        regs

  module Worklist = Worklist.Make (ID)

  let solve_component (prog : Program.t) call_graph summaries
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
        let proc = Program.proc prog pid in
        match Procedure.graph proc with
        | None -> add_stub (node_of pid) proc
        | Some _ ->
            Procedure.iter_blocks proc
            |> Iter.iter (fun (bid, b) ->
                Block.stmts_iter b
                |> Iter.iter
                     (add_intra_stmt summaries callers node_of pid component);
                List.iter (add_phi (node_of pid)) b.phis))
      component;
    (* The interproc part *)
    let worklist = Worklist.create () in
    Worklist.add_list worklist component;
    while Worklist.non_empty worklist do
      let pid = Worklist.pop worklist in
      let proc = Program.proc prog pid in
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
          (* Store a summary of this outvar *)
          let m = Hashtbl.get_or summaries pid ~default:StringMap.empty in
          let m = StringMap.add (Var.name !node.v) leaves m in
          Hashtbl.replace summaries pid m;
          (* Propagate calls within this scc *)
          Hashtbl.get_or callers pid ~default:[]
          |> List.iter (fun (call : call_info) ->
              propagate_call node_of
                (fun pid -> Worklist.add worklist call.caller_id)
                (Var.name @@ var node)
                call leaves))
    done

  type 'a skip_option = SSome of 'a | Skip | SNone

  (** Collapse copies through phis into copies *)
  let collapse_composites g =
    let open CopyNode in
    (* Invariant: var node in !searched =>
        (find node) is not linear copied from any other variable and
        all (map find copied_from) are in !searched *)
    let searched = ref VarSet.empty in
    (* For ensuring each node is only searched once *)
    let searching = ref VarSet.empty in
    (* Ensures: var node in !searched *)
    (* Ensures: !searching == old(!searching) *)
    let rec search (node : t) =
      if not @@ VarSet.mem !node.v !searched then (
        searching := VarSet.add !node.v !searching;
        propagate node;
        searching := VarSet.remove !node.v !searching;
        searched := VarSet.add !node.v !searched)
    (* Search targets and see if a common single parent + function exists *)
    and propagate node =
      match
        effective_parent LF.identity !node.copied_from
          (ref (VarMap.singleton !node.v SNone))
      with
      | SSome ((LF.TopEdge | LF.Join _), l) -> propagate_copy node
      | SSome (f, l) ->
          join l f node;
          if not @@ LF.is_id f then propagate_copy node
      | Skip -> failwith "the effective parent shouldn't ever be skip!"
      | SNone -> ()
    (* Further propagate only copy edges *)
    and propagate_copy node =
      match effective_copy_parent !node.copied_from (ref VarSet.empty) with
      | SSome n -> join_copy n node
      | Skip -> failwith "the effective parent shouldn't ever be skip!"
      | _ -> ()
    (* Perform a dfs on the subgraph of nodes that are currently being
       searched, searching any new not-in-progress nodes, and try collect a
       common parent edge while doing so. Effectively, we find all leaf edges
       of this graph, where a leaf is a node that has been searched or is
       properly a leaf, and "join" them together (but we join during the
       search). *)
    (* memo stores computed parent edges per node, from said node. if we are
       mid computation of that node, we store SNone. if another searcher
       queries memo and finds Some SNone, then there is a cycle. *)
    and effective_parent f (nodes : t list) memo =
      let step ((f', n) : edge) =
        assert (Option.is_none !n.parent);
        let f = f @. f' in
        match VarMap.get !n.v !memo with
        | Some (SSome (f'', n')) -> SSome (f' @. f'', n')
        | Some Skip -> Skip
        | Some SNone when LF.is_id f -> Skip
        (* I came up with a funky argument for why any non-identity cycle
           should return None (return None as in return this node as
           the parent)
           It was something like: if we have a non identity function from the
           root that loops back on a currently searched node, that node will
           have a path to the root of this search, giving us a non identity
           loop through the root! In this case the node before the loop should
           be returned as the parent. *)
        | Some SNone -> SSome (f', n)
        | None -> (
            memo := VarMap.add !n.v SNone !memo;
            let r =
              if VarSet.mem !n.v !searching then
                effective_parent f !n.copied_from memo
              else (
                search n;
                SSome (find n))
            in
            (* If there was no parent then this node is now the parent *)
            let r = match r with SNone -> SSome (LF.identity, n) | e -> e in
            memo := VarMap.add !n.v r !memo;
            match r with SSome (f'', n') -> SSome (f' @. f'', n') | a -> a)
      in
      List.map (step % find) nodes
      |> List.reduce (fun a b ->
          match (a, b) with
          | a, Skip | Skip, a -> a
          | SSome (f1, n1), SSome (f2, n2) when CopyNode.eq n1 n2 ->
              SSome (LF.join f1 f2, n1)
          | _ -> SNone)
      |> Option.get_or ~default:SNone
    (* The same thing as above but only copy propagation only (so much
       duplication...) *)
    and effective_copy_parent (nodes : t list) visited =
      let step n =
        assert (Option.is_none !n.copy_parent);
        if VarSet.mem !n.v !visited then Skip
        else (
          visited := VarSet.add !n.v !visited;
          if VarSet.mem !n.v !searching then
            effective_copy_parent !n.copied_from visited
          else (
            search n;
            SSome (find_copy n)))
      in
      List.map (step % find_copy) nodes
      |> List.reduce (fun a b ->
          match (a, b) with
          | a, Skip | Skip, a -> a
          | SSome n1, SSome n2 when CopyNode.eq n1 n2 -> SSome n1
          | _ -> SNone)
      |> Option.get_or ~default:SNone
    in
    VarMap.iter (const (search % snd % find)) g

  let solve (prog : Program.t) =
    let graphs : (ID.t, CopyNode.t VarMap.t) Hashtbl.t = Hashtbl.create 100 in
    let call_graph = Program.CallGraph.make_call_graph prog in
    let summaries = Hashtbl.create 100 in
    ( Trace_core.with_span ~__FILE__ ~__LINE__ "graph-creation" @@ fun _ ->
      Program.CallGraph.Scc.scc_list call_graph
      |> List.map
           (List.filter_map (function
             | Program.CallGraph.Vert.ProcBegin id -> Some id
             | _ -> None))
      |> List.iter (solve_component prog call_graph summaries graphs) );
    ( Trace_core.with_span ~__FILE__ ~__LINE__ "phi-propagation" @@ fun _ ->
      Hashtbl.iter (const collapse_composites) graphs );
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

let%expect_test "canonicalises" =
  (* This program used to get stuck in an infinite loop before canonicalisation
     as Top was represented by Join(a, b, Top) for a constantly changing b *)
  let lst =
    Loader.Loadir.ast_of_string
      {|
prog entry @f;

proc @f (x_in: bv64) -> (x_3:bv64)
[
  block %entry [
    var x_1: bv64 := bvadd(x_in:bv64, 0xffffffffffffffc0:bv64);
    goto(%a);
  ];
  block %a (var x_2:bv64 := phi(%entry -> x_1:bv64, %a -> x_3:bv64)) [
    (var x_3:bv64) := call @g(x_2);
    goto(%a, %ret);
  ];
  block %ret [
    return;
  ]
];

proc @g (x_in: bv64) -> (x_3:bv64)
[
  block %entry [
    var x_1: bv64 := bvadd(x_in:bv64, 0xffffffffffffffd0:bv64);
    goto(%a, %ret);
  ];
  block %a [
    var x_2: bv64 := bvadd(x_1:bv64, 0x30:bv64);
    goto(%ret);
  ];
  block %ret (var x_3:bv64 := phi ( %entry -> x_1:bv64, %a -> x_2:bv64) ) [
    return;
  ]
];
    |}
  in
  let prog = lst.prog in
  ignore @@ LinearConstAnalysis.solve prog

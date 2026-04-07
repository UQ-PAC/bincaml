(** Interprocedural linear expression constant propagation.

    Performs constant propagation for assignments of the form y := a * x + b;
    where a and b are constants. *)

open Lang
open Common
open Idessi
open Lattice_types

module LinearDomain = struct
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

  let eval f x =
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

  type state_update = (DL.t * t) Iter.t

  let init_data (proc : Program.proc) =
    Procedure.formal_in_params proc |> StringMap.values

  open DL

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
      | BinaryExpr { op = `BVADD; arg1; arg2 } -> liftJoin2 Lin.add arg1 arg2
      (* BVMUL isn't an intrin ... *)
      | BinaryExpr { op = `BVMUL; arg1; arg2 } -> liftJoin2 Lin.mul arg1 arg2
      | _ -> None

    let extract_expr e =
      match Expr.BasilExpr.cata extract_alg e with
      | Some (Some a, Some _, b)
        when Z.equal Z.one (Bitvec.value a) && Z.equal Z.zero (Bitvec.value b)
        ->
          IdEdge
      | Some (Some a, Some _, b) -> Linear (a, b)
      | _ -> TopEdge
  end

  let transfer_call call param d =
    match d with
    | Lambda -> Iter.singleton (Lambda, IdEdge)
    | Label v ->
        StringMap.to_iter call
        |> Iter.filter (fun (s, e) -> VarSet.mem v (Expr.BasilExpr.free_vars e))
        |> Iter.map (fun (s, e) ->
            let v' = StringMap.find s param in
            (Label v', Extract.extract_expr e))

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
            |> Iter.map (fun (v', e) -> (Label v', Extract.extract_expr e))
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

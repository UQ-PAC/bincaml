open Common
open Containers
open Ops

module AbstractExpr = struct
  type ('const, 'var, 'unary, 'binary, 'intrin, 'e) t =
    | RVar of 'var  (** variables *)
    | Constant of 'const
        (** constants; a pure intrinsic function with zero arguments *)
    | UnaryExpr of 'unary * 'e
        (** application of a pure intrinsic function with one arguments *)
    | BinaryExpr of 'binary * 'e * 'e
        (** application of a pure intrinsic function with two arguments *)
    | ApplyIntrin of 'intrin * 'e list
        (** application of a pure intrinsic function with n arguments *)
    | ApplyFun of string * 'e list
        (** application of a pure runtime-defined function with n arguments *)
    | Binding of 'e list * 'e  (** syntactic binding in a nested scope *)
  [@@deriving eq, ord, fold, map, iter]

  let id a b = a
  let fold f b o = fold id id id id id f b o

  let map f e =
    let id a = a in
    map id id id id id f e

  let hash hash e1 : int =
    match e1 with
    | RVar r -> Hash.(combine2 1 (poly r))
    | UnaryExpr (op, a) -> Hash.(combine3 3 (poly op) (hash a))
    | BinaryExpr (op, l, r) -> Hash.(combine4 5 (poly op) (hash l) (hash r))
    | Constant c -> Hash.(combine2 7 (poly c))
    | ApplyIntrin (i, args) -> Hash.(combine3 11 (poly i) (list hash args))
    | ApplyFun (n, args) -> Hash.(combine3 13 (string n) (list hash args))
    | Binding (args, body) -> Hash.(combine3 17 (list poly args) (hash body))
end

module Alges = struct
  open AbstractExpr

  let children_alg a =
    let alg a = fold (fun acc a -> a @ acc) [] a in
    alg

  let hash_alg (hash_const : 'a -> int) (hash_var : 'b -> int) =
    let alg a =
      match a with
      | RVar v -> hash_var v
      | Constant c -> hash_const c
      | UnaryExpr (op, e) -> Hash.pair Hashtbl.hash Fun.id (Hashtbl.hash op, e)
      | BinaryExpr (op, e, e2) ->
          Hash.triple Hashtbl.hash Fun.id Fun.id (Hashtbl.hash op, e, e2)
      | ApplyIntrin (op, es) ->
          Hash.pair Hashtbl.hash (Hash.list Fun.id) (op, es)
      | ApplyFun (n, es) -> Hash.pair Hash.string (Hash.list Fun.id) (n, es)
      | Binding (vs, b) -> Hash.pair (Hash.list hash_var) Fun.id (vs, b)
    in
    alg
end

module type Fix = sig
  type const
  type var
  type unary
  type binary
  type intrin
  type t

  module Var : HASH_TYPE with type t = var

  val fix : (const, var, unary, binary, intrin, t) AbstractExpr.t -> t
  val unfix : t -> (const, var, unary, binary, intrin, t) AbstractExpr.t
end

module Recursion (O : Fix) = struct
  open Fun.Infix
  open O

  type 'e abstract_expr =
    (const, Var.t, unary, binary, intrin, 'e) AbstractExpr.t

  type 'a alg = 'a abstract_expr -> 'a
  type 'a coalg = 'a -> 'a abstract_expr

  (** {1 Recursion schemes}

      Methods of traversing a generic on 'a abstract_expr for a given fix point
      type [Fix.t].

      See:

      {:https://arxiv.org/pdf/2202.13633v1}

      {:https://icfp24.sigplan.org/details/ocaml-2024-papers/11/Recursion-schemes-in-OCaml-An-experience-report}
  *)

  (** Fold an algebra e -> 'a through the expression, from leaves to nodes to
      return 'a. *)
  let rec cata (alg : 'a alg) e =
    (unfix %> AbstractExpr.map (cata alg) %> alg) e

  (* ana coalg = Out◦ ◦ fmap (ana coalg) ◦ coalg *)
  let rec ana (coalg : 'a coalg) e =
    (coalg %> AbstractExpr.map (ana coalg) %> fix) e

  (** Apply function ~f to the expression first, then pass it to alg. Its result
      is accumulated down the expression tree. *)
  let rec map_fold ~(f : 'a -> t abstract_expr -> 'a)
      ~(alg : 'a -> 'b abstract_expr -> 'b) r e =
    let r = f r (unfix e) in
    (unfix %> (AbstractExpr.map (map_fold ~f ~alg r) %> alg r)) e

  (* hylo
  let rec hylo ~consume_alg ~produce_coalg e =
    consume_alg
    % AbstractExpr.map (hylo ~consume_alg ~produce_coalg)
    % produce_coalg
    @@ e
    *)

  (** mutual recursion: simultaneously evaluate two catamorphisms which can
      depend on each-other's results. *)
  let rec mutu ?(cata = cata) (alg1 : ('a * 'b) abstract_expr -> 'a)
      (alg2 : ('a * 'b) abstract_expr -> 'b) =
    let alg x = (alg1 x, alg2 x) in
    (fst % cata alg, snd % cata alg)

  (** zygomorphism;

      Perform two recursion simultaneously, passing the result of the first to
      the second *)
  let zygo ?(cata = cata) (alg1 : 'a alg) (alg2 : ('a * 'b) abstract_expr -> 'b)
      e =
    snd (mutu ~cata (AbstractExpr.map fst %> alg1) alg2) e

  (* zygo with the order swapped *)
  let zygo_l ?(cata = cata) (alg2 : 'a alg)
      (alg1 : ('b * 'a) abstract_expr -> 'b) =
    fst (mutu ~cata alg1 (AbstractExpr.map snd %> alg2))

  let map_fold2 ~f ~(alg1 : 'a -> ('b * 'c) abstract_expr -> 'b)
      ~(alg2 : 'c alg) r e =
    let alg r x = (alg1 r x, alg2 (AbstractExpr.map snd x)) in
    fst (fst % map_fold ~f ~alg r, snd % map_fold ~f ~alg r) e

  (** catamorphism that also passes the original expression through *)
  let rec para_f (alg : ('a * 'b) abstract_expr -> 'b) f e =
    let p f g x = (f x, g x) in
    (alg % AbstractExpr.map (p f (para_f alg f)) % unfix) e

  let para alg e = para_f alg id e

  module Constructors = struct
    let rvar v = fix (RVar v)
    let const v = fix (Constant v)
    let binexp ~op l r = fix (BinaryExpr (op, l, r))
    let unexp ~op arg = fix (UnaryExpr (op, arg))
    let fapply id params = fix (ApplyFun (id, params))
    let binding params body = fix (Binding (params, body))
    let applyintrin ~op params = fix (ApplyIntrin (op, params))
    let apply_fun ~name params = fix (ApplyFun (name, params))
  end

  (* dont know
  let bind_match ~fconst ~frvar ~funi ~fbin ~fbind ~fintrin ~ffun
      (e : 'e abstract_expr) : 'a =
    let open AbstractExpr in
    match e with
    | RVar v -> frvar v
    | Constant c -> fconst c
    | UnaryExpr (op, e) -> funi op e
    | BinaryExpr (op, a, b) -> fbin op a b
    | Binding (a, b) -> fbind a b
    | ApplyIntrin (a, b) -> fintrin a b
    | ApplyFun (a, b) -> ffun a b
    *)

  (**helpers*)

  open struct
    module VarSet = Set.Make (Var)
  end

  (** get free vars of exprs *)
  let free_vars (e : t) =
    let open AbstractExpr in
    let alg e =
      match e with
      | RVar e -> VarSet.singleton e
      | Binding (b, e) ->
          VarSet.diff e (List.fold_left VarSet.union VarSet.empty b)
      | o -> fold (fun acc a -> VarSet.union a acc) VarSet.empty o
    in
    cata alg e

  let free_vars_iter (e : t) = free_vars e |> VarSet.to_iter

  (* substite variables for expressions *)
  let substitute (sub : var -> t option) (e : t) =
    let open AbstractExpr in
    let binding acc e =
      match e with
      | Binding (b, e) ->
          let v =
            List.map free_vars b |> List.fold_left VarSet.union VarSet.empty
          in
          VarSet.union acc v
      | o -> acc
    in
    let subst binding orig =
      match orig with
      | RVar e when VarSet.find_opt e binding |> Option.is_none -> (
          match sub e with Some r -> r | None -> fix orig)
      | o -> fix o
    in
    map_fold ~f:binding ~alg:subst VarSet.empty e

  (** get list of child expressions *)
  let children e = cata Alges.children_alg e
end

module BasilExpr = struct
  open AllOps

  module EHashed = struct
    include AllOps

    type var = Var.t
    type 'a cell = 'a Fix.HashCons.cell

    let equal_cell _ a b = Fix.HashCons.equal a b
    let compare_cell _ a b = Fix.HashCons.compare a b

    type t = expr_node_v cell

    and expr_node_v =
      | E of (const, Var.t, unary, binary, intrin, t) AbstractExpr.t
    [@@deriving eq, ord]

    module HashExpr = struct
      type t = expr_node_v

      let hash e : int =
        e |> function E e -> AbstractExpr.hash Fix.HashCons.hash e

      let equal (i : t) (j : t) : bool =
        match (i, j) with
        | E i, E j ->
            AbstractExpr.equal AllOps.equal_const Var.equal AllOps.equal_unary
              AllOps.equal_binary AllOps.equal_intrin Fix.HashCons.equal i j
    end

    module H = Fix.HashCons.ForHashedTypeWeak (HashExpr)

    let fix i = H.make (E i)
    let unfix i = match Fix.HashCons.data i with E i -> i
  end

  module E = struct
    include AllOps

    type var = Var.t
    type 'a cell = 'a Fix.HashCons.cell

    type t = expr_node_v

    and expr_node_v =
      | E of (const, Var.t, unary, binary, intrin, t) AbstractExpr.t
    [@@unboxed] [@@deriving eq, ord]

    let fix i = E i
    let unfix i = match i with E i -> i
  end

  include E

  module R = Recursion (struct
    include E
    module Var = Var
  end)

  include R

  let pretty_alg (e : Containers_pp.t abstract_expr) =
    let open AbstractExpr in
    let open Containers_pp in
    let open Containers_pp.Infix in
    match e with
    | RVar v -> text @@ Var.to_string v
    | Constant c -> text @@ AllOps.to_string c
    | UnaryExpr (`ZeroExtend bits, e) ->
        fill
          (text "," ^ newline)
          [ (textpf "zero_extend(%d") bits; e ^ text ")" ]
    | UnaryExpr (`SignExtend bits, e) ->
        fill
          (text "," ^ newline)
          [ (textpf "sign_extend(%d") bits; e ^ text ")" ]
    | UnaryExpr (`Extract (hi, lo), e) ->
        fill nil [ textpf "extract(%d,%d, " hi lo ^ e ^ text ")" ]
    | UnaryExpr (op, e) -> text (AllOps.to_string op) ^ bracket "(" e ")"
    | BinaryExpr (op, e, e2) ->
        fill nil
          [
            text (AllOps.to_string op)
            ^ bracket "(" (fill (text "," ^ newline) [ e; e2 ]) ")";
          ]
    | ApplyIntrin (op, es) ->
        fill nil
          [
            text (AllOps.to_string op)
            ^ bracket "(" (fill (text "," ^ newline) es) ")";
          ]
    | ApplyFun (n, es) ->
        fill nil [ text n ^ bracket "(\n" (fill (text "," ^ newline) es) ")" ]
    | Binding (vs, b) -> fill (text " ") vs ^ text " ::" ^ newline ^ b

  (* printers *)
  let print_alg (e : string abstract_expr) =
    let open AbstractExpr in
    match e with
    | RVar v -> Var.to_string v
    | Constant c -> AllOps.to_string c
    | UnaryExpr (`ZeroExtend bits, e) ->
        Printf.sprintf "zero_extend(%d, " bits ^ e ^ ")"
    | UnaryExpr (`SignExtend bits, e) ->
        Printf.sprintf "sign_extend(%d, " bits ^ e ^ ")"
    | UnaryExpr (`Extract (hi, lo), e) ->
        Printf.sprintf "extract(%d, %d, " hi lo ^ e ^ ")"
    | UnaryExpr (op, e) -> AllOps.to_string op ^ "(" ^ e ^ ")"
    | BinaryExpr (op, e, e2) -> AllOps.to_string op ^ "(" ^ e ^ ", " ^ e2 ^ ")"
    | ApplyIntrin (op, es) ->
        AllOps.to_string op ^ "(" ^ String.concat ", " es ^ ")"
    | ApplyFun (n, es) -> n ^ "(" ^ String.concat ", " es ^ ")"
    | Binding (vs, b) -> String.concat " " vs ^ " :: " ^ b

  let pretty s = cata pretty_alg s
  let to_string s = cata print_alg s
  let pp fmt s = Format.pp_print_string fmt @@ to_string s

  (** Algebra that infers types of expressions *)
  let type_alg (e : Types.t abstract_expr) =
    let open AbstractExpr in
    let open Ops.AllOps in
    let get_ty o =
      match o with Fun { ret } -> ret | _ -> failwith "type error"
    in
    match e with
    | RVar r -> Var.typ r
    | Constant op -> ret_type_const op |> get_ty
    | UnaryExpr (op, a) -> ret_type_unary op a |> get_ty
    | BinaryExpr (op, l, r) -> ret_type_bin op l r |> get_ty
    | ApplyIntrin (op, args) -> ret_type_intrin op args |> get_ty
    | ApplyFun (a, b) -> Types.Top
    | Binding (vars, b) -> Types.uncurry vars b

  let type_of e = cata type_alg e

  let fold_with_type ?(cata = cata) (alg : 'e abstract_expr -> 'a) =
    zygo_l ~cata type_alg alg

  let rewrite ?(cata = cata) ~(rw_fun : t abstract_expr -> t option) (expr : t)
      =
    let rw_alg e =
      let orig s = fix s in
      match rw_fun e with
      | Some e' when Types.equal (type_of e') (type_of (orig e)) -> e'
      | Some e' ->
          failwith
          @@ Printf.sprintf
               "improper rewrite type: attempt to rewrite %s into %s"
               (to_string (orig e))
               (to_string e')
      | None -> orig e
    in
    cata rw_alg expr

  let rewrite_typed ?(cata = cata) (f : (t * Types.t) abstract_expr -> t option)
      (expr : t) =
    let rw_alg e =
      let orig s = fix @@ AbstractExpr.map fst s in
      match f e with Some e -> e | None -> orig e
    in
    fold_with_type rw_alg expr

  (** typed expression rewriter *)
  let rewrite_typed ?(cata = cata) (f : (t * Types.t) abstract_expr -> t option)
      (expr : t) =
    let rw_alg e =
      let orig s = fix @@ AbstractExpr.map fst s in
      match f e with Some e -> e | None -> orig e
    in
    fold_with_type ~cata rw_alg expr

  (** typed rewriter that expands two layers deep into the expression *)
  let rewrite_typed_two ?(cata = cata)
      (f : (t abstract_expr * Types.t) abstract_expr -> t option) (expr : t) =
    let rw_alg e =
      let unfold = AbstractExpr.map (fun (e, t) -> (unfix e, t)) e in
      let orig s = fix @@ AbstractExpr.map fst s in
      match f unfold with Some e -> e | None -> orig e
    in
    fold_with_type ~cata rw_alg expr

  (** {2 Smart Constructors} *)

  include R.Constructors

  let zero_extend ~n_prefix_bits (e : t) : t =
    unexp ~op:(`ZeroExtend n_prefix_bits) e

  let sign_extend ~n_prefix_bits (e : t) : t =
    unexp ~op:(`SignExtend n_prefix_bits) e

  let extract ~hi_incl ~lo_excl (e : t) : t =
    unexp ~op:(`Extract (hi_incl, lo_excl)) e

  let concat (e : t) (f : t) : t = applyintrin ~op:`BVConcat [ e; f ]
  let forall ~bound p = unexp ~op:`Forall (binding bound p)
  let exists ~bound p = unexp ~op:`Exists (binding bound p)
  let boolnot e = unexp ~op:`BoolNOT e
  let intconst (v : PrimInt.t) : t = const (`Integer v)
  let boolconst (v : bool) : t = const (`Bool v)
  let bvconst (v : Bitvec.t) : t = const (`Bitvector v)

  let bv_of_int ~(size : int) (v : int) : t =
    const (`Bitvector (Bitvec.of_int ~size v))

  (*
  module Memoiser = Fix.Memoize.ForHashedType (struct
    type expr = t
    type t = expr

    let equal = Fix.HashCons.equal
    let hash = Fix.HashCons.hash
  end)

  let cata_memo (alg : 'a abstract_expr -> 'a) =
    let g r t = AbstractExpr.map r (unfix t) |> alg in
    Memoiser.fix g

  (** memoised rewriter; will likely be slower than without memoisation unless
      there is significant sharing*)
  let rewrite_memo = rewrite ~cata:cata_memo

  (** memoised typed rewriter; will likely be slower than without memoisation
      unless there is significant sharing*)
  let rewrite_typed_memo = rewrite_typed ~cata:cata_memo

  (** memoised typed rewriter that unfolds an extre levels of each subexpr; will
      likely be slower than without memoisation unless there is significant
      sharing*)
  let rewrite_typed_two_memo = rewrite_typed_two ~cata:cata_memo
  *)
end

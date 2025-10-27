open Common
open Containers
open Value
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
    | Binding of 'var list * 'e  (** syntactic binding in a nested scope *)
  [@@deriving eq, ord, fold, map, iter]

  let id a b = a
  let fold f b o = fold id id id id id f b o
  let omap = map

  let map f e =
    let id a = a in
    omap id id id id id f e

  let hash hash e1 =
    let hash_const = Hashtbl.hash in
    let hash_var = Hashtbl.hash in
    let hash_unary = Hashtbl.hash in
    let hash_binary = Hashtbl.hash in
    let hash_intrin = Hashtbl.hash in
    let open HashHelper in
    match e1 with
    | RVar r -> combine 1 (hash_var r)
    | UnaryExpr (op, a) -> combine2 3 (hash_unary op) (hash a)
    | BinaryExpr (op, l, r) -> combine3 5 (hash_binary op) (hash l) (hash r)
    | Constant c -> combine 7 (hash_const c)
    | ApplyIntrin (i, args) ->
        combine 11 (combinel (hash_intrin i) (List.map hash args))
    | ApplyFun (n, args) ->
        combine 13 (combinel (String.hash n) (List.map hash args))
    | Binding (args, body) ->
        combine 17 (combinel (hash body) (List.map hash_var args))
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

  (** Recursion schemes on AbstractExpr.t for a given fix point type.

      See:

      https://arxiv.org/pdf/2202.13633v1

      https://icfp24.sigplan.org/details/ocaml-2024-papers/11/Recursion-schemes-in-OCaml-An-experience-report
  *)

  (** Fold an algebra e -> 'a through the expression, from leaves to nodes to
      return 'a. *)
  let rec cata alg e = (unfix %> AbstractExpr.map (cata alg) %> alg) e

  (* ana coalg = Out◦ ◦ fmap (ana coalg) ◦ coalg *)
  let rec ana coalg e = (coalg %> AbstractExpr.map (ana coalg) %> fix) e

  (** Apply function ~f to the expression first, then pass it to alg. Its result
      is accumulated down the expression tree. *)
  let rec map_fold ~f ~alg r e =
    let r = f r (unfix e) in
    (unfix %> (AbstractExpr.map (map_fold ~f ~alg r) %> alg r)) e

  (* hylo *)
  let rec hylo ~consume_alg ~produce_coalg e =
    consume_alg
    % AbstractExpr.map (hylo ~consume_alg ~produce_coalg)
    % produce_coalg
    @@ e

  (* mutual recursion:
    simultaneously evaluate two catamorphisms which can depend on each-other's results.
     *)
  let rec mutu alg1 alg2 =
    let alg x = (alg1 x, alg2 x) in
    (fst % cata alg, snd % cata alg)

  (* zygomorphism;

     Perform two recursion simultaneously, passing the result of the second to the first.
     *)
  let rec zygo alg1 alg2 = fst (mutu alg1 (AbstractExpr.map snd %> alg2))

  (*
    catamorphism that also passes the original expression through
  *)
  let rec para alg f e =
    let p f g x = (f x, g x) in
    (alg % AbstractExpr.map (p f (para alg f)) % unfix) e

  let para alg e = para alg identity e

  (**smart constructors **)

  let rvar v = fix (RVar v)
  let const v = fix (Constant v)
  let intconst v = fix (Constant v)
  let binexp ~op l r = fix (BinaryExpr (op, l, r))
  let unexp ~op arg = fix (UnaryExpr (op, arg))
  let fapply id params = fix (ApplyFun (id, params))
  let binding params body = fix (Binding (params, body))
  let identity x = x
  let applyintrin ~op params = fix (ApplyIntrin (op, params))
  let apply_fun ~name params = fix (ApplyFun (name, params))

  (**helpers**)

  module VarSet = Set.Make (Var)

  (* substite variables for expressions *)
  let substitute (sub : var -> t option) (e : t) =
    let open AbstractExpr in
    let binding acc e =
      match e with
      | Binding (b, e) -> VarSet.union acc (VarSet.of_list b)
      | o -> acc
    in
    let subst binding orig =
      match orig with
      | RVar e when VarSet.find_opt e binding |> Option.is_none -> (
          match sub e with Some r -> r | None -> fix orig)
      | o -> fix o
    in
    map_fold ~f:binding ~alg:subst VarSet.empty e

  (* get free vars of exprs *)
  let free_vars (e : t) =
    let open AbstractExpr in
    let alg e =
      match e with
      | RVar e -> VarSet.singleton e
      | Binding (b, e) -> VarSet.diff e (VarSet.of_list b)
      | o -> fold (fun acc a -> VarSet.union a acc) VarSet.empty o
    in
    cata alg e

  (* get list of child expressions *)
  let children e = cata Alges.children_alg e

  (** tests **)
end

module BasilExpr = struct
  module E = struct
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

  include E

  module R = Recursion (struct
    include E
    module Var = Var
  end)

  include R

  type 'a scheme = (const, var, unary, binary, intrin, 'a) AbstractExpr.t

  (* printers *)
  let print_alg =
    let open AbstractExpr in
    function
    | RVar v -> Var.to_string v
    | Constant c -> AllOps.to_string c
    | UnaryExpr (op, e) -> AllOps.to_string op ^ "(" ^ e ^ ")"
    | BinaryExpr (op, e, e2) -> AllOps.to_string op ^ "(" ^ e ^ ", " ^ e2 ^ ")"
    | ApplyIntrin (op, es) ->
        AllOps.to_string op ^ "(" ^ String.concat ", " es ^ ")"
    | ApplyFun (n, es) -> n ^ "(" ^ String.concat ", " es ^ ")"
    | Binding (vs, b) ->
        String.concat " " (List.map Var.to_string vs) ^ " :: " ^ b

  let to_string s = cata print_alg s
  let pp fmt s = Format.pp_print_string fmt @@ to_string s

  (* constructor helpers *)
  let intconst (v : PrimInt.t) : t = const (`Integer v)
  let boolconst (v : bool) : t = const (`Bool v)
  let bvconst (v : PrimQFBV.t) : t = const (`Bitvector v)
  let load_expr (mem : Var.t) index : t = binexp ~op:`MapIndex (rvar mem) index

  let zero_extend ~n_prefix_bits (e : t) : t =
    applyintrin ~op:(`ZeroExtend n_prefix_bits) [ e ]

  let sign_extend ~n_prefix_bits (e : t) : t =
    applyintrin ~op:(`SignExtend n_prefix_bits) [ e ]

  let extract ~hi_incl ~lo_excl (e : t) : t =
    applyintrin ~op:(`Extract (hi_incl, lo_excl)) [ e ]

  let concat (e : t) (f : t) : t = binexp ~op:`BVConcat e f
  let forall ~bound p = unexp ~op:`Forall (binding bound p)
  let exists ~bound p = unexp ~op:`Exists (binding bound p)
  let boolnot e = unexp ~op:`NOT e
end

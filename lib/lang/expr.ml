open Common
open Containers
open Ops

module AbstractExpr = struct
  type ('const, 'var, 'unary, 'binary, 'intrin, 'e) simple =
    | V of 'var  (** variables *)
    | C of 'const
        (** constants; a pure intrinsic function with zero arguments *)
    | Unary of 'unary * 'e
        (** application of a pure intrinsic function with one arguments *)
    | Binary of 'binary * 'e * 'e
    | Intrin of 'intrin * 'e list
    | FApply of 'e * 'e list
    | Bound of 'var list * 'e

  type ('const, 'var, 'unary, 'binary, 'intrin, 'attrib, 'e) t =
    | RVar of { attrib : 'attrib option; id : 'var }  (** variables *)
    | Constant of { attrib : 'attrib option; const : 'const }
        (** constants; a pure intrinsic function with zero arguments *)
    | UnaryExpr of { attrib : 'attrib option; op : 'unary; arg : 'e }
        (** application of a pure intrinsic function with one arguments *)
    | BinaryExpr of {
        attrib : 'attrib option;
        op : 'binary;
        arg1 : 'e;
        arg2 : 'e;
      }  (** application of a pure intrinsic function with two arguments *)
    | ApplyIntrin of { attrib : 'attrib option; op : 'intrin; args : 'e list }
        (** application of a pure intrinsic function with n arguments *)
    | ApplyFun of { attrib : 'attrib option; func : 'e; args : 'e list }
        (** application of a pure runtime-defined function with n arguments *)
    | Binding of { attrib : 'attrib option; bound : 'var list; in_body : 'e }
        (** syntactic binding in a nested scope *)
  [@@deriving eq, ord, fold, map, iter]

  let simple_view x : ('const, 'var, 'unary, 'binary, 'intrin, 'e) simple =
    match x with
    | RVar { id } -> V id
    | Constant { const } -> C const
    | UnaryExpr { op; arg } -> Unary (op, arg)
    | BinaryExpr { op; arg1; arg2 } -> Binary (op, arg1, arg2)
    | ApplyIntrin { op; args } -> Intrin (op, args)
    | ApplyFun { func; args } -> FApply (func, args)
    | Binding { bound; in_body } -> Bound (bound, in_body)

  let of_simple_view (x : ('const, 'var, 'unary, 'binary, 'intrin, 'e) simple) :
      ('const, 'var, 'unary, 'binary, 'intrin, 'attrib, 'e) t =
    let attrib = None in
    match x with
    | V id -> RVar { id; attrib }
    | C const -> Constant { const; attrib }
    | Unary (op, arg) -> UnaryExpr { attrib; op; arg }
    | Binary (op, arg1, arg2) -> BinaryExpr { attrib; op; arg1; arg2 }
    | Intrin (op, args) -> ApplyIntrin { attrib; op; args }
    | FApply (func, args) -> ApplyFun { attrib; func; args }
    | Bound (bound, in_body) -> Binding { attrib; bound; in_body }

  let map_attrib f x =
    match x with
    | RVar x -> RVar { x with attrib = f x.attrib }
    | Constant x -> Constant { x with attrib = f x.attrib }
    | UnaryExpr x -> UnaryExpr { x with attrib = f x.attrib }
    | BinaryExpr x -> BinaryExpr { x with attrib = f x.attrib }
    | ApplyIntrin x -> ApplyIntrin { x with attrib = f x.attrib }
    | ApplyFun x -> ApplyFun { x with attrib = f x.attrib }
    | Binding x -> Binding { x with attrib = f x.attrib }

  let get_attrib x =
    match x with
    | RVar { attrib } -> attrib
    | Constant { attrib } -> attrib
    | UnaryExpr { attrib } -> attrib
    | BinaryExpr { attrib } -> attrib
    | ApplyIntrin { attrib } -> attrib
    | ApplyFun { attrib } -> attrib
    | Binding { attrib } -> attrib

  let drop_attrib x =
    match x with
    | RVar v -> RVar { v with attrib = None }
    | Constant v -> Constant { v with attrib = None }
    | UnaryExpr v -> UnaryExpr { v with attrib = None }
    | BinaryExpr v -> BinaryExpr { v with attrib = None }
    | ApplyIntrin v -> ApplyIntrin { v with attrib = None }
    | ApplyFun v -> ApplyFun { v with attrib = None }
    | Binding v -> Binding { v with attrib = None }

  let id a b = a
  let fold f b o = fold id id id id id id f b o

  let map f e =
    let id a = a in
    map id id id id id id f e

  let hash hash e1 : int =
    match e1 with
    | RVar { id } -> Hash.(combine2 1 (poly id))
    | UnaryExpr { op; arg } -> Hash.(combine3 3 (poly op) (hash arg))
    | BinaryExpr { op; arg1; arg2 } ->
        Hash.(combine4 5 (poly op) (hash arg1) (hash arg2))
    | Constant { const } -> Hash.(combine2 7 (poly const))
    | ApplyIntrin { op; args } -> Hash.(combine3 11 (poly op) (list hash args))
    | ApplyFun { func; args } -> Hash.(combine3 13 (hash func) (list hash args))
    | Binding { bound; in_body } ->
        Hash.(combine3 17 (list poly bound) (hash in_body))
end

module Alges = struct
  open AbstractExpr

  let children_alg a =
    let alg a = fold (fun acc a -> a @ acc) [] a in
    alg

  let hash_alg (hash_const : 'a -> int) (hash_var : 'b -> int) =
    let alg a =
      match a with
      | RVar { id } -> hash_var id
      | Constant { const } -> hash_const const
      | UnaryExpr { op; arg } ->
          Hash.pair Hashtbl.hash Fun.id (Hashtbl.hash op, arg)
      | BinaryExpr { op; arg1; arg2 } ->
          Hash.triple Hashtbl.hash Fun.id Fun.id (Hashtbl.hash op, arg1, arg2)
      | ApplyIntrin { op; args } ->
          Hash.pair Hashtbl.hash (Hash.list Fun.id) (op, args)
      | ApplyFun { func; args } ->
          Hash.pair Hash.int (Hash.list Fun.id) (func, args)
      | Binding { bound; in_body } ->
          Hash.pair (Hash.list hash_var) Fun.id (bound, in_body)
    in
    alg
end

module type Fix = sig
  type const
  (** Type of constants*)

  type var
  (** Type of variables *)

  type unary
  (** Unary operators *)

  type binary
  (** Binary operators *)

  type intrin
  (** Nary operators *)

  type attrib

  type t
  (** Fixed type *)

  module Var : HASH_TYPE with type t = var

  val fix : (const, var, unary, binary, intrin, attrib, t) AbstractExpr.t -> t
  val unfix : t -> (const, var, unary, binary, intrin, attrib, t) AbstractExpr.t
end

module Make (O : Fix) = struct
  open Fun.Infix
  open O

  type 'e abstract_expr =
    (const, Var.t, unary, binary, intrin, attrib, 'e) AbstractExpr.t

  include Bincaml_util.Recursionscheme.Recursion (struct
    include O

    type 'e expr = 'e abstract_expr

    let map_expr = AbstractExpr.map
  end)

  module Constructors = struct
    let rvar ?attrib id = fix (RVar { attrib; id })
    let const ?attrib const = fix (Constant { attrib; const })

    let binexp ?attrib ~op arg1 arg2 =
      fix (BinaryExpr { attrib; op; arg1; arg2 })

    let unexp ?attrib ~op arg = fix (UnaryExpr { attrib; op; arg })
    let fapply ?attrib func args = fix (ApplyFun { attrib; func; args })
    let binding ?attrib bound in_body = fix (Binding { attrib; bound; in_body })
    let applyintrin ?attrib ~op args = fix (ApplyIntrin { attrib; op; args })
    let apply_fun ?attrib ~func args = fix (ApplyFun { attrib; func; args })
    let attrib e = unfix e |> AbstractExpr.get_attrib
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
      | RVar { id } -> VarSet.singleton id
      | Binding { bound; in_body } ->
          VarSet.diff in_body (VarSet.add_list VarSet.empty bound)
      | o -> fold (fun acc a -> VarSet.union a acc) VarSet.empty o
    in
    cata alg e

  let free_vars_iter (e : t) = free_vars e |> VarSet.to_iter

  (* substite variables for expressions *)
  let substitute (sub : var -> t option) (e : t) =
    let open AbstractExpr in
    let binding acc e =
      match e with Binding { bound } -> VarSet.add_list acc bound | o -> acc
    in
    let subst binding orig =
      match orig with
      | RVar { id } when VarSet.find_opt id binding |> Option.is_none -> (
          match sub id with Some r -> r | None -> fix orig)
      | o -> fix o
    in
    map_fold ~f:binding ~alg:subst VarSet.empty e

  (** get list of child expressions *)
  let children e = cata Alges.children_alg e
end

module BasilExpr = struct
  type const = Ops.AllOps.const
  type unary = Ops.AllOps.unary
  type binary = Ops.AllOps.binary
  type intrin = Ops.AllOps.intrin
  type var = Var.t

  module Var = Var
  open Ops.AllOps

  (** Fixed type of basil expressions: an expression of type {!t} whose
      subexpressions are also expressions of type {!t} *)
  type t =
    | E of (const, Var.t, unary, binary, intrin, t Attrib.t, t) AbstractExpr.t
  [@@unboxed] [@@deriving eq, ord]

  type ty = Types.t
  type attrib = t Attrib.t

  open struct
    (** leftover ; we could hash-cons the expression if we want *)
    module EHashed = struct
      include AllOps

      type var = Var.t
      type 'a cell = 'a Fix.HashCons.cell

      let equal_cell _ a b = Fix.HashCons.equal a b
      let compare_cell _ a b = Fix.HashCons.compare a b

      type t = expr_node_v cell

      and expr_node_v =
        | E of
            (const, Var.t, unary, binary, intrin, t Attrib.t, t) AbstractExpr.t
      [@@deriving eq, ord]

      module HashExpr = struct
        type t = expr_node_v

        let hash e : int =
          e |> function E e -> AbstractExpr.hash Fix.HashCons.hash e

        let equal (i : t) (j : t) : bool =
          match (i, j) with
          | E i, E j ->
              AbstractExpr.equal AllOps.equal_const Var.equal AllOps.equal_unary
                AllOps.equal_binary AllOps.equal_intrin
                (Attrib.equal Fix.HashCons.equal)
                Fix.HashCons.equal i j
      end

      module H = Fix.HashCons.ForHashedTypeWeak (HashExpr)

      let fix i = H.make (E i)
      let unfix i = match Fix.HashCons.data i with E i -> i
    end
  end

  (** {1 Expression recursions}

      We define the {! fix} and {!unfix} functions in order to derive traversal
      operations using recursion schemes, for more explanation on this see:
      {!Bincaml_util.Recursionscheme.Recursion}. *)

  (** create fixed type from abstract type *)
  let fix i = E i

  (** create abstract type from fixed type *)
  let unfix i = match i with E i -> i

  open struct
    module E = struct
      include AllOps

      type outer = t
      type t = outer
      type var = Var.t
      type attrib = t Attrib.t

      module Var = Var

      let fix i = fix i
      let unfix i = unfix i
    end

    module R = Make (E)
  end

  include R

  (** {1 Printing}*)

  let pretty_alg pattrib (e : Containers_pp.t abstract_expr) =
    let open AbstractExpr in
    let open Containers_pp in
    let open Containers_pp.Infix in
    let a = AbstractExpr.get_attrib e |> pattrib in
    match e with
    | RVar { id; attrib } -> text (Var.to_string id) ^ a
    | Constant { const } -> text (AllOps.to_string const) ^ a
    | UnaryExpr { op = `Lambda as op; arg } ->
        text (AllOps.to_string op) ^ a ^ text " " ^ arg
    | UnaryExpr { op = `Forall as op; arg } ->
        text (AllOps.to_string op) ^ a ^ text " " ^ arg
    | UnaryExpr { op = `Exists as op; arg } ->
        text (AllOps.to_string op) ^ a ^ text " " ^ arg
    | UnaryExpr { op = `ZeroExtend bits; arg } ->
        fill
          (text "," ^ newline)
          [ text "zero_extend" ^ a ^ (textpf "(%d") bits; arg ^ text ")" ]
    | UnaryExpr { op = `SignExtend bits; arg } ->
        fill
          (text "," ^ newline)
          [ text "sign_extend" ^ a ^ (textpf "(%d") bits; arg ^ text ")" ]
    | UnaryExpr { op = `Extract (hi, lo); arg = e } ->
        fill nil [ text "extract" ^ a ^ textpf "(%d,%d, " hi lo ^ e ^ text ")" ]
    | UnaryExpr { op; arg = e } ->
        text (AllOps.to_string op) ^ a ^ bracket "(" e ")"
    | BinaryExpr { op = `Load (endian, bits); arg1; arg2 } ->
        let endian =
          text @@ match endian with `Big -> "be" | `Little -> "le"
        in
        fill
          (text "," ^ newline)
          [
            text "load_" ^ endian ^ a ^ (textpf "(%d") bits;
            arg1 ^ text ", " ^ arg2 ^ text ")";
          ]
    | BinaryExpr { op; arg1 = e; arg2 = e2 } ->
        fill nil
          [
            text (AllOps.to_string op)
            ^ a
            ^ bracket "(" (fill (text "," ^ newline) [ e; e2 ]) ")";
          ]
    | ApplyIntrin { op; args = es } ->
        fill nil
          [
            text (AllOps.to_string op)
            ^ a
            ^ bracket "(" (fill (text "," ^ newline) es) ")";
          ]
    | ApplyFun { func = n; args = es } ->
        fill nil
          [ n ^ a ^ bracket "(" (nest 2 (fill (text "," ^ newline) es)) ")" ]
    | Binding { bound = vs; in_body = b } ->
        fill (text " ") (List.map (fun v -> bracket "(" (Var.pretty v) ")") vs)
        ^ text " :: " ^ a ^ bracket "(" b ")"

  let pretty_drop_attrib s =
    cata (pretty_alg (fun x -> Containers_pp.text "")) s

  let pretty s =
    let open Containers_pp in
    let pretty_attr = function
      | Some (`Assoc e) ->
          let attrib =
            StringMap.filter
              (fun k v -> not @@ String.equal k Attrib.location_key)
              e
          in
          if StringMap.is_empty attrib then text ""
          else
            text " " ^ Attrib.attrib_pretty pretty_drop_attrib (`Assoc attrib)
      | Some e -> text " " ^ Attrib.attrib_pretty pretty_drop_attrib e
      | None -> text ""
    in
    cata (pretty_alg pretty_attr) s

  let to_string s = Containers_pp.Pretty.to_string ~width:80 (pretty s)
  let pp fmt s = Format.pp_print_string fmt @@ to_string s

  (** {1 Typing}*)

  (** Algebra that infers types of expressions *)
  let type_alg (e : Types.t abstract_expr) =
    let open AbstractExpr in
    let open Ops.AllOps in
    let get_ty o =
      match o with Fun { ret } -> ret | _ -> failwith "type error"
    in
    match e with
    | RVar { id } -> Var.typ id
    | Constant { const = op } -> ret_type_const op |> get_ty
    | UnaryExpr { op; arg } -> ret_type_unary op arg |> get_ty
    | BinaryExpr { op; arg1 = l; arg2 = r } -> ret_type_bin op l r |> get_ty
    | ApplyIntrin { op; args } -> ret_type_intrin op args |> get_ty
    | ApplyFun { func; args } ->
        let _, rt = Types.uncurry func in
        rt
    | Binding { bound = vars; in_body = b } ->
        Types.curry (List.map Var.typ vars) b

  let type_of e = cata type_alg e

  (** {1 Additional traversals}*)

  let fold_with_type (alg : 'e abstract_expr -> 'a) = zygo_l ~cata type_alg alg

  (** substitute subexpression sbased on parameter *)
  let rewrite ~(rw_fun : t abstract_expr -> t option) (expr : t) =
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

  let rewrite_two (f : t abstract_expr abstract_expr -> t option) (expr : t) =
    let rw_alg e =
      let unfold = AbstractExpr.map unfix e in
      let orig s = lazy (fix s) in
      match f unfold with Some e -> e | None -> Lazy.force @@ orig e
    in
    cata rw_alg expr

  let rewrite_typed (f : (t * Types.t) abstract_expr -> t option) (expr : t) =
    let rw_alg e =
      let orig s = fix @@ AbstractExpr.map fst s in
      match f e with Some e -> e | None -> orig e
    in
    fold_with_type rw_alg expr

  (** typed expression rewriter *)
  let rewrite_typed (f : (t * Types.t) abstract_expr -> t option) (expr : t) =
    let rw_alg e =
      let orig s = fix @@ AbstractExpr.map fst s in
      match f e with Some e -> e | None -> orig e
    in
    fold_with_type rw_alg expr

  (** typed rewriter that expands two layers deep into the expression *)
  let rewrite_typed_two
      (f : (t abstract_expr * Types.t) abstract_expr -> t option) (expr : t) =
    let rw_alg e =
      let unfold = AbstractExpr.map (fun (e, t) -> (unfix e, t)) e in
      let orig s = fix @@ AbstractExpr.map fst s in
      match f unfold with Some e -> e | None -> orig e
    in
    fold_with_type rw_alg expr

  (** {1 Smart Constructors} *)

  include R.Constructors

  let zero_extend ?attrib ~n_prefix_bits (e : t) : t =
    unexp ?attrib ~op:(`ZeroExtend n_prefix_bits) e

  let sign_extend ?attrib ~n_prefix_bits (e : t) : t =
    unexp ?attrib ~op:(`SignExtend n_prefix_bits) e

  let load ?attrib ~bits endian (m : t) (ind : t) : t =
    binexp ?attrib ~op:(`Load (endian, bits)) m ind

  let extract ?attrib ~hi_excl ~lo_incl (e : t) : t =
    unexp ?attrib ~op:(`Extract (hi_excl, lo_incl)) e

  let concat ?attrib (e : t) (f : t) : t =
    applyintrin ?attrib ~op:`BVConcat [ e; f ]

  let concatl ?attrib (e : t list) : t = applyintrin ?attrib ~op:`BVConcat e
  let forall ?attrib ~bound p = unexp ?attrib ~op:`Forall (binding bound p)
  let exists ?attrib ~bound p = unexp ?attrib ~op:`Exists (binding bound p)
  let lambda ?attrib ~bound p = unexp ?attrib ~op:`Lambda (binding bound p)
  let boolnot ?attrib e = unexp ?attrib ~op:`BoolNOT e
  let intconst ?attrib (v : PrimInt.t) : t = const ?attrib (`Integer v)
  let boolconst ?attrib (v : bool) : t = const ?attrib (`Bool v)
  let bvconst ?attrib (v : Bitvec.t) : t = const ?attrib (`Bitvector v)

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

module type ExprType = sig
  include Fix

  type 'e abstract_expr

  include
    Bincaml_util.Recursionscheme.Recurseable
      with type 'a O.expr =
        (const, var, unary, binary, intrin, attrib, 'a) AbstractExpr.t

  type ty

  val type_alg : ty O.expr -> ty
end

module IVarFix = struct
  include AllOps

  module Var = struct
    include Int

    let show v = Int.to_string v
  end

  type var = Int.t

  type t = expr_node_v

  and expr_node_v =
    | E of (const, Int.t, unary, binary, intrin, t Attrib.t, t) AbstractExpr.t
  [@@unboxed] [@@deriving eq, ord]

  type attrib = t Attrib.t

  let fix i = E i
  let unfix i = match i with E i -> i
end

module ExprIntVar = Make (IVarFix)

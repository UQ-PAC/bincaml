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
    | Lambda of Ops.AllOps.lambda * 'var list * 'e
    | Let of ('var * 'e) list * 'e

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
    | Lambda of {
        op : Ops.AllOps.lambda;
        attrib : 'attrib option;
        bound_vars : 'var list;
        in_body : 'e;
      }  (** syntactic binding in a nested scope *)
    | Let of {
        attrib : 'attrib option;
        bound_vars : ('var * 'e) list;
        in_body : 'e;
      }  (** syntactic binding in a nested scope *)
  [@@deriving eq, ord, fold, map, iter]

  let simple_view x : ('const, 'var, 'unary, 'binary, 'intrin, 'e) simple =
    match x with
    | RVar { id } -> V id
    | Constant { const } -> C const
    | UnaryExpr { op; arg } -> Unary (op, arg)
    | BinaryExpr { op; arg1; arg2 } -> Binary (op, arg1, arg2)
    | ApplyIntrin { op; args } -> Intrin (op, args)
    | ApplyFun { func; args } -> FApply (func, args)
    | Lambda { op; bound_vars; in_body } -> Lambda (op, bound_vars, in_body)
    | Let { bound_vars; in_body } -> Let (bound_vars, in_body)

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
    | Lambda (op, bound_vars, in_body) ->
        Lambda { op; attrib; bound_vars; in_body }
    | Let (bound_vars, in_body) -> Let { attrib; bound_vars; in_body }

  let map_attrib f x =
    match x with
    | RVar x -> RVar { x with attrib = f x.attrib }
    | Constant x -> Constant { x with attrib = f x.attrib }
    | UnaryExpr x -> UnaryExpr { x with attrib = f x.attrib }
    | BinaryExpr x -> BinaryExpr { x with attrib = f x.attrib }
    | ApplyIntrin x -> ApplyIntrin { x with attrib = f x.attrib }
    | ApplyFun x -> ApplyFun { x with attrib = f x.attrib }
    | Lambda x -> Lambda { x with attrib = f x.attrib }
    | Let x -> Let { x with attrib = f x.attrib }

  let get_attrib x =
    match x with
    | RVar { attrib } -> attrib
    | Constant { attrib } -> attrib
    | UnaryExpr { attrib } -> attrib
    | BinaryExpr { attrib } -> attrib
    | ApplyIntrin { attrib } -> attrib
    | ApplyFun { attrib } -> attrib
    | Let { attrib } -> attrib
    | Lambda { attrib } -> attrib

  let drop_attrib x =
    match x with
    | RVar v -> RVar { v with attrib = None }
    | Constant v -> Constant { v with attrib = None }
    | UnaryExpr v -> UnaryExpr { v with attrib = None }
    | BinaryExpr v -> BinaryExpr { v with attrib = None }
    | ApplyIntrin v -> ApplyIntrin { v with attrib = None }
    | ApplyFun v -> ApplyFun { v with attrib = None }
    | Lambda v -> Lambda { v with attrib = None }
    | Let v -> Let { v with attrib = None }

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
    | Lambda { bound_vars; in_body } ->
        Hash.(combine3 17 (list poly bound_vars) (hash in_body))
    | Let { bound_vars; in_body } ->
        Hash.(combine3 23 ((list (pair poly hash)) bound_vars) (hash in_body))
end

module Alges = struct
  open AbstractExpr

  let children_alg a =
    let alg a = fold (fun acc a -> a @ acc) [] a in
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

    let binding ?attrib ~op bound_vars in_body =
      fix (Lambda { attrib; op; bound_vars; in_body })

    let letexp ?attrib bound_vars in_body =
      fix (Let { attrib; bound_vars; in_body })

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
    | Lambda (a, b) -> fbind a b
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
      | Let { bound_vars; in_body } ->
          let bindees =
            List.fold_left VarSet.union VarSet.empty (List.map snd bound_vars)
          in
          let bound_vars = List.map fst bound_vars in
          VarSet.union bindees
            (VarSet.diff in_body (VarSet.add_list VarSet.empty bound_vars))
      | Lambda { bound_vars; in_body } ->
          VarSet.diff in_body (VarSet.add_list VarSet.empty bound_vars)
      | o -> fold (fun acc a -> VarSet.union a acc) VarSet.empty o
    in
    cata alg e

  let free_vars_iter (e : t) = free_vars e |> VarSet.to_iter

  (* substite variables for expressions *)
  let substitute (sub : var -> t option) (e : t) =
    let open AbstractExpr in
    let rec subst bound orig =
      let exp = unfix orig in
      match exp with
      | RVar { id } when VarSet.find_opt id bound |> Option.is_none -> (
          match sub id with Some r -> r | None -> orig)
      | Lambda { op; bound_vars; in_body; attrib } ->
          (* exprs to bind are evaluated outside the bound *)
          let bound = VarSet.add_list bound bound_vars in
          let in_body = subst bound in_body in
          fix (Lambda { op; bound_vars; in_body; attrib })
      | Let { bound_vars; in_body; attrib } ->
          (* exprs to bind are evaluated outside the bound *)
          let bound = VarSet.add_list bound (List.map fst bound_vars) in
          let in_body = subst bound in_body in
          fix (Let { bound_vars; in_body; attrib })
      | o -> fix @@ AbstractExpr.map (subst bound) o
    in
    subst VarSet.empty e

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

  let unfix2 e = AbstractExpr.map unfix (unfix e)
  let unfix3 e = AbstractExpr.map unfix2 (unfix e)

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

  module FoldN = struct
    (** module defining set of algebras for folding n layers of the expression
        at a time, exposing more context (where n is 1-5)

        This is achieved by the record which tracks both the value at each
        level, and the values for all subexpressions of that level.

        This is a pain to pattern match on, and quite expensive, so unclear if a
        great idea.

        . *)

    type ('a, 'e) t = { this : 'a option; inner : 'e abstract_expr option }
    type 'a t1 = ('a, 'a) t
    type 'a t2 = ('a, 'a t1) t
    type 'a t3 = ('a, 'a t2) t
    type 'a t4 = ('a, 'a t3) t
    type 'a t5 = ('a, 'a t4) t

    let map_inner f (e : ('a, 'b) t) =
      { e with inner = Option.map (AbstractExpr.map f) e.inner }

    let flatten1 (e : 'a t2) : 'a t1 =
      let exception Failed in
      try
        let ne =
          map_inner (function { this = Some e } -> e | _ -> raise Failed) e
        in
        { this = e.this; inner = ne.inner }
      with Failed -> { this = e.this; inner = None }

    let get e =
      e.this |> Option.get_exn_or "accumulator undefined at this level"

    let get_opt e = e.this
    let is_def e = Option.is_some e.this
    let mk_undef e = { this = None; inner = e }

    let drop_1 e : 'a t1 =
      { this = None; inner = Some (AbstractExpr.map get e) }

    let lift_1 n e : 'a t1 =
      { this = None; inner = Some (AbstractExpr.map get e) }

    let lift_2 n e : 'a t2 =
      { this = Some n; inner = Some (AbstractExpr.map flatten1 e) }

    let drop_2 e : 'a t2 =
      { this = None; inner = Some (AbstractExpr.map flatten1 e) }

    let lift_3 n e : 'a t3 =
      { this = Some n; inner = Some (AbstractExpr.map (map_inner flatten1) e) }

    let drop_3 e : 'a t3 =
      { this = None; inner = Some (AbstractExpr.map (map_inner flatten1) e) }

    let drop_4 e : 'a t4 =
      {
        this = None;
        inner = Some (AbstractExpr.map (map_inner (map_inner flatten1)) e);
      }

    let lift_4 n e : 'a t4 =
      {
        this = Some n;
        inner = Some (AbstractExpr.map (map_inner (map_inner flatten1)) e);
      }

    let drop_5 e : 'a t4 =
      {
        this = None;
        inner =
          Some (AbstractExpr.map (map_inner (map_inner (map_inner flatten1))) e);
      }

    let lift_5 n e : 'a t4 =
      {
        this = Some n;
        inner =
          Some (AbstractExpr.map (map_inner (map_inner (map_inner flatten1))) e);
      }
  end

  (** pretty-print a let expression / definition *)
  let pretty_let ?attrib bound_vars in_expr =
    let open Containers_pp in
    let open FoldN in
    let open AbstractExpr in
    let attrib = Option.get_or ~default:(text "") attrib in
    let vs =
      bound_vars
      |> List.map (function
        | ( name,
            {
              inner =
                Some
                  (Lambda
                     {
                       attrib = lambda_attrib;
                       op = `Lambda;
                       bound_vars = inner_bound;
                       in_body = { this = Some in_body };
                     });
            } ) ->
            let binding =
              fill (text ", ")
                (List.map (fun v -> bracket "(" (Var.pretty v) ")") inner_bound)
            in
            let _, rtype = Types.uncurry (Var.typ name) in
            text (Var.name name)
            ^+ binding ^+ text ":"
            ^+ text (Types.to_string_rexp rtype)
            ^+ text "=" ^+ bracket "(" in_body ")"
        | name, { this = Some e } ->
            let rtype = Var.typ name in
            text (Var.name name)
            ^+ attrib ^+ text ":"
            ^+ text (Types.to_string_rexp rtype)
            ^+ text "=" ^ bracket "(" e ")"
        | _ -> failwith "undefined ")
    in
    let in_expr =
      match in_expr with
      | Some e -> text " in" ^+ bracket "(" e ")"
      | None -> text ""
    in
    text "let" ^+ append_l ~sep:(newline ^ text "and ") vs ^ in_expr

  let pretty_alg pattrib (expr : Containers_pp.t FoldN.t4 abstract_expr) :
      Containers_pp.t FoldN.t4 =
    let open AbstractExpr in
    let open Containers_pp in
    let open Containers_pp.Infix in
    let pass () : Containers_pp.t FoldN.t4 = FoldN.drop_4 expr in
    let return n = FoldN.lift_4 n expr in

    let a = AbstractExpr.get_attrib expr |> pattrib in
    match expr with
    | Let { attrib; in_body = { this = Some inner_exp }; bound_vars } ->
        return
        @@ pretty_let bound_vars ~attrib:(pattrib attrib) (Some inner_exp)
    | Lambda { attrib; op; in_body = { this = Some b }; bound_vars } ->
        let op = Ops.AllOps.to_string op in
        let sep = text "::" in
        let binding =
          fill (text " ")
            (List.map (fun v -> bracket "(" (Var.pretty v) ")") bound_vars)
          ^+ sep ^+ bracket "(" b ")"
        in
        return (text op ^ a ^ text " " ^ binding)
    | Lambda { bound_vars; in_body; attrib } -> pass ()
    | Let { bound_vars; in_body; attrib } -> pass ()
    | RVar { id; attrib } when Var.is_local id ->
        return (text (Var.to_string id) ^ a)
    | RVar { id; attrib } -> return (text (Var.name id) ^ a)
    | Constant { const } -> return (text (AllOps.to_string const) ^ a)
    | UnaryExpr { op = `ZeroExtend bits; arg = { this = Some arg } } ->
        return
          (fill
             (text "," ^ newline)
             [ text "zero_extend" ^ a ^ (textpf "(%d") bits; arg ^ text ")" ])
    | UnaryExpr { op = `SignExtend bits; arg = { this = Some arg } } ->
        return
          (fill
             (text "," ^ newline)
             [ text "sign_extend" ^ a ^ (textpf "(%d") bits; arg ^ text ")" ])
    | UnaryExpr { op = `Extract (hi, lo); arg = { this = Some e } } ->
        return
          (fill nil
             [ text "extract" ^ a ^ textpf "(%d,%d, " hi lo ^ e ^ text ")" ])
    | UnaryExpr { op = `ReadField field; arg = { this = Some arg } } ->
        return (arg ^ text "." ^ text field)
    | BinaryExpr
        {
          op = `WriteField field;
          arg1 = { this = Some r };
          arg2 = { this = Some vl };
        } ->
        return @@ r ^ text " with " ^ text field ^+ text "=" ^+ vl
    | UnaryExpr { op; arg = { this = Some e } } ->
        return (text (AllOps.to_string op) ^ a ^ bracket "(" e ")")
    | BinaryExpr
        {
          op = `Load (endian, bits);
          arg1 = { this = Some arg1 };
          arg2 = { this = Some arg2 };
        } ->
        return
          (let endian =
             text @@ match endian with `Big -> "be" | `Little -> "le"
           in
           fill
             (text "," ^ newline)
             [
               text "load_" ^ endian ^ a ^ (textpf "(%d") bits;
               arg1 ^ text ", " ^ arg2 ^ text ")";
             ])
    | BinaryExpr { op; arg1 = { this = Some e }; arg2 = { this = Some e2 } } ->
        return
          (fill nil
             [
               text (AllOps.to_string op)
               ^ a
               ^ bracket "(" (fill (text "," ^ newline) [ e; e2 ]) ")";
             ])
    | ApplyIntrin
        {
          op = `Cases;
          args =
            [
              {
                inner =
                  Some
                    (BinaryExpr
                       {
                         op = `IfThen;
                         arg1 = { this = Some cond };
                         arg2 = { this = Some thn };
                       });
              };
              { this = Some els };
            ];
        } ->
        return (text "if" ^+ cond ^+ text "then" ^+ thn ^+ text "else" ^+ els)
    | ApplyIntrin { op; args = es } when List.for_all FoldN.is_def es ->
        return
          (fill nil
             [
               text (AllOps.to_string op)
               ^ a
               ^ bracket "("
                   (fill (text "," ^ newline) (List.map FoldN.get es))
                   ")";
             ])
    | ApplyFun { func = { this = Some n }; args = es }
      when List.for_all FoldN.is_def es ->
        return
          (fill nil
             [
               bracket "(" n ")" ^ a
               ^ bracket "("
                   (nest 2 (fill (text "," ^ newline) (List.map FoldN.get es)))
                   ")";
             ])
    | _ ->
        (* undefined child: maybe a case up the tree can do something with this *)
        pass ()

  let pretty_drop_attrib s =
    cata (pretty_alg (fun x -> Containers_pp.text "")) s |> FoldN.get

  let pretty_attr =
    let open Containers_pp in
    function
    | Some (`Assoc e) ->
        let attrib =
          StringMap.filter (fun k v -> not @@ Attrib.is_internal_key k) e
        in
        if StringMap.is_empty attrib then text ""
        else text " " ^ Attrib.attrib_pretty pretty_drop_attrib (`Assoc attrib)
    | Some e -> text " " ^ Attrib.attrib_pretty pretty_drop_attrib e
    | None -> text ""

  let pretty s = cata (pretty_alg pretty_attr) s |> FoldN.get
  let to_string s = Containers_pp.Pretty.to_string ~width:80 (pretty s)
  let pp fmt s = Format.pp_print_string fmt @@ to_string s

  (** pretty print a single let definition *)
  let pretty_let_single name s body =
    pretty_let [ (name, cata (pretty_alg pretty_attr) s) ] body

  (** {1 Typing}*)

  type rewrite =
    | SomeInfo of { v : t; __LINE__ : int; __FILE__ : string }
    | Keep

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
    | Lambda { op; bound_vars; in_body = b } ->
        ret_type_lambda op (bound_vars |> List.map Var.typ) b |> get_ty
        (*Types.curry (List.map Var.typ bound_vars) b*)
    | Let { bound_vars; in_body } -> in_body

  let type_of e = cata type_alg e

  (** {1 Additional traversals}*)

  let idk alg = para alg
  let fold_with_type (alg : 'e abstract_expr -> 'a) = zygo_l ~cata type_alg alg
  let fold_with_type_r (alg : 'e abstract_expr -> 'a) = zygo ~cata type_alg alg

  type rwinfo = {
    from : t;
    into : t;
    __LINE__ : int option;
    __FILE__ : string option;
  }

  let show_rwinfo = function
    | { from; into } -> to_string from ^ " ~> " ^ to_string into

  open struct
    let log_rw visit ?__LINE__ ?__FILE__ o e =
      Option.iter
        (fun f ->
          let a = type_of o in
          let b = type_of e in
          if not @@ Types.equal a b then
            raise
              (Failure
                 ("ill-typed rewrite " ^ Types.to_string a ^ " ~> "
                ^ Types.to_string b ^ " "
                 ^ Option.get_or ~default:"" __FILE__
                 ^ ":" ^ Option.get_or ~default:""
                 @@ Option.map Int.to_string __LINE__));
          f { __LINE__; __FILE__; from = o; into = e })
        visit;
      e
  end

  (** substitute subexpression sbased on parameter *)
  let rewrite ?visit ~(rw_fun : t abstract_expr -> rewrite) (expr : t) =
    let rw_alg e =
      let orig s = fix s in
      match rw_fun e with
      | SomeInfo { v; __LINE__; __FILE__ } ->
          log_rw visit ~__LINE__ ~__FILE__ (fix e) v
      | None -> orig e
    in
    cata rw_alg expr

  (** substitute subexpression sbased on parameter *)
  let rewrite_down ?visit ~(rw_fun : t abstract_expr -> rewrite) (expr : t) =
    let rw_alg e =
      let orig s = fix s in
      match rw_fun e with
      | SomeInfo { v; __LINE__; __FILE__ }
        when Types.equal (type_of v) (type_of (orig e)) ->
          log_rw visit ~__LINE__ ~__FILE__ (fix e) v
      | SomeInfo { v; __LINE__; __FILE__ } ->
          failwith
          @@ Printf.sprintf
               "improper rewrite type: attempt to rewrite %s into %s"
               (to_string (orig e))
               (to_string v)
      | Keep -> orig e
    in
    rw_recurse_down ~f:rw_alg expr

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

  let[@inline] replace (here : Lexing.position) v =
    SomeInfo { v; __LINE__ = here.pos_lnum; __FILE__ = here.pos_fname }

  let replace_opt = function
    | Some v -> SomeInfo { v; __LINE__; __FILE__ }
    | None -> Keep
  [@@inline always]

  (** typed rewriter that expands two layers deep into the expression *)
  let rewrite_typed_two ?visit
      (f : (t abstract_expr * Types.t) abstract_expr -> rewrite) (expr : t) =
    let rw_alg e =
      let unfold = AbstractExpr.map (fun (e, t) -> (unfix e, t)) e in
      let orig s = fix @@ AbstractExpr.map fst s in
      match f unfold with
      (*| Some n ->
         Option.iter
            (fun f ->
              f { from = orig e; into = n; __LINE__ = None; __FILE__ = None })
            visit;
          n *)
      | SomeInfo { v; __LINE__; __FILE__ } ->
          log_rw visit ~__LINE__ ~__FILE__ (orig e) v
      | Keep -> orig e
    in
    fold_with_type rw_alg expr

  (** {1 Smart Constructors} *)

  include R.Constructors

  let binexp ?attrib ~op arg1 arg2 =
    match op with
    | #Ops.AllOps.intrin as op -> applyintrin ?attrib ~op [ arg1; arg2 ]
    | #Ops.AllOps.binary as op -> binexp ?attrib ~op arg1 arg2

  let zero_extend ?attrib ~n_prefix_bits (e : t) : t =
    unexp ?attrib ~op:(`ZeroExtend n_prefix_bits) e

  let field_store ?attrib ~(field : string) (record : t) (e : t) : t =
    binexp ?attrib ~op:(`WriteField field) record e

  let field_read ?attrib ~(field : string) (record : t) : t =
    unexp ?attrib ~op:(`ReadField field) record

  let sign_extend ?attrib ~n_prefix_bits (e : t) : t =
    unexp ?attrib ~op:(`SignExtend n_prefix_bits) e

  let load ?attrib ~bits endian (m : t) (ind : t) : t =
    binexp ?attrib ~op:(`Load (endian, bits)) m ind

  let extract ?attrib ~hi_excl ~lo_incl (e : t) : t =
    unexp ?attrib ~op:(`Extract (hi_excl, lo_incl)) e

  let concat ?attrib (e : t) (f : t) : t =
    applyintrin ?attrib ~op:`BVConcat [ e; f ]

  let ifthenelse ?attrib cond t e =
    applyintrin ~op:`Cases [ binexp ~op:`IfThen cond t; e ]

  let concatl ?attrib (e : t list) : t = applyintrin ?attrib ~op:`BVConcat e
  let forall ?attrib ~bound p = binding ?attrib ~op:`Forall bound p
  let exists ?attrib ~bound p = binding ?attrib ~op:`Exists bound p
  let lambda ?attrib ~bound p = binding ?attrib ~op:`Lambda bound p
  let boolnot ?attrib e = unexp ?attrib ~op:`BoolNOT e
  let intconst ?attrib (v : PrimInt.t) : t = const ?attrib (`Integer v)
  let boolconst ?attrib (v : bool) : t = const ?attrib (`Bool v)
  let bvconst ?attrib (v : Bitvec.t) : t = const ?attrib (`Bitvector v)

  let bv_of_int ~(size : int) (v : int) : t =
    const (`Bitvector (Bitvec.of_int ~size v))

  let drop_attrib a =
    let a =
      rewrite ~rw_fun:(AbstractExpr.drop_attrib %> fix %> replace [%here]) a
    in
    a

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

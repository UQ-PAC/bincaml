open Common
open Containers
open Ops
include Abstract_expr

module BasilExpr = struct
  type const = Ops.AllOps.const
  type unary = Ops.AllOps.unary
  type binary = Ops.AllOps.binary
  type intrin = Ops.AllOps.intrin
  type var = Var.t

  let hash_const = function
    | `Bitvector b -> Hash.combine2 2 (Bitvec.hash b)
    | `Boolean b -> Hash.combine2 3 (if b then 11 else 13)

  let top_typ = Types.Nothing

  module Var = Var
  open Ops.AllOps

  (** Fixed type of basil expressions: an expression of type {!t} whose
      subexpressions are also expressions of type {!t} *)
  type t =
    | E of (const, Var.t, unary, binary, intrin, Types.t, t) AbstractExpr.t
  [@@unboxed] [@@deriving eq, ord]

  type typ = Types.t

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
      type typ = Types.t

      module Var = Var

      let fix i = fix i
      let unfix i = unfix i
      let top_typ = Types.Top
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

    let map f e = { e with this = f e.this }
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

  let pretty_alg ?(type_annot = false) pattrib
      (expr : Containers_pp.t FoldN.t4 abstract_expr) : Containers_pp.t FoldN.t4
      =
    let open AbstractExpr in
    let open Containers_pp in
    let open Containers_pp.Infix in
    let pass () : Containers_pp.t FoldN.t4 = FoldN.drop_4 expr in
    let return n = FoldN.lift_4 n expr in

    let a = AbstractExpr.get_attrib expr |> pattrib in
    let e =
      match expr with
      | Let { attrib; in_body = { this = Some inner_exp }; bound_vars } ->
          return
          @@ pretty_let bound_vars ~attrib:(pattrib attrib) (Some inner_exp)
      | Lambda { attrib; op; in_body = { this = Some b }; bound_vars; triggers }
        ->
          let op = Ops.AllOps.to_string op in
          let sep = text "::" in
          let triggers =
            if List.is_empty triggers then text ""
            else
              bracket " { .triggers = ["
                (append_sp
                @@ List.map
                     (fun t ->
                       bracket "["
                         (append_l ~sep:(text ", ") (List.map FoldN.get t))
                         "]")
                     triggers)
                "]}"
          in
          let binding =
            fill (text " ")
              (List.map (fun v -> bracket "(" (Var.pretty v) ")") bound_vars)
            ^+ sep ^+ bracket "(" b ")"
          in
          return (text op ^ triggers ^ a ^ text " " ^ binding)
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
      | BinaryExpr { op; arg1 = { this = Some e }; arg2 = { this = Some e2 } }
        ->
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
                     (nest 2
                        (fill (text "," ^ newline) (List.map FoldN.get es)))
                     ")";
               ])
      | _ ->
          (* undefined child: maybe a case up the tree can do something with this *)
          pass ()
    in
    if not type_annot then e
    else
      FoldN.map
        (function
          | Some e ->
              Some
                (e ^ text ":"
                ^+ text (Types.to_string @@ AbstractExpr.get_typ expr))
          | None -> None)
        e

  let pretty_drop_attrib s =
    cata (pretty_alg (fun x -> Containers_pp.text "")) s |> FoldN.get

  let pretty_attr =
    let open Containers_pp in
    function
    | e when StringMap.is_empty e -> text ""
    | e ->
        let attrib =
          StringMap.filter (fun k v -> not @@ Attrib.is_internal_key k) e
        in
        if StringMap.is_empty attrib then text ""
        else text " " ^ Attrib.attrib_pretty (`Assoc attrib)

  let pretty s = cata (pretty_alg ~type_annot:false pretty_attr) s |> FoldN.get

  let pretty_a ?(type_annot = false) s =
    cata (pretty_alg ~type_annot pretty_attr) s |> FoldN.get

  let to_string s = Containers_pp.Pretty.to_string ~width:80 (pretty s)

  let to_string_annot s =
    Containers_pp.Pretty.to_string ~width:80 (pretty_a ~type_annot:true s)

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

  let elabourate_typ e =
    fold_with_type
      (fun t ->
        let typ = type_alg (AbstractExpr.map snd t) in
        fix (AbstractExpr.set_typ (AbstractExpr.map fst t) typ))
      e

  let rec fixup_typ (eo : t) : t =
    let get_typ (e : t abstract_expr) =
      AbstractExpr.(
        match e with
        | Constant { const = `Bitvector i } -> Types.Bitvector (Bitvec.size i)
        | Constant { const = `Bool _ } -> Types.Boolean
        | Constant { const = `Integer _ } -> Types.Integer
        | RVar { id } -> Var.typ id
        | e -> AbstractExpr.get_typ e)
    in

    let e = unfix eo in
    let et : t abstract_expr =
      match get_typ e with
      | Types.Top ->
          let ne = AbstractExpr.map fixup_typ e in
          let t = AbstractExpr.map (unfix %> get_typ) ne in
          let t = try type_alg t with _ -> Top in
          AbstractExpr.set_typ ne t
      | t -> AbstractExpr.set_typ e t
    in
    fix et

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
      | Keep -> orig e
    in
    cata rw_alg expr

  (** substitute subexpression sbased on parameter *)
  let rewrite_checktype ?visit ~(rw_fun : t abstract_expr -> rewrite) (expr : t) =
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

  let rec hash e : int =
    match e with
    | E e ->
        let h = Hash.poly in
        AbstractExpr.hash h Var.hash h h h Hashtbl.hash hash e

  let rec equal (i : t) (j : t) : bool =
    match (i, j) with
    | E i', E j' ->
        let e =
          AbstractExpr.equal equal_const Var.equal equal_unary equal_binary
            equal_intrin Types.equal equal i' j'
        in
        e

  (** {1 Smart Constructors} *)

  open R.Constructors

  let binexp ?attrib ~op arg1 arg2 =
    (match op with
      | #Ops.AllOps.intrin as op -> applyintrin ?attrib ~op [ arg1; arg2 ]
      | #Ops.AllOps.binary as op -> binexp ?attrib ~op arg1 arg2)
    |> fixup_typ

  let unexp ?attrib ?typ ~op arg = unexp ?attrib ?typ ~op arg |> fixup_typ

  let apply_fun ?attrib ?typ ~func args =
    apply_fun ?attrib ?typ ~func args |> fixup_typ

  let letexp ?attrib ?typ bound_vars in_body =
    letexp ?attrib ?typ bound_vars in_body |> fixup_typ

  let zero_extend ?attrib ~n_prefix_bits (e : t) : t =
    unexp ?attrib ~op:(`ZeroExtend n_prefix_bits) e |> fixup_typ

  let field_store ?attrib ~(field : string) (record : t) (e : t) : t =
    binexp ?attrib ~op:(`WriteField field) record e |> fixup_typ

  let field_read ?attrib ~(field : string) (record : t) : t =
    unexp ?attrib ~op:(`ReadField field) record |> fixup_typ

  let sign_extend ?attrib ~n_prefix_bits (e : t) : t =
    unexp ?attrib ~op:(`SignExtend n_prefix_bits) e |> fixup_typ

  let load ?attrib ~bits endian (m : t) (ind : t) : t =
    binexp ?attrib ~op:(`Load (endian, bits)) m ind |> fixup_typ

  let extract ?attrib ~hi_excl ~lo_incl (e : t) : t =
    unexp ?attrib ~op:(`Extract (hi_excl, lo_incl)) e |> fixup_typ

  let concat ?attrib (e : t) (f : t) : t =
    applyintrin ?attrib ~op:`BVConcat [ e; f ] |> fixup_typ

  let ifthenelse ?attrib cond t e =
    applyintrin ~op:`Cases [ binexp ~op:`IfThen cond t; e ] |> fixup_typ

  let concatl ?attrib (e : t list) : t =
    applyintrin ?attrib ~op:`BVConcat e |> fixup_typ

  let forall ?attrib ?triggers ~bound p =
    lambda ?triggers ?attrib ~op:`Forall bound p |> fixup_typ

  let exists ?attrib ?triggers ~bound p =
    lambda ?triggers ?attrib ~op:`Exists bound p |> fixup_typ

  let lambda ?attrib ?triggers ~bound p =
    lambda ?triggers ?attrib ~op:`Lambda bound p |> fixup_typ

  let boolnot ?attrib e = unexp ?attrib ~op:`BoolNOT e |> fixup_typ

  let intconst ?attrib (v : PrimInt.t) : t =
    const ?attrib ~typ:Integer (`Integer v) |> fixup_typ

  let boolconst ?attrib (v : bool) : t =
    const ?attrib ~typ:Boolean (`Bool v) |> fixup_typ

  let bvconst ?attrib (v : Bitvec.t) : t =
    const ?attrib ~typ:(Bitvector (Bitvec.size v)) (`Bitvector v)

  let rvar ?attrib v = rvar ?attrib ~typ:(Var.typ v) v

  let bv_of_int ~(size : int) (v : int) : t =
    const (`Bitvector (Bitvec.of_int ~size v)) ~typ:(Bitvector size)

  let const ?attrib ?typ v = const ?attrib ?typ v |> fixup_typ
  let fapply ?attrib ?typ func args = fapply ?attrib ?typ func args |> fixup_typ

  let applyintrin ?attrib ?typ ~op args =
    applyintrin ?attrib ?typ ~op args |> fixup_typ

  let drop_attrib a =
    let a =
      rewrite ~rw_fun:(AbstractExpr.drop_attrib %> fix %> replace [%here]) a
    in
    a

  let show_abstract pp_e e =
    AbstractExpr.show Ops.AllOps.pp_const Var.pp Ops.AllOps.pp_unary
      Ops.AllOps.pp_binary Ops.AllOps.pp_intrin Types.pp pp_e e
end

module HashExprFix = struct
  open BasilExpr
  include AllOps
  module Var = Var

  type nonrec 'e abstract_expr = 'e abstract_expr
  type var = Var.t
  type 'a cell = 'a Fix.HashCons.cell

  let equal_cell _ a b = Fix.HashCons.equal a b
  let compare_cell _ a b = Fix.HashCons.compare a b

  type t = expr_node_v cell

  and expr_node_v =
    | E of (const, Var.t, unary, binary, intrin, Types.t, t) AbstractExpr.t
  [@@deriving eq, ord]

  module HashExpr = struct
    type t = expr_node_v

    let hash e : int =
      match e with
      | E e ->
          let e = AbstractExpr.drop_attrib e in
          let h = Hash.poly in
          AbstractExpr.hash h Var.hash h h h Hashtbl.hash Fix.HashCons.hash e

    let equal (i : t) (j : t) : bool =
      match (i, j) with
      | E i', E j' ->
          AbstractExpr.equal equal_const Var.equal equal_unary equal_binary
            equal_intrin Types.equal Fix.HashCons.equal
            (AbstractExpr.drop_attrib i')
            (AbstractExpr.drop_attrib j')
  end

  type typ = Types.t

  let top_typ = Types.Top

  module H = Fix.HashCons.ForHashedType (HashExpr)

  let fix i = H.make (E i)
  let unfix i = match Fix.HashCons.data i with E i -> i
end

module ExprHashCons = struct
  include HashExprFix
  include Make (HashExprFix)

  let of_expr e =
    let alg e = fix (AbstractExpr.drop_attrib e) in
    BasilExpr.cata alg e

  let show_dbg (e : t) =
    let i = Fix.HashCons.id e in
    let h = Fix.HashCons.hash e in
    let ihash = Hashtbl.hash e in
    let full =
      unfix e
      |> BasilExpr.show_abstract (fun f e ->
          Format.fprintf f "%d" @@ Fix.HashCons.id e)
    in
    let t = cata BasilExpr.fix e |> BasilExpr.to_string_annot in
    Printf.sprintf "%d:%d:%d=%s==%s" i h ihash t full

  (*

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

module IVarFix = struct
  include AllOps

  module Var = struct
    include Int

    let show v = Int.to_string v
  end

  type var = Int.t

  type t = expr_node_v

  and expr_node_v =
    | E of (const, Int.t, unary, binary, intrin, Types.t, t) AbstractExpr.t
  [@@unboxed] [@@deriving eq, ord]

  type typ = Types.t

  let top_typ = Types.Top
  let fix i = E i
  let unfix i = match i with E i -> i
end

module ExprIntVar = Make (IVarFix)

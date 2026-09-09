(** Simple hindley-milner type inference *)

(** Union-find-based implementation of Hindley-Milner type inference for
    type-annotating the AST, without let-generalisation at the moment.

    This is based on Algorithm J described in Milner, 1978;
    {:https://doi.org/10.1016%2F0022-0000%2878%2990014-4}.

    The following may be more accessible:

    - {:https://en.wikipedia.org/wiki/Hindley%E2%80%93Milner_type_system#Algorithm_J}
    - {:https://bernsteinbear.com/blog/type-inference/} *)

module TypeExpr = TypeExpr
(** {1 Type Expressions}

    Bincaml's AST is generic in the type annotation expression.

    The type system that is embedded in the concrete expression type we use is
    defined in {! Common.Types}.

    This is the type loaded by the frontend, and attached to variables, and
    expressions, and which all prettyprinters assume.

    The underlying expression type though, {! Expr.AbstractExpr.t} is generic in
    the type.

    To perform type inference we lift the bincaml type to a minimal
    representation, and create expressions annotated with this type expression.

    Once inference has finished, we extract again expressions typed with the
    bincaml type.

    The HM type is simple, it is either

    - a type variable
    - a type constructor of the form [(type list, constr. name)]

    {[
    type 'a expr = Var of tvar | TypeConstr of 'a list * string
    ]}

    This type is open recursive so we can traverse it using the
    {! Bincaml_util.Recursionscheme} module.

    This type is hash-consed so we can retrieve a canonical reference for each
    corresponding bincaml type.

    This type is placed in a union-find datastructre in order to perform type
    unification. *)

(** {1 Type Inference}

    Type inference is split into two phases, inference and elaboration.
    Inference determines the type for each expression in the program, raising
    type errors when conflicts arise. Elaboration anotates the program with
    these expressions.

    {2 Inference} *)

module Hm_types = Hm_types
(** Conversions to/form HM state and bincaml types *)

module Unification = Unification
module Inference = Inference

(** Traversal of expressions to infer types

    We traverse the bincaml AST and construct a {! TypeExpr.t} for the type of
    each expression, and perform unification to determine what the type is.

    Bincaml has some specific concerns: for its type system:

    {3 Ad-hoc polymorpic operators}

    Our operators are ad-hoc polymorphic. Polymorphism in HM is represented with
    type schemes. A type-scheme in HM is a non-recursive universal quantifier
    over type variables.

    {[
    type scheme = Forall of tvar list * t
    ]}

    We represent our ad-hoc polymorphic operators by immediately generalising
    them, returning a type scheme for a generic function type. For instance for
    [bvadd] we know all the widths have to be equal, so the type scheme is

    [bvadd :: Forall i : Bitvector i -> Bitvector i -> Bitvector i] *)

module Solve_bv = Solve_bv

(** {3 Parametric Bitvectors}

    For cases like [bvadd], it is enough that one of their arguments (or return)
    be type annotated in order to infer concrete types for all type variables in
    the type scheme.

    However some operations, such as concatenation, are typed depending on
    arithmetic over the width values of the arguments passed to them.

    We define the type constructor ℕ to represent numeric types, we interpret it
    as a number when its argument is a type constructor which is the string
    representation of a number. E.g. the type "5 ℕ" represents the number 5.

    The [bv] bitvector type is parametric in its width, i.e [bv5] is defined as;

    {[
    TypeConstr ([5 ℕ, "bv")
    ]}

    When we do not know the exact width we use a type variable, and rely on
    unification, and a width-solving post-pass to determine the precise type.

    If there is not enough information to determine a concrete width, extraction
    to a bincaml type will fail with a type error.

    In order to solve for widths, we represent width-dependent operations as a a
    pair of a type scheme and type constraint. E.g. for [concat] this type
    constraint is of the form

    {[
    (* scheme *)
    concat :: Forall a  b  c : Bitvector a -> Bitvector b -> Bitvector c

    (* constraint *)
    Add { a ; b; equ=c }  (** a + b = c *)
    ]}

    These constraints are collected, and solved iteratively after the inference
    pass has run. This proces is naive and exponential in the number of
    deductive steps it has to make. *)

module Elaboration = Elaboration
(** {2 Elaboration}

    As the inference returns a version of the program typed with the HM
    [TypeExpr]s, the elaboration amounts to a traversal of the program which
    constructs bincaml-typed representations of these structures.

    This module implements both inference and elaboratino for the high-level
    program structures as this simplifies book-keeping of types. *)

open Common
open Abstract_expr

(** Convenience module including all HM submodules. *)
module Everything = struct
  include Hm_types
  (** @closed *)

  include Unification
  (** @closed *)

  include Inference
  (** @closed *)

  include Solve_bv
  (** @closed *)

  include Elaboration
  (** @closed *)
end

(** {2 Union-find / hash-cons state} *)

include TypeExpr.State
(** @inline *)

(** {1 High-level type-inference operations} *)

(*
   TODO:

 In order to  maintain well-typedness of rewrites we will probably want to
 inject the  global type definitions into the program, always. Otherwise we
 probably risk inferring inconsistent types. Maybe this goes for for all the
 global bindings. I.e. if we use a definition incorrectly it will end up
 ill-typed and that error will be harder to track down. Injecting all the
 bindings is somewhat giving up though.

 We could justifiably just require
 transforms to "know what they are doing" and inject enough type information for
 it to be well-typed coming out.  Mistakes could be found by running a global
 program typecheck after the transform. *)

(** Algebra that infers types of expressions in a fresh local context, assuming
    all free variables are defined and annotated. *)
let locally_elaborate_expr (e : Expr.BasilExpr.t) =
  let open AbstractExpr in
  let open Ops.AllOps in
  let st = create_state () in
  let constraints = ref [] in
  let univ = "<expr local>" in
  let ctx =
    Expr.BasilExpr.free_vars_iter e
    |> Iter.fold (Unification.decl_var_typ st univ) TypeExpr.TCtx.empty
  in
  let visit_constraint c = constraints := c :: !constraints in
  (* TODO: need mode where we absorb take the existing annotations and try to
  extend , rather than expecting everythign declared in context. *)
  let i = Inference.infer_expr st visit_constraint ~univ [%here] e ctx in
  let _ = Solve_bv.solve_constraints st ~max_iters:100 !constraints in
  let e = Elaboration.elaborate_expr st ~univ [%here] i ctx in
  e

(** Algebra for returning the annotated type (for use with functions like
    fold_with_type)*)
let elaborated_type_alg (e : Types.t Expr.BasilExpr.abstract_expr) =
  Expr.AbstractExpr.get_typ e

(** Partially apply args list to function type funtype and return resulting type
*)
let type_applied (funtype : Types.t) (args : Types.t list) =
  let st = create_state () in
  let rt = Inference.fresh_tvar st ~n:"ret" () in
  let args = List.map (Hm_types.ty_of_basil st) args in

  let funt = Hm_types.curry_f st args rt in
  let ft = Hm_types.ty_of_basil st funtype in
  Errors.to_result @@ fun () ->
  Unification.unify st ~pos:[%here] ft funt |> ignore;
  Hm_types.to_basil rt

(** Apply type inference to a program and return a fully type-annotated copy of
    the program. *)
let elaborate_prog prog =
  (* We need to create a local typing module in order to get fresh state for the
  union find and hash cons. *)
  let st = create_state () in
  let scheme, prog = Elaboration.infer_program st prog in
  prog

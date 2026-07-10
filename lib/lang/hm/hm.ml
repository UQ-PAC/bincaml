(** Simple hindley-milner type inference *)

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

    [  type 'a expr =  Var of tvar  | TypeConstr of 'a list * string ]

    This type is open recursive so we can traverse it using the
    {! Bincaml_util.Recursionscheme} module.

    This type is hash-consed so we can retrieve a canonical reference for each
    corresponding bincaml type.

    This type is placed in a union-find datastructre in order to perform type
    unification. *)

module TypeExpr = TypeExpr

(** {1 Type Inference}

    Type inference is split into two phases, inference and elaboration.
    Inference determines the type for each expression in the program, raising
    type errors when conflicts arise. Elaboration anotates the program with
    these expressions.

    {2 Inference}

    We traverse the bincaml AST and construct a {! TypeExpr.t} for the type of
    each expression, and perform unification to determine what the type is.

    {3 Parametric Bitvectors}

    Bitvector types are parametric in their widths, technically some operations,
    such as concatenation, are typed depending on the arguments passed to them.
    For now our approach is to hope there is enogugh typing information to fully
    propagate concrete types.

    We define the types like "5" to represent the number 5. The "Bitvector" type
    is parametric in its width type, i.e [bv5] is defined as
    [TypeConstr ([TypeConstr ([],"5")], "bv")]. When we do not know the exact
    width we use a type variable, and rely on unification to determine the
    precise type. Our type constraints cannot fully represent our
    value-dependent bitvector widths, this will fail (emitting a type varable)
    unless there are sufficient type annotations.

    {3 Ad-hoc polymorpic operators}

    Bincaml has some specific concerns, namely our operators are ad-hoc
    polymorphic. For each op (e.g. bvadd)

    A type-scheme in HM is a non-recursive universal quantifier over type
    variables.

    [type scheme = Forall of tvar list * t]

    We represent our ad-hoc polymorphic operators by immediately generalising
    them, returning a type scheme for a generic function type. For instance for
    [bvadd] we know all the widths have to be equal, so the type scheme is

    [bvadd :: Forall i : Bitvector i -> Bitvector i -> Bitvector i]

    {2 Elaboration}

    As the inference returns a version of the program typed with the HM
    [TypeExpr]s, the elaboration amounts to a traversal of the program which
    constructs bincaml-typed representations of these structures. *)

module Inference = Inference

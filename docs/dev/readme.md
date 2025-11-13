

# Related Work

### IR

The exprssion ast consists of an open recursive ADT (for use with recursion
schemes) with generic variables, generic set primitive operations as a
polymorphic variant.

Polymorphic variants are powerful, as they allow structural extension of the IR
language, however lead to slightly unpredictable typechecking behaviour. Hence
for better ergonomics we restrict them to the set of operation tags in the IR.
Unfortunately this leads to 4 generic type parameters, respectively for the set
of constants, unary operators, binary operators, and nary operators. We hope
that as most code is written against the fixed-point type that has all these
instantiated it is not too much of a problem.

Structure

- [Recursion schemes in ocaml](https://icfp24.sigplan.org/details/ocaml-2024-papers/11/Recursion-schemes-in-OCaml-An-experience-report)
- [A guide to recursion schemes](https://yangzhixuan.github.io/pdf/fantastic-morphisms.pdf)
- [Code reuse through polymorphic variants](https://www.math.nagoya-u.ac.jp/~garrigue/papers/variant-reuse.pdf)
- [expr structrue in smtml](https://formalsec.github.io/smtml/smtml/Smtml/Eval/index.html#type-op_type)

Semantics

- [Viper IR for separation logic](https://github.com/viperproject/silver/blob/master/documentation/syntax/sil-syntax.txt)
  - [Experience report on viper development](https://link.springer.com/chapter/10.1007/978-3-031-98668-0_5)

### Binary Static Analysers

- [binsec/codex](https://github.com/codex-semantics-library/codex) (GPL)
  - Contains many useful domains
  - Binsec/Codex paper artifact, minimal impelemntatino "TAI": https://zenodo.org/records/10895582
  - An interesting aspect is the use of hash-consed patricia trees (tries) and global value numbering for
  efficient map merging resulting in [this
  library](https://ocaml.org/p/patricia-tree/), Endianneses of the key is
  important for efficiency here, though there is a trie  in ccube/containers
  that would be easier to use I am unsure how the endianness works out.
- [why3 inference](https://gitlab.inria.fr/why3/why3/-/tree/master/src/infer?ref_type=heads) (GPL)

OCaml engineering

- Some gospel-verified ocaml algorithms:
  - [cameleer/examples](https://github.com/ocaml-gospel/cameleer/tree/master/examples)
  - [vocal](https://github.com/ocaml-gospel/vocal/tree/main)
  - There are useful things like queues and union-find, which have been used in other tools, this provides
    at least some argument for a minimal trust base. E.g. [pqueue usedin in miou scheduler](https://github.com/robur-coop/miou/blob/main/lib/miou_pqueue.ml)
- [What is CPS (discuss)](https://discuss.ocaml.org/t/what-is-the-use-of-continuation-passing-style-cps/4491/11)
- [Optimising state monad (discuss)](https://discuss.ocaml.org/t/can-a-state-monad-be-optimized-out-with-flambda/9841/5)

# TODO

To continue performing program analysis research on an ocaml-based platform
what will we absolutely need to implement as a foundation?

## Testing / Validation story

I want to leverage testing from the start much more than we did in sbasil, this
means constructing components independently with testable properties. I am
not a fan of TDD but maybe unit tests at some point.

- needs to be fast to run, and targeted at features
- needs to prevent regressions
- need to design so that its conducive to correctness properties; i.e. clear
abstract model of the program generally

#### Design requirements:

- clear input & output representation for components i.e. IL code gen and
consumption, good reserialisable human readable printed formats of data or
input
- test case generation (structured fuzzing)
- counterexample minimization
- regression testing framework
- probably some kind of equivalence checking of programs as early as possible;
interpreter, smt, etc

- consider using gospel framework to gradually verify modules, or provide more
powerful dynamic testing on top of regular tests
  - If we incrementally specify in gospel as documentation it can provide a path to extend, especially if we make specifications testable using ortac.
    - Consider integration of [ortac](https://github.com/ocaml-gospel/ortac) for more powerful property testing
  - Cameleer provides deductive verification of gospel specifications using
- Consider exploring ocaml's `afl-fuzz` support function fuzzing

- architect obasil so that components are independent, have independent correctness properties can be tested and verified independently and composed
  together

# Tasks

## Expression evaluator

Function to evaluate (and possibly partially evaluate /constant-fold) basil ir
expressions. Implementation should be straightforward based on prim.

#### Validation / Testing

- Property test output with smtlib:
  - depends: smtlib encoding of expressions
  - depends: expression generator


## SMT encoding of expressions

Implemenentation options:

- cvc5, z3 libraries
  - Probably avoid these initially cvc5 and z3 due to large compile time
  burden, though they would be the most efficient. CVC5 bindings generally seem
  more immature though.
- use containserlib sexpr to generate smtlib2 and subprocess
  - very flexible with regards to solver support
  - requires signficiant serlialisation and IO (IO can be mitigated by writing
  to a ramdisk and telling the solver to read from there)
  - limited to the solver features that are implemented in SMTLib2
- [smtml](https://formalsec.github.io/smtml/smtml/)
  - requires an smtlib library installed
  - supports multiple solvers if you install them
  - extra features like simplifying rewrite systems on solvers, good
  incremental api

#### Validation / Testing

- generate tautologies and check they are unsat?

## IR Well-formedness checks

- Implement a series of syntactic analysers to ensure the IR is a well-formed program

- There are no variables **read-before initialisation**; an easy forwards worklist analysis
- The IR is type-correct
- The formal and actual parameter lists match up across call and returns
- all branches are total and deterministic
- everything is declared before use
- reaching definitions analysis
- entry vert has no predecessors

## Value Analysis

A static analysis that assigns each variable an abstract value. For some
abstract domain. Ideally we want a precise domain for binaries like the reduced
product of known bits and interval.

Choose any single domain to start with. This item constitutes a single value
domain, maybe a lattice module type and a functor that produces an analysis.
I.e. to abstract over the ocamlgraph solver. Realistically we probably don't
initially need any structure.

- Use the fpottier/fix or ocamlgraph worklist worklist solver (ocamlgrpah
probably easier)
- known bits related work (GPL):
https://github.com/codex-semantics-library/codex/blob/main/domains/bitwise_domain.ml

#### Validation / Testing

- check the soundness property (`abstract \in concrete`) using the interpreter
for generated programs
  - depends: expression generator

## IDE Solver

We want an IDE solver more sophisticated than our current solver, i.e. to
simplify the discovery of dependencies and avoid the problems with backwards
analyses. As a starting point we could try just port sBASIL's ide solver. We
probably have the goal to eventually formalise and verify this in isabelle as a
research result, and can use this to experiment, or just delay it and code
extract the final solver.

- find an efficient encoding of microfunctions
- use ocamlgraph for phase 1 microfunction discovery ?
- use fpottier/fix as worklist algorithm to solve phase 2 ?

- implement a simple analysi

- See also:

## Program parser and serialiser

- Need to enable unit testing via parsing an ocaml string into a procedure
- want less magic when loading dsl than is present in sbasil
- Varying levels of completeness: e.g. including the attrib lists defining
memory initialisation for whole-program interpreter
- I would like to relax the restrictions on the IR regarding type annotation to
make it easier to write manually and include a basic type-propagation pass
- maybe going via an edsl is a good idea again

#### Validation / Testing

- serialise parse loop is the identity
  - requires deep-equality definition on programs
- IR well-formedness checks

## Interproc Linear-Expr propagation

- depends: IDE solver

- This is an efficient constant and copy-propagation simplifier, it is ideal
for simplifying pointer-arithmetic to facilitate stack use cleanup. It can also
be used to clean up abi constraints like call-preserved parameters by being
interprocedural; it is advantageous to do this with one general and efficient
analysis.
- uses the linear expression domain:

#### Validation / Testing

interpreter with refinement assertions OR interprocedural translation validator

- depends: whole-program interpreter

## Expression Generator

- utilise a property testing system to generate random expressions
- We have to be careful of partial functinos in the IR, and to generate
type-correct code: it would be useful therefore to have a typechecker.
  - depends: expression type-checker
  - depends: property testing framework

## Rewrite system

- It would be cool to port basil's expression rewriter as I am quite fond of
it, we can probably leverage hashconsing to memoise the rewriter here for
better efficiency too. BPaul also has a rewriter to simplify predicates


### Validation

- It would be interesting to pull an sexpr representation out of the basil IR
that can generate code, this would require quantifying out the runtime
conditions on bitvector widths to generate a version for each static set of
widths, I think that is an ok tradeoff.
- this sexpr can then generate ocaml code and isabelle theorems, or simply
smtlib queries to verify its correctness
- It would be cool to support the rewrite langauge in Ego. c.f.
https://github.com/agle/eggomess/blob/0bd8401aae7f0b362ac9c730c0f5f07930a60414/bin/main.ml#L482-L663

## SSA translation

- The ir embeds an SSA structure we need implemnent analyses
  1. To translate IR into the SSA structure
  2. To adapt DSA into SSA structure

## SSA-based analysis

- framwork for efficient fixedpoint analysis for SSA-based IR with a single state domain.

#### Validation / Testing

- check for violations using the reaching-definitions analysis
  - depends: reaching definitions analysis

## Loop Analysis

- Via linear congruence equality domain (Mine, etc.)
- interval analysis
- relational analysis with TIP

## Irreducible loop transform

- Check whether we can leverage existing loop algorithm in ocaml graph
- Reducible loops would be cool for tv

#### Validation / Testing

- whole program interpreter on irreducible programs
- unit tests: depends program parser serialiser

## Whole-program interpreter

- Want it to be reasonably fast for test efficiency: don't make it a monad again for performance
- If we want efficiency we could make all values a z.t and monomorphise operations to their width-specialisations, have the allocator bookkeep where pages are allocated.
- Structrue memory as a tree to pages of bytes, and flatten the bytes to bitvectors on load/store
- Try to make memory initialisation complete
- Provide debugging hooks somehow
- depends: expression evaluator

### Validation / Testing

The execution of csmith-generated programs matches the execution natively or in qemu (i.e. outputs the same hash)

## Translation validator

- Implementation of TACAS paper in ocaml, roughly this is decomposed into:

1. Cut set transform (may be able to use [ocamlgraph](https://ocaml.org/p/ocamlgraph/2.2.0/doc/ocamlgraph/Graph/Mincut/Make/index.html#val-min_cutset)
2. Monadic effect encoding
    - make the call encoding simpler, just capture all global variables in the program rather than doing some weird analysis
4. Invarinat construction based on an analysis result
5. SSA-based DAG program extration
    - emit src and target programs as a let .. in function rather than the encoding sbasil uses as its cleaner and more efficient

- We should extend it to interprocedural validation, this means guarding
ackermann instantiations by the interproc domain value, and adding the
interproc results to invariant at beginning and return cuts
- Should eventually include the smt incremental solver effect optimisation
- query simplification using a copyprop etc
- very rough reference implementation; https://github.com/ncough/tv-sanity

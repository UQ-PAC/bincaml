#import "style.typ": conf
#show: conf.with(title: "Implementation Notes for Wrapped Intervals in Bincaml")

#set document(author: "Hayden Brown", keywords: ("BASIL", "Bincaml", "Interval Analysis"))

#let wint = (l, u) => $paren.l.closed #l, #u paren.r.closed$
#let po = $subset.eq.sq$
#let ponot = $subset.eq.sq.not$
#let join = $attach(t: tilde.op, limits(union.sq))$
#let lub = $attach(t: tilde.op, limits(union.big.sq))$
#let meet = $attach(t: tilde.op, limits(inter.sq))$
#let glb = $attach(t: tilde.op, limits(inter.big.sq))$
#let None = $sans("None")$
#let Some = $sans("Some")$
#let nsplit = $sans("nsplit")$
#let ssplit = $sans("ssplit")$
#let cut = $sans("cut")$
#let np = $sans("np")$
#let sp = $sans("sp")$
#let umin = $sans("umin")$
#let umax = $sans("umax")$
#let smin = $sans("smin")$
#let smax = $sans("smax")$
#let pudiv = $attach(t: tilde.op, br: u, limits(div))$
#let psdiv = $attach(t: tilde.op, br: s, limits(div))$
#let wudiv = $div_w_u$
#let wsdiv = $div_w_s$
#let msb = $sans("msb")$
#let concat = $sans("concat")$
#let extract = $sans("extract")$
#let trunc = $sans("trunc")$

= Background

In low-level representations, values lose typing information and are simply treated as bitvectors.
These representations do not specify signedness as a property of a value, as we would in a high-level context,
but as part of the semantics of an operation.
When defining interval semantics for bitvectors, selecting between signed or unsigned semantics
will always result in a loss of precision when needing to interpret as the other signedness.

Wrapped intervals use a circular model of the integers to allow changing signedness depending on the context.
We divide the circle into two equal hemispheres, $wint(0^w, 01^(w-1))$ and $wint(10^(w-1), 1^w)$,
creating a north and south pole.

$ np = wint(01^(w-1), 10^(w-1)) #h(1cm) sp = wint(1^w, 0^w) $

By cutting the circle at the north pole and stretching it out into a line,
we are able to interpret our intervals as signed,
whilst making a cut at the south pole creates the unsigned number line.

Our lattice consists of the empty interval $bot$, the full interval $top$ and the delimited interval $wint(x, y)$.
To prevent having multiple representations for the full interval,
any delimited interval $wint(y +_w 1, y)$ is normalised to $top$.
For the partial order, $s po t$ if and only if $s$ is contained fully within $t$.

Delimited intervals are defined as containing all the values encountered when
moving clockwise on the circle from $x$ to $y$, including $x$ and $y$ themselves.
As such $wint(001, 011) != wint(011, 001)$, with $wint(001, 011)$ being the shorter path between the endpoints.

= Known Widths

#align(center, block(width: 60%, stroke: 1pt, inset: 1em, spacing: 2em)[
  #set par(justify: false)
  *NOTE*

  This section is now obsolete after merging #link("https://github.com/agle/bincaml/pull/26", "#26") which provides types to the `ValueAbstraction`
  and #link("https://github.com/agle/bincaml/pull/40", "#40") which uses these types instead of inference.
  However, we will keep it around for historical reference.
])

Multiple functions specified in the paper @navasSignednessAgnosticProgramAnalysis2012
rely on knowing the length of the bitvector being operated upon,
even if said bitvector has an abstract state of $top$ or $bot$.
Such functions include cardinality (written as $\#(top)$ and $\#wint(x, y)$)
and the operations which split an interval at either pole $nsplit(s)$ and $ssplit(s)$,
and their combined version $cut(s)$.

$ \#(top) = 2^w $
$ nsplit(top) = ssplit(top) = cut(top) = {wint(0^w, 01^(w-1)), wint(10^(w-1), 1^w)} $

Whilst these cases only require a known width when the provided input is $top$,
due to the existence of the complement operator, a width must be stored for $bot$ as well.
If $overline(top_w) = bot$ then applying the complement would cause us to lose information,
preventing us from satisfying the double negation law $overline(overline(top_w)) = top_w$.

We choose to represent this in OCaml using a record pairing the abstract interpretation with the bitwidth.
Even though it is redundant to store a bitwidth for the interval case, as this can be derived from the bitvectors,
we still store it to make pattern matching the elements of lattices nicer to read.

```ocaml
(* Objectively worse version *)
type t =
  | Top of int option
  | Interval of { lower : Bitvec.t; upper : Bitvec.t }
  | Bot of int option
```

```ocaml
(* Some redundant information, but easier to work with *)
type l = Top | Interval of { lower : Bitvec.t; upper : Bitvec.t } | Bot
type t = { w : int option; v : l }
```

As for prior art, the Crab static analysis library @seahornCrabLibraryBuilding implements this data structure
using two bitvectors of equal length and a boolean flag for the bottom case.
Top is represented by any interval where the cardinality is $2^w$ and `is_bottom == false`.
This approach works well for C++ with it's lack of tagged unions and pattern matching,
however, the version provided above is more natural for functional programming.

Operations such as the partial order $po$ and equality are defined on the lattice type `l`
and deferred to by the versions for `t` to satisfy the module definition.

== Propagation and Inference

The signature of `module Lattice` in Bincaml requires a constant `val bottom : t`
to initialise all variables with prior to determining fixpoints.
Since the width of the variable is not provided as an input, we fall back to `{ w = None; v = Bot }`.

Whilst most variables will have a known width as soon as they are assigned a constant or expression containing a constant,
it is still necessary to propagate width information to `Bot` and `Top` during analysis.
To ensure the precision of signedness-agnostic multiplication,
the $cut$ operation is used, which requires a known width if $s_v = top$.
A similar situation exists for the bitwise logic, extension, truncation and shifting operators,
which frequently use $nsplit$ and $ssplit$.

$sans("infer")(s, t)$ attempts to resolve the bitwidth using the width of another object.
This relies on the assumption that binary operations
will only be performed on bitvectors of the same length (enforced by the type checker).
Lattice operations such as join and widening operate on their inputs after inference.
This is also the case for the evaluation semantics of binary operations.

$
  sans("infer")(s, t) = cases(
    (s, t) & "if" s_w = t_w,
    ({Some w; s_v}, {Some w; t_v}) & "if" s_w = Some w or t_w = Some w,
    sans("fail") & "if" s_w = Some w_1 and t_w = Some w_2 and w_1 != w_2
  )
$

= Least Upper Bound

The join operation provided by the paper is imperfect.
It is not associative, nor monotone and biased towards a lexicographically smaller lower bound
when joining two disjoint intervals of equal size.
Due to the large impact application order has on precision when joining multiple intervals,
the paper provides an alternative join implementation $lub S$ for a set of intervals which exploits this bias.

The method consists of two iterations over a set of intervals sorted lexicographically by lower bound.
The first iteration finds the least upper bound of all intervals which cross the South Pole (where ${s in S | wint(1^w, 0^w) po s}$).
The second iteration finds the largest uncovered gap in $S$, the complement of which is the least upper bound of the set.

Figure 3 in the paper mentions an operation $sans("extend")(s, t)$ which is
"identical to $join$, except that the last cases are omitted".
The specific cases to eliminate are not mentioned and the Crab implementation does not bother implementing $lub$,
instead opting to left fold using $join$.
Due to this ambiguity and the fact that it does not break things whilst testing, we assume $sans("extend")(s, t) = s join t$.

A best guess to why this is mentioned is that the check for which interval has the lowest lower bound in the fifth case
is made redundant by sorting the set prior to iteration, and can be removed to reduce time spent computing conditions.

= Concat

The concat operation in Basil does not have an equivalent in the paper or Crab
and had to be derived from scratch, through much trial and error.
Even though the variant found in the IR takes multiple arguments,
we have presented the function as a binary operation for clarity.

$
  concat(s, t) = cases(
    bot & "if" s = bot or t = bot,
    wint(concat(a, 0^w), concat(b, 1^w)) & "if" s = wint(a, b) and sp po t,
    wint(concat(a, c), concat(b, d)) & "if" s = wint(a, b) and sp ponot t and t = wint(c, d),
    wint(concat(0^w, c), concat(1^w, d)) & "if" s = top and sp ponot t and t = wint(c, d),
    top & "otherwise"
  )
$

When $t$ crosses the south pole, it becomes possible for the values $concat(x, 0^(w_t))$ and $concat(x, 1^(w_t))$ (where $x in s$)
to exist in the interval $concat(s, t)$.
This explains why $wint(concat(a, min(c, d)), concat(b, max(c, d)))$ is insufficient, as when $sp po t$
we fail to include values in $wint(concat(a, 0^(w_t)), concat(a, min(c, d)))$ and $wint(concat(b, max(c, d)), concat(b, 1^(w_t)))$.

This is handled in the code by replacing `t` with `{ w = t.w; v = Top }` if it crosses the south pole
and using $s = wint(a, b) and t = top$ as the condition for the second case,
mostly so that everything can be done in a single pattern match without any nested ifs.

= Conditional Semantics

Conditional semantics allow us to refine our intervals based on assertions and assumptions in the program.
We choose to refine when the condition is a binary operation where at least one of the arguments is a variable.
The notation $rho_(s theta t) (s)$ to denotes the reduction of $s$ when $s theta t$ holds where $theta in {=, !=, <=, <, >, >=}$.

== Equalities and Inequalities

The equalities are trivially defined using meet and the complement.
The equivalent reduction for $t$ can be derived by the commutativity of $=$ and $!=$.

$ rho_(s = t) (s) = s meet t #h(1cm) rho_(s != t) (s) = s meet overline(t) $

For conditions involving inequalities, we require different variants for signed and unsigned.
We will only define the unsigned versions here as the signed versions can be derived by replacing
$umin$ and $umax$ with $smin$ and $smax$.

$
  rho_(s <= t) (s) = cases(
    bot & "if" t = bot,
    s & "if" umax in t,
    s meet wint(umin, b) & "if" t = wint(a, b)
  )
$

The second case is used to account for crossing the south pole;
if $umax in t$ then every value in $s$ is less than or equal to $t$.

$
  rho_(s < t) (s) = cases(
    bot & "if" t = bot,
    s meet wint(umin, umax - 1) & "if" umax in t,
    bot & "if" t = wint(a, b) and b = umin,
    s meet wint(umin, b - 1) & "if" t = wint(a, b) and b != umin
  )
$

For strictly less than, $umax$ will not ever be included in the reduced interval
as there is no value strictly greater than $umax$.
We factor this into the second branch to improve precision.
The third case handles the interval $wint(umin, umin)$ ($t$ is guaranteed not to cross the south pole),
where applying the final case would produce $top$ rather than reducing to the empty interval.

The reductions for $>=$ and $>$ are handled using similar principles:

#grid(
  columns: 2,
  align: horizon,
  column-gutter: 2em,
  $
    rho_(s >= t) (s) = cases(
      bot & "if" t = bot,
      s & "if" umin in t,
      s meet wint(a, umax) & "if" t = wint(a, b)
    )
  $,
  $
    rho_(s > t) (s) = cases(
      bot & "if" t = bot,
      s meet wint(umin + 1, umax) & "if" umin in t,
      bot & "if" t = wint(a, b) and a = umax,
      s meet wint(a + 1, umax) & "if" t = wint(a, b) and b != umax
    )
  $,
)

The reductions for $t$ can be found by flipping the inequality whilst preserving the strictness,
such that interval being reduced is on the left side of the condition.
This is why we choose to explicitly define $>=$ and $>$ even though they cannot be passed to `ValueAbstraction.eval_binop` and `Domain.transfer`.

$ rho_(s <= t) (t) = rho_(t >= s) (t) $

== Composition

Since `AND` and `OR` are intrinsics (can a variable number of arguments),
we need a precise way to find the greatest lower bound of a set of intervals.
By using $lub$ and the complement, we construct this operation via De Morgan's laws:

$ glb S = overline(lub { overline(s) | s in S }) $

For conjunction, for each variable refined we take the meet of their refinements:

$ rho_(P_1 and dots.c and P_n) (s) = glb { rho_(p) (s) | p in P } $

If the predicate $P_i$ cannot be used to refine $s$ then $rho_(P_i) (s) = s$.
This allows us to make the observation that since disjunction uses join,
it is only able to refine a variable if every predicate produces a strictly more precise result than $s$.
In the implementation, we use this to avoid computing the least upper bound for a variable
by checking if the number of reductions it appears in is equal to the number of predicates.
Given the runaway nature of join, we still need to incorporate our original information after the reduction
to ensure our result after reduction is at least as precise as before reduction.

$ rho_(P_1 or dots.c or P_n) (s) = s meet lub { rho_(p) (s) | p in P } $

If a predicate is surrounded by a `BoolNOT`, we use logical laws (mostly De Morgan's) to rearrange
so that the top-level expression is either a `BinaryExpr` or `ApplyIntrin`.

We directly define implies and its negations to avoid additional recursive calls for simplification.

$ rho_(P_1 ==> P_2) = rho_(not P_1 or P_2) #h(1cm) rho_(not (P_1 ==> P_2)) = rho_(P_1 and not P_2) $

== Limitations and Future Work

Currently, we are unable to propagate information back to variables used as sub-expressions of the arguments.
A common case is assertions of the form $s <= extract_(32, 0) (t)$.
Since $s$ is an `RVar` and $extract_(32, 0) (t)$ is a `UnaryExpr`, we are only able to perform reduction on $s$.

This could be resolved using techniques similar to section 4.6 of the Miné tutorial @mineTutorialStaticInference2017
by defining backward abstract evaluation functions.
These backwards operators take the original arguments and produce refined arguments based on the new information derived from the condition.
The advantage of this method is that we are able to also propagate the effect of assertions to variables
which are not directly contained in the assertion (neither argument is required to be `RVar`).

In our current implementation of this analysis, we operate on the control flow graph rather than the data flow graph,
as due to the DFG's structure, chaotic iteration will never call `transfer` on `assert`, `assume` or `guard` statements.
The alternative is to use Single Static Information (SSI) form @ananianStaticSingleInformation1999
to encode the reductions as new assignments which can be later unified with phi nodes.
This allows us to retain the performance benefits of using the DFG
whilst still being able to use the information in assertions for precision.

= Miscellanea

== Intersection Issue

The intersection/exact meet function in the paper is incorrectly specified.
The correct version was recovered from Crab and is supplied below.

$
  s inter t = cases(
    emptyset & "if" s = bot or t = bot,
    {t} & "if" s = t or s = top,
    {s} & "if" t = top,
    {wint(a, d), wint(c, b)} & "if" s = wint(a, b) and t = wint(c, d) and a in t and b in t and c in s and d in s,
    {s} & "if" s = wint(a, b) and t = wint(c, d) and a in t and b in t,
    {t} & "if" s = wint(a, b) and t = wint(c, d) and c in s and d in s,
    {wint(a, d)} & "if" s = wint(a, b) and t = wint(c, d) and a in t and d in s and b in.not t and c in.not s,
    {wint(c, b)} & "if" s = wint(a, b) and t = wint(c, d) and b in t and c in s and a in.not t and d in.not s,
    emptyset & "otherwise"
  )
$

== Signed Multiplication

In the conditions of signed multiplication, we check if the multiplication will produce an interval with a cardinality less than $2^w$.
However, the paper fails to account for this occurring when the interval increases counter-clockwise. Corrected version below.

$
  wint(a, b) times_s wint(c, d) = cases(
    wint(a times_w c, b times_w d) & "if" msb(a) = msb(b) = msb(c) = msb(d),
    & and -2^w < b times d - a times c < 2^w,
    wint(a times_w d, b times_w c) & "if" msb(a) = msb(b) = 1 and msb(c) = msb(d) = 0,
    & and -2^w < b times c - a times d < 2^w,
    wint(b times_w c, a times_w d) & "if" msb(a) = msb(b) = 0 and msb(c) = msb(d) = 1,
    & and -2^w < a times d - b times c < 2^w,
    top & "otherwise"
  )
$

== Division Semantics

Adapted from Crab since the original paper does not specify these.
In the Crab implementation, unsigned division uses $nsplit$ which is incorrect.
$ssplit$ should be used to interpret both intervals as unsigned.
This is likely a typo as $nsplit$ is named `signed_split` in the code, whilst $ssplit$ is named `unsigned_split`.

$
  sans("trim_zero")(s) = cases(
    emptyset & "if" s = bot,
    {wint(1, 1^w)} & "if" s = top,
    {wint(1, b)} & "if" s = wint(a, b) and a = 0,
    {wint(a, 1^w)} & "if" s = wint(a, b) and b = 0,
    {wint(a, 1^w), wint(1, b)} & "if" s = wint(a, b) and 0 in s,
    emptyset & "otherwise"
  )
$

$
  s pudiv t = cases(
    wint(a wudiv d, b wudiv c) & "if" s = wint(a, b) and t = wint(c, d),
    top & "otherwise"
  )
$

$
  wint(a, b) psdiv wint(c, d) = cases(
    wint(b wsdiv c, a wsdiv d) & "if" msb(a) = msb(c) = 1,
    & and (b != smin or c != -1) and (a != smin or d != -1),
    wint(a wsdiv d, b wsdiv c) & "if" msb(a) = msb(c) = 0,
    & and (a != smin or d != -1) and (b != smin or c != -1),
    wint(a wsdiv c, b wsdiv d) & "if" msb(a) = 1 and msb(c) = 0,
    & and (a != smin or c != -1) and (b != smin or d != -1),
    wint(b wsdiv d, a wsdiv c) & "if" msb(a) = 0 and msb(c) = 1,
    & and (b != smin or d != -1) and (a != smin or c != -1),
    top & "otherwise"
  )
$

$ s div_u t = lub { u pudiv w | u in nsplit(s), v in ssplit(t), w in sans("trim_zero")(v) } $
$ s div_s t = lub { u psdiv w | u in cut(s), v in cut(t), w in sans("trim_zero")(v) } $

== Logical Operations

The bitwise logical operations use the same trick as multiplication and division.
We split all intervals at the south pole to get unsigned intervals
and collect them using $lub$ after applying the unsigned version of the algorithm.
The algorithms presented in Chapter 4.3 of Hacker's Delight @warrenHackersDelight2013
have been adapted to work with tail recursion.

Crab does not implement these for some reason.

== Shifts

The definitions of shifting operations provided by the paper rely on a constant shift amount.
They also state that this can be extended to handle a variable shift amount
by computing for every value in the interval and taking the join of the results.

$ s #`<<` t = lub { s #`<<` k | k in t } $

Due to the sort in $lub$, this method has $O(n log n)$ time complexity where $n$ is the cardinality of $t$ (which could be at most $2^w$).
Since it would be computational costly to do otherwise, we only compute shifts for singleton intervals.
This method is also used by Crab.

$
  s #`<<` t = cases(
    s #`<<` k & "if" t = wint(k, k),
    top & "otherwise"
  )
$

A strategy that uses the cardinality as a threshold or clamping the interval to $t inter wint(0, w)$ was briefly considered.
However, these methods are not necessary as variable shifts do not occur particularly often in Basil IR after simplification.

== Extract

The extract operation in Basil is not provided by the paper,
but can be derived by combining $trunc_k (s)$ and logical right shift $#`>>l`$.
Zero-length extracts are special cased.
Truncate and extract take constant integer values for their indices
because doing this with an interval would be a nightmare.

$ extract_("hi", "lo") (s) = trunc_("hi" - "lo") (s #`>>l` "lo") "if" "hi" != "lo" $

#bibliography("wrapped-intervals.bib", title: "References", style: "ieee")

#import "@preview/lovelace:0.3.0": *

#import "style.typ": conf
#show: conf.with(title: "Reduced Product of Known Bits and Wrapped Intervals")
#set document(author: ("Hayden Brown", "Sneha Zazen"), keywords: ("BASIL", "Bincaml", "Reduced Product"))

#let wint = (l, u) => $paren.l.closed #l, #u paren.r.closed$
#let po = $subset.eq.sq$
#let ponot = $subset.eq.sq.not$
#let join = $union.sq$
#let meet = $inter.sq$
#let psmeet = $attach(t: tilde.op, limits(meet))$
#let pslub = $attach(t: tilde.op, limits(union.big.sq))$
#let concat = $sans("concat")$
#let extract = $sans("extract")$
#let ssplit = $sans("ssplit")$
#let tnum = $sans("tnum")$
#let lower = $sans("lower")$
#let upper = $sans("upper")$
#let sp = $sans("sp")$
#let smaller = $sans("smaller")$
#let swint = $sans("wint")$
#let into = $sans("into")$

= Introduction

Reduced product domains allow us to use information from differing representations to increase the precision of the other.
The wrapped interval domain works best for arithmetic operations,
whilst tristate numbers provide more detail for bitwise/logical operations.
For wrapped intervals, introducing information from the known bits analysis allows us to have gaps in our intervals,
which we can exploit to shorten their width.
For tristate numbers, wrapping intervals can be used to resolve unknown bits of high significance.

= Conversions

== Tristate Numbers to Wrapped Intervals

To ensure the soundness and precision of this conversion, the following rules must hold:

$ tnum[i] in {0, 1} ==> lower[i] = upper[i] = tnum[i] $
$ tnum[i] = mu ==> & lower[i] = 0 and upper[i] = 1 $

A conceptual method to ensure this holds is to convert each bit into a single bit wrapped interval,
and then concatenate those intervals together.

$ 0 mapsto wint(0, 0) quad 1 mapsto wint(1, 1) quad mu mapsto wint(0, 1) = top_1 $

$ 0 1 mu 1 mapsto concat(wint(0, 0), wint(1, 1), wint(0, 1), wint(1, 1)) = wint(0101, 0111) $

However, this method is inefficient since it needs to $sans("extract")$ each bit and then $concat$.
Instead, we can perform the mapping in constant time using bitwise operations on the value and mask.
We do this by redefining our rules on value and mask, we get the following:

$ m[i] = 0 ==> lower[i] = upper[i] = v[i] $
$ m[i] = 1 ==> lower[i] = 0 and upper[i] = 1 $

From here, we can use the specified function table to derive our bitwise operations.

$ {v; m} mapsto wint(v #`&` #`~`m, v #`|` m) $

== Wrapped Intervals to Tristate Numbers

When converting intervals, we must be careful of crossing the south pole $sp = wint(1^w, 0^w)$ as relying on only the bounds
obscures some possible values, similar to the $concat$ operation.

$ sp po wint(a, b) ==> wint(a, b) mapsto mu^w $

Based on similar principle, any bits after the first bit where the lower and upper bound must also be considered as unknown.
For example, a naive conversion of the interval $wint(001, 011)$ would produce $0 mu 1$.
However, this result would be considered unsound as the interval contains $010$ which is not included in $0 mu 1$.

For an interval which does not cross the south pole, we find $k$, the minimum number of required to represent $lower #`^` upper$.
This is performed with the ZArith library by using the `Z.numbits` function.
From here, we are able to construct the mask $0^(w-k)1^k$ using $k$ and the value $lower #`|` #`~`m$
(either $lower$ or $upper$ can be used, since the differing bits just get masked away).

```ocaml
(* Psuedocode for OCaml impl *)
let diff = Bitvec.bitxor lower upper in
let k = Z.numbits @@ Bitvec.to_unsigned_bigint diff in
let m = Bitvec.(concat (zero ~size:(w - k)) (ones ~size:k)) in
let v = Bitvec.(bitand lower @@ bitnot m) in
tnum v m
```

To finish off, the implementation of the known bits domain uses a lifted lattice
to account for the lack of width argument in `Lattice.bottom` and `ValueAbstraction.top`.
$top$ is handled by the current implementation since it crosses the south pole.
As for the empty interval $bot$, we simply map it to the bottom value of the known bits lattice.

= Reductions

== Meet Reduction

The reduction function $rho$ takes the pair of abstract representations and uses them to refine each other.

In the case of tristate numbers, we are able to use known bits in one result to determine the unknown bits of another.
We assume that given the soundness of the analyses and conversion functions,
known bits in the same position will not differ between arguments.
We are able to determine the meet using the following function:

$
  a meet b = cases(
    bot & "if" a_v #`&` #`~`a_m != b_v #`&` #`~`b_m,
    { v = (a_v #`|` b_v) #`&` #`~`m; space m = a_m #`&` b_m } & "otherwise"
  )
$

A similar trick can be used by taking the join of the intersection of two intervals.
This will not be the exact meet but rather a pseudo meet similar to the join on wrapped intervals.

$ s psmeet t = pslub s inter t $

Finally we can combine these for the reduction function:

$ rho((tnum, swint)) = (tnum meet into_tnum (swint), swint psmeet into_swint (tnum)) $

Whilst in most cases it is possible to apply the reduction function multiple times until a fixed point is reached,
due to the lack of guaranteed termination for join on wrapped intervals this will not work.
Using a widening operator for this process would be counterintuitive.

== Arthurian Reduction

Unlike tristate numbers, the meet $psmeet$ is not the most precise reduction for intervals.
For this, we adapt two algorithms from Alex Arthur's implementation of the known bits and unsigned interval reduced product.
This method uses a binary search on the unknown bits to truncate the bounds of the interval.

Since the algorithm uses unsigned comparisons, it does not work for wrapped intervals out of the box.
Instead we apply the $ssplit$ trick to operate on a set of unsigned intervals, of which we take the least upper bound $pslub$.
Arthur's algorithm for reducing the tristate number is equivalent to $tnum meet into_tnum (swint')$
where $swint'$ is $swint$ after reduction.

Below we show the imperative pseudocode of the interval reduction, with both bounds being computed simultaneously.
The implemented version involves recursion on a single bit mask and logical right shifting.

#figure(pseudocode-list[
  + *def* $rho_swint (swint, tnum)$
    + $wint(a, b), wint(b', a') <- swint, into_swint (tnum)$
    + *for* $i in [w - 1, 0]$
      + *if* $tnum[i] = mu$ *then*
        + $a'[i], b'[i] <- 0, 1$
        + *if* $a' < a$ *then* $a'[i] <- 1$ *endif*
        + *if* $b' > b$ *then* $b'[i] <- 0$ *endif*
      + *endif*
    + *endfor*
    + *return* $wint(a', b')$
])

Using this method, we derive the full reduction function:

$
  rho((tnum, swint)) = (tnum meet into_tnum (swint'), pslub {rho_swint (w, tnum) | w in ssplit(v), v in swint inter into_swint (tnum)})
$

== Coughlin Method

The method shown in this section is equivalent to the one described above,
but with the advantage of executing in constant time by using bitwise operations instead of an iterative approach.
This method has also been verified in Boogie to be sound and signedness-agnostic (i.e. handles intervals which cross the south pole),
meaning we also avoid taking the $ssplit$ and then joining the individually reduced intervals.
As such, the complete reduction is now the following:

$ rho((tnum, swint)) = (tnum meet into_tnum (swint'), rho_swint (swint, tnum)) $

#let mssb = $sans("mssb")$
#let lssb = $sans("lssb")$
#let above = $sans("above")$
#let below = $sans("below")$
#let mergeon = $sans("mergeon")$

First, some primitive defintions:

- $mssb(x)$ returns a bitvector where only the most significant set bit of $x$ is set.
  We are able to construct this using the `Z.numbits` trick presented earlier.
- $lssb(x) = x #`&` -x$ returns a bitvector where only the least significant set bit of $x$ is set.
- $above(p) = #`~`\(p #`|` (p - 1))$ takes a bitvector with a single set bit
  and returns a bitvector where all bits more significant than it are set.
- $below(p) = p - 1$ takes a bitvector with a single set bit
  and returns a beitvector where all bits less significant than it set.
- $mergeon(a, b, p) = (a #`&` above(p)) #`|` (b #`&` below(p))$ takes two bitvectors and a bitvector with a single set bit
  and constructs such that bits more significant that the set bit come from $a$
  less significant bits come from $b$.
  This is equivalent to $concat(extract_(w, k + 1)(a), 0, extract_(k, 0)(b))$ where $k$ is the set bit in $p$.

#grid(
  columns: (1fr, 1fr),
  figure(pseudocode-list[
    + *def* $rho_swint_"lower" (a, tnum)$
      + $"diff" <- mssb((a #`^` tnum_v) #`&` #`~`tnum_m)$
      + $wint("tmin", "_") <- into_swint (tnum)$
      + *if* $"diff" = 0$ *then*
        + *return* $a$
      + *else if* $a #`&` "diff" = 0$ *then*
        + *return* $"diff" #`|` mergeon(a, "tmin", "diff")$
      + *else*
        + $"carry" <- lssb(above("diff") #`&` #`~`a #`&` tnum_m)$
        + *return* $"carry" #`|` mergeon(a, "tmin", "carry")$
      + *endif*
  ]),
  figure(pseudocode-list[
    + *def* $rho_swint_"upper" (b, tnum)$
      + $"diff" <- mssb((b #`^` tnum_v) #`&` #`~`tnum_m)$
      + $wint("_", "tmax") <- into_swint (tnum)$
      + *if* $"diff" = 0$ *then*
        + *return* $b$
      + *else if* $b #`&` "diff" != 0$ *then*
        + *return* $mergeon(b, "tmax", "diff")$
      + *else*
        + $"borrow" <- lssb(above("diff") #`&` b #`&` tnum_m)$
        + *return* $mergeon(b, "tmax", "borrow")$
      + *endif*
  ]),
)

$
  rho_swint (swint, tnum) = cases(
    bot & "if" swint = bot,
    into_swint (tnum) & "if" swint = top,
    wint(rho_swint_"lower" (a, tnum), rho_swint_"upper" (b, tnum)) & "if" swint = wint(a, b)
  )
$

= Transfer Function

In Bincaml, we define the `Domain` module over the `StateAbstraction` $V -> (tnum, swint)$,
but still want to the use the transfer functions for $V -> tnum$ and $V -> swint$
to take advantage of the conditional semantics provided for wrapped intervals.
As an implementation detail, `Known_bits.Domain` and `Wrapped_intervals.Domain` supply a function `tf`
which accepts a `read` function and the evaluated and abstract statement
and returns an iterator of updates to the state.

In the transfer function of the reduced product, we define `read` functions of the form `fun k -> (read k dom).wint`
to only read the appropriate part of the state, without needing to construct separate maps.
To update the state of the reduced product, we first apply only the $tnum$ updates, then the $swint$ updates.
This avoids having to zip maps with differing keys and a rather large footgun related to module sealing.

If the statement is an `assert` or `guard`, we collect the variables updated by either analysis
and run the reduction on only those variables to propagate the effects of conditional semantics.
All evaluation functions in the `ValueAbstraction` (excluding `eval_const`) run reduce on the final result.
`eval_intrin` does not perform reduction in the intermediate steps.

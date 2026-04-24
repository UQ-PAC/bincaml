(** [cached ~eq f argfun] returns a function which computes
    [fun x -> f (argfun x)], but calls to the inner [f] are cached based on the
    result of [argfun x]. Only the most recent value is cached.

    It is intended that [x] be some large state object, [argfun] extracts
    relevant dependencies from [x], and [f] performs the slow computation.
    [argfun] should be fast to compute.

    The parameter [~eq] defines equality for values of type [argfun x]. *)
let cached ~eq f argfun =
  let cache = CCCache.linear ~eq 1 in
  fun x ->
    try CCCache.with_cache cache f (argfun x)
    with e ->
      Logs.err (fun m ->
          m "error during cached handler: %s\n%s" (Printexc.to_string e)
            (Printexc.get_backtrace ()));
      raise e

let physical = CCEqual.physical
let equal2 eq1 eq2 (x1, x2) (y1, y2) = eq1 x1 y1 && eq2 x2 y2

let equal3 eq1 eq2 eq3 (x1, x2, x3) (y1, y2, y3) =
  eq1 x1 y1 && eq2 x2 y2 && eq3 x3 y3

let equal4 eq1 eq2 eq3 eq4 (x1, x2, x3, x4) (y1, y2, y3, y4) =
  eq1 x1 y1 && eq2 x2 y2 && eq3 x3 y3 && eq4 x4 y4

let equal5 eq1 eq2 eq3 eq4 eq5 (x1, x2, x3, x4, x5) (y1, y2, y3, y4, y5) =
  eq1 x1 y1 && eq2 x2 y2 && eq3 x3 y3 && eq4 x4 y4 && eq5 x5 y5

let equal6 eq1 eq2 eq3 eq4 eq5 eq6 (x1, x2, x3, x4, x5, x6)
    (y1, y2, y3, y4, y5, y6) =
  eq1 x1 y1 && eq2 x2 y2 && eq3 x3 y3 && eq4 x4 y4 && eq5 x5 y5 && eq6 x6 y6

let equal7 eq1 eq2 eq3 eq4 eq5 eq6 eq7 (x1, x2, x3, x4, x5, x6, x7)
    (y1, y2, y3, y4, y5, y6, y7) =
  eq1 x1 y1 && eq2 x2 y2 && eq3 x3 y3 && eq4 x4 y4 && eq5 x5 y5 && eq6 x6 y6
  && eq7 x7 y7

let equal8 eq1 eq2 eq3 eq4 eq5 eq6 eq7 eq8 (x1, x2, x3, x4, x5, x6, x7, x8)
    (y1, y2, y3, y4, y5, y6, y7, y8) =
  eq1 x1 y1 && eq2 x2 y2 && eq3 x3 y3 && eq4 x4 y4 && eq5 x5 y5 && eq6 x6 y6
  && eq7 x7 y7 && eq8 x8 y8

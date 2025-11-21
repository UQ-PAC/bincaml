
  $ bincaml script roundtrip.sexp

The serialise -> parse serialise loop should be idempotent

  $ diff before.il after.il

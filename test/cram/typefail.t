  $ dune exec bincaml script ./typefail.sexp 2>/dev/null
  Arguments are not of the same type in eq
  Arguments are not of the same type in neq
  Arguments are not of the same type in eq
  Arguments are not of the same type in neq
  Arguments are not of the same type in eq
  Arguments are not of the same type in neq
  Paramters for the function has a type mismatch: type of intneg(0x1:bv32) != type of $NF:bv1
  intneg body is not a integer
  bv32 is not the correct type of int for intadd
  bv32 is not the correct type of int for intdiv
  bv32 is not the correct type of int for intmod
  bv32 is not the correct type of int for intmul
  bv32 is not the correct type of int for intsub
  bv32 is not the correct type of int for intlt
  bv32 is not the correct type of int for intle
  Paramters for the function has a type mismatch: type of bvnot(1) != type of $NF:bv1
  bvnot body is not a bitvector
  Paramters for the function has a type mismatch: type of bvneg(1) != type of $NF:bv1
  bvneg body is not a bitvector
  Paramters for the function has a type mismatch: type of zero_extend(32, 2) != type of $NF:bv64
  Nothing type encountered in operator
  zero_extend_32 body is not a bitvector
  Paramters for the function has a type mismatch: type of sign_extend(32, 2) != type of $NF:bv64
  Nothing type encountered in operator
  sign_extend_32 body is not a bitvector
  extract_32_31  body is not a bitvector
  int is not of bitvector type in bvsle
  int is not of bitvector type in bvslt
  bv32 is not the correct type of bv64 for bvsle
  bv32 is not the correct type of bv64 for bvslt
  int is not of bitvector type in bvult
  int is not of bitvector type in bvule
  Paramters for the function has a type mismatch: type of bvand(1, 0x1:bv32) != type of $NF:bool
  int is not of bitvector type in bvand
  bool is not of bitvector type in bvor
  bool is not of bitvector type in bvadd
  bv32 is not the correct type of bv64 for bvadd
  bool is not of bitvector type in bvmul
  bv32 is not the correct type of bv64 for bvmul
  bool is not of bitvector type in bvudiv
  bv32 is not the correct type of bv64 for bvudiv
  bool is not of bitvector type in bvurem
  bv32 is not the correct type of bv64 for bvurem
  bool is not of bitvector type in bvshl
  bv32 is not the correct type of bv64 for bvshl
  bool is not of bitvector type in bvlshr
  bv32 is not the correct type of bv64 for bvlshr
  bool is not of bitvector type in bvnand
  bv32 is not the correct type of bv64 for bvnand
  bool is not of bitvector type in bvxor
  bv32 is not the correct type of bv64 for bvxor
  bool is not of bitvector type in bvsub
  bv32 is not the correct type of bv64 for bvsub
  bool is not of bitvector type in bvsdiv
  bv32 is not the correct type of bv64 for bvsdiv
  bool is not of bitvector type in bvsrem
  bv32 is not the correct type of bv64 for bvsrem
  bool is not of bitvector type in bvsmod
  bv32 is not the correct type of bv64 for bvsmod
  bool is not of bitvector type in bvashr
  bv32 is not the correct type of bv64 for bvashr
  Address loading data (#4:bv32) does not match address size (64)
  Body of booltobv1(0x7a0:bv64) is not a Boolean
  booltobv1 body is not a boolean
  [125]


  $ dune exec bincaml script ./typefail.sexp 2>/dev/null
  Arguments are not of the same type in eq at statement 0 in %main_entry
  Arguments are not of the same type in neq at statement 1 in %main_entry
  Arguments are not of the same type in eq at statement 2 in %main_entry
  Arguments are not of the same type in neq at statement 3 in %main_entry
  Arguments are not of the same type in eq at statement 4 in %main_entry
  Arguments are not of the same type in neq at statement 5 in %main_entry
  Paramters for the function has a type mismatch: type of intneg(0x1:bv32) != type of $NF:bv1 at statement 6 in %main_entry
  intneg body is not a integer at statement 6 in %main_entry
  bv32 is not the correct type of int for intadd at statement 7 in %main_entry
  bv32 is not the correct type of int for intdiv at statement 8 in %main_entry
  bv32 is not the correct type of int for intmod at statement 9 in %main_entry
  bv32 is not the correct type of int for intmul at statement 10 in %main_entry
  bv32 is not the correct type of int for intsub at statement 11 in %main_entry
  bv32 is not the correct type of int for intlt at statement 12 in %main_entry
  bv32 is not the correct type of int for intle at statement 13 in %main_entry
  Paramters for the function has a type mismatch: type of bvnot(1) != type of $NF:bv1 at statement 14 in %main_entry
  bvnot body is not a bitvector at statement 14 in %main_entry
  Paramters for the function has a type mismatch: type of bvneg(1) != type of $NF:bv1 at statement 15 in %main_entry
  bvneg body is not a bitvector at statement 15 in %main_entry
  Paramters for the function has a type mismatch: type of zero_extend(32, 2) != type of $NF:bv64 at statement 16 in %main_entry
  Nothing type encountered in operator at statement 16 in %main_entry
  zero_extend_32 body is not a bitvector at statement 16 in %main_entry
  Paramters for the function has a type mismatch: type of sign_extend(32, 2) != type of $NF:bv64 at statement 17 in %main_entry
  Nothing type encountered in operator at statement 17 in %main_entry
  sign_extend_32 body is not a bitvector at statement 17 in %main_entry
  extract_32_31  body is not a bitvector at statement 18 in %main_entry
  int is not of bitvector type in bvsle at statement 19 in %main_entry
  int is not of bitvector type in bvslt at statement 20 in %main_entry
  bv32 is not the correct type of bv64 for bvsle at statement 21 in %main_entry
  bv32 is not the correct type of bv64 for bvslt at statement 22 in %main_entry
  int is not of bitvector type in bvult at statement 23 in %main_entry
  int is not of bitvector type in bvule at statement 24 in %main_entry
  Paramters for the function has a type mismatch: type of bvand(1, 0x1:bv32) != type of $NF:bool at statement 25 in %main_entry
  int is not of bitvector type in bvand at statement 25 in %main_entry
  bool is not of bitvector type in bvor at statement 26 in %main_entry
  bool is not of bitvector type in bvadd at statement 27 in %main_entry
  bv32 is not the correct type of bv64 for bvadd at statement 28 in %main_entry
  bool is not of bitvector type in bvmul at statement 29 in %main_entry
  bv32 is not the correct type of bv64 for bvmul at statement 30 in %main_entry
  bool is not of bitvector type in bvudiv at statement 31 in %main_entry
  bv32 is not the correct type of bv64 for bvudiv at statement 32 in %main_entry
  bool is not of bitvector type in bvurem at statement 33 in %main_entry
  bv32 is not the correct type of bv64 for bvurem at statement 34 in %main_entry
  bool is not of bitvector type in bvshl at statement 35 in %main_entry
  bv32 is not the correct type of bv64 for bvshl at statement 36 in %main_entry
  bool is not of bitvector type in bvlshr at statement 37 in %main_entry
  bv32 is not the correct type of bv64 for bvlshr at statement 38 in %main_entry
  bool is not of bitvector type in bvnand at statement 39 in %main_entry
  bv32 is not the correct type of bv64 for bvnand at statement 40 in %main_entry
  bool is not of bitvector type in bvxor at statement 41 in %main_entry
  bv32 is not the correct type of bv64 for bvxor at statement 42 in %main_entry
  bool is not of bitvector type in bvsub at statement 43 in %main_entry
  bv32 is not the correct type of bv64 for bvsub at statement 44 in %main_entry
  bool is not of bitvector type in bvsdiv at statement 45 in %main_entry
  bv32 is not the correct type of bv64 for bvsdiv at statement 46 in %main_entry
  bool is not of bitvector type in bvsrem at statement 47 in %main_entry
  bv32 is not the correct type of bv64 for bvsrem at statement 48 in %main_entry
  bool is not of bitvector type in bvsmod at statement 49 in %main_entry
  bv32 is not the correct type of bv64 for bvsmod at statement 50 in %main_entry
  bool is not of bitvector type in bvashr at statement 51 in %main_entry
  bv32 is not the correct type of bv64 for bvashr at statement 52 in %main_entry
  Address loading data (#4:bv32) does not match address size (64) at statement 54 in %main_entry
  Body of booltobv1(0x7a0:bv64) is not a Boolean at statement 0 in %main_9
  booltobv1 body is not a boolean at statement 0 in %main_9
  [125]


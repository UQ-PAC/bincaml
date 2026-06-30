  $ bincaml script ./sva.sexp
  (load-il ../../examples/irreducible_loop_1.il)
  (run-transforms sva)
  bincaml: [WARNING] Invariants not satisfied during 'sva'. Needs [SSA] but only have [].
  (R31_in->(Stack(@puts_1584)->⟦0x0:bv64, 0x0:bv64⟧, _->⊥), R30_in->(Par(@puts_1584_{ Var.name = ("R30_in", 1); scope = (Var.Local "@puts_1584"); typ = bv64;
    tags = Var.None })->⟦0x0:bv64, 0x0:bv64⟧, _->⊥), R29_in->(Par(@puts_1584_{ Var.name = ("R29_in", 2); scope = (Var.Local "@puts_1584"); typ = bv64;
    tags = Var.None })->⟦0x0:bv64, 0x0:bv64⟧, _->⊥), _->⊥)
  (#4->(Stack(@main_1876)->⟦0xffffffffffffffe0:bv64, 0xffffffffffffffe0:bv64⟧, _->⊥), load18->(Loaded->⟦0x0:bv32, 0x0:bv32⟧, _->⊥), #5->(Loaded->⊤, _->⊥), $NF->(Loaded->⟦0x0:bv32, 0x0:bv32⟧, _->⊥), $R0->(Loaded->⟦0x0:bv64, 0x0:bv64⟧, _->⊥), $R1->(Loaded->⟦0x0:bv64, 0x0:bv64⟧, _->⊥), $R29->(Loaded->⟦0x0:bv64, 0x0:bv64⟧, _->⊥), $R30->(Loaded->⟦0x0:bv64, 0x0:bv64⟧, _->⊥), R31_in->(Stack(@main_1876)->⟦0x0:bv64, 0x0:bv64⟧, _->⊥), R30_in->(Loaded->⊤, _->⊥), R29_in->(Loaded->⊤, _->⊥), _->⊥)

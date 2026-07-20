  $ cat > hm.il <<'EOF'
  > memory shared $mem : (bv64 -> bv8);
  > var $PC:bv64;
  > prog entry @main;
  > 
  > type nothing = Thing of { a: bv1 };
  > 
  > proc @main()  -> () {  }
  > [
  >   block %main_code [
  >     var R0_out:nothing := (Thing)(0x1:bv10);
  >     goto (%ret_1);
  >   ];
  >   block %ret_1 [ return; ]
  > ];
  > EOF

  $ bincaml script - <<EOF
  > (load-il hm.il)
  > (run-transforms hindley-milner-elaborate)
  > EOF
  (load-il hm.il)
  bincaml: [ERROR] global Thing:(bv1->nothing) should have global sigil $
  (run-transforms hindley-milner-elaborate)
  bincaml: (run-transforms hindley-milner-elaborate): Failure("var not found: <global>::Thing")
           
  [123]


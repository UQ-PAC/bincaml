

  $ printf "\ninvalid program\nsyntax" > invalid.il

  $ bincaml dump-il invalid.il
  bincaml: Parse error:  invalid.il:2
           2 | invalid program
               ^^^^^^^
           
  [123]

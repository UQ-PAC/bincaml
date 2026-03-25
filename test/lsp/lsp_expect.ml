let%expect_test "a" =
  let buf = Lexing.from_string {|abc  <-
  <- a|} in
  let open Bincaml_lsp.Raw_tokens in
  let p () = print_endline (show_lexbuf buf) in

  p ();
  [%expect {| abs_pos=0, start_pos=0, curr_pos=0, last_pos=0, cur={ Lexing.pos_fname = ""; pos_lnum = 1; pos_bol = 0; pos_cnum = 0 }, start={ Lexing.pos_fname = ""; pos_lnum = 1; pos_bol = 0; pos_cnum = 0 } |}];
  print_endline (CCList.to_string ~sep:"\n" show_token_with_pos (next_token buf ()));
  [%expect {|
    { Raw_tokens.token = (TOK_LocalIdent ((0, 3), "abc"));
      str = "(TOK_LocalIdent ((0, 3), \"abc\"))";
      startpos =
      { Lexing.pos_fname = ""; pos_lnum = 1; pos_bol = 0; pos_cnum = 0 };
      endpos = { Lexing.pos_fname = ""; pos_lnum = 1; pos_bol = 0; pos_cnum = 3 }
      }
    |}];
  p ();
  [%expect {| abs_pos=0, start_pos=0, curr_pos=3, last_pos=3, cur={ Lexing.pos_fname = ""; pos_lnum = 1; pos_bol = 0; pos_cnum = 3 }, start={ Lexing.pos_fname = ""; pos_lnum = 1; pos_bol = 0; pos_cnum = 0 } |}];

  print_endline (CCList.to_string ~sep:"\n" show_token_with_pos (next_token buf ()));
  [%expect {|
    AFTER ERROR:abs_pos=0, start_pos=5, curr_pos=5, last_pos=5, cur={ Lexing.pos_fname = ""; pos_lnum = 1; pos_bol = 0; pos_cnum = 5 }, start={ Lexing.pos_fname = ""; pos_lnum = 1; pos_bol = 0; pos_cnum = 4 }
    AFTER ERROR:abs_pos=0, start_pos=6, curr_pos=6, last_pos=6, cur={ Lexing.pos_fname = ""; pos_lnum = 1; pos_bol = 0; pos_cnum = 5 }, start={ Lexing.pos_fname = ""; pos_lnum = 1; pos_bol = 0; pos_cnum = 4 }
    AFTER ERROR:abs_pos=0, start_pos=10, curr_pos=10, last_pos=10, cur={ Lexing.pos_fname = ""; pos_lnum = 2; pos_bol = 8; pos_cnum = 10 }, start={ Lexing.pos_fname = ""; pos_lnum = 2; pos_bol = 8; pos_cnum = 9 }
    AFTER ERROR:abs_pos=0, start_pos=11, curr_pos=11, last_pos=11, cur={ Lexing.pos_fname = ""; pos_lnum = 2; pos_bol = 8; pos_cnum = 10 }, start={ Lexing.pos_fname = ""; pos_lnum = 2; pos_bol = 8; pos_cnum = 9 }
    { Raw_tokens.token = KW_and; str = "<error>";
      startpos =
      { Lexing.pos_fname = ""; pos_lnum = 1; pos_bol = 0; pos_cnum = 5 };
      endpos =
      { Lexing.pos_fname = ""; pos_lnum = 2; pos_bol = 8; pos_cnum = 14 } }
    { Raw_tokens.token = (TOK_LocalIdent ((13, 14), "a"));
      str = "(TOK_LocalIdent ((13, 14), \"a\"))";
      startpos =
      { Lexing.pos_fname = ""; pos_lnum = 2; pos_bol = 8; pos_cnum = 13 };
      endpos =
      { Lexing.pos_fname = ""; pos_lnum = 2; pos_bol = 8; pos_cnum = 14 } }
    |}];

  p ();
  [%expect {| abs_pos=0, start_pos=13, curr_pos=14, last_pos=14, cur={ Lexing.pos_fname = ""; pos_lnum = 2; pos_bol = 8; pos_cnum = 14 }, start={ Lexing.pos_fname = ""; pos_lnum = 2; pos_bol = 8; pos_cnum = 13 } |}];

  print_endline (CCList.to_string ~sep:"\n" show_token_with_pos (next_token buf ()));
  [%expect {|
    { Raw_tokens.token = TOK_EOF; str = "TOK_EOF";
      startpos =
      { Lexing.pos_fname = ""; pos_lnum = 2; pos_bol = 8; pos_cnum = 14 };
      endpos =
      { Lexing.pos_fname = ""; pos_lnum = 2; pos_bol = 8; pos_cnum = 14 } }
    |}];

  p ();
  [%expect {| abs_pos=0, start_pos=14, curr_pos=14, last_pos=14, cur={ Lexing.pos_fname = ""; pos_lnum = 2; pos_bol = 8; pos_cnum = 14 }, start={ Lexing.pos_fname = ""; pos_lnum = 2; pos_bol = 8; pos_cnum = 14 } |}]

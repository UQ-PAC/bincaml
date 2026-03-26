let%expect_test "errors on newline" =
  let buf = Lexing.from_string {|abc  <-
  <- a|} in
  let open Bincaml_lsp.Raw_tokens in
  let p () = print_endline (show_lexbuf buf) in

  p ();
  [%expect
    {| abs_pos=0, start_pos=0, curr_pos=0, last_pos=0, cur={ Lexing.pos_fname = ""; pos_lnum = 1; pos_bol = 0; pos_cnum = 0 }, start={ Lexing.pos_fname = ""; pos_lnum = 1; pos_bol = 0; pos_cnum = 0 } |}];
  print_endline
    (CCList.to_string ~sep:"\n" show_token_with_pos (next_token buf ()));
  [%expect
    {|
    { Raw_tokens.token = (Ok (TOK_LocalIdent ((0, 3), "abc")));
      str = "(TOK_LocalIdent ((0, 3), \"abc\"))";
      startpos =
      { Lexing.pos_fname = ""; pos_lnum = 1; pos_bol = 0; pos_cnum = 0 };
      endpos = { Lexing.pos_fname = ""; pos_lnum = 1; pos_bol = 0; pos_cnum = 3 }
      }
    |}];
  p ();
  [%expect
    {| abs_pos=0, start_pos=0, curr_pos=3, last_pos=3, cur={ Lexing.pos_fname = ""; pos_lnum = 1; pos_bol = 0; pos_cnum = 3 }, start={ Lexing.pos_fname = ""; pos_lnum = 1; pos_bol = 0; pos_cnum = 0 } |}];

  print_endline
    (CCList.to_string ~sep:"\n" show_token_with_pos (next_token buf ()));
  [%expect
    {|
    { Raw_tokens.token = (Error ()); str = "Syntax error: unrecognised token";
      startpos =
      { Lexing.pos_fname = ""; pos_lnum = 1; pos_bol = 0; pos_cnum = 5 };
      endpos = { Lexing.pos_fname = ""; pos_lnum = 1; pos_bol = 0; pos_cnum = 8 }
      }
    { Raw_tokens.token = (Error ()); str = "Syntax error: unrecognised token";
      startpos =
      { Lexing.pos_fname = ""; pos_lnum = 2; pos_bol = 8; pos_cnum = 10 };
      endpos =
      { Lexing.pos_fname = ""; pos_lnum = 2; pos_bol = 8; pos_cnum = 11 } }
    { Raw_tokens.token = (Ok (TOK_LocalIdent ((13, 14), "a")));
      str = "(TOK_LocalIdent ((13, 14), \"a\"))";
      startpos =
      { Lexing.pos_fname = ""; pos_lnum = 2; pos_bol = 8; pos_cnum = 13 };
      endpos =
      { Lexing.pos_fname = ""; pos_lnum = 2; pos_bol = 8; pos_cnum = 14 } }
    |}];

  p ();
  [%expect
    {| abs_pos=0, start_pos=13, curr_pos=14, last_pos=14, cur={ Lexing.pos_fname = ""; pos_lnum = 2; pos_bol = 8; pos_cnum = 14 }, start={ Lexing.pos_fname = ""; pos_lnum = 2; pos_bol = 8; pos_cnum = 13 } |}];

  print_endline
    (CCList.to_string ~sep:"\n" show_token_with_pos (next_token buf ()));
  [%expect
    {|
    { Raw_tokens.token = (Ok TOK_EOF); str = "TOK_EOF";
      startpos =
      { Lexing.pos_fname = ""; pos_lnum = 2; pos_bol = 8; pos_cnum = 14 };
      endpos =
      { Lexing.pos_fname = ""; pos_lnum = 2; pos_bol = 8; pos_cnum = 14 } }
    |}];

  p ();
  [%expect
    {| abs_pos=0, start_pos=14, curr_pos=14, last_pos=14, cur={ Lexing.pos_fname = ""; pos_lnum = 2; pos_bol = 8; pos_cnum = 14 }, start={ Lexing.pos_fname = ""; pos_lnum = 2; pos_bol = 8; pos_cnum = 14 } |}]

let%expect_test "errors on same line" =
  let buf = Lexing.from_string {|abc  <- <- a|} in
  let open Bincaml_lsp.Raw_tokens in
  let p () = print_endline (show_lexbuf buf) in

  p ();
  [%expect
    {| abs_pos=0, start_pos=0, curr_pos=0, last_pos=0, cur={ Lexing.pos_fname = ""; pos_lnum = 1; pos_bol = 0; pos_cnum = 0 }, start={ Lexing.pos_fname = ""; pos_lnum = 1; pos_bol = 0; pos_cnum = 0 } |}];
  print_endline
    (CCList.to_string ~sep:"\n" show_token_with_pos (next_token buf ()));
  [%expect
    {|
    { Raw_tokens.token = (Ok (TOK_LocalIdent ((0, 3), "abc")));
      str = "(TOK_LocalIdent ((0, 3), \"abc\"))";
      startpos =
      { Lexing.pos_fname = ""; pos_lnum = 1; pos_bol = 0; pos_cnum = 0 };
      endpos = { Lexing.pos_fname = ""; pos_lnum = 1; pos_bol = 0; pos_cnum = 3 }
      }
  |}];

  print_endline
    (CCList.to_string ~sep:"\n" show_token_with_pos (next_token buf ()));
  [%expect
    {|
    { Raw_tokens.token = (Error ()); str = "Syntax error: unrecognised token";
      startpos =
      { Lexing.pos_fname = ""; pos_lnum = 1; pos_bol = 0; pos_cnum = 5 };
      endpos = { Lexing.pos_fname = ""; pos_lnum = 1; pos_bol = 0; pos_cnum = 8 }
      }
    { Raw_tokens.token = (Error ()); str = "Syntax error: unrecognised token";
      startpos =
      { Lexing.pos_fname = ""; pos_lnum = 1; pos_bol = 0; pos_cnum = 8 };
      endpos = { Lexing.pos_fname = ""; pos_lnum = 1; pos_bol = 0; pos_cnum = 9 }
      }
    { Raw_tokens.token = (Ok (TOK_LocalIdent ((11, 12), "a")));
      str = "(TOK_LocalIdent ((11, 12), \"a\"))";
      startpos =
      { Lexing.pos_fname = ""; pos_lnum = 1; pos_bol = 0; pos_cnum = 11 };
      endpos =
      { Lexing.pos_fname = ""; pos_lnum = 1; pos_bol = 0; pos_cnum = 12 } }
    |}]

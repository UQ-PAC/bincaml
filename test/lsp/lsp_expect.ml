let%expect_test "a" =
  let buf = Lexing.from_string {|abc  <-
  <- a|} in
  let open Bincaml_lsp.Raw_tokens in
  let p () = print_endline (show_lexbuf buf) in

  p ();
  [%expect {| abs_pos=0, start_pos=0, curr_pos=0, last_pos=0, cur={ Lexing.pos_fname = ""; pos_lnum = 1; pos_bol = 0; pos_cnum = 0 }, start={ Lexing.pos_fname = ""; pos_lnum = 1; pos_bol = 0; pos_cnum = 0 } |}];
  print_endline (CCList.to_string ~sep:"\n" show_token_with_pos (next_token buf ()));
  [%expect {|
    { Raw_tokens.token = (Ok (TOK_LocalIdent ((0, 3), "abc")));
      str = "(TOK_LocalIdent ((0, 3), \"abc\"))";
      startpos =
      { Lexing.pos_fname = ""; pos_lnum = 1; pos_bol = 0; pos_cnum = 0 };
      endpos = { Lexing.pos_fname = ""; pos_lnum = 1; pos_bol = 0; pos_cnum = 3 }
      }
    |}];
  p ();
  [%expect {| abs_pos=0, start_pos=0, curr_pos=3, last_pos=3, cur={ Lexing.pos_fname = ""; pos_lnum = 1; pos_bol = 0; pos_cnum = 3 }, start={ Lexing.pos_fname = ""; pos_lnum = 1; pos_bol = 0; pos_cnum = 0 } |}];

  print_endline (CCList.to_string ~sep:"\n" show_token_with_pos (next_token buf ()));
  [%expect {| |}];

  p ();
  [%expect {| abs_pos=0, start_pos=5, curr_pos=6, last_pos=5, cur={ Lexing.pos_fname = ""; pos_lnum = 1; pos_bol = 0; pos_cnum = 5 }, start={ Lexing.pos_fname = ""; pos_lnum = 1; pos_bol = 0; pos_cnum = 4 } |}];

  print_endline (CCList.to_string ~sep:"\n" show_token_with_pos (next_token buf ()));
  [%expect {| |}];

  p ();
  [%expect {| abs_pos=0, start_pos=6, curr_pos=7, last_pos=6, cur={ Lexing.pos_fname = ""; pos_lnum = 1; pos_bol = 0; pos_cnum = 5 }, start={ Lexing.pos_fname = ""; pos_lnum = 1; pos_bol = 0; pos_cnum = 4 } |}]

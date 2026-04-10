
let () =
  Logs.set_level (Some Logs.Info);
  Logs.set_reporter (Logs.format_reporter ~app:Format.std_formatter ~dst:Format.std_formatter ())

let%expect_test "error then error" =
  let open Bincaml_lsp.Raw_tokens in
  let s = {|<-  <--
    <-|} in

  extract_and_render_tokens stdout s;
  [%expect {|
    <-  <--
    aa  bbb
        <-
        dd
    a: Syntax error: unrecognised token
    b: Syntax error: unrecognised token
    c: Syntax error: unrecognised token
    d: TOK_EOF
    |}]

let%expect_test "error then token" =
  let open Bincaml_lsp.Raw_tokens in
  let s = {|<- e|} in

  extract_and_render_tokens stdout s;
  [%expect {|
    <- e
    aa b
    a: Syntax error: unrecognised token
    b: (TOK_LocalIdent ((3, 4), "e"))
    c: TOK_EOF
    |}]

let%expect_test "errors on same line" =
  let s = {| <---   <--- aa <--  <--  <--|} in
  let open Bincaml_lsp.Raw_tokens in

  extract_and_render_tokens stdout s;
  [%expect {|
     <---   <--- aa <--  <--  <--
     aaaa   bbbb cc ddd  eee  ggg
    a: Syntax error: unrecognised token
    b: Syntax error: unrecognised token
    c: (TOK_LocalIdent ((13, 15), "aa"))
    d: Syntax error: unrecognised token
    e: Syntax error: unrecognised token
    f: Syntax error: unrecognised token
    g: TOK_EOF
    |}]

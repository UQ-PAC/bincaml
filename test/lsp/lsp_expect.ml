let () =
  Logs.set_level (Some Logs.Info);
  Logs.set_reporter
    (Logs.format_reporter ~app:Format.std_formatter ~dst:Format.std_formatter ())

let%expect_test "error then error" =
  let open Bincaml_lsp.Raw_tokens in
  let s = {|<-  <--
    <-|} in

  extract_and_render_tokens stdout s;
  [%expect
    {|
    <-  <--
    ab  cde
        <-
        fg
    a: (TOK_Infix_BVSLT "<")
    b: (TOK_Infix_BVSUB "-")
    c: (TOK_Infix_BVSLT "<")
    d: (TOK_Infix_BVSUB "-")
    e: (TOK_Infix_BVSUB "-")
    f: (TOK_Infix_BVSLT "<")
    g: (TOK_Infix_BVSUB "-")
    h: TOK_EOF
    |}]

let%expect_test "error then token" =
  let open Bincaml_lsp.Raw_tokens in
  let s = {|<- e|} in

  extract_and_render_tokens stdout s;
  [%expect
    {|
    <- e
    ab c
    a: (TOK_Infix_BVSLT "<")
    b: (TOK_Infix_BVSUB "-")
    c: (TOK_LocalIdent ((3, 4), "e"))
    d: TOK_EOF
    |}]

let%expect_test "errors on same line" =
  let s = {| <---   <--- aa <--  <--  <--|} in
  let open Bincaml_lsp.Raw_tokens in
  extract_and_render_tokens stdout s;
  [%expect
    {|
     <---   <--- aa <--  <--  <--
     abcd   efgh ii jkl  mno  pqr
    a: (TOK_Infix_BVSLT "<")
    b: (TOK_Infix_BVSUB "-")
    c: (TOK_Infix_BVSUB "-")
    d: (TOK_Infix_BVSUB "-")
    e: (TOK_Infix_BVSLT "<")
    f: (TOK_Infix_BVSUB "-")
    g: (TOK_Infix_BVSUB "-")
    h: (TOK_Infix_BVSUB "-")
    i: (TOK_LocalIdent ((13, 15), "aa"))
    j: (TOK_Infix_BVSLT "<")
    k: (TOK_Infix_BVSUB "-")
    l: (TOK_Infix_BVSUB "-")
    m: (TOK_Infix_BVSLT "<")
    n: (TOK_Infix_BVSUB "-")
    o: (TOK_Infix_BVSUB "-")
    p: (TOK_Infix_BVSLT "<")
    q: (TOK_Infix_BVSUB "-")
    r: (TOK_Infix_BVSUB "-")
    s: TOK_EOF
    |}]

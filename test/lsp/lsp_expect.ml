
let () =
  Logs.set_level (Some Logs.Info);
  Logs.set_reporter (Logs.format_reporter ~app:Format.std_formatter ~dst:Format.std_formatter ())

let%expect_test "errors on newline" =
  let s = {|abc  <-   b
  <- a|} in
  let open Bincaml_lsp.Raw_tokens in

  extract_and_render_tokens stdout s;
  [%expect {|
    inline-test-runner.exe: [ERROR] moving past error
    inline-test-runner.exe: [ERROR] moving past error
    inline-test-runner.exe: [ERROR] moving past error
    inline-test-runner.exe: [ERROR] moving past error
    abc  <-   b
    aaa  bbb  c
      <- a
      ddde
    (TOK_LocalIdent ((0, 3), "abc"))
    Syntax error: unrecognised token
    (TOK_LocalIdent ((10, 11), "b"))
    Syntax error: unrecognised token
    (TOK_LocalIdent ((17, 18), "a"))
    |}]

let%expect_test "errors on same line" =
  let s = {| <- abc    <---   <-     <--- aa <--|} in
  let open Bincaml_lsp.Raw_tokens in

  extract_and_render_tokens stdout s;
  [%expect {|
    inline-test-runner.exe: [ERROR] moving past error
    inline-test-runner.exe: [ERROR] moving past error
    inline-test-runner.exe: [ERROR] moving past error
    inline-test-runner.exe: [ERROR] moving past error
    inline-test-runner.exe: [ERROR] moving past error
    inline-test-runner.exe: [ERROR] moving past error
    inline-test-runner.exe: [ERROR] moving past error
    inline-test-runner.exe: [ERROR] moving past error
    inline-test-runner.exe: [ERROR] moving past error
    inline-test-runner.exe: [ERROR] moving past error
    inline-test-runner.exe: [ERROR] moving past error
    inline-test-runner.exe: [ERROR] moving past error
    inline-test-runner.exe: [ERROR] moving past error
    inline-test-runner.exe: [ERROR] moving past error
    inline-test-runner.exe: [ERROR] moving past error
     <- abc    <---   <-     <--- aa <--
     aaabbb    ccccc  dd     eeee ff gggg
    Syntax error: unrecognised token
    (TOK_LocalIdent ((4, 7), "abc"))
    Syntax error: unrecognised token
    Syntax error: unrecognised token
    Syntax error: unrecognised token
    (TOK_LocalIdent ((30, 32), "aa"))
    Syntax error: unrecognised token
    |}]

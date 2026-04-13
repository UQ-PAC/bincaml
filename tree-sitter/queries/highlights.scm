; https://neovim.io/doc/user/treesitter/#treesitter-highlight-groups
;
; https://tree-sitter.github.io/tree-sitter/using-parsers/queries/1-syntax.html

"goto" @keyword.return
"unreachable" @keyword.return
"return" @keyword.return

"call" @keyword.function
"indirect" @keyword.function

"nop" @keyword
"load" @keyword
"le" @keyword
"be" @keyword
"store" @keyword
"guard" @keyword
"assert" @keyword
"assume" @keyword
"var" @keyword
"memory" @keyword
"shared" @keyword.modifier
"type" @keyword
[ "rely"
  "relies"
  "guarantee"
  "guarantee"
  "require"
  "requires"
  "ensures"
  "ensure"
  "captures"
  "modifies"
  "classification"
  "let"
  "in"
  "fun"
  "invariant"
  "of"
  "ptr" ] @keyword
[ "forall"
  "exists"
  "old" ] @keyword.operator

[ "match"
  "with"
  "cases"
  "if"
  "then"
  "else"] @keyword.conditional

(IntVal) @number
(token_IntegerHex) @number
(token_IntegerDec) @number
"true" @constant.builtin
"false" @constant.builtin

(Type) @type
(token_BVTYPE) @type.builtin
(token_INTTYPE) @type.builtin
(token_BOOLTYPE) @type.builtin
(token_BIdent) @variable.member
(SumCase (token_LocalIdent) @constructor)
(RecordField (token_LocalIdent) @variable.member)
(FieldVal (token_Str) @variable.member)
(Decl . "type" . (token_LocalIdent) @type.definition)
(TypeAssign (token_LocalIdent) @type.definition)

(token_BlockIdent) @function.call
(Block (token_BlockIdent) @function)
"block" @keyword.function

(token_ProcIdent) @function.call
(Decl (token_ProcIdent) @function)
(Decl (list_Params) @variable.parameter)
"proc" @keyword.function

"prog" @keyword.directive
"entry" @keyword.directive

(BinOp) @function.builtin
(BoolBinOp) @function.builtin
(UnOp) @function.builtin
(EqOp) @function.builtin

"load_be" @function.builtin
"load_le" @function.builtin

"boolnot" @function.builtin
"intneg" @function.builtin
"booltobv1" @function.builtin
"eq" @function.builtin
"neq" @function.builtin
"bvnot" @function.builtin
"bvneg" @function.builtin
"bvand" @function.builtin
"bvor" @function.builtin
"bvadd" @function.builtin
"bvmul" @function.builtin
"bvudiv" @function.builtin
"bvurem" @function.builtin
"bvshl" @function.builtin
"bvlshr" @function.builtin
"bvnand" @function.builtin
"bvnor" @function.builtin
"bvxor" @function.builtin
"bvxnor" @function.builtin
"bvcomp" @function.builtin
"bvsub" @function.builtin
"bvsdiv" @function.builtin
"bvsrem" @function.builtin
"bvsmod" @function.builtin
"bvashr" @function.builtin
"bvule" @function.builtin
"bvugt" @function.builtin
"bvuge" @function.builtin
"bvult" @function.builtin
"bvslt" @function.builtin
"bvsle" @function.builtin
"bvsgt" @function.builtin
"bvsge" @function.builtin
"intadd" @function.builtin
"intmul" @function.builtin
"intsub" @function.builtin
"intdiv" @function.builtin
"intmod" @function.builtin
"intlt" @function.builtin
"intle" @function.builtin
"intgt" @function.builtin
"intge" @function.builtin
"booland" @function.builtin
"boolor" @function.builtin
"boolimplies" @function.builtin
"zero_extend" @function.builtin
"sign_extend" @function.builtin
"extract" @function.builtin
"bvconcat" @function.builtin

[
  (token_BeginList)
  (token_EndList)
  (token_BeginRec)
  (token_EndRec)
  (token_OpenParen)
  (token_CloseParen)
] @punctuation.bracket

[ ";" "," "=" ] @punctuation.delimiter
[ ":" ":=" "::" "mem:=" ] @punctuation
[ (token_BeginRec)
  (token_EndRec)
  (token_BeginList)
  (token_EndList) ] @punctuation.bracket

(token_Str) @string
(token_CommentMulti) @comment
(token_CommentSingle) @comment

(Expr1
  (Expr1
    (Expr2 [(Value) (LocalVar) (GlobalVar)] @function.call)
  )
  .
  (token_OpenParen))

(Expr (token_LocalIdent) @constructor . (token_BeginRec))
(FieldAssign (token_LocalIdent) @variable.member . "=")

(Decl "let" . (token_GlobalIdent) @function . (list_LocalVarParen))
(Expr "let" . (token_LocalIdent) @function . (list_LocalVarParen))

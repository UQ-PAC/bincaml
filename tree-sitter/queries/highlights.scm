; (keyword) @keyword
; (other) @variable
; ((other) @x
;   (#match? @x "^//.*")) @comment
; ((other) @x
;   (#match? @x "^/\\*.*")) @comment
; ((other) @x
;   (#match? @x "^[^a-zA-Z_0-9]+$")) @punctuation.delimiter
; ((other) @x
;   (#match? @x "^[\"']")) @string
; ((other) @x
;   (#match? @x "^(->|\\=|:\\=)$")) @operator
; ((other) @x
;   (#match? @x "^[0-9]")) @number
; ((other) @x
;   (#match? @x "^(int|bool|bv)")) @type.builtin
; ((other) @x
;   (#match? @x "^[$#.]")) @constant
; ((other) @x
;   (#match? @x "^(proc|prog)")) @keyword.function
; ((other) @x
;   (#match? @x "^block")) @keyword.conditional

"goto" @keyword.return
"unreachable" @keyword.return
"return" @keyword.return

["ensures" "ensure" "requires" "require"] @keyword

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
"shared" @keyword

(IntVal) @constant
(token_IntegerHex) @constant
(token_IntegerDec) @constant
"true" @constant
"false" @constant

(Type) @type
(token_BVTYPE) @type.builtin
(token_INTTYPE) @type.builtin
(token_BOOLTYPE) @type.builtin
(token_BIdent) @variable.member

(token_BlockIdent) @function.call
(Block (token_BlockIdent) @function)
"block" @keyword.conditional

(token_ProcIdent) @function.call
(Decl (token_ProcIdent) @function)
(Decl (list_Params) @variable.parameter)
"proc" @keyword.function

"prog" @keyword.directive
"entry" @keyword.directive

(BinOp) @function
(BoolBinOp) @function
(UnOp) @function
(EqOp) @function

"boolnot" @function
"intneg" @function
"booltobv1" @function
"eq" @function
"neq" @function
"bvnot" @function
"bvneg" @function
"bvand" @function
"bvor" @function
"bvadd" @function
"bvmul" @function
"bvudiv" @function
"bvurem" @function
"bvshl" @function
"bvlshr" @function
"bvnand" @function
"bvnor" @function
"bvxor" @function
"bvxnor" @function
"bvcomp" @function
"bvsub" @function
"bvsdiv" @function
"bvsrem" @function
"bvsmod" @function
"bvashr" @function
"bvule" @function
"bvugt" @function
"bvuge" @function
"bvult" @function
"bvslt" @function
"bvsle" @function
"bvsgt" @function
"bvsge" @function
"intadd" @function
"intmul" @function
"intsub" @function
"intdiv" @function
"intmod" @function
"intlt" @function
"intle" @function
"intgt" @function
"intge" @function
"booland" @function
"boolor" @function
"boolimplies" @function
"zero_extend" @function
"sign_extend" @function
"extract" @function
"bvconcat" @function

[
  (token_BeginList)
  (token_EndList)
  (token_BeginRec)
  (token_EndRec)
] @punctuation.bracket

[ ";" "," ] @punctuation.delimiter
[ ":" "=" ":=" ] @punctuation
[ "(" ")"
  (token_BeginRec)
  (token_EndRec)
  (token_BeginList)
  (token_EndList) ] @punctuation.bracket

(token_Str) @string

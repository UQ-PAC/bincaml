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

"call" @function.call
"indirect" @function.call

"nop" @keyword
"load" @keyword
"store" @keyword
"guard" @keyword
"assert" @keyword
"assume" @keyword
"var" @keyword
"memory" @keyword
"shared" @keyword

(IntVal) @constant
"true" @constant
"false" @constant

(Type) @type
(token_BVTYPE) @type.builtin
(token_INTTYPE) @type.builtin
(token_BOOLTYPE) @type.builtin
(token_BIdent) @constant

(token_BlockIdent) @function.call
"block" @keyword.conditional

(token_ProcIdent) @function.call
"proc" @function.def

"prog" @keyword.directive
"entry" @keyword.directive

(BinOp) @function
(BoolBinOp) @function
(UnOp) @function
(EqOp) @function
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
[ ":" "(" ")" "=" ":=" ] @punctuation

(token_Str) @string

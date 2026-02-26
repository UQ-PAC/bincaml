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

(Jump "goto" @keyword)
(Jump "unreachable" @keyword)
(Jump "return" @keyword.return)

(Stmt "call" @keyword.function)
(Stmt "indirect" @keyword.function)
(Stmt "nop" @keyword)
(Stmt "load" @keyword)
(Stmt "store" @keyword)
(Stmt "guard" @keyword)
(Stmt "assert" @keyword)
(Stmt "assume" @keyword)

(Decl "var" @keyword)
(Decl "memory" @keyword)
(Decl "shared" @keyword)

(IntVal) @constant
"true" @constant
"false" @constant

(Type) @type
(BVType) @type.builtin
(IntType) @type.builtin
(BoolType) @type.builtin
(token_BIdent) @constant

(token_BlockIdent) @function.call
"block" @keyword.conditional

(token_LocalIdent) @variable
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

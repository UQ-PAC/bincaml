(keyword) @keyword
(other) @variable
((other) @x
  (#match? @x "^//.*")) @comment
((other) @x
  (#match? @x "^/\\*.*")) @comment
((other) @x
  (#match? @x "^[^a-zA-Z_0-9]+$")) @punctuation.delimiter
((other) @x
  (#match? @x "^[\"']")) @string
((other) @x
  (#match? @x "^(->|\\=|:\\=)$")) @operator
((other) @x
  (#match? @x "^[0-9]")) @number
((other) @x
  (#match? @x "^(int|bool|bv)")) @type.builtin
((other) @x
  (#match? @x "^[@%]")) @function.call
((other) @x
  (#match? @x "^[$#.]")) @constant
((other) @x
  (#match? @x "^(proc|prog)")) @keyword.function
((other) @x
  (#match? @x "^block")) @keyword.conditional

((other) @x
  (#match? @x "^(var|assert|assume|return|goto|load|store|unreachable)$")) @keyword.return

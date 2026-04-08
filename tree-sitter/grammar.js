let bnfc_grammar = require("./grammar.bnfc.js");

// Manually define some conflict and precedence resolution rules.
// This imports the generated Tree-sitter grammar which is grammar.bnfc.js
module.exports = grammar({
  ...bnfc_grammar,
  conflicts: $ => [
    [$.Expr, $.LocalVar]
  ],
  precedences: $ => [
    [$.Expr2, $.Expr1, $.Expr],
  ],
});

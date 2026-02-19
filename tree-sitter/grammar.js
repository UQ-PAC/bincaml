/**
 * @file Basilir grammar for tree-sitter
 * @author UQ PAC
 * @license MIT
 */

/// <reference types="tree-sitter-cli/dsl" />
// @ts-check

module.exports = grammar({
  name: "basilir",

  rules: {
    // TODO: add the actual grammar rules
    source_file: $ => "hello"
  }
});

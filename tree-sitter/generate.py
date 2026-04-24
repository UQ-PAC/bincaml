#!/usr/bin/env python3

with open('/home/rina/progs/obasil/lib/fe/basilir/__init__.py') as f:
    pygments = f.read()

Comment = 'comment'
Name = 'name'
Operator = 'operator'
class Number:
    Integer = 'number_integer'
    Float = 'number_float'
class String:
    Double = 'string_double'
    Char = 'string_char'
class Token:
    Space = 'token_space'

pygments = pygments.replace('import pygments.lexer', '').replace('from pygments.token import *', '').replace('pygments.lexer.RegexLexer', '')

exec(pygments)

print(BasilIRLexer.KEYWORDS)
tokens = BasilIRLexer.tokens['root']
for i, (token, kind) in enumerate(tokens):
    if token == r'/\*((.)(?<!\*))*\*((.)(?<![\*/])((.)(?<!\*))*\*|\*)*/':
        tokens[i] = (r'/\*.*?\*/', kind)
    elif token == r'"((.)(?<!["\\])|\\["\\nt])*"' or token == r'"((.)(?<!["\\])|\\["\\fnrt])*"':
        tokens[i] = (r'"(?:[^\\"]|\\.)*"', kind)
    elif token == r'\'((.)(?<![\'\\])|\\[\'\\nt])\'':
        tokens[i] = (r"'(?:[^\\']|\\.)*'", kind)
    elif token.startswith('$'):
        tokens[i] = ('\\' + token, kind)

import json

keywords = f'$ => choice({',\n'.join(json.dumps(x) for x in BasilIRLexer.KEYWORDS)})'
other = f'$ => choice({',\n'.join(f'new RustRegex({json.dumps(x)})' for x, _ in tokens)})'

grammar = '''
/**
 * @file Basilir grammar for tree-sitter
 * @author UQ PAC
 * @license MIT
 */

/// <reference types="tree-sitter-cli/dsl" />
// @ts-check

module.exports = grammar({
  name: "basilir",

  extras: ($) => [
    new RustRegex("\\\\s"),
  ],

  rules: {
    // TODO: add the actual grammar rules
    source_file: $ => repeat(choice($.keyword, $.other)),
    keyword: %s,
    other: %s,
  }
});
''' % (keywords, other)

with open('grammar.js', 'w') as f:
    f.write(grammar)

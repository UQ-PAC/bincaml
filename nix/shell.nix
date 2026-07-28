{
  lib,
  stdenv,
  mkShell,

  # ocaml packages
  opam,
  dune,
  findlib,
  bincaml,
  bincaml_lsp,
  odoc,
  odig,
  ocaml-lsp,
  ocamlformat,

  # dev packages
  tree-sitter,
  nodejs-slim,
  perf,
  bnfc-treesitter,
  boogie,
  cvc5,
  linol-lwt,
  linol,
  capstone,

  # lsp
  logs,
  mtime,
  z3,
}:

mkShell {
  buildInputs = [
    capstone
  ];

  packages = [
    opam
    findlib
    dune
    odoc
    odig
    ocaml-lsp
    ocamlformat
    tree-sitter
    nodejs-slim
    bnfc-treesitter
    boogie
    cvc5
    # bincaml_lsp
    linol
    linol-lwt
    logs
    mtime
    z3.out
    # sherlodoc - not in nixpkgs?
  ]
  ++ lib.optional stdenv.hostPlatform.isLinux perf;

  inputsFrom = [
    (bincaml.overrideAttrs { doCheck = true; })
  ];

  shellHook = ''
    export ODIG_CACHE_DIR=~/.cache/odig
  '';
}

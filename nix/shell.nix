{
  lib,
  stdenv,
  mkShell,

  # ocaml packages
  bincaml,
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
}:

mkShell {
  packages = [
    odoc
    odig
    ocaml-lsp
    ocamlformat
    tree-sitter
    nodejs-slim
    bnfc-treesitter
    boogie
    cvc5
    # sherlodoc - not in nixpkgs?
  ]
  ++ lib.optional stdenv.hostPlatform.isLinux perf;

  inputsFrom = [
    bincaml
  ];

  shellHook = ''
    export ODIG_CACHE_DIR=~/.cache/odig

    ocaml_hash="$(echo "$OCAMLPATH" | sha1sum | cut -d' ' -f1)"
    if [[ -z "$ocaml_hash" ]]; then
      echo 'cannot make ocaml hash - cannot cache odig'
      export ODIG_LIB_DIR="$(mktemp -d)/lib"
    else
      export ODIG_LIB_DIR="$ODIG_CACHE_DIR/$ocaml_hash"
    fi

    if ! [[ -d "$ODIG_LIB_DIR" ]]; then
      mkdir -p "$ODIG_LIB_DIR"
      IFS=':' read -ra ADDR <<< "$OCAMLPATH"
      for i in "''${ADDR[@]}"; do
        ln -sf $i/* "$ODIG_LIB_DIR"
      done
    fi
  '';
}

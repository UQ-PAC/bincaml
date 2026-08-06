{
  isShellForCI,

  lib,
  stdenv,
  mkShell,

  # ocaml packages
  bincaml,
  bincaml_lsp,
  capstone_arm64_disas,
  odoc,
  odoc-driver,
  odig,
  ocaml-lsp,
  ocamlformat,
  opam,

  # dev packages
  perf,
}:

mkShell {
  packages = [
    odoc
    odoc-driver
    odig
    ocamlformat
  ]

  ++ lib.optionals (!isShellForCI) (
    [
      bincaml_lsp
      ocaml-lsp
    ]
    ++ lib.optional stdenv.hostPlatform.isLinux perf
  )

  ++ lib.optionals (isShellForCI) [
    opam
  ];

  inputsFrom = [
    (bincaml.overrideAttrs { doCheck = true; })
    (capstone_arm64_disas.overrideAttrs { doCheck = true; })
    (bincaml_lsp.overrideAttrs { doCheck = true; })

    # including these unchanged will subtract them from the dependencies of each other:
    # https://github.com/NixOS/nixpkgs/blob/f9bb1890175874edf242921789e8e9fdfcc2023c/pkgs/build-support/mkshell/default.nix#L32-L34
    bincaml
    capstone_arm64_disas
    bincaml_lsp
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
  '' + lib.optionalString isShellForCI ''
    opam init --bare --disable-sandboxing $(mktemp -d) --quiet --no
    export OPAMCOLOR=never
  '';
}

Records versions of tools installed by Nix. These tool versions
are used in CI and in the Nix develop shell.

  $ mkdir nix
  > cp *.nix nix
  > cp ../flake.nix ../flake.lock ../.gitignore .

  $ git init --quiet -b dummy
  > git add .
  > git config user.email '41898282+github-actions[bot]@users.noreply.github.com'
  > git config user.name 'github-actions[bot]'
  > git commit --quiet -m dummy

  $ nix --quiet eval .#versions --raw \
  > | sort | uniq | grep -v 'writable-tmpdir-as-home-hook\|perf-linux'
  BNFC-2.9.6.3-unstable-2026-05-08
  Boogie-3.5.7
  capstone-5.0.9
  cmdliner-2.1.1
  cvc5-1.3.4
  dune-3.24.1
  nodejs-slim-24.19.0
  ocaml-5.4.1
  ocaml5.4.1-alcotest-1.9.1
  ocaml5.4.1-angstrom-0.16.1
  ocaml5.4.1-aslp_lifter_ocaml-1.1.0
  ocaml5.4.1-containers-3.18
  ocaml5.4.1-containers-data-3.18
  ocaml5.4.1-findlib-1.9.8
  ocaml5.4.1-fix-20250919
  ocaml5.4.1-fmt-0.11.0
  ocaml5.4.1-intPQueue-20250925
  ocaml5.4.1-iter-1.9
  ocaml5.4.1-kittyimg-0.1
  ocaml5.4.1-linenoise-1.5.1
  ocaml5.4.1-linol-0.11
  ocaml5.4.1-linol-lwt-0.11
  ocaml5.4.1-logs-0.10.0
  ocaml5.4.1-menhir-20260203
  ocaml5.4.1-mtime-2.2.0
  ocaml5.4.1-ocaml-protoc-plugin-6.1.0
  ocaml5.4.1-ocamlformat-0.29.0
  ocaml5.4.1-ocamlgraph-2.2.0
  ocaml5.4.1-odig-0.1.0
  ocaml5.4.1-odoc-3.2.1
  ocaml5.4.1-odoc-driver-3.2.1
  ocaml5.4.1-patricia-tree-0.11.0
  ocaml5.4.1-pp_loc-2.1.0
  ocaml5.4.1-ppx_deriving-6.1.1
  ocaml5.4.1-ppx_expect-0.17.3
  ocaml5.4.1-qcheck-alcotest-0.91
  ocaml5.4.1-qcheck-core-0.91
  ocaml5.4.1-qcheck-stm-0.11
  ocaml5.4.1-stb_image-0.5
  ocaml5.4.1-terminal_size-0.2.0
  ocaml5.4.1-trace-0.5
  ocaml5.4.1-trace-tef-0.5
  ocaml5.4.1-unionFind-20250818
  ocaml5.4.1-zarith-1.14
  opam-2.5.2
  protobuf-35.1
  tree-sitter-0.26.9
  z3-4.16.0

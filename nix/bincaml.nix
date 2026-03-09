{ lib
, buildDunePackage
, nix-gitignore
, writableTmpDirAsHomeHook

# ocaml packages
, menhir
, zarith
, fix
, trace
, trace-tef
, containers
, containers-data
, iter
, ppx_deriving
, ocamlgraph
, intPQueue
, cmdliner
, pp_loc
, fmt
, patricia-tree

# test:
, ppx_expect
, alcotest
, qcheck-core
, qcheck-alcotest
, qcheck-stm

# dev:
# , odig
# , sherlodoc
# , ocaml-lsp-server
# , ocamlformat
# , basil_lsp
# , perf
# , tree-sitter
# , nodejs
}:

buildDunePackage {
  pname = "bincaml";
  version = "0.0";

  minimalOCamlVersion = "5.0";

  src = nix-gitignore.gitignoreSource [ "nix" "flake.nix" "flake.lock" ] ./..;

  checkInputs = [ ppx_expect alcotest qcheck-core qcheck-alcotest qcheck-stm ];
  nativeBuildInputs = [ menhir writableTmpDirAsHomeHook ];
  buildInputs =
    [ menhir fix trace trace-tef containers containers-data iter
      ppx_deriving ocamlgraph intPQueue cmdliner pp_loc fmt patricia-tree ];
  propagatedBuildInputs = [ zarith ];

  doCheck = true;
  outputs = [ "out" "dev" ];

  meta = {
    homepage = "https://github.com/agle/bincaml";
    description = "binary decompiler for verification";
    maintainers = with lib.maintainers; [ katrinafyi ];
    mainProgram = "bincaml";
  };
}

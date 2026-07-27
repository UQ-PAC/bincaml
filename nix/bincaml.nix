{
  lib,
  buildDunePackage',
  nix-gitignore,
  writableTmpDirAsHomeHook,
  protobuf,

  # ocaml packages
  menhir,
  angstrom,
  ocaml-protoc-plugin,
  zarith,
  fix,
  trace,
  trace-tef,
  containers,
  containers-data,
  iter,
  ppx_deriving,
  ocamlgraph,
  intPQueue,
  cmdliner,
  pp_loc,
  fmt,
  patricia-tree,
  logs,
  mtime,
  terminal_size,
  kittyimg,
  stb_image,
  linenoise,
  unionFind,

  capstone_arm64_disas,
  aslp_lifter_ocaml,

  # test:
  ppx_expect,
  alcotest,
  qcheck-core,
  qcheck-alcotest,
  qcheck-stm,

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

buildDunePackage' {
  pname = "bincaml";
  version = "0.0";

  minimalOCamlVersion = "5.0";

  src = nix-gitignore.gitignoreSource [ "nix" "flake.nix" "flake.lock" ] ./..;

  checkInputs = [
    alcotest
    qcheck-core
    qcheck-alcotest
    qcheck-stm
  ];
  nativeBuildInputs = [
    writableTmpDirAsHomeHook
    protobuf
    ocaml-protoc-plugin
    menhir
  ];
  propagatedBuildInputs = [
    ocaml-protoc-plugin
    angstrom
    zarith
    ppx_expect
    pp_loc
    ppx_deriving
    containers
    containers-data
    ocamlgraph
    menhir
    fix
    trace
    trace-tef
    iter
    intPQueue
    cmdliner
    fmt
    patricia-tree
    logs
    mtime
    unionFind
    terminal_size
    kittyimg
    linenoise
    stb_image
    capstone_arm64_disas
    aslp_lifter_ocaml
    qcheck-core
    qcheck-alcotest
    qcheck-stm
  ];

  postPatch = ''
    patchShebangs --build test
  '';

  doCheck = true;
  outputs = [
    "out"
    "dev"
  ];

  meta = {
    homepage = "https://github.com/agle/bincaml";
    description = "binary decompiler for verification";
    maintainers = with lib.maintainers; [ katrinafyi ];
    mainProgram = "bincaml";
  };
}

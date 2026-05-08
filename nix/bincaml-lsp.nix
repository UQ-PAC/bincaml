{
  lib,
  buildDunePackage,
  nix-gitignore,
  writableTmpDirAsHomeHook,

  # ocaml packages
  bincaml,
  logs,
  fmt,
  iter,
  linol,
  linol-lwt,
  containers,
  ppx_deriving,
  ppx_import,

  # test:

  # dev:
}:

buildDunePackage {
  pname = "bincaml_lsp";
  version = "0.0";

  minimalOCamlVersion = "5.0";

  src = nix-gitignore.gitignoreSource [ "nix" "flake.nix" "flake.lock" ] ./..;

  checkInputs = [ ];
  nativeBuildInputs = [ writableTmpDirAsHomeHook ];
  buildInputs = [
    bincaml
    logs
    fmt
    iter
    containers
    ppx_deriving
  ];
  propagatedBuildInputs = [
    linol
    linol-lwt
    ppx_import
  ];

  doCheck = true;
  outputs = [
    "out"
    "dev"
  ];

  meta = {
    homepage = "https://github.com/agle/bincaml";
    description = "language server for bincaml intermediate representation";
    maintainers = with lib.maintainers; [ katrinafyi ];
    mainProgram = "bincaml";
  };
}

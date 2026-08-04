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
    linol
    linol-lwt
  ];

  doCheck = true;
  outputs = [ "out" ];

  meta = {
    homepage = "https://github.com/agle/bincaml";
    description = "language server for bincaml intermediate representation";
    maintainers = with lib.maintainers; [ katrinafyi ];
    mainProgram = "bincaml";
  };
}

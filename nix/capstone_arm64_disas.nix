{
  lib,
  buildDunePackage,
  writableTmpDirAsHomeHook,
  capstone,

  # ocaml packages
  bincaml,
  logs,
  fmt,
  iter,
  linol,
  linol-lwt,
  containers,
  ppx_deriving,
  ppx_expect,

  # test:

  # dev:
}:

buildDunePackage {
  pname = "capstone_arm64_disas";
  version = "0.0";

  minimalOCamlVersion = "5.0";

  inherit (bincaml) src;

  checkInputs = [ ];
  nativeBuildInputs = [ writableTmpDirAsHomeHook ];
  buildInputs = [
    logs
    fmt
    iter
    linol
    linol-lwt
    containers
    ppx_deriving
    ppx_expect
  ];
  propagatedBuildInputs = [ capstone ];

  outputs = [ "out" ];

  meta = {
    homepage = "https://github.com/agle/bincaml";
    description = "";
    maintainers = with lib.maintainers; [ katrinafyi ];
    mainProgram = "bincaml";
  };
}

{
  lib,
  buildDunePackage,
  writableTmpDirAsHomeHook,

  # ocaml packages
  ocaml,
  bincaml,
  containers,
  re

  # test:

  # dev:
}:

buildDunePackage {
  pname = "boogieml";
  version = "0.0";

  minimalOCamlVersion = "5.0";

  inherit (bincaml) src;

  checkInputs = [ ];
  nativeBuildInputs = [ writableTmpDirAsHomeHook ];
  buildInputs = [ ocaml ];
  propagatedBuildInputs = [ ];

  outputs = [ "out" ];
  doCheck = false; # missing (package) declarations in dune files

  meta = {
    homepage = "https://github.com/agle/bincaml";
    description = "";
    maintainers = with lib.maintainers; [ katrinafyi ];
    mainProgram = "bincaml";
  };
}

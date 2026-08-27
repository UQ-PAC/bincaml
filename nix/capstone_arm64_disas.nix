{
  lib,
  buildDunePackage,
  writableTmpDirAsHomeHook,
  capstone,

  # ocaml packages
  ocaml,
  bincaml,

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
  buildInputs = [ ocaml ];
  propagatedBuildInputs = [ capstone ];

  outputs = [ "out" ];
  doCheck = false; # missing (package) declarations in dune files

  meta = {
    homepage = "https://github.com/agle/bincaml";
    description = "";
    maintainers = with lib.maintainers; [ katrinafyi ];
    mainProgram = "bincaml";
  };
}

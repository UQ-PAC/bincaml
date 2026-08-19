{
  lib,
  buildDunePackage,
  nix-gitignore,
  writableTmpDirAsHomeHook,
  capstone,

  # ocaml packages
  ocaml

  # test:

  # dev:
}:

buildDunePackage {
  pname = "capstone_arm64_disas";
  version = "0.0";

  minimalOCamlVersion = "5.0";

  src = nix-gitignore.gitignoreSource [ "nix" "flake.nix" "flake.lock" ] ./..;

  checkInputs = [ ];
  nativeBuildInputs = [ writableTmpDirAsHomeHook ];
  buildInputs = [ ocaml ];
  propagatedBuildInputs = [ capstone ];

  doCheck = false;
  outputs = [
    "out"
    "dev"
  ];

  meta = {
    homepage = "https://github.com/agle/bincaml";
    description = "";
    maintainers = with lib.maintainers; [ katrinafyi ];
    mainProgram = "bincaml";
  };
}

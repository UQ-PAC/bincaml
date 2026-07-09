{
  lib,
  buildDunePackage,
  fetchFromGitHub,
}:

buildDunePackage (self: {
  pname = "aslp_lifter_ocaml";
  version = "1.1.0";

  minimalOCamlVersion = "4.08";

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "aslp-lifter-ocaml";
    rev = self.version;
    hash = "sha256-Hlp9LwXHx4Xii0PrmucuSzMvsyaCSho5jKkoyhn82mg=";
  };

  checkInputs = [ ];
  nativeBuildInputs = [ ];
  buildInputs = [ ];
  propagatedBuildInputs = [ ];

  outputs = [
    "out"
    "dev"
  ];

  meta = {
    homepage = "https://github.com/UQ-PAC/aslp-lifter-ocaml";
    description = "";
    maintainers = with lib.maintainers; [ katrinafyi ];
  };
})

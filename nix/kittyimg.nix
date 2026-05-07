{
  lib,
  buildDunePackage,
  fetchFromGitHub,

  # ocaml packages
  base64,
}:

buildDunePackage (self: {
  pname = "kittyimg";
  version = "0.1";

  minimalOCamlVersion = "4.08";

  src = fetchFromGitHub {
    owner = "Armael";
    repo = "ocaml-kittyimg";
    rev = self.version;
    hash = "sha256-jDiiQAZRzZaIACunNNfqCd5gwJ2BKGiMpTxWJt9jtgs=";
  };

  checkInputs = [ ];
  nativeBuildInputs = [ ];
  buildInputs = [ ];
  propagatedBuildInputs = [ base64 ];

  outputs = [
    "out"
    "dev"
  ];

  meta = {
    homepage = "https://github.com/Armael/ocaml-kittyimg";
    description = "Implementation of kitty's terminal graphics protocol";
    maintainers = with lib.maintainers; [ katrinafyi ];
  };
})

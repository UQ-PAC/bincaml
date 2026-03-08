{ lib
, buildDunePackage
, fetchFromGitHub

# ocaml packages
, hector
}:

buildDunePackage {
  pname = "intPQueue";
  version = "20250925";

  minimalOCamlVersion = "4.14";

  src = fetchFromGitHub {
    owner = "fpottier";
    repo = "intPQueue";
    rev = "867de385bab00833a5919ac8ec148b5f8bd81900";
    hash = "sha256-fycOdbQ+Fm5nJnDdbCmF0pTUNG8Uh+kQnAoWDnpJ6tY=";
  };

  checkInputs = [ ];
  nativeBuildInputs = [ ];
  buildInputs = [ ];
  propagatedBuildInputs = [ hector ];

  outputs = [ "out" "dev" ];

  meta = {
    homepage = "https://github.com/fpottier/intPQueue";
    description = "A fast and compact priority queue with low integer keys";
    maintainers = with lib.maintainers; [ katrinafyi ];
  };
}

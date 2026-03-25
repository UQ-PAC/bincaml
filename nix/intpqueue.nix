{ lib
, buildDunePackage
, fetchFromGitHub

# ocaml packages
, hector
}:

buildDunePackage (self: {
  pname = "intPQueue";
  version = "20250925";

  minimalOCamlVersion = "4.14";

  src = fetchFromGitHub {
    owner = "fpottier";
    repo = "intPQueue";
    rev = self.version;
    hash = "sha256-nnFh/Urnf3oT/s1WcXuo/zLu9A6yIRzUB2dEpTwKqF0=";
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
})

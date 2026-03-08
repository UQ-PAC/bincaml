{ lib
, buildDunePackage
, fetchFromGitHub

# ocaml packages
, cppo
}:

buildDunePackage (final: {
  pname = "hector";
  version = "20241208";

  minimalOCamlVersion = "4.14";

  src = fetchFromGitHub {
    owner = "fpottier";
    repo = "hector";
    rev = final.version;
    hash = "sha256-sTNPt5s0lBUZ6+bUV36LYdBj71q5EzlJaj1duIqqtZQ=";
  };

  checkInputs = [ ];
  nativeBuildInputs = [ cppo ];
  buildInputs = [ ];
  propagatedBuildInputs = [ ];

  outputs = [ "out" "dev" ];

  meta = {
    homepage = "https://github.com/fpottier/hector";
    description = "A vector library for OCaml";
    maintainers = with lib.maintainers; [ katrinafyi ];
  };
})

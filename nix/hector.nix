{ lib
, buildDunePackage
, fetchFromGitHub

# ocaml packages
, cppo
}:

buildDunePackage {
  pname = "hector";
  version = "20241208";

  minimalOCamlVersion = "4.14";

  src = fetchFromGitHub {
    owner = "fpottier";
    repo = "hector";
    rev = "87ef35d18a8661e48b650959c20faba8f52dde08";
    hash = "sha256-yFFgZOIzOloJmc8wm0VoOTJYK/NWUV0mBNEmZE7t500=";
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
}

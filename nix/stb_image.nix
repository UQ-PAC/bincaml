{
  lib,
  stdenv,
  fetchFromGitHub,
  ocaml,
  findlib,
  result,

  # ocaml packages
}:

stdenv.mkDerivation (self: {
  name = "ocaml${ocaml.version}-${self.pname}-${self.version}";
  pname = "stb_image";
  version = "0.5";

  minimalOCamlVersion = "4.02";

  src = fetchFromGitHub {
    owner = "let-def";
    repo = "stb_image";
    rev = "v${self.version}";
    hash = "sha256-5TOZiGZWUhgvtISdV+lNVI+YIXLSdwzkuV3sL5eT34Y=";
  };

  checkInputs = [ ];
  nativeBuildInputs = [
    ocaml
    findlib
  ];
  buildInputs = [ result ];
  propagatedBuildInputs = [ ];

  outputs = [
    "out"
    "dev"
  ];

  buildPhase = ''
    runHook preBuild
    make
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/ocaml/${ocaml.version}/site-lib
    make install
    runHook postInstall
  '';

  meta = {
    homepage = "https://github.com/let-def/std_image";
    description = "OCaml bindings to stb_iamge, a public domain image loader";
    maintainers = with lib.maintainers; [ katrinafyi ];
  };
})

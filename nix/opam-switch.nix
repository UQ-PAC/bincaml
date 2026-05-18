{ lib
, stdenv
, fetchFromGitHub
, emptyDirectory
, git

# ocaml packages
, intPQueue
, opam
, ocaml
, cppo
, findlib
, hector
, dune
}:

stdenv.mkDerivation (self: {
  pname = "ocaml-switch-asdf";
  version = "20241208";

  src = fetchFromGitHub {
    owner = "ocaml";
    repo = "opam-repository";
    rev = "28d044eb9ccd9b9275c54a845b30932c3d934aa0";
    hash = "sha256-NGdSDCPF/FeWmhAcMXTbLle8l3snGsnqAnujJu/C8Kk=";
  };

  checkInputs = [ ];
  nativeBuildInputs = [ opam ocaml dune findlib cppo ];
  buildInputs = [ hector ];
  propagatedBuildInputs = [ ];

  env.OPAMYES = "true";

  preBuild = ''
    export OPAMROOT=$out
    opam init --disable-sandboxing "$src" --bare --no-setup
    opam option --global 'archive-mirrors+="${/home/rina/.opam/download-cache}"'
    cp ${/home/rina/progs/obasil/bincaml.opam} $out/bincaml.opam
    opam switch create $out --deps-only ocaml-system
    opam list
    opam install hector --fake
    opam install intPQueue
    opam repository set-url default https://opam.ocaml.org
  '';

  outputs = [ "out" "dev" ];

  meta = {
    homepage = "https://github.com/fpottier/hector";
    description = "A vector library for OCaml";
    maintainers = with lib.maintainers; [ katrinafyi ];
  };
})

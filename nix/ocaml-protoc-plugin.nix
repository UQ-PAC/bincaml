{ fetchFromGitHub
, ocaml-protoc-plugin
, dune-configurator
, ptime
, base64
, protobuf
, ppx_expect }:

# XXX: avoid this by properly importing pac-nix

ocaml-protoc-plugin.overrideAttrs (p: {
  version = "6.1.0";
  src = fetchFromGitHub {
    owner = "andersfugmann";
    repo = "ocaml-protoc-plugin";
    rev = "6.1.0";
    hash = "sha256-d7ZpXRL/d6/MY9/wqrDAKsalRqSuQseGLLzA+E3m24o=";
  };
  buildInputs = p.buildInputs ++ [ dune-configurator base64 ];
  propagatedBuildInputs = (p.propagatedBuildInputs or []) ++ [ ppx_expect ptime ];
  postPatch = ''
    substituteInPlace test/config/discover.ml --replace-fail 'conf.cflags;' '(["-std=c++17"] @ conf.cflags);';
  '';
})

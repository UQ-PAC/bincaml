{
  dune_3,
  fetchFromGitHub,
}:

dune_3.overrideAttrs {
  version = "3.24.1";
  src = fetchFromGitHub {
    owner = "ocaml";
    repo = "dune";
    rev = "3.24.1";
    hash = "sha256-hks62JafKmKdkRGTLTVV8c5/OZQYmDtT4L+4JeCPxfc=";
  };
}

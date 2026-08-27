{
  dune_3,
  fetchurl,
}:

dune_3.overrideAttrs {
  version = "3.24.1";
  src = fetchurl {
    url = "https://github.com/ocaml/dune/releases/download/3.24.1/dune-3.24.1.tbz";
    hash = "sha256-Co6qYt/LlFgCvK+abyAmylIoMz7jkaG97dPnCj8m6iw=";
  };
}

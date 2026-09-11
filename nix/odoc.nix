/**
  Patches `ocamlPackages.odoc` to fix its dependency specification and enable use
  as a library. Also update the version to fix failing cmdliner tests.
*/
{
  odoc,
  fetchurl,
  cmdliner,
  ppx_expect,
}:

(odoc.override {
  cmdliner = cmdliner;
}).overrideAttrs
  (
    _: prev: {
      version = "3.2.1";
      src = fetchurl {
        url = "https://github.com/ocaml/odoc/releases/download/3.2.1/odoc-3.2.1.tbz";
        hash = "sha256-1F6xJVFIOf2awncCu0k40bTztpeOmxarlnPqBnJFr/w=";
      };

      propagatedBuildInputs =
        (prev.propagatedBuildInputs or [ ]) ++ (prev.buildInputs or [ ]) ++ [ ppx_expect ];
    }
  )

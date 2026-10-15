/**
  Patches `ocamlPackages.odoc` to fix its dependency specification and enable use
  as a library. Also update the version to fix `include_subdirs` issues.
*/
{
  odoc,
  fetchFromGitHub,
  cmdliner,
  ppx_expect,
}:

(odoc.override {
  cmdliner = cmdliner;
}).overrideAttrs
  (
    _: prev: {
      version = "3.2.1-patched";

      # fixing https://github.com/ocaml/odoc/issues/1475
      src = fetchFromGitHub {
        owner = "rsc-s";
        repo = "odoc";
        rev = "350529a5edfdb560d6e24417903e07ae48022b59";
        hash = "sha256-rjTDigWOYGw8wxPEyeWezINwlTm2FEi++gjoW5CJb5g=";
      };

      propagatedBuildInputs =
        (prev.propagatedBuildInputs or [ ]) ++ (prev.buildInputs or [ ]) ++ [ ppx_expect ];
    }
  )

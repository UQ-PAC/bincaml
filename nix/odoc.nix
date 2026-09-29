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
        rev = "67b11fe751bd369620c93c89641c31d8b13a2633";
        hash = "sha256-oomK4wLBrxca0M4virPLh3fWb/OOdGkaB2qnSjsQ1yk=";
      };

      propagatedBuildInputs =
        (prev.propagatedBuildInputs or [ ]) ++ (prev.buildInputs or [ ]) ++ [ ppx_expect ];
    }
  )

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
        rev = "bd961999c1e24332c26066fe63244092e143b254";
        hash = "sha256-UDD1o1jaSJadiNmPW98vM2FukbzNDWrlXjdcy8KDPfo=";
      };

      propagatedBuildInputs =
        (prev.propagatedBuildInputs or [ ]) ++ (prev.buildInputs or [ ]) ++ [ ppx_expect ];
    }
  )

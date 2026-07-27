# Like buildDunePackage but it does not inject dune to nativeBuildInputs.
# This allows the package Nix file to provide its own Dune version.

# https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/ocaml/dune.nix,

{
  buildDunePackage,
}:

args:
(buildDunePackage args).overrideAttrs (
  final: prev: {
    nativeBuildInputs = builtins.filter (dep: dep.pname != "dune") (prev.nativeBuildInputs or [ ]);
  }
)

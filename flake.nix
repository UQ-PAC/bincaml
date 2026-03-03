{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    opam-nix.inputs.nixpkgs.follows = "nixpkgs";
    opam-nix.url = "github:tweag/opam-nix";
    dune-nix.inputs.nixpkgs.follows = "nixpkgs";
    dune-nix.url = "github:o1-labs/dune-nix";
    opam-nix.inputs.flake-utils.follows = "flake-utils";
    opam-nix.inputs.opam-repository.follows = "opam-repository";
    opam-repository = {
      url = "github:ocaml/opam-repository";
      flake = false;
    };
    pac-opam = {
      url = "github:uq-pac/opam-repository";
      flake = false;
    };
  };
  outputs =
    {
      flake-utils,
      opam-nix,
      dune-nix,
      nixpkgs,
      pac-opam,
      opam-repository,
      ...
    }:
    let
      deps = opam-nix.opamListToQuery (opam-nix.importOpam ./opam.export).installed;
    in
    let
      package = "bincaml";
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        on = opam-nix.lib.${system};
        base-libs = dune-nix.lib.${pkgs.system}.squashOpamNixDeps scope.ocaml.version (
          pkgs.lib.attrVals (builtins.attrNames deps) scope
        );
        query = base-libs // {
          ocaml-compiler = "5.3.0";
          ocaml-variants = "5.3.0+options";
          ocaml-option-fp = "*";
          ocaml-option-flambda = "*";
        };
        scope = on.buildOpamProject' {
          repos = [
            pac-opam
            opam-repository
          ];
        } ./. query;
        overlay = final: prev: {
          ${package} = prev.${package}.overrideAttrs (_: {
            doNixSupport = true;
          });
        };
        scope' = scope.overrideScope overlay;
        main = scope'.${package};
      in
      {
        legacyPackages = scope';

        packages.default = main;

        devShells.default = pkgs.mkShell {
          inputsFrom = [ main ];
          buildInputs = base-libs ++ [
            main
            pkgs.perf
            pkgs.tree-sitter
            pkgs.nodejs
          ];
        };
      }
    );
}

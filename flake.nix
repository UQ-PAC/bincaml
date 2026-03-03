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
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        export = opam-nix.lib.${pkgs.system}.importOpam ./opam.export;
        implicit-deps =
          builtins.removeAttrs (opam-nix.lib.${pkgs.system}.opamListToQuery export.installed)
            [
              "check_opam_switch"
            ];
        extra-packages = {
          ocaml-lsp-server = "*";
        };
        deps = opam-nix.lib.${pkgs.system}.opamListToQuery (export).installed;
        pkgs = nixpkgs.legacyPackages.${system};
        repos = [
          pac-opam
          opam-repository
        ];
        scope = opam-nix.lib.${pkgs.system}.applyOverlays (opam-nix.lib.${pkgs.system}.__overlays) (
          opam-nix.lib.${pkgs.system}.defsToScope pkgs { } (
            opam-nix.lib.${pkgs.system}.queryToDefs repos (extra-packages // implicit-deps)
          )
        );
        base-libs = dune-nix.lib.${pkgs.stdenv.hostPlatform.system}.squashOpamNixDeps scope.ocaml.version (
          pkgs.lib.attrVals (builtins.attrNames deps) scope
        );
      in
      {

        devShells.default = pkgs.mkShell {
          buildInputs = [
            base-libs
            pkgs.perf
            pkgs.tree-sitter
            pkgs.nodejs
          ];
        };
      }
    );
}

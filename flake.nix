{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };
  outputs =
    { self
    , nixpkgs
    }:
    let
      supported-systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs supported-systems (
          system:
          f rec {
            inherit system;

            pkgs = nixpkgs.legacyPackages.${system};
            selfPackages = self.packages.${system};

            selfOcamlPackages = pkgs.ocamlPackages.overrideScope (ofinal: oprev: {
              bincaml = ofinal.callPackage ./nix/bincaml.nix { };
              hector = ofinal.callPackage ./nix/hector.nix { };
              intPQueue = ofinal.callPackage ./nix/intpqueue.nix { };
            });
          }
        );
    in
    {
      packages = forAllSystems ({ pkgs, selfPackages, selfOcamlPackages, ... }: {
        default = selfOcamlPackages.bincaml;
        bincaml = selfOcamlPackages.bincaml;
        intPQueue = selfOcamlPackages.intPQueue;
        hector = selfOcamlPackages.hector;
      });

      devShells = forAllSystems ({ pkgs, selfPackages, selfOcamlPackages, ... }: {

        default = pkgs.mkShell {

          packages = with selfOcamlPackages; [
            odig ocaml-lsp ocamlformat
            pkgs.tree-sitter
            # sherlodoc
          ] ++ pkgs.lib.optional pkgs.stdenv.hostPlatform.isLinux pkgs.perf;

          inputsFrom = [
            selfOcamlPackages.bincaml
          ];

          shellHook = ''
            export ODIG_CACHE_DIR=~/.cache/odig
          '';
        };

      });
    };
}

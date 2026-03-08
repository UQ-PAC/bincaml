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
              intPQueue = ofinal.callPackage ./nix/intPQueue.nix { };
            });
          }
        );
    in
    {
      packages = forAllSystems ({ pkgs, selfPackages, selfOcamlPackages, ... }: rec {
        default = selfOcamlPackages.bincaml;
        bincaml = selfOcamlPackages.bincaml;
        intPQueue = selfOcamlPackages.intPQueue;
        hector = selfOcamlPackages.hector;
        nix-update = pkgs.nix-update;
      });
    };
}

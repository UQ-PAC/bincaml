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

      makeBincamlOcamlPackages = ofinal: oprev: {
        bincaml = ofinal.callPackage ./nix/bincaml.nix { };
        hector = ofinal.callPackage ./nix/hector.nix { };
        intPQueue = ofinal.callPackage ./nix/intpqueue.nix { };
      };

      forAllSystems =
        f:
        nixpkgs.lib.genAttrs supported-systems (
          system:
          f rec {
            inherit system;

            pkgs = nixpkgs.legacyPackages.${system};
            selfPackages = self.legacyPackages.${system};

            selfOcamlPackages =
              pkgs.ocamlPackages.overrideScope makeBincamlOcamlPackages;

            # frame pointer enabled. slower build.
            fpOcamlPackages = selfOcamlPackages.overrideScope (ofinal: oprev: {
              # https://github.com/NixOS/nixpkgs/blob/aca4d95fce4914b3892661bcb80b8087293536c6/pkgs/development/compilers/ocaml/generic.nix#L30
              ocaml = (oprev.ocaml.override {

                flambdaSupport = true;
                framePointerSupport = true;

              }).overrideAttrs (ocaml: {

                patches = ocaml.patches ++ [
                  (pkgs.fetchpatch {
                    url = "https://github.com/ocaml/ocaml/commit/c2eec4dd1de7d0da2d2f76e5e7f2b567901f4e2c.patch";
                    hash = "sha256-qDx8saOLhFMYaK4PLsSvHnDBYKvRSMmPtdVa/IqkQSI=";
                  })
                ];

              });
            });
          }
        );
    in
    {
      defaultPackage = forAllSystems ({ selfPackages, ...}: selfPackages.bincaml);

      legacyPackages = forAllSystems ({ selfOcamlPackages, fpOcamlPackages, ... }: {
        bincaml = selfOcamlPackages.bincaml;
        intPQueue = selfOcamlPackages.intPQueue;
        hector = selfOcamlPackages.hector;

        fp.bincaml = fpOcamlPackages.bincaml;
        fp.intPQueue = fpOcamlPackages.intPQueue;
        fp.hector = fpOcamlPackages.hector;
      });

      devShells = forAllSystems ({ selfOcamlPackages, fpOcamlPackages, ... }: {
        default = selfOcamlPackages.callPackage ./nix/shell.nix { };
        fp = fpOcamlPackages.callPackage ./nix/shell.nix { };
      });
    };
}

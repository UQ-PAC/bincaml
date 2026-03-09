{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    infuse-src.url = "https://codeberg.org/amjoseph/infuse.nix/archive/trunk.tar.gz";
    infuse-src.flake = false;
  };
  outputs =
    { self
    , nixpkgs
    , infuse-src
    }@args:
    let
      inherit (nixpkgs) lib;

      inherit (import ./nix/infuse-lib.nix {
        lib = lib;
        infuse-src = infuse-src;
      }) infuse infuse-with;

      inherit (import ./nix/flake-for-all-systems.nix { lib = lib; })
        flake-for-all-systems;

    in flake-for-all-systems args {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      outputs = { self, nixpkgs, ... }:
        let
          pkgs = nixpkgs.legacyPackages;
          selfOcamlPackages =
            pkgs.ocamlPackages.overrideScope self.overlays.addBincamlPackages;
          fpOcamlPackages =
            selfOcamlPackages.overrideScope self.overlays.enableOcamlFramePointer;
        in
        {
          defaultPackage = selfOcamlPackages.bincaml;

          overlays = {
            addBincamlPackages = ofinal: _: {
              bincaml = ofinal.callPackage ./nix/bincaml.nix { };
              hector = ofinal.callPackage ./nix/hector.nix { };
              intPQueue = ofinal.callPackage ./nix/intpqueue.nix { };
            };

            enableOcamlFramePointer = ofinal: infuse-with {
              # https://github.com/NixOS/nixpkgs/blob/aca4d95fce4914b3892661bcb80b8087293536c6/pkgs/development/compilers/ocaml/generic.nix#L30
              ocaml.__input.flambdaSupport.__assign = true;
              ocaml.__input.framePointerSupport.__assign = true;
              ocaml.__attrs.patches.__append = [
                (pkgs.fetchpatch {
                  url = "https://github.com/ocaml/ocaml/commit/c2eec4dd1de7d0da2d2f76e5e7f2b567901f4e2c.patch";
                  hash = "sha256-qDx8saOLhFMYaK4PLsSvHnDBYKvRSMmPtdVa/IqkQSI=";
                })
              ];
            };
          };

          legacyPackages = {
            bincaml = selfOcamlPackages.bincaml;
            intPQueue = selfOcamlPackages.intPQueue;
            hector = selfOcamlPackages.hector;

            fp.bincaml = fpOcamlPackages.bincaml;
            fp.intPQueue = fpOcamlPackages.intPQueue;
            fp.hector = fpOcamlPackages.hector;
          };

          devShells = {
            default = selfOcamlPackages.callPackage ./nix/shell.nix { };
            fp = fpOcamlPackages.callPackage ./nix/shell.nix { };
          };
        }
      ;
    }
  ;
}

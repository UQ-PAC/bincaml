{
  inputs = {
    pac-nix.url = "github:katrinafyi/pac-nix";

    infuse-src.url = "https://codeberg.org/awarina/infuse.nix/archive/trunk.tar.gz";
    infuse-src.flake = false;
  };
  outputs =
    {
      self,
      infuse-src,
      pac-nix,
    }@args:
    let
      inherit (pac-nix.inputs) nixpkgs;
      inherit (nixpkgs) lib;

      inherit
        (import ./nix/infuse-lib.nix {
          lib = lib;
          infuse-src = infuse-src;
        })
        infuse
        infuse-with
        ;

      inherit (import ./nix/flake-for-all-systems.nix { lib = lib; })
        flake-for-all-systems
        ;

    in
    flake-for-all-systems (args // { inherit nixpkgs; }) {
      overlays = {
        addBincamlPackages = ofinal: _: {
          bincaml = ofinal.callPackage ./nix/bincaml.nix { };
          hector = ofinal.callPackage ./nix/hector.nix { };
          intPQueue = ofinal.callPackage ./nix/intpqueue.nix { };
        };

        enableOcamlFramePointer =
          ofinal:
          infuse-with {
            # https://github.com/NixOS/nixpkgs/blob/aca4d95fce4914b3892661bcb80b8087293536c6/pkgs/development/compilers/ocaml/generic.nix#L30
            ocaml.__input.flambdaSupport.__assign = true;
            ocaml.__input.framePointerSupport.__assign = true;
            ocaml.__attrs.doCheck.__assign = false; # speeds up and avoids test file bug
          };
      };

      systems = [
        "aarch64-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem =
        { self, system, nixpkgs, pac-nix, ... }:
        let
          bnfc-treesitter-pkgs = { inherit (pac-nix.legacyPackages) bnfc-treesitter; };

          pkgs = import nixpkgs {
            system = system;
            config.packageOverrides = _: bnfc-treesitter-pkgs;
          };
          selfOcamlPackages = pkgs.ocamlPackages.overrideScope self.overlays.addBincamlPackages;
          fpOcamlPackages = selfOcamlPackages.overrideScope self.overlays.enableOcamlFramePointer;
        in
        {
          defaultPackage = selfOcamlPackages.bincaml;

          legacyPackages = {
            bincaml = selfOcamlPackages.bincaml;
            intPQueue = selfOcamlPackages.intPQueue;
            hector = selfOcamlPackages.hector;

            fp.bincaml = fpOcamlPackages.bincaml;
            fp.intPQueue = fpOcamlPackages.intPQueue;
            fp.hector = fpOcamlPackages.hector;
          };

          devShells = {
            default = self.devShells.fp;
            fp = fpOcamlPackages.callPackage ./nix/shell.nix { };
            no-fp = selfOcamlPackages.callPackage ./nix/shell.nix { };
          };
        };
    };
}

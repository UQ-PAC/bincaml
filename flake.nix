{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    pac-nix.url = "github:katrinafyi/pac-nix";
    # WARNING: this follows won't work because it causes bnfc build failure
    # pac-nix.inputs.nixpkgs.follows = "nixpkgs";

    infuse-src.url = "https://codeberg.org/awarina/infuse.nix/archive/trunk.tar.gz";
    infuse-src.flake = false;
  };
  outputs =
    {
      self,
      infuse-src,
      nixpkgs,
      pac-nix,
    }@args:
    let
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
    flake-for-all-systems args {
      overlays = {
        addBincamlPackages = ofinal: _: {
          bincaml = ofinal.callPackage ./nix/bincaml.nix { };
          bincaml_lsp = ofinal.callPackage ./nix/bincaml-lsp.nix { };
          hector = ofinal.callPackage ./nix/hector.nix { };
          intPQueue = ofinal.callPackage ./nix/intpqueue.nix { };
          kittyimg = ofinal.callPackage ./nix/kittyimg.nix { };
          stb_image = ofinal.callPackage ./nix/stb_image.nix { };
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
        {
          self,
          system,
          nixpkgs,
          pac-nix,
          ...
        }:
        let
          inherit (pac-nix.legacyPackages) bnfc-treesitter;

          pkgs = nixpkgs.legacyPackages;
          selfOcamlPackages = pkgs.ocamlPackages.overrideScope self.overlays.addBincamlPackages;
          fpOcamlPackages = selfOcamlPackages.overrideScope self.overlays.enableOcamlFramePointer;
        in
        {
          defaultPackage = selfOcamlPackages.bincaml;

          legacyPackages = {
            bincaml = selfOcamlPackages.bincaml;
            bincaml_lsp = selfOcamlPackages.bincaml_lsp;
            intPQueue = selfOcamlPackages.intPQueue;
            hector = selfOcamlPackages.hector;
            kittyimg = selfOcamlPackages.kittyimg;
            stb_image = selfOcamlPackages.stb_image;

            fp.bincaml = fpOcamlPackages.bincaml;
            fp.bincaml_lsp = fpOcamlPackages.bincaml_lsp;
            fp.intPQueue = fpOcamlPackages.intPQueue;
            fp.hector = fpOcamlPackages.hector;
            fp.kittyimg = fpOcamlPackages.kittyimg;
            fp.stb_image = fpOcamlPackages.stb_image;
          };

          devShells = {
            default = self.devShells.fp;
            fp = fpOcamlPackages.callPackage ./nix/shell.nix { inherit bnfc-treesitter; };
            no-fp = selfOcamlPackages.callPackage ./nix/shell.nix { inherit bnfc-treesitter; };
          };
        };
    };
}

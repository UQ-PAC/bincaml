{
  inputs = {
    self.submodules = true;

    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    infuse-src.url = "https://codeberg.org/awarina/infuse.nix/archive/trunk.tar.gz";
    infuse-src.flake = false;
  };
  outputs =
    {
      self,
      infuse-src,
      nixpkgs,
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
        addPackages = final: _: {
          bnfc-treesitter = final.callPackage ./nix/bnfc-treesitter.nix { };
        };

        addOcamlPackages = ofinal: _: {
          buildDune324Package = ofinal.buildDunePackage.override {
            dune_3 = ofinal.dune_3_24;
          };
          dune_3_24 = ofinal.callPackage ./nix/dune_3_24.nix { };

          bincaml = ofinal.callPackage ./nix/bincaml.nix {
            ocaml-protoc-plugin = ofinal.ocaml-protoc-plugin-6-1-0;
            buildDunePackage = ofinal.buildDune324Package;
          };
          bincaml_lsp = ofinal.callPackage ./nix/bincaml-lsp.nix {
            buildDunePackage = ofinal.buildDune324Package;
          };
          capstone_arm64_disas = ofinal.callPackage ./nix/capstone_arm64_disas.nix {
            buildDunePackage = ofinal.buildDune324Package;
          };
          bincamlDocs = ofinal.callPackage ./nix/bincaml-docs.nix { };

          ocaml-protoc-plugin-6-1-0 = ofinal.callPackage ./nix/ocaml-protoc-plugin.nix { };
          aslp_lifter_ocaml = ofinal.callPackage ./nix/aslp-lifter-ocaml.nix { };
          hector = ofinal.callPackage ./nix/hector.nix { };
          intPQueue = ofinal.callPackage ./nix/intpqueue.nix { };
          kittyimg = ofinal.callPackage ./nix/kittyimg.nix { };
          stb_image = ofinal.callPackage ./nix/stb_image.nix { };
          containers = ofinal.callPackage ./nix/containers.nix { };

          odoc_3_2 = ofinal.callPackage ./nix/odoc.nix { };
          sherlodoc = ofinal.callPackage ./nix/sherlodoc.nix {
            odoc = ofinal.odoc_3_2;
          };
          odoc-md = ofinal.callPackage ./nix/odoc-md.nix {
            odoc = ofinal.odoc_3_2;
          };
          odoc-driver = ofinal.callPackage ./nix/odoc-driver.nix {
            odoc = ofinal.odoc_3_2;
          };
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
          ...
        }:
        let
          pkgs = import nixpkgs {
            system = system;
            overlays = [ self.overlays.addPackages ];
          };

          ocamlPackages = pkgs.ocamlPackages.overrideScope (
            _: _: {
              z3-bin = pkgs.z3;
            }
          );
          selfOcamlPackages = ocamlPackages.overrideScope self.overlays.addOcamlPackages;
          fpOcamlPackages = selfOcamlPackages.overrideScope self.overlays.addOcamlPackages;
        in
        {
          defaultPackage = selfOcamlPackages.bincaml;

          packages = {
            inherit (selfOcamlPackages)
              bincaml
              bincaml_lsp
              aslp_lifter_ocaml
              capstone_arm64_disas
              intPQueue
              hector
              kittyimg
              stb_image
              containers
              dune_3_24
              ;

            bnfc-treesitter = pkgs.bnfc-treesitter;

            ci = self.devShells.ci;
          };

          legacyPackages = {
            ocamlPackages = selfOcamlPackages;
            bincamlDocs = selfOcamlPackages.bincamlDocs;
            pkgs = pkgs;

            fp.bincaml = fpOcamlPackages.bincaml;
            fp.bincaml_lsp = fpOcamlPackages.bincaml_lsp;
            fp.capstone_arm64_disas = fpOcamlPackages.capstone_arm64_disas;
            fp.aslp_lifter_ocaml = fpOcamlPackages.aslp_lifter_ocaml;
            fp.intPQueue = fpOcamlPackages.intPQueue;
            fp.hector = fpOcamlPackages.hector;
            fp.kittyimg = fpOcamlPackages.kittyimg;
            fp.stb_image = fpOcamlPackages.stb_image;
            fp.containers = fpOcamlPackages.containers;
          };

          devShells = {
            default = self.devShells.fp;
            fp = fpOcamlPackages.callPackage ./nix/shell.nix {
              isShellForCI = false;
            };
            no-fp = selfOcamlPackages.callPackage ./nix/shell.nix {
              isShellForCI = false;
            };
            ci = selfOcamlPackages.callPackage ./nix/shell.nix {
              isShellForCI = true;
            };
          };
        };
    };
}

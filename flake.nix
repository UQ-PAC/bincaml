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
            odoc odig ocaml-lsp ocamlformat
            pkgs.tree-sitter pkgs.nodejs-slim
            # sherlodoc
          ] ++ pkgs.lib.optional pkgs.stdenv.hostPlatform.isLinux pkgs.perf;

          inputsFrom = [
            selfOcamlPackages.bincaml
          ];

          shellHook = ''
            export ODIG_CACHE_DIR=~/.cache/odig

            ocaml_hash="$(echo "$OCAMLPATH" | sha1sum | cut -d' ' -f1)"
            if [[ -z "$ocaml_hash" ]]; then
              echo 'cannot make ocaml hash - cannot cache odig'
              export ODIG_LIB_DIR="$(mktemp -d)/lib"
            else
              export ODIG_LIB_DIR="$ODIG_CACHE_DIR/$ocaml_hash"
            fi

            if ! [[ -d "$ODIG_LIB_DIR" ]]; then
              mkdir -p "$ODIG_LIB_DIR"
              IFS=':' read -ra ADDR <<< "$OCAMLPATH"
              for i in "''${ADDR[@]}"; do
                ln -sf $i/* "$ODIG_LIB_DIR"
              done
            fi
          '';
        };

      });
    };
}

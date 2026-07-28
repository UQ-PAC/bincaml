{
  inputs = {
    self.submodules = true;

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
          bincaml = ofinal.callPackage ./nix/bincaml.nix {
            ocaml-protoc-plugin = ofinal.ocaml-protoc-plugin-6-1-0;
          };
          ocaml-protoc-plugin-6-1-0 = ofinal.callPackage ./nix/ocaml-protoc-plugin.nix { };
          bincaml_lsp = ofinal.callPackage ./nix/bincaml-lsp.nix { };
          capstone_arm64_disas = ofinal.callPackage ./nix/capstone_arm64_disas.nix { };
          aslp_lifter_ocaml = ofinal.callPackage ./nix/aslp-lifter-ocaml.nix { };
          hector = ofinal.callPackage ./nix/hector.nix { };
          intPQueue = ofinal.callPackage ./nix/intpqueue.nix { };
          kittyimg = ofinal.callPackage ./nix/kittyimg.nix { };
          stb_image = ofinal.callPackage ./nix/stb_image.nix { };
          containers = ofinal.callPackage ./nix/containers.nix { };
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
            aslp_lifter_ocaml = selfOcamlPackages.aslp_lifter_ocaml;
            capstone_arm64_disas = selfOcamlPackages.capstone_arm64_disas;
            intPQueue = selfOcamlPackages.intPQueue;
            hector = selfOcamlPackages.hector;
            kittyimg = selfOcamlPackages.kittyimg;
            stb_image = selfOcamlPackages.stb_image;
            containers = selfOcamlPackages.containers;

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
              inherit bnfc-treesitter;
              z3 = pkgs.z3.out;
            };
            no-fp = (selfOcamlPackages.callPackage ./nix/shell.nix {
              inherit bnfc-treesitter;
              z3 = pkgs.z3.out;
            }).overrideAttrs (final: prev:
                  let
                    ins = (final.buildInputs ++ final.propagatedBuildInputs);
                    hash = builtins.hashString "sha512" (lib.concatMapStrings (p: p.outPath) ins);
                    opams = lib.map (p: { inherit (p) pname version out; }) ins;
                  in {
              shellHook = (prev.shellHook or "") + ''
                ocaml_hash="${hash}"
                export OPAMROOT="$(pwd)/.nixx-ocaml/$ocaml_hash"

                mkdir -p "$OPAM_SWITCH_PREFIX"/lib/stublibs

                uniq="$(echo "$OCAMLPATH" | tr ':' '\n' | sort | uniq)"
                ocamlpaths=( $uniq )

                pnames=()
                versions=()

                for p in "''${ocamlpaths[@]}"; do
                  segment="$(cut -d/ -f4 <<< "$p")"
                  combined="$(echo "$segment" | sed -E 's/^[^-]+-(.*)-([^-]+)''$/\1:\2/')"
                  IFS=: read -r -a pname_and_version <<< "$combined"

                  pname="''${pname_and_version[0]}"
                  pname="$(sed s/^ocaml${selfOcamlPackages.ocaml.version}-// <<< "$pname")"
                  pnames+=( "$pname" )

                  version="''${pname_and_version[1]}"
                  grepped="$(grep -R 'version = "' "$p/$pname/META" | cut -d'"' -f2 | head -n1)"
                  if [[ -n "$grepped" ]] && ! [[ "$grepped" = *' '* ]]; then
                    version="$grepped"
                  fi

                  echo $segment '->' "''${pname_and_version[@]}" "$version"

                  versions+=( "$version" )
                done

                opams=()
                for index in "''${!pnames[@]}"; do
                  pname="''${pnames[$index]}"
                  version="''${versions[$index]}"

                  case "$pname" in
                    qcheck-stm|trace-tef|trace|qcheck-multicoretests-util|pp_loc)
                      suffix="" ;;
                    *)
                      suffix=".$version" ;;
                  esac

                  case "$pname" in
                    seq|aslp_lifter_ocaml|capstone_arm64_disas|findlib) ;;
                    *)
                      opams+=( "$pname$suffix" ) ;;
                  esac
                done

                opam init --yes --disable-sandboxing --no-setup --compiler=ocaml-system
                # opam env --switch=ocaml-system
                eval $(opam env --switch=ocaml-system)

                opam install --fake --best-effort "''${opams[@]}"

                for i in "''${!ocamlpaths[@]}"; do
                  site_lib="''${ocamlpaths[$i]}"
                  pname="''${pnames[$i]}"

                  for d in "$site_lib"/*; do
                    if [[ "$(basename $d)" != stublibs ]]; then
                      ln -sf "$d" "$OPAM_SWITCH_PREFIX"/lib/$pname || true
                    else
                      ln -sf "$d"/* "$OPAM_SWITCH_PREFIX"/lib/stublibs || true
                    fi
                  done

                  # if [[ -d {out}/share/doc ]]; then
                  #   ln -sf {out}/share/doc/{pname'} "$OPAM_SWITCH_PREFIX"/doc/{pname'} || true
                  # fi

                done


              '';
            });
          };
        };
    };
}

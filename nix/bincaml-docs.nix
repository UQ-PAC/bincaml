/**
  Facilitates generating ocamldocs for the Bincaml package and its dependencies.
*/
{
  lib,
  newScope,
}:

lib.makeScope newScope (
  self:
  let
    callPackage = self.callPackage;
  in
  {
    /**
      Usually, `odoc_driver` uses opam to discover packages, but we don't have
      a real opam switch in Nix. Fortunately, `odoc_driver` also has the ability
      to load packages from Dune's `_build` folder structure, implemented in the
      `dune_overrides` function:
        https://github.com/ocaml/odoc/blob/v3.1/src/driver/opam.ml#L228

      This derivation transforms the separate Nix packages for Bincaml and its
      dependencies into this Dune-like folder structure expected by `odoc_driver`.
    */
    fake_dune_prefix = callPackage (
      {
        ocaml,
        buildEnv,
        fmt,
        yojson_2,
        bos,
      }:
      (buildEnv {
        name = "fake-dune-prefix-for-odoc";
        paths = [
          fmt # TODO: change to bincaml and bincaml_lsp
        ];
        includeClosures = true;
        ignoreCollisions = false;
        pathsToLink = [
          "/share/doc"
          "/lib/ocaml/${ocaml.version}/site-lib"
        ];
        postBuild = ''
          d=$out/_build/install/default

          mkdir -p $d $out/bin
          mv -v $out/share/doc $d/doc
          mv -v $out/lib/ocaml/*/site-lib $d/lib

          mkdir $d/lib/ocaml
          ln -s ${ocaml}/lib/ocaml/* $d/lib/ocaml

          # this makes the builtin packages (like `unix`) appear
          # as distinct top-level packages rather than being under
          # `ocaml`. we probably need to fake `.changes` to avoid this.
          for meta in ${ocaml}/lib/ocaml/*/META; do
            ln -s $(dirname $meta) $d/lib
          done

          rm -rf $out/share $out/lib
          rm -rf $d/lib/{compiler-libs,stdlib,topfind,stublibs}

          cat <<EOF > $out/bin/activate_fake_dune_prefix.sh
          export OCAMLPATH=$d/lib
          export CAMLLIB=$d/lib/ocaml
          EOF
          chmod +x $out/bin/*
        '';
      }).overrideAttrs
        (
          _: prev: {
            # `linol` (and others?) depend on hardcoded `yojson_2` which leads
            # to both yojson 3 and 2 in the closure, which causes conflicts.
            buildCommand = ''
              grep -v ${yojson_2} $extraPathsFrom > without_yojson
              extraPathsFrom=without_yojson
              ${prev.buildCommand}
            '';
          }
        )
    ) { };

    /**
      Provides a no-op `opam` script which prints a path to an empty dir.
    */
    fake_opam = callPackage (
      {
        writeShellScriptBin,
        emptyDirectory,
      }:
      (writeShellScriptBin "opam" "echo ${emptyDirectory}").overrideAttrs { name = "fake-opam-for-odoc"; }
    ) { };

    /**
      Main output which builds the HTML/JS/CSS for the documentation website.

      Also has a `dev` output which contains the `.odocl` files for Sherlodoc.
    */
    docs = callPackage (
      {
        stdenvNoCC,
        emptyDirectory,
        fake_opam,
        fake_dune_prefix,
        ocaml,
        findlib,
        odoc,
        sherlodoc,
        odoc-driver,
      }:
      stdenvNoCC.mkDerivation {
        name = "bincaml-docs";

        dontUnpack = true;
        doCheck = true;

        nativeBuildInputs = [
          ocaml
          findlib
          odoc-driver
          sherlodoc
          fake_opam
          fake_dune_prefix
        ];

        outputs = [ "out" "dev" "db" ];

        buildPhase = ''
          source activate_fake_dune_prefix.sh
          odoc_driver \
            --html-dir=$out \
            --mld-dir=$dev --odoc-dir=$dev --odocl-dir=$dev \
            $(cd $OCAMLPATH && echo *) --json-output

          mkdir $db
          export SHERLODOC_DB=$db/sherlodoc.marshal
          for d in $dev/*; do
            if [[ -d $d ]]; then
              found="$(find $d -name '*.odocl' -not -name '*__*' -not -name 'impl-*' -not -name page-index.odocl)"
              if [[ -n "$found" ]]; then
                printf "$(basename $d)\t%s\n" $found >> file-list
              fi
            fi
          done

          sherlodoc index --file-list file-list

          ocamlfind printconf

          echo ${fake_opam}
          echo ${fake_dune_prefix}
        '';

        checkPhase = ''
          [[ -f $out/ocaml/stdlib/index.html ]] || {
            echo "stdlib index.html missing. stdlib links are probably broken."
            exit 1
          }

          echo "Testing sherlodoc search..."
          sherlodoc search Format.formatter | grep 'type Stdlib.Format.formatter'
        '';
      }
    ) { };

    serve = callPackage (
      {
        sherlodoc,
        docs,
        writeShellScriptBin,
      }:
      writeShellScriptBin "sherlodoc-serve-bincaml" ''
        export SHERLODOC_DB=${docs.db}/sherlodoc.marshal
        exec ${lib.getExe sherlodoc} serve "$@"
      ''
    ) { };
  }
)

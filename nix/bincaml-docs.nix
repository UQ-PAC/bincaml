/**
  Facilitates generating ocamldocs for the Bincaml package and its dependencies.
*/
{ lib, newScope }:

lib.makeScope newScope (
  self:
  let
    callPackage = self.callPackage;
  in
  {
    test_package_for_odoc_include_subdirs = callPackage (
      { dune, buildDunePackage }:
      buildDunePackage (self: {
        pname = "test_package_for_odoc_include_subdirs";
        version = "0.0";
        src = dune.src;

        preBuild = ''
          rm -rf dune-project
          cd test/blackbox-tests/test-cases/include-qualified/basic.t

          dune describe

          echo "
          (name ${self.pname})
          (package (name ${self.pname}))
          " >> dune-project
          substituteInPlace lib/dune --replace-fail 'library' "library (public_name ${self.pname}.foolib)"
        '';
      })
    ) { };

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
        runCommand,
        bincaml_lsp,
        yojson_2,
        bos,
      }:
      (buildEnv {
        name = "fake-dune-prefix-for-odoc";
        paths = [ bincaml_lsp ];
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

          # the builtin packages (like `unix`) have no top-level META
          # file and only have META files in subdirectories of ocaml/.
          # this moves them up one level so that odoc can find them.
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
            extraPathsFrom = runCommand "extraPathsFrom" { } ''
              grep -v ${yojson_2} ${prev.extraPathsFrom} > $out
            '';
          }
        )
    ) { };

    /**
      Provides a no-op `opam` script which prints a path to an empty dir.
    */
    fake_opam = callPackage (
      { writeShellScriptBin, emptyDirectory }:
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
          fake_opam
          fake_dune_prefix
        ];

        outputs = [
          "out"
          "dev"
        ];

        buildPhase = ''
          source activate_fake_dune_prefix.sh
          export OCAMLRUNPARAM=b
          odoc_driver \
            --html-dir=$out \
            --mld-dir=$dev --odoc-dir=$dev --odocl-dir=$dev \
            $(cd $OCAMLPATH && echo *)

          ocamlfind printconf

          echo ${fake_opam}
          echo ${fake_dune_prefix}
        '';

        checkPhase = ''
          [[ -f $out/ocaml/stdlib/index.html ]] || {
            echo "stdlib index.html missing. stdlib links are probably broken."
            exit 1
          }
        '';
      }
    ) { };

    db = callPackage (
      {
        stdenvNoCC,
        sherlodoc,
        writeText,
        src,
      }:
      stdenvNoCC.mkDerivation {
        name = "bincaml-sherlodoc-db";

        src = src;
        doCheck = true;

        nativeBuildInputs = [ sherlodoc ];

        buildPhase = ''
          mkdir -p $out/bin
          export SHERLODOC_DB=$out/sherlodoc.marshal
          for d in $src/*; do
            if [[ -d $d ]]; then
              found="$(find $d -name '*.odocl' -not -name '*__*' -not -name 'impl-*' -not -name page-index.odocl)"
              if [[ -n "$found" ]]; then
                printf "$(basename $d)\t%s\n" $found >> file-list
              fi
            fi
          done

          sherlodoc index --file-list file-list

          cat <<EOF > $out/bin/activate_sherlodoc_db.sh
          export SHERLODOC_DB=$SHERLODOC_DB
          EOF
          chmod +x $out/bin/*
        '';

        checkPhase = ''
          echo "Testing sherlodoc search..."
          sherlodoc search Format.formatter | grep 'type Stdlib.Format.formatter'
        '';
      }
    ) { src = self.docs.dev; };

    serve = callPackage (
      {
        sherlodoc,
        docs,
        writeShellApplication,
        db,
      }:
      writeShellApplication {
        name = "sherlodoc-serve-bincaml";
        runtimeInputs = [
          sherlodoc
          db
        ];
        derivationArgs.checkPhase = "";
        text = ''
          source activate_sherlodoc_db.sh
          exec sherlodoc serve "$@"
        '';
      }
    ) { };
  }
)

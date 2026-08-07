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
          bos
        ];
        includeClosures = true;
        ignoreCollisions = false;
        pathsToLink = [
          "/share/doc"
          "/lib/ocaml/${ocaml.version}/site-lib"
        ];
        postBuild = ''
          d=$out/_build/install/default

          mkdir -p $d
          mv -v $out/share/doc $d/doc
          mv -v $out/lib/ocaml/*/site-lib $d/lib
          ln -s ${ocaml}/lib/ocaml $d/lib

          rm -rf $out/share $out/lib
          rm -rf $d/lib/topfind $d/lib/stublibs

          cat <<EOF > $out/activate.sh
          export CAMLLIB=$d/lib/ocaml
          export OCAMLPATH=$d/lib
          EOF
          chmod +x $out/activate.sh
        '';
      }).overrideAttrs
        (
          _: prev: {
            # `linol` (and others?) depend on hardcoded `yojson_2` which leads
            # to both yojson 3 and 2 in the closure, which causes conflicts.
            buildCommand = ''
              grep -v ${yojson_2} $extraPathsFrom > without_yojson
              extraPathsFrom=without_yojson
            ''
            + prev.buildCommand;

          setupHook
          }
        )
    ) { };

    /**
      Provides a fake `opam` script which prints a path which contains the
      files needed by: https://github.com/ocaml/odoc/blob/v3.1/src/driver/ocamlfind.ml#L6-L9
    */
    fake_opam = callPackage (
      {
        writeShellScriptBin,
        emptyDirectory,
      }:
      (writeShellScriptBin "opam" "echo ${emptyDirectory}").overrideAttrs { name = "fake-opam-for-odoc"; }
    ) { };

    docs = callPackage (
      {
        runCommand,
        fake_opam,
        fake_dune_prefix,
        ocaml,
        findlib,
        odoc,
        sherlodoc,
        odoc-driver,
      }:
      runCommand "bincaml-docs"
        {
          nativeBuildInputs = [
            findlib
            fake_opam
            fake_dune_prefix
            odoc-driver
            odoc
            sherlodoc
            ocaml
          ];
        }
        ''
          (
            source ${fake_dune_prefix}/activate.sh
            odoc_driver --html-dir=$out $(cd $OCAMLPATH && echo *)

            ocamlfind printconf
          )

          echo ${fake_opam}
          echo ${fake_dune_prefix}
        ''
    ) { };
  }
)

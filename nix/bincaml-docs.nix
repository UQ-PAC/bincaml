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
          mkdir -p $d
          mv -v $out/share/doc $d/doc
          mv -v $out/lib/ocaml/*/site-lib $d/lib
          ln -s ${ocaml}/lib/ocaml $d/lib/ocaml

          rm -rf $out/share $out/lib
          rm -rf $d/lib/topfind
        '';
        passthru.path = "_build/install/default";

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
          }
        )
    ) { };

    /**
      Provides a fake `opam` script which prints a path which contains the
      files needed by: https://github.com/ocaml/odoc/blob/v3.1/src/driver/ocamlfind.ml#L6-L9
    */
    fake_opam = callPackage (
      {
        runCommand,
        findlib,
        ocaml,
        runtimeShell,
        fake_dune_prefix,
      }:
      runCommand "fake-opam-for-odoc-driver" { } ''
        mkdir -pv $out/lib $out/bin

        cat <<EOF > $out/lib/findlib.conf
        destdir="/nix/store/dmdkfg086nl1p8my3wf65sv7v99krd94-ocaml5.4.1-findlib-1.9.8/lib/ocaml/5.4.1/site-lib"
        path="/nix/store/14nbg9kalx0fzg412ibngwgpfjahcq2b-ocaml-5.4.1/lib/ocaml:/nix/store/dmdkfg086nl1p8my3wf65sv7v99krd94-ocaml5.4.1-findlib-1.9.8/lib/ocaml/5.4.1/site-lib:${fake_dune_prefix}/${fake_dune_prefix.path}/lib"
        ldconf="ignore"
        ocamlc="ocamlc.opt"
        ocamlopt="ocamlopt.opt"
        ocamldep="ocamldep.opt"
        ocamldoc="ocamldoc.opt"
        EOF

        ln -s ${fake_dune_prefix}/${fake_dune_prefix.path}/lib/ocaml $out/lib/ocaml

        cat <<EOF > $out/bin/opam
        #!${runtimeShell}
        echo $out
        EOF
        chmod +x $out/bin/opam
      ''
    ) { };

    docs = callPackage (
      {
        runCommand,
        fake_opam,
        fake_dune_prefix,
        ocaml,
        odoc,
        sherlodoc,
        odoc-driver,
      }:
      runCommand "bincaml-docs"
        {
          nativeBuildInputs = [
            fake_opam
            odoc-driver
            odoc
            sherlodoc
            ocaml
          ];
        }
        ''
          dune_prefix=${fake_dune_prefix}/${fake_dune_prefix.path}
          OCAMLPATH=$dune_prefix/lib \
            odoc_driver --html-dir=$out $(cd $dune_prefix/lib && echo *) -v

          echo ${fake_dune_prefix}
          echo ${fake_opam}
        ''
    ) { };
  }
)

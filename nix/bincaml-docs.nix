{
buildEnv,
runCommand,
writeShellScriptBin,
odoc-driver,
  bincaml,
  bincaml_lsp,
odoc,
findlib,
ocaml,
sherlodoc,
runtimeShell
}:

let
  dummy-opam = runCommand "dummy-opam" {
  } ''
    mkdir -pv $out/lib $out/bin
    cp ${findlib}/etc/findlib.conf $out/lib
    cp -r ${ocaml}/lib/ocaml $out/lib/ocaml

    cat <<EOF > $out/bin/opam
    #!${runtimeShell}
    echo $out
    EOF
    chmod +x $out/bin/opam
  '';

env = buildEnv {
name = "ajidso";
  paths = [ odoc ];
  includeClosures = true;
  pathsToLink = [ "/share/doc" "/lib/ocaml/5.4.1/site-lib" ];

  postBuild = ''
    mv $out/share/doc doc
    mv $out/lib/ocaml/*/site-lib lib
    ln -s ${ocaml}/lib/ocaml lib

    rm -rf $out
    mkdir -v $out
    mv doc lib $out
  '';
};

in runCommand "bincaml-docs" {
  nativeBuildInputs = [ dummy-opam odoc-driver odoc sherlodoc ocaml ];
} ''
  dune_prefix=$(mktemp -d)/_build/install/default
  mkdir -p $(dirname $dune_prefix)
  ln -s ${env} $dune_prefix
  ls -l $(dirname $dune_prefix)
  OCAMLPATH=$dune_prefix/lib odoc_driver --html-dir=$out $(cd $dune_prefix/lib && echo *)
''

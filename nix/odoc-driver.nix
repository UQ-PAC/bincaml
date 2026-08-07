{
  lib,
  buildDunePackage,

  odoc,
  odoc-md,
  fpath,
  bos,
  yojson,
  findlib,
  opam-format,
  logs,
  eio_main,
  eio,
  progress,
  cmdliner,
  sexplib,
  ppx_sexp_conv,
  sherlodoc,
}:

buildDunePackage {
  pname = "odoc-driver";
  inherit (odoc) version src;

  nativeBuildInputs = [ sherlodoc ];
  buildInputs = [
    odoc
    odoc-md
    fpath
    bos
    yojson
    findlib
    opam-format
    logs
    eio_main
    eio
    progress
    cmdliner
    sexplib
    ppx_sexp_conv
  ];

  postPatch = ''
    substituteInPlace src/driver/ocamlfind.ml --replace-fail '~config ~env_camllib' ""
    substituteInPlace src/driver/opam.ml --replace-fail 'OCAMLPATH' 'OCAMLPATHX'
  '';

  nativeCheckInputs = [ ];
  checkInputs = [ ];
  doCheck = true;

  meta = {
    description = "OCaml Documentation Generator - Driver";
    mainProgram = "odoc_driver";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.katrinafyi ];
    homepage = "https://github.com/ocaml/odoc";
    changelog = "https://github.com/ocaml/odoc/blob/${odoc.version}/CHANGES.md";
  };
}

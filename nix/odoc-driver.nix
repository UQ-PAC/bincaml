{
  lib,
  fetchpatch2,
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

  patches = [
    (fetchpatch2 {
      url = "https://github.com/ocaml/odoc/commit/02408309dc223f8ab97a023dfec4e4641ec55736.patch";
      hash = "sha256-FO2QaK1TaxCNBpttFy/GHnePa6uvKOvxE+rstKcPY/Q=";
    })
  ];

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

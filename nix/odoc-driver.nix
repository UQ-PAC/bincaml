{
  lib,
  makeWrapper,
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

  nativeBuildInputs = [
    sherlodoc
    makeWrapper
  ];
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
    substituteInPlace src/driver/ocamlfind.ml \
      --replace-fail '~config ~env_camllib' "" \
      --replace-fail 'let config =' 'let _config =' \
      --replace-fail 'let env_camllib =' 'let _env_camllib ='
  '';

  nativeCheckInputs = [ ];
  checkInputs = [ ];
  doCheck = true;

  postInstall = ''
    wrapProgram $out/bin/odoc_driver --prefix PATH : ${lib.makeBinPath [ odoc sherlodoc ]}
  '';

  meta = {
    description = "OCaml Documentation Generator - Driver";
    mainProgram = "odoc_driver";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.katrinafyi ];
    homepage = "https://github.com/ocaml/odoc";
    changelog = "https://github.com/ocaml/odoc/blob/${odoc.version}/CHANGES.md";
  };
}

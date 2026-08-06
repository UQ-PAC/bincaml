{
  lib,
  buildDunePackage,
  writableTmpDirAsHomeHook,

  odoc,
  base64,
  bigstringaf,
  js_of_ocaml,
  brr,
  cmdliner,
  decompress,
  fpath,
  lwt,
  menhir,
  ppx_blob,
  tyxml,
  odig,
  base,
  alcotest,
  findlib,
}:

buildDunePackage (self: {
  pname = "sherlodoc";
  inherit (odoc) version src;

  nativeBuildInputs = [
    menhir
    js_of_ocaml
    writableTmpDirAsHomeHook
  ];

  buildInputs = [
    odoc
    findlib
    base64
    bigstringaf
    brr
    cmdliner
    decompress
    fpath
    lwt
    ppx_blob
    tyxml
    base
    alcotest
  ];

  nativeCheckInputs = [
    odig
    odoc
  ];
  checkInputs = [ alcotest ];
  doCheck = true;

  postPatch = ''
    substituteInPlace sherlodoc/test/dune --replace-quiet --quiet ""
  '';

  meta = {
    description = "Search engine for OCaml documentation";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.katrinafyi ];
    homepage = "https://github.com/ocaml/odoc";
  };
})

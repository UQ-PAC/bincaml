{
  lib,
  fetchpatch2,
  buildDunePackage,
  writableTmpDirAsHomeHook,

  opam,
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

  patches = [
    (fetchpatch2 {
      url = "https://github.com/ocaml/odoc/commit/9695cd79ec29c082f62c768a99a650ebf06892d3.patch";
      hash = "sha256-8eyclSV4MnMkVcT+0NjPKWARzITm6tJpg0n/Z7Yi/L4=";
    })
  ];

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
    opam
  ];
  checkInputs = [ alcotest ];
  doCheck = true;

  preCheck = ''
    substituteInPlace sherlodoc/test/dune --replace-quiet --quiet ""

    cat <<EOF >> sherlodoc/test/dune
    (env
     (_
      (env-vars
       (ODIG_LIB_DIR $(echo ${tyxml}/lib/ocaml/*/site-lib))
       (ODIG_DOC_DIR ${tyxml}/share/doc)
       (LOG_LEVEL info)
       )))
    EOF

    opam init --bare --disable-sandboxing $(mktemp -d) --quiet --no
  '';

  meta = {
    description = "Search engine for OCaml documentation";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.katrinafyi ];
    homepage = "https://github.com/ocaml/odoc";
  };
})

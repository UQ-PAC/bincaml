{
  lib,
  makeWrapper,
  fetchFromGitHub,
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
  crunch,
  cppo,
  dream,

  enableWww ? true,
  # Restores `sherlodoc/www` folder. https://github.com/ocaml/odoc/issues/1441
  sherlodoc-www-src ? fetchFromGitHub {
    owner = "mt-caret";
    repo = "odoc";
    rev = "426bb50b0679ee3bb69f974141ab4a6797587c2c";
    hash = "sha256-1lzggOwpIBaBHAFKeAMscA+UEB1F4G7DR3Om3rllyzI=";
  }
}:

buildDunePackage (self: {
  pname = "sherlodoc";
  inherit (odoc) version src;

  nativeBuildInputs = [
    menhir
    js_of_ocaml
    writableTmpDirAsHomeHook
    makeWrapper
  ] ++ lib.optionals enableWww [
    cppo
    crunch
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
  ] ++ lib.optionals enableWww [
    dream
  ];

  nativeCheckInputs = [
    odig
    odoc
    opam
  ];
  checkInputs = [ alcotest ];
  doCheck = true;

  postPatch = lib.optionalString enableWww ''
    cp -r ${sherlodoc-www-src}/sherlodoc/www sherlodoc/www
    substituteInPlace sherlodoc/www/dune --replace-fail '(optional)' ""
  '';

  preCheck = ''
    substituteInPlace sherlodoc/test/dune --replace-quiet --quiet ""

    cat <<EOF >> sherlodoc/test/dune
    (env
     (_
      (env-vars
       (ODIG_LIB_DIR $(echo ${tyxml}/lib/ocaml/*/site-lib))
       (ODIG_DOC_DIR ${tyxml}/share/doc)
       (OPAMCOLOR never)
       (LOG_LEVEL info)
       )))
    EOF

    opam init --bare --disable-sandboxing $(mktemp -d) --quiet --no --no-setup
  '';

  postInstall = ''
    wrapProgram $out/bin/sherlodoc --set PATH ${lib.makeBinPath [ odoc ]}
  '';

  meta = {
    mainProgram = "sherlodoc";
    description = "Search engine for OCaml documentation";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.katrinafyi ];
    homepage = "https://github.com/ocaml/odoc/tree/master/sherlodoc";
  };
})

{
  lib,
  buildDunePackage,

  odoc,
  cmdliner,
  cmarkit,
}:

buildDunePackage {
  pname = "odoc-md";
  inherit (odoc) version src;

  nativeBuildInputs = [ ];
  buildInputs = [
    odoc
    cmdliner
    cmarkit
  ];

  nativeCheckInputs = [ ];
  checkInputs = [ ];
  doCheck = true;

  meta = {
    description = "OCaml Documentation Generator - Markdown support";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.katrinafyi ];
    homepage = "https://github.com/ocaml/odoc";
    changelog = "https://github.com/ocaml/odoc/blob/${odoc.version}/CHANGES.md";
  };
}

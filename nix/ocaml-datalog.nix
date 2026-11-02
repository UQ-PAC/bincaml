{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  mdx,
}:

buildDunePackage {
  pname = "datalog";
  version = "0.7-unstable-2026-11-02";

  src = fetchFromGitHub {
    owner = "c-cube";
    repo = "datalog";
    rev = "d6f4c1c7d14286dd5c3cd21bb97f3cbbd5988cc2";
    hash = "sha256-UvnnNXGD3jzrgonvTVPCcpMuFwhPSC2+LQNqFdFSs3w=";
  };

  doCheck = true;
  nativeCheckInputs = [ mdx ];

  meta = {
    homepage = "https://github.com/c-cube/datalog";
    description = "An in-memory datalog implementation for OCaml.";
    maintainers = with lib.maintainers; [ katrinafyi ];
    mainProgram = "datalog_cli";
  };
}

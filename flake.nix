{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";

    opam-repository = {
      url = "github:ocaml/opam-repository";
      flake = false;
    };

    pac-opam = {
      url = "github:uq-pac/opam-repository";
      flake = false;
    };

    opam-nix = {
      url = "github:tweag/opam-nix";
      inputs.flake-utils.follows = "flake-utils";
      inputs.opam-repository.follows = "opam-repository";
    };

    nixpkgs.follows = "opam-nix/nixpkgs";
  };
  outputs =
    {
      flake-utils,
      opam-nix,
      nixpkgs,
      pac-opam,
      opam-repository,
      ...
    }:
    let
      package = "bincaml";
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        on = opam-nix.lib.${system};
        devPackagesQuery = {
          menhir = "*";
          zarith = "*";
          fix = "*";
          trace = "*";
          trace-tef = "*";
          containers = "*";
          iter = "*";
          containers-data = "*";
          ppx_deriving = "*";
          ocamlgraph = "*";
          intPQueue = "*";
          cmdliner = "*";
          pp_loc = "*";
          fmt = "*";
          patricia-tree = "*";
          odig = "*";
          sherlodoc = "*";
          ppx_expect = "*";
          alcotest = "*";
          qcheck-core = "*";
          qcheck-alcotest = "*";
          qcheck-stm = "*";
          ocaml-lsp-server = "*";
          ocamlformat = "*";
          basil_lsp = "*";
        };
        query = devPackagesQuery // {
          ocaml-compiler = "5.4.0";
          ocaml-variants = "5.4.0+options";
          ocaml-option-fp = "*";
          ocaml-option-flambda = "*";
        };
        scope = on.buildOpamProject' {
          repos = [
            pac-opam
            opam-repository
          ];
        } ./. query;
        main = scope.${package};
        devPackages = builtins.attrValues (pkgs.lib.getAttrs (builtins.attrNames devPackagesQuery) scope);
      in
      {
        legacyPackages = scope;

        packages.default = main;

        devShells.default = pkgs.mkShell {
          inputsFrom = [ main ];
          buildInputs = devPackages ++ [ main ];
        };
      }
    );
}

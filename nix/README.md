# Nix packages for bincaml

To use the Nix packages, you should use the flake at the top of the repository.
- `nix build .` for default build, fast without frame pointer.
- `nix build .#fp.bincaml` for frame-pointer + flambda build.

You can also use `nix run` in place of `nix build` to immediately
run the built program.

See `bincaml.nix` for the package definition. If more dependencies are ever
added to bincaml, this is the place they must be added.

There are also useful dev shells for working on the project. These
provide the build-dependencies for bincaml, as well as useful tools
like the ocaml-lsp.
- `nix develop .` for default shell.
  frame-pointer + flambda enabled for easier debugging, but will take
  ~10 minutes on first build.
- `nix develop .#no-fp` for shell without frame-pointer or flambda.
  faster for a cold start as it can use the central nixpkgs cache.

Once inside the shell, you can use `dune build` and other dune commands
to work on the project.

See `shell.nix` for the shell definition and currently included packages.

# updating a package

The flake depends on some Ocaml dependencies which we have packaged
manually (namely, hector and intPQueue).
To the version of these dependencies, you can run something like this
from the repository root:
```bash
nix run nixpkgs/b6fd4d089fb1c5315ee7f365de6480f7c3150c69#nix-update -- --flake -f . --build --commit intPQueue
```
Be aware of future bug: https://github.com/Mic92/nix-update/issues/535

Most other dependencies will have their versions provided by whatever is in
nixpkgs. If a new or different version is needed, we would have to
override them.

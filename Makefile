_build/nix-vars.gc: flake.nix flake.lock nix/aslp-lifter-ocaml.nix nix/bincaml-lsp.nix nix/bincaml.nix nix/capstone_arm64_disas.nix nix/containers.nix nix/dune_3_24.nix nix/flake-for-all-systems.nix nix/hector.nix nix/infuse-lib.nix nix/intpqueue.nix nix/kittyimg.nix nix/ocaml-protoc-plugin.nix nix/shell.nix nix/stb_image.nix
	mkdir -p _build
	nix build --accept-flake-config --impure --expr \
		"(builtins.getFlake \"git+file:$$PWD\")"'.devShells.$${builtins.currentSystem}.no-fp' -o .shell
	mv .shell _build/nix-vars.gc

_build/nix-vars.sh: _build/nix-vars.gc
	vars="`nix --accept-flake-config print-dev-env .#capstone_arm64_disas`" && echo "$$vars" > _build/nix-vars.sh


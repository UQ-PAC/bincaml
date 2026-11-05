.DELETE_ON_ERROR:

DDISASM = ddisasm/bin/ddisasm
BWRAP = bwrap/bin/bwrap
GCC = gcc/bin/aarch64-unknown-linux-gnu-gcc
BINCAML ?= bincaml
ROOT ?= ..

.PHONY: phony
phony:
	@true

nix.env: $(ROOT)/flake.nix $(ROOT)/flake.lock
	nix build '.#pac.ddisasm^out' --no-link
	printf '%s=%s\n' \
		DDISASM `nix build '.#pac.ddisasm^out' --no-link --print-out-paths`/bin/ddisasm \
		BWRAP   `nix build '.#pkgs.bubblewrap^out' --no-link --print-out-paths`/bin/bwrap \
		GCC     `nix build '.#pkgs.pkgsCross.aarch64-multiplatform.pkgsBuildHost.gcc^out' --no-link --print-out-paths`/bin/aarch64-unknown-linux-gnu-gcc \
		> $@

%.exe: %.c nix.env
	source ./nix.env; $$BWRAP --unshare-all \
	  --ro-bind /nix/store /nix/store --ro-bind $< $< --bind . /out --chdir /out \
	  --die-with-parent \
	  $$GCC $< -o $@

%.gtirb: %.exe nix.env
	source ./nix.env; $$DDISASM $< --ir $@

%.il: %.gtirb
	printf '%s\n' "(load-gtirb $<)" "(dump-il $@)" | $(BINCAML) script -

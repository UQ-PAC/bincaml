.DELETE_ON_ERROR:

BINCAML ?= bincaml
DDISASM = ddisasm/bin/ddisasm
BWRAP = bwrap/bin/bwrap
GCC = gcc/bin/aarch64-unknown-linux-gnu-gcc

.PHONY: phony
phony:
	@true

nix: ../flake.nix ../flake.lock
	echo > nix

ddisasm: nix
	nix build '.#pac.ddisasm' --out-link ddisasm-link
	ln -f -s ddisasm-link/bin/ddisasm ddisasm

bwrap: nix
	nix build '.#pkgs.bubblewrap' --out-link bwrap-link
	ln -f -s bwrap-link/bin/bwrap bwrap

aarch64-unknown-linux-gnu-gcc: nix
	nix build '.#pkgs.pkgsCross.aarch64-multiplatform.pkgsBuildHost.gcc^out' --out-link gcc-link
	ln -f -s gcc-link/bin/aarch64-unknown-linux-gnu-gcc aarch64-unknown-linux-gnu-gcc

%.exe: %.c aarch64-unknown-linux-gnu-gcc bwrap
	GCC=`readlink -f aarch64-unknown-linux-gnu-gcc` eval ./bwrap --unshare-all \
	  --ro-bind /nix/store /nix/store --ro-bind $< $< --bind . /out --chdir /out \
	  --die-with-parent \
	  '$$GCC' $< -o $@

%.gtirb: %.exe $(DDISASM)
	./ddisasm $< --ir $@

%.il: %.gtirb
	printf '%s\n' "(load-gtirb $<)" "(dump-il $@)" | $(BINCAML) script -

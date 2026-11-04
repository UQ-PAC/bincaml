.DELETE_ON_ERROR:

BINCAML ?= bincaml
DDISASM = ddisasm/bin/ddisasm
BWRAP = bwrap/bin/bwrap
GCC = gcc/bin/aarch64-unknown-linux-gnu-gcc

.PHONY: phony
phony:
	@true

nix: ../flake.nix ../flake.lock
	touch nix

$(DDISASM): nix
	nix build '.#pac.ddisasm' --out-link ddisasm

$(BWRAP): nix
	nix build '.#pkgs.bubblewrap' --out-link bwrap

$(GCC): nix
	nix build '.#pkgs.pkgsCross.aarch64-multiplatform.pkgsBuildHost.gcc' --out-link gcc

%.exe: %.c $(GCC) $(BWRAP)
	GCC=`realpath $(GCC)` eval $(BWRAP) --unshare-all \
	  --ro-bind /nix/store /nix/store --ro-bind $< $< --bind . /out --chdir /out \
	  --die-with-parent \
	  '$$GCC' $< -o $@

%.gtirb: %.exe $(DDISASM)
	$(DDISASM) $< --ir $@

%.il: %.gtirb
	printf '%s\n' "(load-gtirb $<)" "(dump-il $@)" | $(BINCAML) script -

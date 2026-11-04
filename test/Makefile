.DELETE_ON_ERROR:

DDISASM = ddisasm/bin/ddisasm
BWRAP = bwrap/bin/bwrap
GCC = gcc/bin/aarch64-unknown-linux-gnu-gcc
BINCAML ?= bincaml

.PHONY: phony
phony:
	@true

$(DDISASM):
	nix build '.#pac.ddisasm' --out-link ddisasm

$(BWRAP):
	nix build '.#pkgs.bubblewrap' --out-link bwrap

$(GCC):
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

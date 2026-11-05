.DELETE_ON_ERROR:

BINCAML ?= bincaml
ROOT ?= ..
NIX_ENV ?= ./nix.env

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

%.exe: %.c $(NIX_ENV)
	if [ -n '$(NIX_ENV)' ]; then source '$(NIX_ENV)'; fi ; $$BWRAP --unshare-all \
	  --ro-bind /nix/store /nix/store --ro-bind $< $< --bind . /out --chdir /out \
	  --die-with-parent \
	  $$GCC $< -o $@

%.gtirb: %.exe $(NIX_ENV)
	if [ -n '$(NIX_ENV)' ]; then source '$(NIX_ENV)'; fi ; $$DDISASM $< --ir $@

%.il: %.gtirb
	printf '%s\n' "(load-gtirb $<)" "(dump-il $@)" | $(BINCAML) script -

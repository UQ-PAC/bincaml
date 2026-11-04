
.PHONY: phony
phony:
	@true

%.exe: phony
	[[ -n "$(SRCS)" ]]  # SRCS variable should be non-empty
	aarch64-unknown-linux-gnu-gcc $(SRCS) -o $@

%.gtirb: %.exe
	ddisasm $^ --ir $@

%.il: %.gtirb
	printf '%s\n' "(load-gtirb $^)" "(dump-il $@)" | bincaml script -

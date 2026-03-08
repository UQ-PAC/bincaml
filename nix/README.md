Nix packages for bincaml.

To update:
```bash
nix run nixpkgs/b6fd4d089fb1c5315ee7f365de6480f7c3150c69#nix-update -- --flake -f . --build --commit intPQueue
```
Be aware of future bug: https://github.com/Mic92/nix-update/issues/535

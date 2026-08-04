#!/bin/bash -eu

nix develop .#ci --ignore-env --keep-env-var CI --command "$@"

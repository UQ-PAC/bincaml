#!/bin/bash -eu

exec nix develop .#ci --ignore-env --keep-env-var CI --command "$@"

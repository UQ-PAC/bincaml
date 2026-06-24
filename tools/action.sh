#!/usr/bin/env bash


# checkout
set -eu
git init --quiet --initial-branch main
git remote add origin "https://github.com/${GITHUB_REPOSITORY}.git"
git fetch --quiet --no-tags --depth=1 origin "$GITHUB_SHA"
git checkout --quiet "$GITHUB_SHA"
git submodule init
git submodule update --init --depth 1

# test
opam install -t . --deps-only
opam exec -- dune build '@install'
opam exec -- dune runtest --force --profile=release




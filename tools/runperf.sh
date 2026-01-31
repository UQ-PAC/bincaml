#!/usr/bin/env bash

set -xe

echo "May want to allow system wide profiling"
echo "# sysctl kernel.perf_event_paranoid=1"

repo="$(git rev-parse --show-toplevel)"
exe=$repo/_build/default/bin/main.exe
dune build $(realpath --relative-to=$(pwd) $exe)
perf record -F 10000 --call-graph fp $exe $@
perf script -i perf.data | $repo/tools/vendor/stackcollapse-perf.pl > out.folded
$repo/tools/vendor/flamegraph.pl out.folded > flamegraph.svg



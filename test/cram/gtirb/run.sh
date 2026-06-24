#!/usr/bin/env bash
#

cat << EOF | bincaml script -
(load-gtirb $1)
; (run-transforms trim-unreachable-proc)
(dump-il)
EOF

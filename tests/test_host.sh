#!/bin/sh
# All host tests: the unit tests, then upstream's own checks on a host build
# made with our config.h (A4, centimetres) and our zlib shim's mapping.
set -eu
HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
sh "$HERE/test_lock.sh"
sh "$HERE/test-part.sh"
sh "$HERE/test-man2text.sh"
sh "$HERE/host_check.sh"

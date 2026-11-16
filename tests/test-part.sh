#!/bin/sh
# Unit test for scripts/write-part.sh: a fake part drawer gives the Part file
# GFOpenUpTool expects (header, needs, one copy line per file, SYS: targets).
set -eu
HERE=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
mkdir -p "$T/C" "$T/Utilities/Potrace"
: > "$T/C/potrace"; : > "$T/C/mkbitmap"
for f in ReadMe COPYING potrace.txt; do : > "$T/Utilities/Potrace/$f"; done
sh "$HERE/scripts/write-part.sh" "$T" 1.16
fail() { echo "FAIL: $*"; cat "$T/Part"; exit 1; }
[ "$(sed -n 1p "$T/Part")" = "part Potrace 1.16" ] || fail header
grep -qx 'needs 68040' "$T/Part" || fail needs
grep -qx 'copy "C/potrace" "SYS:C/potrace"' "$T/Part" || fail potrace
grep -qx 'copy "C/mkbitmap" "SYS:C/mkbitmap"' "$T/Part" || fail mkbitmap
grep -qx 'copy "Utilities/Potrace/ReadMe" "SYS:Utilities/Potrace/ReadMe"' "$T/Part" || fail readme
[ "$(grep -c '^copy' "$T/Part")" = 5 ] || fail count
grep -q '"Part"' "$T/Part" && fail "Part lists itself"
grep -q 'needs part' "$T/Part" && fail "no part needed"
echo "test-part: pass"

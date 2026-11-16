#!/bin/sh
# Unit test for scripts/man2text.py: troff requests and font escapes go,
# section names stay (upper case), option lines stay.
set -eu
HERE=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
out=$(printf '.TH potrace 1 "x" "Version 1.16"\n.SH NAME\npotrace \\- trace\n.SH OPTIONS\n.TP\n.B \\-s, \\-\\-svg\nSVG \\fIoutput\\fP.\n.\\" a comment\n' | python3 "$HERE/scripts/man2text.py")
fail() { echo "FAIL: $*"; echo "$out"; exit 1; }
echo "$out" | grep -qx 'POTRACE(1)' || fail title
echo "$out" | grep -qx 'NAME' || fail section
echo "$out" | grep -qx '    potrace - trace' || fail dash
echo "$out" | grep -qx '    -s, --svg' || fail tp
echo "$out" | grep -qx '        SVG output.' || fail font
echo "$out" | grep -q 'comment' && fail comment
echo "$out" | grep -q '\\f' && fail escape
echo "test-man2text: pass"

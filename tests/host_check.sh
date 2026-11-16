#!/bin/sh
# Host test: Potrace and mkbitmap built from the locked tarball with this
# port's amiga/config.h (the Amiga build's settings, with the host's zlib in
# place of z.library), then Potrace's own check scripts run against them:
# the tracing, every backend, the input readers and mkbitmap.
#   tests/host_check.sh [potrace-1.16.tar.gz]   (fetched when not given)
# GPL-2.0-or-later, like Potrace. Copyright (c) 2026 AmiCradle Team.
set -eu
HERE=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
. "$HERE/potrace.lock"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
TGZ=${1:-$T/potrace.tar.gz}
[ -f "$TGZ" ] || curl -sSfL --retry 2 -o "$TGZ" "$POTRACE_URL"
echo "$POTRACE_SHA256  $TGZ" | sha256sum -c --status || { echo "FAIL: tarball hash"; exit 1; }
tar -xzf "$TGZ" -C "$T"
S=$T/potrace-$POTRACE_VERSION
CC=${CC:-cc}
CF="-O1 -DHAVE_CONFIG_H -I$HERE/amiga -I$S/src -I$S/src/include/getopt"
LIB="curve.c trace.c decompose.c potracelib.c"
cd "$S/src"
# shellcheck disable=SC2086
$CC $CF -o potrace main.c bitmap_io.c backend_eps.c flate.c greymap.c render.c backend_pgm.c backend_svg.c \
    backend_xfig.c backend_dxf.c backend_pdf.c backend_geojson.c lzw.c progress_bar.c bbox.c trans.c $LIB -lz -lm
# shellcheck disable=SC2086
$CC $CF -o mkbitmap mkbitmap.c bitmap_io.c greymap.c -lm
cd "$S/check"
# shellcheck disable=SC2086
$CC $CF -o pgmdiff pgmdiff.c ../src/greymap.c ../src/bitmap_io.c -lm
$CC $CF -o checkbin checkbin.c
fail=0
for t in potrace-check.sh backend-check.sh input-check.sh mkbitmap-check.sh mkbitmap-input-check.sh; do
    if srcdir=. EXEEXT= TEMPDIR="$T" sh "$t" > "$T/$t.log" 2>&1; then echo "pass: $t"
    else echo "FAIL: $t"; tail -5 "$T/$t.log"; fail=1; fi
done
./../src/potrace --version | grep -q "potrace 1.16" || { echo "FAIL: version"; fail=1; }
# A4 and metric: the Amiga build's defaults
../src/potrace --version 2>&1 | grep -q "Default page size: a4" && ../src/potrace --version 2>&1 | grep -q "Default unit: centimeters" || { echo "FAIL: A4 and centimetres default"; fail=1; }
[ $fail = 0 ] && echo "Potrace checks: all passed"
exit $fail

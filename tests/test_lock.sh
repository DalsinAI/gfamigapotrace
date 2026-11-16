#!/bin/sh
# potrace.lock pins everything build-amiga.sh fetches.
set -eu
HERE=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
. "$HERE/potrace.lock"
echo "$POTRACE_SHA256" | grep -Eqx '[0-9a-f]{64}' || { echo "FAIL sha256"; exit 1; }
echo "$GUEST_COMMIT" | grep -Eqx '[0-9a-f]{40}' || { echo "FAIL guest commit"; exit 1; }
case "$POTRACE_URL" in *"/$POTRACE_VERSION/potrace-$POTRACE_VERSION.tar.gz") ;; *) echo "FAIL url"; exit 1;; esac
grep -q "potrace $POTRACE_VERSION " "$HERE/amiga/amiga_start.c" || { echo "FAIL \$VER version"; exit 1; }
grep -q "\"$POTRACE_VERSION\"" "$HERE/amiga/config.h" || { echo "FAIL config.h version"; exit 1; }
echo "test_lock: pass"

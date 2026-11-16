#!/bin/sh
# Writes the Part file GFOpenUpTool INSTALL reads (gfopenup src/openuptool.c):
# "copy" for each file under the part drawer, each to SYS:<its path>
# (C/potrace -> SYS:C/potrace, Utilities/Potrace/... -> SYS:Utilities/Potrace/...).
#   write-part.sh <part drawer> <version>
# GPL-2.0-or-later. Copyright (c) 2026 AmiCradle Team.
set -eu
P=$1; V=$2
{
    echo "part Potrace $V"
    echo "; Potrace: traces bitmaps (PBM, PGM, PPM, BMP) into SVG, PDF, EPS, DXF and more; mkbitmap prepares scans"
    echo "needs 68040"
    (cd "$P" && find C Utilities -type f ! -name Part | LC_ALL=C sort) | while read -r f; do
        echo "copy \"$f\" \"SYS:$f\""
    done
} > "$P/Part"

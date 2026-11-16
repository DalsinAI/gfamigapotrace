# Potrace for GFOS

Potrace 1.16 by Peter Selinger, built for GFOS (AmigaOS 3.2.3 with GFOpenUp)
on a 68040: soft float that takes the FPU when there is one (fpuauto).

* `potrace` traces a black and white bitmap (PBM, PGM, PPM or BMP) into
  smooth vector graphics: SVG, PDF, EPS, PostScript, DXF, GeoJSON, PGM,
  Gimppath or XFig.
* `mkbitmap` turns a colour or grey scan into a clean bitmap for potrace
  (highpass filter, scaling, threshold).

PDF and PostScript output are compressed through z.library (GFOpenZlib,
version 53 or later in LIBS:); no zlib is built in. Page size defaults to A4
and the default unit is centimetres.

## Use

    1> mkbitmap -f 2 -s 2 -t 0.48 scan.pgm -o scan.pbm
    1> potrace -s scan.pbm -o scan.svg
    1> potrace -b pdf -r 300 scan.pbm -o scan.pdf

`potrace --help` and `mkbitmap --help` list every option; the full manuals are
in `SYS:Utilities/Potrace/potrace.txt` and `mkbitmap.txt`.

## Install

The GFOpenUp part installs `SYS:C/potrace`, `SYS:C/mkbitmap` and
`SYS:Utilities/Potrace/` (this ReadMe, the manuals, Potrace's own README,
AUTHORS and COPYING):

    1> GFOpenUpTool INSTALL Parts/Potrace

Needs a 68040 or 68060 and z.library 53 for compressed PDF and PostScript.

## Build

    STOVE=~/AmiCradle/stoves/os32-gcc16-open6 OUT=out ./build-amiga.sh

`potrace.lock` pins Potrace's release tarball (by SHA-256) and the
amicradle-guest commit that gives z.library's SDK and fpuauto. Nothing
third-party is kept in this repository.

## Tests

    sh tests/test_host.sh

Unit tests for the part writer, the manual converter and the lock, then
Potrace's own check scripts (potrace, backends, input formats, mkbitmap) on a
host build made with this port's `amiga/config.h`.

## Licence

GPL-2.0-or-later, like Potrace (see LICENSE). Potrace is copyright (C)
2001-2019 Peter Selinger. Port: Copyright (c) 2026 AmiCradle Team.

Designed, tested and delivered by The AmiCradle Team.

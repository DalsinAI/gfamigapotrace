#!/bin/sh
# Builds Potrace 1.16 (potrace and mkbitmap) for GFOS (AmigaOS 3.2.3 with
# GFOpenUp) with a stove: 68040, soft float with the FPU taken when there
# is one (fpuauto); PDF and PostScript compression through z.library.
#   STOVE=.../stoves/os32-gcc16-open6 OUT=out ./build-amiga.sh
# Potrace's release tarball, z.library's SDK and fpuauto are fetched at what
# potrace.lock gives; nothing third-party is kept here.
# OUT gets Parts/Potrace: a GFOpenUp part (its Part file and its files),
# installed with  GFOpenUpTool INSTALL Parts/Potrace
#   SYS:C/potrace, SYS:C/mkbitmap, SYS:Utilities/Potrace/ (ReadMe, manuals, licence)
# GPL-2.0-or-later, like Potrace. Copyright (c) 2026 AmiCradle Team.
set -eu
HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$HERE/potrace.lock"
STOVE=${STOVE:-"$HOME/AmiCradle/stoves/os32-gcc16-open6"}
WORK="${WORK:-$HOME/.cache/gfamigapotrace/build}"; OUT="${OUT:-$WORK/out}"
TC="$STOVE/prefix"; PATH="$TC/bin:$PATH"; export PATH
mkdir -p "$WORK" "$OUT"; OUT=$(cd "$OUT" && pwd)
t0=$(date +%s)
m68k-amigaos-gcc --version | head -n 1

# --- Potrace's release tarball, checked ---------------------------------------
TGZ="$WORK/potrace-$POTRACE_VERSION.tar.gz"
[ -f "$TGZ" ] || curl -sSfL --retry 2 --max-time 300 -o "$TGZ" "$POTRACE_URL"
echo "$POTRACE_SHA256  $TGZ" | sha256sum -c --status || { rm -f "$TGZ"; echo "potrace tarball: hash mismatch"; exit 1; }
SRC="$WORK/potrace-$POTRACE_VERSION"
rm -rf "$SRC"; tar -xzf "$TGZ" -C "$WORK"

# --- z.library's SDK and fpuauto from amicradle-guest -------------------------
G="$WORK/guest"
if [ "$(git -C "$G" rev-parse HEAD 2>/dev/null)" != "$GUEST_COMMIT" ]; then
    rm -rf "$G"; mkdir -p "$G"; git -C "$G" init -q
    git -C "$G" config core.sparseCheckout true
    printf '/libraries/openzlib/sdk/\n/common/fpuauto/\n' > "$G/.git/info/sparse-checkout"
    git -C "$G" fetch -q --depth 1 --filter=blob:none "$GUEST_REPO" "$GUEST_COMMIT"
    git -C "$G" checkout -q FETCH_HEAD
fi
ZSDK="$G/libraries/openzlib/sdk/Include_H"
[ -f "$ZSDK/proto/z.h" ] || { echo "no z.library SDK at $GUEST_COMMIT"; exit 1; }
FA="$G/common/fpuauto"; FAL="$WORK/fpuauto"
if [ ! -f "$FAL/libfpuauto.a" ] || [ "$(cat "$FAL/.rev" 2>/dev/null)" != "$GUEST_COMMIT" ]; then
    rm -rf "$FAL"; mkdir -p "$FAL/obj"
    m68k-amigaos-gcc -m68040 -DFPUAUTO_COMMON -c "$FA/fpuauto.S" -o "$FAL/obj/fa_common.o"
    for n in $(sed 's/^--wrap=//' "$FA/fpuauto.wraps"); do
        m68k-amigaos-gcc -m68040 -DR_$n -c "$FA/fpuauto.S" -o "$FAL/obj/fa_$n.o"
    done
    m68k-amigaos-ar rcs "$FAL/libfpuauto.a" "$FAL"/obj/fa_*.o
    echo "$GUEST_COMMIT" > "$FAL/.rev"
fi

# --- compile and link -----------------------------------------------------------
LATE=""
if m68k-amigaos-gcc -fno-late-combine-instructions -S -o /dev/null -x c /dev/null 2>/dev/null; then LATE="-fno-late-combine-instructions"; fi
CF="-std=gnu17 -noixemul -m68040 -O2 -fomit-frame-pointer -fno-delete-null-pointer-checks $LATE -DHAVE_CONFIG_H -I$HERE/amiga -I$HERE/amiga/zlib -I$ZSDK -I$SRC/src -I$SRC/src/include/getopt"
LF="-noixemul -m68040 -specs=$HERE/scripts/m68k-soft-m68040.specs -specs=$FA/fpuauto.specs -L$FAL"
O="$WORK/obj"; rm -rf "$O"; mkdir -p "$O"
cc1() { m68k-amigaos-gcc $CF "$@"; }
for f in main bitmap_io backend_eps flate greymap render backend_pgm backend_svg backend_xfig backend_dxf \
         backend_pdf backend_geojson lzw progress_bar bbox trans curve trace decompose potracelib mkbitmap getopt getopt1; do
    cc1 -c "$SRC/src/$f.c" -o "$O/$f.o" 2> "$O/$f.log" || { cat "$O/$f.log"; exit 1; }
done
cc1 -c "$HERE/amiga/zlib_glue.c" -o "$O/zlib_glue.o"
cc1 -c "$HERE/amiga/amiga_start.c" -o "$O/start_potrace.o"
cc1 -DGFOS_MKBITMAP -c "$HERE/amiga/amiga_start.c" -o "$O/start_mkbitmap.o"
cd "$O"
m68k-amigaos-gcc $LF -o potrace.debug main.o bitmap_io.o backend_eps.o flate.o greymap.o render.o backend_pgm.o \
    backend_svg.o backend_xfig.o backend_dxf.o backend_pdf.o backend_geojson.o lzw.o progress_bar.o bbox.o trans.o \
    curve.o trace.o decompose.o potracelib.o getopt.o getopt1.o zlib_glue.o start_potrace.o -lm
m68k-amigaos-gcc $LF -o mkbitmap.debug mkbitmap.o bitmap_io.o greymap.o getopt.o getopt1.o start_mkbitmap.o -lm
cd "$HERE"

# --- the GFOpenUp part: Parts/Potrace -------------------------------------------
P="$OUT/Parts/Potrace"; rm -rf "$P"; mkdir -p "$P/C" "$P/Utilities/Potrace"
m68k-amigaos-strip -o "$P/C/potrace" "$O/potrace.debug"
m68k-amigaos-strip -o "$P/C/mkbitmap" "$O/mkbitmap.debug"
D="$P/Utilities/Potrace"
cp "$HERE/README.md" "$D/ReadMe"
cp "$SRC/README" "$D/ReadMe-Potrace"
cp "$SRC/COPYING" "$D/COPYING"
cp "$SRC/AUTHORS" "$D/AUTHORS"
# the manuals as plain text (their troff markup taken out; no groff needed)
for m in potrace mkbitmap; do
    sed -e 's/@VERSION@/1.16/g' -e 's/@INSTALL_PREFIX@/SYS:/g' "$SRC/doc/$m.1.in" | python3 "$HERE/scripts/man2text.py" > "$D/$m.txt"
done
sh "$HERE/scripts/write-part.sh" "$P" "$POTRACE_VERSION"
ls -l "$P/C"
m68k-amigaos-nm "$O/potrace.debug" | grep -qi ' U _\?inflate\| T _deflate' && { echo "a zlib was linked in"; exit 1; }
strings "$P/C/potrace" | grep -q 'potrace 1.16 (16.11.2026) GFOS' || { echo "no \$VER"; exit 1; }
echo "part: $(grep -c '^copy' "$P/Part") files, $(du -sk "$P" | cut -f1) KB"
echo "fpuauto: $(m68k-amigaos-nm "$O/potrace.debug" | grep -c ' T ___wrap_') wrapped routines"
echo "total: $(( $(date +%s) - t0 )) s"

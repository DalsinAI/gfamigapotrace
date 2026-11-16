/* <zlib.h> for Potrace on GFOS: the deflate calls flate.c makes, through
 * z.library (GFOpenZlib, LIBS:z.library) instead of a zlib linked in.
 * z_stream and the Z_ codes are z.library's own (libraries/z.h).
 * GPL-2.0-or-later, like Potrace. Copyright (c) 2026 AmiCradle Team. */
#ifndef GFOS_POTRACE_ZLIB_H
#define GFOS_POTRACE_ZLIB_H

#include <exec/types.h>
#include <libraries/z.h>

#ifndef Z_NULL
#define Z_NULL 0
#endif
typedef UBYTE Bytef;

/* z.library 53 or later, opened on first use and closed at exit; without
 * it they answer Z_STREAM_ERROR with msg saying so. */
int gfos_deflateInit(z_stream *strm, int level);
int gfos_deflate(z_stream *strm, int flush);
int gfos_deflateEnd(z_stream *strm);

#define deflateInit(s, l) gfos_deflateInit((s), (l))
#define deflate(s, f)     gfos_deflate((s), (f))
#define deflateEnd(s)     gfos_deflateEnd((s))

#endif

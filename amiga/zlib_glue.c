/* See zlib.h. GPL-2.0-or-later, like Potrace. Copyright (c) 2026 AmiCradle Team. */
#include <zlib.h>
#include <stdlib.h>
#include <proto/exec.h>
#include <proto/z.h>

struct Library *ZBase;
static const char no_zlib[] = "needs z.library 53 or later in LIBS: (GFOpenZlib)";

static void close_z(void)
{
    if (ZBase) { CloseLibrary(ZBase); ZBase = 0; }
}

static int open_z(z_stream *s)
{
    if (!ZBase) {
        ZBase = OpenLibrary((CONST_STRPTR)"z.library", 53);
        if (ZBase) atexit(close_z);
    }
    if (!ZBase) { s->msg = no_zlib; return 0; }
    return 1;
}

int gfos_deflateInit(z_stream *s, int level)
{
    if (!open_z(s)) return Z_STREAM_ERROR;
    /* z.library allocates for itself: zalloc/zfree/opaque are not called */
    return (int)DeflateInit(s, level);
}

int gfos_deflate(z_stream *s, int flush)
{
    if (!open_z(s)) return Z_STREAM_ERROR;
    return (int)Deflate(s, flush);
}

int gfos_deflateEnd(z_stream *s)
{
    if (!open_z(s)) return Z_STREAM_ERROR;
    return (int)DeflateEnd(s);
}

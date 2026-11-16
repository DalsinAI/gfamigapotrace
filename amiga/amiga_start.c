/* The version strings and a stack big enough for Potrace's path tracing on
 * large bitmaps (libnix's startup sets __stack up for a Shell's 4 KB).
 * GPL-2.0-or-later, like Potrace. Copyright (c) 2026 AmiCradle Team. */
unsigned long __stack = 256 * 1024;
#ifdef GFOS_MKBITMAP
static const char version[] __attribute__((used)) = "$VER: mkbitmap 1.16 (16.11.2026) GFOS 68040";
#else
static const char version[] __attribute__((used)) = "$VER: potrace 1.16 (16.11.2026) GFOS 68040";
#endif

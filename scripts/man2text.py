#!/usr/bin/env python3
"""Turns a troff man page (stdin) into plain text (stdout) for an Amiga ReadMe.
Only the requests Potrace's two manuals use: .TH .SH .SS .TP .PP .LP .IP .B .I
.BR .IR .RS .RE .nf .fi .br .sp .TS/.TE and \\f font escapes.
Copyright (c) 2026 AmiCradle Team. GPL-2.0-or-later."""
import re, sys

def inline(s):
    s = re.sub(r'\\f[BIRP]|\\f\(..', '', s)
    s = s.replace('\\-', '-').replace('\\e', '\\').replace('\\(em', '--').replace('\\(en', '-')
    s = s.replace('\\&', '').replace('\\ ', ' ').replace('\\|', '').replace('\\^', '')
    s = re.sub(r'\\\(..', '', s)
    return s

def main():
    out, indent, pending_tp = [], 0, False
    for raw in sys.stdin.read().splitlines():
        line = raw.rstrip()
        if line.startswith(('.\\"', "'\\\"")) or line in ('.', "'"):
            continue
        if line.startswith('.'):
            parts = line[1:].split(None, 1)
            req = parts[0] if parts else ''
            arg = parts[1] if len(parts) > 1 else ''
            arg = arg.replace('"', '')
            if req == 'TH':
                f = arg.split()
                out.append(f'{f[0].upper()}({f[1] if len(f) > 1 else 1})'); out.append('')
            elif req == 'SH':
                out.append(''); out.append(inline(arg).upper()); indent = 4
            elif req == 'SS':
                out.append(''); out.append('  ' + inline(arg)); indent = 4
            elif req in ('PP', 'LP', 'P', 'sp'):
                out.append(''); indent = 4
            elif req == 'TP':
                out.append(''); pending_tp = True
            elif req == 'IP':
                out.append(''); out.append(' ' * 4 + inline(arg)); indent = 8
            elif req in ('B', 'I', 'SM'):
                text = ' ' * indent + inline(arg)
                if pending_tp: text = ' ' * 4 + inline(arg); indent = 8; pending_tp = False
                out.append(text)
            elif req in ('BR', 'IR', 'RB', 'RI', 'BI', 'IB'):
                text = inline(''.join(arg.split()))
                if pending_tp: out.append(' ' * 4 + text); indent = 8; pending_tp = False
                else: out.append(' ' * indent + text)
            elif req == 'RS':
                indent += 4
            elif req == 'RE':
                indent = max(4, indent - 4)
            # .nf .fi .br .TS .TE .ad .na .ne .in and the rest: no output
            continue
        text = inline(line)
        if pending_tp:
            out.append(' ' * 4 + text); indent = 8; pending_tp = False
        else:
            out.append(' ' * indent + text if text else '')
    txt = '\n'.join(out)
    txt = re.sub(r'\n{3,}', '\n\n', txt).strip('\n') + '\n'
    sys.stdout.write(txt)

if __name__ == '__main__':
    main()

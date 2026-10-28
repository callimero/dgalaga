#!/usr/bin/env python3
"""Writes a copy of a cart without comments, blank lines and leading
indentation, for the exports (.p8.png and index.html): the png can hold
only so much compressed code, and the comments count too.

Tab separators (-->8) stay, strings are respected. The source cart keeps
its comments.

Usage:  python3 tools/strip.py dgalaga.p8 /tmp/dgalaga_min.p8
"""
import sys

src, dst = sys.argv[1], sys.argv[2]
lines = open(src).read().split('\n')
a = lines.index('__lua__') + 1
b = next(i for i in range(a, len(lines)) if lines[i].startswith('__'))


def strip(line):
    q = None
    i = 0
    while i < len(line):
        c = line[i]
        if q:
            if c == '\\':
                i += 1
            elif c == q:
                q = None
        elif c in '"\'':
            q = c
        elif line.startswith('--', i):
            return line[:i]
        i += 1
    return line


lua = []
for line in lines[a:b]:
    if line.startswith('-->8'):
        lua.append('-->8')
        continue
    line = strip(line).strip()
    if line:
        lua.append(line)

out = lines[:a] + lua + lines[b:]
open(dst, 'w').write('\n'.join(out))
print('code chars %d -> %d' % (sum(len(l) + 1 for l in lines[a:b]),
                               sum(len(l) + 1 for l in lua)))

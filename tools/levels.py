#!/usr/bin/env python3
"""Writes the levels into the map of dgalaga.p8 (map rows 0-31,
memory 0x2000-0x2fff). Stand-in until the web level editor exists.

Usage:  python3 tools/levels.py dgalaga.p8

Format per level (bytes):
  len (whole level incl. this byte; 0 = end of list)
  type (0 normal, 1 bonus)
  cols, rows
  per slot (row by row): kind + 16*stream   (kind 0 = empty)
  number of streams
  per stream: delay/4, gap (frames), speed*16, kind, count
              (kind/count only used in bonus levels),
              segments m, then 1+3m points as x+64, y+64
kinds: 1 red, 2 green, 3 blue, 4 bug
"""
import sys

KIND = {'.': 0, 'r': 1, 'g': 2, 'b': 3, 'B': 4}
KIND_NAME = {'red': 1, 'green': 2, 'blue': 3, 'bug': 4}


def mirror(pts):
    """mirror a path left <-> right (screen is 128 wide)"""
    return [(127 - x, y) for x, y in pts]


# formation: one string per row, one char per slot (see KIND);
# streams: which stream fills a slot, same layout, digits 1-3
LEVELS = [
    {   # 1: two streams from the top, curling in
        'grid': ['.rrr.',
                 'ggggg',
                 'bbbbb'],
        'stream': ['.112.',
                   '11222',
                   '11222'],
        'streams': [
            dict(delay=0, gap=8, speed=1.5,
                 pts=[(48, -12), (48, 70), (6, 96), (24, 50)]),
            dict(delay=40, gap=8, speed=1.5,
                 pts=mirror([(48, -12), (48, 70), (6, 96), (24, 50)])),
        ]},
    {   # 2: from the sides, two segments, bug from the top
        'grid': ['.rrBrr.',
                 'ggggggg',
                 'bbbbbbb'],
        'stream': ['.11322.',
                   '1113222',
                   '1113222'],
        'streams': [
            dict(delay=0, gap=7, speed=1.6,
                 pts=[(-12, 30), (50, 20), (70, 104), (40, 96),
                      (10, 88), (16, 50), (40, 44)]),
            dict(delay=0, gap=7, speed=1.6,
                 pts=mirror([(-12, 30), (50, 20), (70, 104), (40, 96),
                             (10, 88), (16, 50), (40, 44)])),
            dict(delay=60, gap=14, speed=1.2,
                 pts=[(64, -20), (64, 10), (64, 30), (64, 50)]),
        ]},
    {   # 3: bonus, nobody shoots, they leave at the end
        'bonus': True,
        'streams': [
            dict(delay=0, gap=10, speed=1.5, kind='red', count=8,
                 pts=[(-12, 20), (60, 124), (70, -20), (140, 60)]),
            dict(delay=100, gap=10, speed=1.5, kind='green', count=8,
                 pts=[(140, 30), (60, 134), (50, -20), (-12, 70)]),
        ]},
]


def coord(v):
    v = int(round(v)) + 64
    if not 0 <= v <= 255:
        raise SystemExit('coordinate out of range (-64..191): %d' % (v - 64))
    return v


def encode(lv):
    out = [1 if lv.get('bonus') else 0]
    grid = lv.get('grid', [])
    strm = lv.get('stream', [])
    rows = len(grid)
    cols = len(grid[0]) if grid else 0
    out += [cols, rows]
    for r in range(rows):
        for c in range(cols):
            k = KIND[grid[r][c]]
            st = int(strm[r][c]) if k else 0
            out.append(k + 16 * st)
    out.append(len(lv['streams']))
    for st in lv['streams']:
        pts = st['pts']
        if (len(pts) - 1) % 3:
            raise SystemExit('path needs 1+3*m points, has %d' % len(pts))
        out += [st['delay'] // 4, st['gap'], int(round(st['speed'] * 16)),
                KIND_NAME.get(st.get('kind'), 0), st.get('count', 0),
                (len(pts) - 1) // 3]
        for x, y in pts:
            out += [coord(x), coord(y)]
    out = [len(out) + 1] + out
    if out[0] > 255:
        raise SystemExit('level too long: %d bytes' % out[0])
    return out


def main():
    path = sys.argv[1]
    data = []
    for i, lv in enumerate(LEVELS):
        b = encode(lv)
        print('level %d: %d bytes' % (i + 1, len(b)))
        data += b
    data.append(0)
    if len(data) > 4096:
        raise SystemExit('levels too big: %d of 4096 bytes' % len(data))
    rows = (len(data) + 127) // 128
    data += [0] * (rows * 128 - len(data))
    maprows = [''.join('%02x' % v for v in data[r * 128:(r + 1) * 128])
               for r in range(rows)]

    lines = open(path).read().rstrip('\n').split('\n')
    if '__map__' in lines:
        i = lines.index('__map__') + 1
        j = i
        while j < len(lines) and not lines[j].startswith('__'):
            j += 1
        old = lines[i:j]
        # keep map rows after ours (should be empty, rows 0-31 only)
        lines[i:j] = maprows + old[rows:32]
    else:
        # sections in order: lua gfx label gff map sfx music
        k = len(lines)
        for name in ('__sfx__', '__music__'):
            if name in lines:
                k = min(k, lines.index(name))
        lines[k:k] = ['__map__'] + maprows
    open(path, 'w').write('\n'.join(lines) + '\n')
    print('written: %d bytes in %d map rows' % (len(data), rows))


if __name__ == '__main__':
    main()

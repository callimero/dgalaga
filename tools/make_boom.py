#!/usr/bin/env python3
"""Builds dgboom.p8: a small test cart that shows the explosions of one
small and one big alien in a loop, to tune them.

Settings, color tables and the explosion functions are copied from
dgalaga.p8, so the values tuned in dgboom.p8 can go back 1:1 (the block
between "-- explosion: sprites 64-68" and "fx={}").

Usage:  python3 tools/make_boom.py dgalaga.p8 ~/.lexaloffle/pico-8/carts/dgboom.p8
"""
import re
import sys

src, dst = sys.argv[1], sys.argv[2]
text = open(src).read()
lines = text.split('\n')
a = lines.index('__lua__') + 1
b = next(i for i in range(a, len(lines)) if lines[i].startswith('__'))
lua = '\n'.join(lines[a:b])


def block(start, end_pat):
    i = lua.index(start)
    m = re.compile(end_pat, re.M).search(lua, i)
    return lua[i:m.end()]


def func(name):
    return block('function %s(' % name, r'^end$')


settings = block('-- explosion: sprites 64-68', r'^fx=\{\}.*$')
anim = block('anim={', r'^\}$')
funcs = '\n\n'.join(func(n) for n in ('boom', 'spark', 'parts', 'booms'))

harness = '''-- explosion test (made by
-- tools/make_boom.py from
-- dgalaga.p8). tune the block
-- below, then copy it back.
-- ⬅️➡️ big alien, ⬆️⬇️ small one,
-- 🅾️ boom now, ❎ slow motion

''' + settings + '''

''' + anim + '''

small={"red","draco","blueb","ufo","fly","bug","greenb"}
big={"bugm","mother","flym","dracom"}
loop_t=100      -- frames per loop

pt={}
si,bi,lt,slow,fr=2,1,0,false,0

function _update60()
	if (btnp(⬅️)) bi=(bi-2)%#big+1 lt=0
	if (btnp(➡️)) bi=bi%#big+1 lt=0
	if (btnp(⬆️)) si=si%#small+1 lt=0
	if (btnp(⬇️)) si=(si-2)%#small+1 lt=0
	if (btnp(❎)) slow=not slow
	fr+=1
	if (slow and fr%4>0) return
	if btnp(🅾️) or lt==30 then
		sfx(6)
		boom({x=32,y=64,k=small[si],an=anim[small[si]]})
		boom({x=96,y=64,k=big[bi],an=anim[big[bi]]})
	end
	lt=(lt+1)%loop_t
end

function _draw()
	cls(0)
	-- the aliens until they blow up
	if lt<30 then
		spr(anim[small[si]][1][1],28,60)
		spr(anim[big[bi]][1][1],88,56,2,2)
	end
	parts()
	booms()
	print(small[si],32-#small[si]*2,90,6)
	print(big[bi],96-#big[bi]*2,90,6)
	print("⬅️➡️ big  ⬆️⬇️ small",14,108,5)
	print("🅾️ boom  ❎ slow"..(slow and " (on)" or ""),14,116,5)
end

''' + funcs + '\n'


def section(name):
    if '__%s__' % name not in lines:
        return []
    i = lines.index('__%s__' % name)
    j = i + 1
    while j < len(lines) and not lines[j].startswith('__'):
        j += 1
    return lines[i:j]


out = ['pico-8 cartridge // http://www.pico-8.com', 'version 43', '__lua__',
       harness.rstrip('\n')]
for name in ('gfx', 'gff', 'sfx'):
    out += section(name)
open(dst, 'w').write('\n'.join(out) + '\n')
print('written', dst)

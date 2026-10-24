-- todo
	-- enemies formation
	-- attacks
	-- levels
	-- level transitions
	-- meteor storm
 -- object class 
 	
-- settings

p={x=64-4, y=118, w=1} -- w: weapon
s={}
ns=100
e={}
ne=10
b={} --ringbuffer later
-- own shots: magazine, reloads
-- only when empty
shot_max=3     -- shots in magazine
               -- (extras: more)
reload_time=20 -- frames per shot
shot_spd=3     -- px/frame
pb={} -- enemy plasma balls

-- weapons: list of projectiles
-- per shot, {sprite,dx}
wpn={
	{{4,0}},                  -- single
	{{5,0}},                  -- double
	{{4,-0.6},{4,0},{4,0.6}}, -- triple
}

-- animations by time: per frame
-- {sprite,flip_x,flip_y,frames}
anim={
	green={{144,false,false,20},{145,false,false,20}},
	red={{128,false,false,20},{129,false,false,20}},
	blue={{160,false,false,20},{161,false,false,20}},
	-- sz=2: sprite is 2x2
	bug={{164,false,false,12},{166,false,false,12},sz=2},
	coin={{112,false,false,6},{113,false,false,6},
		{114,false,false,6},{115,false,false,6},
		{115,false,true,6},{114,false,true,6},
		{113,false,true,6},{112,false,true,6}},
}


function _init()
	pal(4,133,1)
	-- btnp without auto repeat:
	-- holding = one shot
	poke(0x5f5c,255)
	ammo=shot_max
	reload=0
	reloading=false
	-- stars init
	for i=1,ns do
		add(s,{x=rnd(128),y=rnd(128),z=rnd(10)+2})		
	end
	-- rotation: 8 directions per kind
	rot={green=rot_tab(144),
		red=rot_tab(128),blue=rot_tab(160)}
	-- demo: formation flutters,
	-- one row per kind
	for r,k in ipairs({"red","green","blue"}) do
		for i=0,4 do
			add(e,obj_new(k,24+i*20,r*12))
		end
	end
	-- one of each dives spinning
	-- (staggered, different speeds)
	for n,k in ipairs({"red","green","blue"}) do
		local o=obj_new(k,14+n*24,-40*n,"spin")
		o.a,o.v,o.rate=0.75,0.3+n*0.1,1/(30+n*10)
		add(e,o)
	end
	-- blue flies a circle, image
	-- points where it flies
	local o=obj_new("blue",64,80,"dir")
	o.v,o.curve=0.5,0.004
	add(e,o)
	-- bug flutters over the greens
	o=obj_new("bug",64,24)
	o.cool=60
	add(e,o)
	_update60=title
end

function title()
	cls(0)
	print("pico deluxe",40,30,10)
	_update60=game
 if(btnp(❎))  _update60=game
end


function game()
	local til=0
	cls(0)
	stars()
	if(btn(⬅️)) then
	 p.x=p.x-1	--and > 0
	 til=-1
	end
	if(btn(➡️)) then
	 p.x=p.x+1 --and < 128
	 til=1
 end	
	-- debug: up = next weapon
	if (btnp(⬆️)) p.w=p.w%#wpn+1
	-- fire: one shot per press
	-- while there is ammo
	if btnp(❎) and ammo>0 then
		shoot(p.w)
		ammo-=1
	end
	-- empty: reload one shot every
	-- reload_time frames until full
	if (ammo==0) reloading=true
	if reloading then
		reload+=1
		if reload>=reload_time then
			ammo+=1
			reload=0
			if (ammo==shot_max) reloading=false
		end
	end
 enem()
 plasma()
	bullets()
	spr(19+til,p.x,p.y)
end
-->8
-- ====== objects ======
-- object: x,y = center
-- mode:
--  "anim" frames by time
--  "dir"  image points in
--         flight direction a
--  "spin" image spins with
--         rate, wherever it
--         flies
-- angles in turns:
-- 0=right 0.25=up 0.5=left
-- 0.75=down
-- a: direction, v: speed,
-- curve: change of a per frame
-- ia: image angle
-- aspd: own animation speed
-- (0.9..1.1), random start
-- frame -> formation does not
-- flutter in sync
function obj_new(k,x,y,mode)
	local o={k=k,x=x,y=y,
		mode=mode or "anim",
		an=anim[k],rt=rot[k],
		a=0.75,v=0,curve=0,
		ia=0.75,rate=0,
		aspd=0.9+rnd(0.2)}
	o.f=flr(rnd(#o.an))+1
	o.t=rnd(o.an[o.f][4])
	return o
end

function obj_update(o)
	-- fly
	o.a=(o.a+o.curve)%1
	o.x+=cos(o.a)*o.v
	o.y+=sin(o.a)*o.v
	-- image angle
	if o.mode=="spin" then
		o.ia=(o.ia+o.rate)%1
	else
		o.ia=o.a
	end
	-- frames by time
	o.t+=o.aspd
	if o.t>=o.an[o.f][4] then
		-- keep rest: exact timing
		o.t-=o.an[o.f][4]
		o.f=o.f%#o.an+1
	end
end

function obj_draw(o)
	local fr
	if o.mode=="anim" then
		fr=o.an[o.f]
	else
		fr=o.rt[flr(o.ia*8+0.5)%8+1]
	end
	-- size in sprites (1 or 2)
	local z=o.an.sz or 1
	spr(fr[1],o.x-4*z,o.y-4*z,z,z,fr[2],fr[3])
end

-- rotation table from a sprite
-- row: n=front, n+2=diagonal,
-- n+3=side. index 1..8 =
-- right,up-right,up,up-left,
-- left,down-left,down,
-- down-right.
-- image upside down: swap the
-- flips here
function rot_tab(n)
	return {
		{n+3,false,false},
		{n+2,false,false},
		{n,false,false},
		{n+2,true,false},
		{n+3,true,false},
		{n+2,true,true},
		{n,false,true},
		{n+2,false,true}}
end

-- bug: swings over the formation,
-- shoots now and then
function bug_move(o)
	o.x=64+sin(t()/6)*44
	o.y=24+sin(t()/1.5)*2
	o.cool-=1
	if o.cool<=0 then
		add(pb,{x=o.x,y=o.y+6})
		o.cool=40+rnd(60)
	end
end

-- plasma balls fall down,
-- gone at the bottom
function plasma()
	for k in all(pb) do
		k.y+=1
		spr(51,k.x-4,k.y-4)
		if (k.y>132) del(pb,k)
	end
end

function enem()
	for en in all(e) do
		if (en.k=="bug") bug_move(en)
		obj_update(en)
		-- demo: out at the bottom,
		-- in at the top
		if (en.y>136) en.y=-8
		obj_draw(en)
	end
end

function stars()
	for st in all(s) do
		st.y+=st.z/20
		pset(st.x,st.y,4+st.z/5)
		if st.y>128 then
			st.x=rnd(128)
			st.y=0
			st.z=rnd(10)+2
  end			
	end
end

-- fire weapon w: one bullet per
-- projectile, each keeps its
-- sprite and sideways speed
function shoot(w)
	for pr in all(wpn[w]) do
		add(b,{x=p.x,y=p.y-4,s=pr[1],dx=pr[2]})
	end
end

function bullets()
	for bu in all(b) do
		bu.x+=bu.dx
		bu.y-=shot_spd
		spr(bu.s,bu.x,bu.y)
		-- gone at the top
		if (bu.y<-8) del(b,bu)
	end
end


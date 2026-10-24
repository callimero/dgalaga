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
pt={} -- particles
eb={} -- enemy bullets
eshot_spd=1.5   -- px/frame
eshot_cool=40   -- frames between
                -- salvos (+random)
salvo_max=3     -- shots per salvo
                -- (1..salvo_max)
salvo_gap=14    -- frames between
                -- shots of a salvo
trail_life=15   -- frames a plasma
                -- particle lives

-- formation
form_sway=12    -- px left/right
form_period=8   -- secs per swing
dive_every=120  -- frames between
                -- waves (+random)
wave={1,1,2,2,3,3} -- divers per
                -- wave, repeats
dive_spd=1      -- px/frame
dive_pre=15     -- frames down
                -- before the spin
dive_spin=1/30  -- turns/frame
dive_turns=2    -- spins, then stop
                -- (+0..2 random)
back_spd=1.2    -- px/frame home
back_turn=0.02  -- max turn/frame

-- weapons: list of projectiles
-- per shot, {sprite,dx,hit width}
-- hit width: half width of the
-- shot (double: two shots in one
-- sprite, so wider)
wpn={
	{{4,0,1}},                        -- single
	{{5,0,3}},                        -- double
	{{6,-0.6,1},{6,0,1},{6,0.6,1}},   -- triple
}

-- hit points and score per kind
hp={red=1,green=1,blue=1,bug=5}
worth={red=50,green=40,blue=30,bug=200}
flash_time=4    -- frames white
                -- after a hit
-- explosion: sprites 64-68,
-- frames per image
boom_spd=4
-- particle colors per kind
-- {bright,dark}
col={red={8,2},green={11,3},
	blue={12,1},bug={14,2}}
fx={} -- running explosions

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
	-- score/hiscore: shown between
	-- levels later
	score=0
	hiscore=0
	lives=3
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
	-- formation: one row per kind,
	-- each enemy has its slot
	-- (col,row) and a state st
	for r,k in ipairs({"red","green","blue"}) do
		for c=0,4 do
			local o=obj_new(k,0,0)
			o.col,o.row,o.st=c,r,"form"
			o.x,o.y=slot(o)
			add(e,o)
		end
	end
	dive_cool=dive_every
	wave_n=0
	-- bug flutters over the greens
	local o=obj_new("bug",64,24)
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
 ebullets()
	bullets()
	spr(19+til,p.x,p.y)
	hud()
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
		aspd=0.9+rnd(0.2),
		hp=hp[k] or 1,fl=0}
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
	-- just hit: all colors white
	local f=o.fl>0
	if f then
		o.fl-=1
		for c=1,15 do pal(c,7) end
	end
	spr(fr[1],o.x-4*z,o.y-4*z,z,z,fr[2],fr[3])
	-- pal() resets everything, also
	-- the dark grey of the stars
	if (f) pal() pal(4,133,1)
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
-- gone at the bottom. they shed
-- green particles
function plasma()
	for k in all(pb) do
		k.y+=1
		if rnd()<0.5 then
			add(pt,{x=k.x-3+rnd(3),y=k.y-2,
				dx=rnd(0.4)-0.2,dy=-rnd(0.3),
				l=trail_life,ml=trail_life,c1=11,c2=3})
		end
		spr(51,k.x-4,k.y-4)
		if (k.y>132) del(pb,k)
	end
	parts()
	booms()
end

-- particles drift and fade:
-- color c1 in the first half of
-- their life (ml), then c2
function parts()
	for q in all(pt) do
		q.x+=q.dx
		q.y+=q.dy
		q.l-=1
		pset(q.x,q.y,q.l>q.ml/2 and q.c1 or q.c2)
		if (q.l<=0) del(pt,q)
	end
end

-- slot of an enemy in the
-- formation, whole formation
-- swings left and right
function slot(o)
	return 24+o.col*20+sin(t()/form_period)*form_sway,
		o.row*12
end

-- now and then one enemy leaves
-- the formation
-- waves of divers: sizes from
-- wave, next wave when the time
-- is up and all are back home
function start_dive()
	dive_cool-=1
	local f={}
	for en in all(e) do
		if (en.st=="form") add(f,en)
		-- someone still out: wait
		if (en.st=="dive" or en.st=="back") return
	end
	if (dive_cool>0 or #f==0) return
	dive_cool=dive_every+rnd(dive_every)
	wave_n=wave_n%#wave+1
	for i=1,min(wave[wave_n],#f) do
		local o=rnd(f)
		del(f,o)
		-- first straight down, then
		-- the spin (see form_move)
		o.st,o.mode="dive","dir"
		o.pre=dive_pre
		o.a,o.v,o.rate=0.75,dive_spd,dive_spin
		-- how far it spins (turns)
		o.spin=dive_turns+rnd(2)
		-- arc to the left or right
		o.curve=rnd({-1,1})*0.002
		-- shot when leaving the
		-- formation
		eshoot(o)
	end
end

-- formation states:
-- form: sits on its slot
-- dive: spins down in an arc
-- back: comes in from the top,
--       steers home, rejoins
function form_move(o)
	if o.st=="form" then
		o.x,o.y=slot(o)
	elseif o.st=="dive" then
		-- spun enough: image points
		-- where it flies again
		-- 1. straight down, no shots
		if o.pre>0 then
			o.pre-=1
			if (o.pre<=0) o.mode="spin"
		-- 2. spin, no shots
		elseif o.mode=="spin" then
			o.spin-=o.rate
			-- spin over: sink and shoot
			-- right away
			if o.spin<=0 then
				o.mode="dir"
				o.cool=0
			end
		-- 3. sinking: shoot while above
		-- the ship
		elseif o.y<p.y then
			o.cool-=1
			if (o.cool<=0) eshoot(o)
		end
		-- salvo running: next shot
		if o.burst>0 and o.y<p.y then
			o.bgap-=1
			if o.bgap<=0 then
				add(eb,{x=o.x,y=o.y+4,dx=0,dy=eshot_spd})
				o.burst-=1
				o.bgap=salvo_gap
			end
		end
		-- out of the screen (any side):
		-- back in at the top
		if o.y>136 or o.x<-12 or o.x>140 then
			o.x,o.y=mid(8,o.x,120),-8
			o.st,o.mode="back","dir"
			o.curve,o.v=0,back_spd
		end
	elseif o.st=="back" then
		local sx,sy=slot(o)
		local dx,dy=sx-o.x,sy-o.y
		-- turn towards the slot,
		-- at most back_turn per frame
		local d=(atan2(dx,dy)-o.a+0.5)%1-0.5
		o.a+=mid(-back_turn,d,back_turn)
		-- close: glide into the slot
		-- (turn circle is ~10 px)
		local n=abs(dx)+abs(dy)
		if n<12 then
			o.v=0
			o.x+=dx*0.15
			o.y+=dy*0.15
		end
		if n<1 then
			o.st,o.mode="form","anim"
		end
	end
end

-- start a salvo of 1..salvo_max
-- shots, straight down. the shots
-- are fired in form_move
function eshoot(o)
	o.burst=flr(rnd(salvo_max))+1
	o.bgap=0
	o.cool=eshot_cool+rnd(eshot_cool)
end

-- enemy bullets fly straight,
-- gone outside the screen
function ebullets()
	for q in all(eb) do
		q.x+=q.dx
		q.y+=q.dy
		spr(0,q.x-4,q.y-3)
		if (q.y>132 or q.x<-8 or q.x>136) del(eb,q)
	end
end

function enem()
	start_dive()
	for en in all(e) do
		if (en.k=="bug") bug_move(en)
		if (en.st) form_move(en)
		obj_update(en)
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

-- ships left, top right
function hud()
	spr(21,110,-1)
	print("x"..lives,118,1,7)
end

-- fire weapon w: one bullet per
-- projectile, each keeps its
-- sprite and sideways speed
function shoot(w)
	for pr in all(wpn[w]) do
		add(b,{x=p.x,y=p.y-4,s=pr[1],dx=pr[2],w=pr[3]})
	end
end

function bullets()
	for bu in all(b) do
		bu.x+=bu.dx
		bu.y-=shot_spd
		spr(bu.s,bu.x,bu.y)
		-- gone at the top or on a hit
		if (bu.y<-8 or hit(bu)) del(b,bu)
	end
end

-- does bullet bu hit an enemy?
-- shot center is x+3.5,y+3 in
-- its sprite, enemy box is its
-- size minus 1 px each side
function hit(bu)
	local bx,by=bu.x+3.5,bu.y+3
	for en in all(e) do
		local r=4*(en.an.sz or 1)-1
		if abs(bx-en.x)<r+bu.w and abs(by-en.y)<r then
			en.hp-=1
			en.fl=flash_time
			if en.hp<=0 then
				score+=worth[en.k] or 0
				boom(en)
				del(e,en)
			end
			return true
		end
	end
	return false
end

-- explosion: sprite animation
-- plus a burst of particles in
-- the enemy's colors
function boom(o)
	local z=o.an.sz or 1
	add(fx,{x=o.x,y=o.y,z=z,t=0})
	local c=col[o.k] or {10,8}
	for i=1,12*z do
		local a,v=rnd(),0.3+rnd(1)*z
		add(pt,{x=o.x,y=o.y,
			dx=cos(a)*v,dy=sin(a)*v,
			l=20+rnd(10),ml=30,c1=c[1],c2=c[2]})
	end
end

-- explosions: 5 images, then gone.
-- big enemies: drawn 2x (sspr)
function booms()
	for q in all(fx) do
		local n=flr(q.t/boom_spd)
		if n>4 then
			del(fx,q)
		else
			local sx,sy=(64+n)%16*8,(64+n)\16*8
			local w=8*q.z
			sspr(sx,sy,8,8,q.x-w/2,q.y-w/2,w,w)
		end
		q.t+=1
	end
end


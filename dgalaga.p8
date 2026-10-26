pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
-- todo
	-- enemies formation
	-- attacks
	-- levels
	-- level transitions
	-- meteor storm
 -- object class 
 	
-- gameplay tuning: put settings here to try
-- them out. runs first in _init and
-- overrides the values further down
function tune()
	-- enter_cool=30
	-- kami_spd=2
	dbg_start = 1 --startlevel
	dbg_keys=true -- debug, pc only:
               -- k/l level chose, w weapon
end

-- settings
-- ship at the start of a game (the
-- current values are in p, see
-- new_ship). w: weapon 1-3,
-- shots: battery size (charges)
ship0={spd=0.8,lives=3,w=1,shots=3,armor=0}
spd_step=0.2    -- speed extra
spd_max=2
shots_max=20    -- battery max
                -- (bullet extras)
shield_time=600 -- frames of a
                -- shield extra
                -- (shield = blinking,
                -- cannot be hit)

-- extras: an alien that dies drops
-- one with drop_chance. which one:
-- by weight wt. fn: what it does
drop_chance=0.1
item_spd=0.6    -- px/frame falling
extra={
	bullet={s=34,wt=10,fn=function() more_shots() end},
	speed= {s=35,wt=5, fn=function() p.spd=min(p.spd+spd_step,spd_max) end},
	shield={s=36,wt=3, fn=function() p.inv=max(p.inv,shield_time) end},
	single={s=37,wt=2, fn=function() weapon(1) end},
	double={s=38,wt=2, fn=function() weapon(2) end},
	triple={s=39,wt=1, fn=function() weapon(3) end},
	-- todo: what does the scoop do?
	scoop= {s=40,wt=0, fn=function() end},
	life=  {s=41,wt=1, fn=function() p.lives+=1 end},
}
it={} -- falling extras
dead_time=90    -- frames until the
                -- ship comes back
inv_time=120    -- frames blinking,
                -- cannot be hit
ship_r=3        -- hit box half size
s={}
ns=100
e={}
ne=10
b={} --ringbuffer later
-- own shots: like a battery, each
-- shot takes one charge (p.ammo of
-- p.shots), it recharges all the
-- time while not full
reload_time=5  -- frames per charge
shot_spd=3     -- px/frame
pb={} -- projectiles of big enemies
-- per big kind: sprite, speed,
-- aimed at the ship?, trail
-- colors (bright,dark; nil=none)
eshot={
	bug={s=51,v=1,aim=true,c1=11,c2=3},
	mother={s=54,v=1.2,aim=true},
	flym={s=52,v=1.1,aim=true,c1=8,c2=2},
	greenm={s=51,v=1.1,aim=true,c1=11,c2=3},
}
pt={} -- particles
eb={} -- enemy bullets
eshot_spd=1.5   -- px/frame
eshot_cool=40   -- frames between
                -- salvos (+random)
salvo_max=3     -- shots per salvo
                -- (1..salvo_max)
salvo_gap=14    -- frames between
                -- shots of a salvo
enter_cool=100   -- frames between
                -- salvos while flying
                -- in (+random, 0=none)
trail_life=15   -- frames a plasma
                -- particle lives

-- levels: stored in the map
-- (rows 0-31 = 0x2000-0x2fff),
-- written by the level editor.
-- do not paint in the map editor!
-- enemy kinds by number
kinds={"red","green","blue","bug","ufo","mother","flym","greenm"}
between_time=150 -- frames of the
                -- screen between
                -- levels

-- kamikaze level: waves of kami_n
-- aliens dive side by side from
-- the top (left to right), brake
-- at the bottom, fly back up. next
-- wave when this one is gone
kami_wait=60    -- frames at start
kami_n=5        -- aliens per wave
kami_gap=40     -- pause frames
                -- between waves
kami_dx=2      -- px side by side
kami_dy=2       -- px higher each
                -- (slanted line)
kami_spd=1.5    -- px/frame
kami_low=85     -- y where they brake
                -- (turn ~25 px lower)
kami_brake=0.05 -- slow down/frame
kami_fan=0.08   -- sideways spread
kami_cool=20    -- frames between
                -- shots (+random)
end_wait=120    -- frames the level
                -- goes on after the
                -- last enemy (and no
                -- enemy shots left)

-- big enemies roam the upper half
roam_spd=0.5    -- px/frame
roam_turn=0.01  -- max turn/frame
roam_dash=1.6   -- px/frame in a
                -- dash
dash_chance=0.3 -- per decision
roam_bottom=60  -- lowest y

-- formation
form_dx=14      -- px between cols
form_dy=12      -- px between rows
                -- (defaults, each
                -- level has its own)
form_top=14     -- y of row 0
form_sway=12    -- px left/right
                -- (less if the
                -- formation is wide)
form_period=8   -- secs per swing
dive_every=120  -- frames between
                -- waves (+random)
wave={1,1,2,2,3,3} -- divers per
                -- wave, repeats
dive_spd=1      -- px/frame
spin_spd=0.5    -- px/frame while
                -- spinning out
dive_spin=1/30  -- turns/frame
dive_turns=1    -- spins (+0..0.5)
loop_chance=0.5 -- chance of a loop
loop_r=18       -- loop radius px
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
hp={red=2,green=1,blue=1,bug=8,ufo=2,mother=8,flym=6,greenm=6}
worth={red=50,green=40,blue=30,bug=200,ufo=300,mother=500,flym=300,greenm=300}
flash_time=4    -- frames white
                -- after a hit
-- explosion: sprites 64-68,
-- frames per image
boom_spd=4
-- particle colors per kind
-- {bright,dark}
col={ship={7,12},red={8,2},green={11,3},
	blue={12,1},bug={14,2},
	ufo={6,13},mother={6,8},
	flym={12,8},greenm={11,3}}
fx={} -- running explosions

-- animations by time: per frame
-- {sprite,flip_x,flip_y,frames}
anim={
	green={{144,false,false,20},{145,false,false,20}},
	red={{128,false,false,20},{129,false,false,20}},
	blue={{160,false,false,20},{161,false,false,20}},
	-- sz=2: sprite is 2x2
	bug={{164,false,false,12},{166,false,false,12},sz=2},
	ufo={{176,false,false,20},{177,false,false,20}},
	mother={{168,false,false,16},{170,false,false,16},sz=2},
	flym={{132,false,false,10},{134,false,false,10},sz=2},
	greenm={{136,false,false,14},{138,false,false,14},sz=2},
	coin={{112,false,false,6},{113,false,false,6},
		{114,false,false,6},{115,false,false,6},
		{115,false,true,6},{114,false,true,6},
		{113,false,true,6},{112,false,true,6}},
}


function _init()
	tune()
	pal(4,133,1)
	-- btnp without auto repeat:
	-- holding = one shot
	poke(0x5f5c,255)
	-- score/hiscore: shown between
	-- levels later
	score=0
	hiscore=0
	p=new_ship()
	reload=0
	-- stars init
	for i=1,ns do
		add(s,{x=rnd(128),y=rnd(128),z=rnd(10)+2})		
	end
	-- rotation: 8 directions per kind
	rot={green=rot_tab(144),
		red=rot_tab(128),blue=rot_tab(160),
		ufo=rot_tab(176)}
	stage=dbg_start-1
	-- devkit: keyboard for debug keys
	if (dbg_keys) poke(0x5f2d,1)
	dbg_t=0
	start_level()
	_update60=title
end

function title()
	cls(0)
	stars()
	print("pico8 deluxe galaga",26,40,10)
	if (t()%1<0.7) print("press 🅾️ to start",30,70,7)
	if btnp(🅾️) then
		bt=between_time
		_update60=between
	end
end


function game()
	local til=0
	cls(0)
	stars()
	dbg_input()
	-- ship destroyed: wait, then
	-- back (or game over)
	if p.dead>0 then
		p.dead-=1
		if p.dead==0 then
			if p.lives==0 then
				_update60=over
				return
			end
			p.x,p.inv=60,inv_time
		end
	else
	if(btn(⬅️)) then
	 p.x-=p.spd
	 til=-1
	end
	if(btn(➡️)) then
	 p.x+=p.spd
	 til=1
 end
	-- stay on the screen
	p.x=mid(0,p.x,120)	
	-- fire: one shot per press
	-- while there is charge
	if btnp(🅾️) and p.ammo>0 then
		shoot(p.w)
		p.ammo-=1
	end
	end -- ship alive
	-- battery recharges all the time,
	-- one charge per reload_time
	if p.ammo<p.shots then
		reload+=1
		if reload>=reload_time then
			p.ammo+=1
			reload=0
		end
	end
 spawn()
 enem()
 plasma()
 ebullets()
	bullets()
	items()
	if p.dead==0 then
		if p.inv>0 then
			p.inv-=1
		elseif ship_hit() then
			die()
		end
		-- blink while invulnerable
		if (p.dead==0 and p.inv%8<4) spr(19+til,p.x,p.y)
	end
	hud()
	-- after a level switch: number
	if dbg_t>0 then
		dbg_t-=1
		print("stage "..stage,1,1,7)
	end
	-- bonus: blinking announcement
	if lev.bonus and #e==0 and lev.n==#lev.q and lev.t%30<20 then
		print("bonus stage",42,50,10)
	end
	-- all came and all are gone:
	-- go on a bit (explosions,
	-- shots still flying)
	if #lev.q==0 and #e==0 then
		lev.done+=1
		if lev.done>=end_wait and #eb+#pb+#it==0 and p.dead==0 then
			hiscore=max(hiscore,score)
			-- hits of a bonus/kamikaze level
			-- for the announcement
			last=(lev.bonus or lev.kami) and lev or nil
			start_level()
			bt=between_time
			_update60=between
		end
	end
end

function over()
	hiscore=max(hiscore,score)
	cls(0)
	stars()
	print("game over",46,56,8)
	local t="score "..score
	print(t,64-#t*2,66,7)
	-- restart the cart
	if (btnp(🅾️)) run()
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

-- big enemy fires its own
-- projectile, aimed at the ship
-- (where it is now) or down
function big_shot(o)
	local w=eshot[o.k]
	local a=0.75
	if (w.aim) a=atan2(p.x+4-o.x,p.y+4-o.y)
	add(pb,{x=o.x,y=o.y+6,s=w.s,
		dx=cos(a)*w.v,dy=sin(a)*w.v,
		c1=w.c1,c2=w.c2})
end

-- projectiles of big enemies fly
-- straight, gone outside the
-- screen. they may shed particles
-- (acid), left behind them
function plasma()
	for k in all(pb) do
		k.x+=k.dx
		k.y+=k.dy
		if k.c1 and rnd()<0.5 then
			add(pt,{x=k.x-3+rnd(3)-k.dx*2,y=k.y-k.dy*2,
				dx=rnd(0.4)-0.2,dy=-rnd(0.3),
				l=trail_life,ml=trail_life,c1=k.c1,c2=k.c2})
		end
		spr(k.s,k.x-4,k.y-4)
		if (k.y>132 or k.x<-8 or k.x>136) del(pb,k)
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
	return 64+(o.col-lev.rc[o.row])*lev.dx
		+sin(t()/form_period)*lev.sway,
		form_top+o.row*lev.dy
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
		-- big ones stay in formation
		if (en.st=="form" and not eshot[en.k]) add(f,en)
		-- someone still out: wait
		if (en.st=="dive" or en.st=="back" or en.st=="enter") return
	end
	if (dive_cool>0 or #f==0 or #lev.q>0) return
	dive_cool=dive_every+rnd(dive_every)
	wave_n=wave_n%#wave+1
	for i=1,min(wave[wave_n],#f) do
		local o=rnd(f)
		del(f,o)
		-- spins out of the formation,
		-- phases: see form_move
		o.st,o.ph,o.mode="dive","spin","spin"
		o.a,o.v,o.rate=0.75,spin_spd,dive_spin
		o.spin=dive_turns+rnd(0.5)
		o.curve,o.burst=0,0
		o.loop=rnd()<loop_chance
	end
end

-- formation states:
-- form: sits on its slot
-- dive: spins down in an arc
-- back: comes in from the top,
--       steers home, rejoins
function form_move(o)
	-- salvo running (dive or flying
	-- in): next shot
	if o.burst and o.burst>0 and o.y<p.y then
		o.bgap-=1
		if o.bgap<=0 then
			add(eb,{x=o.x,y=o.y+4,dx=0,dy=eshot_spd})
			o.burst-=1
			o.bgap=salvo_gap
		end
	end
	if o.st=="form" then
		o.x,o.y=slot(o)
	elseif o.st=="roam" then
		roam(o)
	elseif o.st=="kami" then
		kami_move(o)
	elseif o.st=="enter" then
		fly_path(o)
		-- shoot while flying in (not
		-- in bonus stages)
		if enter_cool>0 and not o.bonus and o.y>4 and o.y<p.y then
			o.cool-=1
			if o.cool<=0 then
				if eshot[o.k] then
					big_shot(o)
				else
					eshoot(o)
				end
				o.cool=enter_cool+rnd(enter_cool)
			end
		end
	elseif o.st=="dive" then
		-- 1. spin out, slowly
		if o.ph=="spin" then
			o.spin-=o.rate
			if o.spin<=0 then
				-- 2. dive down towards the
				-- ship's side, fire
				o.ph,o.mode="down","dir"
				o.a=0.75+sgn(p.x+4-o.x)*(0.03+rnd(0.07))
				o.v=dive_spd
				eshoot(o)
			end
		else
			-- shoot while above the ship
			if o.y<p.y then
				o.cool-=1
				if (o.cool<=0) eshoot(o)
			end
			-- 3. maybe a loop in the
			-- lower two thirds
			if o.ph=="down" and o.loop and o.y>48 and o.x>40 and o.x<88 then
				o.ph,o.loop="loop",false
				-- turns per frame for radius
				o.curve=rnd({-1,1})*o.v/(6.28*loop_r)
				o.lp=1
			elseif o.ph=="loop" then
				o.lp-=abs(o.curve)
				-- full circle: dive on
				if (o.lp<=0) o.ph,o.curve="down",0
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
		local n=abs(dx)+abs(dy)
		-- turn towards the slot, close
		-- to it: towards the formation
		-- pose (up, like the anim image)
		local d=((n<12 and 0.25 or atan2(dx,dy))-o.a+0.5)%1-0.5
		o.a+=mid(-back_turn,d,back_turn)
		-- close: glide into the slot
		-- (turn circle is ~10 px)
		if n<12 then
			o.v=0
			o.x+=dx*0.15
			o.y+=dy*0.15
			o.a+=mid(-0.04,d,0.04)
		end
		if n<1 then
			o.st,o.mode="form","anim"
		end
	end
end

-- is the ship hit by an enemy
-- bullet or acid?
function ship_hit()
	local cx,cy=p.x+4,p.y+4
	for q in all(eb) do
		if abs(q.x-1-cx)<ship_r+1 and abs(q.y-cy)<ship_r+1 then
			del(eb,q)
			return true
		end
	end
	for k in all(pb) do
		if abs(k.x-cx)<ship_r+2 and abs(k.y-cy)<ship_r+2 then
			del(pb,k)
			return true
		end
	end
	-- touching an enemy does
	-- nothing (like the original)
	return false
end

-- ship explodes, one life less
function die()
	p.lives-=1
	-- lose one weapon tier
	p.w=max(1,p.w-1)
	boom({x=p.x+4,y=p.y+4,an={},k="ship"})
	p.dead=dead_time
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
		if (en.st) form_move(en)
		obj_update(en)
	end
	-- small ones first, big ones
	-- on top of them
	for en in all(e) do
		if (not eshot[en.k]) obj_draw(en)
	end
	for en in all(e) do
		if (eshot[en.k]) obj_draw(en)
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
	spr(21,112,-1)
	print(p.lives,120,1,7)
end

-- a new ship from the start
-- values ship0
function new_ship()
	local o={x=60,y=118,dead=0,inv=0}
	for k,v in pairs(ship0) do o[k]=v end
	o.ammo=o.shots
	return o
end

-- one more charge in the battery
function more_shots()
	p.shots=min(p.shots+1,shots_max)
end

-- weapon extra: a new weapon is
-- installed (even a weaker one),
-- the same one again gives one
-- more charge in the battery
function weapon(w)
	if p.w==w then
		more_shots()
	else
		p.w=w
	end
end

-- maybe drop an extra at x,y:
-- first the chance for any, then
-- which one by its weight
function drop(x,y)
	if (rnd()>=drop_chance) return
	local sum=0
	for k,x2 in pairs(extra) do sum+=x2.wt end
	local r=rnd(sum)
	for k,x2 in pairs(extra) do
		r-=x2.wt
		if r<0 then
			add(it,{x=x,y=y,e=x2})
			return
		end
	end
end

-- extras fall down, the ship
-- collects them
function items()
	for q in all(it) do
		q.y+=item_spd
		spr(q.e.s,q.x-4,q.y-4)
		if p.dead==0 and abs(q.x-p.x-4)<7 and abs(q.y-p.y-4)<7 then
			q.e.fn()
			del(it,q)
		elseif q.y>132 then
			del(it,q)
		end
	end
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
				if (en.bonus) lev.hits+=1
				drop(en.x,en.y)
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

-->8
-- ====== levels ======
-- levels in the map: "dg" and
-- format version 3, then per
-- level: len (0=end of list),
-- type (0 normal,1 bonus,2 kami),
-- text length, text chars, cols,
-- rows, col and row spacing px,
-- per slot: kind+16*stream,
-- streams, per stream: delay/4,
-- gap, speed*16, kind+count (only
-- bonus), segments, points x+64,
-- y+64 (start + 3 per segment)

-- type 2 (kamikaze): kind, waves
-- read level n (after the last:
-- start again with level 1)
function load_level(n)
	local a=0x2003
	for i=2,n do
		a+=peek(a)
		if (peek(a)==0) a=0x2003
	end
	local function rd()
		a+=1
		return peek(a)
	end
	local ty=rd()
	-- free text for the announcement
	local tx=""
	for i=1,rd() do tx..=chr(rd()) end
	-- kamikaze: kind and waves,
	-- the rest is fixed (settings)
	if ty==2 then
		local l={kami=true,q={},t=0,hits=0,done=0,k=kinds[rd()],text=tx}
		-- one entry per wave: center x,
		-- from left to right
		local w,m=rd(),(kami_n-1)/2*kami_dx+12
		for i=0,w-1 do
			add(l.q,{x=m+i*(128-2*m)/max(1,w-1)})
		end
		l.n=w*kami_n
		return l
	end
	local l={bonus=ty==1,c=rd(),r=rd(),
		dx=rd(),dy=rd(),rc={},text=tx,
		slots={},q={},t=0,hits=0,n=0,done=0}
	-- each row centered on its own
	-- first..last used slot
	local lo,hi=99,-99
	for row=0,l.r-1 do
		local a0,a1=99,-99
		for col=0,l.c-1 do
			local v=rd()
			if v%16>0 then
				add(l.slots,{col=col,row=row,k=kinds[v%16],st=v\16})
				a0,a1=min(a0,col),max(a1,col)
			end
		end
		l.rc[row]=(a0+a1)/2
		lo,hi=min(lo,a0-l.rc[row]),max(hi,a1-l.rc[row])
	end
	-- sway: less if the formation
	-- is wide (keep it on screen)
	l.sway=mid(0,(120-(hi-lo)*l.dx)/2,form_sway)
	for si=1,rd() do
		local st={delay=rd()*4,gap=rd(),v=rd()/16,
			k=kinds[rd()],n=rd(),m=rd(),pts={}}
		for i=0,3*st.m do
			add(st.pts,{rd()-64,rd()-64})
		end
		-- who flies this stream, when
		local j=0
		if l.bonus then
			for i=1,st.n do
				add(l.q,{t=st.delay+j*st.gap,st=st,k=st.k})
				j+=1
			end
		else
			for sl in all(l.slots) do
				if sl.st==si then
					add(l.q,{t=st.delay+j*st.gap,st=st,k=sl.k,sl=sl})
					j+=1
				end
			end
		end
	end
	l.n=#l.q
	return l
end

function start_level()
	stage+=1
	lev=load_level(stage)
	e,pb,eb,it={},{},{},{}
	dive_cool=dive_every
	wave_n=0
end

-- launch the enemies whose time
-- has come, at the path start
function spawn()
	lev.t+=1
	if (lev.kami) return kami_wave()
	for q in all(lev.q) do
		if lev.t>=q.t then
			local pt0=q.st.pts[1]
			local o=obj_new(q.k,pt0[1],pt0[2],
				rot[q.k] and "dir" or "anim")
			o.st,o.path,o.seg,o.u="enter",q.st,0,0
			o.cool=rnd(enter_cool)+10
			if q.sl then
				o.col,o.row=q.sl.col,q.sl.row
			else
				o.bonus=true
			end
			add(e,o)
			del(lev.q,q)
		end
	end
end

-- point and direction on bezier
-- segment i (0..) at u (0..1)
function bez(q,i,u)
	local a,b,c,d=q[3*i+1],q[3*i+2],q[3*i+3],q[3*i+4]
	local v=1-u
	local function f(k)
		return v*v*v*a[k]+3*v*v*u*b[k]+3*v*u*u*c[k]+u*u*u*d[k],
			3*v*v*(b[k]-a[k])+6*v*u*(c[k]-b[k])+3*u*u*(d[k]-c[k])
	end
	local x,dx=f(1)
	local y,dy=f(2)
	return x,y,dx,dy
end

-- follow the path at constant
-- speed. end: fly home (back),
-- bonus enemies just leave
function fly_path(o)
	local x,y,dx,dy=bez(o.path.pts,o.seg,o.u)
	o.x,o.y=x,y
	if (dx!=0 or dy!=0) o.a=atan2(dx,dy)
	-- length of the derivative,
	-- approx. (no overflow)
	local ax,ay=abs(dx),abs(dy)
	o.u+=o.path.v/max(1,max(ax,ay)+min(ax,ay)/2)
	if o.u>=1 then
		o.u-=1
		o.seg+=1
		if o.seg>=o.path.m then
			if eshot[o.k] then
				-- big ones roam
				o.st,o.v,o.ta,o.rt="roam",roam_spd,o.a,0
			elseif o.col then
				o.st,o.v="back",back_spd
			else
				del(e,o)
			end
		end
	end
end

-- big enemy wanders in the upper
-- half: new heading now and then,
-- sometimes a dash, shoots
function roam(o)
	o.rt-=1
	if o.rt<=0 then
		o.rt=60+rnd(90)
		if rnd()<dash_chance then
			o.v,o.dash=roam_dash,20+rnd(20)
		else
			o.ta=rnd()
		end
	end
	-- dash over: slow again
	if o.dash then
		o.dash-=1
		if (o.dash<=0) o.dash,o.v=nil,roam_spd
	end
	-- leaving the area: stop a dash,
	-- turn back to the middle, faster
	local tr=roam_turn
	if o.x<12 or o.x>116 or o.y<10 or o.y>roam_bottom then
		o.ta=atan2(64-o.x,34-o.y)
		o.dash,o.v,tr=nil,roam_spd,roam_turn*3
	end
	local d=(o.ta-o.a+0.5)%1-0.5
	o.a+=mid(-tr,d,tr)
	o.cool-=1
	if o.cool<=0 then
		big_shot(o)
		o.cool=40+rnd(60)
	end
end

-- kamikaze: next wave when the
-- last one is gone (shot or out),
-- after a pause
function kami_wave()
	if #e>0 or #lev.q==0 then
		lev.wait=nil
		return
	end
	lev.wait=lev.wait or lev.t+(#lev.q*kami_n==lev.n and kami_wait or kami_gap)
	if (lev.t<lev.wait) return
	local q=deli(lev.q,1)
	for j=0,kami_n-1 do
		local m=j-(kami_n-1)/2
		local o=obj_new(lev.k,q.x+m*kami_dx,-8-j*kami_dy,
			rot[lev.k] and "dir" or "anim")
		o.st,o.vx,o.vy,o.bonus="kami",m*kami_fan,kami_spd,true
		o.cool=rnd(kami_cool)
		add(e,o)
	end
end

-- kamikaze: dive, fanning out a
-- little, brake at the bottom and
-- fly back up. shoots a lot
function kami_move(o)
	if (o.y>=kami_low) o.up=true
	if o.up then
		o.vy=max(o.vy-kami_brake,-kami_spd)
		o.vx*=0.95
	end
	o.x+=o.vx
	o.y+=o.vy
	o.a=atan2(o.vx,o.vy)
	o.cool-=1
	if o.cool<=0 and o.y<p.y-8 then
		add(eb,{x=o.x,y=o.y+4,dx=0,dy=eshot_spd})
		o.cool=kami_cool+rnd(kami_cool)
	end
	-- out at the top: gone
	if (o.up and o.y<-12) del(e,o)
end

-- debug keys (devkit, pc only):
-- k one level back, l one on,
-- w next weapon
function dbg_input()
	while dbg_keys and stat(30) do
		local k=stat(31)
		if k=="k" or k=="l" then
			-- start_level counts up
			if (k=="k") stage=max(0,stage-2)
			start_level()
			dbg_t=90
		end
		-- w: next weapon
		if (k=="w") p.w=p.w%#wpn+1
	end
end

-- screen between levels
-- announcement of the next level:
-- stage, its text, bonus blinks,
-- hits of the last bonus level
function between()
	cls(0)
	stars()
	local function mid_print(t,y,c)
		print(t,64-#t*2,y,c)
	end
	mid_print("stage "..stage,34,10)
	mid_print(lev.text,44,7)
	if (lev.bonus and t()%0.5<0.35) mid_print("bonus stage",54,10)
	if (last) mid_print("hits "..last.hits.." of "..last.n,70,11)
	mid_print("score "..score,84,7)
	mid_print("hi "..hiscore,94,6)
	bt-=1
	if bt<=0 then
		last=nil
		_update60=game
	end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000005755750000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000560000000000000000000000575557555500000000000000000000000000000000000
000b0000000600000000000000000000000700000700006000070000056556500000555000000000005755755557610000000000000000000000000000000000
00090000000600000000000000000000000a00000b0000b0000c0000555555650005655655000000055555555575565000000000000000000000000000000000
00000000000000000000000000000000000900000300003000010000565565550005565555500000075557665565511000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000051165600066555666665000555575556551151500000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000111000065555555555550755755555155551500000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000656665565656550557655655655555500000000000000000000000000000000
00000000000000000005500000055000000550000000000000000000000000000555555555155150755655555155115100000000000000000000000000000000
bbbbbbbbbbbbbbbb0006600000066000000660000000000000000000000000005655551555555555555515551555555500000000000000000000000000000000
00000000000000000006600000066000000660000000600000000000000000005555551555655155575551115555511100000000000000000000000000000000
0bbbbbbbbbbbbbb00006600000566500000660000005650000000000000000005551515561151110055755555551555000000000000000000000000000000000
00000000000000000c0660c0c066660c0c0660c00006d60000000000000000000055155155111000055555555551115000000000000000000000000000000000
00bbbbbbbbbbbb000667d6606667d6660667d6600066d66000000000000000000000111111100000005555555555550000000000000000000000000000000000
0000000000000000056ddc70566dd66107cdd6500006660000000000000000000000000000000000000555555151500000000000000000000000000000000000
000bbbbbbbbbb0000006600000666600000660000000000000000000000000000000000000000000000005515150000000000000000000000000000000000000
0000000000000000077fff00077fff00077fff00077fff00077fff00077fff00077fff0006dddd00077fff00077fff0000000000000000000000000000000000
0000bbbbbbbb000077aaa8f0778aa8f177bbb8f1778888f1778888f1778888f1788888f16cccccd1778888f1778888f100000000000000000000000000000000
000000000000000078a8a8f078a888f17b888bf1788788f1787878f1788c88f17bbbbbf1d98c89d1788888f1788888f100000000000000000000000000000000
00000bbbbbb00000f8aa8890f8aaa891fb878b91f88a8891f8b8b891fc8c8c91f3333391d88888d1f8888891f888889100000000000000000000000000000000
0000000000000000f8a8a890f888a891fb888b91f8898891f8383891f8c8c891f8bbb891dc888c51f8888891f888889100000000000000000000000000000000
000000bbbb000000f8aaa990f8aa8991f8bbb991f8888991f8888991f88c8991f8838991dcc8cc51f8888991f888899100000000000000000000000000000000
00000000000000000ff999000ff999110ff999110ff999110ff999110ff999110ff999110ddd55110ff999110ff9991100000000000000000000000000000000
0000000bb00000000000000001111110011111100111111001111110011111100111111001111110011111100111111000000000000000000000000000000000
0000000000000060000000000000000000000000000000000000000000dddd0000000000000000000000000000bbbb0000000000000000000000000000000000
000000000000060000060000000000000000000000bbb000000000000dddddd000dddd0000000000000000000bbbbbb000bbbb00000000000000000000000000
0005000000556000000600000007b0000007e0000b7bbb0000161000dddddddd0dddddd000dddd0000000000bbbbbbbb0bbbbbb000bbbb000000000000000000
07a66660000650000056500000bbb30000eee8000bbbb30000666000dddddddddddddddd1dddddd111111111bbbbbbbbbbbbbbbb3bbbbbb33333333300000000
00050000008050000009000000bb330000ee88000bb3330000161000dddddddd1dddddd101dddd1000000000bbbbbbbb3bbbbbb303bbbb300000000000000000
0000000007000000000a0000000330000008800000333000000000001dddddd101dddd1000111100000000003bbbbbb303bbbb30003333000000000000000000
0000000000000000000000000000000000000000000000000000000001dddd1000111100000000000000000003bbbb3000333300000000000000000000000000
00000000000000000000000000000000000000000000000000000000001111000000000000000000000000000033330000000000000000000000000000000000
00000000000000000000000000000900000009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000090909090909090900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000a0a00090a0a00090a0a09000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000770000a7770000a7879000000090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000007aa0009088a0009000a00000009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000700000aa7aa000aa70a000a000a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000a0000090a9000090a909009000900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888880008888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888088888800088880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888882888888222222222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888288888820288882000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
28888882028888200022220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02888820002222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000060c0000000000000000000000000000000000000000000000008e800000000000006e6000000000000000000000000000000000000000
06c3c60060c3c060006d828006666660000222066022200000022206602220000000087878000000000006787600000000000000000000000000000000000000
061816006d181d6006d8892c00dddd0000227e2662e722000022ee2662ee22000b00008280000b00000000626000000000000000000000000000000000000000
068986006d898d606d889880008881c0002eee2222eee200002ee72222ee7200b3b000222000b3b000b000222000b00000000000000000000000000000000000
068986006d898d60008988d608999830002ee226622ee200002ee226622ee200b33b0222220b33b00b3b0222220b3b0000000000000000000000000000000000
068986006d898d6000888d60008881c000022282282220000002228228222000b3b3beeeeeb3b3b00b33beeeeeb33b0000000000000000000000000000000000
06080600600800600000d60000dddd000000cc8888cc00000000cc8888cc0000b3b3b77727b3b3b00b33b77727b33b0000000000000000000000000000000000
0000000000000000000060000666666000cccc9889cccc000000cc9889cc0000b3b3b22222b3b3b00b33b22222b33b0000000000000000000000000000000000
0000000000000000000b0000bbbb330000c6cc8998cc6c000006cc89986cc000b3b3beeeeeb3b3b00b33beeeeeb33b0000000000000000000000000000000000
030003003000003000b30000033330000ccccc8888ccccc0000ccc8888cc6000b3b302777203b3b00b33027772033b0000000000000000000000000000000000
03080b0033080bb00b358000003500000ccccc9889ccccc0000ccc9889ccc000b3300222220033b00b30022222003b0000000000000000000000000000000000
0b3eb300b33eb330335eb33003ee80000c6c6c8998c6c6c000cc6c8998c6cc0033000eee2e0003300b300eee2e003b0000000000000000000000000000000000
0b5e3300b35e333000e5b30000530000cccccc8888cccccc00cccc8888cccc003000022772000030033002277200330000000000000000000000000000000000
0b000300b300053000053000033bb000ccc6c098890c6ccc006ccc9889cc6c000000002220000000030000222000030000000000000000000000000000000000
03000300300000300003000033333300c6ccc089980ccc6c000cc68998ccc0000000002220000000000000222000000000000000000000000000000000000000
000000000000000000000000000000000ccc00088000ccc000000008800000000000000200000000000000020000000000000000000000000000000000000000
0080080000800800000b000000000000000000000000000000005000000600000000000000000000000000000000000000000000000000000000000000000000
0b0880000b0880b00b0108000b0b00b00060009d690006000006009d690060000000000000000000000000000000000000000000000000000000000000000000
0b111cb000111c000011188000cccc08006009899890600000060989989060000000015666600000000001566660000000000000000000000000000000000000
0011ccb00b11cc00b1111c000111c1800006069669d660000006069669d6600000000ccecec0000000000c8cc8c0000000000000000000000000000000000000
001c1c00001c1cb000111c1b01cc11800000666666d600000000666666d600000011156767666100001115676766610000000000000000000000000000000000
0b1c1cb0001c1c00011cc100001111080000336dddb300000000336dddb300000155665677666660015566567766666000000000000000000000000000000000
000110000b0110b0001010b00b00b0b0000bebbeebeb3000000bebbeebebe0001515557666666666151555766666666600000000000000000000000000000000
00000000000000000000b0000000000000be3eec1ee3eb0000ebe3e1e3e3ee001565566677666666156556667766666600000000000000000000000000000000
0000000000000000000000000000000000ee3ee1cee3ee0000eee3ee1ebe3e00e8e8e8e8e8e8e8e88e8e8e8e8e8e8e8e00000000000000000000000000000000
000000000000000000500000000b000000ebeeecceeebe0000ee3eeece3eee000555556555565550055555655556555000000000000000000000000000000000
000cc000000cc0000d66cc0000d6600000eeeec111eeee0000eeeee1eeeeee000056565555555650005656555555565000000000000000000000000000000000
006666000066660000db6c0000db6c0000eeee11cceeee0000eeeeeceeeeee0000cccc55555cccc000c7cc55555cccc000000000000000000000000000000000
0b6b6b6006b6b6b0000d660000d66c0000eeeecc11eeee0000eeeeee1eeeee00000c703bbb30c700000cc02888207c0000000000000000000000000000000000
00dddd0000dddd000000db5000db6000000eee111ceee000000eeee1eeeee000000000337b300000000000227820000000000000000000000000000000000000
000000000000000000000d00000600000000eccc11ce00000000eeec1eee00000000000b3b000000000000082800000000000000000000000000000000000000
00000000000000000000000000000000000000011000000000000001100000000000000000000000000000000000000000000000000000000000000000000000
__label__
000000000000000000000000000000000000000000000000000000000000000000e5b30000000000000000000000000000000000500000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000335eb33000000000000000000000000000000000000000000060007070777000
00000000000000000000000000000000000000000000000000000000000000000b35800000000000000000000000000000000000000000000565007070007000
000000000000000000000000000000000000000000000000000000000000000000b30000000000000000000000000000000000000000000006d6000700077000
0000000l00000000000000000000000000060000000000000000000000000000000b0000000000000000000000000000000000000000000066d6607070007000
00000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000666007070777000
00000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000l0000000000000000000000000000
00000000000000000000000000000000608060000000000000006080600000000000000060806000000000000006008006000000000000060080060000000000
00000000000000000000l00000000000689860000000000000006898600000000000000068986000000000000006d898d600000000000006d898d60000000000
00000000000000000000000000000000689860000000000000006898600000000000000068986000000000000006d898d600000000000006d898d60000000000
00000000000000000000000000000000689860000000000000006898600000000000000068986000000000000006d898d600000000000006d898d60000000000
00000000000000000000000000000000618160000000000000006181600000000000000061816000000000000006d181d600000000000006d181d60000000000
000000000000000000000000000000506c3c60000000000000006c3c60000000000000006c3c60000000000000060c3c06000000000000060c3c060000000000
00000000000000000500000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000060009d69000600000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000l0000000000060098998906000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000006069669d66000000000000000000000000000000l00000000000000000000
0000000000000000000000000000000300000300000000000000000000000000l000666666d60300000000000000300030000000000000000000000000000000
000000000000000000000000000000033080bb000000000000000000000000000000336dddb3bb000000000000003080b0000000000000000000000000000000
0000000000000000000000000000000b33eb3300000000000000000000000000000bebbeebeb3300000000000000b3eb30000000000000000000000000000000
0000000000000000000000000000000b35e3330000000000000000000000000000be3eec1ee3eb00000000000000b5e330000000000000000000000000000000
0000000000000000000000000000000b3000530000000000000000000000000000ee3ee1cee3ee00000000000000b00030000000000000000000000000000000
000000000000000000000000000000030000030000000000000000000000000000ebeeecceeebe00000000000000300030000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000eeeec111eeee00000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000eeee11cceeee00000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000eeeecc11eeee00000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000eee111ceee00000000000000l000050000000000000000000000000000000
00000000000000000000000000000000600000000000000000000000000000000000eccb11ce0000000000000000000000000000000000000000000000050000
00000000000000000000000000000000000000000000000000000000000000000000000b7b000000000000000000000000000000000000000000000000005000
00000000000000000000000000000000b0110b000000000000000011000000000000000bbb310000000000000000b0110b00000000000000b0110b0000000000
0000000000000000000000000000000001c1c000050000000000b1c1cb0000000000000bb331cb0000000000000001c1c00000000000006001c1c00000000000
0000000000006000000000000000000001c1cb0000000000000001c1c00000000000000033c1c00000000000000501c1cb0000000000000001c1cb0000000000
00000000000000000000000000000000b11ccl00000000000000011ccb00000000000000011ccb00000000000000b11cc000000000000000b11cc00000000000
000000000000000000000000000000000111c000000000000000b111cb00000000000000b111cb000000000000000111c0000000000000000111c00000000000
00000000000000000000000000000000b0880b00000000000000b0880000000000000000b0880000000000000000b0880b00000000500000b0880b0000000000
00000000000000000000000000000000080080000000000000000800805000000000000008008000000000000000080080000000000000000800800000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000050000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000l000000000000000000000000500000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000500000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000500000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000050l0000000000000000000000000000000000500000000000000000000000000000000000000000000000000000005000000l000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000l000
00000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000l0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000500000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000005000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000l000000000000000000000l0000000000000000000000000000000000000000000000000000000000000000000000030000000000000000000000000
00000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000050000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000l00000
00000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000300000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b00000000000000000000000000
000000000000000000000000000000000000000l0000000006000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b00b000000000000000000000000
00000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0000000000000000000500000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000007b000000000000000000000000
00000000000000000000050000000000000000000000000000000000000000000000000000000050000000000000000000000bbb300000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000050000000000000000000000000l000000bb3300000000000000000000000
0000000000000000000000000000000500000000000000000000000000000000000000000000000b000000000000000000000033000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000050000000000b3000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000b35800000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000335eb33000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000l00000000000e5b30000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000005300000000000000000000000000000000000000000000000
00000000000000000000000000000050000000000000000000000000000000000000000000000003000000000000000000000000000000000000060000000000
000000000000000000000000000000000000000l0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000005
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000l000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000060l00000000000000000000000000000000000000000000000000000000000000000006000l000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000500000000l00000000000000000000
00000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000055000000000000000000005000000500000000000000000000000000000
000000000000000000000000000000000000000000000000000500000000000000000660000000000000000000000000000000l0000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000006600000000000000000000000000000000000000000000000l000000000
000000000l0000000500000000000000000000000000000000000000000000000000066000000000000000000000l00000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000c0660c0050000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000667d660000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000056ddc70000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000066000000000000000000000000000000000000000000000000000000000
00000000000000000050000000000000000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__map__
4447035a00126475636b20746f20746865207369646573210c03090b120012001200002200220022001200120012220022002200120012001200002200220022020008180000015438548a62a37475000818000001ad38ad8a9ba389756f000f6c6f6f6b20696e206d7920657965730c040a0c12121212000000002222222212
00001200122200220000221200001200000000220000220012120000000000002222000200071a00000264326566618e72897d867b7b7c6a00071a0000029b329a669e8e8d898286847b836a6a000862696720626f73730504150c1222113242122200324212220032421222543242050008180108015736574c576c58840008
18010801a836a84ca86ca7840008180108016a396a4f6a796b8e0008180108019539954f9579948e080818010801812b75388b557d6e17021266726f6d206c65667420746f20726967687402058300037570210e0408080000001100000000000021000000000011001100000000210021000000110011001100002100210021
0011000011000011210000210000210200081801080464384c64659f797a82664e5f628c70aa49ad4b9948884464565c0008180108049b38b364989b867a7d66b15f9d8c8faab6adb499b788bb64a95c63000009030c0c1111111100212121211111111100212121210011110000002121000200081801080471327132713271
557182719071a471b851bf529f52897e798f700008180108048e328e328e328e558e828e908ea48eb8aebfad9fad89817970704f0016697473206120747261702e206120666c79747261702e05030e0c111111000011111100271111110000020008180108026834516661967c919e8b926b855d0a081801080198349872b69a
807240000006030e0c151515151515151515151515151515151515010008180108053b364e504c927c9b9fa4af83a26d94546a616a756a897d918a8c97879c71836a54000008030c0a1515151525252525151515152525252515151515252525250200081801080336974f8b646b8470a27b98a77aa561a35779787000081801
0803c997b08b9b6b7b705d7b67a785a59ea3a8798770a0000008030b0a151525254545353515152525454535351515252545453535040008180108044ec64ead4e9e4e884e7269726986699a4e994f894f7a586e5d6a0008180108047cc67cad7c9e7c887c7261726186619a7c997b897b7a726e6d6a000818010804b5c5b5ac
b59db587b5719a719a859a99b598b488b479ab6da66900081801080486c686ad869e86888672a172a186a19a86998789877a906e956a8c00000c04090a1515153535352525254545451515153535352525254545451515153535352525254545450000000000566600000000000600081801080158c658b55895588700081801
08018ec68eb58e958e8700081801080171c671b571957187000818010801a7c6a7b5a795a7870f0818010801a72e9c418a3f84580f08180108015b2e60374456696330010000000e0c02000818050a027f2d7e54456966838097baadbad2000818050a02802d8154ba6999837f9745ad45d23c000008030b0c12121212222222
2212121212222222221212121222222222020008180000017034708646a058720a08180000018f348f86b9a0a77200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

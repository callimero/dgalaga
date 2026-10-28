pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
-- todo
	-- attacks
	-- meteor storm
 	
-- gameplay tuning: put settings here to try
-- them out. runs first in _init and
-- overrides the values further down
function tune()
	dbg_start = 1 --startlevel

--testing
--	dbg_keys=true -- debug, pc only:
               -- k/l level chose, w weapon,
               -- j drops dbg_extra,
               -- p pause
--	ship0.money=1000
--	dbg_extra="scoop"

	
-- implementieren!	
--	reload_time = 20

end

-- settings
-- ship at the start of a game (the
-- current values are in p, see
-- new_ship). w: weapon 1-3,
-- shots: battery size (charges)
ship0={spd=0.8,lives=3,w=1,shots=3,armor=0}
spd_step=0.2    -- speed extra
spd_max=2
spd_min=0.6     -- less speed (shop)
auto_rate=6     -- frames between
                -- shots with auto fire
shots_max=20    -- battery max
                -- (bullet extras)
-- scoop: an energy funnel from the
-- ship's nose sucks small aliens in,
-- two dock left/right and fire with
-- the ship (they take hits for it
-- until the level ends), more ones
-- spin out of the screen (= shot)
scoop_time=600  -- frames
scoop_h=16      -- px high (a line
                -- every 2 px)
scoop_pull=1.5  -- px/frame to dock
mate_dx=10      -- px left/right
shield_time=600 -- frames of a
                -- shield extra
armor_max=4     -- armor: each one
                -- takes one hit
armor_inv=60    -- frames blinking
                -- after armor took
                -- a hit
mult_time=1800  -- frames of points
                -- x2 / x5
                -- (shield = blinking,
                -- cannot be hit)

-- extras: n = on average every
-- n-th shot down alien drops it
-- (0 = never). each extra rolls on
-- its own, if several hit one of
-- them falls. fn: what it does
item_spd=0.6    -- px/frame falling
extra={
	bullet={s=34,n=80,  fn=function() more_shots() end},
	speed= {s=35,n=130, fn=function() p.spd=min(p.spd+spd_step,spd_max) end},
	shield={s=36,n=220, fn=function() p.inv=max(p.inv,shield_time) end},
	single={s=37,n=330, fn=function() weapon(1) end},
	double={s=38,n=330, fn=function() weapon(2) end},
	triple={s=39,n=670, fn=function() weapon(3) end},
	scoop= {s=40,n=110, fn=function() p.scoop_t=scoop_time end},
	life=  {s=41,n=670, fn=function() p.lives+=1 end},
	auto=  {s=42,n=170, fn=function() p.auto=true end},
	armor= {s=43,n=130, fn=function() more_armor() end},
	x2=    {s=44,n=330, fn=function() set_mult(2) end},
	x5=    {s=45,n=170, fn=function() set_mult(5) end},
	-- skulls: weaker ship, three in a
	-- row trigger something
	skullr={s=56,n=80,  fn=function() skull("r") end},
	skullb={s=57,n=80,  fn=function() skull("b") end},
	skullg={s=58,n=80,  fn=function() skull("g") end},
}
it={} -- falling extras and coins

-- coins: first sprite (top view,
-- 4 images to the side view) and
-- value. a dying alien drops one
-- with coin_chance, which one: the
-- higher the value, the rarer
coin_chance=0.05 -- test, lower later
coin_spd=8      -- frames per image
coins={
	{n=80,v=10},   -- silver
	{n=96,v=50},   -- gold
	{n=112,v=100}, -- u238
	{n=84,v=200},  -- anti
	{n=100,v=500}, -- red
}
-- shop: name, price, what it does.
-- shown sorted by price, dearest
-- on top
shop_items={
	{"extra speed",50,function() p.spd=min(p.spd+spd_step,spd_max) end},
	{"extra bullet",75,function() more_shots() end},
	{"double shot",100,function() weapon(2) end},
	{"less speed",150,function() p.spd=max(p.spd-spd_step,spd_min) end},
	{"triple shot",200,function() weapon(3) end},
	{"auto fire",250,function() p.auto=true end},
	{"extra life",400,function() p.lives+=1 end},
	{"armour",600,function() more_armor() end},
}
shop_lock=30    -- frames no buying
                -- after entering
shop_cool=24    -- frames between
                -- two purchases

-- spin: image offset, flipped?
coin_fr={{0},{1},{2},{3},{2,true},{1,true}}
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
reload_time=20 -- frames per charge
shot_spd=3     -- px/frame
pb={} -- projectiles of big enemies
-- per big kind: sprite, speed,
-- aimed at the ship?, trail
-- colors (bright,dark; nil=none)
eshot={
	bugm={s=51,v=1,aim=true,c1=11,c2=3},
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
kinds={"red","green","blue","bugm","ufo","mother","flym","greenm","fly","bug"}
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
kami_dx=2       -- px side by side
kami_dy=2       -- px higher each
                -- (slanted line)
kami_spd=1.5    -- px/frame
kami_low=85     -- y where they brake
                -- (turn ~25 px lower)
kami_brake=0.05 -- slow down/frame
kami_fan=0.08   -- sideways spread
kami_edge=24    -- px from the screen
                -- edge to the outer
                -- alien at the start
                -- (fanning out needs
                -- room)
kami_cool=20    -- frames between
                -- shots (+random)
warp_time=240   -- frames of the warp
                -- before a shop
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
-- per shot, {sprite,dx,hit width,
-- damage}. hit width: half width
-- of the shot (double: two shots in
-- one sprite, so wider). damage:
-- hit points it takes away
wpn={
	{{4,0,1,1}},                          -- single
	{{5,0,3,2}},                          -- double
	{{6,-0.6,1,1.2},{6,0,1,1.2},{6,0.6,1,1.2}}, -- triple
}

-- hit points and score per kind
hp={red=2,green=1,blue=2,bugm=12,ufo=3,mother=12,flym=10,greenm=12,fly=2,bug=4}
worth={red=150,green=40,blue=130,bugm=200,ufo=300,mother=500,flym=300,greenm=300,fly=60,bug=100}
flash_time=4    -- frames white
                -- after a hit
-- explosion: sprites 64-68,
-- frames per image
boom_spd=3
-- explosion particles (z: size of
-- the alien, 1 small, 2 big)
spark_n=12      -- sparks per z
spark_v=0.6     -- speed 0.3+rnd(v*z)
spark_life=20   -- frames (+rnd 10)
ball_n=8        -- big ones: balls in
ball_r=2        -- their colors,
                -- radius r+rnd(r)
ball_v=0.4      -- speed 0.2+rnd(v)
ball_life=50    -- frames (+rnd 10)
debris_n=16     -- grey debris
debris_v=0.5    -- speed 0.3+rnd(v)
-- particle colors per kind
-- {bright,dark}
col={ship={7,12},red={8,2},green={11,3},
	blue={12,1},bugm={14,2},
	ufo={6,13},mother={6,8},
	flym={12,8},greenm={11,3},
	fly={12,8},
	bug={14,2}}
fx={} -- running explosions

-- animations by time: per frame
-- {sprite,flip_x,flip_y,frames}
anim={
	green={{144,false,false,20},{145,false,false,20}},
	red={{128,false,false,20},{129,false,false,20}},
	blue={{160,false,false,20},{161,false,false,20}},
	-- sz=2: sprite is 2x2
	bugm={{164,false,false,12},{166,false,false,12},sz=2},
	ufo={{176,false,false,20},{177,false,false,20}},
	mother={{168,false,false,16},{170,false,false,16},sz=2},
	flym={{132,false,false,10},{134,false,false,10},sz=2},
	greenm={{136,false,false,14},{138,false,false,14},sz=2},
	fly={{140,false,false,8},{141,false,false,8}},
	bug={{156,false,false,16},{157,false,false,16}},
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
	-- score/hiscore are stored >>16
	-- (pico-8 numbers end at 32767):
	-- add points with pts(), show them
	-- with tostr(score,2). hiscore is
	-- saved with cartdata
	cartdata("callimero_dgalaga")
	score=0
	hiscore=dget(0)
	p=new_ship()
	reload=0
	-- stars init
	for i=1,ns do
		add(s,{x=rnd(128),y=rnd(128),z=rnd(10)+2})		
	end
	-- rotation: 8 directions per kind
	rot={green=rot_tab(144),
		red=rot_tab(128),blue=rot_tab(160),
		ufo=rot_tab(176),fly=rot_tab(140),
		bug=rot_tab(156)}
	stage=dbg_start-1
	-- devkit: keyboard for debug keys
	if (dbg_keys) poke(0x5f2d,1)
	dbg_t=0
	start_level()
	_update60=title
end

-- both buttons fire (keyboard
-- layouts, pads, handhelds)
function fire()
	return btnp(🅾️) or btnp(❎)
end

function title()
	cls(0)
	stars()
	print("pico8 deluxe galaga",26,40,10)
	if (t()%1<0.7) print("press 🅾️/❎ to start",22,70,7)
	if fire() then
		next_screen()
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
	p.x=mid(-2,p.x,122)	
	-- fire: one shot per press
	-- while there is charge
	-- auto fire (shop): holding fires
	-- every auto_rate frames
	if (fire() or p.auto and (btn(4) or btn(5)) and lev.t%auto_rate==0) and p.ammo>0 then
		shoot(p.w)
		p.ammo-=1
	end
	end -- ship alive
	-- points x2/x5 run out
	if p.mult_t>0 then
		p.mult_t-=1
		if (p.mult_t==0) p.mult=1
	end
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
 scoop()
 enem()
 plasma()
 ebullets()
	bullets()
	items()
	if p.dead==0 then
		if p.inv>0 then
			p.inv-=1
		elseif ship_hit() then
			-- a docked alien takes the hit,
			-- then armor
			local m=docked()
			if m then
				sfx(6)
				boom(m)
				del(p.mt,m)
				p.inv=armor_inv
			elseif p.armor>0 then
				p.armor-=1
				p.inv=armor_inv
			else
				die()
			end
		end
		-- blink while invulnerable
		if (p.dead==0 and p.inv%8<4) spr(19+til,p.x,p.y)
	end
	hud()
	-- after a level switch: number
	if dbg_t>0 then
		dbg_t-=1
		print("stage "..stage_no(),1,1,7)
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
			save_hi()
			-- hits of a bonus/kamikaze level
			-- for the announcement
			last=(lev.bonus or lev.kami) and lev or nil
			start_level()
			next_screen()
		end
	end
end

-- game over: the money counts as
-- points (x100), once
function over()
	if not p.paid then
		p.paid=true
		-- shift first: money*100 would
		-- overflow above 327
		score+=(p.money>>16)*100
		save_hi()
	end
	cls(0)
	stars()
	print("game over",46,46,8)
	local function mid_print(t,y,c)
		print(t,64-#t*2,y,c)
	end
	mid_print("money "..p.money.." x100",58,9)
	mid_print("score "..tostr(score,2),68,7)
	mid_print("hi "..tostr(hiscore,2),78,6)
	-- restart the cart
	if (fire()) run()
end

-- add points (stored >>16)
function pts(n)
	score+=(n*p.mult)>>16
end

-- new hiscore? keep and save it
function save_hi()
	if score>hiscore then
		hiscore=score
		dset(0,hiscore)
	end
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
	sfx(1,1)
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
		local c=q.l>q.ml/2 and q.c1 or q.c2
		-- with a radius: a ball that
		-- shrinks, else one pixel
		if q.r then
			circfill(q.x,q.y,q.r*q.l/q.ml,c)
		else
			pset(q.x,q.y,c)
		end
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
		sfx(2,2)
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
			sfx(1,1)
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
	sfx(7,0)
	p.lives-=1
	-- lose one weapon tier and auto
	-- fire (armor and points x2/x5
	-- stay)
	p.w,p.auto,p.scoop_t=max(1,p.w-1),false,0
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

-- f: speed factor, blue: colors
-- of the warp (blueshift), with
-- streaks when fast
function stars(f,blue)
	f=f or 1
	for st in all(s) do
		local v=st.z/20*f
		st.y+=v
		local c=4+st.z/5
		if (blue) c=({1,13,12,7})[flr(st.z/3)+1]
		line(st.x,st.y-v*0.8,st.x,st.y,c)
		if st.y>128 then
			st.x=rnd(128)
			st.y=0
			st.z=rnd(10)+2
  end			
	end
end

-- ships left, top right
-- ships left, top right; armor as
-- light blue dots above them
function hud()
	for i=1,p.armor do
		rectfill(110+i*3,1,111+i*3,2,12)
	end
	spr(21,112,2)
	print(p.lives,120,4,7)
end

-- a new ship from the start
-- values ship0
function new_ship()
	local o={x=60,y=118,dead=0,inv=0,money=0,mult=1,mult_t=0,sk="",
		mt={},scoop_t=0}
	for k,v in pairs(ship0) do o[k]=v end
	o.ammo=o.shots
	return o
end

-- first docked alien or nil
function docked()
	for m in all(p.mt) do
		if (m.dock) return m
	end
end

-- scoop: mates follow the ship,
-- flung ones leave, the funnel
-- (a green line every 2 px, each
-- 1 px wider per side, dark green
-- ones run down: sucking) catches
-- small aliens touching it
function scoop()
	for m in all(p.mt) do
		local tx,ty=p.x+4+m.side*mate_dx,p.y+4
		if m.dock then
			m.x,m.y=tx,ty
		else
			-- tumbles to its place
			local dx,dy=tx-m.x,ty-m.y
			local d=max(abs(dx),abs(dy))
			if d<scoop_pull then
				m.dock,m.mode=true,"anim"
			else
				m.x+=dx/d*scoop_pull
				m.y+=dy/d*scoop_pull
			end
		end
		obj_update(m)
		obj_draw(m)
	end
	for o in all(fl) do
		obj_update(o)
		obj_draw(o)
		if (o.y<-12 or o.x<-12 or o.x>140) del(fl,o)
	end
	if (p.scoop_t<=0 or p.dead>0) return
	p.scoop_t-=1
	local cx,ay=p.x+4,p.y-1
	for k=0,scoop_h/2-1 do
		line(cx-1-k,ay-k*2,cx+k,ay-k*2,(k+flr(t()*15))%3==0 and 3 or 11)
	end
	for en in all(e) do
		local dy=ay-en.y
		if not eshot[en.k] and dy>=0 and dy<=scoop_h+3 and abs(en.x-cx)<=dy/2+4 then
			del(e,en)
			en.v,en.curve,en.rate,en.burst=0,0,0.05,0
			en.mode="spin"
			if #p.mt<2 then
				-- dock on the free side
				en.side=-1
				for m in all(p.mt) do
					if (m.side==-1) en.side=1
				end
				add(p.mt,en)
			else
				-- full: spin out up left or
				-- right, counts as shot down
				pts(worth[en.k] or 0)
				if (en.bonus) lev.hits+=1
				en.v,en.a=2,rnd({0.125,0.375})
				add(fl,en)
			end
		end
	end
end

-- skull: one weapon tier and one
-- speed step less, color noted;
-- after three: skull_combo
function skull(c)
	p.w=max(1,p.w-1)
	p.spd=max(spd_min,p.spd-spd_step)
	p.sk..=c
	if #p.sk==3 then
		skull_combo(p.sk)
		p.sk=""
	end
end

-- three skulls in a row, e.g.
-- "rrr" or "rbg": todo (weapons,
-- warps, points, meteor storm ...)
function skull_combo(c)
end

-- one more armor (max armor_max)
function more_armor()
	p.armor=min(p.armor+1,armor_max)
end

-- points x2 / x5 for mult_time
-- frames; a higher factor wins,
-- the time starts again
function set_mult(m)
	p.mult=max(p.mult,m)
	p.mult_t=mult_time
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
-- each one with chance 1/n
-- maybe drop a coin: weight 1/value
function drop_coin(x,y)
	if (rnd()>=coin_chance) return
	local sum=0
	for c in all(coins) do sum+=1/c.v end
	local r=rnd(sum)
	for c in all(coins) do
		r-=1/c.v
		if r<0 then
			add(it,{x=x,y=y,coin=c,t=rnd(30)})
			return
		end
	end
end

function drop(x,y)
	local hit={}
	for k,x2 in pairs(extra) do
		if (x2.n>0 and rnd(x2.n)<1) add(hit,x2)
	end
	if (#hit>0) add(it,{x=x,y=y,e=rnd(hit)})
end

-- extras fall down, the ship
-- collects them
function items()
	for q in all(it) do
		q.y+=item_spd
		if q.coin then
			-- spinning coin; a flipped image
			-- moves 1 px left, so it stays
			-- in place
			q.t+=1
			local f=coin_fr[flr(q.t/coin_spd)%#coin_fr+1]
			spr(q.coin.n+f[1],q.x-4-(f[2] and 1 or 0),q.y-4,1,1,f[2])
		else
			spr(q.e.s,q.x-4,q.y-4)
		end
		if p.dead==0 and abs(q.x-p.x-4)<7 and abs(q.y-p.y-4)<7 then
			if q.coin then
				p.money+=q.coin.v
				sfx(4,3)
			else
				q.e.fn()
				sfx(3,3)
			end
			del(it,q)
		elseif q.y>132 then
			del(it,q)
		end
	end
end

-- fire weapon w: one bullet per
-- projectile, each keeps its
-- sprite and sideways speed
-- sounds: 0 ship gun, 1 alien
-- shot, 2 alien dives, 3 extra,
-- 4 money, 5 scoop (later),
-- 6 alien explodes, 7 ship explodes
-- (also: out of the warp), 8 warp
-- (loop)
function shoot(w)
	sfx(0,0)
	for m in all(p.mt) do
		if (m.dock) add(b,{x=m.x-4,y=m.y-6,s=0,dx=0,w=1,dmg=1})
	end
	for pr in all(wpn[w]) do
		add(b,{x=p.x,y=p.y-4,s=pr[1],dx=pr[2],w=pr[3],dmg=pr[4]})
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
			en.hp-=bu.dmg
			en.fl=flash_time
			if en.hp<=0 then
				pts(worth[en.k] or 0)
				if (en.bonus) lev.hits+=1
				drop(en.x,en.y)
				drop_coin(en.x+4,en.y)
				sfx(6)
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
-- the enemy's main color (no
-- change of color)
function boom(o)
	local z=o.an.sz or 1
	add(fx,{x=o.x,y=o.y,z=z,t=0})
	local c=col[o.k] or {10,8}
	for i=1,spark_n*z do
		spark(o,rnd(),0.3+rnd(spark_v*z),c[1],c[1])
	end
	-- big ones: balls in their colors
	-- and grey debris
	if z>1 then
		for i=1,ball_n do
			spark(o,rnd(),0.2+rnd(ball_v),c[1],c[1],ball_r+rnd(ball_r),ball_life)
		end
		for i=1,debris_n do
			spark(o,rnd(),0.3+rnd(debris_v),7,6)
		end
	end
end

-- one particle from o in direction
-- a with speed v, colors c1 then
-- c2, radius r (nil = a pixel),
-- life lf (nil = spark_life)
function spark(o,a,v,c1,c2,r,lf)
	lf=lf or spark_life
	add(pt,{x=o.x,y=o.y,dx=cos(a)*v,dy=sin(a)*v,
		l=lf+rnd(10),ml=lf+10,c1=c1,c2=c2,r=r})
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
-- type (0 normal,1 bonus,2 kami,
-- 3 shop),
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
	-- shop: no aliens, only the text
	if (ty==3) return {shop=true,text=tx,q={},t=0,hits=0,done=0,n=0}
	if ty==2 then
		local l={kami=true,q={},t=0,hits=0,done=0,k=kinds[rd()],text=tx}
		-- one entry per wave: center x,
		-- from left to right
		local w,m=rd(),(kami_n-1)/2*kami_dx+kami_edge
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
	e,pb,eb,it,b,fl={},{},{},{},{},{}
	-- docked aliens stay until the
	-- level ends
	p.mt={}
	-- battery full, no shield left
	-- from the last level
	p.ammo,p.inv=p.shots,0
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
		sfx(1,1)
		o.cool=kami_cool+rnd(kami_cool)
	end
	-- out at the top: gone
	if (o.up and o.y<-12) del(e,o)
end

-- debug keys (devkit, pc only):
-- k one level back, l one on,
-- w next weapon, j drop an extra,
-- p pause
function dbg_input()
	-- p is ours: no pico-8 pause menu
	-- (enter neither) in debug mode
	if (dbg_keys) poke(0x5f30,1)
	while dbg_keys and stat(30) do
		local k=stat(31)
		if k=="k" or k=="l" then
			-- start_level counts up
			if (k=="k") stage=max(0,stage-2)
			start_level()
			dbg_t=90
			if (lev.shop) shop_open()
		end
		-- p: pause (game stands still)
		if k=="p" then
			dbg_back=_update60
			_update60=dbg_pause
		end
		-- w: next weapon
		if (k=="w") p.w=p.w%#wpn+1
		-- j: drop dbg_extra (tune) in
		-- the middle
		if (k=="j") add(it,{x=64,y=-4,e=extra[dbg_extra or "scoop"]})
	end
end

-- debug pause: the last picture
-- stays, p goes on
function dbg_pause()
	poke(0x5f30,1)
	if (t()%1<0.6) print("pause",54,60,7)
	while stat(30) do
		if (stat(31)=="p") _update60=dbg_back
	end
end

-- screen between levels
-- stage number shown: shops do
-- not count (walks the level list
-- like load_level)
function stage_no()
	local a,c=0x2003,0
	for i=1,stage do
		if i>1 then
			a+=peek(a)
			if (peek(a)==0) a=0x2003
		end
		if (peek(a+1)!=3) c+=1
	end
	return c
end

-- next screen after a level: the
-- announcement, or for a shop the
-- warp (no announcement)
function next_screen()
	if lev.shop then
		wt=0
		-- warp sound loops on channel 2
		sfx(8,2)
		_update60=warp
	else
		bt=between_time
		_update60=between
	end
end

-- warp to the shop: stars get
-- faster and blue, then the shop
function warp()
	wt+=1
	cls(0)
	stars(1+wt/6,wt>20)
	if wt>=warp_time then
		-- out of the warp: loop off,
		-- exit sound
		sfx(-1,2)
		sfx(7,0)
		shop_open()
	end
end

-- ====== shop ======
-- sorted copy of the items
function shop_open()
	shop_list={}
	for it2 in all(shop_items) do add(shop_list,it2) end
	-- insertion sort by price, high
	-- first
	for i=2,#shop_list do
		local j=i
		while j>1 and shop_list[j][2]>shop_list[j-1][2] do
			shop_list[j],shop_list[j-1]=shop_list[j-1],shop_list[j]
			j-=1
		end
	end
	-- cursor starts on "exit"
	shop_sel,shop_t,shop_buy,shop_no=#shop_list+1,0,0,0
	_update60=shop
end

-- deluxe tax free shop: up/down
-- choose, fire buys (once per
-- press, locked at the start and
-- shortly after a purchase), the
-- last line leaves
function shop()
	shop_t+=1
	local n=#shop_list+1
	if (btnp(⬆️)) shop_sel=(shop_sel-2)%n+1
	if (btnp(⬇️)) shop_sel=shop_sel%n+1
	shop_buy-=1
	shop_no-=1
	if fire() and shop_t>shop_lock and shop_buy<=0 then
		if shop_sel==n then
			-- exit: next level
			start_level()
			next_screen()
			return
		end
		local it2=shop_list[shop_sel]
		if p.money>=it2[2] then
			p.money-=it2[2]
			it2[3]()
			sfx(4,3)
			shop_buy=shop_cool
		else
			shop_no=20
		end
	end
	-- draw
	cls(0)
	stars()
	-- rows of stars around the title
	for r in all({1,15}) do
		for i=0,15 do
			print("★",i*8,r,({8,9,10,11,12,14})[(i+r+flr(t()*4))%6+1])
		end
	end
	print("deluxe tax free shop",24,8,11)
	local m="you have "..p.money.." credits"
	print(m,64-#m*2,30,9)
	for i,it2 in ipairs(shop_list) do
		local y=32+i*9
		local c=(i==shop_sel) and (shop_no>0 and shop_no%6<3 and 8 or 10)
			or (p.money>=it2[2] and 11 or 3)
		local pr=tostr(it2[2])
		print(pr,40-#pr*4,y,6)
		print(it2[1],48,y,c)
	end
	print("exit the shop",38,46+#shop_list*9,shop_sel==n and 10 or 9)
end

-- announcement of the next level:
-- stage, its text, bonus blinks,
-- hits of the last bonus level
function between()
	cls(0)
	stars()
	local function mid_print(t,y,c)
		print(t,64-#t*2,y,c)
	end
	mid_print(lev.shop and "shop" or "stage "..stage_no(),34,10)
	mid_print(lev.text,44,7)
	if (lev.bonus and t()%0.5<0.35) mid_print("bonus stage",54,10)
	if (lev.kami and t()%0.5<0.35) mid_print("kamikaze!",54,8)
	if (last) mid_print("hits "..last.hits.." of "..last.n,70,11)
	mid_print("score "..tostr(score,2),84,7)
	mid_print("money "..p.money,104,9)
	mid_print("hi "..tostr(hiscore,2),94,6)
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
0000000000000000077fff00077fff00077fff00077fff00077fff00077fff00077fff0006dddd00077fff00077fff0006dddd0006dddd00077fff0000000000
0000bbbbbbbb000077aaa8f0778aa8f177bbb8f1778888f1778888f1778888f1788888f16cccccd1778788f1778888f16c776cd16c677cd1778888f100000000
000000000000000078a8a8f078a888f17b888bf1788788f1787878f1788c88f17bbbbbf1d98c89d1788888f1788588f1dccc7cd1dc7cccd1788888f100000000
00000bbbbbb00000f8aa8890f8aaa891fb878b91f88a8891f8b8b891fc8c8c91f3333391d88888d1f88c8891f8565891dcc76cd1dc677cd1f888889100000000
0000000000000000f8a8a890f888a891fb888b91f8898891f8383891f8c8c891f8bbb891dc888c51f8888891f8565891dc7ccc51dccc7c51f888889100000000
000000bbbb000000f8aaa990f8aa8991f8bbb991f8888991f8888991f88c8991f8838991dcc8cc51f8818991f8888991dc677c51dc776c51f888899100000000
00000000000000000ff999000ff999110ff999110ff999110ff999110ff999110ff999110ddd55110ff999110ff999110ddd55110ddd55110ff9991100000000
0000000bb00000000000000001111110011111100111111001111110011111100111111001111110011111100111111001111110011111100111111000000000
000000000000006000000000000000000000000000000000000000000000000006dddd5006dddd5006dddd500000000000000000000000000000000000000000
000000000000060000060000000000000000000000bbb0000000000000000000688888856cccccc5633333350000000000000000000000000000000000000000
0005000000556000000600000007b0000007e0000b7bbb000016100000000000d89fff85dc9fffc5d39fff350000000000000000000000000000000000000000
07a66660000650000056500000bbb30000eee8000bbbb3000066600000000000d80f0985dc0f09c5d30f09350000000000000000000000000000000000000000
00050000008050000009000000bb330000ee88000bb333000016100000000000d8fff985dcfff9c5d3fff9350000000000000000000000000000000000000000
0000000007000000000a00000003300000088000003330000000000000000000d88f4885dccf4cc5d33f43350000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000088888810cccccc1033333310000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000555551005555510055555100000000000000000000000000000000000000000
00000000000000000000000000000900000009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000090909090909090900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000a0a00090a0a00090a0a09000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000770000a7770000a7879000000090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000007aa0009088a0009000a00000009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000700000aa7aa000aa70a000a000a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000a0000090a9000090a909009000900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0066600000060000000600000007000000ccc000000c0000000c0000000600000000000000000000000000000000000000000000000000000000000000000000
066666000066500000075000000600000c6ccc0000cc100000061000000c00000000000000000000000000000000000000000000000000000000000000000000
067666000076500000065000000600000ccccc00006c1000000c1000000c00000000000000000000000000000000000000000000000000000000000000000000
066766000066500000065000000600000ccc6c0000c61000000c1000000c00000000000000000000000000000000000000000000000000000000000000000000
0066600000060000000600000006000000ccc000000c0000000c0000000c00000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00aaa000000a0000000a0000000a0000008880000008000000080000000600000000000000000000000000000000000000000000000000000000000000000000
0aaaaa0000aa9000000a9000000a0000086888000088200000062000000800000000000000000000000000000000000000000000000000000000000000000000
0aaaaa0000aa9000000a9000000a0000088888000068200000082000000800000000000000000000000000000000000000000000000000000000000000000000
0aaaaa0000aa9000000a9000000a0000088868000086200000082000000800000000000000000000000000000000000000000000000000000000000000000000
00aaa000000a0000000a0000000a0000008880000008000000080000000800000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00bbb000000b0000000b0000000b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0bbbbb0000bb3000000b3000000b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0bbbbb0000bb3000000b3000000b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0bbbbb0000bb3000000b3000000b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00bbb000000b0000000b0000000b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000060c0000000000000000000000000000000000000000000000008e800000000000006e600000000e202e0002e0e2000000e20000ccd000
06c3c60060c3c060006d828006666660000222066022200000022206602220000000087878000000000006787600000002282200022822000dc022000cdccc22
061816006d181d6006d8892c00dddd0000227e2662e722000022ee2662ee22000b00008280000b0000000062600000000c999c000c999c00ccc982220089892e
068986006d898d606d889880008881c0002eee2222eee200002ee72222ee7200b3b000222000b3b000b000222000b000dc898dc00c898d00cd89882e08989980
068986006d898d60008988d608999830002ee226622ee200002ee226622ee200b33b0222220b33b00b3b0222220b3b00cc929cc00c989c00c98898000089892e
068986006d898d6000888d60008881c000022282282220000002228228222000b3b3beeeeeb3b3b00b33beeeeeb33b00cd898cd00d898c0009888cc00cccdc22
06080600600800600000d60000dddd000000cc8888cc00000000cc8888cc0000b3b3b77727b3b3b00b33b77727b33b000c080c000c080c000899dcd000dcc000
0000000000000000000060000666666000cccc9889cccc000000cc9889cc0000b3b3b22222b3b3b00b33b22222b33b0000000000000000000000cc0000000000
0000000000000000000b0000bbbb330000c6cc8998cc6c000006cc89986cc000b3b3beeeeeb3b3b00b33beeeeeb33b0006000060060000600005060000222000
030003003000003000b30000033330000ccccc8888ccccc0000ccc8888cc6000b3b302777203b3b00b33027772033b0000866800008668000012e80002eee206
03080b0033080bb00b358000003500000ccccc9889ccccc0000ccc9889ccc000b3300222220033b00b30022222003b00052ce25002e2ee20012e26862eeeee80
0b3eb300b33eb330335eb33003ee80000c6c6c8998c6c6c000cc6c8998c6cc0033000eee2e0003300b300eee2e003b0002e1ee202eec1ee202ee12e0c1c1c260
0b5e3300b35e333000e5b30000530000cccccc8888cccccc00cccc8888cccc003000022772000030033002277200330052eece252ee1cee252ecee251c1c1e60
0b000300b300053000053000033bb000ccc6c098890c6ccc006ccc9889cc6c000000002220000000030000222000030002ee1e202eec1ee2021ee2102eeeee80
03000300300000300003000033333300c6ccc089980ccc6c000cc68998ccc00000000022200000000000002220000000052ec25002e1ce200c22210002eee206
000000000000000000000000000000000ccc00088000ccc000000008800000000000000200000000000000020000000000022000002c12000005000000222000
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
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888777777888eeeeee888eeeeee888888888888888888888888888888888888888888888888888888ff8ff8888228822888222822888888822888888228888
8888778887788ee88eee88ee888ee88888888888888888888888888888888888888888888888888888ff888ff888222222888222822888882282888888222888
888777878778eeee8eee8eeeee8ee88888e88888888888888888888888888888888888888888888888ff888ff888282282888222888888228882888888288888
888777878778eeee8eee8eee888ee8888eee8888888888888888888888888888888888888888888888ff888ff888222222888888222888228882888822288888
888777878778eeee8eee8eee8eeee88888e88888888888888888888888888888888888888888888888ff888ff888822228888228222888882282888222288888
888777888778eee888ee8eee888ee888888888888888888888888888888888888888888888888888888ff8ff8888828828888228222888888822888222888888
888777777778eeeeeeee8eeeeeeee888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111bb1b1111bb11711ccc11711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111b111b111b1117111c1c11171111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111b111b111bbb17111c1c11171111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111b111b11111b17111c1c11171111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111bb1bbb1bb111711ccc11711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111166166616661666116611711171111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111611116116161616161117111117111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111666116116661661166617111117111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111116116116161616111617111117111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111661116116161616166111711171111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111661166611661111166616611666161616661171117111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111616161616111111116116161616161611611711111711111111111111111111111111111111111111111111111111111111111111111111111111111111
11111616166116111111116116161666161611611711111711111111111111111111111111111111111111111111111111111111111111111111111111111111
11111616161616161111116116161611161611611711111711111111111111111111111111111111111111111111111111111111111111111111111111111111
11111666166616661666166616161611116611611171117111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111111111111dd1d1d1ddd1ddd11111dd11ddd11dd1ddd1ddd11dd1d1d1ddd1dd1111111111d1d1ddd1ddd1ddd111111111ddd1d1d1ddd1dd111111111
11111111111111111d111d1d11d11d1d11111d1d1d111d1111d11d1d1d1d1d1d1d111d1d11d111111d1d1d1d11d111d11111111111d11d1d1d111d1d11111111
11111ddd1ddd11111ddd1ddd11d11ddd11111d1d1dd11ddd11d11dd11d1d1ddd1dd11d1d111111111d1d1ddd11d111d11111111111d11ddd1dd11d1d11111111
1111111111111111111d1d1d11d11d1111111d1d1d11111d11d11d1d1d1d111d1d111d1d11d111111ddd1d1d11d111d111d1111111d11d1d1d111d1d11111111
11111111111111111dd11d1d1ddd1d1111111ddd1ddd1dd111d11d1d1dd11ddd1ddd1ddd111111111ddd1d1d1ddd11d11d11111111d11d1d1ddd1d1d11111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111ddd1ddd11dd1d1d111111d111dd1ddd111111dd1ddd1ddd1ddd111111dd1d1d1ddd1ddd11d1111111111111111111111111111111111111
11111111111111111d1d1d1d1d111d1d11111d111d1d1d1d11111d111d1d1ddd1d1111111d1d1d1d1d111d1d111d111111111111111111111111111111111111
11111ddd1ddd11111dd11ddd1d111dd111111d111d1d1dd111111d111ddd1d1d1dd111111d1d1d1d1dd11dd1111d111111111111111111111111111111111111
11111111111111111d1d1d1d1d111d1d11111d111d1d1d1d11111d1d1d1d1d1d1d1111111d1d1ddd1d111d1d111d111111111111111111111111111111111111
11111111111111111ddd1d1d11dd1d1d111111d11dd11d1d11111ddd1d1d1d1d1ddd11111dd111d11ddd1d1d11d1111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111eee1eee111116661111166116661666166117111ccc11111eee1e1e1eee1ee1111111111111111111111111111111111111111111111111111111111111
111111e11e11111116161111161616111616161611711c1c111111e11e1e1e111e1e111111111111111111111111111111111111111111111111111111111111
111111e11ee1111116661111161616611666161611171c1c111111e11eee1ee11e1e111111111111111111111111111111111111111111111111111111111111
111111e11e11111116111111161616111616161611711c1c111111e11e1e1e111e1e111111111111111111111111111111111111111111111111111111111111
11111eee1e11111116111171166616661616166617111ccc111111e11e1e1eee1e1e111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111166611111661166616661661111111111cc1111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111616111116161611161616161111177711c1111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111666111116161661166616161777111111c1111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111611111116161611161616161111177711c1111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111161111711666166616161666111111111ccc111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111eee1eee1111166611111661166616661661111111111ccc11111eee1e1e1eee1ee11111111111111111111111111111111111111111111111111111
1111111111e11e111111161611111616161116161616177717771c1c111111e11e1e1e111e1e1111111111111111111111111111111111111111111111111111
1111111111e11ee11111166611111616166116661616111111111c1c111111e11eee1ee11e1e1111111111111111111111111111111111111111111111111111
1111111111e11e111111161111111616161116161616177717771c1c111111e11e1e1e111e1e1111111111111111111111111111111111111111111111111111
111111111eee1e111111161111711666166616161666111111111ccc111111e11e1e1eee1e1e1111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111eee1eee11111666111116111666161616661166111111111ccc11111eee1e1e1eee1ee111111111111111111111111111111111111111111111
11111111111111e11e1111111616111116111161161616111611177717771c1c111111e11e1e1e111e1e11111111111111111111111111111111111111111111
11111111111111e11ee111111666111116111161161616611666111111111c1c111111e11eee1ee11e1e11111111111111111111111111111111111111111111
11111111111111e11e1111111611111116111161166616111116177717771c1c111111e11e1e1e111e1e11111111111111111111111111111111111111111111
1111111111111eee1e1111111611117116661666116116661661111111111ccc111111e11e1e1eee1e1e11111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111161616661661166616661666161116661111116616161666166611111111111111111111111111111111111111111111111111111111
11111111111111111111161616161616161611611611161116161777161616161611161611111111111111111111111111111111111111111111111111111111
11111111111111111111161616661616166611611661166616161111161616161661166111111111111111111111111111111111111111111111111111111111
11111111111111111111161616111616161611611611161616161777161616661611161611111111111111111111111111111111111111111111111111111111
11111111111111111666116616111666161611611666166616661111166111611666161611111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111eee1eee1eee1e1e1eee1ee11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111e1e1e1111e11e1e1e1e1e1e1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111ee11ee111e11e1e1ee11e1e1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111e1e1e1111e11e1e1e1e1e1e1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111e1e1eee11e111ee1e1e1e1e1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111eee1ee11ee111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111ee11e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111eee1e1e1eee11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111116661111161611111666111116661661161611111c111ccc11111666166116161111166616661666166611111111111111111111111111111111
11111111111116161111161611111616111111611616161617771c111c1c11111161161616161111116111611666161111111111111111111111111111111111
11111111111116661111116111111666111111611616161611111ccc1c1c11111161161616161111116111611616166111111111111111111111111111111111
11111111111116111111161611711611111111611616166617771c1c1c1c11711161161616661111116111611616161111111111111111111111111111111111
11111111111116111171161617111611117116661616116111111ccc1ccc17111666161611611666116116661616166611111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111eee1ee11ee1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111e111e1e1e1e111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111ee11e1e1e1e111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111e111e1e1e1e111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111eee1e1e1eee111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111eee1e1111ee1eee111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111e111e111e111e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111ee11e111eee1ee1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111e111e11111e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111eee1eee1ee11eee111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111eee1eee11711bbb1bbb1bb11171116666611171117111111eee1e1e1eee1ee1111111111111111111111111111111111111111111111111111111111111
111111e11e1117111b1b11b11b1b17111666116611171117111111e11e1e1e111e1e111111111111111111111111111111111111111111111111111111111111
111111e11ee117111bb111b11b1b17111661116611171117111111e11eee1ee11e1e111111111111111111111111111111111111111111111111111111111111
111111e11e1117111b1b11b11b1b17111666116611171117111111e11e1e1e111e1e111111111111111111111111111111111111111111111111111111111111
11111eee1e1111711bbb11b11b1b11711166666111711171111111e11e1e1eee1e1e111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111166611111616111111111666111111661666166111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111161611111616111117771616111116111616161611111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111166611111161177711111666111116661666161611111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111161111111616111117771611111111161611161611111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111161111711616111111111611117116611611166611111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111166616661611111111111cc1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111161116116111777111111c1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111611161161111111ccc11c1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111161116116111777111111c1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111116116661666111111111ccc111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111eee1ee11ee11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111e111e1e1e1e1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111ee11e1e1e1e1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111e111e1e1e1e1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
82888222822882228888822282228282888282828222822288888888888888888888888888888888888882228222822282228882822282288222822288866688
82888828828282888888888282828282882882828882888288888888888888888888888888888888888882888882828282828828828288288282888288888888
82888828828282288888882282828222882882228222822288888888888888888888888888888888888882228882822282228828822288288222822288822288
82888828828282888888888282828882882888828288828888888888888888888888888888888888888888828882828288828828828288288882828888888888
82228222828282228888822282228882828888828222822288888888888888888888888888888888888882228882822288828288822282228882822288822288
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

__map__
4447035a00126475636b20746f20746865207369646573210c03090b120012001200002200220022001200120012220022002200120012001200002200220022020008180000015438548a62a37475000818000001ad38ad8a9ba389756f000f6c6f6f6b20696e206d7920657965730c040a0c12121212000000002222222212
00001200122200220000221200001200000000220000220012120000000000002222000200071a00000264326566618e72897d867b7b7c6a00071a0000029b329a669e8e8d898286847b836a6a000862696720626f73730504150c1222113242122200324212220032421222183242050008180108015736574c576c58840008
18010801a836a84ca86ca7840008180108016a396a4f6a796b8e0008180108019539954f9579948e080818010801812b75388b557d6e17021266726f6d206c65667420746f20726967687402050303008300037570210e0408080000001100000000000021000000000011001100000000210021000000110011001100002100
2100210011000011000011210000210000210200081801080464384c64659f797a82664e5f628c70aa49ad4b9948884464565c0008180108049b38b364989b867a7d66b15f9d8c8faab6adb499b788bb64a95c6b000873636973736f727309030c0c111111110021212121111111110021212121001111000000212100020008
1801080471327132713271557182719071a471b851bf529f52897e798f700008180108048e328e328e328e558e828e908ea48eb8aebfad9fad8981797070720016697473206120747261702e206120666c79747261702e0a030c0c11111100000000212121111111113700212121210000000000000000000003000818010802
6d39566b48a970aa8baa8c87757f0008180108029239a96bb7a98faa74aa73878a7f0a0818010801913691747a516f7552010a676c7565207468656d2100000e0c02000818010a04355351528a53a052b752b469ae7ea893a99e95ad81bc568f346b000818010a04ca53ae5275535f5248524b69517e5793569e6aad7ebca98f
cb6b4f0007646f67206c656708030c0e19191913232929291919190000292929000000000000000002000818010802473568654d90698f7e90797c7964000818010802b8359765b290968f8190887b86644f00077520752075207508030c0b131313000023232319191919292929291919190000292929020008180108025234
51684d7e667e757e786d7964000818010802ad34ae68b27e997e8a7e876d86646c00093420636f726e65727307030c0c1919190029292933333300434343000000570000000500081801080147344772517c7a7c000818010801b834b872ae7c857c00081801080147cb4898518a7a8b000818010801b8cbb798ae8a858b0208
18010801802e8045815b80720a0205736c617021090549000964656a612076753f2106030e0c151515151515151515151515151515151515010008180108053b364e504c927c9b9fa4af83a26d94546a616a756a897d918a8c97879c71836a62000e726f6c6c657220636f617374657208030c0a151515152525252515151515
2525252515151515252525250200081801080336974f8b646b8470a27b98a77aa561a357797870000818010803c997b08b9b6b7b705d7b67a785a59ea3a8798770ab000b7069706520647265616d7308030b0a151525254545353515152525454535351515252545453535040008180108044ec64ead4e9e4e884e7269726986
699a4e994f894f7a586e5d6a0008180108047cc67cad7c9e7c887c7261726186619a7c997b897b7a726e6d6a000818010804b5c5b5acb59db587b5719a719a859a99b598b488b479ab6da66900081801080486c686ad869e86888672a172a186a19a86998789877a906e956a94000872616973652075700c04090a1515153535
352525254545451515153535352525254545451515153535352525254545450000000000566600000000000600081801080158c658b5589558870008180108018ec68eb58e958e8700081801080171c671b571957187000818010801a7c6a7b5a795a7870f0818010801a72e9c418a3f84580f08180108015b2e603744566963
3d010d6669677572652038206769667400000e0c02000818050a027f2d7e54456966838097baadbad2000818050a02802d8154ba6999837f9745ad45d23c000008030b0c121212122222222212121212222222221212121222222222020008180000017034708646a058720a08180000018f348f86b9a0a77200000000000000
__sfx__
00010000292501b240152300b23007230032100420000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200
000200001815015130001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
00070000224501e4501a44017440124300f4300b43003400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400
000300002025025240182200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002f150381502c1403a13034120001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
000504000d1500f1400e1500d13000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000e67028670096602965021650086501b65007650126501f650066501b650126400564016650046500d65003650196500265013650176500265000650136400d630176301f6200e620096200661000600
00080000246501f65019650116200a6300d650086500465004610076300965005650026400064002620076400b650096500665004650036400364000640006400064000630000300003000000000000000000000
0004131f00550015500155002550035500355004550045500555006550075500a5500d5501155014550185501a5501b5501b5501c5401d5401e5401d5301b5301c5301c5301e5201f5201e5301d5301c5201b500

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
               -- k/l level chose, w weapon
--	ship0.money=1000

	
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
	auto=  {s=42,wt=4, fn=function() p.auto=true end},
	armor= {s=43,wt=5, fn=function() more_armor() end},
	x2=    {s=44,wt=2, fn=function() set_mult(2) end},
	x5=    {s=45,wt=4, fn=function() set_mult(5) end},
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
kinds={"red","green","blue","bug","ufo","mother","flym","greenm","fly"}
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
hp={red=2,green=1,blue=2,bug=12,ufo=3,mother=12,flym=10,greenm=12,fly=2}
worth={red=150,green=40,blue=130,bug=200,ufo=300,mother=500,flym=300,greenm=300,fly=60}
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
	flym={12,8},greenm={11,3},
	fly={12,8}}
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
	fly={{140,false,false,8},{141,false,false,8}},
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
		ufo=rot_tab(176),fly=rot_tab(140)}
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
 enem()
 plasma()
 ebullets()
	bullets()
	items()
	if p.dead==0 then
		if p.inv>0 then
			p.inv-=1
		elseif ship_hit() then
			-- armor takes the hit
			if p.armor>0 then
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
	p.w,p.auto=max(1,p.w-1),false
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
	local o={x=60,y=118,dead=0,inv=0,money=0,mult=1,mult_t=0}
	for k,v in pairs(ship0) do o[k]=v end
	o.ammo=o.shots
	return o
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
-- first the chance for any, then
-- which one by its weight
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
	e,pb,eb,it,b={},{},{},{},{}
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
-- w next weapon
function dbg_input()
	while dbg_keys and stat(30) do
		local k=stat(31)
		if k=="k" or k=="l" then
			-- start_level counts up
			if (k=="k") stage=max(0,stage-2)
			start_level()
			dbg_t=90
			if (lev.shop) shop_open()
		end
		-- w: next weapon
		if (k=="w") p.w=p.w%#wpn+1
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

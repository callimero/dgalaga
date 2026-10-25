-- todo
	-- enemies formation
	-- attacks
	-- levels
	-- level transitions
	-- meteor storm
 -- object class 
 	
-- settings

p={x=64-4, y=118, w=1} -- w: weapon
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
-- own shots: magazine, reloads
-- only when empty
shot_max=3     -- shots in magazine
               -- (extras: more)
reload_time=20 -- frames per shot
shot_spd=3     -- px/frame
pb={} -- projectiles of big enemies
-- per big kind: sprite, speed,
-- aimed at the ship?, trail
-- colors (bright,dark; nil=none)
eshot={
	bug={s=51,v=1,aim=true,c1=11,c2=3},
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
trail_life=15   -- frames a plasma
                -- particle lives

-- levels: stored in the map
-- (rows 0-31 = 0x2000-0x2fff),
-- written by the level editor.
-- do not paint in the map editor!
-- enemy kinds by number
kinds={"red","green","blue","bug"}
between_time=150 -- frames of the
                -- screen between
                -- levels
bonus_msg=270   -- frames "bonus
                -- stage" blinks
bonus_wait=120  -- frames before the
                -- bonus ships come
end_wait=90     -- frames the level
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
form_top=14     -- y of row 0
form_sway=12    -- px left/right
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
hp={red=1,green=1,blue=1,bug=5}
worth={red=50,green=40,blue=30,bug=200}
flash_time=4    -- frames white
                -- after a hit
-- explosion: sprites 64-68,
-- frames per image
boom_spd=4
-- particle colors per kind
-- {bright,dark}
col={ship={7,12},red={8,2},green={11,3},
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
	p.dead,p.inv=0,0
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
	stage=0
	start_level()
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
	-- ship destroyed: wait, then
	-- back (or game over)
	if p.dead>0 then
		p.dead-=1
		if p.dead==0 then
			if lives==0 then
				_update60=over
				return
			end
			p.x,p.inv=60,inv_time
		end
	else
	if(btn(⬅️)) then
	 p.x=p.x-1	--and > 0
	 til=-1
	end
	if(btn(➡️)) then
	 p.x=p.x+1 --and < 128
	 til=1
 end
	-- stay on the screen
	p.x=mid(0,p.x,120)	
	-- debug: up = next weapon
	if (btnp(⬆️)) p.w=p.w%#wpn+1
	-- fire: one shot per press
	-- while there is ammo
	if btnp(❎) and ammo>0 then
		shoot(p.w)
		ammo-=1
	end
	end -- ship alive
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
 spawn()
 enem()
 plasma()
 ebullets()
	bullets()
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
	-- bonus: blinking announcement
	if lev.bonus and lev.t<bonus_msg and lev.t%30<20 then
		print("bonus stage",42,50,10)
	end
	-- all came and all are gone:
	-- go on a bit (explosions,
	-- shots still flying)
	if #lev.q==0 and #e==0 then
		lev.done+=1
		if lev.done>=end_wait and #eb+#pb==0 and p.dead==0 then
			hiscore=max(hiscore,score)
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
	if (btnp(❎)) run()
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
	return 64+(o.col-(lev.c-1)/2)*form_dx
		+sin(t()/form_period)*form_sway,
		form_top+o.row*form_dy
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
	if o.st=="form" then
		o.x,o.y=slot(o)
	elseif o.st=="roam" then
		roam(o)
	elseif o.st=="enter" then
		fly_path(o)
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
	lives-=1
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
	print(lives,120,1,7)
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
-- level in the map, from 0x2000:
-- len (0=end of list), type
-- (0 normal,1 bonus), cols, rows,
-- per slot: kind+16*stream,
-- streams, per stream: delay/4,
-- gap, speed*16, kind+count (only
-- bonus), segments, points x+64,
-- y+64 (start + 3 per segment)

-- read level n (after the last:
-- start again with level 1)
function load_level(n)
	local a=0x2000
	for i=2,n do
		a+=peek(a)
		if (peek(a)==0) a=0x2000
	end
	local function rd()
		a+=1
		return peek(a)
	end
	local l={bonus=rd()==1,c=rd(),r=rd(),
		slots={},q={},t=0,hits=0,n=0,done=0}
	for row=0,l.r-1 do
		for col=0,l.c-1 do
			local v=rd()
			if (v%16>0) add(l.slots,{col=col,row=row,k=kinds[v%16],st=v\16})
		end
	end
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
				add(l.q,{t=bonus_wait+st.delay+j*st.gap,st=st,k=st.k})
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
	e,pb,eb={},{},{}
	dive_cool=dive_every
	wave_n=0
end

-- launch the enemies whose time
-- has come, at the path start
function spawn()
	lev.t+=1
	for q in all(lev.q) do
		if lev.t>=q.t then
			local pt0=q.st.pts[1]
			local o=obj_new(q.k,pt0[1],pt0[2],
				rot[q.k] and "dir" or "anim")
			o.st,o.path,o.seg,o.u="enter",q.st,0,0
			o.cool=60+rnd(60)
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

-- screen between levels
function between()
	cls(0)
	stars()
	local function mid_print(t,y,c)
		print(t,64-#t*2,y,c)
	end
	mid_print("stage "..stage,40,10)
	if (lev.bonus) mid_print("hits "..lev.hits.." of "..lev.n,52,11)
	mid_print("score "..score,64,7)
	mid_print("hi "..hiscore,74,6)
	bt-=1
	if bt<=0 then
		start_level()
		_update60=game
	end
end

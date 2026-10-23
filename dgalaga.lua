-- todo
	-- enemies formation
	-- attacks
	-- levels
	-- level transitions
	-- meteor storm
	
-- settings

p={x=64-4, y=110}
s={}
ns=100
e={}
ne=10
b={} --ringbuffer later


function _init()
	pal(4,133,1)
	-- stars init
	for i=1,ns do
		add(s,{x=rnd(128),y=rnd(128),z=rnd(10)+2})		
	end
	-- enemies
	for i=1,ne do
		add(e,{x=20+i*6,y=20+10*(i%2),s=16})
	end
	_update60=title
end

function title()
	cls(0)
	print("pico deluxe",40,30,10)
	_update60=game
 if(btnp(❎))  _update60=game
end

function enem()
	for en in all(e) do
		spr(en.s,en.x,en.y)
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

function bullets()
	for bu in all(b) do
		if bu.y>-5 then
			bu.y=bu.y-1
		end
		spr(4,bu.x,bu.y)
	end
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
	if(btn(❎)) then
		-- cooldown wweapon
		-- repeat only when autofire 
		add(b,{x=p.x,y=p.y-4})
	end
	bullets()
	spr(1+til,p.x,p.y)
 enem()
end

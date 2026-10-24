-- todo
	-- enemies formation
	-- attacks
	-- levels
	-- level transitions
	-- meteor storm
 -- object class 
 	
-- settings

p={x=64-4, y=110}
s={}
ns=100
e={}
ne=10
b={} --ringbuffer later

-- animationen nach zeit: je bild
-- {sprite,flip_x,flip_y,frames}
anim={
	gruen={{144,false,false,20},{145,false,false,20}},
	rot={{128,false,false,20},{129,false,false,20}},
	blau={{160,false,false,20},{161,false,false,20}},
	muenze={{112,false,false,6},{113,false,false,6},
		{114,false,false,6},{115,false,false,6},
		{115,false,true,6},{114,false,true,6},
		{113,false,true,6},{112,false,true,6}},
}


function _init()
	pal(4,133,1)
	-- stars init
	for i=1,ns do
		add(s,{x=rnd(128),y=rnd(128),z=rnd(10)+2})		
	end
	-- drehung: 8 richtungen je typ
	dreh={gruen=dreh_tab(144),
		rot=dreh_tab(128),blau=dreh_tab(160)}
	-- demo: formation flattert,
	-- je typ eine reihe
	for r,typ in pairs({"rot","gruen","blau"}) do
		for i=0,4 do
			add(e,obj_neu(typ,24+i*20,r*12))
		end
	end
	-- je einer stuerzt drehend herab
	-- (versetzt, verschieden schnell)
	for k,typ in pairs({"rot","gruen","blau"}) do
		local o=obj_neu(typ,14+k*24,-40*k,"drehen")
		o.a,o.v,o.rate=0.75,0.3+k*0.1,1/(30+k*10)
		add(e,o)
	end
	-- blau fliegt im kreis, bild
	-- zeigt in flugrichtung
	local o=obj_neu("blau",64,80,"richtung")
	o.v,o.kurve=0.5,0.004
	add(e,o)
	-- muenze dreht sich am platz
	add(e,obj_neu("muenze",112,80))
	-- muenze faellt
	o=obj_neu("muenze",104,-10)
	o.v=0.3
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
	if(btn(❎)) then
		-- cooldown wweapon
		-- repeat only when autofire 
		add(b,{x=p.x,y=p.y-4})
	end
	bullets()
	spr(1+til,p.x,p.y)
 enem()
end
-->8
-- ====== objekte ======
-- objekt: x,y = mitte
-- modus:
--  "anim"     bilder nach zeit
--  "richtung" bild zeigt in
--             flugrichtung a
--  "drehen"   bild dreht sich
--             mit rate, egal
--             wohin es fliegt
-- winkel in umdrehungen:
-- 0=rechts 0.25=oben 0.5=links
-- 0.75=unten
-- a: flugrichtung, v: tempo,
-- kurve: a-aenderung je frame
-- ba: winkel des bildes
-- tempo: eigener animations-takt
-- (0.9..1.1), start an zufaelliger
-- stelle der animation -> die
-- formation flattert nicht synchron
function obj_neu(typ,x,y,modus)
	local o={typ=typ,x=x,y=y,
		modus=modus or "anim",
		an=anim[typ],dr=dreh[typ],
		a=0.75,v=0,kurve=0,
		ba=0.75,rate=0,
		tempo=0.9+rnd(0.2)}
	o.f=flr(rnd(#o.an))+1
	o.t=rnd(o.an[o.f][4])
	return o
end

function obj_weiter(o)
	-- fliegen
	o.a=(o.a+o.kurve)%1
	o.x+=cos(o.a)*o.v
	o.y+=sin(o.a)*o.v
	-- bildwinkel
	if o.modus=="drehen" then
		o.ba=(o.ba+o.rate)%1
	else
		o.ba=o.a
	end
	-- bilder nach zeit
	o.t+=o.tempo
	if o.t>=o.an[o.f][4] then
		-- rest behalten: takt bleibt genau
		o.t-=o.an[o.f][4]
		o.f=o.f%#o.an+1
	end
end

function obj_zeichne(o)
	local b
	if o.modus=="anim" then
		b=o.an[o.f]
	else
		b=o.dr[flr(o.ba*8+0.5)%8+1]
	end
	spr(b[1],o.x-4,o.y-4,1,1,b[2],b[3])
end

-- drehtabelle aus einer sprite-
-- reihe: n=vorn, n+2=schraeg,
-- n+3=seite. index 1..8 =
-- rechts,rechts-oben,oben,
-- links-oben,links,links-unten,
-- unten,rechts-unten.
-- zeigt ein bild falsch herum:
-- hier die flips tauschen
function dreh_tab(n)
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

function enem()
	for en in all(e) do
		obj_weiter(en)
		-- demo: unten raus, oben rein
		if (en.y>136) en.y=-8
		obj_zeichne(en)
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

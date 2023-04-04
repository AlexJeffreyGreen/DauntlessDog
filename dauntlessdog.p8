pico-8 cartridge // http://www.pico-8.com
version 37
__lua__
--thegameoverguy
--shump showcase entry for lazy devs
--there is plenty of room
--for improvement, first pico8 game
--initial ui autotext code snippits from
--level27geek
--additional work and bug fixes on ui textboxes done
--by thegameoverguy
function _init()
	t=1
	nextfire=0
	lockout=0
	mode="start"
	maxwave=20
	score=0
	xpad=0
	uixpad=14
	defaulttimer=60
	defselftimer=120
	msgs={"got em!", "blast em!", "great shot", "i never miss!"}
	names={"dover","jane","casey"}
	enames={"gek-o","shelton","chomper","cobra"}
	intros={"let's blast these guys!","make sure you don't eat my dust.","let's kick some butt"}
	warnings={"s.o.s, i'm not going to last at this rate!", "get them off my tail!", "my ship isn't going to last at this rate."}
	respawns={"going back to base", "i need repairs! back to base", "my ship!", "see yah!"}
	encourages={"don't worry! we got this!", "hey dover, drinks on you tonight!", "we are unbeatable!"}
	enemymsgs={"any enemy of cobra is my enemy","casey! your father will destroy you!","dover! you're a failure just like your father!", "cobra had no trouble killing your father!","the federation is doomed!","this galaxy is ours!","we can never loose!","you will never beat me!"}
	enemykillmsgs={"sucker!", "you'll never win!", "easy kill!"}
	enemydeathmsgs={"nooooo!", "boss will kill me!", "boss, i failed!"}
	
	cobramsgs={"dover, your father will never be avenged!", "casey, what a disappointment.", "too slow jane!","don't get in my way","dover, your father never stood a changce."}
	cobraatkmsgs={"ha! you can never defeat me! i am unbeatable!","die!","the galaxy is mine!","you are worthless!","the federation is doomed!","your father was never going to beat me!","i'll kill you casey!"}
	cobradeathmsgs={"impossible!","dover cannot defeat me!","my god, casey... forgive me.","death is only temporary!"}
	
	cobratailmsgs={"my scales are too strong for your lasers!","my tail is invincible!","you are too weak to hurt me!"}
	--btimer=200
	tbx_s_sound={8,9,10}
	m_wave1=7
	m_wave2=13
	m_wave3=17
	m_wave4=19
	
	stars={}
	for i=1,100 do
		local newstar={
  			x=flr(rnd(128)),
  			y=flr(rnd(128)),
  			spd=rnd(1.5)+0.5
  		}
  		add(stars,newstar)
	end
	current_trk=8
end

function start_game()
	wave_enemies={}
	init_waves()
	nextfire=0
	enemies={}
	rings={}
	wave=0
	wavetime=80
	maxhp=15
	
	lockout=0
	
	ships={}
	tail={}
	ship=addfriend(1,58,58)
	ship.hp=15
	ship.mission=""
	ship.x,ship.y=58,150
	local j=addfriend(2,200,200)
	j=addfriend(3,200,200)

	flamespr=17
	
	buls={}
	ebuls={}
	
	parts={}
	shwaves={}
	
	window={}
	
	music(current_trk,6)
	nextwave()
end

function _draw()
 if mode=="game" then
  draw_game()
 elseif mode=="start" then
  draw_start()
 elseif mode=="wavetext" then
 	--draw_window()
  draw_wavetext()
 elseif mode=="over" then
  draw_over()
 elseif mode=="win" then
  draw_win()
 end 
 
 draw_textbox()
end


function _update60()
	t+=1
	if mode=="game" then
  update_game()
 elseif mode=="start" then
  update_start()
 elseif mode=="wavetext" then
-- 	update_wavetransitions()
  update_wavetext()
 elseif mode=="over" then
  update_over()
 elseif mode=="win" then
  update_win()
 end
 update_textbox()
end

function update_textbox()
	if not window or #window==0 then return end
	
	tbx_update()
	local wind=window[1]

	
	if (btnp(🅾️)) and wind.complete then
		del(window,wind)
	elseif wind.selftimer<=0 then
		del(window,wind)
	end
end

function draw_textbox()
	if not window or #window==0 then return end
	draw_window()
	tbx_draw()
end

function update_win()
	animatestars()
	if locked() then return end
	if btn(❎) or btn(🅾️) then
		startscreen()
	end
end

function update_over()
	if locked() then return end
	if btn(❎) or btn(🅾️) then
		nextwave(true)
	end
end

function draw_start()
	cls()
	starfield()
	sspr(0,96,48,16,38,54)
	spr(1,42,75+sin(time())/4)
	spr(32,58,75+sin(time())/4)
	spr(48,74,75+sin(time())/4)
	pout("dauntless dog",35,40,7)
	pout("press ❎ to start!",25,90,7)
	pout("made by thegameoverguy",18,100,7)
end

function draw_over()
	cls(8)
	starfield()
	cutscene(2)
end

function draw_win()

	cls()
	starfield()
	--draw_game()
	--pout("by:",35,8,7)
	pout("game by:",44,50,7)
	pout("thegameoverguy",33,60,7)
	pout("thanks to:",40,75,8)
	pout("lazy devs!",40,83,12)
	pout("level27geek",40,91,3)
	
	pout("dover",8,7,12)
	spr(192,8,15,2,2)
	pout("jane",8,35,14)
	spr(194,8,44,2,2)
	pout("casey",8,63,11)
	spr(196,8,72,2,2)
	pout("chomper",92,7,2)
	spr(228,95,15,2,2)
	pout("shelton",92,35,4)
	spr(226,95,44,2,2)
	pout("gek-0",92,63,3)
	spr(224,95,72,2,2)
	pout("cobra",52,2,12)
	spr(198,46,10,4,4)
	cutscene(3)
end


function startscreen()
	mode="start"
end

function locked()
	if t<lockout then return true end
	if #window>0 then return true end
	return false
end

--★ probably a better way
--of doing this...
function cutscene(_t)
	if _t==2 then
		if ship.allowedmsgs.othermsg then
			addtext(ship,"i'm going down!")
			addtext(ships[2],"dover!, noooo!")
			addtext(ships[3],"i thought we had a chance!")
			ship.allowedmsgs.othermsg=false
		end
	
		if #window<=0 and ships[2].allowedmsgs.othermsg then
			addtext(ship,"no, *panting*")
			addtext(ship,"i can't give up!",25,50,7)
			addtext(ship,"press 🅾️ to restart!",15,80,7)
			ships[2].allowedmsgs.othermsg=false
		end
	elseif _t==3 then
		if ship.allowedmsgs.othermsg then
			addtext(ship,"we did it, we destroyed cobra.")
			addtext(ship,"father, i hope you are proud!")
			addtext(ships[3],"cobra, you failed. your plans are foiled.")
			addtext(ships[2],"the galaxy is free!")
			ship.allowedmsgs.othermsg=false
		end
	end
end
-->8
--update
function update_game()
		--if mode!="wavetext" then
		animatestars()
		--end
		playerinput()
		updateships()
		updateentities(enemies)
		updateentities(rings)
		movebullets(buls)
		movebullets(ebuls)
		if mode!="wavetext" then
			coldetection()
		end
	 changebehaviors()
	 changefriendbehaviors()
		managewave()
end

function update_start()
	if btnp(❎) then
		start_game()
	end
end

function playerinput()
	--★
	if mode!="game" then return end
	--★
--	if btnp(🅾️) then
--		testspawnfriend()
	--end
 ship.sx=0
 ship.sy=0
 ship.spr=1
 
 if btn(⬅️) then
  ship.sx=-2
  ship.spr=2
 end
 if btn(➡️) then
  ship.sx=2
  ship.spr=3
 end
 if btn(⬆️) then
  ship.sy=-2
 end
 if btn(⬇️) then
  ship.sy=2
 end
 if btn(5) then
 	if ship.bultimer<=0 then
 		fire(ship,0,5)
 		--makebullet(ship,buls,1)
 	end
 end
 ship.bultimer-=1
 
 ship.x+=ship.sx
 ship.y+=ship.sy
	--if mode=="game" then
	 --checking if we hit the edge
	 if ship.mission != "flyin" then
	 	if ship.x>128 then
	 	 ship.x=0
	 	end
	 	if ship.x<0 then
	 	 ship.x=128
	 	end
	 	if ship.y<0 then
	  	ship.y=0
	 	end
		 if ship.y>120 then
	  	ship.y=120
	 	end
	 end
	 
	 
 --end
end

function updateships()
	for s in all(ships) do
		if s.invul>0 then
				s.invul-=1
		end
		--if s!=ship then
		doentity(s)
		if s.mission !="respawn" and s.hp==1 and s.allowedmsgs.warningmsg==true then	
			random_msg(3,s)
			s.allowedmsgs.warningmsg=false
	 end
	--	end
 	flamespr=flamespr+.5
 	if flamespr>20 then
  	flamespr=17
	 end
 
 	if s.muzzle>0 then
  	s.muzzle=s.muzzle-1
 	end
 
	end
end

function updateentities(t)
	if mode=="wavetext" then return end
	for e in all(t) do
		animate(e)
		doentity(e)
		move(e)
		if e.muzzle>0 then
  		e.muzzle=e.muzzle-1
 	end
	end
end



function movebullets(t)
	for b in all(t) do
  --local mybul=buls[i]
  --b.y=b.y-b.mov
  move(b)
  if not inbounds(b) then
   del(t,b)
  end
 end
end


function coldetection()
	for e in all (enemies) do
		for s in all(ships) do
			if s.invul<=0 then
				if col(s,e) then
					hurt(s)
				end
			end
		end
		for b in all (buls) do
			if col(e,b) then
				del(buls,b)
				smol_shwave(b.x+4,b.y+4)
				smol_spark(b.x+4,b.y+5)
				--you cannot hurt cobra's head
				if e.entity!="b" then
					e.hp-=1
				else
					--local p=rnd(100)
					--if p>95 then
						e.hp-=.5
					--end
				end
				sfx(1,3)
				e.flash=2
				if e.hp<=0 then
					killenemy(e)
				end
			end
		end
	end
	for r in all(rings) do
		for s in all(ships) do
			if col(s,r) then
				if fget(r.spr,6) then
					s.hp=min(s.hp+1,ship.maxhp)
					sfx(4,3)
					del(rings,r)
				elseif fget(r.spr,7) then
					s.hp=min(s.hp+2,ship.maxhp)
					sfx(5,3)
					del(rings,r)
				end
			end
		end
	end
	for b in all(ebuls) do
		for s in all(ships) do
			if s.invul<=0 then
				if col(s,b) then
					del(ebuls,b)
					hurt(s)
				end
			end
		end
	end
		if #enemies>0 then
		for i=1,#tail do
			for b in all(buls) do
				if col(tail[i],b) then
					del(buls,b)
					smol_spark(b.x+4,b.y+5)
					if i==1 then
						explode(b.x+4,b.y+4)
						--smol_shwave(b.x+4,b.y+4)
						enemies[1].hp-=2
						sfx(7,2)
					end
					--smol_shwave(b.x+4,b.y+4)
				end
			end
			for b in all(ebuls) do
				if col(tail[i],b) then
					del(ebuls,b)
				end
			end
			for s in all(ships) do
				if s.invul<=0 then
					if col(s,tail[i]) then
						hurt(s)
					end
				end
			end
			for r in all(rings) do
				if col(tail[i],r) then
					del(rings,r)
				end
			end
		end
	end
end

function managewave()
	if mode=="game" and #enemies==0 and #rings==0 then
		if wave==maxwave then 
			lockout=t+30
			mode="win" 
		else
			nextwave()
		end
	end
end

--★★
function changebehaviors()
	if mode!="game" then return end
	if #enemies==0 then return end
	local maxnum=min(10,#enemies)
 local myindex=flr(rnd(maxnum))
 myindex=#enemies-myindex
 local e=enemies[myindex]
	if e==nil then return end	
	if e.mission!="protec" or e.behaviortimer>=0 then return end
	if t>nextfire and e.entity=="e" then
		--firespread(e,8,1,rnd())
		fire(e,0,1)
		nextfire=t+20+rnd(30)
	end	
	if t%e.atkf==0 then
		e.target=activeships()
		e.anispd=.08
		e.wait=60
		e.shake=30
		e.behaviortimer=e.behaviormax
		e.mission="attac"
		local msg=6
	
		if e.entity!="e" then
			if e.entity=="b" then
					msg=9
			end
			if flr(rnd(2))%2==0 then
					random_msg(msg,e)
			end
		end
	end
end


function changefriendbehaviors()
	if mode!="game" then return end
	if #enemies==0 then
	 for s in all(ships) do
	 	if s!=ship and s.mission=="attac" then
	 		s.mission="protec"
	 	end
	 end
	 return 
	end

	local s=rnd(ships)
	local b_timer=s.behaviormax
	if s==ship then return end
	if s.behaviortimer<=0 then
		if s.mission=="protec" then
			local e=rnd(enemies)
			if e.entity=="b" then
				if inbounds(tail[1]) then
					e=tail[1]
				end
			end
			--if  then
				for s in all (ships) do
					if e==s.target then
						e=rnd(enemies)
					end
				end
			--end
			s.target=e
			s.behaviortimer=b_timer
			s.mission="attac"
			s.allowedmsgs.randommsg=true
		elseif s.mission=="attac" then
			s.mission="protec"
			s.behaviortimer=b_timer
			--★
		end
	end
	
end

-->8
--draw
function draw_game()
	cls()
	--debug()
	
	draw_ui()
	starfield()
	draw_players()
	draw_entities(enemies)
	draw_entities(rings)
	draw_bullets(buls)
	draw_shwaves()
	draw_particles()
	draw_bullets(ebuls)
end


function debug()
		if #enemies>0 then
			print(enemies[1].mission,0,8)
			print(inbounds(enemies[1],0,38))

		end
	--print(ship.y)
--	print(enemies[1].mission,0,8)
--	print(tail[1].x..","..tail[1].y)
end


function draw_players()
	
	for s in all (ships) do
		drwmyspr(s)
	 if s.muzzle>0 then
	  circfill(s.x-1,s.y-2,s.muzzle,7)
	  circfill(s.x+8,s.y-2,s.muzzle,7)
	 end 
	 spr(flamespr,s.x,s.y+8)	
	end
end


function draw_entities(t)

	for e in all(t) do
		if e.flash and e.flash>0 then
			e.flash-=1
			for i=1,15 do
				pal(i,7)
			end
		end
		
		if e.entity=="mb" then
			spr(flamespr,e.x,e.y-8,1,1,false,true)
			
			if e.muzzle>0 then
	  	circfill(e.x-1,e.y+10,e.muzzle,7)
	  	circfill(e.x+8,e.y+10,e.muzzle,7)
	 	end
		
		end

		if e.entity=="b" then
					
			if e.mission !="protec" then
				retracttail(e)
			end
			for t in all(tail) do
				spr(t.spr,t.x,t.y,2,2)
			end
		end
		drwmyspr(e)
		pal()
	end
end

function draw_bullets(t)
 --drawing bullets
 for b in all(t) do
 	--print(b.spr)
  drwmyspr(b)
  animate(b)
 end
end

function draw_shwaves()
	for s in all(shwaves) do
		circ(s.x,s.y,s.r,s.col)
		s.r+=s.speed
		if s.r>s.tr then
			del(shwaves,s)
		end
	end
end

function draw_particles()
	for p in all (parts) do
		local pc=7
		pc=page_color(p.age,p.blue)
  if p.spark then
  	pset(p.x,p.y,7)
  else
  	circfill(p.x,p.y,p.size,pc)
  end
  p.x+=p.sx
  p.y+=p.sy
  p.sx=p.sx*0.85
  p.sy=p.sy*0.85
  p.age+=1
  if p.age>p.maxage then
  	p.size-=0.5
  	if p.size<0 then
  		del(parts,p)
  	end
  end
	end
	for s in all(shwaves) do
  circ(s.x,s.y,s.r,s.col)
  s.r+=s.speed
  if s.r>s.tr then
   del(shwaves,s)
  end
 end
end




-->8
--tools
function pout(s,x,y,c) -- 42 tokens, 6.1 seconds
	print(s,x-1,y,0)
	print(s,x+1,y,0)
	print(s,x,y-1,0)
	print(s,x,y+1,0)
	print(s,x,y,c)
end

function col(a,b)
 local a_left=a.x
 local a_top=a.y
 local a_right=a.x+a.colw-1
 local a_bottom=a.y+a.colh-1
 
 local b_left=b.x
 local b_top=b.y
 local b_right=b.x+b.colw-1
 local b_bottom=b.y+b.colh-1

 if a_top>b_bottom then return false end
 if b_top>a_bottom then return false end
 if a_left>b_right then return false end
 if b_left>a_right then return false end
 
 return true
end

function starfield()
 
 for i=1,#stars do
  local mystar=stars[i]
  local scol=6
  
  if mystar.spd<1 then
   scol=1
  elseif mystar.spd<1.5 then
   scol=13
  end   
  
  pset(mystar.x,mystar.y,scol)
 end
end


function animatestars()
 
 for i=1,#stars do
  local mystar=stars[i]
  mystar.y=mystar.y+mystar.spd
  if mystar.y>128 then
   mystar.y=mystar.y-128
  end
 end

end


function makespr(_ty,_va,_s)
 local s={}
 s.spr=_s
 s.x=0
 s.y=0
 s.sx=0
 s.sy=0
 s.entity=_ty
 s.val=_va
 s.flash=0
 s.aniframe=1
 s.anispd=0.04
 s.sprw=1
 s.sprh=1
 s.colw=8
 s.colh=8
 s.shake=0
 s.wait=0
 s.bultimer=0
	s.behaviortimer=0
	s.behaviormax=60
	s.muzzle=0
	s.msgtimer=500
	s.sfx={8}
 return s
end

function drwmyspr(myspr)
 local sprx=myspr.x
 local spry=myspr.y
 
 if myspr.shake and myspr.shake>0 then
  myspr.shake-=1
  if t%4<2 then
  	sprx+=1
  end
  --sprx+=abs(sin(t/2.5))
 end
 --if myspr.cir then
 --	sprx-=2
 --	spry-=2
 --end
 --end
 
 spr(myspr.spr,sprx,spry,myspr.sprw,myspr.sprh)
end


--★ tokens
function page_color(page,colb)
 local col=7
 if not colb then
 	if page>5 then col=10 end
 	if page>7 then col=9 end
 	if page>10 then col=8 end
 	if page>12 then col=2 end
 	if page>15 then col=5 end
 else
 	if page>5 then col=6 end
 	if page>7 then col=12 end
	 if page>10 then col=13 end
 	if page>12 then col=1 end
	 if page>15 then col=1 end 
 end
 return col
end

function rectfill2(_x,_y,_w,_h,_c)
 --★
 rectfill(_x,_y,_x+max(_w-1,0),_y+max(_h-1,0),_c)
end

function inbounds(e)
	local x,y=e.x,e.y
 return not (x<0 or y<0 or x>128 or y>128)
end

function animate(e)
	e.aniframe+=e.anispd--0.4
 if flr(e.aniframe) > #e.ani then
  e.aniframe=1
 end
 e.spr=e.ani[flr(e.aniframe)]
end

function isactive(e)
	if e==nil then return false end
	return e.mission==nil or (e.mission != "brb" and e.mission !="respawn") --- e.mission==nil--(e.mission==nil) or (e.mission!="brb") or (e.mission!="respawn")
end

function multisplode(e,num)
	for i=0,num do
			explode(e.x+rnd(4),e.y+rnd(4))
	end
end
-->8
--textboxes and ui
function draw_window()
	if #window==0 then return end
	local cur=window[1]
	local char=cur.tbx_char
	local wx,wy,ww,wh=4,95,80,26	
	rectfill2(uixpad+wx-3,wy+9,22,23,7)
	rectfill2(uixpad+wx-2,wy+10,20,21,1)
 sspr(cur.sprx,cur.spry,16,16,uixpad+wx,wy+12,16,16)
	pout("🅾️",104+uixpad,120+sin(time())/2,7)
	local name=names[char.val]
	if char.entity!="s" then
		name=enames[(char.val)-10]
	end
	pout(name,2+uixpad,wy+2,char.prc)
end


function tbx_update()
 local currentwindow = window[1]
 if currentwindow.tbx_text!=nil then 
	if currentwindow.sound then
		sfx(rnd(currentwindow.tbx_char.sfx),3)
		currentwindow.sound=false
	end
 local first=nil
 local last=nil
 local rows=flr(#currentwindow.tbx_text/currentwindow.tbx_width)+4
 
 --split text into lines
 for i=1,rows do
  first=first or 1+i*currentwindow.tbx_width-currentwindow.tbx_width
  last =last or i*currentwindow.tbx_width
   
  if sub(currentwindow.tbx_text,last,last)!=" " and i<rows and last<#currentwindow.tbx_text  then
  	while(sub(currentwindow.tbx_text,last,last)!=" ") do
  		last-=1
  	end
  end
   
 	--cut off incomplete words
  --if sub(currentwindow.tbx_text,last+1,last+1)!="" or sub(currentwindow.tbx_text,last,last)!=" " and sub(currentwindow.tbx_text,last+1,last+1)!=" " then
  -- for j=1,currentwindow.tbx_width/4 do
  --  if sub(currentwindow.tbx_text,last-j,last-j)==" " and i<rows then
  --   last=last-j
  --  break
  --  end
  -- end
  --end
  
  --if sub(current)
  
  
  --create line
  --if first char is a space, remove the space
  if sub(currentwindow.tbx_text,first,first)==" " then
   currentwindow.tbx_lines[i]=sub(currentwindow.tbx_text,first+1,last)
  else
   currentwindow.tbx_lines[i]=sub(currentwindow.tbx_text,first,last)
  end
   first=last
   last=last+currentwindow.tbx_width
 end
 
 --lines are now made

 --change lines after printing
 if currentwindow.tbx_counter%currentwindow.tbx_width==0 and currentwindow.tbx_cur_line<#currentwindow.tbx_lines then
  currentwindow.tbx_com_line+=1
  currentwindow.tbx_cur_line+=1
  currentwindow.tbx_counter=1  
 end
 --update text counter
 currentwindow.tbx_counter+=1
 
 if (sub(currentwindow.tbx_text,currentwindow.tbx_counter,currentwindow.tbx_counter)=="") then 
 	currentwindow.tbx_counter+=1
 end
 end
 
 if #currentwindow.tbx_lines>4 then
 	--todo overflow lines?
 end
 
end


function tbx_draw()
local currentwindow = window[1]
 if #currentwindow.tbx_lines>0 then
  --print current line one char at a time
  --sfx(rnd(tbx_s_sound))
  pout(sub(currentwindow.tbx_lines[currentwindow.tbx_cur_line],1,currentwindow.tbx_counter),currentwindow.tbx_x+uixpad,currentwindow.tbx_y+currentwindow.tbx_cur_line*8-8,currentwindow.tbx_col) 
  --print complete lines
  for i=1,currentwindow.tbx_com_line do
   	--currentwindow.complete=true
   --if i>0 then
    --pout(currentwindow.tbx_lines[i],8,8*i,currentwindow.tbx_col)
   
    pout(currentwindow.tbx_lines[i],currentwindow.tbx_x+uixpad,currentwindow.tbx_y+i*8-8,currentwindow.tbx_col)
   --end
   --	sfx(rnd(tbx_s_sound))
  end
  
  local rows=flr(#currentwindow.tbx_text/currentwindow.tbx_width)+4

  if currentwindow.tbx_com_line+4>=rows or currentwindow.timer<= 0then
  	currentwindow.complete=true
  end
  --else
 
 -- end
  
  currentwindow.timer-=1
  currentwindow.selftimer-=1
 
 end 
end

function addtext(char,text,tim)
 text=text.." "--bug, ending with a space makes most lines work
	if not tim then
		tim=defaulttimer
	end
	--local c,t=char.prc,char
 local w={
 	tbx_color=char.c,
  tbx_char=char,
		tbx_counter=1,
		tbx_width=20, --characters not pixels
		tbx_lines={},
		tbx_cur_line=1,
		tbx_com_line=0,
 	tbx_x=25,
 	tbx_y=105,
 	tbx_col= 7,
 	tbx_text=text,
 	sprx=char.sprx,
 	spry=char.spry,
 	complete=false,
 	timer=tim,
 	selftimer=defselftimer,
 	sound=true
 }
 add(window,w)
end

function draw_ui()
	local sec_c,thir_c=0,0
	local _leftx,_rightx=0,114
	if ship.x>80 and xpad!=_leftx then
		if uixpad<14 then
			uixpad+=1
		end
		xpad+=2
		if xpad>=128 then
			xpad=-16
		end
	end
	
	if ship.x<40 and xpad!=_rightx then
		if uixpad>0 then
			uixpad-=1
		end
		--uixpad=0
		xpad-=2
		if xpad<=-16 then
			xpad=128
		end
	end
	

	local rect_xpad,rect_ypad=1,5
	local line_xpad,line_ypad=3,3

	for s in all (ships) do
		local lmin=xpad+line_xpad
		rect(xpad+rect_xpad,104,xpad+rect_ypad,126,7)
		--rect(xpad+rect_xpad+2,120-2*(s.hp),xpad+rect_ypad-2,124,s.prc)
		local mp=1.2
		if s.hp> 0 then
			if s.hp==1 then
				mp=1
			end
			line(lmin,124-(s.hp*mp),xpad+line_ypad,124,s.prc)	
		end
		rect_xpad+=4
		rect_ypad+=4
		line_xpad+=4
		line_ypad+=4
	end
	--hard coded for 100 hp lol
	for e in all(enemies) do
		if e.entity=="mb" or e.entity=="b" then
			if e.entity=="b" then
				--spr(204,e.x+8,e.y-36,2,2,false,false)
				--spr(204,e.x+8,e.y-26,2,2,false,false)
				local acc=6
				for i=1,3 do
						spr(204,e.x+8,e.y-acc,2,2,false,false)
						acc+=10
				end
				--spr(204,e.x+8,e.y-26,2,2,false,false)
				--spr(204,e.x+8,e.y-16,2,2,false,false)
			end
			rect(7+10,0,110,5,7)
			--if e.entity=="b" then
			--			rectfill2(9+10,2,100-10,2,2)
			--end
			local form=(e.hp)-(10)
			if e.entity=="b" then
				form=(e.hp/2)-(10)
			end
			rectfill2(9+10,2,form,2,e.prc)
			pout(enames[e.val-10],55,2,e.prc)
		end
	end
end
-->8
--gameplay and friends
--★


function explode(expx,expy,isblue)

 local myp={}
 myp.x=expx
 myp.y=expy
 
 myp.sx=0
 myp.sy=0
 
 myp.age=0
 myp.size=10
 myp.maxage=0
 myp.blue=isblue
 
 add(parts,myp)
	  
 for i=1,30 do
	 local myp={}
	 myp.x=expx
	 myp.y=expy
	 
	 myp.sx=rnd()*6-3
	 myp.sy=rnd()*6-3
	 
	 myp.age=rnd(2)
	 myp.size=1+rnd(4)
	 myp.maxage=10+rnd(10)
	 myp.blue=isblue
	 
	 add(parts,myp)
 end
 
 for i=1,20 do
	 local myp={}
	 myp.x=expx
	 myp.y=expy
	 
	 myp.sx=(rnd()-0.5)*10
	 myp.sy=(rnd()-0.5)*10
	 
	 myp.age=rnd(2)
	 myp.size=1+rnd(4)
	 myp.maxage=10+rnd(10)
	 myp.blue=isblue
	 myp.spark=true
	 
	 add(parts,myp)
 end
 
 --big_shwave(expx,expy)
 
end

function smol_shwave(shx,shy)
 local mysw={}
 mysw.x=shx
 mysw.y=shy
 mysw.r=3
 mysw.tr=6
 mysw.col=9
 mysw.speed=1
 add(shwaves,mysw)
end

function big_shwave(shx,shy)
 local mysw={}
 mysw.x=shx
 mysw.y=shy
 mysw.r=3
 mysw.tr=25
 mysw.col=7
 mysw.speed=3.5
 add(shwaves,mysw)
end

function smol_spark(sx,sy)
 --for i=1,2 do
 local myp={}
 myp.x=sx
 myp.y=sy
 
 myp.sx=(rnd()-0.5)*8
 myp.sy=(rnd()-1)*3
 
 myp.age=rnd(2)
 myp.size=1+rnd(4)
 myp.maxage=10+rnd(10)
 myp.blue=isblue
 myp.spark=true
 
 add(parts,myp)
 --end
end

function init_wavewarnings()
	--local _sh=rnd(ships)
	addtext(ship,"incoming!")
	if #enemies>0 then
		if wave==m_wave1 then
			addtext(ship,"gek-o is tough, but we can defeat him.")
			addtext(ship,"casey, don't let your brother get in your head.")
			addtext(ships[3], "doubt never crossed my mind!")
		elseif wave==m_wave2 then	
			addtext(ship,"the impenetrable shell!")
			addtext(ships[2],"reflexes will be our edge!")
			addtext(ships[2],"focus on his defensive strafe!")
		elseif wave==m_wave3 then
			addtext(ships[2],"oh no!")
			addtext(ships[3],"captin, you don't have to fight!")
			addtext(ship,"chomper!!! you were my friend!")
			addtext(ships[2],"he is gonna dive bomb us!")
			addtext(ships[3],"hopefully our calibrations hold!")
			addtext(enemies[1],"dover!")
			addtext(enemies[1],"time to die!")
		elseif wave==m_wave4 then
			addtext(ship,"cobra!!! it is time!")
			addtext(ships[3],"cobra, you will never beat us!")
			addtext(ship,"avenging my father is my personal vendetta!")
			addtext(ships[3],"let's save this galaxy!")
			addtext(ships[3],"watch for his tail! ")
			addtext(ships[3],"it may be his only weakness!")
		else
 		addtext(ship,"looks like "..#enemies.." enemies are approaching.")
 	end
 	addtext(ship,"protect the galaxy!")
	elseif #rings>0 then
		addtext(ship,"let's recalibrate our engines!")
	end
	--if _sh != ship and isactive(s) then
	--	random_msg(5,_sh)
	--end
end

--friends
function addfriend(_t,_x,_y)
	if #ships==3 then return end
	local _s,c,_posx,_posy,_sprx,_spry=1,12,54,54,0,96
--	if _t==1 then s,c=1,12, end
	if _t==2 then 
		_s,c,_sprx,_spry=32,14,16,96 
	end
	if _t==3 then 
		_s,c,_sprx,_spry=48,11,32,96 
	end
	
	local f=makespr("s",_t,_s)
		--★
		--f.spr=s
		f.posx=_x
		f.posy=_y
		f.x=200
		f.y=200
		f.hp=0
		f.maxhp=15
		f.mission="respawn"
		f.prc=c
		f.invul=0
		f.muzzle=0
		f.sprx=_sprx
		f.spry=_spry
		f.sfx={8,9,10}
		f.allowedmsgs={
			randommsg=true,
			warningmsg=true,
			othermsg=true,
			respawnmsg=true,
		}
		f.behaviortimer=300
		f.behaviormax=300
	add(ships,f)
	--test
	--random_msg(2,f)
	--★
	sfx(3,3)
	
	return f
end

function move(e)
	e.x+=e.sx
	e.y+=e.sy
end

function killenemy(e)
		--★★★
		local acc=1
		for s in all(ships) do
			if s.target and s.target==e then
				if s.allowedmsgs.randommsg then	
					random_msg(1,s)
					s.allowedmsgs.randommsg=false
				end
				s.target=nil
			end
		end
		if e.entity=="b" then
			window={}
			random_msg(10,e)
			for t in all(tail) do
				explode(t.x+4,t.y+4)
				del(tail,t)
			end
			acc=5
		elseif e.entity=="mb" then
			--explode(e.x+4,e.y+4)
			window={}
			acc=3
			random_msg(12,e)
		end
		del(enemies,e)
		sfx(2,2)
		score+=1
		multisplode(e,acc)
		--explode(e.x+4,e.y+4)
		changebehaviors()
end

function hurt(s)
	explode(s.x+4,s.y+4,true)
	s.hp-=1
	sfx(1,2)
	s.invul=60
	if s.hp<=0 then
			if s!=ship then
					big_shwave(s.x+4,s.y+4)
					smol_shwave(s.x+4,s.y+4)
					smol_spark(s.x+4,s.y+5)
					explode(s.x+4,s.y+4)
					s.mission="brb"
					s.posx=130
					s.posy=130
				else
					big_shwave(s.x+4,s.y+4)
					smol_shwave(s.x+4,s.y+4)
					smol_spark(s.x+4,s.y+5)
					lockout=t+30
					mode="over"
				end
	end
end

function follow_t(e,spd)
	if spd==nil then spd=1 end
	if e.sx==0 then
				e.sy=spd
				if e.target and e.target.y<=e.y then
					e.sy=0
					if e.target.x<e.x then
						e.sx=-(spd)
					else
						e.sx=spd
					end
				end
	end
end


function firetarget(e,_t)
	if e.wait<=0 and e.bultimer<=0 then	
		fire(e,0,2)
		--makebullet(e,_t)
		e.wait=30
		e.bultimer=60
	end
		e.bultimer-=1
		e.wait-=1
		e.behaviortimer-=1
end

function fire(e,ang,spd)
	local bs=7
	local sf=0
	local b=makespr(nil,nil,bs)
	b.x=e.x
	if e.entity=="s" then
		b.entity="b"
		b.spr=(3+e.val)--(3+e.val)
		b.y=e.y-6
		b.ani={b.spr}
 	b.sy=-spd
-- 	b.
	else
		b.entity="eb"
	 b.y=e.y+6
		sf=6
		b.colh=6
		b.colw=6
		b.ani={b.spr,b.spr+1,b.spr+2,b.spr+1}
		b.sx=sin(ang)*spd
 	b.sy=cos(ang)*spd
 	if e.entity=="b" then
 		b.x=e.x+12
 		b.y+=16
 	end
	--elseif e.entity=="b" then
	
	end
	b.anispd=0.5
	b.val=1
	b.aniframe=1
	if b.entity=="b" then
		add(buls,b)
	else
		add(ebuls,b)
	end
	e.muzzle=5
	e.bultimer=8
	e.flash=5
	sfx(sf,3)
end

function firespread(e,num,spd,base)
	if base==nil then
		base=0
	end
	 for i=1,num do
  fire(e,1/num*i+base,spd)
 end
end

function aimedfire(e,spd,acc)
	if acc==nil then acc=1 end
	local ang=atan2(e.target.y-e.y,e.target.x-e.x)
	for i=0,acc do
		fire(e,ang,spd)
	end
end

function activeships()
	local temp={}
	for s in all(ships) do
		if isactive(s) then
			add(temp,s)
		end
	end
	return rnd(temp)
end

function random_fire(e)
	
end

function strafe(e)
	local rdist,ldist=120,10
	if e.sx==0 then e.sx=-.5 end
	if e.val==14 then
		rdist=70
	end
	if e.x>=rdist then
			e.sx-=.5
	elseif e.x<=ldist then
			e.sx=.5
	end
	if e.y>50 then
		e.mission="protec"
	end
end

function tailatk(e)
	if #tail<=0 then return end
	--if e.target==nil then
	--	reset_tail(e)
	--end
	local _x=0 

	if e.taildir==0 then	
		_x=1
	else
		_x=-1
	end
	for t in all(tail) do
		t.x+=_x
	end
	if tail[1].x>100 then
		e.taildir=1
	elseif tail[1].x<=-20 then
		e.taildir=0
		reset_tail()
		if #rings<=0 then
			spawnring(1,20+rnd(100),0,2)
		end
	end
end

function reset_tail(e)
	local dest_y=60+rnd(40)
	for t in all(tail) do
		t.y=dest_y
	end
end

function retracttail(e)
	if #tail<=0 then return end
	if tail[1].x>=-20 then
		for t in all (tail) do
			t.x-=1
		end
	end
end
-->8
--waves
function spawnwave()
		local wavetype=1
		
		if wave%2==0 then
			wavetype=2
		end
		if wave==m_wave1 or wave==m_wave2 or wave==m_wave3 or wave==m_wave4 then
			if current_trk!=0 then
				music(-1,300)
				current_trk=0
				music(current_trk,6)
			end
			wavetype=3
		else
			if current_trk!=8 then
				music(-1,300)
				current_trk=8
				music(current_trk,6)
			end
		end
		
  place(wavetype,wave_enemies[wave])
  
end

function place(t,lvl)
	for y=1,#lvl do
		local l=lvl[y]
		for x=1,#l do
			if l[x]!=0 then
				if t==1 then
					spawnen(l[x],x*12-6,4+y*12,y*3)
				elseif t==3 then
					spawnen(l[x],54,20,30)
				else
					spawnring(l[x],x*12-6,4+y*12,y*6)
				end
			end
		end
	end
end


function nextwave(reset_wave)
	if not reset_wave then
		wave+=1
	else
		for s in all (ships) do
			s.hp=s.maxhp
		end
	end
	if wave==maxwave then return end
	mode="wavetext"
	for s in all (ships) do
		if isactive(s) then
			s.mission="flyin"
		end
	end
	ship.x=80
	ship.posy=80
		buls={}
	ebuls={}
	rings={}
	tail={}
	enemies={}
	spawnwave()

	init_wavewarnings()
	if wave==m_wave1 or wave==m_wave2 or wave==m_wave3 then
		random_msg(6,enemies[1])
	elseif wave==m_wave4 then
		random_msg(8,enemies[1])
	end
	--if wave==4 then
	--	random_msg(6,enemies[1])
	--end
	
end

function spawnen(_t,_x,_y,_w)
	local e=makespr("e",_t)
	e.sx=0
	e.sy=0
	e.wait=_w
	e.rev=false
	e.anispd=0.04
	e.x=_x
	e.y=_y-66
	e.posx=_x
	e.posy=_y
	e.mission="flyin"
	e.bultimer=60
	e.target=nil
	e.behaviormax=60
	if _t==nil or _t==1 then
		e.spr=64
		e.hp=3
		e.atkf=60/wave
	elseif _t==2 then
		e.spr=67
		e.hp=3
		e.atkf=90/wave
	elseif _t==3 then
		e.spr=70
		e.hp=4
		e.atkf=120/wave
	elseif _t==4 then
		e.spr=73
		e.hp=4
		e.atkf=60
	elseif _t==5 then
		e.spr=76
		e.hp=5
		e.atkf=120
	elseif _t==6	then
		e.spr=83
		e.hp=5
		e.atkf=120/wave
	elseif _t==7 then
		e.spr=86
		e.hp=6
		e.atkf=60
	elseif _t==8 then
		e.spr=89
		e.hp=6
		e.atkf=30
	elseif _t==9 then
		e.spr=92
		e.hp=7
		e.atkf=60
	elseif _t==10 then
		e.spr=108
		e.hp=7
		e.atkf=60
	elseif _t==11 then
		e.spr=80
		e.hp=100
		e.ani={80}
		e.atkf=15
		e.sprx=0
		e.spry=112
		e.entity="mb"
		e.prc=3
		e.behaviormax=100
	elseif _t==12 then
		e.spr=81
		e.hp=100
		e.ani={81}
		e.atkf=15
		e.sprx=16
		e.spry=112
		e.entity="mb"
		e.prc=4
		e.behaviormax=200
	elseif _t==13 then
		e.spr=82
		e.hp=100
		e.ani={82}
		e.atkf=30
		e.sprx=32
		e.spry=112
		e.entity="mb"
		e.prc=2
		e.behaviormax=60
	elseif _t==14 then
		e.spr=198
		e.hp=200
		e.ani={e.spr}
		e.atkf=60
		e.sprx=48
		e.posx=50
		e.sprx=96
		e.spry=112
		e.entity="b"
		e.prc=8
		e.sprw=4
		e.sprh=4
		e.colw=30
		e.colh=30
		e.dir=0
		e.behaviormax=300
		e.sfx={11}
		--e.tailwarning=true
		e.taildir=0
		tail={
		}
		local _tmp=add(tail,{x=-20,y=0,spr=234,colw=16,colh=16})
		for i=1,8 do
			add(tail,{x=_tmp.x-(i*16),y=_tmp.y,spr=202,colw=16,colh=16})
		end
		
	end
	
	if e.entity == "e" then
				e.ani={e.spr,e.spr+1,e.spr+2,e.spr+1}
	end
	
	add(enemies,e)	
end

function spawnring(_t,_x,_y,_w)
	
	local _s=128
	
	if _t==2 then
		_s=131
	end
	
	local r=makespr("r",_t)
		r.spr=_s--rings
		r.anispd=0.08
		r.posy=130
		r.x=_x
		r.y=_y
		r.wait=_w
		r.ani={_s,_s+1,_s+2}
		r.mission="ring"
	
	add(rings,r)
end

function doentity(e)
	if e.wait>0 then
				e.wait-=1
		return
	end
	if e.entity=="s" then
		doship(e)
		return
	elseif e.entity=="e" or e.entity=="mb" or e.entity=="b" then
		doenemy(e)
		return
	elseif e.entity=="r" then
		doring(e)
	end
end

function doship(e)
	e.behaviortimer-=1
	if e.mission=="flyin" then
			e.x+=((e.posx-e.x)/16)/2
			e.y+=((e.posy-e.y)/16)/2	
			if abs(e.y-e.posy)<0.7 then
				if e.val==1 then
					e.mission=""
					return
				end
				e.x=e.posx
				e.y=e.posy
				e.wait=5
				resetbehavior(e)
			end
	elseif e.mission=="protec" then
		if e.val==2 then
				e.x+=(((ship.x+12)-e.x)/16)/2
		elseif e.val==3 then
				e.x+=(((ship.x-12)-e.x)/16)/2
		end
				e.y+=(((ship.y+12)-e.y)/16)/2
	elseif e.mission=="attac" then
		if e.target==nil then
			e.mission="protec"
			resetbehavior(e)
			return
		end
		local tx_pad=4
		if e.val==3 then
			tx_pad=-4
		end
		--★??
		e.x+=(e.target.x-e.x+tx_pad)/7
		e.y+=(100-e.y-(e.val*2))/7
		firetarget(e,buls)
	elseif e.mission=="brb" then
		e.x+=(e.posx-e.x)/2
		e.y+=(e.posy-e.y)/2
		if e.allowedmsgs.respawnmsg then
			random_msg(4,e)
			e.allowedmsgs.respawnmsg=false
		end
		if abs(e.x-e.posx)<0.7 then
			e.mission="respawn"
		end
	elseif e.mission=="respawn" then
		e.hp+=rnd(2)
		e.wait=60
		if e.hp>=e.maxhp then
			e.hp=e.maxhp
			e.mission="flyin"
			e.allowedmsgs.respawnmsg=true
			e.allowedmsgs.randommsg=true
			e.allowedmsgs.warningmsg=true
			e.allowedmsgs.othermsg=true
			random_msg(2,e)
		end
	elseif e.mission=="wave" then
		
		--if e.x
	end
end

function doenemy(e)
    --bmanagement
    e.behaviortimer-=1
    if e.behaviortimer<= 0 and e.mission=="attac" then
        resetbehavior(e)
    end
    local _t=e.val
    local mission=e.mission
    --attack
    if mission=="attac" then
    --protec
        local mode=1
        local feq=1
        local follow=false
        local _ring=false
        if _t==1 then
            floatdown(e)
        elseif _t==2 or _t==3 or _t==7 then
            local spd=_t
            mode=2
            if _t==7 then
                spd=5
            end
            follow=true--follow_t(e,spd)
        elseif _t==4 then
            mode=2
        elseif _t==5 then
            feq=5
        elseif _t==6 then
            feq=8
            follow=true--follow_t(e)
        elseif _t==8 then
            feq=1
            mode=3
        elseif _t==9 then
            mode=2
            feq=2
        elseif _t==10 then
            mode=3
            feq=2
            strafe(e)
        elseif _t==11 then
            mode=1
            feq=2
            follow=false
            strafe(e)
        elseif _t==12 then
            mode=3
            strafe(e)
            _ring=true
        elseif _t==13 then
            mode=2
            follow=true
            _ring=true
        else
            mode=4
            feq=8
            _ring=true
        end
        if t%e.atkf==0 then
            if mode==1 then
             aimedfire(e,feq)
            elseif mode==2 then
             firespread(e,6,feq,time()/32)
            elseif mode==3 then
             firespread(e,4,feq,time()/8)
													firespread(e,8,feq,rnd())
            end
            if follow then
                follow_t(e)
            end
            if _ring and #rings<=0 then
                spawnring(1,20+rnd(100),0,2)
            end
            if _t==14 then
            	tailatk(e)
            end
        end
        if _t==14 then
        	strafe(e)
									if t%15==0 then
										firespread(e,feq,1,time()/8)
									--	tailatk(e)
									end
        end
    	if not inbounds(e) then	
						e.x,e.y,e.sx,e.sy,e.mission=e.posx,-25,0,0,"divein"
					end
    elseif mission=="protec" then
        if _t>=11 then
            if t%e.atkf==0 then
                if _t==14 then
                    firespread(e,16,1,time()/8)
                elseif _t==12 then
                    firespread(e,8,1,rnd())
                elseif _t==11 then
                    firetarget(e,8,8)
                else
                				--firetarget(e,16,8)
                   -- firespread(e,8,1,time()/16)
                    firespread(e,16,1,1)
                end
            end
            if _t==14 then
            	tailatk(e)
            end
        end
       if not inbounds(e) then	
								e.x,e.y,e.sx,e.sy,e.mission=e.posx,-25,0,0,"divein"
							end
    elseif mission=="divein" then
        if e.y<e.posy then
            e.y+=1
            if t%60==0 and e.entity!="e" then
                if _t==11 then
                    aimedfire(e,8,3)
                elseif _t==13 or _t==14 then
                    firespread(e,16,1,time()/8)
                    --firespread(e,16,1,time()/8)
                    --firespread(e,4,2,time()/16)
                end
            end
        elseif e.y==e.posy then
            if _t==14 then
                random_msg(8,e)
            end
            e.mission="attac"
        end
    --flyin
    else
    	e.x+=(e.posx-e.x)/7
  	  e.y+=(e.posy-e.y)/7
					if abs(e.y-e.posy)<0.7 and abs(e.y-e.posy)<0.7 then
       e.x,e.y=e.posx,e.posy
       e.mission="protec"
     end
    end
end

function floatdown(e)
	e.sy=1.5
	e.sx=sin(t/15)
	if e.x<32 then
		e.sx+=1-(e.x/32)
	end
	if e.x>88 then
		e.sx-=(e.x-88)/32
	end
end

function doring(e)
	if inbounds(e) then
		e.sy=.5
	else
		del(rings,e)
	end
end

function resetbehavior(e)
	e.behaviortimer=e.behaviormax
	e.mission="protec"
	if e.entity=="b" then
		random_msg(11,e)
	end
end


function draw_wavetext()
	draw_game()
end

function update_wavetext()
 update_game()
 if #window==0 then
 	mode="game"
	end
end


-->8
function random_msg(_t,_fri)
	local _msg=nil
	if _t==1 then
		_msg=rnd(msgs)
	elseif _t==2 then
		_msg=rnd(intros)
	elseif _t==3 then
		_msg=rnd(warnings)
	elseif _t==4 then
		_msg=rnd(respawns)
	elseif _t==5 then
		_msg=rnd(encourages)
	elseif _t==6 then
		_msg=rnd(enemymsgs)
	elseif _t==7 then
		_msg=rnd(enemykillmsgs)
	elseif _t==8 then
		_msg=rnd(cobramsgs)
	elseif _t==9 then
		_msg=rnd(cobraatkmsgs)
	elseif _t==10 then
		_msg=rnd(cobradeathmsgs)
	elseif _t==11 then
		_msg=rnd(cobratailmsgs)
	elseif _t==12 then
		_msg=rnd(enemydeathmsgs)
	end
	addtext(_fri,_msg)
end
-->8
function init_waves()
add(wave_enemies,
{--wave 1
	{0,1,1,1,1,1,1,1,1,0},
 {0,1,1,1,1,1,1,1,1,0},
 {0,1,1,1,1,1,1,1,1,0},
 {0,1,1,1,1,1,1,1,1,0}
}
)
add(wave_enemies,{--wave 2
	{0,0,0,1,0,0,1,0,0,0},
 {0,0,0,1,0,0,1,0,0,0},
 {0,0,0,1,0,0,1,0,0,0},
 {0,0,0,1,0,0,1,0,0,0}
})
add(wave_enemies,{--wave 3
 {1,1,2,2,1,1,2,2,1,1},
 {1,1,2,2,1,1,2,2,1,1},
 {1,1,2,2,2,2,2,2,1,1},
 {1,1,2,2,2,2,2,2,1,1}
})
add(wave_enemies,{--wave 4
	{0,2,0,1,2,2,1,0,2,0},
 {0,0,0,0,0,0,0,0,0,0},
 {0,0,0,0,0,0,0,0,0,0},
 {0,2,0,1,2,2,1,0,2,0}
})
add(wave_enemies,{--wave 5
	{4,0,0,0,0,0,0,0,0,4},
 {0,0,3,3,4,4,3,3,0,0},
 {0,0,3,3,4,4,3,3,0,0},
 {0,0,0,0,4,4,0,0,0,0}
})
add(wave_enemies,{--wave 6
	{0,2,0,1,2,2,1,0,2,0},
 {0,2,1,0,0,0,0,1,2,0},
 {0,2,1,0,0,0,0,1,2,0},
 {0,2,0,1,2,2,1,0,2,0}
})
add(wave_enemies,{--wave 7
	{11}
})
add(wave_enemies,{--wave 8
	{5,0,0,0,0,0,0,0,0,5},
 {5,0,6,1,5,5,1,6,0,5},
 {5,0,6,1,5,5,1,6,0,5},
 {5,0,0,0,0,0,0,0,0,5}
})
add(wave_enemies,{--wave 9
	{6,0,7,7,0,0,7,7,0,6},
 {0,2,1,0,2,2,0,1,2,0},
 {1,3,1,0,2,2,0,1,3,1},
 {6,0,7,7,0,0,7,7,0,6}
})
add(wave_enemies,{--wave 10
	{0,2,0,1,2,2,1,0,2,0},
 {1,2,1,2,0,0,2,1,2,1},
 {1,2,1,2,0,0,2,1,2,1},
 {0,2,0,1,2,2,1,0,2,0}
})
add(wave_enemies,{--wave 11
	{8,0,8,0,8,0,8,0,8,0},
 {0,9,0,9,0,9,0,9,0,9},
 {0,9,0,9,0,9,0,9,0,9},
 {8,0,8,0,8,0,8,0,8,0}
})
add(wave_enemies,{--wave 12
	{0,2,0,1,2,2,1,0,2,0},
 {1,2,1,2,0,0,2,1,2,1},
 {1,2,1,2,0,0,2,1,2,1},
 {0,2,0,1,2,2,1,0,2,0}
})
add(wave_enemies,{--wave 13
	{12}
})
add(wave_enemies,{--wave 14
	{0,2,0,1,2,2,1,0,2,0},
 {1,2,1,2,0,0,2,1,2,1},
 {1,2,1,2,0,0,2,1,2,1},
 {0,2,0,1,2,2,1,0,2,0}
})
add(wave_enemies,{--wave 15
	{8,10,7,10,5,5,10,7,10,8},
 {8,10,7,0,5,5,0,7,10,8},
 {8,10,6,0,4,4,0,6,10,8},
 {8,10,6,10,4,4,10,6,10,8}
})
add(wave_enemies,{--wave 16
	{0,2,0,1,2,2,1,0,2,0},
 {1,2,1,2,0,0,2,1,2,1},
 {1,2,1,2,0,0,2,1,2,1},
 {0,2,0,1,2,2,1,0,2,0}
})
add(wave_enemies,{--wave 17
	{13}
})
add(wave_enemies,{--wave 18
	{0,2,0,1,2,2,1,0,2,0},
 {1,2,1,2,0,0,2,1,2,1},
 {1,2,1,2,0,0,2,1,2,1},
 {0,2,0,1,2,2,1,0,2,0}
})
add(wave_enemies,{--wave 19
	{14}
})
end
__gfx__
0000000000066000006600000000660000000000000000000b0000b0000000000000000000000000000000000000000000000000000000000000000000000000
00000000000110000011000000001100c000000c0e0000e0b000000b000000000000000000000000000000000000000000000000000000000000000000000000
00700700600110066011006006001106c000000ce0e00e0e0b0000b0000880000009900000077000000000000000000000000000000000000000000000000000
00077000101661011166101001016611c000000c0e0000e0b000000b00899800009aa90000788700000000000000000000000000000000000000000000000000
00077000101aa10111aa10100101aa11c000000c000000000b0000b000899800009aa90000788700000000000000000000000000000000000000000000000000
00700700116116111611611001161161c000000c0e0000e0b000000b000880000009900000077000000000000000000000000000000000000000000000000000
0000000066c11c666c11c660066c11c6c000000ce0e00e0e0b0000b0000000000000000000000000000000000000000000000000000000000000000000000000
0000000000c66c000c66c000000c66c0000000000e0000e0b000000b000000000000000000000000000000000000000000000000000000000000000000000000
0000000090099009900aa009a00aa00a700770070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009009900990099009a00aa00a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000090099009a00aa00a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000090099009a00aa00a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000099000900990090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000900990090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000ee00000ee00000000ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00e22e000e22e000000e22e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00e22e000e22e000000e22e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e2ee2e0e2ee2e0000e2ee2e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e2aa2e0e2aa2e0000e2aa2e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e2e22e2eee22e2e00e2e22ee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eec88ceeec88cee00eec88ce00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00c66c000c66c000000c66c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088000008800000000880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00033000003300000000330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00033000003300000000330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00399300009930000003990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
033bb330033b33000033b33000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03bbbb3003bbb300003bbb3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03b00b3003b0b300003b0b3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0000c00c000c0000c000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000333000000000000000000000000000000000000000000000000000000000000555500005555000055550028000082280000822800008200000000
0033330003bbbb30003333005550055555500555550000550e0000e000e00e0000e00e0005666650056666500566665002822820028228200282282000000000
03bbbb300b3b3bb303bbbb30575005755750057557500575e0e00e0e0e0ee0e00e0ee0e0567dd765567dd765567dd765028ee820028ee820028ee82000000000
3bb3b3b33b3333b33bbbbbb39995599999955999999559990e0ee0e000e88e0000e88e00560dd065560dd065560dd065283ee382283ee382283ee38200000000
3b3333b3337777333bbbbbb3000550000005500000055000e008800e0e0870200e0870e056000065056006500056650002788720027887200278872000000000
337707333770777333b3b3b30059a5000059a500055555500e0870e000e00e0000e00e00056006500560065000566500202ee202002ee200002ee20000000000
03777730037777300333333005a9a9500555555000000000e000000e0e0000e000eeee0005600650005005000005500002022020020220200200002000000000
0033330000333300003333000555555000000000000000000ee00ee000eeee000000000000500500000000000000000000000000200000020022220000000000
00c66c00606006060050050008800880088008800000000000055000000550000005500000111100000110000001100098000089980000899800008900000000
60c33c064440044450800805089889808898898880088008005dd500005dd500005dd50001cccc10001cc1000011110009899890098998900989989000000000
33633633499449948e8ee8e8089779808990799888877888855dd55c005dd500c55dd5581c7887c101c77c1000711700098aa890098aa890098aa89000000000
303aa3034994499488877888089709808997799889907998005dd500855dd55c005dd5001c0880c101c88c1008811880983aa389983aa389983aa38900000000
33366333494444940e8cc8e0089779800897798008977980c55dd558005dd500855dd55c1c0000c1001001000011110009788790097887900978879000000000
30033003449999440e8cc8e000899800008998000089980000566500005665000056650001c00c100010010000111100909aa909009aa900009aa90000000000
300660030444444000e88e0000088000000880000008800000d70d0000d70d0000d07d0001c00c10000110000001100009099090090990900900009000000000
6000000600033000000ee00000000000000000000000000000055000000550000005500000100100000110000001100000000000900000090099990000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000222000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000222200028888200022220000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002888820082828820288882000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000028828282282222822888888200000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000028222282227777222888888200000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022770722277077722282828200000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002777720027777200222222000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000222200002222000022220000000000
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
00666600000660000006600000aaaa00000aa000000aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000
660000660660066000066000aa0000aa0aa00aa0000aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000
600000060600006000066000a000000a0a0000a0000aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000
660000660660066000066000aa0000aa0aa00aa0000aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000
00666600000660000006600000aaaa00000aa000000aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000055550000000099002222009900000666666666600000000000000000111100000000000000111111100111111100000111111000000000000000000000
000005777750000000aa92eeee29aa000065555dd555560000111110000111333311100001111100333331111113333300011333333110000000000000000000
0000565757750000009ad9eeee9da9000655555dd555556001993331111333333333311113339910333333111133333300133333333331000000000000000000
000576656557500000aa95e55e59aa0006dbbbbddbbbbd6013398833333333333333333333889331a93333311333339a01333333333333100000000000000000
00576666666675000099e5eeee5e99000ddb99bddb9abdd013399883333333333333333338899331a9a9333333339a9a01333333333333100000000000000000
0577666666667750002ee5e22e5ee20006db999bb99abd6013319811333111333311133311891331a9a9a93333a99a9a13333333333333310000000000000000
0576115661156750082eeee22eeee2800dd3b9a999ab3dd013331133331333133133313333113331a9a9a99339a99a9a13333333333333310000000000000000
0576151111516750088dddd22dddd880066039abb9a3066013333333113113333331131133333331a9a9a99339a99a9a13333333333333310000000000000000
5576151771516755008888d22d88880000003babb9b3000013333331331133333333113313333331a9a9a99339a99a9a13333333333333310000000000000000
57765117751167750028888228888200000003bbbb30000001311133333333111133333333111310a9a9a99339a99a9a13333333333333310000000000000000
577677777777677500028888888820000000033bb33000000131aa11133111999911133111aa1310a9a9a93333a99a9a13333333333333310000000000000000
55767700007577550002998dd8992000000003b38b3000000131aa99911999222299911999aa1310a9a9333333339a9a01333333333333100000000000000000
05775770077577500000aa9ee9aa00000000033b833000000131aa99777772222227777799aa1310a93333311333339a01333333333333100000000000000000
05577575575775500000999999990000000003b88b30000001331a9a7666722222276667a9a13310333333111133333300133333333331000000000000000000
005555755755550000000a9ee9a000000000038b8330000000131aa976667222222766679aa13100333331111113333300011333333110000000000000000000
00050558855050000000000aa00000000000033b3b30000000131aa976667222222766679aa13100111111100111111100000111111000000000000000000000
000000000000000000088000000880000000444400444400001331a9a76672222227667a9a133100111aaaa00000000000881110011188000000000000000000
0883300000033880000788b00b8870000044555544555544000131a9a76672222227667a9a13100011999aaa0000000001388331133883100000000000000000
33883bbbbbb388330007088bb8807000049946d65566d499000131a9a76722222222767a9a131000199999aaa0000000133aa833338aa3310000000000000000
377883bbbb3887730007073bb370700049994d61166d64990001331a9767222222227679a1331000a999999aaa00000013139783387931310000000000000000
3707833bb338707300077733337770004994d65115d66d4900001331976722222222767913310000a9a999999aa0000013111998899111310000000000000000
37773555555377730007770330770000499465544556d64900000131997782222228779913100000a9a99a9999aa000013177111111771310000000000000000
03335777777533300000bb3333bb0000494554477445556400000133197788222288779133100000a9a99a9999aaa00011176671176671110000000000000000
00a5777777775a000000333333330000444447787774445400000013198788888888789131000000a9a99a9999aaaa0011317678876713110000000000000000
00a5755555575a0000000b3773b0000044477878877777440000001319eee788887eee9131000000a9a99a9999aaaa0013137678876731310000000000000000
000a5bbbbbb5a000000053388335000040477888887877400000001319ee77eeee77ee9131000000a9a99a9999aaa0001113377ee77331110000000000000000
0000aabbbbaa00000555b933339b5550004788888888784000000013319e767ee767e91331000000a9a99a9999aa00000131377ee77313100000000000000000
00555abbbba555005dd6b993399b6d5500048eefeee88840000000013317667ee766713310000000a9a999999aa000000111137ee73111100000000000000000
00566aabbaa665005dd66bb99bb66dd50004eefeeee8884000000000133111799711133100000000a999999aaa0000000013311ee11331000000000000000000
005566abba6655005ddd66bbbb66ddd5004eeeeee7e8749400000000013333111133331000000000199999aaa000000000111131131111000000000000000000
6665565bb555566655ddd666666ddd55004eeeee777749940000000000111333333111000000000011999aaa0000000000013133331310000000000000000000
6666555555556666d55dddddddddd55d004eeee44444994000000000000001111110000000000000111aaaa00000000000013133331310000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000600
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60000000000000000000000000000000000000100000000000000000000000000000000000000000000000001000011000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000d000000000000000000000000000000000000000000000000000000000000000000000000100
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d00000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000600000000010000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000060000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000000100000000000000000000
0000000000000000000000000000000000000000000000000000000000000d000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000d0000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000
00000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000d00000000000000060000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000010000000000000000000000100000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000770077707070770077707000777007700770000077000770077000000000000000000000000000000000000000000
00000000000000000000000000000000000707070707070707007007000700070007000000070707070700000000000000000000000000000000000000000000
00000000000000000000000000000000000707077707070707007007000770077707770000070707070700000000000000000000000000000000000000000000
00000000000000060000000000000000000707070707070707007007000700000700070000070707070707000000000000000000000000000000000000000000
00000000000000000000000000000000000777070700770707007007770777077007700000077707700777000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000d00000000000000000000000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000d000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000
00000010000000000000000000000000000000000000555500000000990022220099000006666666666000000000000000001000000000000000000000000000
00000000000600000000000000000000000000000005777750000000aa92eeee29aa000065555dd5555600000000000000000000000000000000000000000000
000000000000000000000000000000000000000000565757750000009ad9eeee9da9000655555dd5555560000600000000000000000000000000000000000000
00000000000000000000000000000000000000000576656557500000aa95e55e59aa0006dbbbbddbbbbd60000000000000000000000000000000000000000000
00000000000d0000000000000000000000000000576666666675000099e5eeee5e99000ddb99bddb9abdd0000000000000000000000000000000000000000000
000000000000000000000000000000000000000577666666667750002ee5e22e5ee20006db999bb99abd60000000000000000000000000000000000000000000
000000000000000000000000000000000000000576115661156750082eeee22eeee2800dd3b9a999ab3dd000000000000000000000000000000000000d000000
00000000000000000000000000000000000000d576151111516750088dddd22dddd880066039abb9a30660000000000000000000000000000000000000000000
000000000000000000000006000000000000005576151771516755008888d22d88880000003babb9b30000000000000000000000000000000000000000000000
0000000000000000000000000000000000000057765117751167750028888228888200000003bbbb300000000000000000000000000000000000000000000000
00000000000000000000000000000000000000577677777777677500028888888820000000033bb3300000000000000000000000000000000000000000000000
0000000000000000000000000000000000000055767700007577550002998dd8992000000003b38b300000000000000000000000000000000000000000000000
0000000000000000100000000000000000000005775770077577500000aa9ee9aa00000000033b83300000000000000000000000000000000000000000000000
0000000000000000000000000000000000000005577575575775500000999999990000000003b88b300000000000000000000000000000000000000000000000
00000000000000000000000000000000000000005555755755550000000a9ee9a000000000038b83300000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000050558855050000000000aa0000000000d033b3b300000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000100000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000060000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000060006600000000000000ee00000000000000880000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000110000000000000e22e0000000000000330000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000d000600110060000d00000e22e0000000000000330000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000010166101000000000e2ee2e010000000003993000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000101aa101000000000e2aa2e000000000033bb3300000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000001161161100000000e2e22e2e0000000003bbbb300000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000066c11c6600000000eec88cee0000000003b00b300000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000c66c000000000000c66c00000000000c0000c00000000000000000000600000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d00000000000000000
00000000d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000d000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000007770777077700770077000000777770000007770077000000770777077707770777007000000000000000000000000000000000
00000000000000000000000007070707070007000700000007707077000000700707000007000070070707070070007000000000000010000000000000000000
00000000000000000000000007770770077007770777000007770777000000700707000007770070077707700070007000000000000000000000000000000000
00000000000000000000000007000707070000070007000007707077000000700707000100070070070707070070000000000000000000000000000000000000
00000000000000000000000007000707077707700770000000777770000000700770000007700070070707070070007000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000d000000
000000000000000000000000000000000000000000000000000000000000000000d0000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000077707770770077700000777070700000777070707770077077707770777007707070777077700770707070700000000000000000000000
00000000000000000077707070707070000000707070700000070070707000700070707770700070707070700070707000707070700000000000000000000000
00000000000000000070707770707077000000770077700000070077707700700077707070770070707070770077007000707077700000060000000000000000
00000000000000000070707070707070000000707000700000070070707000707070707070700070707770700070707070707000700060000000000000000000
00000000000000000070707070777077700000777077700000070070707770777070707070777077000700777070707770077077700000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d0000000000000000000000000000000000
0000000000000000000000000000000000000000000000d000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000060000000000000600000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000
00000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000001000000000000000000000
000000000000000000000000000d0000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000d00000000000000000000000000000000000000000
0000000000000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000

__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040408080800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010101010100000101000000000000010101010101000001010000000000000101010101010000000000000000000001010101010100000000
__sfx__
040100002b120231201f1201a12014120121200f1200b120091100711006110041100210001100011000010000100051000410004100031000210002100021000110001100011000010000100001000010000100
00030000000000053002130071300c1300d1300c1300913003120051200c1300e1300b13007130041300212000120001200000000000000000000000000000000000000000000000000000000000000000000000
000300000f55008550125501b550195500d55006550055501c540085500e55012550125500855001550075500b550015500a5500455003300023000230004300083000e3000b3000730005300033000330009100
00080000355502f5502c54028540215401e5401b5301753014530115300f5300d5200c5200a520095100851007510065100551005500045000450003500035000350003500035000350002500025000250001500
000300002d7302a730337303a73000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000024530215301d530265301c530000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01030000292201522023120221201b1202f1200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000212201b2200f2200822006210083100d3102a6202c6202f620306201f650206502155017550195501f5501e5500f100071000e100071000b100061000610006100000000000000000000000000000000
001000002f6102961030620160001a500170001a0000f6000d6000d6001d0001d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000002361020610236301110014000111001100010100110001a50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000176101f61022620101000b1000c10016100102000c2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000007650076400643006420086200761010500095000b5000f500115000c5000b50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
150a00000f260112600f260003001126011260112601126016260162601626016260162601626016260162600d2600f2600d26000000122601226012260000001726017260172601726017260172601726017260
150a0000112600f26016260162601226012260112601126000000000000000000000112600f260162601626012260122601126011260162601626017260172601226012260122601226012260122601226012260
150a0000112600f26016260162601226012260112601126000000000000000000000112600f260162601626012260122601126011260162601626017260172600f2600f2600f2600f2600f2600f2600f2600f260
150a00000f2600f2600d2600d2600f2600f2600d2600d26012260122601226012260122601226012260122600f2600f2600d2600d2600f2600f2600d2600d2601626016260162601626016260162601626016260
030a00000f2600f26000000000000f2600f2600a2600a2600f2600f26012260122600f2600f2600a2600a2600f2600f26012260122600f2600f26000000000000f2600f26000000000000f2600f2600000000000
010a00000f2600f26000000000000f2600f26000000000000f2600f26000000000000f2600f2600b2600b26000000000000b2600b2600f2600f26000000000000f2600f26000000000000f2600f2600000000000
010a00000f2600f26011260112601226112260142601426014260142601426014260142601426014260142601426014260142601426014260142601426014261122601226011261112600f2610f2600d2610d260
011000000f2600f2600f26011260112600f2600f2600f2600e2600e2600e2600f2600f2600e2600e2600e2601126011260112600f2600f2601126011260112601326013260132600f2600f260132601326013260
111000000f2500f2500d2500d2500f2500f25000000000000f2500f2500d2500d2500f2500f25000000000000f2500f2500d2500d2500f2500f25000000000000d2500d2500d2500d2500d2500d2500d2500d250
111000000f2500f250000000d2500d250000000f2500f25012250122501225012250122501225012250122500f2500f250000000d2500d250000000f2500f2501625016250162501625016250162501625016250
1110000014250142500000012250122500000014250142500f2500f2500f2500f2500f2500f2500f2500f25014250142500000012250122500000014250142500d2500d2500d2500d2500d2500d2500d2500d250
111000001625014250122500d2501625014250122500d2500f2500f2500f2500f2500f2500f2500f2500f2501625014250122500d2501625014250122500d2500d2500d2500d2500d2500d2500d2500d2500d250
111000000f2500f2500f2500f2500d2510d2500d2500d2500f2500f2500f2500f250122511225012250122500f2500f2500f2500f2500d2510d2500d2500d2500f2500f2500f2500f25014251142501425014250
391000001245000000124500000012450000001245000000124500000012450000001245000000144501245012450000001245000000124500000012450000001245000000124500000012450000001445016450
111000000f2500f250002000d2500d250002000f2500f25012250122501225012250122501225012250122500f2500f250002000d2500d250002000f2500f2500d2500d2500d2500d2500d2500d2500d2500d250
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 14544344
00 14585444
00 15585544
00 15585544
00 16595644
00 15585544
00 17595744
02 17574344
01 1d424344
00 22614344
00 1e424344
00 1e424344
00 1f424344
00 1e424344
00 1f424344
02 20424344


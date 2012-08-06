-- game.lua
-- the game class can have several states
-- using different draw, update functions

require 'Player.lua'
require 'Enemy.lua'
require 'Bomber.lua'

Game = Class(function(self)
	
	self.c = Camera(vector(0,0), 1, 0)
	self.cameraMoveSpeed = 200
	self.p = Player(self)
	self.playerDead = false
	self.bgImg = love.graphics.newImage("assets/images/background.png")
	
	self.introTimer = 5
	self.bigFont = love.graphics.newFont(30)
	love.graphics.setFont(self.bigFont)
	
	self.enemies = {}
	
	for i=1,6 do
		local p = vector((math.random()-0.5)*1200,(math.random()-0.5)*900)
		if p.x < 0 then
			p.x = p.x - 200
		else
			p.x = p.x + 200
		end
		if p.y < 0 then
			p.y = p.y - 200
		else
			p.y = p.y + 200
		end
		table.insert(self.enemies, Bomber(self, p ))
		table.insert(self.enemies, Enemy(self, -p, math.random(8)))
	end
	
	self.bombs = {}
	
	love.graphics.setBackgroundColor(255,255,255)
	-- scatter some eyes
	self.eyes = {}
	for i=1,1 do
		table.insert(self.eyes, Eye(nil,vector(math.random()*800-400,math.random()*600-300), self, math.random()*4+4))
	end
	
	--self.enemyStr = 1
	--self.enemyTimeout = 2
end)

function Game:update(dt)
	dt = math.min(dt, 0.1) -- min 10 fps
	
	self.introTimer = self.introTimer - dt
	
	local mp = vector(love.mouse:getPosition()) - vector(400,300) -- mouse coords on screen
	local pp = self.p:globalPos()
	
	-- try to put the center of the screen on the midpoint between the player and the mouse
	local t = (mp + self.p.p)/1.5
	self.c:translate(t - self.c.pos)
	
	-- if self.e.dead == true then
		-- self.enemyTimeout = self.enemyTimeout - dt
		-- if self.enemyTimeout < 0 then
			-- self.enemyTimout = 2
			-- local newX = -(self.p.p.x/math.abs(self.p.p.x))*200
			-- local newY = -(self.p.p.y/math.abs(self.p.p.y))*100
			-- self.enemyStr = self.enemyStr + 1
			-- self.e = Enemy(self, vector(newX, newY), self.enemyStr, (math.random()-0.5)*20+20*math.sqrt(self.enemyStr)+100, (math.random()-0.5)*20+20*self.enemyStr+150)
		-- end
	-- end
	for i,e in ipairs(self.enemies) do
		if self.playerDead then 
			e:idle(dt)
		else
			if #e.eyes == 0 then
				table.remove(self.enemies, i)
			else
				e:update(dt)
			end
		end
	end
	
	if self.playerDead then
		for i,e in ipairs(self.enemies) do
			for j,eye in ipairs(e.eyes) do
				eye.shooting = nil
			end
		end
	end
	
	
	self.p:update(dt)
	for i,eye in ipairs(self.eyes) do
		if eye.p:dist(self.p.p) < (self.p.size+eye.size) then
			eye.p = vector(0,0) --set the eye position to zero and then
			self.p:addEye(self, eye.size) -- insert the eye to teh player
			table.remove(self.eyes, i) -- remove from the list of eyes
			love.audio.play(Eye.blinkSound)
		end
	end
	if #self.eyes == 0 then
		for i=1,1 do
			--table.insert(self.eyes, Eye(nil,vector(math.random()*800-400,math.random()*600-300), self, math.random()*4+4))
		end
	end
	
	for i,b in ipairs(self.bombs) do
		b:update(dt)
	end
	
end

function Game:draw()
	self.c:predraw()
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(self.bgImg, -1600,-1600, 0, 8, 8)
	love.graphics.setColor(0,0,0,255)
	
	for i,e in ipairs(self.enemies) do
		e:draw()
	end
	
	for i,eye in ipairs(self.eyes) do
		eye:draw(nil, true)
	end
	
	for i,b in ipairs(self.bombs) do
		b:draw()
	end
	
	if not self.playerDead then
		self.p:draw()
	end
	
	self.c:postdraw()
	
	if self.playerDead then
		love.graphics.print("You are dead.",20,20)
	end
	
	if self.introTimer > 3 then
		love.graphics.setColor(0,0,0,255)
		love.graphics.print("Become the dominant creature", 20, 20)
		love.graphics.print("Your eyes are your greatest tool.", 20, 60)
	elseif self.introTimer > 0 then
		love.graphics.setColor(0,0,0,255*(self.introTimer/3))
		love.graphics.print("Become the dominant creature", 20, 20)
		love.graphics.print("Your eyes are your greatest tool.", 20, 60)
	end
	
	if #self.enemies == 0 then
		love.graphics.print("You are victorious... but what a", 20,20)
		love.graphics.print("hideous monster you have become.", 20,70)
	end
end

function Game:keyPressed(k)
	self.p:keyPressed(k)
end
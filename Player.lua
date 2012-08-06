-- player.lua
require 'Eye.lua'

Player = Class(function(self, g)
	Creature.construct(self, g, vector(0,0), 20)
	self.v = vector(0,0) -- velocity
	self.speed = 200 -- top speed
	self.drag = 6
	self.range = 125
	table.insert(self.eyes, Eye(self,vector(math.random(),math.random()), self.g, math.random()*4+4))
	self.firingSound = love.audio.newSource('assets/sounds/firing.ogg')
	self.firingSound:setLooping(true)
	self.firingSound:play() -- pre-start the firing sound
	self.firingSound:pause()
end)
Player:Inherit(Creature)

function Player:update(dt)
	-- update
	self:relaxEyes(dt)
	
	-- eye targeting
	-- works differently for player than enemies
	for i,eye in ipairs(self.eyes) do
		eye:update(dt) -- blink and/or die
		if eye.health < 0 then
			self:removeEye(eye)
		end
	end
	
	for i,eye in ipairs(self.eyes) do
		-- if any eye is within range of a player's eye, shoot it
		-- if we have a target already and it's in range, keep shooting it
		
		if eye.blind < 0 or (eye.shooting and -- if we have a target, but...
		((eye:globalPos()):dist(eye.shooting:globalPos()) > self.range or -- the target is out of range
		eye.shooting.health < 0)) then -- or the target is dead, then
			eye.shooting = nil -- stop shooting it.
		end
		
		for j,e in ipairs(self.g.enemies) do
			if eye.shooting == nil and eye.blind >= 0 and 
			self.p:dist(e.p) < self.size+e.size+self.range then -- player is not out of range 
				-- find the nearest target and shoot it
				local minD = 100000 -- arbitrary large number
				local target = nil
				for j,eye2 in ipairs(e.eyes) do
					d = (eye.p+self.p):dist(eye2.p+e.p)
					if d < minD then
						minD = d
						target = eye2
					end
				end
				eye.minD = minD
				if target and (minD < self.range) then
					eye.shooting = target
					break
				end
			end
		end
		
		eye:update(dt) -- blink and/or die
	end
	local numShooting = 0
	local totalHealth = 0
	for i,eye in ipairs(self.eyes) do
		if eye.shooting then
			numShooting = numShooting+1
			totalHealth = totalHealth + eye.shooting.health
		end
	end
	self.firingSound:setVolume(math.sqrt(numShooting))
	self.firingSound:setPitch(totalHealth / numShooting / 255)
	if numShooting > 0 then
		self.firingSound:resume()
	else
		self.firingSound:pause()
	end
	
	if #self.eyes < 1 then
		self.g.playerDead = true
	end
	
	-- apply drag forces
	self.v = self.v-self.v*self.drag*dt
	
	if love.mouse.isDown('l') then
		-- move towards the mouse
		local dmouse = self.g.c:mousepos()-self.p
		if dmouse:len() > self.size then
			self.v = dmouse:normalized()*self.speed
		end
	end
	
	self.p = self.p + self.v*dt
	self.size = 20+math.sqrt(#(self.eyes)/2)
end

function Player:draw()
	-- draw the boundaries
	love.graphics.setColor(255,0,0,80)
	love.graphics.circle("line", self.p.x, self.p.y, self.range, 64)
	-- draw the body
	love.graphics.setColor(255,255,255,255)
	love.graphics.circle("fill", self.p.x, self.p.y, self.size, 32)
	drawCircle(self.p,self.size)
	-- draw the eyes
	for i,eye in ipairs(self.eyes) do
		if eye.shooting then
			eye:draw(eye.shooting:globalPos())
		else
			eye:draw()
		end
	end
	for i,eye in ipairs(self.eyes) do
		local p = eye:globalPos()
		if eye.shooting then
			p2 = eye.shooting:globalPos()
			love.graphics.setColor(255,0,0,255)
			love.graphics.line(p.x, p.y, p2.x, p2.y)
		end
	end
end

function drawHair(p,dir,len)
	-- draw a hair
end

function Player:keyPressed(k)
	if k == 'i' then
		--table.insert(self.eyes, Eye(vector(0,0)));
		--love.audio.play(Eye.blinkSound)
	end
end
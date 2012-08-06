-- enemy.lua
-- an enemy has several eyes and moves sporadically

Enemy = Class(function(self, g, p, str, range, speed, sight)
	Creature.construct(self, g, p, str*5)
	self.range = range or 150
	self.speed = speed or 100
	self.sight = sight or 240 -- how far can it see
	self.drag = 2
	for i=1,str do
		Creature.addEye(self, g, math.sqrt(str)*math.random()*2+4)
	end
	self.v = vector(0,0)
	self.idleAngle = 0
	self.firingSound = love.audio.newSource('assets/sounds/firing.ogg')
	self.firingSound:setLooping(true)
	self.firingSound:play() -- pre-start the firing sound
	self.firingSound:pause()
	self.dead = false
end)
Enemy:Inherit(Creature)

function Enemy:idle(dt)
	-- like update but don't kill the player
	self:relaxEyes(dt)
	for i,eye in ipairs(self.eyes) do
		eye:update(dt) -- blink and/or die
	end
	self.v = self.v:normalized()*self.speed/2
	self.p = self.p + self.v:rotated(self.idleAngle)*dt
	if (self.g.playerDead == false) or self.idleAngle < math.pi then
		self.idleAngle = self.idleAngle + 1*dt
	end
end
	

function Enemy:update(dt)
	-- first, relax (spread evenly and rotate) the eyes
	self:relaxEyes(dt)
	
	if #(self.eyes) == 0 then
		if self.dead == false then
			self.dead = true
		end
		return
	end
	
	for i,eye in ipairs(self.eyes) do
		if eye.health < 0 and eye.dead == false then
			-- this eye just died, drop the eye
			table.insert(self.g.eyes, Eye(nil, eye:globalPos(), self.g, eye.size))
		end
		eye:update(dt) -- blink and/or die
		if eye.health < 0 then
			self:removeEye(eye)
		end
	end
	-- eye targeting
	for i,eye in ipairs(self.eyes) do
		-- if any eye is within range of a player's eye, shoot it
		-- if we have a target already and it's in range, keep shooting it
		
		if eye.blind < 0 or (eye.shooting and -- if we have a target, but...
		((eye.p+self.p):dist(eye.shooting.p+self.g.p.p) > self.range or -- the target is out of range
		eye.shooting.health < 0)) then -- or the target is dead, then
			eye.shooting = nil -- stop shooting it.
		end
		
		if eye.shooting == nil and eye.blind >= 0 and 
		self.p:dist(g.p.p) < self.size+self.g.p.size+self.range then -- player is not out of range 
			-- find the nearest target and shoot it
			local minD = 100000 -- arbitrary large number
			local target = nil
			for j,eye2 in ipairs(g.p.eyes) do
				d = (eye.p+self.p):dist(eye2.p+self.g.p.p)
				if d < minD then
					minD = d
					target = eye2
				end
			end
			eye.minD = minD
			if target and (minD < self.range) then
				eye.shooting = target
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
	
	
	local pDist = self.g.p.p - self.p -- distance to the player
	local force = 2*pDist -- total forces on the enemy
	
	if pDist:len() < (self.range+self.size+self.g.p.size-4) -- player is more than a few pixels within range
	or pDist:len() > self.sight+self.g.p.size then -- player is out of vision
		force = vector(self.speed/2,0):rotated(self.idleAngle)
		self.idleAngle = self.idleAngle + dt
	end
	force = force - self.v*self.drag -- apply drag force from velocity
	self.v = self.v + force*dt -- apply the force to the velocity
	if self.v:len() > self.speed then
		self.v = self.v:normalized()*self.speed -- the speed is limited
	end
	self.p = self.p + self.v*dt -- apply the velocity to the position
end


function Enemy:draw()
	if self.dead then
		return
	end
	-- draw the boundaries
	love.graphics.setColor(200,200,255,40)
	love.graphics.circle("fill", self.p.x, self.p.y, self.sight, 128)
	--love.graphics.setColor(255,255,255,255)
	--love.graphics.circle("fill", self.p.x, self.p.y, self.range, 64)
	love.graphics.setColor(255,0,0,20)
	love.graphics.circle("fill", self.p.x, self.p.y, self.range, 64)
	-- draw the body
	love.graphics.setColor(255,255,255,255)
	love.graphics.circle("fill", self.p.x, self.p.y, self.size, 32)
	drawCircle(self.p,self.size)
	-- draw the eyes
	for i,eye in ipairs(self.eyes) do
		local p = self.p+eye.p
		if self.p:dist(self.g.p.p) > self.sight+self.g.p.size then
			eye:draw(vector(-1000,-1000))
		else
			eye:draw(self.g.p.p)
		end
		--drawCircle(p+eye.force, 2)
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
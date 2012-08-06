-- Bomber.lua
-- an Bomber has one eye and large sight
-- Bombers launch ink bombs which blind eyes

require 'Bomb.lua'

Bomber = Class(function(self, g, p, speed, sight)
	Creature.construct(self, g, p, 15)
	self.speed = speed or 60
	self.sight = sight or 340 -- how far can it see
	self.drag = 2
	Creature.addEye(self, g, 10)
	self.v = vector(0,0)
	self.idleAngle = 0
	self.dead = false
	self.shootTime = 0
	self.shootDelay = 5
end)
Bomber:Inherit(Creature)

function Bomber:idle(dt)
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
	

function Bomber:update(dt)
	-- first, relax (spread evenly and rotate) the eyes
	self:relaxEyes(dt)
	
	self.shootTime = self.shootTime + dt -- how long it has been since i shot
	
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
		eye:update(dt) -- blink and/or die
	end
	
	-- targeting
	if self:globalPos():dist(self.g.p:globalPos()) < self.sight + self.g.p.size then
		if self.shootTime >= 0 then
			self:shootBomb()
			self.shootTime = -self.shootDelay
		end
	end
	
	
	local pDist = self.g.p.p - self.p -- distance to the player
	local force = 2*pDist -- total forces on the Bomber
	
	if pDist:len() > self.sight+self.g.p.size then -- player is out of vision
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

function Bomber:shootBomb()
	table.insert(self.g.bombs, Bomb(self.g, self:globalPos()))
	Bomb.launchSound:play()
end


function Bomber:draw()
	if self.dead then
		return
	end
	-- draw the boundaries
	love.graphics.setColor(200,200,255,40)
	love.graphics.circle("fill", self.p.x, self.p.y, self.sight, 128)
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
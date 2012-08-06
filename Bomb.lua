-- Bomb.lua
-- bombs are shot by bombers, and track towards the player til they either are in range or time out and explode

Bomb = Class(function(self,g,p)
	self.g = g
	self.p = p
	self.v = (self.g.p:globalPos() - self.p):rotated((math.random()-0.5)*math.pi):normalized()*50
	self.timer = 5
	self.thrust = 1000
	self.exploded = false
	self.explosionRadius = 60
	self.maxSpeed = 100
	
end)
Bomb.launchSound = love.audio.newSource('assets/sounds/launchBomb.ogg')
Bomb.explodeSound = love.audio.newSource('assets/sounds/bomb.ogg')

function Bomb:update(dt)
	self.timer = self.timer - dt
	
	if self.timer < -1 then
		for i,b in ipairs(self.g.bombs) do
			if b == self then
				table.remove(self.g.bombs)
				return
			end
		end
	end
	
	if self.timer < 0 or 
	(self.p:dist(self.g.p:globalPos())+self.g.p.size < self.explosionRadius+15) then
		if self.exploded == false then
			self.exploded = true
			self:explode()
		end
		return
	end
	
	local f = (self.g.p:globalPos() - self.p):normalized()*self.thrust
	self.v = self.v + f*dt
	if self.v:len() > self.maxSpeed then
		self.v = self.v:normalized()*self.maxSpeed
	end
	self.p = self.p + self.v*dt
end

function Bomb:explode()
	self.timer = 0
	Bomb.explodeSound:play()
	for i,eye in ipairs(self.g.p.eyes) do
		if eye:globalPos():dist(self.p) < self.explosionRadius then
			eye.blind = -5+math.random()
		end
	end
	for i,e in ipairs(self.g.enemies) do
		for i,eye in ipairs(e.eyes) do
			if eye:globalPos():dist(self.p) < self.explosionRadius then
				eye.blind = -5+math.random()
			end
		end
	end
			
end

function Bomb:draw()
	if self.exploded then
		love.graphics.setColor(0,0,0,255*(1+self.timer))
		love.graphics.circle('fill', self.p.x, self.p.y, self.explosionRadius, 64)
		--love.graphics.print("Range: "..self.p:dist(self.g.p:globalPos()) .. "explded".. self.timer, self.p.x+5, self.p.y+5)
	else
		love.graphics.setColor(0,0,0,255)
		love.graphics.circle('fill', self.p.x, self.p.y, 5)
		--love.graphics.print("Range: "..self.p:dist(self.g.p:globalPos()) .. " tracking " .. self.timer, self.p.x+5, self.p.y+5)
	end
end
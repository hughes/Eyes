-- Eye.lua
-- an Eye is a Node.

Eye = Class(function(self,parent,p,g,size)
	Node.construct(self, parent, p)
	self.g = g
	self.size = size or 5
	self.blinkTimeout = math.random(10)
	self.blinkDuration = math.random()*0.05+0.05
	self.blinking = false
	self.shooting = nil
	self.force = vector(0,0)
	self.health = 255
	self.dead = false
	self.blind = 0
end)
Eye:Inherit(Node)

Eye.blinkSounds = {love.audio.newSource('assets/sounds/blink.ogg'),
				   love.audio.newSource('assets/sounds/blink2.ogg'),
				   love.audio.newSource('assets/sounds/blink3.ogg')}
				   
Eye.blinkSound = Eye.blinkSounds[math.random(#Eye.blinkSounds)]

Eye.dieSound = love.audio.newSource('assets/sounds/die.ogg')

function Eye:update(dt)
	-- first of all: is this eye dead?
	if self.health < 0 then
		if self.dead == false then
			Eye.dieSound:play()
			self.dead = true
		end
		return
	end
	if self.blind < 0 then
		self.blind = self.blind + dt
		return
	end
	self.blinkTimeout = self.blinkTimeout - dt
	-- when the blinkTimeout expires, blink the eye
	if self.blinkTimeout < 0 then
		if self.blinking == false and self.parent == self.g.p then
			-- staring the blink, play the sound
			Eye.blinkSound:play()
			Eye.blinkSound = Eye.blinkSounds[math.random(#Eye.blinkSounds)]
		end
		self.blinking = true
		-- when the blinkTimeout gets blow the blinkDuration, stop blinking
		if self.blinkTimeout < -self.blinkDuration then
			self.blinkTimeout = math.random(10)
			self.blinkDuration = math.random()*0.05+0.05
			self.blinking = false
		end
	end
	if self.shooting then
		self.shooting.health = self.shooting.health - 20*dt
	end
end

function Eye:draw(target, isGreen)
	p = self:globalPos()
	local myTarget = target or g.c:mousepos()
	t = p+3*(myTarget-self:globalPos()):normalize_inplace() -- where should the eye look
	if isGreen then
		love.graphics.setColor(127,255,127,255) -- a dropped eye
	else
		love.graphics.setColor(255,math.max(self.health,0),math.max(self.health,0),255)
	end
	love.graphics.circle('fill', p.x, p.y, self.size, 32)
	drawCircle(p,self.size)
	
	if self.blinking or self.blind < 0 then
		-- draw the blinking eye
		love.graphics.setColor(0,0,0,255)
		love.graphics.circle('fill', p.x, p.y, self.size, 32)
	else
		drawCircle(t,math.floor(self.size/3))
		love.graphics.setColor(0,0,0,255)
		love.graphics.circle('fill', t.x, t.y,math.ceil(self.size/3))
	end
	
	--love.graphics.print("blind:"..self.blind, self:globalPos().x+10, self:globalPos().y+10)
end
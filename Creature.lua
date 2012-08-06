-- Creature.lua
-- Player is a creature. Enemy is a creature. they have common elements.

Creature = Class(function(self, g, p, size)
	Node.construct(self, nil, p)
	self.g = g
	self.size = size
	self.v = vector(0,0)
	self.eyes = {}
end)
Creature:Inherit(Node)

function Creature.addEye(self, g, size)
	-- initial eye position should have a random element to prevent locking / exploding
	local eye = Eye(self, vector((math.random()-0.5)*size*1.5, (math.random()-0.5)*size*1.5), self.g, size)
	table.insert(self.eyes, eye)
end

function Creature:removeEye(eye)
	for i,e in ipairs(self.eyes) do
		if e == eye then
			table.remove(self.eyes, i)
		end
	end
end

function Creature:relaxEyes(dt)
	for i,eye in ipairs(self.eyes) do
		-- eyes are repelled from each other when on the player
		-- but never leave the body
		-- calculate the total eye repulsion forces
		local force = vector(0,0)
		for j,eye2 in ipairs(self.eyes) do
			if eye ~= eye2 then
				local d = eye2.p-eye.p
				local dlen = d:len()
				if dlen < (eye.size+eye2.size) then
					force = force - (d:normalized())/dlen*5
				else
					force = force - (d:normalized())/dlen
				end
			end
		end
		force = force*100
		
		-- we never want to force the eye out of the body
		-- so if the position is greater than 
		--if eye.p:len2() > math.pow(self.size-7, 2) then
			force = force - eye.p*eye.p:len()/8
		--end
		if force:len2() > 1000 then
			force = force/force:len2() * 1000
		end
		eye.p = eye.p + force*dt
		eye.force = force
		lastForce = force
		eye.p:rotate_inplace(0.4*dt*eye.p:len()/self.size)
	end
end
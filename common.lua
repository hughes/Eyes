-- common requirements
require "hump/vector.lua"
require "hump/class.lua"
require "hump/camera.lua"
require "hump/timer.lua"

require "Node.lua"
require "Creature.lua"

function drawCircle(p,r)
	local segments = 32
	love.graphics.setColor(0,0,0,255)
	love.graphics.setLineWidth(1)
	-- circle drawing glitches when width is > 1
	-- so redraw the circles for now :(
	love.graphics.circle("line", p.x, p.y, r, segments)
	love.graphics.circle("line", p.x, p.y, r+0.5, segments)
	love.graphics.circle("line", p.x, p.y, r+1, segments)
	love.graphics.circle("line", p.x, p.y, r+1.5, segments)
	love.graphics.circle("line", p.x, p.y, r+2, segments)
end


function round(num, dec)
	local d = math.pow(10,dec)
	return math.floor(num*d)/d
end
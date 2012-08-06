require 'common.lua'
require 'Game.lua'

function love.load()
	-- load
	g = Game()
end

function love.update(dt)
	-- update
	g:update(dt)
end

function love.draw()
	-- draw
	g:draw()
end

function love.keypressed(k)
	if k=='escape' then
		love.event.push('q')
	end
	g:keyPressed(k)
end
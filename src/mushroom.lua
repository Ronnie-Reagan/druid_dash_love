-- player.lua
local Mushroom = {}
local const = require("src.utils.const")

function Mushroom.new(x, y)
	local self = {
		x = x,
		y = y,
		sprite = love.graphics.newImage("assets/sprites/player/mushroom.png"),
		animspeed = math.random() * 20
	}
	self.animtimer = self.animspeed

	function self:update()
		self.animspeed = self.animspeed - 1
		if self.animspeed <= 0 then
			self.animspeed = self.animtimer
		end
	end

	function self:draw()
		-- draw
		self.sprite:setFilter('nearest', 'nearest')
		love.graphics.draw(self.sprite, math.floor(self.x * const.TILE_GRID_SIZE + 0.5),
						   math.floor(self.y * const.TILE_GRID_SIZE + math.sin(self.animspeed / 10) + 0.5))
	end

	return self
end

return Mushroom

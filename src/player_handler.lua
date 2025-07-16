-- player.lua
local Player = {}
local const = require("src.utils.const")
local helpers = require("src.utils.helpers")
local debugger = require("debugger")
debugger.active = true

function Player.new(id, x, y)
    local self = {
        id = id,
        x = x,
        y = y,
        sprite = love.graphics.newImage("assets/sprites/player/dd_player.png"),
        direction = const.DIRECTION.NONE
    }

    -- why was this being defined every update loop lol
    function love.keypressed(key)
        if self.direction == const.DIRECTION.NONE then
            if key == "a" then
                self.direction = const.DIRECTION.LEFT
            elseif key == "d" then
                self.direction = const.DIRECTION.RIGHT
            elseif key == "w" then
                self.direction = const.DIRECTION.UP
            elseif key == "s" then
                self.direction = const.DIRECTION.DOWN
            elseif key == "left" then
                self.x = self.x - 1
            elseif key == "right" then
                self.x = self.x + 1
            elseif key == "up" then
                self.y = self.y - 1
            elseif key == "down" then
                self.y = self.y + 1
            end
        end
    end

    function self:update(dt)
        local x = self.x
        local y = self.y
        if self.direction ~= const.DIRECTION.NONE then

            x = x + const.DIRECTION_TABLE[self.direction][1]
            y = y + const.DIRECTION_TABLE[self.direction][2]
            -- check if we can step on a tile
            local new_tile = _G.map:get_tile(x, y, 1)
            if new_tile ~= nil then
                debugger.print(new_tile) -- this shouldnt be called
            end
            if new_tile ~= nil and
                not helpers.is_value_in_set(new_tile, const.WALL_TILES) and
                not helpers.is_value_in_set(new_tile, const.WATER_TILES) then
                debugger.print(string.format("moving from X:%d, Y:%d, to X:%d, Y:%d", self.x, self.y, x, y))
                self.x = x
                self.y = y
            else
                debugger.print(string.format("denied moving from X:%d, Y:%d, to X:%d, Y:%d", self.x, self.y, x, y))
                self.direction = const.DIRECTION.NONE
            end
        end
    end

    function self:draw()
        -- draw
        love.graphics.draw(self.sprite, self.x * const.TILE_GRID_SIZE, self.y * const.TILE_GRID_SIZE)
    end

    return self
end

return Player

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

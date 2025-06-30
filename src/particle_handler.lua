local particle_handler = {
    PARTICLE_TYPE = {
        DOT = 1, RECTANGLE = 2, CIRCLE = 3
    }
}
local color_handler = require "src.utils.color"


function particle_handler.new_particle(x, y, sx, sy, lifetime, color, type)
    local particle = {
        x = x,
        y = y,
        sx = sx,
        sy = sy,
        lifetime = lifetime,
        color = color,
        type = type or particle_handler.PARTICLE_TYPE.DOT
    }

    function particle:update(dt)
        self.lifetime = self.lifetime - 1
        self.x = self.x + self.sx
        self.y = self.y + self.sy
    end

    function particle:draw()
        if self.type == particle_handler.PARTICLE_TYPE.DOT then
            color_handler.set(color)
            love.graphics.rectangle("fill", self.x, self.y, 2, 2)
            color_handler.reset()
        end
    end

    return particle
end

return particle_handler
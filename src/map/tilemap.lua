local const = require "src.utils.const"
local mush_handler = require "src.mushroom"

function loadTileMap(path)
    local map = require(path)
    -- tell how big the tiles are
    -- these are all in tileseet

    map.quads = {}
    local tileset = map.tilesets[1]

    map.image = love.graphics.newImage(const.MAPFILE_PATH .. tileset.image)
    map.tileset = tileset
    map.pixel_width = map.width * tileset.tilewidth
    map.pixel_height = map.height * tileset.tileheight
    -- whole width of our tileset

    for y = 0, (tileset.imageheight / tileset.tileheight) - 1 do
        for x = 0, (tileset.imagewidth / tileset.tilewidth) - 1 do
            -- adding quads
            local quad = love.graphics.newQuad(x * tileset.tilewidth, y * tileset.tileheight, tileset.tilewidth,
                                               tileset.tileheight, tileset.imagewidth, tileset.imageheight)
            table.insert(map.quads, quad)
        end
    end

    function map:pre_proces()
        for i, layer in ipairs(self.layers) do
            for y = 0, layer.height - 1 do
                for x = 0, layer.width - 1 do
                    local index = (x + y * layer.width) + 1
                    local tileid = layer.data[index]
                    if tileid == 4 then
                        local mush = mush_handler.new(x, y)
                        table.insert(_G.mushrooms, mush)
                        layer.data[index] = 1
                    end
                end
            end
        end
    end

    function map:draw()
        for i, layer in ipairs(self.layers) do
            for y = 0, layer.height - 1 do
                for x = 0, layer.width - 1 do
                    local index = (x + y * layer.width) + 1
                    local tileid = layer.data[index]
                    if tileid ~= 0 then
                        local quad = self.quads[tileid]
                        local drawx = x * self.tileset.tilewidth
                        local drawy = y * self.tileset.tileheight

                        love.graphics.draw(self.image, quad, math.floor(drawx + 0.5), math.floor(drawy + 0.5))
                    end
                end
            end
        end
    end

    function map:get_tile(x, y, layer)
        local work_layer = self.layers[layer or 1]
        if x < 0 or y < 0 or x >= work_layer.width or y >= work_layer.height then
            return nil
        end
        local tile_index = (x + y * work_layer.width) + 1
        return work_layer.data[tile_index]
    end

    function map:set_tile(x, y, id, layer)
        local work_layer = self.layers[layer or 1]
        local tile_index = (x + y * work_layer.width) + 1
        work_layer.data[tile_index] = id
    end

    return map
end

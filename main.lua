io.stdout:setvbuf('no')

require "src.map.tilemap"
local color = require "src.utils.color"
local const = require "src.utils.const"
local player_hander = require "src.player_handler"
local particle_handler = require "src.particle_handler"
local helpers = require "src.utils.helpers"
local currentWidth

function love.load()
    math.randomseed(os.time())
    love.graphics.setDefaultFilter('nearest', 'nearest', 1)
    _G.font = love.graphics.newFont("assets/font/pico-mono.ttf")
    _G.font:setFilter("linear", "nearest")

    _G.mushrooms = {}
    _G.map = loadTileMap(const.TILEMAP_1_PATH)
    _G.map:pre_proces()

    local desktopWidth, desktopHeight = love.window.getDesktopDimensions()
    local maxScale = math.floor(math.min((desktopWidth * 0.9) / _G.map.pixel_width,
                                         (desktopHeight * 0.9) / _G.map.pixel_height))
    _G.scale = math.max(1, maxScale)
    local scaledWidth = _G.map.pixel_width * _G.scale
    local scaledHeight = _G.map.pixel_height * _G.scale

    love.window.setMode(scaledWidth, scaledHeight, {
        resizable = true,
        borderless = false,
        fullscreen = false
    })

    currentWidth = scaledWidth
    currentHeight = scaledHeight

    love.keyboard.setKeyRepeat(true)

    tickPeriod = 1 / 60
    accumulator = 0.0

    mushroom_collection = {}
    particle_collection = {}
    player = player_hander.new(1, 1, 1)
end

function love.resize(w, h)
    local newScale = math.max(1, math.floor(math.min(w / _G.map.pixel_width, h / _G.map.pixel_height)))
    _G.scale = newScale

    -- Snap window to nearest valid integer scale of map
    local scaledWidth = _G.map.pixel_width * _G.scale
    local scaledHeight = _G.map.pixel_height * _G.scale
    love.window.setMode(scaledWidth, scaledHeight, {
        resizable = true
    })

    currentWidth = math.max(scaledWidth, w - 400)
    print(currentWidth)
    currentHeight = scaledHeight
end

-- table to store mushrooms marked for removal (avoids modifying the class itself)
local mushToRemove = {}
local bounceBack = false -- bool for if should reverse directional movement due to off map bug

function love.update(dt)
    accumulator = accumulator + dt

    if accumulator >= tickPeriod then
        player:update(dt)
        -- add "dust" particle when player moves
        if player.direction ~= const.DIRECTION.NONE then
            handle_player_particle()
        end

        mushToRemove = {}

        for i = #_G.mushrooms, 1, -1 do
            local mush = _G.mushrooms[i]
            mush:update(dt)

            -- removing mushrooms in contact with the player
            if player.x == mush.x and player.y == mush.y then
                table.insert(mushToRemove, i)
            end
        end

        for i = #particle_collection, 1, -1 do
            local particle = particle_collection[i]
            particle:update()
            if particle.lifetime <= 0 then
                table.remove(particle_collection, i)
            end
        end

        -- after completing the current loop iteration, commence removal of the mushrooms
        for _, mushroomIndex in ipairs(mushToRemove) do
            table.remove(_G.mushrooms, mushroomIndex)
        end

        accumulator = accumulator - tickPeriod
    end
end

function love.draw()
    love.graphics.setFont(_G.font)
    love.graphics.scale(_G.scale, _G.scale)

    -- drawing the map
    _G.map:draw()

    for _, particle in ipairs(particle_collection) do
        particle:draw()
    end

    -- try to draw player
    player:draw()

    for _, m in ipairs(_G.mushrooms) do
        m:draw()
    end

    -- drawing the pos
    color.set(8) -- selected 8 for white, got red (9) instead
    local coordText = string.format("X:%d Y:%d", player.x, player.y)
    local textWidth = _G.font:getWidth(coordText)
    love.graphics.print(coordText, (_G.map.pixel_width - textWidth), 5)
    color.reset()
end

function handle_player_particle()
    for i = 1, 10 do
        local particle_direction_x = const.REVERSE_DIRECTION_TABLE[player.direction][1]
        local particle_direction_y = const.REVERSE_DIRECTION_TABLE[player.direction][2]
        local part = particle_handler.new_particle(player.x * const.TILE_GRID_SIZE + math.random(0, 16),
                                                   player.y * const.TILE_GRID_SIZE + const.TILE_GRID_SIZE,
                                                   math.random() *
                                                       (particle_direction_x > 0 and particle_direction_x or
                                                           math.random() * helpers.random_element_from({-1, 1})),
                                                   math.random() *
                                                       (particle_direction_y > 0 and particle_direction_y or
                                                           -math.random()), 10,
                                                   helpers.random_element_from({4, 5, 19, 20, 27}), 1)
        table.insert(particle_collection, part)
    end

    -- add "footprints"
    local part1 = particle_handler.new_particle(player.x * const.TILE_GRID_SIZE + 4,
                                                player.y * const.TILE_GRID_SIZE + const.TILE_GRID_SIZE - 2, 0, 0, 20,
                                                helpers.random_element_from({19}), 1)
    local part2 = particle_handler.new_particle(player.x * const.TILE_GRID_SIZE + 12,
                                                player.y * const.TILE_GRID_SIZE + const.TILE_GRID_SIZE - 4, 0, 0, 20,
                                                helpers.random_element_from({19}), 1)
    table.insert(particle_collection, part1)
    table.insert(particle_collection, part2)
end

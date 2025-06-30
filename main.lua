io.stdout:setvbuf('no')


require "src.map.tilemap"
local color = require "src.utils.color"
local const = require "src.utils.const"
local player_hander = require "src.player_handler"
local particle_handler = require "src.particle_handler"
local helpers = require "src.utils.helpers"

function love.load()
	math.randomseed( os.time() )
	love.graphics.setDefaultFilter('nearest','nearest', 1)
	_G.font = love.graphics.newFont("assets/font/pico-mono.ttf")
	_G.font:setFilter("linear", "nearest")

	--window = {translateX = 40, translateY = 40, scale = 1, width = 1920, height = 1080}
	--width, height = love.graphics.getDimensions ()
	--love.window.setMode (960, 548, {resizable=true, borderless=false})
	_G.map_index = 1
	load_map(map_index)
	love.keyboard.setKeyRepeat(true)
	
	tickPeriod = 1/60
	accumulator = 0.0

	
end

function load_map(index)
	_G.mushrooms = {}
	_G.map = loadTileMap(const.TILEMAP_1_PATH..index)
	player_positions = _G.map:pre_proces()
	particle_collection = {}
	player = player_hander.new(1, player_positions[1], player_positions[2])
end

function love.update(dt)
	accumulator = accumulator+dt

	if accumulator >= tickPeriod then
		player:update(dt)
		-- add "dust" particle when player moves
		if player.direction ~= const.DIRECTION.NONE then
			handle_player_particle()
		end
		
		for i=#_G.mushrooms, 1, -1 do
			local mush = _G.mushrooms[i]
			mush:update()
			if player.x == mush.x and player.y == mush.y then
				-- handle particles first then delete mush
				for i=1,10 do
					local particle = particle_handler.new_particle(
						mush.x * const.TILE_GRID_SIZE + const.TILE_GRID_SIZE/2,
						mush.y * const.TILE_GRID_SIZE,
						math.random() * helpers.random_element_from({-0.5,0.5}),
						-math.random(2),
						math.random(10) + 20,
						helpers.random_element_from({color.PICO_RED, color.PICO_WHITE, color.PICO_LIGHT_PEACH}),
						particle_handler.PARTICLE_TYPE.DOT
					)
					table.insert(particle_collection, particle)
				end
				
				table.remove(_G.mushrooms, i)
			end
		end

		-- change starting tile to be active portal once
		-- number  of mushroms is zero
		if #mushrooms == 0 then
			_G.map:set_tile(player_positions[1], player_positions[2], const.ACTIVE_PORTAL_TILE, 1)
		end

		for i=#particle_collection, 1, -1 do
			local particle = particle_collection[i]
			particle:update()
			if particle.lifetime <= 0 then
				table.remove(particle_collection, i)
			end
		end
		accumulator = accumulator - tickPeriod
	end
end




function love.draw()
	love.graphics.setFont(_G.font)
	love.graphics.scale(4,4)	

	-- drawing the map
	_G.map:draw()
	
	
	for _,particle in ipairs(particle_collection) do
		particle:draw()
	end

	-- try to draw player
	player:draw()

	for _,m in ipairs(_G.mushrooms) do
		m:draw()
	end


	-- drawing the random text
	color.set(1)
	love.graphics.print(player.x.." "..player.y, 0, 0)
	love.graphics.print(_G.map:get_tile(player.x, player.y, 1), 2, 16)
	color.reset()
	
end

function handle_player_particle()
	for i=1,10 do
		local particle_direction_x = const.REVERSE_DIRECTION_TABLE[player.direction][1]
		local particle_direction_y = const.REVERSE_DIRECTION_TABLE[player.direction][2]
		local part = particle_handler.new_particle(
			player.x*const.TILE_GRID_SIZE+math.random(0,16),
			player.y*const.TILE_GRID_SIZE+const.TILE_GRID_SIZE,
			math.random()*( particle_direction_x > 0 and particle_direction_x or math.random() * helpers.random_element_from({-1,1})),
			math.random()*( particle_direction_y > 0 and particle_direction_y or -math.random()),
			10,
			helpers.random_element_from({4,5,19,20, 27}),
			particle_handler.PARTICLE_TYPE.DOT
		)
		table.insert(particle_collection, part)
	end

	-- add "footprints"
	local part1 = particle_handler.new_particle(
			player.x*const.TILE_GRID_SIZE+4,
			player.y*const.TILE_GRID_SIZE+const.TILE_GRID_SIZE-2,
			0,
			0,
			20,
			helpers.random_element_from({19}),
			particle_handler.PARTICLE_TYPE.DOT
		)
	local part2 = particle_handler.new_particle(
			player.x*const.TILE_GRID_SIZE+12,
			player.y*const.TILE_GRID_SIZE+const.TILE_GRID_SIZE-4,
			0,
			0,
			20,
			helpers.random_element_from({19}),
			particle_handler.PARTICLE_TYPE.DOT
		)
	table.insert(particle_collection, part1)
	table.insert(particle_collection, part2)
end
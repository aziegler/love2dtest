local tiles = {}

local spriteSheet
local spriteBatch

local case_possible = 12
local case_attaque = 59


local map = {}
map.content = {}
map.overlay = {}
map.player_known = {{},{},{},{}}
map.sizeX = 20
map.sizeY = 15
map.posX = 0
map.posY = 0

local constants = {}
constants.spriteSheet = "assets/Tilesheet/medieval_tilesheet.png"
constants.tileSize = 64
constants.tileMargin = 32
constants.mapSize = 100
constants.spriteSheetColumn = 18
constants.fog = 40

local function load ()
	spriteSheet = love.graphics.newImage(constants.spriteSheet)
	love.window.setFullscreen(true)
	map.tilesCountX = math.floor(love.graphics.getWidth() / constants.tileSize)
	map.tilesCountY = math.floor(love.graphics.getHeight() / constants.tileSize)
	mapFile = io.open("assets/map.tmx", "r")
	local i = 0
	for line in mapFile:lines() do
		if not(line:match("<")) then
			local j = 0
			map.content[i] = {}
			map.overlay[i] = {}
			for player_idx = 1,4 do
				map.player_known[player_idx][i] = {}
			end
			for number in string.gmatch(line,"%d+") do 
				map.content[i][j] = {tileId = tonumber(number, 10)}
				map.overlay[i][j] = {}
				for player_idx = 1,4 do
					map.player_known[player_idx][i][j] = false
				end
				j = j + 1
			end
			i = i + 1
		end
	end
	spriteBatch = love.graphics.newSpriteBatch(spriteSheet,2 * map.tilesCountX * map.tilesCountY)
end

local function build_quad(tileNumber)
	local x = (tileNumber-1) % constants.spriteSheetColumn
	local y = math.floor(tileNumber / constants.spriteSheetColumn)
	return  love.graphics.newQuad(
		constants.tileMargin + x * ( constants.tileMargin + constants.tileSize), 
		constants.tileMargin + ( constants.tileMargin + constants.tileSize) * y, 
		constants.tileSize, 
		constants.tileSize,
		spriteSheet:getWidth(),
		spriteSheet:getHeight())
end

local function add_to_batch(x,y,tileNumber)
	if not(tileNumber) then
		return
	end
	if x < 0 or y < 0 or x >= map.tilesCountX or y >= map.tilesCountY then
		return
	end
	spriteBatch:add(build_quad (tileNumber),x * constants.tileSize, y * constants.tileSize)
end

local function get_tile_coordinates(x,y)
	local screen_x = x * constants.tileSize
	local screen_y = y * constants.tileSize
	return screen_x, screen_y
end

local function update(current_player,players,villages)
	spriteBatch:clear()
	for i = 0,map.tilesCountX  do
		for j = 0, map.tilesCountY do
			local relative_y = map.posY+j
			local relative_x = map.posX+i
			if(map.player_known[current_player.idx][relative_y][relative_x]) then
				add_to_batch(i,j,map.content[relative_y][relative_x].tileId)
				for key, tile in  pairs(map.overlay[relative_y][relative_x]) do
					add_to_batch(i,j,tile.tileId)
				end
			else 
				add_to_batch(i,j,constants.fog)
			end
		end
	end
	for idx,village in pairs(villages) do
		local relative_y = village.coord.x - map.posY
		local relative_x = village.coord.y - map.posX
		if(map.player_known[current_player.idx][relative_y][relative_x]) then
			add_to_batch(relative_x,relative_y,village.tile)
		end
	end
	for idx,player in pairs(players) do
		if player.placed then
			local relative_y = player.coord.x - map.posY
			local relative_x = player.coord.y - map.posX
			
			if player.moving then
				for i = -1,1 do
					for j = -1,1 do
						if not (i == 0) or not (j == 0) then
							local x_clique = player.coord.x - i
							local y_clique = player.coord.y - j
							local attaque = false
							for idx,player_2 in pairs(players) do
								if (player_2.coord.x == x_clique and player_2.coord.y == y_clique) then
									attaque = true
									break
								end
							end
							for idx,village in pairs(villages) do
								if (village.coord.x == x_clique and village.coord.y == y_clique) then
									attaque = true
									break
								end
							end
							if attaque then
								add_to_batch(relative_x - j, relative_y - i, case_attaque)
							else
								add_to_batch(relative_x - j, relative_y - i, case_possible)
							end
						end
					end
				end
			end
			if relative_x < map.tilesCountX and relative_x >= 0 and relative_y < map.tilesCountY and relative_y >= 0 then
				if(map.player_known[current_player.idx][relative_y][relative_x]) then
					add_to_batch(relative_x,relative_y,player.perso)
				end
			end
		end
	end
	spriteBatch:flush()
end

local function draw(current_player,players)
	love.graphics.draw(spriteBatch)
	for idx,player in pairs(players) do
		if player.placed and map.player_known[current_player.idx][player.coord.x][player.coord.y] then
			love.graphics.setColor(0, 0, 0)
			local x,y = get_tile_coordinates(player.coord.x,player.coord.y)
			print("X "..x.."Y "..y)
			love.graphics.print(player.pv.." ",y + 22,x - 3,0,1,1)
			love.graphics.setColor(255, 255, 255)
		end
	end
end

local function draw_exact_tile(x,y,tileNumber)
	love.graphics.draw(spriteSheet,build_quad ( tileNumber ), x * constants.tileSize, y * constants.tileSize)	
end

local function get_mouse_coordinates()
	local perso_y = math.floor(love.mouse.getY()/constants.tileSize)+map.posY
	local perso_x = math.floor(love.mouse.getX()/constants.tileSize)+map.posX
	return {x = perso_y, y = perso_x}
end


local function get_objects_at_mouse()
	coords = get_mouse_coordinates()
	return map.overlay[coords.x][coords.y]
end

local function insert_object(coords,tileId)
	table.insert(
			map.overlay[coords.x][coords.y],
			({tileId = tileId}))
end

local function put_object_at_mouse(tileId)
	local coords = get_mouse_coordinates()
	insert_object(coords,tileId)	
end

local function discover_around(coords,w,h,player)
	for i = -1 * w, 1 * w do
		for j = -1 * h, 1 * h do
			if not (map.player_known[player][coords.x + i] == nil) and not (map.player_known[player][coords.x + i][coords.y + j] == nil) then
				map.player_known[player][coords.x + i][coords.y + j] = true
			end
		end
	end
end

local function discover_at_mouse(w,h,player)
	local coords = get_mouse_coordinates()
	discover_around(coords,w,h,player)
end



local function move(dx,dy)
	map.posX = map.posX + dx
	map.posY = map.posY + dy
	map.posX = math.max(math.min(map.posX,constants.mapSize - map.tilesCountX -1),0)
	map.posY = math.max(math.min(map.posY,constants.mapSize - map.tilesCountY -1),0)
end

local function put_objects_around(x,y,tileId)
	for i = -1,1 do
		for j = -1,1 do
			if not (i == 0) or not (j == 0) then
				insert_object({x = x+i, y = y+j},tileId)
			end
		end
	end
end

local function remove(x,y,tileId)
	local objects = map.overlay[x][y]
	for idx,value in pairs(objects) do
		if value.tileId == tileId then
			table.remove(objects,idx)
		end
	end
end

local function remove_around(x,y,tileId)
	for i = -1,1 do
		for j = -1,1 do
			remove(x+i,y+j,tileId)
		end
	end
end

tiles.load = load
tiles.update = update
tiles.draw = draw
tiles.get_objects_at_mouse = get_objects_at_mouse
tiles.put_object_at_mouse = put_object_at_mouse
tiles.put_objects_around = put_objects_around
tiles.move = move
tiles.remove = remove
tiles.remove_around = remove_around
tiles.discover_at_mouse = discover_at_mouse
tiles.get_mouse_coordinates = get_mouse_coordinates

return tiles
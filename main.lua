
local spriteSheet
local spriteBatch
local map = {}
map.content = {}
map.overlay = {}
map.sizeX = 20
map.sizeY = 15
map.posX = 0
map.posY = 0

local currentTile = 1
local possibleTilesSize = 19
local possibleTiles = {15,16,17,18,33,34,35,36,51,52,53,54,113,114,115,116,117,118,119}

local constants = {}
constants.spriteSheet = "assets/Tilesheet/medieval_tilesheet.png"
constants.tileSize = 64
constants.tileMargin = 32
constants.mapSize = 100
constants.spriteSheetColumn = 18

function love.load()
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
			for number in string.gmatch(line,"%d+") do 
				map.content[i][j] = tonumber(number, 10)
				map.overlay[i][j] = -1
				j = j + 1
			end
			i = i + 1
		end
	end
	spriteBatch = love.graphics.newSpriteBatch(spriteSheet,2 * map.tilesCountX * map.tilesCountY)
end


function love.keypressed(key)
	if key == 'a' then
		currentTile = (currentTile % possibleTilesSize) + 1
	end
end

function love.update(dt)	
	if love.keyboard.isDown("d") then
		map.posX = math.min(map.posX + 1,constants.mapSize - map.tilesCountX -1)
	elseif love.keyboard.isDown("s") then
		map.posY = math.min(map.posY + 1,constants.mapSize - map.tilesCountY - 1)
	elseif love.keyboard.isDown("q") then
		map.posX = math.max(map.posX - 1,0)
	elseif love.keyboard.isDown("z") then 
		map.posY = math.max(map.posY - 1,0)
	end
	if(love.mouse.isDown(1)) then
		map.overlay[math.floor(love.mouse.getY()/constants.tileSize)+map.posY][math.floor(love.mouse.getX()/constants.tileSize)+map.posX] = possibleTiles[currentTile]
	end

	spriteBatch:clear()
	for i = 0,map.tilesCountX  do
		for j = 0, map.tilesCountY do
			local relative_y = map.posY+j
			local relative_x = map.posX+i
			add_to_batch(i,j,map.content[relative_y][relative_x])
			if map.overlay[relative_y][relative_x] > -1 then
				add_to_batch(i,j,map.overlay[relative_y][relative_x])
			end
		end
	end
	spriteBatch:flush()
end

function add_to_batch(x,y,tileNumber)
	if not(tileNumber) then
		return
	end
	if x < 0 or y < 0 or x >= map.tilesCountX or y >= map.tilesCountY then
		return
	end
	spriteBatch:add(build_quad (tileNumber),x * constants.tileSize, y * constants.tileSize)
end

function build_quad(tileNumber)
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

function draw_exact_tile(x,y,tileNumber)
	love.graphics.draw(spriteSheet,build_quad ( tileNumber ), x * constants.tileSize, y * constants.tileSize)	
end




function love.draw()
	love.graphics.draw(spriteBatch)
	draw_exact_tile(math.floor(love.mouse.getX()/constants.tileSize),math.floor(love.mouse.getY()/constants.tileSize),possibleTiles[currentTile])
end
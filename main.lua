
local spriteSheet
local map = {}
map.content = {}
map.overlay = {}
map.sizeX = 20
map.sizeY = 15
map.posX = 0
map.posY = 0

local currentTile = 1
local possibleTiles = {15,16,17,18}

local constants = {}
constants.spriteSheet = "assets/Tilesheet/medieval_tilesheet.png"
constants.tileSize = 64
constants.tileMargin = 32
constants.mapSize = 100
constants.spriteSheetHeight = 704
constants.spriteSheetWidth = 1760
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

end

function love.keypressed(key, scancode, isRepeat)
	if key == 'a' and not(isRepeat) then
		currentTile = (currentTile % 4) + 1
	end
end

function love.update()	
	if love.keyboard.isDown("z") then
		map.posX = math.min(map.posX + 1,constants.mapSize - map.tilesCountX -1)
	elseif love.keyboard.isDown("s") then
		map.posY = math.min(map.posY + 1,constants.mapSize - map.tilesCountY - 1)
	elseif love.keyboard.isDown("q") then
		map.posX = math.max(map.posX - 1,0)
	elseif love.keyboard.isDown("d") then 
		map.posY = math.max(map.posY - 1,0)
	end
	if(love.mouse.isDown(1)) then
		map.overlay[math.floor(love.mouse.getY()/constants.tileSize)][math.floor(love.mouse.getX()/constants.tileSize)] = possibleTiles[currentTile]
	end

end

function build_quad(x,y)
	return  love.graphics.newQuad(
		constants.tileMargin + x * ( constants.tileMargin + constants.tileSize), 
		constants.tileMargin + ( constants.tileMargin + constants.tileSize) * y, 
		constants.tileSize, 
		constants.tileSize,
		constants.spriteSheetWidth,
		constants.spriteSheetHeight)
end

function draw_exact_tile(x,y,tileNumber)
	love.graphics.draw(spriteSheet,build_quad ((tileNumber-1) % constants.spriteSheetColumn,math.floor(tileNumber / constants.spriteSheetColumn)), x * constants.tileSize, y * constants.tileSize)	
end

function draw_tile(x,y,tileNumber)
	if not(tileNumber) then
		return
	end
	if x < 0 or y < 0 or x >= map.tilesCountX or y >= map.tilesCountY then
		return
	end
	draw_exact_tile(x, y, tileNumber)
end

function love.draw()
	for i = 0,map.tilesCountX  do
		for j = 0, map.tilesCountY do
			local relative_y = map.posY+j
			local relative_x = map.posX+i
			draw_tile(i,j,map.content[relative_y][relative_x])
			if map.overlay[relative_y][relative_x] > -1 then
				draw_tile(i,j,map.overlay[relative_y][relative_x])
			end
		end
	end
	draw_exact_tile(math.floor(love.mouse.getX()/constants.tileSize),math.floor(love.mouse.getY()/constants.tileSize),possibleTiles[currentTile])
end 

local spriteSheet
local map = {}
map.content = {}
map.sizeX = 20
map.sizeY = 15
map.tileColumn = 18
map.tileSize = 126
map.posX = 0
map.posY = 0



function love.load()
	spriteSheet = love.graphics.newImage("assets/Tilesheet/medieval_tilesheet.png")
	love.window.setFullscreen(true)
	map.tilesCountX = math.floor(love.graphics.getWidth() / 64)
	map.tilesCountY = math.floor(love.graphics.getHeight() / 64)
	mapFile = io.open("assets/map.tmx", "r")
	local i = 0
	for line in mapFile:lines() do
		if not(line:match("<")) then
			local j = 0
			map.content[i] = {}
			for number in string.gmatch(line,"%d+") do 
				map.content[i][j] = tonumber(number, 10)
				j = j + 1
			end
			i = i + 1
		end
	end

end

function love.update()
	if love.keyboard.isDown("right") then
		map.posX = math.min(map.posX + 1,100 - map.tilesCountX -1)
	elseif love.keyboard.isDown("down") then
		map.posY = math.min(map.posY + 1,100 - map.tilesCountY - 1)
	elseif love.keyboard.isDown("left") then
		map.posX = math.max(map.posX - 1,0)
	elseif love.keyboard.isDown("up") then 
		map.posY = math.max(map.posY - 1,0)

	end
end

function build_quad(x,y)
	return  love.graphics.newQuad(32 + x * 96, 32 + 96 * y, 64, 64,1760,704)
end

function draw_tile(x,y,tileNumber)
	if not(tileNumber) then
		return
	end
	if x < 0 or y < 0 or x >= map.tilesCountX or y >= map.tilesCountY then
		return
	end
	love.graphics.draw(spriteSheet,build_quad ((tileNumber-1) % 18,math.floor(tileNumber / 18)), 64 * x,64 * y )
end

function love.draw()
	for i = 0,map.tilesCountX  do
		for j = 0, map.tilesCountY do
			draw_tile(i,j,map.content[map.posY+j][map.posX+i])
		end
	end
end
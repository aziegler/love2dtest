
local tiles = require("tileset")



local currentTile = 1
local possibleTilesSize = 5
local possibleTiles = {66,84,102,114,120}
local village = {113,115,114,118,117}
local nb_village = 10
local personnage = {66,84,102,120}



local players = {}
local villages = {}

local player = 1
local max_player = 4

local playing = true

local function create_player(tileId, index)
	table.insert(players,{perso = tileId, coord = nil, placed = false, moving = false, pv = 10, idx = index})
end

local function create_village()
	local x = love.math.random(1,15)
	local y = love.math.random(1,20)
	table.insert(villages,{tile = village[1],coord = {x = x, y = y},proprio = nil})
end

local function get_current_player()
	return players[player]
end

local function get_player_at(x,y)
	for idx,player_2 in pairs(players) do
		if (player_2.coord.x == x and player_2.coord.y == y) then
			return idx, player_2
		end
	end
	return nil
end

local function get_village_at(x,y)
	for idx,village in pairs(villages) do
		if (village.coord.x == x and village.coord.y == y) then
			return idx, village
		end
	end
	return nil
end


function love.load()
	for i = 1, max_player do
		create_player(personnage[i], i)
	end
	for i = 1, nb_village do
		create_village()
	end
	tiles.load()
end


function love.keypressed(key)
	if key == 'space' and not playing then
		player = (player % max_player) + 1
		if get_current_player() == nil then
			change_turn()
		end
		playing = true
	end
	if key =='escape' then
		love.event.quit()
	end
end

function change_turn()
	playing = false
end

function love.mousepressed(x,y,button)
	if not playing then
		return
	end
	if not get_current_player().placed then
		tiles.discover_at_mouse(2,2,get_current_player().idx)
		get_current_player().coord = tiles.get_mouse_coordinates()
		get_current_player().placed = true
		change_turn()
		return
	end

	local coord = tiles.get_mouse_coordinates()

	if get_current_player().moving then
		if math.abs(get_current_player().coord.x - coord.x) <= 1 and math.abs(get_current_player().coord.y - coord.y) <= 1 then
			local idx, joueur_attaque = get_player_at(coord.x, coord.y)
			local idx_village, village_attaque = get_village_at(coord.x, coord.y)
			if joueur_attaque and not (idx == player) then
				get_current_player().moving = false
				change_turn()
				joueur_attaque.pv = joueur_attaque.pv - 5
				if joueur_attaque.pv < 1 then
					table.remove (players, idx)
					max_player = max_player - 1
					if player > idx then
						player = player - 1				
					end
				end
				return
			elseif village_attaque then
				get_current_player().moving = false
				change_turn()
				village_attaque.tile = village[get_current_player().idx + 1]
				village_attaque.proprio = get_current_player().idx
			else
				tiles.discover_at_mouse(1,1,get_current_player().idx)
				get_current_player().coord = coord
				get_current_player().moving = false
				change_turn()
				return
			end
		end
	end

	if get_current_player().coord.x == coord.x and get_current_player().coord.y == coord.y then
		get_current_player().moving = true
		return
	end
end

function appartient(elt, tableau)
	for _, item in pairs(tableau) do
		if elt == item then
			return true
		end
	end
	return false
end

function love.update(dt)	
	--if love.keyboard.isDown("d") then
--		tiles.move(1,0)
--	elseif love.keyboard.isDown("s") then
--		tiles.move(0,1)
--	elseif love.keyboard.isDown("q") then
--		tiles.move(-1,0)
--	elseif love.keyboard.isDown("z") then 
--		tiles.move(0,-1)
--	end
	
	tiles.update(get_current_player(),players, villages)
end






function love.draw()
	tiles.draw(get_current_player(),players)
	love.graphics.setColor(0, 0, 0)
	if not playing then
		love.graphics.print("Appuyer sur Espace pour passer au joueur suivant...",
			love.graphics.getWidth( )/2 - 200,love.graphics.getHeight()/2,0,3,3)
	end
	love.graphics.setColor(255, 255, 255)
--	draw_exact_tile(math.floor(love.mouse.getX()/constants.tileSize),math.floor(love.mouse.getY()/constants.tileSize),possibleTiles[currentTile])
end
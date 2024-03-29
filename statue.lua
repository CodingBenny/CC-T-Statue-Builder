if turtle and turtle.getFuelLevel() < 6000 then
print("Computer says no")
sleep(3)
print("Refuel first")
return
end

local reqs = {
"https://raw.githubusercontent.com/DelusionalLogic/pngLua/master/30log.lua",
"https://raw.githubusercontent.com/DelusionalLogic/pngLua/master/stream.lua",
"https://raw.githubusercontent.com/DelusionalLogic/pngLua/master/deflate.lua",
"https://raw.githubusercontent.com/DelusionalLogic/pngLua/master/png.lua",
"https://raw.githubusercontent.com/iskolbin/lbase64/master/base64.lua",
"https://raw.githubusercontent.com/CodingBenny/CC-T-Statue-Builder/master/block_colours.lua",
"https://raw.githubusercontent.com/CodingBenny/CC-T-Statue-Builder/master/poses.lua",
}
local foldername = "lib_statue"

if not fs.exists(foldername) then
	fs.makeDir(foldername)
	for _,r in ipairs(reqs) do
		shell.run("wget",r,foldername.."/"..r:match("[^/]*$"))
	end
end

package.path = package.path..";"..foldername.."/?.lua"
require("png")
local base64 = require("base64")
local blocks = dofile(foldername.."/block_colours.lua")
local poses = dofile(foldername.."/poses.lua")

local args = {...}

if #args == 0 then
	print("statue <Name> [Pose] [Blocks...]")
	print("E.g.: statue Notch default .* -dirt")
	print("or: statue Notch default wool glass")
	write("Poses:")
	for i in pairs(poses) do write(" ") write(i) end
	print()
	return
end
local name = table.remove(args,1)
local size = tonumber(table.remove(args,1) or 1) or error("Invalid Size")
local pose = table.remove(args,1) or "default"
local settings_string = settings.get("statue.patterns", "terracotta -glazed concrete")
local patterns = args or {}
if #patterns == 0 then
	for m in string.gmatch( settings_string, "[^ \t]+" ) do
		table.insert( patterns, m )
	end
end

if not poses[pose] then print("No such pose") return end

local response,msg = http.get("https://api.mojang.com/users/profiles/minecraft/"..name)
if not response then printError(msg) return end

local player_data = textutils.unserializeJSON(response.readAll())
if not player_data then print("Player not found") return end
write("UUID: ")
print(player_data.id)

response,msg = http.get(
	"https://sessionserver.mojang.com/session/minecraft/profile/".. player_data.id)
if not response then printError(msg) return end
player_data = textutils.unserializeJSON(response.readAll())
local texture_url
for i,j in pairs(player_data.properties) do
	if type(j) == "table" and j.name == "textures" then
		player_data = textutils.unserializeJSON(base64.decode(j.value))
		break
	end
end
write("Name: ")
print(player_data.profileName)
if not player_data.textures.SKIN then print("That user has no custom skin") return end
response,msg = http.get(player_data.textures.SKIN.url, nil, true)
if not response then printError(msg) return end
write("Got texture")
local pngfile = fs.open(foldername .."/lastskin.png","wb")
pngfile.write(response.readAll())
pngfile.close()
local skin = pngImage(foldername .."/lastskin.png")
print(string.format(" with Size %dx%d",skin.width,skin.height))
local allowedBlocks = {
--Colors of the terminal
  black = { 25, 25, 25 },
  blue = { 51, 102, 204 },
  brown = { 127, 102, 76 },
  cyan = { 76, 153, 178 },
  gray = { 76, 76, 76 },
  green = { 87, 166, 78 },
  lightBlue = { 153, 178, 242 },
  lightGray = { 153, 153, 153 },
  lime = { 127, 204, 25 },
  magenta = { 229, 127, 216 },
  orange = { 242, 178, 51 },
  pink = { 242, 178, 204 },
  purple = { 178, 102, 229 },
  red = { 204, 76, 76 },
  white = { 240, 240, 240 },
  yellow = { 222, 222, 108 }
}

local function findBestBlock(x, y, asset)
	local skin = asset or skin
	if skin.height < y then return nil end
	local p = skin:getPixel(x,y)
	if p.A == 0 then return nil end
	local block, diff = nil, math.huge
	for i,j in pairs(allowedBlocks) do
		-- https://en.wikipedia.org/wiki/Color_difference
		local dr = (p.R+j[1])/2
		local r, g, b = p.R-j[1], p.G-j[2], p.B-j[3]
		local dc = (2 + dr / 256) * r * r +
			4 * g * g +
			(2 + (255 - dr) / 256) * b * b
		if dc < diff then
			block, diff = i, dc
		end
	end
	return block
end

for y=9,16 do
	for x=9,16 do
		local g = findBestBlock(x,y)
		term.setBackgroundColour(colors[g] or colors.black)
		write(" ")
	end
	term.setBackgroundColour(colors.black)
	print("")
end

allowedBlocks = {}
for _,p in ipairs(patterns) do
	local add = true
	if p:sub(1,1) == "-" then
		p = p:sub(2)
		add = false
	end
	for b in pairs(blocks) do
		if b:match(p) then
			allowedBlocks[b] =  add and blocks[b] or nil
		end
	end
end

local plan = {}
local maxHeight = 0

local function round(v)
	return vector.new(math.floor(v.x + 0.5),math.floor(v.y + 0.5),math.floor(v.z + 0.5))
end

local function setP(v, block)
	local w = round(v)
	if w.x > maxHeight then maxHeight = w.x end
	plan[w.x] = plan[w.x] or {}
	plan[w.x][w.y] = plan[w.x][w.y] or {}
	plan[w.x][w.y][w.z] = block
end

local function getP(v)
	local w = round(v)
	return plan[w.x] and plan[w.x][w.y] and plan[w.x][w.y][w.z]
end

local function mult(a,b)
	return vector.new(a.x*b.x, a.y*b.y, a.z*b.z)
end
local function gt(a,b) return a.x > b or a.y > b or a.z > b end

-- name, size, texture, overlay texture
local body_parts = {
{"right_leg",vector.new(12,4,4),{16,48},{0,48}},
{"left_leg",vector.new(12,4,4),{0,16},{0,32},flip=true},
{"upper_right_leg",vector.new(6,4,4),{16,48},{0,48}},
{"upper_left_leg",vector.new(6,4,4),{0,16},{0,32},flip=true},
{"lower_right_leg",vector.new(6,4,4),{16,54},{0,54}},
{"lower_left_leg",vector.new(6,4,4),{0,22},{0,38},flip=true},
{"right_arm_big",vector.new(12,4,4),{32,48},{48,48}},
{"left_arm_big",vector.new(12,4,4),{40,16},{40,32},flip=true},
{"upper_right_arm_big",vector.new(6,4,4),{32,48},{48,48}},
{"upper_left_arm_big",vector.new(6,4,4),{40,16},{40,32},flip=true},
{"lower_right_arm_big",vector.new(6,4,4),{32,54},{48,54}},
{"lower_left_arm_big",vector.new(6,4,4),{40,22},{40,38},flip=true},
{"torso",vector.new(12,4,8),{16,16},{16,32}},
{"head",vector.new(8,8,8),{0,0},{32,0}}
}
if player_data.textures.SKIN.metadata and 
  player_data.textures.SKIN.metadata.model == "slim" then
	for i,j in ipairs(body_parts) do
		if j[1]:match("big") then
			j[1] = j[1]:gsub("big","small")
			j[2].z = 3
		end
	end
end

if skin.height == 32 then
	for i=1,11,2 do
		body_parts[i][3] = body_parts[i+1][3]
	end
end

local sides = {
	--start corner        texil right          texil down   texture x y  overlay direction
	{vector.new(-1, 1,-1),vector.new( 0, 0, 1),vector.new( 0,-1, 0),2,0, vector.new(-1, 0, 0)}, --bottom
	{vector.new( 1, 1,-1),vector.new( 0, 0, 1),vector.new( 0,-1, 0),1,0, vector.new( 1, 0, 0)}, --top
	{vector.new( 1, 1,-1),vector.new( 0,-1, 0),vector.new(-1, 0, 0),0,1, vector.new( 0, 0,-1)}, --left (right cheek)
	{vector.new( 1,-1, 1),vector.new( 0, 1, 0),vector.new(-1, 0, 0),2,1, vector.new( 0, 0, 1)}, --right (left cheek)
	{vector.new( 1, 1, 1),vector.new( 0, 0,-1),vector.new(-1, 0, 0),3,1, vector.new( 0, 1, 0)}, --back
	{vector.new( 1,-1,-1),vector.new( 0, 0, 1),vector.new(-1, 0, 0),1,1, vector.new( 0,-1, 0)}, --front
}

local function tOffset(side, part)
	local size = part[2]
	local dy = 1
	if side == sides[1] and part[1]:match("upper") then dy = 7 end
	if side == sides[1] and part[1]:match("lower") then dy = -5 end
	if side[4] >= 2 then
		return size.z+size.y*(side[4]-1)+1,side[5]*size.y+dy
	end
	return size.y*side[4]+1,side[5]*size.y+dy
end

local function rotate(p, r)
	if r then
		if r[1] ~= 0 then p=vector.new(p.x, p.y*math.cos(r[1])-p.z*math.sin(r[1]), p.y*math.sin(r[1]) + p.z*math.cos(r[1])) end
		if r[2] ~= 0 then p=vector.new(p.x*math.cos(r[2])-p.z*math.sin(r[2]),p.y, p.x*math.sin(r[2]) + p.z*math.cos(r[2])) end
		if r[3] ~= 0 then p=vector.new(p.x*math.cos(r[3])+p.y*math.sin(r[3]), -p.x*math.sin(r[3]) + p.y*math.cos(r[3]), p.z) end
	end
	return p
end

local one = vector.new(1,1,1)
local flip_vector = vector.new(1,1,-1)

local function planCube(part, polish)
	local pose = poses[pose][part[1]] or poses[pose][part[1]:gsub("small","big")]
	if not pose then return end
	local off_center = rotate(part[2],pose[2])*size
	off_center = (vector.new(math.abs(off_center.x),math.abs(off_center.y),math.abs(off_center.z))-one)/2
	local center = vector.new(unpack(pose[1]))*size+off_center
	local flip = (skin.height == 32) and part.flip and not polish
	for i=1,#sides do
		local s = sides[i]
		local optional_flip = flip and flip_vector or one
		local right = rotate(mult(s[2],optional_flip),pose[2])
		local down = rotate(mult(s[3],optional_flip),pose[2])
		local start_corner = mult(off_center, rotate(mult(s[1],optional_flip),pose[2])) + center
		local overlay_direction = rotate(mult(s[6],optional_flip),pose[2])
		local texture_width = math.abs(s[2]:dot(part[2]))*size-1
		local texture_height = math.abs(s[3]:dot(part[2]))*size-1
		local sx,sy = tOffset(s, part)
		for x=0,texture_width do
			for y=0,texture_height do
				local p = start_corner + (right*x)+(down*y)
				local op = p+overlay_direction
				if not polish then
					local oblock = findBestBlock(sx+part[4][1]+math.floor(x/size),sy+part[4][2]+math.floor(y/size))
					if not flip and oblock then
						setP(op,oblock)
					else
						local block = findBestBlock(sx+part[3][1]+math.floor(x/size),sy+part[3][2]+math.floor(y/size))
						if block then
							setP(p,block)
						end
					end
				else
					if getP(op) and
						(x ~= 0 or getP(p-right)) and
						(x ~= texture_width or getP(p+right)) and
						(y ~= 0 or getP(p-down)) and
						(y ~= texture_height or getP(p+down)) then
							setP(p,"removed")
					end
				end
			end
		end
		sleep(0.05)
	end
end

local function planAsset(asset)
	local response,msg = http.get(asset[1], nil, true)
	if not response then printError(msg) return end
	local pngfile = fs.open(foldername .."/lastskin.png","wb")
	pngfile.write(response.readAll())
	pngfile.close()
	local asset_png = pngImage(foldername .. "/lastskin.png")
	local lfl_Corner = vector.new(unpack(asset[2]))*size
	local up = rotate(vector.new(1,0,0),asset[3])
	local right = rotate(vector.new(0,0,1),asset[3])
	for x=1,asset_png.width*size do
		for y=1,asset_png.height*size do
			local block = findBestBlock(math.ceil(x/size),math.ceil(y/size),asset_png)
			if block then
				setP(lfl_Corner+right*(x-1)+ up*(asset_png.height*size-y),block)
			end
		end
	end
end

local pos = vector.new(0,0,0)
local facing = vector.new(0,1,0)
local up = vector.new(1,0,0)

local aborted = false
local function checkAborted()
	if aborted then
		aborted = false
		error("Aborted", 0)
		return
	end
end

local function face(f)
	if up:cross(facing) == f then
		facing=f
		turtle.turnRight()
	end
	while f ~= facing do
		facing=facing:cross(up)
		turtle.turnLeft()
	end
end

local function goTo(tpos)
	while tpos.x > pos.x do
		checkAborted()
		if turtle.up() then
			pos.x=pos.x+1
		end
	end
	local movDir = vector.new(0,1,0)
	for i=1,4 do
		local n = mult(tpos-pos,movDir)
		if gt(n,0) then
			n = n:length()
			face(movDir)
			for j=1,n do
				repeat checkAborted() until turtle.forward()
			end
			pos=pos+(movDir*n)
		end
		movDir=movDir:cross(up)
	end
	while tpos.x < pos.x do
		checkAborted()
		if turtle.down() then
			pos.x=pos.x-1
		end
	end
end

--put blocks generously
for _,j in ipairs(body_parts) do
	planCube(j)
end

if poses[pose].assets then
	for _,j in ipairs(poses[pose].assets) do
		planAsset(j)
	end
end

--assuming the groud is flat
local blocksUnderneath = turtle and turtle.detectDown()
plan[-1] = nil
if blocksUnderneath then
	for m,j in pairs(plan[0] or {}) do
		for k,l in pairs(j) do
			setP(vector.new(-1,m,k),"removed")
		end
	end
end

--cut corners literally
for _,j in ipairs(body_parts) do
	planCube(j, true)
end

local gravity_blocks = {
	sand=true, gravel=true,
	purple_concrete_powder = true,
    cyan_concrete_powder = true,
    white_concrete_powder = true,
    yellow_concrete_powder = true,
    green_concrete_powder = true,
    orange_concrete_powder = true,
    pink_concrete_powder = true,
    black_concrete_powder = true,
    blue_concrete_powder = true,
    light_blue_concrete_powder = true,
    brown_concrete_powder = true,
    gray_concrete_powder = true,
    red_concrete_powder = true,
    magenta_concrete_powder = true,
    lime_concrete_powder = true,
    light_gray_concrete_powder = true,}


for n,i in pairs(plan) do
	for m,j in pairs(i) do
		for k,l in pairs(j) do
			if l == "removed" then
				j[k] = nil
			end
			if gravity_blocks[l] then
				local p = vector.new(n-1,m,k)
				if not getP(p) then setP(p,"string") end
			end
		end
	end
end

local function countItems(last_section)
	local items = last_section.rest_items or {}
	local rest_items = {}
	local used_slots = 0
	local minLayer = last_section.maxLayer or -2
	local isFull = false
	for i,j in pairs(items) do
		while j > 0 do
			if not isFull then
				used_slots=used_slots+1
				j=j-64
				if used_slots == 16 - settings.get("statue.reservedSlots", 0) then
					isFull = true
				end
			else
				items[i] = items[i] - j
				rest_items[i] = j
				if items[i] == 0 then
					items[i] = nil
				end
			end
		end
	end
	if isFull then
		return {items=items,rest_items=rest_items,used_slots=used_slots,minLayer=minLayer,maxLayer=minLayer}
	end
	for i=minLayer+1,maxHeight do
		for _,j in pairs(plan[i] or {}) do
			for _,k in pairs(j) do
				if used_slots < 16 - settings.get("statue.reservedSlots", 0) or (items[k] and items[k] % 64 ~= 0) then
					items[k] = items[k] and items[k]+1 or 1
					if items[k] % 64 == 1 then
						used_slots=used_slots+1
					end
				else
					rest_items[k] = rest_items[k] and rest_items[k]+1 or 1
					isFull = true
				end
			end
		end
		if isFull then
			return {items=items,rest_items=rest_items,used_slots=used_slots,minLayer=minLayer,maxLayer=i}
		end
	end
	return {items=items,rest_items=rest_items,used_slots=used_slots,minLayer=minLayer,maxLayer=maxHeight}
end

local function checkItems(section)
	local hasItems = {}
	for i=1,16 do
		local s = turtle.getItemDetail(i)
		if s then
			local name = s.name:match(":(.*)")
			hasItems[name] = hasItems[name] and hasItems[name]+s.count or s.count
		end
	end
	term.clear()
	term.setCursorPos(1,1)
	print(string.format("Items for layers %d-%d:",section.minLayer+2,section.maxLayer+2))
	local hasAll = true
	for block,count in pairs(section.items) do
		if not hasItems[block] or count-hasItems[block] ~= 0 then
			print(string.format("%6dx %s",hasItems[block] and count-hasItems[block] or count,block))
			if not hasItems[block] or hasItems[block] < count then
				hasAll = false
			end
		end
	end
	term.setTextColor(term.isColor() and colors.red or colors.lightGray)
	for block,count in pairs(hasItems) do
		if not section.items[block] then
			print(string.format("%6dx %s",-hasItems[block],block))
		end
	end
	term.setTextColor(colors.white)
	return hasAll
end

local function waitForItems(section)
	while not checkItems(section) do
		os.pullEvent("turtle_inventory")
	end
	term.clear()
	term.setCursorPos(1,1)
	print("Work Work")
end

getmetatable(pos).__eq = function (a,b) return a.x == b.x and a.y == b.y and a.z == b.z end

local function getSlot(block)
	for i=1,16 do
		local s = turtle.getItemDetail(i)
		if s and s.name:match(":"..block.."$") then
			return i
		end
	end
	return nil
end

local function findClosest(layer)
	local movDir = vector.new(0,1,0)
	local closest = vector.new(layer, pos.y, pos.z)
	if getP(closest) then return closest end --after moving up
	for i=1,4 do
		local n = closest + movDir
		if getP(n) and getSlot(getP(n)) then
			return n
		end
		movDir=movDir:cross(up)
	end
	local ry, rz, diff = nil, nil, 1000000
	for i,j in pairs(plan[layer] or {}) do
		for k,l in pairs(j) do
			local y, z = pos.y-i, pos.z-k
			if y*y + z*z < diff and getSlot(l) then
				ry, rz, diff = i, k, y*y + z*z
			end
		end
	end
	if not ry then return false end
	return vector.new(layer,ry,rz)
end
local zero = vector.new()

print("Press t to abort")

local currentSection
local nextSection
local currentLayer

local function build()
	local resuming = false
	if fs.exists("statue_progress") then
		local save = dofile("statue_progress")
		plan = save.plan
		currentSection = save.currentSection
		nextSection = save.nextSection
		resuming = true
		fs.delete("statue_progress")
	else
		currentSection = countItems({})
		if type(_G.smeltNextItems) == "function" then
			_G.smeltNextItems(currentSection.items)
		end
	end
	repeat
		if not resuming then
			nextSection = countItems(currentSection)
			if settings.get("statue.returnForItems", true) then
				goTo(zero)
				face(vector.new(0,1,0))
			end
			if type(_G.gatherItems) == "function" then
				parallel.waitForAll(function () waitForItems(currentSection) end, function() _G.gatherItems(currentSection.items) end)
			else
				waitForItems(currentSection)
			end
			if type(_G.smeltNextItems) == "function" and next(nextSection.items) then
				_G.smeltNextItems(nextSection.items)
			end
		else
			resuming = false
		end
		for i=currentSection.minLayer,currentSection.maxLayer do
			currentLayer = i
			local nextPos = findClosest(i)
			print("Building layer " .. tostring(i+2))
			while nextPos do
				local slot = getSlot(getP(nextPos))
				if turtle.getSelectedSlot() ~= slot then
					turtle.select(slot)
				end
				goTo(nextPos + up)
				while not (turtle.placeDown() or 
					(getP(nextPos) == "string" and turtle.detectDown() and turtle.dropUp(1))) do
					checkAborted()
				end
				setP(nextPos,nil)
				nextPos = findClosest(i)
			end
		end
		currentSection = nextSection
	until currentSection.used_slots == 0
end

local function setBlocks()
	for i=-1,#plan do
		for k,l in pairs(plan[i] or {}) do
			for m,n in pairs(l) do
				if n == "string" then n = "tripwire" end
				local ok,msg
				repeat 
					ok,msg = pcall(commands.async.setblock,"~"..k,"~"..i,"~"..m,n)
					if not ok then --catch tasklimit
						print(msg)
						sleep(1)
					end
					if aborted then
						return
					end
				until ok
			end
		end
	end
	local s = os.startTimer(0.5)
	while true do
		local r = {os.pullEvent()}
		if r[1] == "task_complete" and not r[4] then
			for i,j in ipairs(r[5]) do printError(j) end
		elseif r[1] == "timer" and r[2] == s then break end
	end
end

local function listenAbort()
	local event,char
	repeat
		event, char = os.pullEvent("char")
	until char == "t"
	aborted = true
	sleep(120)
	--Hard Abort
end

local ok,msg
if turtle then
	ok,msg = pcall(function() parallel.waitForAny(build, listenAbort) end)
elseif commands then
	setBlocks()
	return
else
	print("Must be on a command computer or on a turtle")
end

--From http://lua-users.org/wiki/CopyTable
function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

if not ok then
	printError(msg)
	if settings.get("statue.returnOnError", true) and pos ~= zero then
		print("Going home to cry")
		currentSection.minLayer = currentLayer
		local f = fs.open("statue_progress","w")
		f.write("return ".. textutils.serialize(deepcopy(
			{currentSection=currentSection,nextSection=nextSection,plan=plan})))
		f.close()
		print("Run with the same parameters to resume")
		goTo(zero)
		face(vector.new(0,1,0))
	end
else
	if settings.get("statue.returnWhenDone", true) then
		goTo(zero)
		face(vector.new(0,1,0))
	end
	print("Done")
end
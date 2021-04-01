rednet.open("left")
local rsp = peripheral.wrap("back")
local cardinal = "west"

rednet.host("item_requests","supplier")
local settings = require "refinedstorage.autostocksettings"
local logged = { item={}, fluid={} }
local Status = { OK = 1, CRAFTABLE = 2, UNCRAFTABLE = 3, CRAFTING = 4 }
turtle.select(1)

local craftings = {
    terracotta = {terracotta={2,3,4,6,8,10,11,12},color={7},amount=8},
    stained_glass = {glass={2,3,4,6,8,10,11,12},color={7},amount=8},
    wool = {white_wool={2},color={3}},
    concrete_powder = {sand={2,3,4,6},gravel={8,10,11,12},color={7},amount=8},
    concrete = {concrete_powder={2}}
}

local concrete_timer = 0

local function craft(item, count, slots, color, block)
    print(string.format("%5dx %s",count*#slots,item))
    if craftings[block] and item ~= "terracotta" then
            for k,i in pairs(craftings[block]) do
            if k ~= "amount" then
                local j = k == "color" and color.."_dye" or k
                craft(j, math.ceil(count / (craftings[block].amount or 1)),i,color,k)
            end
        end
        if block == "concrete" then
            turtle.dropDown(count)
			local new_ct = os.clock() + 15 + (count > 64 and 64 or count)/3
			concrete_timer = math.max(concrete_timer, new_ct)
			if turtle.getItemCount() > 0 then
				turtle.drop()
			end
        else
            turtle.craft()
        end
    else
		rsp.extractItem({name="minecraft:"..item},count*#slots,cardinal)
		--sleep(1)
		if turtle.getItemCount() < count*#slots then
			print("Missing Item: "..item)
			sleep(concrete_timer - os.clock())
			turtle.select(16)
			while turtle.suckDown() do
				turtle.dropUp()
			end
			turtle.select(1)
			repeat
				sleep(60)
				rsp.extractItem({name="minecraft:"..item},count*#slots-turtle.getItemCount(),cardinal)
			until turtle.getItemCount() == count*#slots
		end
		for _,i in ipairs(slots) do
			turtle.transferTo(i,count)
		end
    end
end
local queue = {}

local function isSame(items1, items2)
    for i,j in pairs(items1) do
        if items2[i] ~= j then
            return false
        end
    end
    return true
end

local function listen()
    while true do
        local sender,msg = rednet.receive("item_requests")
        if type(msg) == "table" then
			print("Received Message")
            if msg.queue then
                msg.sender = sender
                table.insert(queue, msg)
                os.queueEvent("new_request")
            elseif queue[1].done and isSame(queue[1].items, msg.items) then
                rednet.send(queue[1].sender,"Done","item_requests")
            end
        end
        if msg == "Empty" then
            os.queueEvent("ender_empty")
        end
    end
end

local function complete_helper(items, ct)
	for item,count in pairs(items) do
		if (not item:match("concrete$")) ~= ct then
			local color, block = item:match("^([^_]*)_(.*)$")
			if color == "light" then
				color,block = block:match("^([^_]*)_(.*)$")
				color = "light_" .. color
			end
			local rem = count
			while rem > 0 do
				local stack = rem > 64 and 64 or rem
                local rsitem = rsp.getItem({name=item}).count
				if rsitem and rsitem > stack then
                    rsp.extractItem({name=item},stack,cardinal)
                else
                    craft(item, stack, {1},color,block)
				end
                turtle.dropUp(stack)
				if turtle.getItemCount() > 0 then
					turtle.drop()
				end
				rem = rem - 64
			end
		end
	end
end

--copied from autostock.lua because it can not be invoked otherwise and not without a monitor
local function restock()
	local info, msg = {}, nil
    if refinedstorage.isConnected() then
        for _,v in ipairs(settings.getStock()) do
            local handlers, stack = settings.getHandlers(v)
            if handlers then
                local stored,err = handlers.find(stack)
                local state = {
                    handlers = handlers,
                    stack = stack,
                    target = handlers.getQuantity(stack),
                    quantity = handlers.getQuantity(stored),
                    name = stored.displayName or stack.name,
                }

                if state.quantity >= state.target then
                    state.status = Status.OK
                else
                    local pattern,err = handlers.findPattern(stack)
                    if pattern then
                        state.status = Status.CRAFTABLE
                    else
                        state.status = Status.UNCRAFTABLE
                    end
                end
                state.summary = string.format("%s/%s", handlers.formatQuantity(state.quantity), handlers.formatQuantity(state.target))
                table.insert(info, state)
            end
        end
    else
        msg = "Storage offline"
    end
    local tasks,err = refinedstorage.getTasks()
    for _,v in ipairs(info) do
        local k = v.stack.name
        if v.status == Status.CRAFTABLE then
            -- there may be multiple separate crafting tasks for the same output
            local crafting = 0
            for _,t in ipairs(tasks) do
                local handlers, stack = settings.getHandlers(t.stack)
                if handlers == v.handlers and stack.name == k then
                    v.status = Status.CRAFTING
                    crafting = crafting + handlers.getQuantity(stack)
                end
            end
            local remaining = v.target - v.quantity - crafting
            if crafting > 0 and logged[v.handlers.type][k] == nil then
                print(string.format("%s at %s, crafting %s in progress", v.name, v.summary,
                        v.handlers.formatQuantity(crafting)))
                logged[v.handlers.type][k] = "wip"
            end
            if remaining > 0 then
                local t,err = v.handlers.craft(v.stack, remaining)
                if t then
                    v.status = Status.CRAFTING
                    if logged[v.handlers.type][k] ~= true then
                        local handlers, stack = settings.getHandlers(t.stack)
                        print(string.format("%s at %s, started crafting %s", v.name, v.summary,
                                handlers.formatQuantity(handlers.getQuantity(stack))))
                        logged[v.handlers.type][k] = true
                    end
                elseif err and logged[v.handlers.type][k] ~= err then
                    print(string.format("%s at %s, %s", v.name, v.summary, err))
                    logged[v.handlers.type][k] = err
                end
            end
        else
            logged[v.handlers.type][k] = nil
        end
    end
end

local function complete()
    while true do
        if #queue == 0 then
            os.pullEvent("new_request")
        end
        print(#queue)
		complete_helper(queue[1].items, true)
		complete_helper(queue[1].items, false)
		sleep(concrete_timer - os.clock())
		while turtle.suckDown() do
			turtle.dropUp()
		end
		rednet.send(queue[1].sender,"Done","item_requests")
        print("Finished order")
        print(#queue)
        queue[1].done = true
        os.pullEvent("ender_empty")
		restock()
        table.remove(queue,1)
    end
end

parallel.waitForAll(listen, complete)
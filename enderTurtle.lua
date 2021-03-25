local args = {...}
rednet.open("left")
local sup_id = rednet.lookup("item_requests","supplier")
local carryEnderChest = true
settings.set("statue.reservedSlots", carryEnderChest and 1 or 0)
settings.set("statue.returnForItems", not carryEnderChest)
if not carryEnderChest then
	turtle.turnLeft()
	turtle.place()
	turtle.turnRight()
end

_G.smeltNextItems = function(items)
    print("Queueing Item Request")
    rednet.send(sup_id,{queue=true,items=items},"item_requests")
end

_G.gatherItems = function(items)
  print(textutils.serialise(items))
  local server_id,response
  if carryEnderChest then
	  turtle.select(1)
	  repeat until turtle.place()
	  turtle.select(2)
  else
    turtle.turnLeft()
  end
  repeat
    print("Sending Item Request")
    rednet.send(sup_id,{queue=false,items=items},"item_requests")
    server_id,response = rednet.receive("item_requests")
  until response == "Done"
  print("Done")
  for i=1,16 do
    turtle.suck()
  end
  rednet.send(sup_id,"Empty","item_requests")
  if carryEnderChest then
	  turtle.select(1)
	  turtle.dig()
  else
	  turtle.turnRight()
  end
end

shell.run("statue.lua",unpack(args))

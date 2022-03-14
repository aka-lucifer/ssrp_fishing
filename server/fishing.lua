-- Variables
QBCore = exports['qb-core']:GetCoreObject()
local minigameStatuses = {}

-- Events
RegisterNetEvent("lx_fishing-server:fishing:requestMinigame")
AddEventHandler("lx_fishing-server:fishing:requestMinigame", function(crewmates, state, bait)
  local src = source
  local shuffledCrewmates = ShuffleTable(crewmates)
  minigameStatuses[src] = {
    entries = 0
  }

  print(json.encode(minigameStatuses[src]), json.encode(shuffledCrewmates))
  
  for a = 1, #shuffledCrewmates do
    table.insert(minigameStatuses[src], {
      server_id = shuffledCrewmates[a],
      state = "UNPLAYED"
    })
    
    print(json.encode(minigameStatuses[src]))

    TriggerClientEvent("lx_fishing-client:fishing:startMinigame", shuffledCrewmates[a], src, state, bait)

    if a >= 3 then -- change to 3 for testing
      break -- stop for loop, as we only need to do it to 3 of the crew
    end
  end
end)

RegisterNetEvent("lx_fishing-server:fishing:updateState")
AddEventHandler("lx_fishing-server:fishing:updateState", function(state, captainId, currZone)
  print("UPDATE STATE", state, captainId, source, json.encode(minigameStatuses[captainId]))
  local src = source
  local Player = QBCore.Functions.GetPlayer(captainId)

  for a = 1, #minigameStatuses[captainId] do
    if minigameStatuses[captainId][a].server_id == src then
      print("found entry")
      minigameStatuses[captainId][a].state = state
      minigameStatuses[captainId].entries = minigameStatuses[captainId].entries + 1
      break
    end
  end

  Wait(0)

  if minigameStatuses[captainId].entries >= 3 then -- change to 3 for testing
    print("finished, update source", json.encode(minigameStatuses[captainId]))
    local successRate = 0
    for a = 1, #minigameStatuses[captainId] do
      if minigameStatuses[captainId][a].state == "SUCCESS" then
        successRate = successRate + 1
      end

      if a == #minigameStatuses[captainId] then
        print(successRate, minigameStatuses[captainId].entries)
        if successRate == minigameStatuses[captainId].entries then
          print("all crewmen succeeded!")
          
          if QB_Fishing.debugging then print("fishing in zone with large sized bait") end
          local caughtFish = currZone .. "_meat"
          local currAmount = CheckAmount(captainId, caughtFish)

          print(captainId, caughtFish, CheckAmount(captainId, caughtFish), json.encode(QB_Fishing.carryMaxes))

          if (currAmount + 1) <= QB_Fishing.carryMaxes[caughtFish] then
            if QB_Fishing.debugging then print("caught (" .. caughtFish .. ")!") end
            Player.Functions.AddItem(caughtFish, 1)
            TriggerClientEvent("lx_fishing-client:fishing:attachFish", captainId)
            TriggerClientEvent('inventory:client:ItemBox', captainId, QBCore.Shared.Items[caughtFish], "add")
            TriggerClientEvent('QBCore:Notify', captainId, "You and your crew were successful in catching the " .. QBCore.Shared.Items[caughtFish].label:gsub("% Meat", "") .. ".", "success", 3000)
          else
            TriggerClientEvent('QBCore:Notify', captainId, "You't can't carry any more " .. QBCore.Shared.Items[caughtFish].label:gsub("% Meat", "") .. ", so you throw it back in the water!", "error", 3000)
          end
        else
          print("some crewmen failed!")
          TriggerClientEvent('QBCore:Notify', captainId, "You and your crew were unsuccessful in catching the fish and it got away!", "error", 3000)
        end
      end
    end
  end
end)

RegisterNetEvent("lx_fishing-server:fishing:catchFish")
AddEventHandler("lx_fishing-server:fishing:catchFish", function(bait, state)
  local src = source
  local Player = QBCore.Functions.GetPlayer(src)
  local caughtFish = nil
  local caughtAmount = 0

  if bait == "small_fish_bait" then -- Land Fishing
    if QB_Fishing.debugging then print("fishing on land with small sized bait") end
    caughtFish = QB_Fishing.types.land[math.random(1, #QB_Fishing.types.land)]
    caughtAmount = math.random(1, 3)
  elseif bait == "medium_fish_bait" then -- Deep Fishing
    if state > 1 then -- If we're in deep or rare waters, give us a medium sized fish
      if QB_Fishing.debugging then print("fishing in deep waters with medium sized bait") end
      caughtFish = QB_Fishing.types.deep[math.random(1, #QB_Fishing.types.deep)]
      caughtAmount = math.random(1, 3)
    else -- If we use medium bait on land, get small sized fish
      if QB_Fishing.debugging then print("fishing on land with medium sized bait") end
      caughtFish = QB_Fishing.types.land[math.random(1, #QB_Fishing.types.land)]
      caughtAmount = math.random(1, 3)
    end
  elseif bait == "large_fish_bait" then
    if state == 2 then
      if QB_Fishing.debugging then print("fishing in zone with medium sized bait") end
      caughtFish = QB_Fishing.types.deep[math.random(1, #QB_Fishing.types.deep)]
      caughtAmount = math.random(1, 3)
    else
      if QB_Fishing.debugging then print("fishing in zone with small sized bait") end
      caughtFish = QB_Fishing.types.land[math.random(1, #QB_Fishing.types.land)]
      caughtAmount = math.random(1, 3)
    end
  end

  Wait(0)

  local currAmount = CheckAmount(src, caughtFish)
  if (currAmount + caughtAmount) <= QB_Fishing.carryMaxes[caughtFish] then
    if QB_Fishing.debugging then print("caught x" .. caughtAmount .. " of (" .. caughtFish .. ")!") end
    Player.Functions.AddItem(caughtFish, caughtAmount)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[caughtFish], "add")
  else
    TriggerClientEvent('QBCore:Notify', src, "You't can't carry any more " .. QBCore.Shared.Items[caughtFish].label:gsub("% Meat", "") .. ", so you throw it back in the water!", "error", 3000)
  end
end)

-- Item Uses
QBCore.Functions.CreateUseableItem("small_fish_bait", function(source, item)
  local Player = QBCore.Functions.GetPlayer(source)
  if Player.Functions.RemoveItem(item.name, 1, item.slot) then
    TriggerClientEvent("lx_fishing-client:startFishing", source, "small_fish_bait")
  end
end)

QBCore.Functions.CreateUseableItem("medium_fish_bait", function(source, item)
  local Player = QBCore.Functions.GetPlayer(source)
  if Player.Functions.RemoveItem(item.name, 1, item.slot) then
    TriggerClientEvent("lx_fishing-client:startFishing", source, "medium_fish_bait")
  end
end)

QBCore.Functions.CreateUseableItem("large_fish_bait", function(source, item)
  local Player = QBCore.Functions.GetPlayer(source)
  if Player.Functions.RemoveItem(item.name, 1, item.slot) then
    TriggerClientEvent("lx_fishing-client:startFishing", source, "large_fish_bait")
  end
end)

-- Callbacks
QBCore.Functions.CreateCallback('lx_fishing-server:hasItem', function(source, cb, itemName)
  print("Item: " .. itemName)
  local src = source
  local Player = QBCore.Functions.GetPlayer(src)
  
  for key, value in pairs(Player.PlayerData.items) do
    if value.name == itemName and value.amount > 0 then
      cb(true, value)
    end
  end

  cb(false, nil)
end)

QBCore.Functions.CreateCallback('lx_fishing-server:hasEnoughOfItem', function(source, cb, itemName, itemAmount)
  print("Item: " .. itemName)
  local src = source
  local Player = QBCore.Functions.GetPlayer(src)
  
  for key, value in pairs(Player.PlayerData.items) do
    if value.name == itemName and value.amount >= itemAmount then
      cb(true, value)
    end
  end

  cb(false, nil)
end)

-- Methods
CheckAmount = function(server_id, item)
  local Player = QBCore.Functions.GetPlayer(server_id)
  
  for key, value in pairs(Player.PlayerData.items) do
    if value.name == item then
      return value.amount
    end
  end

  return 0
end

ShuffleTable = function(tbl)
  for i = #tbl, 2, -1 do
    local j = math.random(i)
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end
  return tbl
end
-- Variables
local pedNetId = -1

-- Events
AddEventHandler("onResourceStop", function(resourceName) -- Handles deleting the ped on resource stop/restart
  if GetCurrentResourceName() == resourceName then
    print("fishing resource stopped!")
    if pedNetId ~= -1 and NetworkGetEntityFromNetworkId(pedNetId) then
      if QB_Fishing.debugging then print("ped exists, delete it") end
      DeleteEntity(NetworkGetEntityFromNetworkId(pedNetId))
      pedNetId = -1
    end
  end
end)

AddEventHandler("onResourceStart", function(resourceName)
  if GetCurrentResourceName() == resourceName then
    print("fishing resource started!")
    if pedNetId == -1 then
      local ped = CreatePed(20, GetHashKey(QB_Fishing.selling.black_market.models[math.random(1, #QB_Fishing.selling.black_market.models)]), QB_Fishing.selling.black_market.position.x, QB_Fishing.selling.black_market.position.y, QB_Fishing.selling.black_market.position.z, QB_Fishing.selling.black_market.position.w, true, true)
      pedNetId = NetworkGetNetworkIdFromEntity(ped)
      if QB_Fishing.debugging then print("Created Ped - Handle: (" .. ped .. ") | Net ID: (" .. pedNetId .. ")", "Syncing to client") end
    else
      if QB_Fishing.debugging then print("ped already exists, no point in creating it") end
    end
  end
end)

RegisterNetEvent("lx_fishing-server:selling:blackmarketPed")
AddEventHandler("lx_fishing-server:selling:blackmarketPed", function()
  local src = source
  TriggerClientEvent("lx_fishing-client:selling:syncPed", src, pedNetId)
end)

RegisterNetEvent("lx_fishing-server:selling:useBlackmarket")
AddEventHandler("lx_fishing-server:selling:useBlackmarket", function(fishData)
  if QB_Fishing.debugging then print("Fish Data (" .. json.encode(fishData) .. ")") end
  local itemData = nil
  local src = source
  local ped = GetPlayerPed(src)
  local salesPed = NetworkGetEntityFromNetworkId(pedNetId)
  local pedPos = GetEntityCoords(ped, false)
  local salesPos = GetEntityCoords(salesPed, false)

  if #(pedPos - salesPos) <= 1.5 then -- check we're close enough
    local Player = QBCore.Functions.GetPlayer(src)
    for i, value in pairs(Player.PlayerData.items) do
      if value.name == fishData.item then
        itemData = value
        break
      end
    end

    if QB_Fishing.debugging then print("Item Data - " .. json.encode(itemData)) end
    if itemData ~= nil then
      local sellTime = fishData.time * itemData.amount
      if QB_Fishing.debugging then print("Sell Time: " .. sellTime) end
      TriggerClientEvent("QBCore:Notify", src, "Selling " .. fishData.label .. "...", "success", sellTime)
      Wait(sellTime + 1200)
      pedPos = GetEntityCoords(ped, false)
      salesPos = GetEntityCoords(salesPed, false)
      
      if #(pedPos - salesPos) <= 1.5 then -- Double check we're close enough
        Player.Functions.RemoveItem(itemData.name, itemData.amount, itemData.slot)
        TriggerClientEvent('turbo-inventory:client:ItemBox', src, QBCore.Shared.Items[itemData.name], "remove")
        Player.Functions.AddMoney("cash", fishData.price * itemData.amount, "Fish Black Market (x" .. itemData.amount .. " for $" .. Utils.FormatToMoney(fishData.price * itemData.amount) .. ")")
        
        ClearPedTasks(ped)
        TaskPlayAnim(salesPed, "mp_ped_interaction", "handshake_guy_a", 8.0, 8.0, 3000, 1, 1.0, false, false, false)
        TaskPlayAnim(ped, "mp_ped_interaction", "handshake_guy_a", 8.0, 8.0, 3000, 1, 1.0, false, false, false)
        Wait(3000)
        ClearPedTasks(salesPed)
        ClearPedTasks(ped)
      else
        TriggerClientEvent("QBCore:Notify", src, "You went too far away and were unable to complete the deal!", "error", 3000)
      end

      TriggerClientEvent("lx_fishing-client:selling:syncMenu", src, false)
    else
      TriggerClientEvent("QBCore:Notify", src, "You don't have any " .. fishData.label:gsub("^%l", string.upper) .. "!", "error", 3000)
    end
  end
end)

RegisterNetEvent("lx_fishing-server:selling:sellFish")
AddEventHandler("lx_fishing-server:selling:sellFish", function(fishData)
  if QB_Fishing.debugging then print("Fish Data (" .. json.encode(fishData) .. ")") end
  local itemData = nil
  local src = source
  local ped = GetPlayerPed(src)
  local pedPos = GetEntityCoords(ped)
  local Player = QBCore.Functions.GetPlayer(src)

  for i, value in pairs(Player.PlayerData.items) do
    if value.name == fishData.item then
      itemData = value
      break
    end
  end

  if QB_Fishing.debugging then print("Item Data - " .. json.encode(itemData)) end
    if itemData ~= nil then
      local sellTime = fishData.time * itemData.amount
      if QB_Fishing.debugging then print("Sell Time: " .. sellTime) end
      TriggerClientEvent("QBCore:Notify", src, "Selling " .. fishData.label .. "...", "success", sellTime)
      Wait(sellTime + 1200)
      pedPos = GetEntityCoords(ped, false)
      
      if #(pedPos - vector3(QB_Fishing.selling.standard.position)) <= 1.5 then -- Double check we're close enough
        Player.Functions.RemoveItem(itemData.name, itemData.amount, itemData.slot)
        TriggerClientEvent('turbo-inventory:client:ItemBox', src, QBCore.Shared.Items[itemData.name], "remove")
        Player.Functions.AddMoney("cash", fishData.price * itemData.amount, "La Spada Fish Sales (x" .. itemData.amount .. " for $" .. Utils.FormatToMoney(fishData.price * itemData.amount) .. ")")
      else
        TriggerClientEvent("QBCore:Notify", src, "You went too far away from the sale!", "error", 3000)
      end

      TriggerClientEvent("lx_fishing-client:selling:syncMenu", src, false)
    else
      TriggerClientEvent("QBCore:Notify", src, "You don't have any " .. fishData.label:gsub("^%l", string.upper) .. "!", "error", 3000)
    end
end)
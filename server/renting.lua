-- Variables
-- locationKey = -1

-- -- Events
-- RegisterNetEvent("lx_fishing-server:updateLocation")
-- AddEventHandler("lx_fishing-server:updateLocation", function(newLocation)
--   Logger.Info("Updating Location Key", "Updating from (" .. locationKey .. ") - (" .. newLocation .. ")")
--   locationKey = newLocation
-- end)

RegisterNetEvent("lx_fishing-server:rentVehicle")
AddEventHandler("lx_fishing-server:rentVehicle", function(vehData, locationKey)
  local src = source
  local player = QBCore.Functions.GetPlayer(src)
  local currCash = player.PlayerData.money["cash"]

  if QB_Fishing.debugging then print("Cash: " .. currCash .. " | Rental Data: " .. json.encode(vehData)) end
  if currCash >= vehData.rental_price then
    player.Functions.RemoveMoney("cash", vehData.rental_price, "Rented a " .. vehData.name .. " for $" .. Utils.FormatToMoney(vehData.rental_price))
    TriggerClientEvent("lx_fishing-client:rentVehicle", src, vehData, locationKey)
  else
    TriggerClientEvent('QBCore:Notify', src, "Insufficient Funds!", "error", 3000)
  end
end)

RegisterNetEvent("lx_fishing-server:setRented")
AddEventHandler("lx_fishing-server:setRented", function(vehData, netId)
  QB_Fishing.rented[netId] = vehData
  print("rent data", json.encode(QB_Fishing.rented[netId]))
end)

RegisterServerEvent("lx_fishing-server:returnVeh")
AddEventHandler("lx_fishing-server:returnVeh", function(netId, health, locationKey)
    local src = source
    local ped = GetPlayerPed(src)
    local player = QBCore.Functions.GetPlayer(src)
    
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    DeleteEntity(vehicle)

    QB_Fishing.rented[netId].rental_price = math.ceil((QB_Fishing.rented[netId].rental_price / 100) * health / 10)
    player.Functions.AddMoney("cash", QB_Fishing.rented[netId].rental_price, "Returned rental of " .. QB_Fishing.rented[netId].name .. " for $" .. Utils.FormatToMoney(QB_Fishing.rented[netId].rental_price) .. ".")
    
    local spawnPos = QB_Fishing.renting.locations["rent"][locationKey]
    print("spawn pos", spawnPos)
    SetEntityCoords(ped, spawnPos.x, spawnPos.y, spawnPos.z, true, false, false, false)
    TriggerClientEvent('QBCore:Notify', src, "Returned rental for $" .. Utils.FormatToMoney(QB_Fishing.rented[netId].rental_price) .. ".", "success", 3000)
    QB_Fishing.rented[netId] = nil
end)
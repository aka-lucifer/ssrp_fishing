-- Variables
local pedNet = -1
local pedHandle = nil
local illegalSalesTick = nil
local salesTick = nil

--[[ HANDLE SELL MENU ]]
local inMenu = false
local illegalSalesMenu = {{ header = "Illegal Sales", isMenuHeader = true }}
local salesMenu = {{ header = "Fish Sales", isMenuHeader = true }}

for k, v in pairs(QB_Fishing.selling.black_market.fishes) do
  table.insert(illegalSalesMenu, {
    header = v.label,
    txt = "Sell " .. v.label .. " for $" .. Utils.FormatToMoney(v.price),
    params = {
      event = "lx_fishing-client:selling:useBlackmarket",
      args = v
    }
  })

  if QB_Fishing.debugging then Logger.Log("Formatted Illegal Sales Data", json.encode(illegalSalesMenu)) end
end

for k, v in pairs(QB_Fishing.selling.standard.fishes) do
  table.insert(salesMenu, {
    header = v.label,
    txt = "Sell " .. v.label .. " for $" .. Utils.FormatToMoney(v.price) .. ", for each fish.",
    params = {
      event = "lx_fishing-client:selling:sellFish",
      args = v
    }
  })

  if QB_Fishing.debugging then Logger.Log("Formatted Sales Data", json.encode(salesMenu)) end
end

-- Events
AddEventHandler("onResourceStart", function(resourceName)
  if GetCurrentResourceName() == resourceName then
    TriggerServerEvent("lx_fishing-server:selling:blackmarketPed")
  end
end)

RegisterNetEvent("lx_fishing-client:selling:syncMenu")
AddEventHandler("lx_fishing-client:selling:syncMenu", function(bool)
  inMenu = bool
end)

RegisterNetEvent("lx_fishing-client:selling:syncPed")
AddEventHandler("lx_fishing-client:selling:syncPed", function(netId)
  if QB_Fishing.debugging then Logger.Log("Fish Blackmarket", "NPC Net ID Recieved!") end
  pedNet = netId
  pedHandle = NetworkGetEntityFromNetworkId(pedNet)

  -- Debug Info
  if QB_Fishing.debugging then print("found ped (" .. pedNet .. ") | (" .. pedHandle .. "), adding blip for entity") end

  -- Behaviour
  FreezeEntityPosition(pedHandle, true)
  SetEntityInvincible(pedHandle, true)
  SetBlockingOfNonTemporaryEvents(pedHandle, true)
  SetPedCanRagdoll(pedHandle, false)

  -- Tick Control
  illegalSalesTick = Thread(PedInteraction, true, 500)
end)

RegisterNetEvent("lx_fishing-client:selling:useBlackmarket")
AddEventHandler("lx_fishing-client:selling:useBlackmarket", function(fishData)
  if QB_Fishing.debugging then print("Sell all of your " .. fishData.item) end
  local ped = Ped(PlayerPedId())
  local pedPos = ped:Position()

  if pedPos:Dist(GetEntityCoords(pedHandle)) <= 1.5 then
    Utils.RequestAnim("mp_ped_interaction") -- Request this here as this native isn't server supported yet
    TriggerServerEvent("lx_fishing-server:selling:useBlackmarket", fishData)
  else
    QBCore.Functions.Notify("You aren't close enough to make this deal!", "error", 3000)
  end
end)

RegisterNetEvent("lx_fishing-client:selling:sellFish")
AddEventHandler("lx_fishing-client:selling:sellFish", function(fishData)
  if QB_Fishing.debugging then print("Sell all of your " .. fishData.item) end
  TriggerServerEvent("lx_fishing-server:selling:sellFish", fishData)
end)

-- Methods
PedInteraction = function()
  if not inMenu then
    local ped = Ped(PlayerPedId())
    local pedPos = ped:Position()

    if pedPos:Dist(GetEntityCoords(pedHandle)) <= 2.0 then
      if illegalSalesTick.delay >= 500 then
        illegalSalesTick:ChangeDelay(5)
      end

      Utils.TopLeft("~INPUT_CONTEXT~ Sell Illegal Fish")
      if IsControlJustPressed(0, 51) then
        inMenu = true
        exports["qb-menu"]:openMenu(illegalSalesMenu)
      end
    else
      if illegalSalesTick.delay < 500 then
        illegalSalesTick:ChangeDelay(500)
      end
    end
  end
end

-- Threads
Citizen.CreateThread(function()
  local blip = AddBlipForCoord(QB_Fishing.selling.standard.position.x, QB_Fishing.selling.standard.position.y, QB_Fishing.selling.standard.position.z)
  SetBlipScale(blip, 0.7)
  SetBlipSprite(blip, 210)
  SetBlipColour(blip, 7)
  SetBlipAsShortRange(blip, true)

  BeginTextCommandSetBlipName("STRING")
  AddTextComponentString("La Spada Fish Sales")
  EndTextCommandSetBlipName(blip)
end)

salesTick = Thread(function()
  local ped = Ped(PlayerPedId())
  local pedPos = ped:Position()
  local dist = pedPos:Dist(QB_Fishing.selling.standard.position)

  if not inMenu then
    if dist <= 20.0 then
      if salesTick.delay >= 500 then
        salesTick:ChangeDelay(5)
      end

      DrawMarker(27, vector3(QB_Fishing.selling.standard.position.x, QB_Fishing.selling.standard.position.y, QB_Fishing.selling.standard.position.z - 0.98), vector3(0.0, 0.0, 0.0), vector3(0.0, 0.0, 0.0), vector3(3.0, 3.0, 0.3), 32, 232, 112, 150, false, true)

      if dist <= 1.5 then
        Utils.TopLeft("~INPUT_CONTEXT~ Sell Fish")
        if IsControlJustPressed(0, 51) then
          inMenu = true
          exports["qb-menu"]:openMenu(salesMenu)
        end
      end
    else
      if salesTick.delay <= 5 then
        salesTick:ChangeDelay(500)
      end
    end
  else
    if dist > 1.5 then -- If we've left the marker proximity, close the menu
      inMenu = false
    end
  end
end, true, 500)
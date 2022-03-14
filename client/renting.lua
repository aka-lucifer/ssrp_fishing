-- Global Variables
inMenu = false
locationKey = -1

-- Variables
local currLocation = nil
local rentedPosition = vector3(-1629.82, -1168.36, 1.18 - 2.0)
local spawnedRental = nil
local rentThread = nil

--[[ HANDLE RENTAL MENU ]]
local menuData = {{ header = "Boat Renting", isMenuHeader = true }}

for k, v in pairs(QB_Fishing.renting.vehicles) do
  -- if QB_Fishing.debugging then
    -- Logger.Log("Rented Veh Data", "[" .. k .. "]: " .. json.encode(v))
  -- end

  table.insert(menuData, {
    header = v.name,
    txt = "Rent a " .. v.name .. " for $" .. Utils.FormatToMoney(v.rental_price),
    params = {
      event = "lx_fishing-client:prepareRenting",
      args = v
    }
  })

  if QB_Fishing.debugging then
    Logger.Log("Formatted Rental Data", json.encode(menuData))
  end
end

-- [[ Handle Rental Blips ]]
for k, v in pairs(QB_Fishing.renting.locations["rent"]) do
  local blip = AddBlipForCoord(v.x, v.y, v.z)
  SetBlipScale(blip, 0.7)
  SetBlipSprite(blip, 427)
  SetBlipColour(blip, 2)
  SetBlipAsShortRange(blip, true)

  BeginTextCommandSetBlipName("STRING")
  AddTextComponentString("Boat Rental")
  EndTextCommandSetBlipName(blip)
end

-- Events
RegisterNetEvent("lx_fishing-client:prepareRenting")
AddEventHandler("lx_fishing-client:prepareRenting", function(vehData) -- Gotta do this as qb-menu is ass and won't send server events
  TriggerServerEvent("lx_fishing-server:rentVehicle", vehData, locationKey)
end)

RegisterNetEvent("lx_fishing-client:rentVehicle")
AddEventHandler("lx_fishing-client:rentVehicle", function(vehData, tableKey)
  rentedPosition = QB_Fishing.renting.locations["spawn"][vehData.model][tableKey]
  spawnedRental = Rental(vehData.model, Coords(rentedPosition.x, rentedPosition.y, rentedPosition.z, rentedPosition.w))
  TriggerEvent("vehiclekeys:client:SetOwner", spawnedRental:Plate())
  TriggerServerEvent("lx_fishing-server:setRented", vehData, spawnedRental:GetNetId())
  inMenu = false
end)

-- Threads
rentThread = Thread(function()
  local ped = Ped(PlayerPedId())
  local pedPos = ped:Position()

  if not inMenu then
    for k, v in pairs(QB_Fishing.renting.locations["rent"]) do
      local dist = pedPos:Dist(v)
      if dist < 10.0 then
        rentThread:ChangeDelay(5)
        currLocation = v
        DrawMarker(27, v, vector3(0.0, 0.0, 0.0), vector3(0.0, 0.0, 0.0), vector3(3.0, 3.0, 0.3), 32, 232, 112, 150, false, true)
        if dist <= 2.0 then
          Utils.TopLeft("~INPUT_DETONATE~ Rent a Boat")
          if IsControlJustPressed(0, 47) then
            if locationKey ~= k then
              if QB_Fishing.debugging then print("different location") end
              locationKey = k
            end

            exports["qb-menu"]:openMenu(menuData)
            inMenu = true
          end
        end
      end
    end
  end

  if rentedPosition ~= nil then
    if ped:InsideVehicle() and IsPedInAnyBoat(ped.handle) then
      local dist = pedPos:Dist(rentedPosition)
        if dist <= 25.0 then
          currLocation = rentedPosition
          rentThread:ChangeDelay(5)
          DrawMarker(1, rentedPosition.x, rentedPosition.y, rentedPosition.z - 0.5, vector3(0.0, 0.0, 0.0), vector3(0.0, 0.0, 0.0), vector3(5.0, 5.0, 4.7), 255, 0, 0, 150, false, true, 2, false, false, false, false)
          if dist <= 5.0 then
            Utils.TopLeft("~INPUT_DETONATE~ Return Rented Boat")
            if IsControlJustPressed(0, 47) then
              spawnedRental:Return()
              rentedPosition = vector3(-1629.82, -1168.36, 1.18 - 2.0)
            end
          end
        end
    end
  end

  if currLocation ~= nil then
    if pedPos:Dist(currLocation) > 17.0 then
      rentThread:ChangeDelay(500)
      currLocation = nil
      inMenu = false
    end
  end
end, true, 500)
-- Variables
inZone = false
currentZone = nil
zoneThread = nil
local currLocation = nil

-- Threads
-- [ZONE BLIP HANDLER]
CreateThread(function()
  for k, v in pairs(QB_Fishing.zones.locations) do
    local blip = AddBlipForRadius(v.location.x, v.location.y, v.location.z, 400.0)

    if v.type == "shark" then
      SetBlipColour(blip, 55) -- silver
    elseif v.type == "dolphin" then
      SetBlipColour(blip, 62)
    elseif v.type == "turtle" then
      SetBlipColour(blip, 2)
    elseif v.type == "whale" then
      SetBlipColour(blip, 67)
    end
  end
end)

Thread(function()
  local ped = Ped(PlayerPedId())
  local pedPos = ped:Position()

  for k, v in pairs(QB_Fishing.zones.locations) do
    if pedPos:Dist(v.location) <= 400.0 then
      currentZone = v.type
      currLocation = v.location
      inZone = true
    end
  end

  if QB_Fishing.debugging then
    if currentZone ~= nil then
      print("ZONE - " .. currentZone)
    end
  end
    
  if currLocation ~= nil then
    if pedPos:Dist(currLocation) >= 410.0 then
      local tempVar = currentZone
      currentZone = nil
      currLocation = nil
      inZone = false
      print("Cleared zone (" .. tempVar .. ")")
    end
  end
end, true, 500)
Utils = {}

Utils.Type = function(obj)
	if type(obj) == 'table' then
		local meta = getmetatable(obj)
		if meta ~= nil then
			return (rawget( getmetatable(obj), "__type" ) or 'table')
		end
	end
	return type(obj)
end

Utils.RequestModel = function(model)
	local modelHash = (type(model) == 'string' and GetHashKey(model) or model)

	if QB_Fishing.debugging then print("hash", model, modelHash) end
	if IsModelInCdimage(modelHash) then
		if HasModelLoaded(modelHash) then
			return true, modelHash
		else
			RequestModel(modelHash)
			local now = GetGameTimer()
			repeat
				Wait(1)
				if (GetGameTimer() - now) >= 20000 then
					warning('Timeout requesting model "%s" after 20 seconds', modelHash)
					timedout = true
					break
				end
			until (HasModelLoaded(modelHash))
			if timedout then
				return false
			end
			return true, modelHash
		end
	else
		return false
	end
end

Utils.RequestAnim = function(animDict)
	if type(animDict) == 'string' then
		if HasAnimDictLoaded(animDict) then
			return true
		end
		RequestAnimDict(animDict)
		local now = GetGameTimer()
		repeat
			Wait(1)
			if (GetGameTimer() - now) >= 20000 then
				warning('Timeout requesting anim "%s" after 20 seconds', animDict)
				timedout = true
				break
			end
		until (HasAnimDictLoaded(animDict))
		if timedout then
			return false
		end
		return true
	else
		warning('Tried to TimeoutRequestAnim without string!')
		return false
	end
end

Utils.CreateRod = function()
    local ped = Ped(PlayerPedId())
    local pedPos = ped:Position()

    fishingRod = Prop("prop_fishing_rod_01", pedPos, true)
    fishingRod:WaitForExistence()
		if QB_Fishing.debugging then print("created rod!") end

    AttachEntityToEntity(fishingRod.handle, ped.handle, ped:BoneIndex(18905), 0.15, 0.03, 0.01, 50.0, 95.0, 180.0, true, true, false, true, 1, true)
    fishingStarted = true
		pedPos = ped:Position()
    local inWater, height = GetWaterHeight(pedPos.x, pedPos.y, pedPos.z)
    if QB_Fishing.debugging then Logger.Log("Water Height", "In Water (" .. tostring(inWater) .. ") | Water Height (" .. height .. ")") end
    if inZone then
        fishingState = 3 -- Illegal fishing (Sharks, Turtles, Dolphins, etc)
    elseif inWater and height > 0.02 and not inZone then
        fishingState = 2 -- Deep Fishing
    elseif not inWater and height <= 0.03 and not inZone then
        fishingState = 1 -- Land Fishing
    end
end

Utils.DeleteRod = function()
	if fishingRod and fishingRod:Exists() then
    fishingRod:Delete()
    fishingRod = nil
	end
  
	fishingStarted = false
  castedLine = false
end

Utils.GetZoneType = function()
  if inZone then
    return true, currentZone
  end

	return false, nil
end

Utils.StopFishing = function()
  local ped = Ped(PlayerPedId())
  fishingStarted = false
  castedLine = false
  ped:ClearTasks()
  Utils.DeleteRod()
	Utils.ClearLoading()
	if fishingThread then
		fishingThread:Kill()
		fishingThread = nil
	end
end

Utils.GetVehiclesInArea = function(coords, area)
    local vehicles = GetGamePool("CVehicle")
    local vehiclesInArea = {}

    for i = 1, #vehicles, 1 do
        local vehicleCoords = GetEntityCoords(vehicles[i])
        local distance = GetDistanceBetweenCoords(vehicleCoords, coords.x, coords.y, coords.z, true)

        if distance <= area then
            table.insert(vehiclesInArea, vehicles[i])
        end
    end

    return vehiclesInArea
end

Utils.IsParkingSpotAvailable = function(coords, radius)
    local vehicles = Utils.GetVehiclesInArea(coords, radius)

    return #vehicles == 0
end

Utils.TopLeft = function(string)
  SetTextComponentFormat("STRING")
  AddTextComponentString(string)
  DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

Utils.ShowLoading = function(loadingText)
  BeginTextCommandBusyspinnerOn("STRING")
  AddTextComponentSubstringPlayerName(loadingText)
  EndTextCommandBusyspinnerOn(3)
end

Utils.ClearLoading = function()
	BusyspinnerOff()
end

Utils.FormatToMoney = function(number)
	local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')
	int = int:reverse():gsub("(%d%d%d)", "%1,")
	return minus .. int:reverse():gsub("^,", "") .. fraction
end

Utils.AttachFish = function(fishType, vehHandle)
	local vehCoords = GetEntityCoords(vehHandle, false)
	local vehHeading = GetEntityHeading(vehHandle)
  local loadedModel, modelHash = Utils.RequestModel(fishType)
	local fish = nil

  if loadedModel then
    fish = CreatePed(29, modelHash, vehCoords.x, vehCoords.y, vehCoords.z, vehHeading, true, false) -- Create the fkin fish
    SetEntityHealth(fish, 0) -- Kill the fkin fish
    AttachEntityToEntity(fish, currVeh, GetEntityBoneIndexByName(currVeh, "engine"), -1.2, -10.0, -3.0, 0.0, 100.0, 100.0, false, false, false, true, 2, true)
  else
    print("couldn't load the fkin fish!")
  end

	return fish
end

Utils.GetNearbyPlayers = function()
	local ped = Ped(PlayerPedId())
	local pedPos = ped:Position()
	local nearbyPlayers = {}

	for i, element in pairs(GetActivePlayers()) do
		if element ~= PlayerId() then
			print("[" .. GetPlayerServerId(element) .. "]: " .. element)
			local otherPed = Ped(GetPlayerPed(element))
			local playerDist =  pedPos:Dist(otherPed:Position())
			if playerDist <= 20.0 then
				table.insert(nearbyPlayers, GetPlayerServerId(element))
			end
		else
			print("yourself doesn't count fat cunt!")
		end
	end

	return nearbyPlayers
end
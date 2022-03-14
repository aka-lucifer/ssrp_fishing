-- Variables
QBCore = exports['qb-core']:GetCoreObject()
fishingStarted = false
castedLine = false
fishingRod = nil
fishingState = 0
fishingThread = nil
currentBait = "NONE"
local timeoutState = "NONE"
local succeededAttempts = 0
local neededAttempts = 4
local fishAttacker, fishHash = AddRelationshipGroup("FKING_FISH")
local fisherMan, fisherManHash = AddRelationshipGroup("FKING_FISHERMAN")
local lastFish = nil

SetRelationshipBetweenGroups(5, fishHash, fisherManHash)
SetRelationshipBetweenGroups(5, fisherManHash, fishHash)

-- Events
AddEventHandler('onResourceStop', function(resource)
  if resource == GetCurrentResourceName() then
    if fishingRod and fishingRod:Exists() then
      fishingRod:Delete()
      fishingRod = nil
      Ped(PlayerPedId()):ClearTasks()
      if castedLine then
        Utils.ClearLoading()
      end
    end

    if lastFish then
      local fishEntity = NetworkGetEntityFromNetworkId(lastFish)
      if fishEntity and DoesEntityExist(fishEntity) then
        DetachEntity(fishEntity)
        DeleteEntity(fishEntity)
        fishEntity = nil
        lastFish = nil
      end
    end
  end
end)

RegisterNetEvent("lx_fishing-client:startFishing")
AddEventHandler("lx_fishing-client:startFishing", function(usedBait)
	QBCore.Functions.TriggerCallback("lx_fishing-server:hasItem", function(haveRod, rodData)
    if haveRod then
      local ped = Ped(PlayerPedId())
      local lastVeh = GetVehiclePedIsIn(ped.handle, true)
      local nearWater, distance = ped:FacingWater()
      if QB_Fishing.debugging then Logger.Info("Rod Testing", "Near: " .. tostring(nearWater) .. " | Dist: " .. distance) end
      -- if nearWater and distance <= 10.0 then
      if nearWater then
        if QB_Fishing.debugging then print("close enough, create prop") end
        local inZone, zoneType = Utils.GetZoneType()
        if inZone then
          if zoneType == "dolphin" or zoneType == "shark" or zoneType == "whale" then
            local vehModel = GetDisplayNameFromVehicleModel(GetEntityModel(lastVeh))
            if vehModel ~= "TUG" then
              QBCore.Functions.Notify("You can't catch this type of fish, without a bigger boat", "error", 3000)
              return
            end
          end
        end

        currentBait = usedBait
        Utils.CreateRod()
        fishingThread = Thread(Fishing, true, 5)
      else
        QBCore.Functions.Notify("You aren't close enough to the water, to start fishing!", "error", 3000)
      end
    else
      QBCore.Functions.Notify("You don't have a fishing rod!", "error", 3000)
    end
  end, "fishing_rod")
end)

RegisterNetEvent("lx_fishing-client:fishing:startMinigame")
AddEventHandler("lx_fishing-client:fishing:startMinigame", function(captainsId, state, bait)
  fishingState = state
  currentBait = bait
  print("starting minigame", fishingState, currentBait)
  local Skillbar = exports['qb-skillbar']:GetSkillbarObject()
  neededAttempts, difficultyTime = GetBiteDifficulty()
  Skillbar.Start({
    duration = difficultyTime,
    pos = math.random(10, 30),
    width = math.random(10, 20),
  }, function()
    if succeededAttempts + 1 >= neededAttempts then
      -- Finish
      TriggerServerEvent("lx_fishing-server:fishing:updateState", "SUCCESS", captainsId, currentZone)
    else
      -- Repeat
      Skillbar.Repeat({
        duration = difficultyTime,
        pos = math.random(10, 40),
        width = math.random(10, 20),
      })
      succeededAttempts = succeededAttempts + 1
    end
  end, function()
    -- Fail
    TriggerServerEvent("lx_fishing-server:fishing:updateState", "FAILED", captainsId, currentZone)
  end)
end)

RegisterNetEvent("lx_fishing-client:fishing:attachFish")
AddEventHandler("lx_fishing-client:fishing:attachFish", function()
  local lastVeh = GetPlayersLastVehicle()
  local vehCoords = GetEntityCoords(lastVeh, false)
  local fish = NetworkGetEntityFromNetworkId(lastFish)
  SetEntityHealth(fish, 0) -- Kill the fkin fish
  AttachEntityToEntity(fish, lastVeh, GetEntityBoneIndexByName(lastVeh, "engine"), -1.2, -10.0, -3.0, 0.0, 190.0, 100.0, false, false, false, true, 2, true)
end)

-- Methods
Fishing = function()
  local ped = Ped(PlayerPedId())
  local pedPos = ped:Position()
  if ped:Dead() then
    ped:ClearTasks()
    Utils.DeleteRod()
    print("Fishing stopped as you died!")
  end

  if fishingStarted then
    if IsControlJustPressed(0, 202) or IsDisabledControlJustPressed(0, 202) then -- Backspace or ESC pressed
      Utils.StopFishing()
      QBCore.Functions.Notify("You put your fishing rod away!", "success", 3000)
    end

    if not castedLine then
      if ped:Swimming() then
        Utils.StopFishing()
        QBCore.Functions.Notify("You can't fish whilst you're swimming!", "error", 3000)
      end

      Utils.TopLeft("Cast your line by pressing ~INPUT_DETONATE~")
      if IsControlJustPressed(0, 47) then
        Utils.RequestAnim("amb@world_human_stand_fishing@idle_a")
        Utils.DeleteRod() -- Delete and recreate the fishing rod at a different rotation, so it looks better in the hand
        Utils.CreateRod()
        AttachEntityToEntity(fishingRod.handle, ped.handle, ped:BoneIndex(18905), 0.15, 0.10, 0.01, 50.0, 95.0, 180.0, true, true, false, true, 1, true)
        castedLine = true
        ped:PlayAnim("amb@world_human_stand_fishing@idle_a", "idle_b", 8.0, -8, -1, 31, 0.0, false, false, false)
        Utils.ShowLoading("Waiting for fish to bite")
      end
    else
      if timeoutState == "NONE" then
        timeoutState = "CREATED"
        local timer = GetBiteTime()
        if QB_Fishing.debugging then print("timeout timer is", timer) end
        
        QBCore.Functions.Progressbar("fishing", "Waiting for a bite...", timer, false, true, {
          disableMovement = true,
          disableCarMovement = false,
          disableMouse = false,
          disableCombat = true
        })

        SetTimeout(timer, function()
          if fishingStarted and castedLine then -- Double check we're still fishing
            timeoutState = "FINISHED"
            succeededAttempts = 0
            neededAttempts, difficultyTime = GetBiteDifficulty()
            neededAttempts = 1

            if QB_Fishing.debugging then print("Needed attempts", neededAttempts, difficultyTime) end
            QBCore.Functions.Notify("A fish has bitten the bait, get ready to reel it in...", "success", 1000)
            local inZone, zoneType = Utils.GetZoneType()
            if inZone then
              if currentBait == "large_fish_bait" then
                print("in rare fish zone wiggaaaaa", zoneType)
                local nearbyPlayers = Utils.GetNearbyPlayers() -- Double check player count
                if #nearbyPlayers >= 3 then -- change to 3 for testing
                  print("enough crewmen 1")
                  if zoneType == "dolphin" then
                    local loadedModel, modelHash = Utils.RequestModel("a_c_dolphin")
                    if loadedModel then
                      local ped = PlayerPedId()
                      local coords = GetEntityCoords(ped)
                      local fishyFucker = CreatePed(29, modelHash, coords.x + math.random(1, 4), coords.y + math.random(1, 4), coords.z - 1.5, GetEntityHeading(currVeh), true, false) -- Create the fkin fish
                      local oldFish = NetworkGetEntityFromNetworkId(lastFish)
                      if oldFish and DoesEntityExist(oldFish) then
                        if IsEntityAttachedToEntity(oldFish, GetPlayersLastVehicle()) then
                          DetachEntity(oldFish)
                        end

                        DeleteEntity(oldFish)
                        lastFish = nil
                      end
                      lastFish = NetworkGetNetworkIdFromEntity(fishyFucker)

                      SetPedRelationshipGroupHash(ped, fisherManHash)
                      SetPedFleeAttributes(fishyFucker, 0, false)
                      SetPedRelationshipGroupHash(fishyFucker, fishHash)

                      GiveWeaponToPed(fishyFucker, GetHashKey("WEAPON_ANIMAL"), 200, true, true)
                      SetCanAttackFriendly(fishyFucker, true, true)
                      SetPedCombatAttributes(fishyFucker, 46, true)
                      TaskWanderStandard(fishyFucker, 10.0, 10)

                      local fishBlip = AddBlipForEntity(fishyFucker)
                      SetBlipSprite(fishBlip, 303)
                      SetBlipColour(fishBlip, 1)
                      SetBlipAsShortRange(fishBlip, true)
                      BeginTextCommandSetBlipName("STRING")
                      AddTextComponentString("Dolphin")
                      EndTextCommandSetBlipName(fishBlip)
                    end
                  elseif zoneType == "shark" then
                    local loadedModel, modelHash = Utils.RequestModel("a_c_sharktiger")
                    if loadedModel then
                      local ped = PlayerPedId()
                      local coords = GetEntityCoords(ped)
                      local fishyFucker = CreatePed(29, modelHash, coords.x + math.random(3, 7), coords.y + math.random(3, 7), coords.z - 10.0, GetEntityHeading(ped), true, false) -- Create the fkin fish
                      local oldFish = NetworkGetEntityFromNetworkId(lastFish)
                      if oldFish and DoesEntityExist(oldFish) then
                        if IsEntityAttachedToEntity(oldFish, GetPlayersLastVehicle()) then
                          DetachEntity(oldFish)
                        end

                        DeleteEntity(oldFish)
                        lastFish = nil
                      end
                      lastFish = NetworkGetNetworkIdFromEntity(fishyFucker)

                      SetPedRelationshipGroupHash(ped, fisherManHash)
                      SetPedFleeAttributes(fishyFucker, 0, false)
                      SetPedRelationshipGroupHash(fishyFucker, fishHash)

                      GiveWeaponToPed(fishyFucker, GetHashKey("WEAPON_ANIMAL"), 200, true, true)
                      SetCanAttackFriendly(fishyFucker, true, true)
                      SetPedCombatAttributes(fishyFucker, 46, true)
                      TaskWanderStandard(fishyFucker, 10.0, 10)

                      local fishBlip = AddBlipForEntity(fishyFucker)
                      SetBlipSprite(fishBlip, 303)
                      SetBlipColour(fishBlip, 1)
                      SetBlipAsShortRange(fishBlip, true)
                      BeginTextCommandSetBlipName("STRING")
                      AddTextComponentString("Shark")
                      EndTextCommandSetBlipName(fishBlip)
                    end
                  elseif zoneType == "whale" then
                    local loadedModel, modelHash = Utils.RequestModel("a_c_killerwhale")
                    if loadedModel then
                      local ped = PlayerPedId()
                      local coords = GetEntityCoords(ped)
                      local fishyFucker = CreatePed(29, modelHash, coords.x + math.random(1, 4), coords.y + math.random(1, 4), coords.z - 1.5, GetEntityHeading(currVeh), true, false) -- Create the fkin fish
                      local oldFish = NetworkGetEntityFromNetworkId(lastFish)
                      if oldFish and DoesEntityExist(oldFish) then
                        if IsEntityAttachedToEntity(oldFish, GetPlayersLastVehicle()) then
                          DetachEntity(oldFish)
                        end

                        DeleteEntity(oldFish)
                        lastFish = nil
                      end
                      lastFish = NetworkGetNetworkIdFromEntity(fishyFucker)

                      SetPedRelationshipGroupHash(ped, fisherManHash)
                      SetPedFleeAttributes(fishyFucker, 0, false)
                      SetPedRelationshipGroupHash(fishyFucker, fishHash)

                      GiveWeaponToPed(fishyFucker, GetHashKey("WEAPON_ANIMAL"), 200, true, true)
                      SetCanAttackFriendly(fishyFucker, true, true)
                      SetPedCombatAttributes(fishyFucker, 46, true)
                      TaskWanderStandard(fishyFucker, 10.0, 10)

                      local fishBlip = AddBlipForEntity(fishyFucker)
                      SetBlipSprite(fishBlip, 303)
                      SetBlipColour(fishBlip, 1)
                      SetBlipAsShortRange(fishBlip, true)
                      BeginTextCommandSetBlipName("STRING")
                      AddTextComponentString("Whale")
                      EndTextCommandSetBlipName(fishBlip)
                    end
                  end
                else
                  print("You don't have enough crewman to catch this type of fish!", #nearbyPlayers)
                  QBCore.Functions.Notify("You don't have enough crewman to catch this type of fish!", "error", 3000)
                end
              end
            end
            
            Wait(1500)

            local Skillbar = exports['qb-skillbar']:GetSkillbarObject()
            Skillbar.Start({
              duration = difficultyTime,
              pos = math.random(10, 30),
              width = math.random(10, 20),
            }, function()
              if succeededAttempts + 1 >= neededAttempts then
                -- Finish
                timeoutState = "NONE"
                succeededAttempts = 0
                Utils.StopFishing()
                if inZone then
                  if currentBait == "large_fish_bait" then
                    if zoneType ~= "turtle" then -- Need to be in a dolphin, shark or whale zone
                      local nearbyPlayers = Utils.GetNearbyPlayers() -- Double check player count
                      if #nearbyPlayers >= 3 then -- change to 3 for testing
                        print("enough crewmen 2")
                        QBCore.Functions.Notify("Inform your crew, three of them will have 10 seconds until they'll have to start pulling and reeling in the fish.", "success", 10000)
                        SetTimeout(10000, function()
                          TriggerServerEvent("lx_fishing-server:fishing:requestMinigame", nearbyPlayers, fishingState, currentBait)
                        end)
                      else
                        print("You don't have enough crewman to catch this type of fish!", #nearbyPlayers)
                        QBCore.Functions.Notify("You don't have enough crewman to catch this type of fish!", "error", 3000)
                      end
                      return
                    end
                  end
                end
                TriggerServerEvent("lx_fishing-server:fishing:catchFish", currentBait, fishingState, currentZone)
              else
                -- Repeat
                Skillbar.Repeat({
                  duration = math.random(700, 1250),
                  pos = math.random(10, 40),
                  width = math.random(10, 20),
                })
                succeededAttempts = succeededAttempts + 1
              end
            end, function()
              -- Fail
              timeoutState = "NONE"
              Utils.StopFishing()
              QBCore.Functions.Notify("The fish got away!", "error", 3000)
            end)
          else
            if QB_Fishing.debugging then print("we didn't continue as you're no longer fishing!") end
          end
        end)
      end
    end
  end
end

function GetBiteTime()
  local time = 0

  if fishingState == 0 then
    time = 500
  elseif fishingState == 1 then
    time = math.random(QB_Fishing.biteTimes.land.start, QB_Fishing.biteTimes.land.finish)
  elseif fishingState == 2 then
    if currentBait == "medium_fish_bait" or currentBait == "large_fish_bait" then
      time = math.random(QB_Fishing.biteTimes.deep.start, QB_Fishing.biteTimes.deep.finish)
    else
      time = math.random(QB_Fishing.biteTimes.land.start, QB_Fishing.biteTimes.land.finish)
    end
  elseif fishingState == 3 then
    if currentBait == "large_fish_bait" then
      time = math.random(QB_Fishing.biteTimes.rare.start, QB_Fishing.biteTimes.rare.finish)
    elseif currentBait == "medium_fish_bait" then
      time = math.random(QB_Fishing.biteTimes.deep.start, QB_Fishing.biteTimes.deep.finish)
    else
      time = math.random(QB_Fishing.biteTimes.land.start, QB_Fishing.biteTimes.land.finish)
    end
  end

  return time
end

function GetBiteDifficulty()
  local difficulty = 0
  
  if fishingState == 0 then -- Default
    return 1, 1500
  elseif fishingState == 1 then -- Land Fishing
    return 2, math.random(QB_Fishing.biteTimes.land.start, QB_Fishing.biteTimes.land.finish) / 4
  elseif fishingState == 2 then -- Deep Fishing
    if currentBait == "medium_fish_bait" or currentBait == "large_fish_bait" then -- If we use medium or large bait then get a medium sized fish
      return 4, math.random(QB_Fishing.biteTimes.deep.start, QB_Fishing.biteTimes.deep.finish) / 4
    else -- If we use small bait in deep waters, get small sized fish
      return 2, math.random(QB_Fishing.biteTimes.land.start, QB_Fishing.biteTimes.land.finish) / 4
    end
  elseif fishingState == 3 then -- Rare Fishing
    if currentBait == "large_fish_bait" then
      return 6, math.random(QB_Fishing.biteTimes.rare.start, QB_Fishing.biteTimes.rare.finish) / 4
    elseif currentBait == "medium_fish_bait" then
      return 4, math.random(QB_Fishing.biteTimes.deep.start, QB_Fishing.biteTimes.deep.finish) / 4
    else
      return 2, math.random(QB_Fishing.biteTimes.land.start, QB_Fishing.biteTimes.land.finish) / 4
    end
  end

  return difficulty
end
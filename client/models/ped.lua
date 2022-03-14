Ped = {}
PedMethods = {}

PedMethods.__call = function(self, handle)
	local object = setmetatable({}, {
		__index = self,
		__tonumber = function(self) return self.handle end,
		__tostring = function(self) return "Ped: " .. self.handle end,
		__type = "Ped",
	})
  if type(handle) == "number" then
    if DoesEntityExist(handle) then
      object.handle = handle
      object.model = GetEntityModel(object.handle)
    else
      assert(nil, "The entity doesn't exist!")
    end
  else
    assert(nil, "The second parameter expected number, but got " .. type(handle))
  end
	return object
end

PedMethods.__index = {
	Handle = function(self)
		if not self:Exists() then
			warning("The Ped doesn't exist!")
			return
		end

		return self.handle
	end,

	Exists = function(self)
		return (DoesEntityExist(self.handle) == 1 and true or false)
	end,

	Position = function(self)
		if not self:Exists() then
			warning("The Ped doesn't exist!")
			return
		end
		local coords = GetEntityCoords(self.handle)
		local heading = GetEntityHeading(self.handle)
		return Coords(coords.x, coords.y, coords.z, heading)
	end,

	SetPosition = function(self, xCoord, yCoord, zCoord, hCoord)
		if xCoord == nil or type(xCoord) ~= "number" then Logger.Error("Ped Class", "The xCoord wasn't a number!") return end
		if yCoord == nil or type(yCoord) ~= "number" then Logger.Error("Ped Class", "The yCoord wasn't a number!") return end
		if zCoord == nil or type(zCoord) ~= "number" then Logger.Error("Ped Class", "The zCoord wasn't a number!") return end
		if hCoord ~= nil and type(hCoord) ~= "number" then Logger.Error("Ped Class", "The hCoord wasn't a number!") return end

		if not self:Exists() then
			warning("The Ped doesn't exist!")
			return
		end
		
		SetEntityCoords(self.handle, xCoord, yCoord, zCoord)
		if hCoord ~= nil then
			SetEntityHeading(self.handle, hCoord)
		end
	end,
	
	InsideVehicle = function(self)
		if not self:Exists() then
			warning("The Ped doesn't exist!")
			return
		end
		return IsPedSittingInAnyVehicle(self.handle)
	end,

	PlayAnim = function(self, animDict, animName, blendInSpeed, blendOutSpeed, duration, flag, playbackRate, lockX, lockY, lockZ) 
		if not self:Exists() then
			warning("The Ped doesn't exist!")
			return
		end

		if animDict == nil or type(animDict) ~= "string" then Logger.Error("Ped Class", "The animDict wasn't a string!") return end
		if animName == nil or type(animName) ~= "string" then Logger.Error("Ped Class", "The animName wasn't a string!") return end
		
		TaskPlayAnim(self.handle, animDict, animName, blendInSpeed or 8.0, blendOutSpeed or 8.0, duration or -1, flag or -1, playbackRate or 0, lockX or false, lockY or false, lockZ or false)
		
		-- print(self.handle, animDict, animName, flag, IsEntityPlayingAnim(self.handle, animDict, animName, flag))
		-- while not IsEntityPlayingAnim(self.handle, animDict, animName, flag or -1) do 
			-- Wait(0)
		-- end

		return true
	end,

	ClearTasks = function(self)
		if self:Exists() then
			ClearPedTasks(self.handle)
		else
			warning("The Ped doesn't exist!")
		end
	end,

  FacingWater = function(self)
    local headPos = GetPedBoneCoords(self.handle, 31086, 0.0, 0.0, 0.0)
    local offsetPos = GetOffsetFromEntityInWorldCoords(self.handle, 0.0, 50.0, -25.0)
    local hit, hitPos = TestProbeAgainstWater(headPos.x, headPos.y, headPos.z, offsetPos.x, offsetPos.y, offsetPos.z)
    local distance = Vdist(headPos.x, headPos.y, headPos.z, hitPos.x, hitPos.y, hitPos.z)
    return hit, distance
  end,

	BoneIndex = function(self, index)
		if self:Exists() then
			return GetPedBoneIndex(self.handle, index)
		else
			Logger.Error("Ped Class", "The Ped doesn't exist!")
		end
	end,

	Dead = function(self)
		return IsEntityDead(self.handle)
	end,

	Swimming = function(self)
		return IsPedSwimming(self.handle)
	end
}

setmetatable(Ped, PedMethods)

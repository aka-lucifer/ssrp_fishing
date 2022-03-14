Rental = {}
RentalMethods = {}

RentalMethods.__call = function(self, model, position)
	local object = setmetatable({}, {
		__index = self,
		__tonumber = function(self) return self.handle end,
		__tostring = function(self) return "Ped: " .. self.handle end,
		__type = "Rental Vehicle",
	})
  if type(model) == "string" or type(model) == "number" then
    local loadedModel, hashKey = Utils.RequestModel(model)
    
    if loadedModel then
      object.model = hashKey
      if type(model) == "string" then object.modelName = model end

			if Utils.Type(position) ~= 'Coords' then
				if type(position) ~= 'vector4' then
					error("The position parameter expected Coords or Vector4, but got " ..type(position))
				end
      end

      object.handle = CreateVehicle(object.model, position.x, position.y, position.z, position.heading, true, true)

			SetModelAsNoLongerNeeded(object.model)
			RequestCollisionAtCoord(position.x, position.y, position.z)
			
			while not HasCollisionLoadedAroundEntity(object.handle) do
				RequestCollisionAtCoord(position.x, position.y, position.z)
				Wait(0)
			end

			SetEntityInvincible(object.handle, false)
			SetEntityVisible(object.handle, true)
			SetVehRadioStation(object.handle, "OFF")
      TaskWarpPedIntoVehicle(PlayerPedId(), object.handle, -1)
      exports["LegacyFuel"]:SetFuel(object.handle, 100)
      SetVehicleDirtLevel(object.handle, 0)
      WashDecalsFromVehicle(object.handle, 100)
      RemoveDecalsFromVehicle(object.handle, false)
    else
      Logger.Error("Vehicle Class", "Vehicle doesn't exist or request timed out!")
      return nil
    end
  else
    assert(nil, "Second parameter was "..type(p1).." but expected string or number")
  end

	return object
end

RentalMethods.__index = {
	Exists = function(self)
		return (DoesEntityExist(self.handle) == 1 and true or false)
	end,

	GetNetId = function(self)
		if self:Exists() then
			return NetworkGetNetworkIdFromEntity(self.handle)
		end
	end,

	GetBodyHealth = function(self)
		if self:Exists() then
			return GetVehicleBodyHealth(self.handle)
		end
	end,

	GetDirtLevel = function(self)
		if self:Exists() then
			return GetVehicleDirtLevel(self.handle)
		end
	end,

	GetEngineHealth = function(self)
		if self:Exists() then
			return GetVehicleEngineHealth(self.handle)
		end
	end,

	GetPetrolTankHealth = function(self)
		if self:Exists() then
			return GetVehiclePetrolTankHealth(self.handle)
		end
	end,

	GetFuelLevel = function(self)
		if self:Exists() then
			return GetVehicleFuelLevel(self.handle)
		end
	end,

	Return = function(self)
		if self:Exists() then
      TriggerServerEvent("lx_fishing-server:returnVeh", self:GetNetId(), self:GetBodyHealth(), locationKey)
		end
	end,

	GetPedInSeat = function(self, seat)
		if type(seat) ~= "number" then assert(nil, "Seat parameter expected number, but got " .. type(seat)) return end
		if self:Exists() then
			return GetPedInVehicleSeat(self.handle, seat)
		else
			warning("Vehicle doesn't exist!")
		end
	end,

	Plate = function(self)
		if self:Exists() then
			return GetVehicleNumberPlateText(self.handle)
		end
	end
}

setmetatable(Rental, RentalMethods)
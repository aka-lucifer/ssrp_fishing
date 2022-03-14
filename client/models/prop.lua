
Prop = {}
PropMethods = {}

PropMethods.__call = function(self, model, coords, isNetworked)
	local object = setmetatable({}, {
		__index = self,
		__tostring = function(self)
			return ('Prop<%s>'):format(table.concat({'id: '..self.handle, 'model: '..(self.modelName or self.model)}))
		end,
	})

  if Utils.Type(coords) ~= 'Coords' then
    if type(coords) ~= 'vector4' then
      error("The coords parameter expected Coords or Vector4, but got " ..type(coords))
    end
  end

  if type(isNetworked) ~= 'boolean' then error("The isNetwork parameter expected boolean, but got " ..type(isNetworked)) end
  
	local loadedModel, hashKey = Utils.RequestModel(model)
	if loadedModel then
    object.modelName = model
    object.model = hashKey
    object.handle = CreateObject(object.model, coords.x, coords.y, coords.z, isNetworked, true, false)
    while not DoesEntityExist(object.handle) do Wait(0) end
  end

	return object
end

PropMethods.__index = {
	Exists = function(self)
		return (DoesEntityExist(self.handle) == 1)
	end,

	WaitForExistence = function(self)
		while not self:Exists() do Wait(0) end
	end,

	Delete = function(self)
		if not self:Exists() then
			warning('Prop doesn\'t exists!')
			return
		end
		DeleteEntity(self.handle)
	end,

	Remove = function(self)
		if not self:Exists() then
			warning('Prop doesn\'t exists!')
			return
		end
		DeleteEntity(self.handle)
	end,

	GetOwner = function(self)
		if self:Exists() then
			return NetworkGetEntityOwner(self.handle)
		end
	end,

	GetNetId = function(self)
		if self:Exists() then
			return NetworkGetNetworkIdFromEntity(self.handle)
		end
	end,

	Position = function(self)
		return Coords(GetEntityCoords(self.handle), GetEntityHeading(self.handle))
	end
}

setmetatable(Prop, PropMethods)
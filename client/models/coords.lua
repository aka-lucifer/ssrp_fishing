
Coords = {}
CoordsMethods = {}

-- init
CoordsMethods.__call = function(self, ...)
	local o = setmetatable({}, {
		__index = self,
		__tostring = function(self)
			return ("Coords<%s>"):format(table.concat({'X: '..self.x, 'Y: '..self.y, 'Z: '..self.z, 'W: '..self.w}, ', '))
		end,
		__tonumber = function(self)
			return vec(self.x, self.y, self.z)
		end,
		__type = 'Coords',
		__unpack = function(self)
			return self.x, self.y, self.z, self.w
		end,
		__pack = function(self)
			return {x=self.x, y=self.y, z=self.z, w=self.w}
		end
	})
	local params = {...}
	o.x = 0.0
	o.y = 0.0
	o.z = 0.0
	o.w = 0.0
	if type(params[1]) == 'number' then
		-- is passing each parameter
		o.x = tonumber(params[1]) or 0.0
		o.y = tonumber(params[2]) or 0.0
		o.z = tonumber(params[3]) or 0.0
		o.w = tonumber(params[4]) or 0.0
	elseif type(params[1]) == 'vector2' then
		-- is passing X and Y
		o.x, o.y = params[1].x, params[1].y
	elseif type(params[1]) == 'vector3' then
		-- is passing X Y and Z
		o.x, o.y, o.z = params[1].x, params[1].y, params[1].z
		if type(params[2]) == 'number' then
			o.w = tonumber(params[2]) or 0.0
		end
	elseif type(params[1]) == 'vector4' then
		-- is passing X Y Z and W
		o.x, o.y, o.z, o.w = params[1].x, params[1].y, params[1].z, params[1].w
	elseif type(params[1]) == 'table' then
		o.x = tonumber(params[1].x) or 0.0
		o.y = tonumber(params[1].y) or 0.0
		o.z = tonumber(params[1].z) or 0.0
		o.w = tonumber((params[1].w or params[1].heading)) or 0.0
	else
		assert(nil, 'None of the passed parameters are number, vector2, vector3, vector4 or a table')
	end

	if math.type(o.x) == 'integer' then
		o.x = o.x + 0.0
	end
	if math.type(o.y) == 'integer' then
		o.y = o.y + 0.0
	end
	if math.type(o.z) == 'integer' then
		o.z = o.z + 0.0
	end
	if math.type(o.w) == 'integer' then
		o.w = o.w + 0.0
	end
	o.heading = o.w
	return o
end

-- methods
CoordsMethods.__index = {
	AddBlip = function(self, spriteId, shortRange, blipName, scale, color, alpha)
		self.blip = AddBlipForCoord(self.x, self.y, self.z)
		if type(spriteId) ~= 'number' then
			assert(nil, 'The spriteId wasn\'t a number.')
		end
		SetBlipSprite(self.blip, spriteId)
		SetBlipColour(self.blip, color or 0)
		SetBlipAlpha(self.blip, alpha or 255)
		SetBlipScale(self.blip, scale or 1.0)
		SetBlipAsShortRange(self.blip, shortRange or false)
		if blipName then
			AddTextComponentSubstringBlipName(self.blip)
			BeginTextCommandSetBlipName(blipName)
			EndTextCommandSetBlipName(self.blip)
		end
		return self.blip
	end,

	UpdateX = function(self, v)
		if math.type(v) == 'float' then
			self.x = v
		elseif math.type(v) == 'integer' then
			self.x = v + 0.0
		else
			warning('The new X need to be an integer or a float, not a '..type(v))
		end
	end,
	
	UpdateY = function(self, v)
		if math.type(v) == 'float' then
			self.y = v
		elseif math.type(v) == 'integer' then
			self.y = v + 0.0
		else
			warning('The new Y need to be an integer or a float, not a '..type(v))
		end
	end,
	
	UpdateZ = function(self, v)
		if math.type(v) == 'float' then
			self.z = v
		elseif math.type(v) == 'integer' then
			self.z = v + 0.0
		else
			warning('The new Z need to be an integer or a float, not a '..type(v))
		end
	end,
	
	UpdateW = function(self, v)
		if math.type(v) == 'float' then
			self.w = v
		elseif math.type(v) == 'integer' then
			self.w = v + 0.0
		else
			warning('The new W need to be an integer or a float, not a '..type(v))
		end
	end,

	Dist = function(self, coords)
		return #(vector3(self.x, self.y, self.z) - vector3(coords.x, coords.y, coords.z))
	end
}

-- class
setmetatable(Coords, CoordsMethods)

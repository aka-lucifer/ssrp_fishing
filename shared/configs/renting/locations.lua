QB_Fishing.renting.locations = {
  ["rent"] = {
    [1] = vector3(-1611.59, 5261.44, 4.0 - 1.02),
    [2] = vector3(-1604.1, -1131.96, 2.14 - 0.98)
  },

  ["spawn"] = {
    ["squalo"] = {
      [1] = vector4(-1603.29, 5260.55, 0.4, 20.39),
      [2] = vector4(-1629.82, -1168.36, 1.18 - 2.0, 132.53)
    },

    
    ["seashark"] = {
      [1] = vector4(-1603.29, 5260.55, 0.4, 20.39),
      [2] = vector4(-1629.82, -1168.36, 1.18 - 2.0, 132.53)
    },

    
    ["dinghy"] = {
      [1] = vector4(-1603.29, 5260.55, 0.4, 20.39),
      [2] = vector4(-1629.82, -1168.36, 1.18 - 2.0, 132.53)
    },

    
    ["marquis"] = {
      [1] = vector4(-1599.81, 5263.62, 0.53, 17.8),
      [2] = vector4(-1637.23, -1175.03, 1.08, 125.34)
    },

    
    ["tug"] = {
      [1] = vector4(-1583.48, 5266.8, 1.16, 29.24),
      [2] = vector4(-1650.0, -1186.41, 1.38, 127.15)
    }
  }
}

if QB_Fishing.debugging then print("locations loaded!", json.encode(QB_Fishing.renting.locations)) end
------------------------------------------------------------------------------------
-- LX Fishing
-- Written By akaLucifer#0103
-- Releasing or Claiming this as your own is against, this resources License
------------------------------------------------------------------------------------
fx_version 'bodacious'
game 'gta5'

shared_scripts {
  "shared/shared.lua",
  "shared/configs/**/*.lua"
}

client_scripts {
  "client/models/*.lua",
  "client/*.lua"
}

server_scripts {
  "server/models/*.lua",
  "server/*.lua"
}

-- NOTES
-- ADD ALL FISHING RELATED ITEMS TO INVENTORY RESOURCE ON BETA GIT (fishing_road, baits, fishtypes, etc)
-- ["fishing_rod"] 			 		 = {["name"] = "fishing_rod", 					["label"] = "Fishing Rod", 				["weight"] = 5000, 		["type"] = "item", 		["image"] = "fishing_rod.png", 			["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,	   ["combinable"] = nil,   ["description"] = "A fishing rod for adventures with friends!"},
-- ["shark_meat"] 			         	 = {["name"] = "shark_meat", 			        	["label"] = "Shark Meat",                 		["weight"] = 1111,      ["type"] = "item",      ["image"] = "shark_meat.png",             ["unique"] = false,     ["useable"] = true,     ["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "Shark meat yes that's it!"},
-- ["dolphin_meat"] 			         	 = {["name"] = "dolphin_meat", 			        	["label"] = "Dolphin Meat",                 		["weight"] = 1111,      ["type"] = "item",      ["image"] = "dolphin_meat.png",             ["unique"] = false,     ["useable"] = true,     ["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "Dolphin meat yes that's it!"},
-- ["turtle_meat"] 			         	 = {["name"] = "turtle_meat", 			        	["label"] = "Turtle Meat",                 		["weight"] = 1111,      ["type"] = "item",      ["image"] = "turtle_meat.png",             ["unique"] = false,     ["useable"] = true,     ["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "Turtle meat yes that's it!"},
-- ["whale_meat"] 			         	 = {["name"] = "whale_meat", 			        	["label"] = "Whale Meat",                 		["weight"] = 1111,      ["type"] = "item",      ["image"] = "whale_meat.png",             ["unique"] = false,     ["useable"] = true,     ["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "Whale meat yes that's it!"},
-- ["whitefish_meat"] 			         	 = {["name"] = "whitefish_meat", 			        	["label"] = "Whitefish Meat",                 		["weight"] = 1111,      ["type"] = "item",      ["image"] = "whitefish_meat.png",             ["unique"] = false,     ["useable"] = true,     ["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "Whitefish meat yes that's it!"},
-- ["trout_meat"] 			         	 = {["name"] = "trout_meat", 			        	["label"] = "Trout Meat",                 		["weight"] = 1111,      ["type"] = "item",      ["image"] = "trout_meat.png",             ["unique"] = false,     ["useable"] = true,     ["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "Trout meat yes that's it!"},
-- ["pike_meat"] 			         	 = {["name"] = "pike_meat", 			        	["label"] = "Pike Meat",                 		["weight"] = 1111,      ["type"] = "item",      ["image"] = "pike_meat.png",             ["unique"] = false,     ["useable"] = true,     ["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "Pike meat yes that's it!"},
-- ["lobster_meat"] 			         	 = {["name"] = "lobster_meat", 			        	["label"] = "Lobster Meat",                 		["weight"] = 1111,      ["type"] = "item",      ["image"] = "lobster_meat.png",             ["unique"] = false,     ["useable"] = true,     ["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "Lobster meat yes that's it!"},
-- ["salmon_meat"] 			         	 = {["name"] = "salmon_meat", 			        	["label"] = "Salmon Meat",                 		["weight"] = 1111,      ["type"] = "item",      ["image"] = "salmon_meat.png",             ["unique"] = false,     ["useable"] = true,     ["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "Salmon meat yes that's it!"},
-- ["roach_meat"] 			         	 = {["name"] = "roach_meat", 			        	["label"] = "Roach Meat",                 		["weight"] = 1111,      ["type"] = "item",      ["image"] = "roach_meat.png",             ["unique"] = false,     ["useable"] = true,     ["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "Roach meat yes that's it!"},
-- ["goldfish_meat"] 			         	 = {["name"] = "goldfish_meat", 			        	["label"] = "Goldfish Meat",                 		["weight"] = 1111,      ["type"] = "item",      ["image"] = "goldfish_meat.png",             ["unique"] = false,     ["useable"] = true,     ["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "Goldfish meat yes that's it!"},
-- ["crawfish_meat"] 			         	 = {["name"] = "crawfish_meat", 			        	["label"] = "Crawfish Meat",                 		["weight"] = 1111,      ["type"] = "item",      ["image"] = "crawfish_meat.png",             ["unique"] = false,     ["useable"] = true,     ["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "Crawfish meat yes that's it!"},
-- ["small_fish_bait"] 			         = {["name"] = "small_fish_bait", 					["label"] = "Small Fish Bait", 				["weight"] = 400, 		["type"] = "item", 		["image"] = "fishbait.png", 			["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,	   ["combinable"] = nil,   ["description"] = "Small fish bait"},
-- ["medium_fish_bait"] 			         = {["name"] = "medium_fish_bait", 					["label"] = "Medium Fish Bait", 				["weight"] = 400, 		["type"] = "item", 		["image"] = "fishbait.png", 			["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,	   ["combinable"] = nil,   ["description"] = "Medium fish bait"},
-- ["large_fish_bait"] 			         = {["name"] = "large_fish_bait", 					["label"] = "Large Fish Bait", 				["weight"] = 400, 		["type"] = "item", 		["image"] = "fishbait.png", 			["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,	   ["combinable"] = nil,   ["description"] = "Large fish bait"},

-- [ FEATURES ]
-- Zones for rare fishing spots
-- Boat Rentals (You get less than the rental price based on how badly, the boat is damaged, e.g. if the boat is 50% damaged then the return price is (rental_price) + 1/2 rental_price)
-- Correct prop placement, with line casting
-- OOP Lua Classes
-- Skillbar for catching fishes, time and difficulty depends on the fish
-- Fishes you catch vary depending if you're fishing on land, on a boat in the ocean, or in a rare zone.
-- Fish black market selling (includes synced ped, animations with ped and yourself upon deal completion, dist checks for the deals)
-- Fish selling
-- The fish you retrieve is based on bait and location, you won't recieve a big fish using small fish bait in a deep fishing zone and vice versa.
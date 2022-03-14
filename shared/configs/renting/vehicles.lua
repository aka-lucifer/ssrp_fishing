QB_Fishing.rented = {}

QB_Fishing.renting.vehicles = {
  {name = "Squalo", model = "squalo", rental_price = 1500},
  {name = "Sea Shark", model = "seashark", rental_price = 2500},
  {name = "Dinghy", model = "dinghy", rental_price = 3000},
  {name = "Marquis", model = "marquis", rental_price = 5000},   
  {name = "Tug", model = "tug", rental_price = 8000}
}

if QB_Fishing.debugging then print("vehicles loaded loaded!", json.encode(QB_Fishing.renting.vehicles)) end
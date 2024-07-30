extends Commons
#For tribe and army management

var resources = {}
var army = []
var buildings = []

func add_to_army(monster, level = 1):
	var monster_info = {
		"kind": monster,
		"name": monster_stats[monster]["name"],
		"level": level,
	}
	army.append(monster_info)
	print("Current army: ")
	print(army)
func add_to_buildings(building, state, position, level = 1):
	var building_info = {
		"kind": building,
		#"name": monster_stats[monster]["name"],
		"state": state,								# BUILDINGS ARE PER STATE
		"position": position,
		"level": level,
	}
	buildings.append(building_info)
	print("Current buildings: ")
	print(buildings)

func level_monster(monster):
	#TODO resource consumition
	var unit_key = TribeManagement.army.find(monster)
	print(unit_key)
	print(monster)
	var costs = monster_stats[monster["kind"]]["levels"][monster["level"]+1]["cost"]
	if spend_resources(costs):
		TribeManagement.army[unit_key]["level"] += 1
	else:
		print("More Resources needed")

func clear_army():
	army.clear()


func spend_resources(resources_cost) -> bool:
	for resource in resources_cost:
		#Check if you have the resources
		if resources[resource] >= resources_cost[resource]:
			continue
		else:
			return false
			
	for resource in resources_cost:
		#Spènd the resources
		print("Spending " + resource + " " + str(resources_cost[resource]))
		resources[resource] -= resources_cost[resource]
	print("remaining resources:")
	print(resources)
	return true


func add_resources(resources_amount):
	for resource in resources_amount:
		resources[resource] += resources_amount[resource]
		print("Adding " + str(resource) + " " + str(resources_amount[resource]))



# Called when the node enters the scene tree for the first time.
func _ready():
	for i in RESOURCES:
		resources[i] = 500
	resources["SULFUR"] = 250
	resources["FOOD"] = 250
	resources["POISON"] = 100
	resources["DEMON_BLOOD"] = 0

	print("RESOURCES: ", resources)
	#resources["resource1"] = 999999
	#resources["resource2"] = 999999
	#resources["resource3"] = 999999


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

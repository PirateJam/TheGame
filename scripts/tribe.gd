extends Commons

@export var resource1: int = 999999
@export var resource2: int = 999999
@export var resource3: int = 999999

func spend_resources(resource1_cost: int, resource2_cost: int, resource3_cost: int) -> bool:
	if resource1 >= resource1_cost and resource2 >= resource2_cost and resource3 >= resource3_cost:
		resource1 -= resource1_cost
		resource2 -= resource2_cost
		resource3 -= resource3_cost
		return true
	return false

func add_resources(resource1_amount: int, resource2_amount: int, resource3_amount: int):
	resource1 += resource1_amount
	resource2 += resource2_amount
	resource3 += resource3_amount

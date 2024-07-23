extends Node

var units_state = []
func save_unit_state(unit):
	var unit_info = {
		"type": unit.unit_type,
	}
	units_state.append(unit_info)

func clear_units_state():
	units_state.clear()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

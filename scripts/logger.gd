extends Node


func error(message):
	print_rich("[color=red]ERROR: " + str(message) + "[/color]")

func warn(message):
	print_rich("[color=yellow]WARNING: " + str(message) + "[/color]")

func log(message):
	print("LOG: " + str(message))

'''CAN'T ACCESS `production`, therefore not usable
func debug(message):
	if !get_node("/root/Menu").production:
		log(message)'''

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

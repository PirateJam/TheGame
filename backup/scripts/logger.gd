extends Node


var escape = PackedByteArray([0x1b]).get_string_from_ascii()


func error(message):
	var code = "[1;32m"
	print("ERROR: " + str(message))

func warn(message):
	var code = "[1;93m"
	print("WARNING: " + str(message))

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

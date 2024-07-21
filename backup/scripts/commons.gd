extends Node
class_name Commons
enum MONSTER_TYPES {RANGED, MEELEE, CAVALRY}
enum MONSTER_KINDS {YIPEEE}	#this is just an example monster because I lack ideas:tm:

enum BUILDING_KINDS {WALL}

func get_building_textures(kind: BUILDING_KINDS, level):
	if level>5 or level<0:
		return [unknown_texture, unknown_texture]
	match kind:
		BUILDING_KINDS.WALL:
			return [load("res://assets/images/buildings/wall_front-" + str(level) + ".png"), load("res://assets/images/buildings/wall_side-" + str(level) + ".png")]

func get_monster_textures(kind: MONSTER_KINDS, level):
	if level>5 or level<0:
		return unknown_texture
	match kind:
		MONSTER_KINDS.YIPEEE:
			return load("res://assets/images/monsters/yippe_example_monster" + str(level) + ".png")


var unknown_texture = load("res://assets/images/misc/unknown.png")

const default_state_color = Color(255, 255 , 255, 0.2)
const hover_state_color = Color(255, 255, 255, 0.4)
const select_state_color = Color(200, 200, 255, 0.6)

const default_button_color = Color(229, 226 , 71, 0.2)
const hover_button_color = Color(229, 226 , 71, 0.4)
const select_button_color = Color(229, 226 , 71, 0.6)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

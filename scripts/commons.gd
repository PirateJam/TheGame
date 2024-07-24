extends Node2D
class_name Commons

enum BIOMES {FOREST, DESERT, SWAMP}

enum MONSTER_TYPES {RANGED, MEELEE, CAVALRY}
enum MONSTER_KINDS {YIPEEE, YIPEEEARCHER, YIPEEHORSE}	#this is just an example monster because I lack iDeas:tm:

enum BUILDING_KINDS {WALL, WITCH_HUT, }
enum ROTATION {FRONT, LEFT, BACK, RIGHT}

func get_biome_texture(biome: BIOMES):
	match biome:
		BIOMES.FOREST:
			return load("res://assets/images/biomes/forest.png")
		BIOMES.DESERT:
			return load("res://assets/images/biomes/desert.png")

func get_building_textures(kind: BUILDING_KINDS, level: int):
	if level>5 or level<0:
		return [unknown_texture, unknown_texture]
	match kind:
		BUILDING_KINDS.WALL:
			print("res://assets/images/buildings/wall_front-" + str(level) + ".png")
			return [load("res://assets/images/buildings/wall_front-" + str(level) + ".png"), load("res://assets/images/buildings/wall_side-" + str(level) + ".png")]

func get_monster_textures(kind: MONSTER_KINDS, level: int):
	if level>5 or level<0:
		return unknown_texture
	match kind:
		MONSTER_KINDS.YIPEEE:
			return load("res://assets/images/monsters/yippe_example_monster" + str(level) + ".png")
		MONSTER_KINDS.YIPEEEARCHER:
			return load("res://assets/images/monsters/yippe_example_monster" + str(level) + ".png")
		MONSTER_KINDS.YIPEEHORSE:
			return load("res://assets/images/monsters/yippe_example_monster" + str(level) + ".png")


var unknown_texture = load("res://assets/images/misc/unknown.png")


const map_size = 10
const state_view_zoom = 1.5

const controlled_default_state_color = Color(0.4, 1, 0.4, 0.3)
const controlled_hover_state_color = Color(0.4, 1, 0.4, 0.5)
const controlled_select_state_color = Color(0.4, 1, 0.4, 0.7)


const default_state_color = Color(1, 0.6 , 0.6, 0.2)
const hover_state_color = Color(1, 0.6, 0.6, 0.4)
const select_state_color = Color(1, 0.6, 0.6, 0.6)

const default_button_color = Color(0.847, 0.765, 0.015, 0.19)
const hover_button_color = Color(0.847, 0.765, 0.015, 0.25)
const select_button_color = Color(0.847, 0.765, 0.015, 0.35)



var tree_textures = [
	load("res://assets/images/misc/tree1.png"),
	load("res://assets/images/misc/tree2.png"),
	load("res://assets/images/misc/tree3.png"),
]														# OUTDATES / NOT USED

var forest_trees = [
	load("res://assets/images/misc/tree1.png"),
	load("res://assets/images/misc/tree2.png"),
]

var desert_trees = [
	load("res://assets/images/misc/tree3.png"),
]

var swamp_trees = [
	load("res://assets/images/misc/tree2.png"),
]

const forest_trees_amount = 8
const swamp_trees_amount = 10
const desert_trees_amount = 4




var font_data = load("res://assets/fonts/DaysOne.ttf")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

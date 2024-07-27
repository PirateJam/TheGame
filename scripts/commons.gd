extends Node2D
class_name Commons

enum BIOMES {FOREST, DESERT, SWAMP, WATER_BODY}
enum RESOURCES {WOOD, IRON, ELIXIR}

enum MONSTER_TYPES {RANGED, MEELEE, CAVALRY}
enum MONSTER_KINDS {YIPEEE, YIPEEEARCHER, YIPEEHORSE}	#this is just an example monster because I lack iDeas:tm:

enum BUILDING_KINDS {WALL, WITCH_HUT, COMMANDER_CAMP}
enum ROTATION {FRONT, LEFT, BACK, RIGHT}


var default_soundtrack = preload("res://assets/music/premix_loops/peace_premix.mp3")
var combatA_soundtrack = preload("res://assets/music/premix_loops/combatA_premix.mp3")
var combatB_soundtrack = preload("res://assets/music/premix_loops/combatB_premix.mp3")
var combatC_soundtrack = preload("res://assets/music/premix_loops/combatC_premix.mp3")


var building_info = {
	BUILDING_KINDS.WALL: {
		"cost": {"WOOD": 100, "IRON": 20},
		"rotatable": true,
		"texture": get_building_textures(BUILDING_KINDS.WALL, 1)
	},
	BUILDING_KINDS.COMMANDER_CAMP: {
		"cost": {"WOOD": 100, "IRON": 100},
		"rotatable": false,
		"texture": get_building_textures(BUILDING_KINDS.COMMANDER_CAMP, 1)
	}
}

func get_biome_texture(biome: BIOMES):
	match biome:
		BIOMES.FOREST:
			return load("res://assets/images/biomes/forest.png")
		BIOMES.DESERT:
			return load("res://assets/images/biomes/desert.png")
		BIOMES.SWAMP:
			return load("res://assets/images/biomes/swamp.png")
		BIOMES.WATER_BODY:
			return load("res://assets/images/biomes/water.png")
func get_biome_stateview(biome: BIOMES):
	match biome:
		BIOMES.FOREST:
			return load("res://assets/images/biomes/forest_stateview.png")
		BIOMES.DESERT:
			return load("res://assets/images/biomes/desert_stateview.png")
		BIOMES.SWAMP:
			return load("res://assets/images/biomes/swamp_stateview.png")
		BIOMES.WATER_BODY:
			return load("res://assets/images/biomes/water_stateview.png")

func get_building_textures(kind: BUILDING_KINDS, level = 1):
	if level>5 or level<0:
		return [unknown_texture, unknown_texture]
	match kind:
		BUILDING_KINDS.WALL:
			print("res://assets/images/buildings/wall_front-1.png")
			return [load("res://assets/images/buildings/wall_front-1.png"), load("res://assets/images/buildings/wall_side-1.png")]
		BUILDING_KINDS.COMMANDER_CAMP:
			return [load("res://assets/images/buildings/commander_camp.png"), load("res://assets/images/buildings/wall_side-" + str(level) + ".png")]

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

var aim_cursor = load("res://assets/images/misc/crosshair.png")


const map_size = 10
const state_view_zoom = 1.5


const controlled_default_state_color = Color(1, 1, 1, 0.3)
const controlled_hover_state_color = Color(1, 1, 1, 0.5)
const controlled_select_state_color = Color(1, 1, 1, 0.7)


const default_state_color = Color(1, 1 , 1, 0.2)
const hover_state_color = Color(1, 1, 1, 0.4)
const select_state_color = Color(1, 1, 1, 0.6)

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


#Monsters Data
var max_level = 5
var monster_stats = {
	MONSTER_KINDS.YIPEEE: {
			"locked": false,
			"name": "Yipee", 
			"type": MONSTER_TYPES.MEELEE,
			"levels": {
				1: {
					"stats": {
						"health": 100, 
						"attack_power": 20, 
						"attack_speed": 1.0, 
						"attack_range": 30.0, 
						"movement_speed": 100,
					},
					"cost": {
						"resource1": 100, 
						"resource2": 100, 
						"resource3": 100
					},
					"skills": { 
						0: "Strong Attack"
					}
				},
				2: {
					"stats": {
						"health": 200, 
						"attack_power": 25, 
						"attack_speed": 1.1, 
						"attack_range": 30.0, 
						"movement_speed": 105,
					},
					"cost": {
						"resource1": 200, 
						"resource2": 200, 
						"resource3": 200
					},
					"skills": {
					}
				},
				3: {
					"stats": {
						"health": 250, 
						"attack_power": 30, 
						"attack_speed": 1.2, 
						"attack_range": 30.0, 
						"movement_speed": 110,
					},
					"cost": {
						"resource1": 300, 
						"resource2": 300, 
						"resource3": 300
					},
					"skills": {
					}
				},
				4: {
					"stats": {
						"health": 200, 
						"attack_power": 25, 
						"attack_speed": 1.1, 
						"attack_range": 30.0, 
						"movement_speed": 105,
					},
					"cost": {
						"resource1": 500, 
						"resource2": 500, 
						"resource3": 500
					},
					"skills": {
					}
				},
				5: {
					"stats": {
						"health": 200, 
						"attack_power": 25, 
						"attack_speed": 1.1, 
						"attack_range": 30.0, 
						"movement_speed": 105,
					},
					"cost": {
						"resource1": 800, 
						"resource2": 800, 
						"resource3": 800
					},
					"skills": {
						0: "Strong Attack"
					}
				},
			},
		},
		MONSTER_KINDS.YIPEEEARCHER: {
			"locked": false,
			"name": "Yipee Archer",
						"type": MONSTER_TYPES.RANGED,
			"levels": {
				1: {
					"stats": {
						"health": 80, 
						"attack_power": 10, 
						"attack_speed": 1.0, 
						"attack_range": 300.0, 
						"movement_speed": 90,
					},
					"cost": {
						"resource1": 100, 
						"resource2": 200
					},
					"skills": {
					}
				},
				2: {
					"stats": {
						"health": 85, 
						"attack_power": 15, 
						"attack_speed": 1.2, 
						"attack_range": 310.0, 
						"movement_speed": 93,
					},
					"cost": {
						"resource1": 200, 
						"resource2": 600, 
					},
					"skills": {
					}
				},
				3: {
					"stats": {
						"health": 90, 
						"attack_power": 20, 
						"attack_speed": 1.4, 
						"attack_range": 340.0, 
						"movement_speed": 95,
					},
					"cost": {
						"resource1": 300, 
						"resource2": 900,
					},
					"skills": {
					}
				},
				4: {
					"stats": {
						"health": 200, 
						"attack_power": 25, 
						"attack_speed": 1.1, 
						"attack_range": 30.0, 
						"movement_speed": 105,
					},
					"cost": {
						"resource1": 500, 
						"resource2": 500, 
						"resource3": 500
					},
					"skills": {
					}
				},
				5: {
					"stats": {
						"health": 200, 
						"attack_power": 25, 
						"attack_speed": 1.1, 
						"attack_range": 30.0, 
						"movement_speed": 105,
					},
					"cost": {
						"resource1": 800, 
						"resource2": 800, 
						"resource3": 800
					},
					"skills": {
						0: "Snipe"
					}
				},
			},
		},
		MONSTER_KINDS.YIPEEHORSE: {
			"locked": false,
			"name": "Yipee Cavalry",
						"type": MONSTER_TYPES.CAVALRY,
			"levels": {
				1: {
					"stats": {
						"health": 200, 
						"attack_power": 30, 
						"attack_speed": 0.5, 
						"attack_range": 30.0, 
						"movement_speed": 200,
					},
					"cost": {
						"resource1": 150, 
						"resource2": 100, 
						"resource3": 300
					},
					"skills": {
					}
				},
				2: {
					"stats": {
						"health": 250, 
						"attack_power": 35, 
						"attack_speed": 0.6, 
						"attack_range": 30.0, 
						"movement_speed": 215,
					},
					"cost": {
						"resource1": 300, 
						"resource2": 200, 
						"resource3": 600
					},
					"skills": {
					}
				},
				3: {
					"stats": {
						"health": 300, 
						"attack_power": 40, 
						"attack_speed": 0.7, 
						"attack_range": 30.0, 
						"movement_speed": 230,
					},
					"cost": {
						"resource1": 300, 
						"resource2": 300, 
						"resource3": 300
					},
					"skills": {
					}
				},
				4: {
					"stats": {
						"health": 200, 
						"attack_power": 25, 
						"attack_speed": 1.1, 
						"attack_range": 30.0, 
						"movement_speed": 105,
					},
					"cost": {
						"resource1": 500, 
						"resource2": 500, 
						"resource3": 500
					},
					"skills": {
					}
				},
				5: {
					"stats": {
						"health": 200, 
						"attack_power": 25, 
						"attack_speed": 1.1, 
						"attack_range": 30.0, 
						"movement_speed": 105,
					},
					"cost": {
						"resource1": 800, 
						"resource2": 800, 
						"resource3": 800
					},
					"skills": {
						0: "Charge"
					}
				},
			},
		}
}



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

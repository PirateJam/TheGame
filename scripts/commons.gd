extends Node2D
class_name Commons

enum BIOMES {FOREST, DESERT, SWAMP, WATER_BODY}
enum RESOURCES {WOOD, IRON, ELIXIR}

enum MONSTER_TYPES {RANGED, MEELEE, CAVALRY}
enum MONSTER_KINDS {EVILEYE, SPIDER, GIANTFROG, BIES, SKELETON}	#this is just an example monster because I lack iDeas:tm:

enum BUILDING_KINDS {WALL, WITCH_HUT, COMMANDER_CAMP}
enum ROTATION {FRONT, LEFT, BACK, RIGHT}


var default_soundtrack = preload("res://assets/music/premix_loops/peace_premix.mp3")
var combatA_soundtrack = preload("res://assets/music/premix_loops/combatA_premix.mp3")
var combatB_soundtrack = preload("res://assets/music/premix_loops/combatB_premix.mp3")
var combatC_soundtrack = preload("res://assets/music/premix_loops/combatC_premix.mp3")


var resource_gain_delay = 30	# 30 seconds

var building_info = {
	BUILDING_KINDS.WALL: {
		"cost": {"WOOD": 100, "IRON": 20},
		"rotatable": true,
		"passive_resource_gain": {},
		"texture": get_building_textures(BUILDING_KINDS.WALL, 1)
	},
	BUILDING_KINDS.COMMANDER_CAMP: {
		"cost": {"WOOD": 100, "IRON": 100},
		"rotatable": false,
		"passive_resource_gain": {"WOOD": 50},
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
		MONSTER_KINDS.EVILEYE:
			return load("res://assets/images/monsters/yippe_example_monster" + str(level) + ".png")
		MONSTER_KINDS.SPIDER:
			return load("res://assets/images/monsters/yippe_example_monster" + str(level) + ".png")
		MONSTER_KINDS.GIANTFROG:
			return load("res://assets/images/monsters/yippe_example_monster" + str(level) + ".png")
		MONSTER_KINDS.BIES:
			return load("res://assets/images/monsters/yippe_example_monster" + str(level) + ".png")
		MONSTER_KINDS.SKELETON:
			return load("res://assets/images/monsters/yippe_example_monster" + str(level) + ".png")


var unknown_texture = load("res://assets/images/misc/unknown.png")

var aim_cursor = load("res://assets/images/misc/crosshair.png")


const map_size = 10
const state_view_zoom = 1.5


const controlled_default_state_color = Color(1, 1, 1, 0.7)
const controlled_hover_state_color = Color(1, 1, 1, 0.85)
const controlled_select_state_color = Color(1, 1, 1, 1)


const default_state_color = Color(1, 1 , 1, 0.4)
const hover_state_color = Color(1, 1, 1, 0.6)
const select_state_color = Color(1, 1, 1, 0.8)

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
	MONSTER_KINDS.EVILEYE: {
			"locked": false,
			"name": "Evil Eye", 
			"type": MONSTER_TYPES.RANGED,
			"levels": {
				1: {
					"stats": {
						"health": 50, 
						"attack_power": 70, 
						"attack_speed": 0.2, 
						"attack_range": 500.0, 
						"movement_speed": 60
					},
					"cost": {
						"Food": 100, 
						"Sulfur": 10
					},
					"skills": { 
					}
				},
				2: {
					"stats": {
						"health": 100, 
						"attack_power": 80, 
						"attack_speed": 0.25, 
						"attack_range": 510.0, 
						"movement_speed": 65
					},
					"cost": {
						"Food": 200, 
						"Sulfur": 20
					},
					"skills": {
					}
				},
				3: {
					"stats": {
						"health": 150, 
						"attack_power": 90, 
						"attack_speed": 0.3, 
						"attack_range": 520.0, 
						"movement_speed": 70,
					},
					"cost": {
						"Food": 400, 
						"resource2": 40, 
					},
					"skills": {
					}
				},
				4: {
					"stats": {
						"health": 200, 
						"attack_power": 100, 
						"attack_speed": 0.35, 
						"attack_range": 540.0, 
						"movement_speed": 75,
					},
					"cost": {
						"Food": 600, 
						"Sulfur": 60, 
					},
					"skills": {
					}
				},
				5: {
					"stats": {
						"health": 400, 
						"attack_power": 180, 
						"attack_speed": 0.5, 
						"attack_range": 600.0, 
						"movement_speed": 100,
					},
					"cost": {
						"Food": 1500, 
						"Sulfur": 200, 
						"Demon Blood": 1
					},
					"skills": {
						0: "Petrify Stare"
					}
				},
			},
		},
		MONSTER_KINDS.SPIDER: {
			"locked": false,
			"name": "Spider",
						"type": MONSTER_TYPES.MEELEE,
			"levels": {
				1: {
					"stats": {
						"health": 120, 
						"attack_power": 10, 
						"attack_speed": 2.0, 
						"attack_range": 30.0, 
						"movement_speed": 120,
					},
					"cost": {
						"Food": 150, 
						"Poison": 15
					},
					"skills": {
					}
				},
				2: {
					"stats": {
						"health": 180, 
						"attack_power": 15, 
						"attack_speed": 2.1, 
						"attack_range": 35.0, 
						"movement_speed": 125,
					},
					"cost": {
						"Food": 300, 
						"resource2": 25, 
					},
					"skills": {
					}
				},
				3: {
					"stats": {
						"health": 240, 
						"attack_power": 20, 
						"attack_speed": 2.2, 
						"attack_range": 40.0, 
						"movement_speed": 130,
					},
					"cost": {
						"Food": 600, 
						"Poison": 45,
					},
					"skills": {
					}
				},
				4: {
					"stats": {
						"health": 300, 
						"attack_power": 25, 
						"attack_speed": 2.3, 
						"attack_range": 45.0, 
						"movement_speed": 135,
					},
					"cost": {
						"Food": 900, 
						"Poison": 65, 
					},
					"skills": {
					}
				},
				5: {
					"stats": {
						"health": 600, 
						"attack_power": 40, 
						"attack_speed": 3, 
						"attack_range": 50.0, 
						"movement_speed": 180,
					},
					"cost": {
						"Food": 2000, 
						"Poison": 150, 
						"Demon Blood": 1
					},
					"skills": {
						0: "Poison Strike"
					}
				},
			},
		},
		MONSTER_KINDS.GIANTFROG: {
			"locked": false,
			"name": "Giant Frog",
						"type": MONSTER_TYPES.MEELEE,
			"levels": {
				1: {
					"stats": {
						"health": 300, 
						"attack_power": 30, 
						"attack_speed": 0.5, 
						"attack_range": 40.0, 
						"movement_speed": 90,
					},
					"cost": {
						"Food": 400, 
					},
					"skills": {
					}
				},
				2: {
					"stats": {
						"health": 400, 
						"attack_power": 35, 
						"attack_speed": 0.55, 
						"attack_range": 42.0, 
						"movement_speed": 100,
					},
					"cost": {
						"Food": 800, 
					},
					"skills": {
					}
				},
				3: {
					"stats": {
						"health": 500, 
						"attack_power": 40, 
						"attack_speed": 0.6, 
						"attack_range": 44.0, 
						"movement_speed": 110,
					},
					"cost": {
						"Food": 1200, 
					},
					"skills": {
					}
				},
				4: {
					"stats": {
						"health": 600, 
						"attack_power": 45, 
						"attack_speed": 0.65, 
						"attack_range": 46.0, 
						"movement_speed": 120,
					},
					"cost": {
						"Food": 1500, 
					},
					"skills": {
					}
				},
				5: {
					"stats": {
						"health": 1500, 
						"attack_power": 90, 
						"attack_speed": 0.8, 
						"attack_range": 50.0, 
						"movement_speed": 155,
					},
					"cost": {
						"Food": 5000, 
						"Demon Blood": 1, 
					},
					"skills": {
						0: "Swallow Whole"
					}
				},
			},
		},
		MONSTER_KINDS.BIES: {
			"locked": false,
			"name": "Bies",
						"type": MONSTER_TYPES.CAVALRY,
			"levels": {
				1: {
					"stats": {
						"health": 150, 
						"attack_power": 20, 
						"attack_speed": 1.0, 
						"attack_range": 30.0, 
						"movement_speed": 200,
					},
					"cost": {
						"Food": 200, 
						"Bone": 20
					},
					"skills": {
					}
				},
				2: {
					"stats": {
						"health": 200, 
						"attack_power": 25, 
						"attack_speed": 1.1, 
						"attack_range": 35.0, 
						"movement_speed": 215,
					},
					"cost": {
						"Food": 400, 
						"Bone": 40, 
					},
					"skills": {
					}
				},
				3: {
					"stats": {
						"health": 250, 
						"attack_power": 30, 
						"attack_speed": 1.2, 
						"attack_range": 40.0, 
						"movement_speed": 230,
					},
					"cost": {
						"Food": 600, 
						"Bone": 60,
					},
					"skills": {
					}
				},
				4: {
					"stats": {
						"health": 300, 
						"attack_power": 30, 
						"attack_speed": 1.3, 
						"attack_range": 45.0, 
						"movement_speed": 245,
					},
					"cost": {
						"Food": 900, 
						"Bone": 90, 
					},
					"skills": {
					}
				},
				5: {
					"stats": {
						"health": 600, 
						"attack_power": 50, 
						"attack_speed": 1.8, 
						"attack_range": 50.0, 
						"movement_speed": 300,
					},
					"cost": {
						"Food": 2000, 
						"Bone": 200, 
						"Demon Blood": 1
					},
					"skills": {
						0: "Stalking"
					}
				},
			},
		},
		MONSTER_KINDS.SKELETON: {
			"locked": false,
			"name": "Bies",
						"type": MONSTER_TYPES.MEELEE,
			"levels": {
				1: {
					"stats": {
						"health": 200, 
						"attack_power": 15, 
						"attack_speed": 1.5, 
						"attack_range": 30.0, 
						"movement_speed": 100,
					},
					"cost": {
						"Bone": 25, 
					},
					"skills": {
					}
				},
				2: {
					"stats": {
						"health": 250, 
						"attack_power": 20, 
						"attack_speed": 1.6, 
						"attack_range": 35.0, 
						"movement_speed": 110,
					},
					"cost": {
						"Bone": 50, 
					},
					"skills": {
					}
				},
				3: {
					"stats": {
						"health": 300, 
						"attack_power": 25, 
						"attack_speed": 1.7, 
						"attack_range": 40.0, 
						"movement_speed": 120,
					},
					"cost": {
						"Bone": 75, 
					},
					"skills": {
					}
				},
				4: {
					"stats": {
						"health": 350, 
						"attack_power": 30, 
						"attack_speed": 1.8, 
						"attack_range": 45.0, 
						"movement_speed": 120,
					},
					"cost": {
						"Bone": 100, 
					},
					"skills": {
					}
				},
				5: {
					"stats": {
						"health": 700, 
						"attack_power": 60, 
						"attack_speed": 2.5, 
						"attack_range": 50.0, 
						"movement_speed": 180,
					},
					"cost": {
						"Bone": 300, 
						"Demon Blood": 1, 
					},
					"skills": {
						0: "Summon Skeleton"
					}
				},
			},
		},
}



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

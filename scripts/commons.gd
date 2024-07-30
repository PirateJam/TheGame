extends Node2D
class_name Commons

enum BIOMES {FOREST, DESERT, SWAMP, WATER_BODY, SNOW}
enum RESOURCES {WOOD, IRON, DEMON_BLOOD, SULFUR, POISON, FOOD}

enum MONSTER_TYPES {RANGED, MEELEE, CAVALRY}
enum MONSTER_KINDS {EVILEYE, SPIDER, GIANTFROG}	#this is just an example monster because I lack iDeas:tm:

enum BUILDING_KINDS {WALL, WITCH_HUT, COMMANDER_CAMP, SAWMILL, BLACKSMITH}
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
	},
	BUILDING_KINDS.SAWMILL: {
		"cost": {"WOOD": 150, "IRON": 50},
		"rotatable": false,
		"passive_resource_gain": {"WOOD": 100},
		"texture": get_building_textures(BUILDING_KINDS.SAWMILL, 1)
	},
	BUILDING_KINDS.BLACKSMITH: {
		"cost": {"WOOD": 200, "IRON": 100},
		"rotatable": false,
		"passive_resource_gain": {"IRON": 50},
		"texture": get_building_textures(BUILDING_KINDS.BLACKSMITH, 1)
	},
	BUILDING_KINDS.WITCH_HUT: {
		"cost": {"WOOD": 200, "IRON": 200},
		"rotatable": false,
		"passive_resource_gain": {},
		"texture": get_building_textures(BUILDING_KINDS.BLACKSMITH, 1)
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
		BIOMES.SNOW:
			return load("res://assets/images/biomes/snow.png")
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
		BIOMES.SNOW:
			return load("res://assets/images/biomes/snow_stateview.png")

func get_building_textures(kind: BUILDING_KINDS, level = 1):
	if level>5 or level<0:
		return [unknown_texture, unknown_texture]
	match kind:
		BUILDING_KINDS.WALL:
			print("res://assets/images/buildings/wall_front-1.png")
			return [load("res://assets/images/buildings/wall_front-1.png"), load("res://assets/images/buildings/wall_side-1.png")]
		BUILDING_KINDS.COMMANDER_CAMP:
			return [load("res://assets/images/buildings/commander_camp.png"), load("res://assets/images/buildings/wall_side-" + str(level) + ".png")]
		BUILDING_KINDS.SAWMILL:
			return [load("res://assets/images/buildings/commander_camp.png"), load("res://assets/images/buildings/wall_side-" + str(level) + ".png")]
		BUILDING_KINDS.BLACKSMITH:
			return [load("res://assets/images/buildings/commander_camp.png"), load("res://assets/images/buildings/wall_side-" + str(level) + ".png")]
		BUILDING_KINDS.WITCH_HUT:
			return [load("res://assets/images/buildings/witch_hut.png"), load("res://assets/images/buildings/wall_side-" + str(level) + ".png")]

func get_monster_textures(kind: MONSTER_KINDS, level: int=1):
	if level>5 or level<0:
		return unknown_texture
	match kind:
		MONSTER_KINDS.EVILEYE:
			return load("res://assets/images/monsters/eye_monster.png")
		MONSTER_KINDS.SPIDER:
			return load("res://assets/images/monsters/spider.png")
		MONSTER_KINDS.GIANTFROG:
			return load("res://assets/images/monsters/giant_frog.png")

func get_monster_texture_from_string(kind: String, level: int=1):
	match kind:
		"EVILEYE":
			return load("res://assets/images/monsters/eye_monster.png")
			
		"SPIDER":
			return load("res://assets/images/monsters/spider.png")
			
		"GIANTFROG":
			return load("res://assets/images/monsters/giant_frog.png")




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
var snow_trees = [
	load("res://assets/images/misc/tree1.png"),
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
const snow_trees_amount = 9



var font_data = load("res://assets/fonts/DaysOne.ttf")


func get_monster_index(s: String):	#istg godot can't handle enums properly
	match s:
		"EVILEYE":
			return MONSTER_KINDS.EVILEYE
		"SPIDER":
			return MONSTER_KINDS.SPIDER
		"GIANTFROG":
			return MONSTER_KINDS.GIANTFROG

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
						"attack_range": 300.0, 
						"movement_speed": 60
					},
					"cost": {
						"FOOD": 100, 
						"SULFUR": 10
					},
					"skills": { 
						0: "Petrify Stare"
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
						"FOOD": 200, 
						"SULFUR": 20
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
						"FOOD": 400, 
						"SULFUR": 40, 
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
						"FOOD": 600, 
						"SULFUR": 60, 
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
						"FOOD": 1500, 
						"SULFUR": 200, 
						"DEMON_BLOOD": 1
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
						"FOOD": 150, 
						"POISON": 15
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
						"FOOD": 300, 
						"SULFUR": 25, 
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
						"FOOD": 600, 
						"POISON": 45,
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
						"FOOD": 900, 
						"POISON": 65, 
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
						"FOOD": 2000, 
						"POISON": 150, 
						"DEMON_BLOOD": 1
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
						"FOOD": 400, 
					},
					"skills": {
						0: "Swallow Whole"
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
						"FOOD": 800, 
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
						"FOOD": 1200, 
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
						"FOOD": 1500, 
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
						"FOOD": 5000, 
						"DEMON_BLOOD": 1, 
					},
					"skills": {
						0: "Swallow Whole"
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

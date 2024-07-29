@tool
extends Commons

@export var monster_scene: PackedScene = preload("res://nodes/monster.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func correctify(position, arr) -> Array:
	var last_val = position
	var n_arr = [last_val]
	for i in arr:
		n_arr.append(last_val+i)
		last_val = last_val+i
	return n_arr
func map_pos(position, arr) -> Array:
	var n_arr = []
	for i in arr:
		n_arr.append(-(Vector2.ZERO+position+i))
	return n_arr

var state = load("res://state.gd")
func create_state(id, pos, curves):
	var cstate = state.new(id,pos,curves)
	cstate.id = id
	cstate.position = pos
	cstate.curves = curves
	return cstate
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func spawn_unit(monster_kind: MONSTER_KINDS, position: Vector2, is_enemy: bool, root):
	if monster_scene:
		var monster_instance = monster_scene.instantiate()
		
		root.add_child(monster_instance)
		monster_instance.position = position
		monster_instance.set_monster_kind(monster_kind)
		monster_instance.is_enemy = is_enemy
		if is_enemy:
			monster_instance.add_to_group("enemies")
			monster_instance.set_color(Color(1,0,0,1))
		else:
			monster_instance.add_to_group("allies")
			monster_instance.set_color(Color(0,1,0,1))
		print("Spawned unit: ", monster_kind, " at position: ", position, " (Enemy: ", is_enemy, ")")
	else:
		print("Error: unit_scene is not loaded.")



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

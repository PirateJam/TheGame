extends Commons

@export var monster_scene: PackedScene = preload("res://nodes/monster.tscn")

var units: Array = []
var monster_type: MONSTER_KINDS

# Called when the node enters the scene tree for the first time.
func _ready():

	$CanvasLayer/HBoxContainer/Friendly_melee.connect("pressed", Callable(self, "_on_Spawn_Player_Warrior"))
	$CanvasLayer/HBoxContainer/Friendly_ranged.connect("pressed", Callable(self, "_on_Spawn_Player_Archer"))
	$CanvasLayer/HBoxContainer/Friendly_Cavalry.connect("pressed", Callable(self, "_on_Spawn_Player_Horse"))
	$CanvasLayer/HBoxContainer/Enemy_melee.connect("pressed", Callable(self, "_on_Spawn_Enemy_Warrior"))
	$CanvasLayer/HBoxContainer/Enemy_ranged.connect("pressed", Callable(self, "_on_Spawn_Enemy_Archer"))
	$CanvasLayer/HBoxContainer/Enemy_cavalry.connect("pressed", Callable(self, "_on_Spawn_Enemy_Horse"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func spawn_unit(monster_kind: MONSTER_KINDS, position: Vector2, is_enemy: bool):
	if monster_scene:
		var monster_instance = monster_scene.instantiate()
		add_child(monster_instance)
		monster_instance.position = position
		monster_instance.set_monster_kind(monster_kind)
		monster_instance.is_enemy = is_enemy
		if is_enemy:
			monster_instance.add_to_group("enemies")
		else:
			monster_instance.add_to_group("allies")
		print("Spawned unit: ", monster_kind, " at position: ", position, " (Enemy: ", is_enemy, ")")
	else:
		print("Error: unit_scene is not loaded.")


# Functions to handle button presses
func _on_Spawn_Player_Warrior():
	spawn_unit(MONSTER_KINDS.YIPEEE, Vector2(400, 100), false)

func _on_Spawn_Player_Archer():
	spawn_unit(MONSTER_KINDS.YIPEEEARCHER, Vector2(550, 100), false)

func _on_Spawn_Player_Horse():
	spawn_unit(MONSTER_KINDS.YIPEEHORSE, Vector2(600, 100), false)

func _on_Spawn_Enemy_Warrior():
	spawn_unit(MONSTER_KINDS.YIPEEE, Vector2(400, 500), true)

func _on_Spawn_Enemy_Archer():
	spawn_unit(MONSTER_KINDS.YIPEEEARCHER, Vector2(550, 500), true)

func _on_Spawn_Enemy_Horse():
	spawn_unit(MONSTER_KINDS.YIPEEHORSE, Vector2(600, 500), true)

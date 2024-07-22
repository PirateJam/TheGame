extends Commons

# pre-init basic stats
@export var health: int
@export var attack_power: int
@export var attack_speed: float
@export var attack_range: float
@export var movement_speed: float

# pre-init other stats
var monster_kind: MONSTER_KINDS
var monster_type: MONSTER_TYPES

var target: Node2D = null # Variable to store the target node this unit will attack
var attack_timer: float = 0.0 # Timer for handling attack intervals
var is_enemy: bool = false

var level: int = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if target and is_instance_valid(target):
		var distance_to_target = position.distance_to(target.position)
		if distance_to_target <= attack_range:
			attack_target(target, delta)
		else:
			move_towards_target(target, delta)
	else:
		target = find_target(get_target())
	

# Function to set the target for the unit
func find_target(targets: Array) -> Node2D:
	var closest_target = null
	var closest_distance = attack_range
	for target in targets:
		var distance_to_target = position.distance_to(target.position)
		if distance_to_target > closest_distance:
			closest_target = target
			closest_distance = distance_to_target
	return closest_target

func get_target() -> Array:
	var targets_in_range = []
	var all_targets = null
	
	if is_in_group("allies"):
		all_targets = get_tree().get_nodes_in_group("enemies")
	else:
		all_targets =  get_tree().get_nodes_in_group("allies")
		
	for target in all_targets:
		targets_in_range.append(target)
	#print("Targets in range:", all_targets)
	return targets_in_range


# Function to move the unit towards its target
func move_towards_target(target: Node2D, delta: float):
	#REPLACE WITH PLAYER CHOOSING THE PATH INSTEAD OF AUTO
	if position.distance_to(target.position) > attack_range:
		var direction = (target.position - position).normalized()
		position += direction * movement_speed * delta
		print("Moving towards:", target.position)


func attack_target(target: Node2D, delta: float):
	attack_timer -= delta
	if attack_timer <= 0:
		# Perform attack
		target.take_damage(attack_power)
		attack_timer = 1 / attack_speed  #More attack speed stat -> faster attack
		print("Attacking:", target)


func take_damage(amount: int):
	health -= amount
	if health <= 0:
		die()


func die():
	#Death animation?
	print("Unit of type ", monster_type, " has died at position: ", position)
	queue_free()


func set_monster_kind(type: MONSTER_KINDS):
	self.monster_kind = type
	var stats = monster_stats[monster_kind]
	health = stats["health"]
	attack_power = stats["attack_power"]
	attack_speed = stats["attack_speed"]
	attack_range = stats["attack_range"]
	movement_speed = stats["movement_speed"]
	monster_type = stats["type"]
	$Sprite2D.texture = get_monster_textures(monster_kind, 1)


var monster_stats = {
	MONSTER_KINDS.YIPEEE: {
		"health": 150, "attack_power": 20, "attack_speed": 1.5, "attack_range": 30.0, "movement_speed": 100, "type": MONSTER_TYPES.MEELEE
	},
	MONSTER_KINDS.YIPEEEARCHER: {
		"health": 80, "attack_power": 15, "attack_speed": 1.0, "attack_range": 200.0, "movement_speed": 80, "type": MONSTER_TYPES.RANGED
	},
	MONSTER_KINDS.YIPEEHORSE: {
		"health": 100, "attack_power": 20, "attack_speed": 2.0, "attack_range": 30.0, "movement_speed": 150, "type": MONSTER_TYPES.CAVALRY
	}
}

extends Commons

# pre-init basic stats
@export var health = 100
@export var current_health: int
@export var attack_power: int
@export var attack_speed: float
@export var attack_range: float
@export var movement_speed: float
@export var skills: Array

# pre-init other stats
var monster_kind: MONSTER_KINDS
var monster_type: MONSTER_TYPES


var target: Node2D = null # Variable to store the target node this unit will attack
var attack_timer: float = 0.0 # Timer for handling attack intervals
var is_enemy: bool
var skill_timers: Dictionary

var level: int = -1
var sprite: Sprite2D


#foko stuff
"""func _init(id, kind, level=1):
	self.level = level
	self.sprite = Sprite2D.new()
	self.set_monster_kind(kind)
	"""
func render(position, at):
	self.sprite.position = position
	
	at.add_child(self.sprite)
#foko end


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target and is_instance_valid(target):
		var distance_to_target = position.distance_to(target.position)
		if distance_to_target <= attack_range:
			attack_target(target, delta)
			automatic_skill_usage()
		else:
			move_towards_target(target, delta)
	else:
		target = find_target(get_target())
	
	# Update skill cooldowns
	for skill_name in skill_timers.keys():
		skill_timers[skill_name] -= delta


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
		#print("Moving towards:", target.position)


func attack_target(target: Node2D, delta: float):
	attack_timer -= delta
	if attack_timer <= 0:
		# Perform attack
		target.take_damage(attack_power)
		attack_timer = 1 / attack_speed  #More attack speed stat -> faster attack
		#print("Attacking:", target)


func take_damage(amount: int):
	current_health -= amount
	set_current_health(current_health)
	if current_health <= 0:
		die()


func die():
	#Death animation?
	print("Unit of type ", monster_type, " has died at position: ", position)
	queue_free()


func set_monster_kind(type: MONSTER_KINDS, level = 1):
	self.monster_kind = type
	var stats = monster_stats[monster_kind]
	health = stats["levels"][level]["stats"]["health"]
	current_health = health
	attack_power = stats["levels"][level]["stats"]["attack_power"]
	attack_speed = stats["levels"][level]["stats"]["attack_speed"]
	attack_range = stats["levels"][level]["stats"]["attack_range"]
	movement_speed = stats["levels"][level]["stats"]["movement_speed"]
	monster_type = stats["type"]
	for skill in stats["levels"][level]["skills"]:
		skills = [load("res://nodes/skills/" + stats["levels"][level]["skills"][skill].replace(" ", "") + ".tres" )]
	
	set_max_health(health)
	set_current_health(health)
	
	skill_timers = {}
	for skill in skills:
		skill_timers[skill.name] = 0.0
		
	if not skills:
		print("Monster has not skills")
	$Sprite2D.texture = get_monster_textures(monster_kind, 1)
	#self.sprite.texture = get_monster_textures(monster_kind, 1)

#Function to add skills
func get_skill_by_name(skill_name: String) -> Resource:
	for skill in skills:
		if skill.name == skill_name:
			return skill
	return null

func use_skill(skill_name: String):
	if skill_timers[skill_name] <= 0:
		var skill = get_skill_by_name(skill_name)
		if skill:
			for effect in skill.effects:
				call(effect.function, effect.args)
			#play_animation(skill.animation)
			skill_timers[skill_name] = skill.cooldown  # Reset cooldown
		else:
			print("Skill not found")

func automatic_skill_usage():
	for skill in skills:
		if skill_timers[skill.name] <= 0 and target:
			use_skill(skill.name)
			break

#Skills effect
func modify_power(power: Array): #Increases or decreases the effect of an attack
	print("hey")
	print(target)
	print(attack_power)
	if target:
		target.take_damage(attack_power * power[0])



#Healthbar
func set_max_health(value: int):
	$Healthbar.max_value = value
	update_health_bar()

func set_current_health(value: int):
	current_health = value
	update_health_bar()

func update_health_bar():
	$Healthbar.value = current_health

func set_color(color: Color):
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = color
	$Healthbar.add_theme_stylebox_override("fill", style_box)

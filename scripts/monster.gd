extends Commons

# pre-init basic stats
@export var health = 100
@export var current_health: int
@export var attack_power: int
@export var attack_speed: float
@export var attack_range: float
@export var movement_speed: float
@export var skills: Array

var original_attack_speed: float = 0.0
var original_movement_speed: float = 0.0

# pre-init other stats
var monster_kind: MONSTER_KINDS
var monster_type: MONSTER_TYPES


var target: Node2D = null # Variable to store the target node this unit will attack
var skill_target: Node2D = null
var attack_timer: float = 0.0 # Timer for handling attack intervals
var is_enemy: bool
var skill_timers: Dictionary
var status_effects: Array = []

var level: int = -1
var sprite: Sprite2D

var current_index = 0
var path = [Vector2.ZERO]
var ai = true

# Called when the node enters the scene tree for the first time.
func _ready():
	original_attack_speed = attack_speed
	original_movement_speed = movement_speed
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if ai:
	# Update status effects
		update_status_effects(delta)
		if get_tree().get_nodes_in_group("allies").has(self):
			#print(self, is_enemy, path)
			if target and is_instance_valid(target):
				var distance_to_target = position.distance_to(target.position)
				if distance_to_target <= attack_range:
					attack_target(target, delta)
					automatic_skill_usage()
				else:
					if path.size()>current_index:
						var direction = (path[int(current_index)] - position).normalized()
						current_index+=0.33
						position += direction * movement_speed * delta
					else:
						move_towards_target(target, delta)
			else:
				target = find_target(get_target())
		else:
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
	var closest_distance = 999999
	var distance_to_target
	for found_target in targets:
		distance_to_target = position.distance_to(found_target.position)
		if distance_to_target <= closest_distance:
			closest_target = found_target
			closest_distance = distance_to_target
	return closest_target

func find_low_hp_enemy(args, range):
	var enemies_in_range = get_target()
	var distance_to_target
	
	for enemy in enemies_in_range:
		distance_to_target = position.distance_to(target.position)
		if float(enemy.current_health) / float(enemy.health) <= args[0] and distance_to_target <= range:
			skill_target = enemy
			#print("enemy found: " + skill_target.name)
			return true

func find_lowest_hp_enemy(range):
	var enemies = get_target()
	var lowest_hp_enemy = null
	var lowest_hp = 99999
	var distance_to_target
	
	for enemy in enemies:
		distance_to_target = position.distance_to(enemy.position)
		if enemy.current_health < lowest_hp and distance_to_target <= range:
			lowest_hp_enemy = enemy
			lowest_hp = enemy.current_health
			skill_target = enemy
	return true


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
	
	original_attack_speed = attack_speed
	original_movement_speed = movement_speed
	
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
			skill_timers[skill_name] = skill.cooldown  # Reset cooldown
			
			#Execute the skill
			for effect in skill.effects:
				call(effect.function, effect.args)
			
			#Apply status effect if any
			for status_effect_path in skill.status_effects:
				print(status_effect_path)
				var status_effect = load(status_effect_path)
				target.apply_status_effect(status_effect)
				
			#play_animation(skill.animation)
		else:
			print("Skill not found")

func automatic_skill_usage():
	for skill in skills:
		if skill_timers[skill.name] <= 0 and target:
			if skill.name == "Swallow Whole":
				if find_low_hp_enemy(skill.effects[0].args, attack_range):
					use_skill(skill.name)
				break
			else:
				use_skill(skill.name)
				break


#Skills effect
func modify_power(power: Array): #Increases or decreases the effect of an attack
	if target:
		target.take_damage(attack_power * power[0])

func drain_execution(args: Array): #Executes below args[0]% and heal args[1]%
	if skill_target and float(skill_target.current_health) / float(skill_target.health) <= args[0]:
		current_health += args[1]*health
		if current_health > health:
			current_health = health
		skill_target.die()

func apply_skill_status_effect(skill_status_effect: Resource):
	apply_status_effect(skill_status_effect)

func stalking(args: Array): #Teleport behind a low hp enemies
	if find_lowest_hp_enemy(1000):
		target = skill_target
		target.take_damage(attack_power * args[0])
		var teleport_position = target.position + Vector2(-50, 0)
		global_position = teleport_position
		print("Teleported behind the enemy.")
		
func summon(args: Array):
	var summon_unit_scene: PackedScene 
	var summon_count: int = 1
	summon_unit_scene = load("res://nodes/monster.tscn")
	
	var summon_instance = summon_unit_scene.instantiate()
	if summon_instance:
		summon_instance.set_monster_kind(MONSTER_KINDS.SKELETON, 1)
		summon_instance.global_position = global_position + Vector2(randf_range(-50, 50), randf_range(-50, 50))
		if is_in_group("allies"):
			summon_instance.add_to_group("allies")
			summon_instance.set_color(Color(0,1,0,1))
		else:
			summon_instance.add_to_group("enemies")
			summon_instance.set_color(Color(1,0,0,1))
		
		get_tree().root.add_child(summon_instance)
		print("Summoned a unit.")
		
func damage_all(args: Array):
	var all_targets = get_target()
	for enemy in all_targets:
		enemy.take_damage(attack_power * args[0])

	
#Status related functions
func apply_status_effect(effect: Resource):
	var status_effect = {
		"resource": effect,
		"remaining_time": effect.duration,
		"tick_timer": effect.tick_interval  # Initialize tick timer
	}
	status_effects.append(status_effect)

func update_status_effects(delta: float):
	for effect_data in status_effects:
		effect_data["remaining_time"] -= delta
		effect_data["tick_timer"] -= delta
		if effect_data["remaining_time"] <= 0:
			status_effects.erase(effect_data)
			if effect_data["resource"].effect_function == "apply_petrify":
				self.end_petrify()
		elif effect_data["tick_timer"] <= 0:
			call(effect_data["resource"].effect_function, effect_data["resource"].args)
			effect_data["tick_timer"] = effect_data["resource"].tick_interval  # Reset tick timer



func apply_poison(damage: Array):
	take_damage(damage[0])
	print("Poison applied. Taking ", damage[0], "damage per tick.")
	
func apply_petrify(args: Array):
	movement_speed = 0  # Immobilize
	attack_speed = 0  # Reduce attack speed
	print("Petrified: Immobilized and attack speed reduced.")
	
func end_petrify():
	movement_speed = original_movement_speed  # Restore movement speed
	attack_speed = original_attack_speed  # Restore attack speed
	print("Petrify ended: Movement and attack speed restored.")




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

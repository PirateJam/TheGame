@tool
extends Node2D
### this whole thing is foko's swamp like tf is going on here ~ foko
@export var monster_scene: PackedScene = preload("res://nodes/monster.tscn")

var utils = load("res://scripts/utils.gd").new()
var state_supplier = load("res://scripts/state.gd")
var planning = load("res://scripts/planning.gd")
var building_supplier = load("res://scripts/building.gd")
var menu_supplier = load("res://scripts/menu_supplier.gd")

var logger = load("res://scripts/logger.gd").new()
var cutscene = load("res://scripts/cutscene.gd").new()

var commons = load("res://scripts/commons.gd").new()

var plan

var font
var states = []
var trees = []
var buttons = []
var state_ui_buttons = []
var border_line_width = 2
var border_color = Color.BLACK

var g_position = Vector2.ZERO
var is_planning = false

var raid_phase = 0

var triangles
var cumulated_areas: Array

var _rand

enum RENDERS {MAIN_MENU, MAP, STATE}

var render = RENDERS.MAIN_MENU

enum AIMING_MODES {NONE, BUILDING, SETUP_ATTACK}
var aiming = AIMING_MODES.NONE


const production = false
var first_time_map = true
var first_time_state = true


func _draw() -> void:
	match render:
		RENDERS.MAP:
			draw_line(Vector2.ZERO, Vector2.DOWN*300, Color.AQUA, 0)
	
			draw_string(font, Vector2.ZERO+Vector2.DOWN*30+Vector2.LEFT*50, 'Foko here!')
			logger.log("Drawing states...")
			for state in states:
				var last_line = state.position
				for line in state.curves:
					draw_line(last_line, last_line+line, border_color, border_line_width)
					last_line = last_line+line
				draw_line(last_line, state.position, border_color, border_line_width)
				logger.log("Drawn: "+ state.id)
		RENDERS.MAIN_MENU:
			var text = 'Bellum Monstrum'#'Example Title (Fok)!'
			draw_string(font, Vector2.UP*250+Vector2.LEFT*4*text.length(), text) # move to left by 4/char - to center text
			for button in buttons:
				var last_line = button.position
				for line in button.curves:
					draw_line(last_line, last_line+line, border_color, border_line_width)
					last_line = last_line+line
				draw_line(last_line, button.position, border_color, border_line_width)
				logger.log("Drawn: "+ button.id)
		RENDERS.STATE:
			draw_string(font, Vector2.ZERO+Vector2.DOWN*30+Vector2.LEFT*50, 'Welcome to the State View!')
			if !peeked_state.controlled:
				draw_string(font, Vector2.ZERO+Vector2.DOWN*50+Vector2.LEFT*50, 'state not controlled, shall we attack?')
			
			if is_planning && plan:
				var previous = g_position
				for i in plan.arrow:
					draw_line(previous, i, Color.BLUE, 3, true)
					previous = i
					print("drawing")
			### STATE VIEW SHOULD BE BIOME BACKGROUND, NOT... this	
			#var last_line = peeked_state.position
			#for line in peeked_state.curves:
			#	draw_line(last_line, last_line+line, border_color, border_line_width)
			#	last_line = last_line+line
			#draw_line(last_line, peeked_state.position, border_color, border_line_width)
			#logger.log("(STATE VIEW) Drawn: "+ peeked_state.id)
			
 


func reset_hover_focus():
	match render:
		RENDERS.MAP:
			for state in states:
				state.area.hover_focus = false;
		RENDERS.MAIN_MENU:
			for button in buttons:
				button.area.hover_focus = false;
		RENDERS.STATE:
			for button in state_ui_buttons:
				button.area.hover_focus = false;

func reset_select_focus():
	match render:
		RENDERS.MAP:
			for state in states:
				state.area.select_focus = false;
		RENDERS.MAIN_MENU:
			for button in buttons:
				button.area.select_focus = false;
		RENDERS.STATE:
			for button in state_ui_buttons:
				button.area.select_focus = false;


func update_focus():
	match render:
		RENDERS.MAP:
			for state in states:
				if state.area.select_focus:
					logger.log("FOCUS ON STATE: " + state.id)
					if state.controlled:
						state.area.get_children()[1].color = commons.controlled_select_state_color
					else:
						state.area.get_children()[1].color = commons.select_state_color
				elif state.area.hover_focus:
					logger.log(" (hover) FOCUS ON STATE: " + state.id)
					if state.controlled:
						state.area.get_children()[1].color = commons.controlled_hover_state_color
						
					else:
						state.area.get_children()[1].color = commons.hover_state_color
					
				else:
					if state.area.get_children().size()>1:
						if state.controlled:
							state.area.get_children()[1].color = commons.controlled_default_state_color
						else:
							state.area.get_children()[1].color = commons.default_state_color
		RENDERS.MAIN_MENU:
			for button in buttons:
				
				if button.area.select_focus:
					logger.log("FOCUS ON BUTTON: " + button.id)
					
					button.area.get_children()[1].color = commons.select_button_color
				elif button.area.hover_focus:
					logger.log(" (hover) FOCUS ON BUTTON: " + button.id)
					button.area.get_children()[1].color = commons.hover_button_color
					
				else:
					if button.area.get_children().size()>1:
						button.area.get_children()[1].color = commons.default_button_color
		RENDERS.STATE:
			for button in state_ui_buttons:
				if button.area.select_focus:
					logger.log("FOCUS ON BUTTON: " + button.id)
					
					button.area.get_children()[1].color = commons.select_button_color
				elif button.area.hover_focus:
					logger.log(" (hover) FOCUS ON BUTTON: " + button.id)
					button.area.get_children()[1].color = commons.hover_button_color
					
				else:
					if button.area.get_children().size()>1:
						button.area.get_children()[1].color = commons.default_button_color
			





func resize(x):
	return x*commons.map_size


func exit():
	get_tree().quit()




func prepare_attack():
	logger.error("attack preparation!")
	Input.set_custom_mouse_cursor(commons.aim_cursor)
	aiming = AIMING_MODES.SETUP_ATTACK
	cutscene.cutscene($cutscene_ui, "Atack Preparation", "Let's start with picking our camp's location", load("res://assets/images/misc/crosshair.png"))
	
func building_mode():
	logger.error("building boy!")
	$building_ui.visible = true

var to_build
func building_picked(kind):
	print(str(kind))
	to_build = kind
	Input.set_custom_mouse_cursor(commons.aim_cursor)
	$building_ui.visible = false
	aiming = AIMING_MODES.BUILDING

	cutscene.cutscene($cutscene_ui, "Building", "Now, point where the building shall rise", commons.get_building_textures(to_build)[0])





func passive_resource_gain(delay):
	while true:
		await get_tree().create_timer(delay).timeout
		for state in states:
			if state.controlled:
				for i in state.buildings:
					TribeManagement.add_resources(commons.building_info[i.kind]['passive_resource_gain'])




func _process(delta):
	if !$AudioStreamPlayer2D.is_playing():
		if peeked_state:
			if !peeked_state.controlled:
				match raid_phase:
					0:
						$AudioStreamPlayer2D.stream = commons.combatA_soundtrack		# peeking state
					1:
						$AudioStreamPlayer2D.stream = commons.combatB_soundtrack		# preparation
					2:
						$AudioStreamPlayer2D.stream = commons.combatC_soundtrack		# war
			else:
				$AudioStreamPlayer2D.stream = commons.default_soundtrack			# default idle
		else:
			$AudioStreamPlayer2D.stream = commons.default_soundtrack			# default idle
		$AudioStreamPlayer2D.play()
	if Input.is_action_just_pressed("key_exit"):
		if $cutscene_ui.visible:
			$cutscene_ui.visible = false
		else:
			match render:
				RENDERS.MAP:
					render = RENDERS.MAIN_MENU
					reload_render()
					queue_redraw()
				RENDERS.STATE:
					render = RENDERS.MAP
					reload_render()
					queue_redraw()
	if Input.is_action_just_pressed("key_left_click"):
		match aiming:
			AIMING_MODES.BUILDING:
				Input.set_custom_mouse_cursor(null)		# default cursor
				aiming = AIMING_MODES.NONE
				print(get_global_mouse_position())
				var building = building_supplier.new(to_build, 1, get_global_mouse_position(), Vector2.ZERO, commons.ROTATION.FRONT)
				#var sprite = Sprite2D.new()
				var building_i = commons.building_info[to_build]
				print(building_i["cost"])
				TribeManagement.spend_resources(building_i["cost"])
				add_child(building.get_area())
				peeked_state.buildings.append(building)
				cutscene.cutscene($cutscene_ui, "Building", "Congratulations! Now you can left-click the building to show info about it.", commons.get_building_textures(to_build)[0]) ### TODO
			
			
			AIMING_MODES.SETUP_ATTACK:
				Input.set_custom_mouse_cursor(null)		# default cursor6
				aiming = AIMING_MODES.NONE
				print(get_global_mouse_position())
				var building = building_supplier.new(commons.BUILDING_KINDS.COMMANDER_CAMP, 1, get_global_mouse_position(), Vector2.ZERO, commons.ROTATION.FRONT, Callable(self, "monster_choice").bindv([get_global_mouse_position()]))

				var building_i = commons.building_info[commons.BUILDING_KINDS.COMMANDER_CAMP]
				add_child(building.get_area())
				peeked_state.buildings.append(building)
				#cutscene.cutscene($cutscene_ui, "Building", "Congratulations! Now you can left-click the building to show info about it.", commons.get_building_textures(to_build)[0])
				
				cutscene.cutscene($cutscene_ui, "Commander Camp!", "Now, that we have a place for our generals - we can plan the attack!\n Left click on the camp to go into next stage of preparation.", null)


	


func monster_choice(position):
	$AudioStreamPlayer2D.stop()
	raid_phase = 1
	
	
	
	for i in $attack_ui/options.get_children():
		$attack_ui/options.remove_child(i)
	var monster_position = Vector2.LEFT*180+Vector2.UP*90
	var monster_size = 64
	var monster_amount = 0
	for rmonster in TribeManagement.army:
		var sprite = Sprite2D.new()
		var checkbox = CheckBox.new()
		sprite.texture = commons.get_monster_textures(rmonster["kind"],1)
		sprite.position = monster_position
		
		checkbox.set_meta("Monster", rmonster)
		checkbox.position = monster_position+Vector2.DOWN*25
		
		$attack_ui/options.add_child(sprite)
		$attack_ui/options.add_child(checkbox)
		monster_amount+=1
		if monster_amount%5==0:
			monster_position+=Vector2.DOWN*monster_size+Vector2.LEFT* monster_size*5
		else:
			monster_position+=Vector2.RIGHT*monster_size
	var button = Button.new()
	button.position = Vector2.RIGHT*180+Vector2.DOWN*90
	button.text = "Confirm"
	button.connect("pressed", Callable(self, "monsters_picked").bindv([position]))
	$attack_ui/options.add_child(button)
	$attack_ui.visible = true




func monsters_picked(position):
	var temp_army=[]
	var monster_pos = position+Vector2.RIGHT*64
	$attack_ui.visible = false
	for i in $attack_ui/options.get_children():
		if is_instance_of(i, CheckBox):
			if i.button_pressed:
				print( i.get_meta("Monster") )
				temp_army.append(utils.spawn_unit(i.get_meta("Monster")["kind"], monster_pos, false, self))
				monster_pos+=Vector2.DOWN*96
	
	cutscene.cutscene($cutscene_ui, "Planning!", "Now, the art. Use left mouse button to draw an arrow your units will follow. After that, in top left corner commence the plan.", null)


	



	plan = planning.new(self)
	var height = 500
	var poly = CollisionPolygon2D.new()
	poly.set_polygon(PackedVector2Array([Vector2.LEFT*height*3+Vector2.UP*height, Vector2.LEFT*height*3+Vector2.DOWN*height, Vector2.RIGHT*height*3+Vector2.DOWN*height, Vector2.RIGHT*height*3+Vector2.UP*height]))
	plan.add_child(poly)
	add_child(plan)
	
	g_position = position
	is_planning = true
	var button = Button.new()
	button.connect("pressed", Callable(self, "send_confirmation_signal"))
	button.text = "Commence the Offensive"
	$dynamic_ui.add_child(button)
	
	
	
	var enemy_army = []
	for i in peeked_state.army:
		
		enemy_army.append(utils.spawn_unit(i["kind"], Vector2(randi()%(height*3), randi()%height), true, self, i["level"]))

	await attack_conf_signal
	is_planning = false
	
	
	var path = plan.arrow
	
	for i in temp_army:
		i.path = path
	remove_child(plan)
	$dynamic_ui.remove_child(button)
	plan = null
	
	
	### WAR!!!!
	$AudioStreamPlayer2D.stop()
	raid_phase = 2
	
	
	
	for i in enemy_army:
		
		i.ai = true
	for i in temp_army:
		i.ai = true

	




signal attack_conf_signal

func send_confirmation_signal():
	attack_conf_signal.emit()






func _ready():
	
	
	font = FontFile.new()
	font.font_data = commons.font_data


	### UIs
	
	var building_position = Vector2.LEFT*180+Vector2.UP*90
	var building_size = 64
	var building_amount = 0
	for rbuilding in commons.building_info:
		var building = building_supplier.new(rbuilding, 1, building_position, Vector2.ZERO, commons.ROTATION.FRONT, Callable(self, "building_picked").bindv([rbuilding]))
		
		#var sprite = Sprite2D.new()
		var building_i = commons.building_info[rbuilding]

		$building_ui/options.add_child(building.get_area())
		building_amount+=1
		if building_amount%5==0:
			building_position+=Vector2.DOWN*building_size+Vector2.LEFT* building_size*5
		else:
			building_position+=Vector2.RIGHT*building_size

	



	### DEFAULT MONSTERS

	
	### SETUP_STATES
	var player_state_pos = 118*Vector2.DOWN + 122*Vector2.RIGHT
	var player_state = state_supplier.new("Shadow Empire", player_state_pos, [
		Vector2.LEFT*9+Vector2.DOWN*3,
		Vector2.DOWN*12+Vector2.LEFT*3, Vector2.RIGHT*6+Vector2.DOWN*3, Vector2.DOWN*6+Vector2.LEFT*6,
		Vector2.DOWN*9,Vector2.RIGHT*16 + Vector2.UP*2,
		Vector2.RIGHT*5,
		Vector2.UP*15+Vector2.RIGHT*5
	].map(resize), 
	[
		building_supplier.new(commons.BUILDING_KINDS.WALL, 1, Vector2.ZERO+ 118*Vector2.DOWN + 122*Vector2.RIGHT, Vector2.ZERO, commons.ROTATION.FRONT)
	],
	[
		#ARMY (nevermind)
	],
	{
		commons.RESOURCES.WOOD: 100,
		commons.RESOURCES.IRON: 100,
		commons.RESOURCES.ELIXIR: 50,	#or something
	})
	player_state.controlled = true
	states.append(player_state)
	### DEFAULT_PLAYER_ARMY
	TribeManagement.add_to_army(commons.MONSTER_KINDS.EVILEYE, 1)
	
	
	var basic_state = state_supplier.new("Enemy Tribe", player_state_pos+31*Vector2.DOWN*commons.map_size + 9*Vector2.RIGHT*commons.map_size, [
		Vector2.UP*15+Vector2.RIGHT*5, Vector2.UP*14+Vector2.RIGHT*12,
		Vector2.DOWN*10+Vector2.RIGHT*5, Vector2.DOWN*8+Vector2.LEFT*7
		
	].map(resize), 
	[
		building_supplier.new(commons.BUILDING_KINDS.WALL, 1, Vector2.ZERO, Vector2.ZERO, commons.ROTATION.LEFT),
		building_supplier.new(commons.BUILDING_KINDS.WALL, 1, Vector2.UP*35+Vector2.RIGHT*15, Vector2.ZERO, commons.ROTATION.LEFT)
	],
	[
		{"kind": commons.MONSTER_KINDS.SPIDER, "level": 1},
		#ARMY
	], {}, commons.BIOMES.DESERT)
	states.append(basic_state)
	
	
	
	var basic_state2 = state_supplier.new("Enemy Tribe 2", player_state_pos+ 16*Vector2.DOWN*commons.map_size + commons.map_size*14*Vector2.RIGHT, [ 
				Vector2.LEFT*14+Vector2.UP*16,
				Vector2.RIGHT*12+Vector2.UP*4, Vector2.RIGHT*8, Vector2.DOWN*6+Vector2.RIGHT*6
		
	].map(resize))
	states.append(basic_state2)
	
	
	
	
	
	
	var lake1 = state_supplier.new("Lake 1", player_state_pos + 3*commons.map_size*Vector2.DOWN + 9*Vector2.LEFT*commons.map_size, [
		Vector2.DOWN*12+Vector2.LEFT*3, Vector2.RIGHT*6+Vector2.DOWN*3, Vector2.DOWN*6+Vector2.LEFT*6, Vector2.DOWN*9,
		Vector2.LEFT*10, Vector2.UP*5+Vector2.LEFT*5, Vector2.UP*10, Vector2.RIGHT*5+Vector2.UP*10, 
		
	].map(resize), [], [], {}, commons.BIOMES.WATER_BODY)
	states.append(lake1)
	
	var lake2 = state_supplier.new("Lake 2", player_state_pos + 33*commons.map_size*Vector2.DOWN + 22*commons.map_size*Vector2.LEFT, [
		Vector2.UP*5+Vector2.LEFT*5, Vector2.UP*10, Vector2.RIGHT*5+Vector2.UP*10,
		Vector2.LEFT*15+Vector2.UP*5,Vector2.DOWN*10+Vector2.LEFT*5,
		Vector2.RIGHT*2+Vector2.DOWN*5,Vector2.LEFT*2+Vector2.DOWN*5, Vector2.DOWN*8+Vector2.RIGHT, Vector2.DOWN*4+Vector2.LEFT, Vector2.RIGHT*5
		
	].map(resize), [], [], {}, commons.BIOMES.WATER_BODY)
	states.append(lake2)
	
	var lake3 = state_supplier.new("Lake 3", player_state_pos + 330*Vector2.DOWN + 120*Vector2.LEFT, [
		Vector2.LEFT*10, Vector2.LEFT*15+Vector2.DOWN*2, Vector2.LEFT*5,
		Vector2.DOWN*5, Vector2.RIGHT*5+Vector2.DOWN*5, Vector2.RIGHT*5+Vector2.DOWN*2, Vector2.RIGHT*10,
		Vector2.RIGHT*5+Vector2.UP*5
		
	].map(resize), [], [], {}, commons.BIOMES.WATER_BODY)
	states.append(lake3)
	
	var lake4 = state_supplier.new("Lake 4", player_state_pos + 3*commons.map_size*Vector2.DOWN + 9*commons.map_size*Vector2.LEFT, [#118*Vector2.DOWN + 122*Vector2.RIGHT
		Vector2.LEFT*13+Vector2.DOWN*5,Vector2.LEFT*15+Vector2.UP*5,
		Vector2.UP*5+Vector2.RIGHT*2, Vector2.RIGHT*5+Vector2.UP*5, Vector2.RIGHT*10, Vector2.DOWN*5+Vector2.RIGHT*10
	].map(resize), [], [], {}, commons.BIOMES.WATER_BODY)
	states.append(lake4)
	
	
	
	
	
	
	
	var forest1 = state_supplier.new("Forest 1", player_state_pos + 33*commons.map_size*Vector2.DOWN + 12*commons.map_size*Vector2.LEFT, [#118*Vector2.DOWN + 122*Vector2.RIGHT
		Vector2.DOWN*9+Vector2.LEFT*5, 
		Vector2.DOWN*5+Vector2.RIGHT*2,
		Vector2.DOWN*2+Vector2.RIGHT*5,
		Vector2.RIGHT*5, Vector2.RIGHT*10+Vector2.UP*4,
		Vector2.RIGHT*5+Vector2.UP*1,
		Vector2.LEFT*2+Vector2.UP*7,
		Vector2.RIGHT*1+Vector2.UP*6,
		Vector2.LEFT*5
	].map(resize))
	states.append(forest1)
	
	
	
	
	
	var swamp1 = state_supplier.new("Swamp 1", player_state_pos + 42*commons.map_size*Vector2.DOWN + 17*commons.map_size*Vector2.LEFT, [#118*Vector2.DOWN + 122*Vector2.RIGHT
		Vector2.DOWN*5+Vector2.LEFT*5,
		Vector2.LEFT*10,
		Vector2.LEFT*5+Vector2.DOWN*5,
		Vector2.DOWN*2+Vector2.RIGHT*5,
		Vector2.RIGHT*5+Vector2.DOWN*5,
		Vector2.RIGHT*4,
		Vector2.RIGHT+Vector2.UP*5,
		Vector2.RIGHT*12+Vector2.UP*5,
		Vector2.LEFT*5+Vector2.UP*2
	].map(resize), [], [], {}, commons.BIOMES.SWAMP)
	states.append(swamp1)
	var swamp2 = state_supplier.new("Swamp 2", player_state_pos + 47*commons.map_size*Vector2.DOWN + 32*commons.map_size*Vector2.LEFT, [#118*Vector2.DOWN + 122*Vector2.RIGHT
		Vector2.DOWN*5+Vector2.LEFT*5,
		Vector2.DOWN*2+Vector2.RIGHT*5,
		Vector2.RIGHT*5+Vector2.DOWN*5,
		Vector2.LEFT*10+Vector2.DOWN*2,
		Vector2.LEFT*10+Vector2.UP*10,
		Vector2.UP*5,
		Vector2.RIGHT*5+Vector2.UP*11,
		Vector2.DOWN*5,
		Vector2.DOWN*5+Vector2.RIGHT*5,
	].map(resize), [], [], {}, commons.BIOMES.SWAMP)
	states.append(swamp2)
	
	
	var swamp3 = state_supplier.new("Swamp 3", player_state_pos + 51*commons.map_size*Vector2.DOWN + 47*commons.map_size*Vector2.LEFT, [#118*Vector2.DOWN + 122*Vector2.RIGHT
		Vector2.UP*5,
		Vector2.RIGHT*5+Vector2.UP*11,
		Vector2.UP*4+Vector2.RIGHT,
		Vector2.UP*8+Vector2.LEFT,
		Vector2.UP*5+Vector2.RIGHT*2,
		Vector2.UP*5+Vector2.LEFT*2,
		Vector2.UP*10+Vector2.RIGHT*5,
		Vector2.UP*5+Vector2.RIGHT*2,
		Vector2.LEFT*15+Vector2.DOWN*5,
		Vector2.RIGHT+Vector2.DOWN*15,
		Vector2.LEFT+Vector2.DOWN*5,
		Vector2.DOWN*5+Vector2.LEFT*2,
	].map(resize), [], [], {}, commons.BIOMES.SWAMP)
	states.append(swamp3)
	
	var desert1 = state_supplier.new("Desert 1", player_state_pos+44*Vector2.DOWN*commons.map_size + 10*Vector2.RIGHT*commons.map_size, [
		Vector2.LEFT*2+Vector2.UP*7,
		Vector2.RIGHT*1+Vector2.UP*6,
		Vector2.RIGHT*15 + Vector2.UP*11,
		Vector2.RIGHT*7+Vector2.UP*8,
		Vector2.RIGHT*5+Vector2.DOWN*1,
		Vector2.DOWN*4,
	].map(resize), 
	[
		building_supplier.new(commons.BUILDING_KINDS.WALL, 1, Vector2.ZERO, Vector2.ZERO, commons.ROTATION.LEFT),
		building_supplier.new(commons.BUILDING_KINDS.WALL, 1, Vector2.UP*35+Vector2.RIGHT*15, Vector2.ZERO, commons.ROTATION.LEFT)
	],
	[
		#ARMY
	], {}, commons.BIOMES.DESERT)
	states.append(desert1)
	var desert2 = state_supplier.new("Desert 2", player_state_pos+44*Vector2.DOWN*commons.map_size + 10*Vector2.RIGHT*commons.map_size, [
		Vector2.RIGHT*26 + Vector2.UP*27,
		Vector2.DOWN*8+Vector2.RIGHT*5,
		Vector2.DOWN*5,
		Vector2.DOWN*5+Vector2.LEFT*2,
		Vector2.DOWN*5,
		Vector2.LEFT*10+Vector2.UP*2
	].map(resize), 
	[
		building_supplier.new(commons.BUILDING_KINDS.WALL, 1, Vector2.ZERO, Vector2.ZERO, commons.ROTATION.LEFT),
		building_supplier.new(commons.BUILDING_KINDS.WALL, 1, Vector2.UP*35+Vector2.RIGHT*15, Vector2.ZERO, commons.ROTATION.LEFT)
	],
	[
		#ARMY
	], {}, commons.BIOMES.DESERT)
	states.append(desert2)
	
	
	var forest2 = state_supplier.new("Forest 2", player_state_pos, [
		Vector2.LEFT*9+Vector2.DOWN*3,
		Vector2.UP*5+Vector2.LEFT,
		Vector2.LEFT*10+Vector2.UP*5,
		Vector2.UP*5+Vector2.LEFT,
		Vector2.UP*5+Vector2.RIGHT*10,
		Vector2.RIGHT*10+Vector2.DOWN*5,
		Vector2.RIGHT*13+Vector2.DOWN*8,
		
	].map(resize), 
	[
		building_supplier.new(commons.BUILDING_KINDS.WALL, 1, Vector2.ZERO, Vector2.ZERO, commons.ROTATION.LEFT),
		building_supplier.new(commons.BUILDING_KINDS.WALL, 1, Vector2.UP*35+Vector2.RIGHT*15, Vector2.ZERO, commons.ROTATION.LEFT)
	],
	[
		#ARMY
	], {}, commons.BIOMES.FOREST)
	states.append(forest2)
	
	
	var swamp4 = state_supplier.new("Swamp 4", player_state_pos + Vector2.LEFT * 20 * commons.map_size + Vector2.UP*7  * commons.map_size, [
		Vector2.LEFT*10,
		Vector2.LEFT*5+Vector2.DOWN*5,
		Vector2.LEFT*15+Vector2.DOWN*5,
		Vector2.UP*15+Vector2.LEFT*5,
		Vector2.RIGHT*5+Vector2.UP*5,
		Vector2.RIGHT*5,
		Vector2.RIGHT*24+Vector2.DOWN*5,
		
	].map(resize), 
	[
		building_supplier.new(commons.BUILDING_KINDS.WALL, 1, Vector2.ZERO, Vector2.ZERO, commons.ROTATION.LEFT),
		building_supplier.new(commons.BUILDING_KINDS.WALL, 1, Vector2.UP*35+Vector2.RIGHT*15, Vector2.ZERO, commons.ROTATION.LEFT)
	],
	[
		#ARMY
	], {}, commons.BIOMES.SWAMP)
	states.append(swamp4)
	



	
	
	
	
	
	### MAIN_MENU BUTTONS
	var map_button = menu_supplier.new("Play", Vector2.DOWN*50 + Vector2.LEFT*550,
	 [Vector2.RIGHT*120, Vector2.RIGHT*5+Vector2.DOWN*5, Vector2.DOWN*15, Vector2.LEFT*5+Vector2.DOWN*5, Vector2.LEFT*120, Vector2.LEFT*5+Vector2.UP*5, Vector2.UP*15]
	, null, null, render_map, font)
	buttons.append(map_button)


	var exit_button = menu_supplier.new("Exit", Vector2.DOWN*95 + Vector2.LEFT*550,
	 [Vector2.RIGHT*120, Vector2.RIGHT*5+Vector2.DOWN*5, Vector2.DOWN*15, Vector2.LEFT*5+Vector2.DOWN*5, Vector2.LEFT*120, Vector2.LEFT*5+Vector2.UP*5, Vector2.UP*15]
	, null, null, exit, font)
	buttons.append(exit_button)






	### STATE ACTION BUTTONS
	
	var attack_button = menu_supplier.new("Prepare an Attack", Vector2.UP*50 + Vector2.LEFT*90,
	 [Vector2.RIGHT*180, Vector2.RIGHT*5+Vector2.DOWN*5, Vector2.DOWN*15, Vector2.LEFT*5+Vector2.DOWN*5, Vector2.LEFT*180, Vector2.LEFT*5+Vector2.UP*5, Vector2.UP*15]
	, null, null, prepare_attack, font)
	state_ui_buttons.append(attack_button)
	var build_button = menu_supplier.new("Build", Vector2.UP*50 + Vector2.LEFT*90,
	 [Vector2.RIGHT*180, Vector2.RIGHT*5+Vector2.DOWN*5, Vector2.DOWN*15, Vector2.LEFT*5+Vector2.DOWN*5, Vector2.LEFT*180, Vector2.LEFT*5+Vector2.UP*5, Vector2.UP*15]
	, null, null, building_mode, font)
	state_ui_buttons.append(build_button)
	
	
	# SETUP :D
	
	state_init()
	passive_resource_gain(commons.resource_gain_delay)
	button_init()
	$cutscene_ui/field.modulate.a = 0.8
	$cutscene_ui/field/close.connect("button_up", Callable(self, "close_cutscene"))

	
	
		
	render = RENDERS.MAIN_MENU
	reload_render()

func close_cutscene():
	$cutscene_ui.visible = false

func button_init():
	for button in state_ui_buttons:
		logger.log(button.id)
		
		
		logger.log(button.id)
		$state_ui/options/resize.add_child(button.gen_area())
	logger.log("Initializing buttons:")
	for button in buttons:
		logger.log(button.id)
		$menu_ui/buttons.add_child(button.gen_area())

func reload_render():
	$menu_ui.visible = false
	$map_ui.visible = false
	$state_ui.visible = false
	$building_ui.visible = false
	$attack_ui.visible = false
	$background.visible = false
	$cutscene_ui.visible = false
	stateVisibility(false)
	buildingVisibility(false)
	armyVisibility(false)
	
	peeked_state = null
	
	
	
	match render:
		RENDERS.MAIN_MENU:
			draw_menu()
		RENDERS.MAP:
			draw_map()
		RENDERS.STATE:
			draw_state()

func render_map():
	logger.warn("changing render to map")
	render = RENDERS.MAP
	reload_render()


func get_selected_state():
	for i in states:
		if i.area.select_focus:
			return i



func stateVisibility(bol):
	for i in states:
		i.area.visible = bol
	for i in trees:
		i.visible = bol

func buildingVisibility(bol):
	if peeked_state:
		for i in peeked_state.buildings:
			#i.sprite.visible = bol
			i.area.visible = bol

func armyVisibility(bol):
	if peeked_state:
		if bol:
			triangles = Geometry2D.triangulate_polygon(peeked_state.poly.polygon)
			_rand = RandomNumberGenerator.new()
			var triangle_count = triangles.size()/3
			assert(triangle_count>0)
			cumulated_areas.resize(triangle_count)
			cumulated_areas[-1] = 0
			for i in range(triangle_count):
				var a: Vector2 = peeked_state.poly.polygon[triangles[3 * i + 0]]
				var b: Vector2 = peeked_state.poly.polygon[triangles[3 * i + 1]]
				var c: Vector2 = peeked_state.poly.polygon[triangles[3 * i + 2]]
				cumulated_areas[i] = cumulated_areas[i - 1] + triangle_area(a, b, c)
			for x in peeked_state.army:
				x.position = get_random_point(peeked_state.poly.polygon)
				x.visible = true
				logger.log(x.position)
				#x.render(get_random_point(peeked_state.poly.polygon), self)
				
		else:
			for x in peeked_state.army:
				x.visible = false

var peeked_state


func draw_state():
	if first_time_state:
		cutscene.cutscene($cutscene_ui, "State View", "Welcome to the state view! Here you can conquer the state, and if you already control it - build stuff (via menu on the left).", null)
		first_time_state = false
	var cstate = get_selected_state()
	#ctate.area.visible = true
	reset_select_focus()
	logger.log(cstate.curves)
	peeked_state = cstate
	$state_ui.visible = true
	$background.visible = true
	$Camera2D.zoom = Vector2(commons.state_view_zoom, commons.state_view_zoom)
	if !peeked_state.controlled:
		$AudioStreamPlayer2D.stop()
	for i in cstate.buildings:
		add_child(i.get_area())
		logger.log(i.sprite.position)
		
		logger.log(str(i.kind) + " rendered")
	buildingVisibility(true)
	armyVisibility(!peeked_state.controlled)
	
	var biome_sprite = Sprite2D.new()
	biome_sprite.texture = commons.get_biome_stateview(cstate.biome)
	for i in $background.get_children():
		$background.remove_child(i)
	$background.add_child(biome_sprite)
	
	for button in state_ui_buttons:
		if ([state_ui_buttons[1].id].has(button.id) && !cstate.controlled) or ([state_ui_buttons[0].id].has(button.id) && cstate.controlled):			# disable controlled state buttons for not-controlled state and vice versa
			button.area.visible = false
			button.color_obj.visible = false
		else:
			button.area.visible = true
			button.color_obj.visible = true
	

	queue_redraw()










func draw_menu():
	$menu_ui.visible = true
	queue_redraw()




func draw_map():
	if first_time_map:
		cutscene.cutscene($cutscene_ui, "Map View", "This is map view. Here you can see all the states. States controlled by you are highlighted, There you can start building your empire!\n Controls are listen on the right.", null)
		first_time_map = false
	$map_ui.visible = true
	stateVisibility(true)
	queue_redraw()
	
	
	
	
func state_init():
	logger.log("Initializing states:")
	for state in states:
		logger.log(state.id)
		add_child(state.gen_area())
	
	# TREES
	logger.log("adding trees")

	'''for state in states:
		logger.log("adding trees for " + state.id)
		triangles = Geometry2D.triangulate_polygon(state.poly.polygon)
		_rand = RandomNumberGenerator.new()
		var triangle_count = triangles.size()/3
		assert(triangle_count>0)
		cumulated_areas.resize(triangle_count)
		cumulated_areas[-1] = 0
		for i in range(triangle_count):
			var a: Vector2 = state.poly.polygon[triangles[3 * i + 0]]
			var b: Vector2 = state.poly.polygon[triangles[3 * i + 1]]
			var c: Vector2 = state.poly.polygon[triangles[3 * i + 2]]
			cumulated_areas[i] = cumulated_areas[i - 1] + triangle_area(a, b, c)
		match state.biome:
			commons.BIOMES.FOREST:
				for i in range(commons.forest_trees_amount):
					var tree = Sprite2D.new()
					tree.offset.y = -32
					tree.scale = Vector2(1,1)
					tree.position = get_random_point(state.poly.polygon)
					tree.texture = commons.forest_trees[randi() % commons.forest_trees.size()]
					logger.log(tree.position)
					#$BACKGROUND_OBJ.
					add_child(tree)
					trees.append(tree)
			commons.BIOMES.DESERT:
				for i in range(commons.desert_trees_amount):
					var tree = Sprite2D.new()
					tree.offset.y = -32
					tree.scale = Vector2(1,1)
					tree.position = get_random_point(state.poly.polygon)
					tree.texture = commons.desert_trees[randi() % commons.desert_trees.size()]
					logger.log(tree.position)
					#$BACKGROUND_OBJ.
					add_child(tree)
					trees.append(tree)
			commons.BIOMES.SWAMP:
				for i in range(commons.swamp_trees_amount):
					var tree = Sprite2D.new()
					tree.offset.y = -32
					tree.scale = Vector2(1,1)
					tree.position = get_random_point(state.poly.polygon)
					tree.texture = commons.swamp_trees[randi() % commons.swamp_trees.size()]
					logger.log(tree.position)
					#$BACKGROUND_OBJ.
					add_child(tree)
					trees.append(tree)'''








func get_random_point(polygon) -> Vector2:															# kindly "borrowed" from the internets, my brain is not able to work properly rn so sorry :<
	var total_area: float = cumulated_areas[-1]
	var choosen_triangle_index: int = cumulated_areas.bsearch(_rand.randf() * total_area)
	var a: Vector2 = polygon[triangles[3 * choosen_triangle_index + 0]]
	var b: Vector2 = polygon[triangles[3 * choosen_triangle_index + 1]]
	var c: Vector2 = polygon[triangles[3 * choosen_triangle_index + 2]]
	return random_triangle_point(a, b, c)
	

static func triangle_area(a: Vector2, b: Vector2, c: Vector2) -> float:
	return 0.5 * abs((c.x - a.x) * (b.y - a.y) - (b.x - a.x) * (c.y - a.y))

static func random_triangle_point(a: Vector2, b: Vector2, c: Vector2) -> Vector2:
	return a + sqrt(randf()) * (-a + b + randf() * (c - b))

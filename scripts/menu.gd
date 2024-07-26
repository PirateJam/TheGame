@tool
extends Node2D

@export var monster_scene: PackedScene = preload("res://nodes/monster.tscn")
var utils = load("res://scripts/utils.gd").new()
var state_supplier = load("res://scripts/state.gd")
var building_supplier = load("res://scripts/building.gd")
var menu_supplier = load("res://scripts/menu_supplier.gd")

var logger = load("res://scripts/logger.gd").new()

var commons = load("res://scripts/commons.gd").new()

var font
var states = []
var trees = []
var buttons = []
var state_ui_buttons = []
var border_line_width = 2
var border_color = Color.BLACK

var triangles
var cumulated_areas: Array

var _rand

enum RENDERS {MAIN_MENU, MAP, STATE}

var render = RENDERS.MAIN_MENU

enum AIMING_MODES {NONE, BUILDING, SETUP_ATTACK}
var aiming = AIMING_MODES.NONE


const production = false


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
			var text = 'Example Title :D - (if we want to go with text)'#'Example Title (Fok)!'
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
				
			var last_line = peeked_state.position
			for line in peeked_state.curves:
				draw_line(last_line, last_line+line, border_color, border_line_width)
				last_line = last_line+line
			draw_line(last_line, peeked_state.position, border_color, border_line_width)
			logger.log("(STATE VIEW) Drawn: "+ peeked_state.id)
			
 


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
	#cutscene("Let's start with picking our camp's location")
	
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

	#cutscene("Now, point where the building shall rise")


func _process(delta):
	if !$AudioStreamPlayer2D.is_playing():
		$AudioStreamPlayer2D.stream = commons.default_soundtrack
		$AudioStreamPlayer2D.play()
	if Input.is_action_just_pressed("key_exit"):
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
				add_child(building.get_area())
				peeked_state.buildings.append(building)
				
			AIMING_MODES.SETUP_ATTACK:
				Input.set_custom_mouse_cursor(null)		# default cursor6
				aiming = AIMING_MODES.NONE

func _ready():
	
	
	font = FontFile.new()
	font.font_data = commons.font_data


	### BUILDINGS
	
	var building_position = Vector2.LEFT*180+Vector2.UP*90
	var building_size = 32
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
	
	
	var basic_state = state_supplier.new("Enemy Tribe", player_state_pos+31*Vector2.DOWN*commons.map_size + 9*Vector2.RIGHT*commons.map_size, [
		Vector2.UP*15+Vector2.RIGHT*5, Vector2.UP*14+Vector2.RIGHT*12,
		Vector2.DOWN*10+Vector2.RIGHT*5, Vector2.DOWN*8+Vector2.LEFT*7
		
	].map(resize), 
	[
		load("res://scripts/building.gd").new(commons.BUILDING_KINDS.WALL, 1, Vector2.ZERO, Vector2.ZERO+ 428*Vector2.DOWN + 212*Vector2.RIGHT, commons.ROTATION.LEFT),
		load("res://scripts/building.gd").new(commons.BUILDING_KINDS.WALL, 1, Vector2.UP*35+Vector2.RIGHT*15, Vector2.ZERO+ 428*Vector2.DOWN + 212*Vector2.RIGHT, commons.ROTATION.LEFT)
	],
	[
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
	
	
	
	
	



	
	
	### MAIN_MENU BUTTONS
	var map_button = menu_supplier.new("Peek at Map", Vector2.DOWN*50 + Vector2.LEFT*550,
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
	
	
	#hey @darkran , sorry to bother ya again. But army is initialized in state as a list of `monster.gd`, ho
	
	# SETUP :D
	
	state_init()
	
	button_init()

	
	
		
	render = RENDERS.MAIN_MENU
	reload_render()


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
	stateVisibility(false)
	buildingVisibility(false)
	armyVisibility(false)
	
	
	
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
			i.sprite.visible = bol

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
	var cstate = get_selected_state()
	cstate.area.visible = true
	reset_select_focus()
	logger.log(cstate.curves)
	peeked_state = cstate
	$state_ui.visible = true
	$Camera2D.zoom = Vector2(commons.state_view_zoom, commons.state_view_zoom)
	
	for i in cstate.buildings:
		add_child(i.get_area())
		logger.log(i.sprite.position)
		
		logger.log(str(i.kind) + " rendered")
	buildingVisibility(true)
	armyVisibility(!peeked_state.controlled)

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
		#for i in range(5):
		#	randi() % state.position.x
	
	
	
	#update() # Replace with function body.

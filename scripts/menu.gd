@tool
extends Node2D

var utils = load("res://scripts/utils.gd").new()
var state_supplier = load("res://scripts/state.gd")
var menu_supplier = load("res://scripts/menu_supplier.gd")

var logger = load("res://scripts/logger.gd").new()

var commons = load("res://scripts/commons.gd").new()

var font
var states = []
var trees = []
var buttons = []
var border_line_width = 2
var border_color = Color.BLACK

var triangles
var cumulated_areas: Array

var _rand

enum RENDERS {MAIN_MENU, MAP, STATE}

var render = RENDERS.MAIN_MENU




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

func reset_select_focus():
	match render:
		RENDERS.MAP:
			for state in states:
				state.area.select_focus = false;
		RENDERS.MAIN_MENU:
			for button in buttons:
				button.area.select_focus = false;


func update_focus():
	match render:
		RENDERS.MAP:
			for state in states:
				if state.area.select_focus:
					logger.log("FOCUS ON STATE: " + state.id)
					state.area.get_children()[1].color = commons.select_state_color
				elif state.area.hover_focus:
					logger.log(" (hover) FOCUS ON STATE: " + state.id)
					state.area.get_children()[1].color = commons.hover_state_color
					
				else:
					if state.area.get_children().size()>1:
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

func resize(x):
	return x*commons.map_size


func exit():
	get_tree().quit()

func _ready():
	font = FontFile.new()
	font.font_data = commons.font_data
	# SETUP_STATES
	var player_state = state_supplier.new("Shadow Empire", Vector2.ZERO+ 118*Vector2.DOWN + 122*Vector2.RIGHT, [
		Vector2.LEFT*9+Vector2.DOWN*3, Vector2.DOWN*12+Vector2.LEFT*3, Vector2.RIGHT*6+Vector2.DOWN*3, Vector2.DOWN*6+Vector2.LEFT*6, Vector2.DOWN*9,Vector2.RIGHT*16 + Vector2.UP*2,
		Vector2.RIGHT*5,
		Vector2.UP*15+Vector2.RIGHT*5
	].map(resize), [load("res://scripts/building.gd").new(commons.BUILDING_KINDS.WALL, 1, Vector2.ZERO, Vector2.ZERO+ 118*Vector2.DOWN + 122*Vector2.RIGHT, commons.ROTATION.FRONT)])
	states.append(player_state)
	
	
	var basic_state = state_supplier.new("Enemy Tribe", Vector2.ZERO+ 428*Vector2.DOWN + 212*Vector2.RIGHT, [
		Vector2.UP*15+Vector2.RIGHT*5, Vector2.UP*14+Vector2.RIGHT*12,
		Vector2.DOWN*10+Vector2.RIGHT*5, Vector2.DOWN*8+Vector2.LEFT*7
		
	].map(resize))
	states.append(basic_state)
	
	
	var basic_state2 = state_supplier.new("Enemy Tribe 2", Vector2.ZERO+ 278*Vector2.DOWN + 262*Vector2.RIGHT, [
				Vector2.LEFT*14+Vector2.UP*16,
				Vector2.RIGHT*12+Vector2.UP*4, Vector2.RIGHT*8, Vector2.DOWN*6+Vector2.RIGHT*6
		
	].map(resize))
	states.append(basic_state2)
	
	
	var map_button = menu_supplier.new(" Peek at Map", Vector2.DOWN*50 + Vector2.LEFT*550,
	 [Vector2.RIGHT*120, Vector2.RIGHT*5+Vector2.DOWN*5, Vector2.DOWN*15, Vector2.LEFT*5+Vector2.DOWN*5, Vector2.LEFT*120, Vector2.LEFT*5+Vector2.UP*5, Vector2.UP*15]
	, null, null, render_map, font)
	buttons.append(map_button)


	var exit_button = menu_supplier.new("Exit", Vector2.DOWN*95 + Vector2.LEFT*550,
	 [Vector2.RIGHT*120, Vector2.RIGHT*5+Vector2.DOWN*5, Vector2.DOWN*15, Vector2.LEFT*5+Vector2.DOWN*5, Vector2.LEFT*120, Vector2.LEFT*5+Vector2.UP*5, Vector2.UP*15]
	, null, null, exit, font)
	buttons.append(exit_button)


	render = RENDERS.MAIN_MENU
	reload_render()



func reload_render():
	$menu_ui.visible = false
	$map_ui.visible = false
	stateVisibility(false)
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





var peeked_state

func draw_state():
	var cstate = get_selected_state()
	reset_select_focus()
	print(cstate.curves)
	peeked_state = cstate
	$Camera2D.zoom = Vector2(commons.state_view_zoom, commons.state_view_zoom)
	
	for i in cstate.buildings:
		add_child(i.render())
		print(i.sprite.position)
		
		print(i.kind, " rendered")
	queue_redraw()






func _process(delta):
	if Input.is_action_pressed("key_exit"):
		render = RENDERS.MAIN_MENU
		print("ESC")
		reload_render()
		queue_redraw()

func draw_menu():
	$menu_ui.visible = true

	print("Initializing buttons:")
	for button in buttons:
		print(button.id)
		$menu_ui/buttons.add_child(button.gen_area())
	queue_redraw()




func draw_map():
	$map_ui.visible = true
	stateVisibility(true)
	
	
	
	print("Initializing states:")
	for state in states:
		print(state.id)
		add_child(state.gen_area())

	
	
	# TREES
	print("adding trees")
	
	for state in states:
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
		for i in range(6):
			var tree = Sprite2D.new()
			tree.offset.y = -256
			tree.scale = Vector2(0.012,0.025)
			tree.position = get_random_point(state.poly.polygon)
			tree.texture = commons.tree_textures[randi() % commons.tree_textures.size()]
			print(tree.position)
			#$BACKGROUND_OBJ.
			add_child(tree)
			trees.append(tree)
	queue_redraw()
			







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

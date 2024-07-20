@tool
extends Node2D

var utils = load("res://scripts/utils.gd").new()
var state_supplier = load("res://scripts/state.gd")

var commons = load("res://scripts/commons.gd").new()

var font
var states = []
var border_line_width = 2
var border_color = Color.BLACK
var constant_mul = 5

var triangles
var cumulated_areas: Array

var _rand


func _draw() -> void:
	draw_line(Vector2.ZERO, Vector2.DOWN*300, Color.AQUA, 0)
	
	draw_string(font, Vector2.ZERO+Vector2.DOWN*30+Vector2.LEFT*50, 'Foko here!')
	print("Drawing states...")
	for state in states:
		var last_line = state.position
		for line in state.curves:
			draw_line(last_line, last_line+line, border_color, border_line_width)
			last_line = last_line+line
		draw_line(last_line, state.position, border_color, border_line_width)
		print("Drawn: ", state.id)
		


func reset_hover_focus():
	for state in states:
		state.area.hover_focus = false;
func reset_select_focus():
	for state in states:
		state.area.select_focus = false;


func update_focus():
	for state in states:
		if state.area.select_focus:
			print("FOCUS ON STATE: " + state.id)
			state.area.get_children()[1].color = commons.select_state_color
		elif state.area.hover_focus:
			print(" (hover) FOCUS ON STATE: " + state.id)
			state.area.get_children()[1].color = commons.hover_state_color
			
		else:
			state.area.get_children()[1].color = commons.default_state_color
			

func resize(x):
	return x*constant_mul


func _ready():
	var player_state = state_supplier.new("Shadow Empire", Vector2.ZERO+ 118*Vector2.DOWN + 122*Vector2.RIGHT, [
		Vector2.LEFT*6+Vector2.DOWN*3, Vector2.DOWN*12+Vector2.LEFT*6, Vector2.RIGHT*3+Vector2.DOWN*3, Vector2.DOWN*6+Vector2.LEFT*6, Vector2.DOWN*9,Vector2.RIGHT*12 + Vector2.UP*3, 
		Vector2.UP*15+Vector2.RIGHT*5
	].map(resize))
	states.append(player_state)
	
	
	var basic_state = state_supplier.new("Enemy Tribe", Vector2.ZERO+ 268*Vector2.DOWN + 107*Vector2.RIGHT, [
		Vector2.UP*15+Vector2.RIGHT*5, Vector2.UP*14+Vector2.RIGHT*12,
		Vector2.DOWN*10+Vector2.RIGHT*5, Vector2.DOWN*8+Vector2.LEFT*7
		
	].map(resize))
	states.append(basic_state)
	
	
	var basic_state2 = state_supplier.new("Enemy Tribe 2", Vector2.ZERO+ 193*Vector2.DOWN + 132*Vector2.RIGHT, [
				Vector2.LEFT*2+Vector2.UP*15,
				Vector2.RIGHT*12+Vector2.UP, Vector2.DOWN*2+Vector2.RIGHT*2
		
	].map(resize))
	states.append(basic_state2)
	
	
	print("Initializing states:")
	for state in states:
		print(state.id)
		add_child(state.gen_area())
	font = FontFile.new()
	font.font_data = load("res://assets/fonts/DaysOne.ttf")
	
	
	
	
	
	
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
		for i in range(12):
			var tree = Sprite2D.new()
			tree.offset.y = -32
			tree.scale = Vector2(0.3,0.5)
			tree.position = get_random_point(state.poly.polygon)
			tree.texture = load("res://assets/images/tree_temp.png")
			print(tree.position)
			#$BACKGROUND_OBJ.
			add_child(tree)
			







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

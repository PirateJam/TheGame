extends Camera2D

var commons = load("res://scripts/commons.gd").new()
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
#var zoom_acceleration = 0.1
var acceleration = 0
var acceleration_rate = 0.1
var slowness = 0.25
var max_acc = 100
var speed = 0.05
var min_zoom = 0.19
var max_zoom = 10

var state_min_zoom = 0.19#1
var state_max_zoom = 10

var dead_zone = 500
var zero_pos = Vector2(0,0)

var off_acc_x = 1
var off_acc_y = 0
var border_range = 200

var d_speed=  8

var render_map
var render_menu
var render_state



func _process(delta):
	match get_node("/root/Menu").render:
		render_map:
			var move_speed = d_speed / zoom.x
			var viewPortMousePos = get_viewport().get_mouse_position()

			if get_viewport().get_mouse_position().x<border_range or (get_viewport().size.x-get_viewport().get_mouse_position().x)<border_range:
				offset.x = offset.move_toward(Vector2((-get_viewport().size/2).x, (-get_viewport().size/2).y) + (viewPortMousePos), 1*move_speed).x
			if get_viewport().get_mouse_position().y<border_range or (get_viewport().size.y-get_viewport().get_mouse_position().y)<border_range:
				offset.y = offset.move_toward(Vector2((-get_viewport().size/2).x, (-get_viewport().size/2).y) + (viewPortMousePos), 1*move_speed).y
		
		
			acceleration= clamp(acceleration, -max_acc, max_acc)

			if acceleration>0:
				acceleration = clamp(acceleration - slowness*delta, -max_acc, acceleration)
			elif acceleration<0:
				acceleration = clamp(acceleration + slowness*delta, acceleration, max_acc)
			if zoom.x==clamp(zoom.x-acceleration*speed, min_zoom, max_zoom) or zoom.y==clamp(zoom.y-acceleration*speed, min_zoom, max_zoom): #resetting acceleration on reaching max
				acceleration=0
			zoom = Vector2(clamp(zoom.x-acceleration*speed, min_zoom, max_zoom), clamp(zoom.y-acceleration*speed, min_zoom, max_zoom))
		render_menu:
			zoom = Vector2(1,1)
			offset = Vector2.ZERO
		render_state:
			var move_speed = d_speed / zoom.x
			var viewPortMousePos = get_viewport().get_mouse_position()
			#zoom = Vector2(commons.state_view_zoom, commons.state_view_zoom)
			
			
			#if get_viewport().get_mouse_position().x<border_range or (get_viewport().size.x-get_viewport().get_mouse_position().x)<border_range:
			#	offset.x = offset.move_toward(Vector2((-get_viewport().size/2).x, (-get_viewport().size/2).y) + (viewPortMousePos), 1*move_speed).x
			#if get_viewport().get_mouse_position().y<border_range or (get_viewport().size.y-get_viewport().get_mouse_position().y)<border_range:
			#	offset.y = offset.move_toward(Vector2((-get_viewport().size/2).x, (-get_viewport().size/2).y) + (viewPortMousePos), 1*move_speed).y
			
			
			
		
			acceleration= clamp(acceleration, -max_acc, max_acc)

			if acceleration>0:
				acceleration = clamp(acceleration - slowness*delta, -max_acc, acceleration)
			elif acceleration<0:
				acceleration = clamp(acceleration + slowness*delta, acceleration, max_acc)
			if zoom.x==clamp(zoom.x-acceleration*speed, state_min_zoom, state_max_zoom) or zoom.y==clamp(zoom.y-acceleration*speed, state_min_zoom, state_max_zoom): #resetting acceleration on reaching max
				acceleration=0
			zoom = Vector2(clamp(zoom.x-acceleration*speed, state_min_zoom, state_max_zoom), clamp(zoom.y-acceleration*speed, state_min_zoom, state_max_zoom))

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				acceleration-= acceleration_rate
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				acceleration+= acceleration_rate



func _ready():
	render_map = get_node("/root/Menu").RENDERS.MAP
	render_menu = get_node("/root/Menu").RENDERS.MAIN_MENU
	render_state = get_node("/root/Menu").RENDERS.STATE
	pass

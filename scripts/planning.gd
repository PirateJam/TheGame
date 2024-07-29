@tool
extends Area2D

var arrow = []
var parent
func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		arrow.append(get_global_mouse_position())
		print(arrow)
		parent.queue_redraw()
		#get_node("/root/Menu").reset_hover_focus()
		#print(in_borders(event.position+event.velocity))
		
		#self.hover_focus = in_borders(event.position+event.velocity)
		#get_node("/root/Menu").update_focus()
		
		
		
		pass

# Called when the node enters the scene tree for the first time.
func _ready():
	input_pickable = true
func _init(parent):
	self.parent = parent
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

@tool
extends Area2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var menu = load("res://scripts/menu.gd").new()
var font
var fparent
var select_focus = false
var hover_focus = false

func _init(parent=null):
	fparent = parent



func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseMotion:
		get_node("/root/Menu").reset_hover_focus()
		self.hover_focus = true
		get_node("/root/Menu").update_focus()
		pass
	if (event is InputEventMouseButton && event.pressed):
		if event.button_index == MOUSE_BUTTON_LEFT:

			get_node("/root/Menu").reset_select_focus()
			self.select_focus = true
			get_node("/root/Menu").update_focus()
			pass
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			#open country info
			pass

# Called when the node enters the scene tree for the first time.
func _ready():
	input_pickable = true
	pass # Replace with function body.

	font = FontFile.new()
	font.font_data = load("res://assets/fonts/DaysOne.ttf")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

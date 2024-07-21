@tool
extends Area2D


var logger = load("res://scripts/logger.gd").new()

var font
var fparent
var action

var select_focus = false
var hover_focus = false

func default_fun():
	print("click!")
var instance = null

func _init(parent=null):#action=null):
	#if not action:
	#	self.action = Callable(self, 'default_fun')
	#else:
	#	self.action = action
	self.fparent = parent



func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseMotion:
		#get_node("/root/Menu").reset_hover_focus()
		#print(in_borders(event.position+event.velocity))
		
		#self.hover_focus = in_borders(event.position+event.velocity)
		#get_node("/root/Menu").update_focus()
		
		pass
	if (event is InputEventMouseButton && event.pressed):
		if event.button_index == MOUSE_BUTTON_LEFT:

			get_node("/root/Menu").reset_select_focus()
			self.select_focus = true
			get_node("/root/Menu").update_focus()
			
			await get_tree().create_timer(.1).timeout
			get_node("/root/Menu").reset_select_focus()
			get_node("/root/Menu").update_focus()
			
			self.fparent.action.call()
			
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
	self.connect("mouse_entered", mouse_entered)
	self.connect("mouse_exited", mouse_exited)
	
func mouse_entered():
	get_node("/root/Menu").reset_hover_focus()
	self.hover_focus = true
	get_node("/root/Menu").update_focus()
func mouse_exited():
	get_node("/root/Menu").reset_hover_focus()
	get_node("/root/Menu").reset_select_focus()
	await get_tree().create_timer(.05).timeout
	
	get_node("/root/Menu").update_focus()



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

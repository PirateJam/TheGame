extends Node

func cutscene(cutscene_ui, title: String, description: String, icon):
	cutscene_ui.get_children()[0].get_children()[0].text = title
	cutscene_ui.get_children()[0].get_children()[1].text = description
	if icon:
		cutscene_ui.get_children()[0].get_children()[2].texture = icon
	cutscene_ui.visible = true
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

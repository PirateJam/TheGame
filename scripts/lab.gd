extends Commons

@export var monster_scene = preload("res://nodes/monster.tscn")

var recruitment_menu: Control
var vbox
var callable

# Called when the node enters the scene tree for the first time.
func _ready():
	recruitment_menu = $RecruitmentMenu
	vbox = $RecruitmentMenu.get_node("VBoxContainer")
	$Recruit.connect("pressed", Callable(self, "_on_Recruit_Button_Pressed"))
	$RecruitmentMenu/VBoxContainer/Back.connect("pressed", Callable(self, "_on_Recruit_Button_Pressed"))
	populate_recruitment_menu()

func _on_Recruit_Button_Pressed():
	print("test1 - recruit button press")
	$Recruit.visible = not $Recruit.visible
	$RecruitmentMenu/VBoxContainer/Back.visible = not $RecruitmentMenu/VBoxContainer/Back.visible
	recruitment_menu.visible = not recruitment_menu.visible

func populate_recruitment_menu():
	for monster in MONSTER_KINDS: 
		var button = Button.new()
		var monster_detail = monster_stats[MONSTER_KINDS[monster]]
		button.text = monster_detail['name']
		button.disabled = monster_detail['locked']
		button.connect("pressed", Callable(self, "_on_Recruit_Monster").bindv([monster]))
		#Button to call _on_Recruit_Monster for the kind clicked
		vbox.add_child(button)

func _on_Recruit_Monster(monster):
	print("Recruiting: " + str(monster))
	#var unit_data = unit_scenes[unit_type]
	"""
	if resources >= recruitment_cost and not unit_data.locked:
		resources -= recruitment_cost
		recruit_unit(unit_type)
	else:
		print("Not enough resources or unit is locked")"""


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

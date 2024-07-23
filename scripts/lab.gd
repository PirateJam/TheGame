extends Commons

@export var monster_scene = preload("res://nodes/monster.tscn")


var recruitment_menu: Control
var vbox

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
		var monster_details = monster_stats[MONSTER_KINDS[monster]]
		button.text = monster_details['name']
		button.disabled = monster_details['locked']
		button.connect("pressed", Callable(self, "_on_Recruit_Monster").bindv([monster]))
		vbox.add_child(button)


func _on_Recruit_Monster(monster):
	var monster_details = monster_stats[MONSTER_KINDS[monster]]
	
	if not monster_details["locked"] and TribeManagement.spend_resources(monster_details["costs"]["recruit"]):
		print("Unit created")
	else:
		print("Unit is locked")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

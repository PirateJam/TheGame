extends Commons

@export var monster_scene = preload("res://nodes/monster.tscn")


var recruitment_menu: Control
var upgrade_menu: Control
var vbox

# Called when the node enters the scene tree for the first time.
func _ready():
	recruitment_menu = $RecruitmentMenu
	upgrade_menu = $UpgradeMenu
	
	$LabMenu/Recruit.connect("pressed", Callable(self, "_on_Recruit_Button_Pressed"))
	$LabMenu/Upgrade.connect("pressed", Callable(self, "_on_Upgrade_Button_Pressed"))
	$RecruitmentMenu/UnitList/Back.connect("pressed", Callable(self, "_on_Recruit_Button_Pressed"))
	
	populate_recruitment_menu()
	populate_upgrade_menu()

func populate_recruitment_menu():
	vbox = $RecruitmentMenu.get_node("UnitList")
	for monster in MONSTER_KINDS: 
		var button = Button.new()
		var monster_details = monster_stats[MONSTER_KINDS[monster]]
		button.text = monster_details['name']
		button.disabled = monster_details['locked']
		button.connect("pressed", Callable(self, "_on_Recruit_Monster").bindv([monster]))
		vbox.add_child(button)

func populate_upgrade_menu():
	#Delete Buttons to avoid duppes
	vbox = $UpgradeMenu.get_node("UnitList")
	for child in vbox.get_children():
		child.queue_free()
	
	#Create a button for each monster in the army
	for unit in TribeManagement.army:
		var button = Button.new()
		button.text = unit['name'] + " Level: " + str(unit["level"])
		if unit["level"] < max_level:
			print("Unit level:::::::::::")
			print( unit["level"])
			button.connect("pressed", Callable(self, "_on_Upgrade_Monster").bindv([unit]))
		else:
			button.text = unit['name'] + " Max Level"
			button.disabled = true
			
		button.connect("mouse_entered", Callable(self, "_on_Monster_Button_Hovered").bindv([unit]))
		vbox.add_child(button)

	#Create Back Button
	var back = Button.new()
	back.text = "Back"
	back.name = "Back"
	back.connect("pressed", Callable(self, "_on_Upgrade_Button_Pressed"))
	vbox.add_child(back)

func populate_info_labels(labels):
	for label_text in labels:
		var label = Label.new()
		label.text = label_text
		vbox.add_child(label)

func _on_Recruit_Button_Pressed():
	print("test1 - recruit button press")
	$LabMenu/Recruit.visible = not $LabMenu/Recruit.visible
	$LabMenu/Upgrade.visible = not $LabMenu/Upgrade.visible
	recruitment_menu.visible = not recruitment_menu.visible

func _on_Upgrade_Button_Pressed():
	print("test2 - upgrade button press")
	$LabMenu/Recruit.visible = not $LabMenu/Recruit.visible
	$LabMenu/Upgrade.visible = not $LabMenu/Upgrade.visible
	upgrade_menu.visible = not upgrade_menu.visible

func _on_Monster_Button_Hovered(monster: Dictionary):
	update_monster_stats(monster)

func _on_Upgrade_Monster(monster: Dictionary):
	TribeManagement.level_monster(monster)
	populate_upgrade_menu()


func update_monster_stats(monster: Dictionary):
	#CLear the resume box
	vbox = $UpgradeMenu.get_node("StatsResume")
	for child in vbox.get_children():
		child.queue_free()
		
		
	var monster_details = monster_stats[monster["kind"]]
	var current_stats = [
		"Level: " + str(monster["level"]),
		"Health: " + str(monster_details["levels"][monster["level"]]["stats"]["health"]),
		"Attack Power: " + str(monster_details["levels"][monster["level"]]["stats"]["attack_power"]),
		"Attack Speed: " + str(monster_details["levels"][monster["level"]]["stats"]["attack_speed"]),
		"Attack Range: " + str(monster_details["levels"][monster["level"]]["stats"]["attack_range"]),
		"Movement Speed: " + str(monster_details["levels"][monster["level"]]["stats"]["movement_speed"]),
	]
	var current_skills = []
	for skill in monster_details["levels"][monster["level"]]["skills"]:
		current_skills.append(monster_details["levels"][monster["level"]]["skills"][skill])

	
	if monster["level"] < max_level:
		var upgraded_stats = [
			"Level: " + str(monster["level"]+1),
			"Health: " + str(monster_details["levels"][monster["level"]+1]["stats"]["health"]),
			"Attack Power: " + str(monster_details["levels"][monster["level"]+1]["stats"]["attack_power"]),
			"Attack Speed: " + str(monster_details["levels"][monster["level"]+1]["stats"]["attack_speed"]),
			"Attack Range: " + str(monster_details["levels"][monster["level"]+1]["stats"]["attack_range"]),
			"Movement Speed: " + str(monster_details["levels"][monster["level"]+1]["stats"]["movement_speed"]),
		]
		
		var upgrade_skills = []
		for skill in monster_details["levels"][monster["level"]+1]["skills"]:
			upgrade_skills.append( monster_details["levels"][monster["level"]+1]["skills"][skill])
		
		#Resources cost
		var upgrade_cost = []
		for resource in monster_details["levels"][monster["level"]+1]["cost"]:
			upgrade_cost.append(resource + ": " + str(monster_details["levels"][monster["level"]+1]["cost"][resource]))
		
		#Cost labels
		var costLabel = Label.new()
		costLabel.text = "Resource cost: "
		vbox.add_child(costLabel)
		populate_info_labels(upgrade_cost)
		
		#stats labels
		populate_info_labels(current_stats)
		var skillLabel = Label.new()
		skillLabel.text = "Skills: "
		vbox.add_child(skillLabel)
		populate_info_labels(current_skills)
		
		#upgrade labels
		var upgradeLabel = Label.new()
		upgradeLabel.text = "Upgrades To: "
		vbox.add_child(upgradeLabel)
		populate_info_labels(upgraded_stats)
		var upgradeSkillLabel = Label.new()
		upgradeSkillLabel.text = "Skills: "
		vbox.add_child(upgradeSkillLabel)
		populate_info_labels(upgrade_skills)
		
	else:
		var upgradeLabel = Label.new()
		upgradeLabel.text = "MAX LEVEL REACHED"
		vbox.add_child(upgradeLabel)
		populate_info_labels(current_stats)
		
		var skillLabel = Label.new()
		skillLabel.text = "Skills: "
		vbox.add_child(skillLabel)
		populate_info_labels(current_skills)
		

func _on_Recruit_Monster(monster):
	var monster_details = monster_stats[MONSTER_KINDS[monster]]
	
	if not monster_details["locked"]:
		if TribeManagement.spend_resources(monster_details["levels"][1]["cost"]):
			TribeManagement.add_to_army(MONSTER_KINDS[monster])
			populate_upgrade_menu()
			print("Unit created")
		else:
			print("Not enough resources")
	else:
		print("Unit is locked")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

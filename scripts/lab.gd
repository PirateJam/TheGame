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
		button.connect("mouse_entered", Callable(self, "_on_Monster_Button_Hovered").bindv([unit]))
		button.connect("pressed", Callable(self, "_on_Upgrade_Monster").bindv([unit]))
		#TODO disble button if unit is max level or not resources to upgrade.
		vbox.add_child(button)

	#Create Back Button
	var back = Button.new()
	back.text = "Back"
	back.name = "Back"
	back.connect("pressed", Callable(self, "_on_Upgrade_Button_Pressed"))
	vbox.add_child(back)

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
	print("Upgrade Button Hover")
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
		"Skills: " + str(monster_details["levels"][monster["level"]]["skills"])
	]
	#TODO bock this when the monster is at max level
	var upgraded_stats = [
		"Level: " + str(monster["level"]+1),
		"Health: " + str(monster_details["levels"][monster["level"]+1]["stats"]["health"]),
		"Attack Power: " + str(monster_details["levels"][monster["level"]+1]["stats"]["attack_power"]),
		"Attack Speed: " + str(monster_details["levels"][monster["level"]+1]["stats"]["attack_speed"]),
		"Attack Range: " + str(monster_details["levels"][monster["level"]+1]["stats"]["attack_range"]),
		"Movement Speed: " + str(monster_details["levels"][monster["level"]+1]["stats"]["movement_speed"]),
		"Skills: " + str(monster_details["levels"][monster["level"]]["skills"])
	]
	#Resources cost
	var upgrade_cost = {}
	for resource in monster_details["levels"][monster["level"]+1]["cost"]:
		upgrade_cost[resource] = monster_details["levels"][monster["level"]+1]["cost"][resource]
	
	var costLabel = Label.new()
	costLabel.text = "Resource cost: "
	vbox.add_child(costLabel)
	
	for cost in upgrade_cost:
		var label = Label.new()
		label.text = cost + ": " + str(upgrade_cost[cost])
		vbox.add_child(label)
		
	for stat in current_stats:
		var label = Label.new()
		label.text = stat
		vbox.add_child(label)
		
	var upgradeLabel = Label.new()
	upgradeLabel.text = "Upgrades To: "
	vbox.add_child(upgradeLabel)
		
	for stat in upgraded_stats:
		var label = Label.new()
		label.text = stat
		vbox.add_child(label)

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

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
		button.connect("mouse_entered", Callable(self, "_on_Unit_Button_Hovered").bindv([unit]))
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

func _on_Unit_Button_Hovered(monster: String):
	print("Upgrade Button Hover")
	print(monster)
	var monster_details = monster_stats[MONSTER_KINDS[monster]]
	update_monster_stats(monster_details)

func update_monster_stats(monster: Dictionary):
	#CLear the resume box
	print(monster)
	vbox = $UpgradeMenu.get_node("StatsResume")
	for child in vbox.get_children():
		child.queue_free()
"""
	var stats = [
		"Name: " + monster_data.name,
		"Health: " + str(unit_data.health),
		"Attack Power: " + str(unit_data.attack_power),
		"Attack Speed: " + str(unit_data.attack_speed),
		"Attack Range: " + str(unit_data.attack_range),
		"Movement Speed: " + str(unit_data.movement_speed)
	]

	for stat in stats:
		var label = Label.new()
		label.text = stat
		unit_stats_container.add_child(label)
"""

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

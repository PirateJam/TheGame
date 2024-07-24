extends Node2D

var max_health: int = 100
var current_health: int = 100

func _ready():
	update_health_bar()

func set_max_health(value: int):
	max_health = value
	$ProgressBar.max_value = value
	update_health_bar()

func set_current_health(value: int):
	current_health = value
	update_health_bar()

func update_health_bar():
	$ProgressBar.value = current_health

func set_color(color: Color):
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = color
	$ProgressBar.add_theme_stylebox("fg", stylebox)

@tool
extends Node
class_name MenuSupplier

var utils = load("res://scripts/utils.gd").new()
var state_area = load("res://scripts/state_area.gd")
var commons = load("res://scripts/commons.gd").new()
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var id
var position
var curves
var area
var poly
var color_obj

var buildings			# array of Building
var army				# array of Monster


func _init(id="unspecified", position=Vector2.ZERO, curves=[], buildings = [], army = []):
	self.id = id
	self.position = position
	self.curves = curves
	self.area = state_area.new(self)
	self.poly = CollisionPolygon2D.new()
	self.color_obj = Polygon2D.new()
	
# Called when the node enters the scene tree for the first time.

func getID():
	return self.id


func gen_poly() -> CollisionPolygon2D:
	self.poly.set_polygon(PackedVector2Array(utils.correctify(self.position,curves)))
	self.color_obj.set_polygon(PackedVector2Array(utils.correctify(self.position,curves)))
	self.color_obj.color = commons.default_state_color
	return self.poly

func gen_area() -> Area2D:
	self.area.add_child(gen_poly())
	self.area.add_child(self.color_obj)
	return self.area


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

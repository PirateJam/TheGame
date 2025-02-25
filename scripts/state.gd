@tool
extends Node
class_name State

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

var controlled
var attacked

var buildings			# array of Building
var army				# array of Monster
var resources
var biome

func _init(id="unspecified", position=Vector2.ZERO, curves=[], buildings = [], army = [], resources={}, biome = commons.BIOMES.FOREST):
	self.id = id
	self.position = position
	self.curves = curves
	self.area = state_area.new(self)
	self.poly = CollisionPolygon2D.new()
	self.color_obj = Polygon2D.new()
	
	self.buildings = buildings
	self.army = army
	self.controlled = false
	self.attacked = false		# by player
	self.resources = resources
	
	self.biome = biome
# Called when the node enters the scene tree for the first time.

func getID():
	return self.id


func gen_poly() -> CollisionPolygon2D:
	self.poly.set_polygon(PackedVector2Array(utils.correctify(self.position,curves)))
	self.color_obj.set_polygon(PackedVector2Array(utils.correctify(self.position,curves)))
	if self.controlled:
		self.color_obj.color = commons.controlled_default_state_color
	else:
		self.color_obj.color = commons.default_state_color
	self.color_obj.texture = commons.get_biome_texture(self.biome)
	match self.biome:
		commons.BIOMES.SNOW:
			self.color_obj.texture_offset = Vector2(300, 200)
			self.color_obj.texture_scale = Vector2(5,5)
		commons.BIOMES.WATER_BODY:
			self.color_obj.texture_scale = Vector2(4,4)
			self.color_obj.texture_offset = Vector2(250, -200)
		commons.BIOMES.DESERT:
			self.color_obj.texture_scale = Vector2(4,4)
			self.color_obj.texture_offset = Vector2(-150, -200)
		commons.BIOMES.SWAMP:
			self.color_obj.texture_scale = Vector2(4,4)
			self.color_obj.texture_offset = Vector2(450, -400)
		_:
			self.color_obj.texture_scale = Vector2(6,6)

	return self.poly

func gen_area() -> Area2D:
	self.area.add_child(gen_poly())
	self.area.add_child(self.color_obj)
	return self.area


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

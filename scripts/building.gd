extends Commons


var button_supplier = load("res://scripts/button_area.gd")

var kind#: BUILDING_KINDS		# pre-init
var level: int = -1					# pre-init
var sprite_rotation: ROTATION
var sprite: Sprite2D
var area: Area2D
var poly: CollisionPolygon2D

var action
#var r_position
var parent_position

func display_building_info(kind):
	print("trying to display building info...")

func _init(kind=null, level=-1, position=Vector2.ZERO, parent_position=Vector2.ZERO, sprite_rotation=ROTATION.FRONT, action=Callable(self, "display_building_info").bindv([self.kind])):
	self.kind = kind
	self.level = level
	
	self.position = position
	self.parent_position = parent_position
	
	self.action = action
	
	
	self.sprite_rotation = sprite_rotation
	
	self.area = button_supplier.new(self) # TO BE DONE - make it do something on click, dependent on self.kind :>
	
	self.poly = CollisionPolygon2D.new()
	self.poly.set_polygon(PackedVector2Array([self.position+32*Vector2.LEFT+32*Vector2.UP,self.position-32*Vector2.LEFT+32*Vector2.UP,self.position-32*Vector2.LEFT-32*Vector2.UP, self.position+32*Vector2.LEFT-32*Vector2.UP]))
func render():
	self.sprite = Sprite2D.new()
	self.sprite.position = self.position+self.parent_position
	match self.sprite_rotation:
		ROTATION.LEFT:
			self.sprite.texture = get_building_textures(self.kind, self.level)[1]
		ROTATION.RIGHT:
			self.sprite.texture = get_building_textures(self.kind, self.level)[1]
		ROTATION.FRONT:
			self.sprite.texture = get_building_textures(self.kind, self.level)[0]
		ROTATION.BACK:
			self.sprite.texture = get_building_textures(self.kind, self.level)[0]
	#self.sprite.offset.y = -32
	return self.sprite
# Called when the node enters the scene tree for the first time.
func get_area():
	self.area.add_child(self.render())
	self.area.add_child(self.poly)
	#self.area.position = self.position+self.parent_position
	return self.area
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

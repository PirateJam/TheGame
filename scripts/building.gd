extends Commons


var kind#: BUILDING_KINDS		# pre-init
var level: int = -1					# pre-init
var sprite_rotation: ROTATION
var sprite: Sprite2D

var position
var parent_position

func _init(kind=null, level=-1, position=Vector2.ZERO, parent_position=Vector2.ZERO, sprite_rotation=ROTATION.FRONT):
	self.kind = kind
	self.level = level
	
	self.position = position
	self.parent_position = parent_position
	
	self.sprite_rotation = sprite_rotation


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
	return self.sprite
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

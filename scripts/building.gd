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

var ui

func display_building_info(kind):
	print("trying to display building info...")
	var title = ""
	var desc = ""
	match kind:
		BUILDING_KINDS.WITCH_HUT:
			title = "Witch Hut"
			desc = "Witch hut. The place where you can\n manage your monsters."
		BUILDING_KINDS.WALL:
			title = "Wall"
			desc = "Wall, decoration."
		BUILDING_KINDS.SAWMILL:
			title = "Sawmill"
			desc = "Sawmill, produces wood for your tribe"
		BUILDING_KINDS.BLACKSMITH:
			title = "Blacksmith"
			desc = "Blacksmith, produces iron for your tribe"
		BUILDING_KINDS.COMMANDER_CAMP:
			title = "Commander Camp"
			desc = "Commander Camp. Used for planning\n attacks. In peace time produces \nsmall amounts of wood."
	ui.get_children()[0].text = title
	ui.get_children()[1].text = desc

func _init(kind=null, level=-1, position=Vector2.ZERO, parent_position=Vector2.ZERO, sprite_rotation=ROTATION.FRONT, ui=null, action=Callable(self, "display_building_info")):
	self.kind = kind
	self.level = level
	
	self.position = position
	self.parent_position = parent_position
	
	self.ui = ui
	if action == Callable(self, "display_building_info"):
		self.action = action.bindv([self.kind])
	else:
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

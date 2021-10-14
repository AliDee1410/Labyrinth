extends Node2D

# Constants
const tile_textures = {
	"Straight": preload("res://Assets/Tiles/Path-Straight.png"),
	"Corner" : preload("res://Assets/Tiles/Path-Corner.png"),
	"Junction" : preload("res://Assets/Tiles/Path-Junction.png")
}

# Node/Scene References
onready var grid = get_parent().get_node("Grid")
onready var sprite = $Sprite
onready var object_sprite = $ObjectSprite

# Fields
var tile_type: int
var item = {}

func initialize(type_in = null):
	if type_in: tile_type = type_in
	update_action_tile()

func update_action_tile():
	# Texture
	match tile_type:
		grid.TileTypes.STRAIGHT: sprite.texture = tile_textures["Straight"]
		grid.TileTypes.CORNER: sprite.texture = tile_textures["Corner"]
		grid.TileTypes.JUNCTION: sprite.texture = tile_textures["Junction"]
	
	# Item
	if item: object_sprite.texture = item["texture"]
	else: object_sprite.texture = null

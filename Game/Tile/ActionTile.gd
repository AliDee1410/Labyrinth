extends Node2D

# Constants
const tile_textures = {
	"Straight": preload("res://Assets/Tiles/Path-Straight.png"),
	"Corner" : preload("res://Assets/Tiles/Path-Corner.png"),
	"Junction" : preload("res://Assets/Tiles/Path-Junction.png")
}

# Node/Scene References
onready var sprite = $Sprite
onready var grid: TileMap = get_parent().get_node("Grid")

# Fields
var tile_type: int

func initialize(type_in = null):
	# Tile type
	if type_in: tile_type = type_in
	else:
		tile_type = grid.moveable_tiles.pop_front()
	
	# Texture
	match tile_type:
		grid.TileTypes.STRAIGHT: sprite.texture = tile_textures["Straight"]
		grid.TileTypes.CORNER: sprite.texture = tile_textures["Corner"]
		grid.TileTypes.JUNCTION: sprite.texture = tile_textures["Junction"]
extends Node2D

# Constants & Enums
enum Directions { UP, RIGHT, DOWN, LEFT }
const TILE_TEXTURES = {
	"Straight": preload("res://Assets/Tiles/Path-Straight.png"),
	"Corner" : preload("res://Assets/Tiles/Path-Corner.png"),
	"Junction" : preload("res://Assets/Tiles/Path-Junction.png"),
	"Home-Red": preload("res://Assets/Tiles/Home-Red.png"),
	"Home-Blue": preload("res://Assets/Tiles/Home-Blue.png"),
	"Home-Green": preload("res://Assets/Tiles/Home-Green.png"),
	"Home-Yellow": preload("res://Assets/Tiles/Home-Yellow.png")
}

# Node/Scene References
onready var sprite = $Sprite
onready var item_sprite = $ItemSprite
onready var tile_info = $TileInfo
onready var area2D = $Area2D
onready var grid: TileMap = get_parent()

# Fields
var grid_pos: Vector2
var tile_type: int
var directions = []
var item: String

func _ready():
	area2D.connect("mouse_entered", self, "on_mouse_enter")
	area2D.connect("mouse_exited", self, "on_mouse_exit")

# DEBUG: Lets me see the grid underneath the tile nodes
func _unhandled_input(event):
	if event is InputEventKey:
        if event.pressed and event.scancode == KEY_SPACE:
            visible = !visible

func initialize(rotation_in, item_in = null):
	# Grid pos & Tile type
	grid_pos = grid.world_to_map(position)
	tile_type = grid.get_cell(grid_pos.x, grid_pos.y)
	
	# Texture
	match tile_type:
		grid.TileTypes.STRAIGHT: sprite.texture = TILE_TEXTURES["Straight"]
		grid.TileTypes.CORNER: sprite.texture = TILE_TEXTURES["Corner"]
		grid.TileTypes.JUNCTION: sprite.texture = TILE_TEXTURES["Junction"]
		grid.TileTypes.HOME:
			match grid_pos:
				Vector2(0,0): sprite.texture = TILE_TEXTURES["Home-Red"]
				Vector2(6,6): sprite.texture = TILE_TEXTURES["Home-Blue"]
				Vector2(0,6): sprite.texture = TILE_TEXTURES["Home-Green"]
				Vector2(6,0): sprite.texture = TILE_TEXTURES["Home-Yellow"]
		grid.TileTypes.IMMOVEABLE: sprite.texture = TILE_TEXTURES["Junction"]
		grid.TileTypes.DISABLED_HOME: sprite.texture = TILE_TEXTURES["Corner"]
	
	# Rotation
	match tile_type:
		grid.TileTypes.STRAIGHT, grid.TileTypes.CORNER, grid.TileTypes.JUNCTION:
			sprite.rotation_degrees = rotation_in
		grid.TileTypes.IMMOVEABLE:
			if grid_pos.x == 0: sprite.rotation_degrees = 180
			elif grid_pos.y == 0: sprite.rotation_degrees = 270
			elif grid_pos.y == 6: sprite.rotation_degrees = 90
			else: match grid_pos:
				Vector2(2,2): sprite.rotation_degrees = 180
				Vector2(4,2): sprite.rotation_degrees = 270
				Vector2(2,4): sprite.rotation_degrees = 90
		grid.TileTypes.HOME, grid.TileTypes.DISABLED_HOME:
			match grid_pos:
				Vector2(0,0): sprite.rotation_degrees = 180
				Vector2(0,6): sprite.rotation_degrees = 90
				Vector2(6,0): sprite.rotation_degrees = 270
	
	# Directions
	match tile_type:
		grid.TileTypes.STRAIGHT:
			match int(sprite.rotation_degrees):
				0: directions = [1,0,1,0]
				90: directions = [0,1,0,1]
				180: directions = [1,0,1,0]
				270: directions = [0,1,0,1]
		grid.TileTypes.CORNER, grid.TileTypes.HOME, grid.TileTypes.DISABLED_HOME:
			match int(sprite.rotation_degrees):
				0: directions = [1,0,0,1]
				90: directions = [1,1,0,0]
				180: directions = [0,1,1,0]
				270: directions = [0,0,1,1]
		grid.TileTypes.JUNCTION, grid.TileTypes.IMMOVEABLE:
			match int(sprite.rotation_degrees):
				0: directions = [1,0,1,1]
				90: directions = [1,1,0,1]
				180: directions = [1,1,1,0]
				270: directions = [0,1,1,1]
	
	# Item
	if item_in:
		item = item_in[0]
		item_sprite.texture = item_in[1]
	
	tile_info.update()

func on_mouse_enter():
	if tile_info.has_object():
		tile_info.show_info()

func on_mouse_exit():
	tile_info.hide_info()
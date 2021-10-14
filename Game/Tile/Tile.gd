extends Node2D

# Constants & Enums
const TILE_TEXTURES = {
	"Straight": preload("res://Assets/Tiles/Path-Straight.png"),
	"Corner" : preload("res://Assets/Tiles/Path-Corner.png"),
	"Junction" : preload("res://Assets/Tiles/Path-Junction.png"),
	"Home-Red": preload("res://Assets/Tiles/Home-Red.png"),
	"Home-Blue": preload("res://Assets/Tiles/Home-Blue.png"),
	"Home-Green": preload("res://Assets/Tiles/Home-Green.png"),
	"Home-Yellow": preload("res://Assets/Tiles/Home-Yellow.png")
}
const player_scene = preload("res://Game/Player/Player.tscn")
# DEBUG: Texture not made yet. Using "Yellow Player" texture for now
const MULTI_OBJECTS = {
	2: preload("res://Assets/Players/Multi-Object-2.png"),
	3: preload("res://Assets/Players/Multi-Object-3.png"),
	4: preload("res://Assets/Players/Multi-Object-4.png"),
	5: preload("res://Assets/Players/Multi-Object-5.png")
}

# Node/Scene References
onready var sprite = $Sprite
onready var object_sprite = $ObjectSprite
onready var players = $Players
onready var tile_info = $TileInfo
onready var area2D = $Area2D

onready var grid = get_parent().get_parent()

# Fields
var grid_pos: Vector2
var tile_type: int
var item = {}
var directions = []

func _ready():
	area2D.connect("mouse_entered", self, "on_mouse_enter")
	area2D.connect("mouse_exited", self, "on_mouse_exit")

func initialize(pos_in, type_in, rotation_in, item_info_in = {}):
	# Setup fields
	grid_pos = pos_in
	tile_type = type_in
	sprite.rotation_degrees = rotation_in
	if item_info_in: item = ItemManager.ITEMS[item_info_in["item_index"]]
	if tile_type == grid.TileTypes.HOME: initialize_player()
	update_tile()

func initialize_player():
	var player = player_scene.instance()
	match grid_pos:
		Vector2(0,0):
			if GameManager.players.size() > 0:
				player.name += "Red"
				player.controller_id = GameManager.players[0]
				player.texture = player.PLAYER_TEXTURES["Red"]
		Vector2(6,6):
			if GameManager.players.size() > 1:
				player.name += "Blue"
				player.controller_id = GameManager.players[1]
				player.texture = player.PLAYER_TEXTURES["Blue"]
		Vector2(0,6):
			if GameManager.players.size() > 2:
				player.name += "Green"
				player.controller_id = GameManager.players[2]
				player.texture = player.PLAYER_TEXTURES["Green"]
		Vector2(6,0):
			if GameManager.players.size() > 3:
				player.name += "Yellow"
				player.controller_id = GameManager.players[3]
				player.texture = player.PLAYER_TEXTURES["Yellow"]
	players.add_child(player)
	
func update_tile():
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
	
	# Update Objects
	update_objects()

func update_objects():
	if item:
		if players.get_child_count() > 0: object_sprite.texture = MULTI_OBJECTS[players.get_child_count() + 1]
		else: object_sprite.texture = item["texture"]
	elif players.get_child_count() > 0:
		if players.get_child_count() > 1: object_sprite.texture = MULTI_OBJECTS[players.get_child_count()]
		else: object_sprite.texture = players.get_child(0).texture
	else: object_sprite.texture = null
	tile_info.update_tile_info()
	
func on_mouse_enter():
	if tile_info.has_object():
		tile_info.show_info()

func on_mouse_exit():
	tile_info.hide_info()

func move_tile(direction, new_tile = null, item_in = {}, players_in = null):
	var old_pos = position
	
	# Move tile
	match direction:
		grid.Directions.UP:
			for i in range(32):
				position.y -= 1
				yield(Utils.create_timer(0.1), "timeout")
		grid.Directions.RIGHT:
			for i in range(32):
				position.x += 1
				yield(Utils.create_timer(0.1), "timeout")
		grid.Directions.DOWN:
			for i in range(32):
				position.y += 1
				yield(Utils.create_timer(0.1), "timeout")
		grid.Directions.LEFT:
			for i in range(32):
				position.x -= 1
				yield(Utils.create_timer(0.1), "timeout")
	
	# Fall off edge
	if position.x == -16 or position.y == -16 or position.x == 240 or position.y == 240:
		# Update action tile
		grid.action_tile.tile_type = tile_type
		grid.action_tile.sprite.rotation_degrees = sprite.rotation_degrees
		grid.action_tile.item = item
		grid.action_tile.update_action_tile()
		
		# Move to next phase (end of "moving" phase)
		if GameManager.active_player_id == Network.STEAM_ID:
			Network.remote_sync_func(GameManager, "next_phase")
		
		# Move player to opposite side
		if players.get_child_count() > 0:
			var opp_tile
			match direction:
				grid.Directions.UP: opp_tile = grid.get_child(6).get_child(grid_pos.x)
				grid.Directions.RIGHT: opp_tile = grid.get_child(grid_pos.y).get_child(0)
				grid.Directions.DOWN: opp_tile = grid.get_child(0).get_child(grid_pos.x)
				grid.Directions.LEFT: opp_tile = grid.get_child(grid_pos.y).get_child(6)
			for player in players.get_children():
				player.move_to(opp_tile)
	
	# Reset position
	position = old_pos
	
	# New info
	tile_type = new_tile[0]
	sprite.rotation_degrees = new_tile[1]
	item = item_in
	if players_in:
		for new_player in players_in:
			new_player.move_to(self)
	update_tile()

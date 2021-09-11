extends Node

onready var loading_screen = $CanvasLayer/LoadingScreen
onready var grid = $Board/Grid
onready var action_tile = $Board/ActionTile

func _ready():
	randomize()
	loading_screen.visible = true
	if get_tree().is_network_server():
		
		# Setup MY game
		GameManager.start_game()
		grid.initialize()
		ItemManager.initialize()
		grid.initialize_tiles()
		action_tile.initialize()
		# Hide Loading Screen
		hide_loading_screen()
		# Retrieve data that needs to be synced
		var data = {}
		data["Players"] = GameManager.players
		data["Grid Tiles"] = grid.tiles
		data["Tile Items"] = ItemManager.tile_items
		data["Tile Rotations"] = grid.tile_rotations
		data["Action Tile"] = action_tile.tile_type
		# Tell clients to setup THEIR game using the data above (syncing)
		rpc("initialize_game", data)

# Called by the server, telling clients to load the game with sync data
remote func initialize_game(data):
	GameManager.start_game(data["Players"])
	grid.initialize(data["Grid Tiles"])
	ItemManager.initialize(data["Tile Items"])
	grid.initialize_tiles(data["Tile Rotations"])
	action_tile.initialize(data["Action Tile"])
	hide_loading_screen()

func hide_loading_screen():
	loading_screen.get_node("AnimationPlayer").play("Fade_Out")
	yield(loading_screen.get_node("AnimationPlayer"), "animation_finished")
	loading_screen.visible = false
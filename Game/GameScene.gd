extends Node

onready var loading_screen = $CanvasLayer/LoadingScreen
onready var grid = $Board/Grid
onready var action_tile = $Board/ActionTile
onready var turn_button = $UI/TurnButton
onready var player_info = $UI/PlayerInfo

func _ready():
	randomize()
	loading_screen.visible = true
	if Network.is_lobby_host():
		
		# Setup MY game
		GameManager.start_game()
		ItemManager.initialize()
		grid.initialize()
		action_tile.initialize()
		turn_button.update_button()
		player_info.initialize()
		# Hide Loading Screen
		hide_loading_screen()
		# Retrieve data that needs to be synced
		var data = {}
		data["Players"] = GameManager.players
		data["Items"] = ItemManager.tile_items
		data["Grid Tiles"] = grid.tiles
		data["Action Tile"] = action_tile.tile_type
		# Tell clients to setup THEIR game using the data above (syncing)
		Network.remote_func(self, "initialize_game", [data])

# Called by the server, telling clients to load the game with sync data
func initialize_game(data):
	print(data["Items"])
	GameManager.start_game(data["Players"])
	ItemManager.initialize(data["Items"])
	grid.initialize(data["Grid Tiles"])
	action_tile.initialize(data["Action Tile"])
	turn_button.update_button()
	player_info.initialize()
	hide_loading_screen()

func hide_loading_screen():
	loading_screen.get_node("AnimationPlayer").play("Fade_Out")
	yield(loading_screen.get_node("AnimationPlayer"), "animation_finished")
	loading_screen.visible = false

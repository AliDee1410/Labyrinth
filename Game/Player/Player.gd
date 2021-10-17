extends Node

const PLAYER_TEXTURES = {
	"Red": preload("res://Assets/Players/Player-Red.png"),
	"Blue": preload("res://Assets/Players/Player-Blue.png"),
	"Green": preload("res://Assets/Players/Player-Green.png"),
	"Yellow": preload("res://Assets/Players/Player-Yellow.png")
}

onready var tile = get_parent().get_parent()
onready var grid = tile.grid

var controller_id
var texture

func _ready():
	GameManager.connect("turn_updated", self, "check_phase")
	GameManager.connect("player_left", self, "on_player_left")

func _unhandled_input(event):
	if GameManager.cur_phase == GameManager.TurnPhases.MovePlayer and GameManager.active_player_id == Network.STEAM_ID:
		if controller_id == Network.STEAM_ID:
			if event is InputEventKey:
				if event.pressed and event.scancode == KEY_UP:
					Network.remote_sync_func(self, "try_move", [grid.Directions.UP])
				elif event.pressed and event.scancode == KEY_RIGHT:
					Network.remote_sync_func(self, "try_move", [grid.Directions.RIGHT])
				elif event.pressed and event.scancode == KEY_DOWN:
					Network.remote_sync_func(self, "try_move", [grid.Directions.DOWN])
				elif event.pressed and event.scancode == KEY_LEFT:
					Network.remote_sync_func(self, "try_move", [grid.Directions.LEFT])
	
func try_move(direction):
	var next_y
	var next_x
	var opp_dir
	match direction:
		grid.Directions.UP:
			next_y = tile.grid_pos.y - 1
			next_x = tile.grid_pos.x
			opp_dir = grid.Directions.DOWN
		grid.Directions.RIGHT:
			next_y = tile.grid_pos.y
			next_x = tile.grid_pos.x + 1
			opp_dir = grid.Directions.LEFT
		grid.Directions.DOWN:
			next_y = tile.grid_pos.y + 1
			next_x = tile.grid_pos.x
			opp_dir = grid.Directions.UP
		grid.Directions.LEFT:
			next_y = tile.grid_pos.y
			next_x = tile.grid_pos.x - 1
			opp_dir = grid.Directions.RIGHT
	if (next_y == 7 or next_y == -1) or (next_x == 7 or next_x == -1): return
	
	var next_tile = grid.get_child(next_y).get_child(next_x)
	if tile.directions[direction] == 0 or next_tile.directions[opp_dir] == 0: return
	
	move_to(next_tile)

func move_to(next_tile):
	var player_clone = tile.player_scene.instance()
	player_clone.name = name
	player_clone.controller_id = controller_id
	player_clone.texture = texture
	
	next_tile.players.add_child(player_clone)
	tile.players.remove_child(self)
	next_tile.update_objects()
	tile.update_objects()
	queue_free()

func check_phase():
	# Called on all clients. No remote function needed
	if GameManager.cur_phase == GameManager.TurnPhases.End and controller_id == GameManager.active_player_id:
		check_tile()

# Check tile for picking up items and winning the game
func check_tile():
	var item = tile.item
	var player_items = ItemManager.tile_items[GameManager.active_player_id]
	var player_info = grid.get_parent().get_parent().get_node("UI/PlayerInfo")
	
	if item:
		if player_items.size() > 0:
			var goal_info = player_items[player_items.size() - 1]
			var goal_item = ItemManager.ITEMS[goal_info["item_index"]]
			
			if item["name"] == goal_item["name"]:
				player_items.pop_back()
				ItemManager.tile_items[GameManager.active_player_id] = player_items
				
				tile.item = {}
				tile.update_objects()
				
				player_info.update_info()
				
				# Finish off the end step / pass to next player
				yield(Utils.create_timer(2), "timeout")
				
	elif tile.tile_type == grid.TileTypes.HOME:
		if player_items.size() == 0:
			if controller_id == tile.player_id:
				Network.WINNER = controller_id
				get_tree().change_scene("res://EndScreen/EndScreen.tscn")
	
	# Finish off the end step / pass to next player
	GameManager.next_phase()

func on_player_left():
	var controller_absent = true
	for player in GameManager.players:
		if player["steam_id"] == controller_id:
			controller_absent = false
	if controller_absent:
		tile.players.remove_child(self)
		tile.update_objects()
		queue_free()

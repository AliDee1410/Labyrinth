extends Node

enum TurnPhases { RotateTile, MoveMaze, MazeMoving, MovePlayer, End }
const colours = ["Red", "Blue", "Green", "Yellow"]

var players: Array
var active_player_index: int
var active_player_id: int
var cur_phase: int

signal turn_updated
signal player_left

func start_game(players_in = null):
	if players_in:
		players = players_in
	else:
		players = []
		for p in range(Network.LOBBY_MEMBERS.size()):
			players.append({
				"steam_id": Network.LOBBY_MEMBERS[p]["steam_id"],
				"colour": colours[p]
			})
	
	active_player_index = 0
	active_player_id = players[active_player_index]["steam_id"]
	cur_phase = TurnPhases.RotateTile

func next_phase():
	cur_phase += 1
	if cur_phase > TurnPhases.End:
		next_player()
	else:
		emit_signal("turn_updated")
	
func next_player():
	active_player_index += 1
	if active_player_index >= players.size(): active_player_index = 0
	active_player_id = players[active_player_index]["steam_id"]
	cur_phase = TurnPhases.RotateTile
	emit_signal("turn_updated")

func remove_player(player_id):
	for player in players:
		if player["steam_id"] == player_id:
			players.erase(player)
	ItemManager.tile_items.erase(player_id)
	emit_signal("player_left")
	
	while active_player_index > (players.size() - 1):
		active_player_index -= 1
	active_player_id = players[active_player_index]["steam_id"]
	cur_phase = TurnPhases.RotateTile
	emit_signal("turn_updated")
	

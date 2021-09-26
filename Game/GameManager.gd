extends Node

enum TurnPhases { Start, RotateTile, MoveMaze, MazeMoving, MovePlayer, End }

var players = []
var active_player_index: int
var active_player_id: int
var cur_phase: int

signal turn_updated

func start_game(players_in = null):
	if players_in: players = players_in
	else: for player_id in Network.players: players.append(player_id)
	
	active_player_index = 0
	active_player_id = players[active_player_index]
	cur_phase = TurnPhases.Start

remotesync func next_phase():
	cur_phase += 1
	if cur_phase > TurnPhases.End:
		next_player()
	else:
		
		# DEBUG
		print("== Next Phase ==")
		match cur_phase:
			1: print("Rotate Tile")
			2: print("Move Maze")
			3: print("Maze Moving")
			4: print("Move Player")
			5: print("End")
		emit_signal("turn_updated")
	
func next_player():
	active_player_index += 1
	if active_player_index >= players.size(): active_player_index = 0
	active_player_id = players[active_player_index]
	cur_phase = TurnPhases.Start
	
	# DEBUG
	print("== Next Player ==")
	print("Start")
	
	emit_signal("turn_updated")
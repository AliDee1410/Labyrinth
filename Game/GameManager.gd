extends Node

enum TurnSteps { Start, RotateTile, PlaceTile, MovePlayer, End }

var players = []
var active_player_index: int
var active_player_id: int
var cur_step: int

signal turn_updated

func start_game(players_in = null):
	print("== Game Start ==")
	
	if players_in: players = players_in
	else: for player_id in Network.players: players.append(player_id)
	
	active_player_index = 0
	active_player_id = players[active_player_index]
	cur_step = TurnSteps.Start
	print_stuff()

remotesync func next_step():
	cur_step += 1
	if cur_step > TurnSteps.End:
		next_player()
	else:
		print("== Next Step ==")
		print_stuff()
		emit_signal("turn_updated")
	
func next_player():
	print("== Next Player ==")
	active_player_index += 1
	if active_player_index >= players.size(): active_player_index = 0
	active_player_id = players[active_player_index]
	cur_step = TurnSteps.Start
	print_stuff()
	emit_signal("turn_updated")

func print_stuff():
	print("Players: " + str(players))
	print("Active ID: " + str(active_player_id))
	print("Cur Step: " + str(cur_step))
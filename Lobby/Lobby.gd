extends Control

onready var player_list = $CenterContainer/VBoxContainer/PlayerList
onready var start_button = $CenterContainer/VBoxContainer/StartButton

func _ready():
	start_button.disabled = false
	Network.connect("players_updated", self, "update_lobby")
	if get_tree().is_network_server(): start_button.show()
	update_lobby()

func update_lobby():
	print("Updating lobby")
#	if get_tree().is_network_server():
#		# Update start button
#		if Network.players.size() >= Network.MIN_PLAYERS:
#			start_button.disabled = false
#		else: start_button.disabled = true
	
	# Update player list
	player_list.clear()
	for player_id in Network.players:
		var player_name = Network.players[player_id]["Player Name"]
		player_list.add_item(player_name, null, false)
		
		# TODO: Player Icons????
	
func _on_StartButton_pressed():
	rpc("load_game")

remotesync func load_game():
	get_tree().change_scene("res://Game/Game.tscn")
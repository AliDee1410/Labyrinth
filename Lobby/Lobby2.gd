extends Control

onready var player_list = $CenterContainer/VBoxContainer/PlayerList
onready var ready_button = $CenterContainer/VBoxContainer/ReadyButton
onready var start_button = $CenterContainer/VBoxContainer/StartButton
onready var ready_label = $CenterContainer/VBoxContainer/ReadyLabel

onready var ready_icon = preload("res://Assets/Green_Circle.png")
onready var not_ready_icon = preload("res://Assets/Red_Circle.png")

var ready = false
var ready_players = [1]

func _ready():
	Network.connect("player_disconnected", self, "remove_disconnected_players")
	if get_tree().is_network_server():
		ready_button.hide()
		start_button.show()
		update_lobby()
	else: rpc_id(1, "new_player_joined", Network.my_player_id)

remotesync func update_lobby():
	var sender = get_tree().get_rpc_sender_id()
	if sender == 0:
		print("Updating my lobby")
	else:
		print("Being told to update my lobby")
	if get_tree().is_network_server():
		# Update start button
		if Network.players.size() >= Network.MIN_PLAYERS and ready_players.size() == Network.players.size():
			start_button.disabled = false
		else: start_button.disabled = true
		
	# Update ready label
	ready_label.text = "Ready " + str(ready_players.size()) + "/" + str(Network.players.size())
	
	# Update player list
	player_list.clear()
	for player_id in Network.players:
		var player_name = Network.players[player_id]["Player Name"]
		if player_id in ready_players: player_list.add_item(player_name, ready_icon, false)
		else: player_list.add_item(player_name, not_ready_icon, false)
		
func _on_ReadyButton_pressed():
	print("Adding myself to my ready_players list")
	# Add myself to my ready_players list
	ready = !ready
	if ready:
		ready_button.text = "Unready"
		ready_players.append(Network.my_player_id)
	else:
		ready_button.text = "Ready"
		ready_players.erase(Network.my_player_id)
	rpc("update_ready_players", ready_players)
	rpc("update_lobby")

# Updates this peer's ready_players list with the given list
remote func update_ready_players(new_ready_players):
	print("Updating ready players list")
	ready_players = new_ready_players

# Removes players that are no longer in the network from the ready_players array
func remove_disconnected_players():
	for player_id in ready_players:
		if not player_id in Network.players:
			ready_players.erase(player_id)
	update_lobby()

remote func new_player_joined(player_id):
	print("Updating the new player")
	rpc_id(player_id, "update_ready_players", ready_players)
	rpc("update_lobby")
	
func _on_StartButton_pressed():
	rpc("load_game")

remotesync func load_game():
	get_tree().change_scene("res://Game/Game.tscn")
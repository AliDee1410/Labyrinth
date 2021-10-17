extends Control

onready var loading_screen = $CanvasLayer/LoadingScreen
onready var start_button = $CenterContainer/VBoxContainer/StartButton
onready var lobby_name = $CenterContainer/VBoxContainer/LobbyName
onready var player_list = $CenterContainer/VBoxContainer/PlayerList

func _ready():
	Network.connect("members_updated", self, "update_lobby")
	Network.connect("successfully_connected", self, "hide_loading_screen")
	loading_screen.visible = true
	print("Loaded Lobby scene")

func hide_loading_screen():
	print("Hiding loading screen")
	loading_screen.get_node("AnimationPlayer").play("Fade_Out")
	yield(loading_screen.get_node("AnimationPlayer"), "animation_finished")
	loading_screen.visible = false
	
func update_lobby():
	print("Updating Lobby scene")
	lobby_name.text = Network.LOBBY_INFO["name"]
	
	player_list.clear()
	for player in Network.LOBBY_MEMBERS:
		player_list.add_item(player["steam_name"], null, false)
	
	start_button.visible = Network.is_lobby_host()
	start_button.disabled = Network.LOBBY_MEMBERS.size() < 2

func _on_LeaveButton_pressed():
	Network.leave_lobby()
	get_tree().change_scene("res://Play Menu/PlayMenu.tscn")

func _on_StartButton_pressed():
	Network.lock_lobby()
	Network.remote_sync_func(self, "load_game")
	
func load_game():
	get_tree().change_scene("res://Game/Game.tscn")

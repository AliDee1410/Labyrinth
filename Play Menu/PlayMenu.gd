extends Control

onready var lobby_name_edit = $CenterContainer/VBoxContainer/LobbyNameEdit

func _on_CreateButton_pressed():
	var lobby_name = lobby_name_edit.text
	if not lobby_name: lobby_name = Network.STEAM_NAME + "'s Lobby"
	Network.create_lobby({"name": lobby_name, "host": Network.STEAM_ID})

func _on_JoinButton_pressed():
	get_tree().change_scene("res://Lobby Browser/LobbyBrowser.tscn")
	

extends Control

onready var player_name = $CenterContainer/VBoxContainer/EnterInfo/NameEdit
onready var selected_ip = $CenterContainer/VBoxContainer/EnterInfo/IPEdit
onready var selected_port = $CenterContainer/VBoxContainer/EnterInfo/PortEdit

func _ready():
	player_name.text = Save.save_data["Player Name"]
	selected_ip.text = Network.DEFAULT_IP
	selected_port.text = str(Network.DEFAULT_PORT)

func _on_NameEdit_text_changed():
	Save.save_data["Player Name"] = player_name.text
	Save.write_save()

func _on_HostButton_pressed():
	Network.create_server()
	load_lobby()

func _on_JoinButton_pressed():
	Network.selected_ip = selected_ip.text
	Network.selected_port = int(selected_port.text)
	Network.join_server()
	load_lobby()
	
func load_lobby():
	print("Loading lobby")
	get_tree().change_scene("res://Lobby/Lobby.tscn")
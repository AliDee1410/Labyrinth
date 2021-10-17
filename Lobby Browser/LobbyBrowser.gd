extends Control

enum SEARCH_DISTANCE { Close, Default, Far, Worldwide }

onready var steam_name = $SteamName
onready var lobby_container = $LobbiesPanel/LobbyContainer/VBoxContainer

func _ready():
	steam_name.text = "Steam Name: " + Network.STEAM_NAME
	Steam.connect("lobby_match_list", self, "on_lobby_match_list")
	request_lobby_list()

func request_lobby_list():
	for lobby in lobby_container.get_children():
		lobby_container.remove_child(lobby)
	Steam.addRequestLobbyListDistanceFilter(SEARCH_DISTANCE.Worldwide)
	Steam.requestLobbyList()
	
func _on_BackButton_pressed():
	get_tree().change_scene("res://Play Menu/PlayMenu.tscn")
	
func _on_RefreshButton_pressed():
	request_lobby_list()
	
# ===============
# Callbacks
# ===============
	
func on_lobby_match_list(lobbies):
	for lobby_id in lobbies:
		if Steam.getLobbyData(lobby_id, "is_labyrinth") == "yes":
			var lobby_name = Steam.getLobbyData(lobby_id, "name")
			var member_count = Steam.getNumLobbyMembers(lobby_id)
			
			var lobby_button = Button.new()
			lobby_button.set_text(lobby_name + " - [" + str(member_count) + "] Players")
			lobby_button.rect_min_size = Vector2(1530, 50)
			lobby_button.set_name("lobby_" + str(lobby_id))
			lobby_button.connect("pressed", Network, "join_lobby", [lobby_id])
			
			lobby_container.add_child(lobby_button)
			

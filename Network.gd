extends Node

const DEFAULT_IP = "127.0.0.1"
const DEFAULT_PORT = 6753
const MAX_PLAYERS = 4
const MIN_PLAYERS = 2

var network = NetworkedMultiplayerENet.new()

var selected_ip
var selected_port

var my_player_id
var my_player_data = {}
var players = {}

signal players_updated

func _ready():
	get_tree().connect("network_peer_connected", self, "player_connected")
	get_tree().connect("network_peer_disconnected", self, "player_disconnected")
	get_tree().connect("connected_to_server", self, "successfully_connected")
	get_tree().connect("connection_failed", self, "failed_to_connect")
	get_tree().connect("server_disconnected", self, "disconnected_from_server")

func create_server():
	network.create_server(DEFAULT_PORT, MAX_PLAYERS)
	get_tree().network_peer = network
	print("Server Started")
	
	print("Registering myself...")
	my_player_id = get_tree().get_network_unique_id()
	my_player_data = Save.save_data
	register_player(my_player_id, my_player_data)

remote func register_player(player_id, player_data):
	var sender = get_tree().get_rpc_sender_id()
	if sender: print("Recieveing data from player " + str(sender))
	players[player_id] = player_data
	emit_signal("players_updated")
	print(players)

func join_server():
	print("Joining server...")
	network.create_client(selected_ip, selected_port)
	get_tree().network_peer = network
	
	print("Registering myself...")
	my_player_id = get_tree().get_network_unique_id()
	my_player_data = Save.save_data
	register_player(my_player_id, my_player_data)
	
# Called on ALL peers when a new player joins
func player_connected(player_id):
	print("Connected to player " + str(player_id) + ". Sending them my data now...")
	rpc_id(player_id, "register_player", my_player_id, my_player_data)

# Called on ALL peers when a player disconnects
func player_disconnected(player_id):
	print("Player " + str(player_id) + " disconnected from me. Removing them now...")
	players.erase(player_id)
	emit_signal("players_updated")

func successfully_connected():
	print("Successfully connected to server!")

func failed_to_connect():
	print("Failed to connect to server!")

func disconnected_from_server():
	print("Disconnected from server!")
extends Node

# Constants
enum LOBBY_STATUS { Private, Friends, Public, Invisible }
const MAX_PLAYERS = 4
const SEND_TYPE = 2 # Send reliable
const CHANNEL = 0

# Steam Account vars
var STEAM_ID: int
var STEAM_NAME: String
var OWNED = false
var ONLINE = false

# Steam Lobby vars
var LOBBY_ID: int = 0
var LOBBY_INFO = {"name": "", "host": 0}
var LOBBY_MEMBERS = []
var LOBBY_INVITE_ARG = false

# Custom signals
signal members_updated
signal successfully_connected

# ====================
# Built-in Functions
# ====================

func _ready():
	var INIT = Steam.steamInit()
	if INIT["status"] != 1:
		print("Failed to initialise Steam. " + str(INIT["verbal"]) + " Shutting down...")
		get_tree().quit()
	
	STEAM_ID = Steam.getSteamID()
	STEAM_NAME = Steam.getPersonaName()
	OWNED = Steam.isSubscribed()
	ONLINE = Steam.loggedOn()
	
	if not OWNED:
		print("User does not own this game")
		get_tree().quit()
		
	Steam.connect("lobby_created", self, "on_lobby_created")
	Steam.connect("lobby_joined", self, "on_lobby_joined")
	Steam.connect("join_requested", self, "on_lobby_join_requested")
	Steam.connect("lobby_data_update", self, "on_lobby_data_update")
	Steam.connect("lobby_chat_update", self, "on_lobby_chat_update")
	Steam.connect("lobby_message", self, "on_lobby_message")
	Steam.connect("p2p_session_request", self, "on_p2p_session_request")
	Steam.connect("p2p_session_connect_fail", self, "on_p2p_session_fail")
	check_command_line()

func _process(delta):
	Steam.run_callbacks()
	read_p2p_packet()

# ====================
# Functions
# ====================

func output(message: String):
	print(message)
	# Do other stuff...

func create_lobby(info):
	if LOBBY_ID == 0:
		LOBBY_INFO = info
		output("Creating lobby " + LOBBY_INFO["name"] + "...")
		Steam.createLobby(LOBBY_STATUS.Public, MAX_PLAYERS)
		get_tree().change_scene("res://Lobby/Lobby.tscn")

func join_lobby(lobby_id):
	var lobby_name = Steam.getLobbyData(lobby_id, "name")
	output("Attempting to join lobby " + lobby_name + "...")
	LOBBY_MEMBERS.clear()
	Steam.joinLobby(lobby_id)
	get_tree().change_scene("res://Lobby/Lobby.tscn")

func update_lobby_members():
	LOBBY_MEMBERS.clear()
	
	var member_count = Steam.getNumLobbyMembers(LOBBY_ID)
	for member in range(member_count):
		var steam_id = Steam.getLobbyMemberByIndex(LOBBY_ID, member)
		var steam_name = Steam.getFriendPersonaName(steam_id)
		LOBBY_MEMBERS.append({"steam_id": steam_id, "steam_name": steam_name})
		
	print("Lobby members below: " + str(LOBBY_MEMBERS))
	emit_signal("members_updated")

func leave_lobby():
	if LOBBY_ID != 0:
		Steam.leaveLobby(LOBBY_ID)
		LOBBY_ID = 0
		
		for member in LOBBY_MEMBERS:
			if member["steam_id"] != STEAM_ID:
				Steam.closeP2PSessionWithUser(member["steam_id"])
				
		LOBBY_MEMBERS.clear()
		output("Left lobby " + LOBBY_INFO["name"])
		LOBBY_INFO = {"name": "", "host": 0}
		update_lobby_members()

func make_p2p_handshake():
	print("Sending P2P handshake to lobby members...")
	send_p2p_packet("all", {"type": "handshake", "from": STEAM_ID})

func send_p2p_packet(target: String, packet_data: Dictionary):
	var data: PoolByteArray
	data.append_array(var2bytes(packet_data))
	
	if target == "all":
		if LOBBY_MEMBERS.size() > 1:
			for member in LOBBY_MEMBERS:
				if member["steam_id"] != STEAM_ID:
					Steam.sendP2PPacket(member["steam_id"], data, SEND_TYPE, CHANNEL)
	else:
		Steam.sendP2PPacket(int(target), data, SEND_TYPE, CHANNEL)

func read_p2p_packet():
	var packet_size = Steam.getAvailableP2PPacketSize(0)
	
	if packet_size > 0:
		var packet = Steam.readP2PPacket(packet_size, 0)
		if packet.empty(): print("WARNING: Read an empty packet with non-zero size!")
		
		var readable_data = bytes2var(packet["data"])
		process_packet_data(readable_data)

# What should we do with the data recieved?
func process_packet_data(data):
	var type: String = data["type"]
	if type == "handshake":
		var from = Steam.getFriendPersonaName(data["from"])
		output("Recieved Handshake from " + str(from))
	elif type == "remote_func":
		var node = get_node(data["path"])
		var function = data["function"]
		var args = data["args"]
		node.callv(function, args)
	elif type == "property":
		var property: String = data["property"]
		var value = data["value"]
		set(property, value)

func is_lobby_host() -> bool:
	if LOBBY_ID == 0: return false
	if STEAM_ID == LOBBY_INFO["host"]: return true
	return false

# Call function on all OTHER connected peers
func remote_func(node: Node, function: String, args = []):
	var packet_data = {
		"type": "remote_func",
		"path": node.get_path(),
		"function": function,
		"args": args
	}
	send_p2p_packet("all", packet_data)
	
# Call function on ALL connected peers (including myself)
func remote_sync_func(node: Node, function: String, args = []):
	var packet_data = {
		"type": "remote_func",
		"path": node.get_path(),
		"function": function,
		"args": args
	}
	send_p2p_packet("all", packet_data)
	node.callv(function, args)

# ====================
# Steam Callbacks
# ====================

func on_lobby_created(connect, lobby_id):
	if connect == 1:
		LOBBY_ID = lobby_id
		
		Steam.setLobbyJoinable(LOBBY_ID, true)
		Steam.setLobbyData(LOBBY_ID, "name", LOBBY_INFO["name"])
		Steam.setLobbyData(LOBBY_ID, "host", str(LOBBY_INFO["host"]))
		Steam.setLobbyData(LOBBY_ID, "is_labyrinth", "yes")
		Steam.allowP2PPacketRelay(true)
		
		var lobby_name = Steam.getLobbyData(LOBBY_ID, "name")
		output("Created Lobby " + lobby_name)

func on_lobby_joined(lobby_id, perms, locked, response):
	if response == 1:
		LOBBY_ID = lobby_id
		
		var lobby_name = Steam.getLobbyData(LOBBY_ID, "name")
		var host = int(Steam.getLobbyData(LOBBY_ID, "host"))
		LOBBY_INFO = {"name": lobby_name, "host": host}
		output("Joined Lobby " + lobby_name)
		
		update_lobby_members()
		make_p2p_handshake()
		emit_signal("successfully_connected")
	else:
		var FAIL_REASON: String
		match response:
			2: FAIL_REASON = "This lobby no longer exists."
			3: FAIL_REASON = "You don't have permission to join this lobby."
			4: FAIL_REASON = "The lobby is now full."
			5: FAIL_REASON = "Uh... something unexpected happened!"
			6: FAIL_REASON = "You are banned from this lobby."
			7: FAIL_REASON = "You cannot join due to having a limited account."
			8: FAIL_REASON = "This lobby is locked or disabled."
			9: FAIL_REASON = "This lobby is community locked."
			10: FAIL_REASON = "A user in the lobby has blocked you from joining."
			11: FAIL_REASON = "A user you have blocked is in the lobby."
		output(FAIL_REASON)

func on_lobby_join_requested(lobby_id, friend_id):
	var owner_name = Steam.getFriendPersonaName(friend_id)
	output("Joining " + owner_name + "'s lobby...")
	join_lobby(lobby_id)

func on_lobby_data_update(success, lobby_id, member_id, key):
	print("Success: " + str(success) + ", Lobby ID: " + str(lobby_id) + ", Member ID: " + str(member_id) + ", Key: " + str(key))

func on_lobby_chat_update(lobby_id, changed_id, making_change_id, chat_state):
	var changer = Steam.getFriendPersonaName(making_change_id)
	
	match chat_state:
		1: output(changer + " has joined the lobby.")
		2: output(changer + " has left the lobby.")
		8: output(changer + " has been kicked from the lobby.")
		16: output(changer + " has been banned from the lobby.")
		_: output(changer + " did something...")
	
	update_lobby_members()

# Callback from make_p2p_handshake()
func on_p2p_session_request(requester_id):
	var requester = Steam.getFriendPersonaName(requester_id)
	Steam.acceptP2PSessionWithUser(requester_id)
	make_p2p_handshake() # Send handshake back

func on_p2p_session_fail(steam_id, session_error):
	match session_error:
		0: print("WARNING: Session failure with " + str(steam_id) + " [no error given].")
		1: print("WARNING: Session failure with " + str(steam_id) + " [target user not running the same game].")
		2: print("WARNING: Session failure with " + str(steam_id) + " [local user doesn't own the app].")
		3: print("WARNING: Session failure with " + str(steam_id) + " [target user isn't connected to Steam].")
		4: print("WARNING: Session failure with " + str(steam_id) + " [connection timed out].")
		5: print("WARNING: Session failure with " + str(steam_id) + " [unused].")
		_: print("WARNING: Session failure with " + str(steam_id) + " [unknown error " + str(session_error) + "].")

# ====================
# Check Arguments
# ====================
func check_command_line():
	var ARGS = OS.get_cmdline_args()
	
	if ARGS.size() > 0:
		for arg in ARGS:
			if LOBBY_INVITE_ARG:
				join_lobby(int(arg))
				
			if arg == "+connect_lobby":
				LOBBY_INVITE_ARG = true

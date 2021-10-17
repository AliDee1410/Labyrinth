extends Control

const textures = {
	"Red":
	[
		preload("res://Assets/Players/Player Info/Red/Info-0-Red.png"),
		preload("res://Assets/Players/Player Info/Red/Info-1-Red.png"),
		preload("res://Assets/Players/Player Info/Red/Info-2-Red.png"),
		preload("res://Assets/Players/Player Info/Red/Info-3-Red.png"),
		preload("res://Assets/Players/Player Info/Red/Info-4-Red.png"),
		preload("res://Assets/Players/Player Info/Red/Info-5-Red.png"),
		preload("res://Assets/Players/Player Info/Red/Info-6-Red.png"),
		preload("res://Assets/Players/Player Info/Red/Info-7-Red.png")
	],
	"Blue":
	[
		preload("res://Assets/Players/Player Info/Blue/Info-0-Blue.png"),
		preload("res://Assets/Players/Player Info/Blue/Info-1-Blue.png"),
		preload("res://Assets/Players/Player Info/Blue/Info-2-Blue.png"),
		preload("res://Assets/Players/Player Info/Blue/Info-3-Blue.png"),
		preload("res://Assets/Players/Player Info/Blue/Info-4-Blue.png"),
		preload("res://Assets/Players/Player Info/Blue/Info-5-Blue.png"),
		preload("res://Assets/Players/Player Info/Blue/Info-6-Blue.png"),
		preload("res://Assets/Players/Player Info/Blue/Info-7-Blue.png")
	],
	"Green":
	[
		preload("res://Assets/Players/Player Info/Green/Info-0-Green.png"),
		preload("res://Assets/Players/Player Info/Green/Info-1-Green.png"),
		preload("res://Assets/Players/Player Info/Green/Info-2-Green.png"),
		preload("res://Assets/Players/Player Info/Green/Info-3-Green.png"),
		preload("res://Assets/Players/Player Info/Green/Info-4-Green.png"),
		preload("res://Assets/Players/Player Info/Green/Info-5-Green.png"),
		preload("res://Assets/Players/Player Info/Green/Info-6-Green.png"),
		preload("res://Assets/Players/Player Info/Green/Info-7-Green.png")
	],
	"Yellow":
	[
		preload("res://Assets/Players/Player Info/Yellow/Info-0-Yellow.png"),
		preload("res://Assets/Players/Player Info/Yellow/Info-1-Yellow.png"),
		preload("res://Assets/Players/Player Info/Yellow/Info-2-Yellow.png"),
		preload("res://Assets/Players/Player Info/Yellow/Info-3-Yellow.png"),
		preload("res://Assets/Players/Player Info/Yellow/Info-4-Yellow.png"),
		preload("res://Assets/Players/Player Info/Yellow/Info-5-Yellow.png"),
		preload("res://Assets/Players/Player Info/Yellow/Info-6-Yellow.png"),
		preload("res://Assets/Players/Player Info/Yellow/Info-7-Yellow.png")
	]
}

onready var active_player = $ActivePlayer
onready var cards = $Cards

func _ready():
	GameManager.connect("turn_updated", self, "check_phase")

func check_phase():
	# Update to show new active player
	if GameManager.cur_phase == GameManager.TurnPhases.RotateTile:
		update_info()

func update_info():
	# Active player
	var frames = SpriteFrames.new()
	var colour = GameManager.players[GameManager.active_player_index]["colour"]
	for texture in textures[colour]:
		frames.add_frame("default", texture)
	active_player.frames = frames
	
	# Number of cards LEFT
	var player_items = ItemManager.tile_items[GameManager.active_player_id]
	var num_items_left = ItemManager.ITEMS_PER_PLAYER - player_items.size()
	active_player.frame = num_items_left
	
	# Cards	
	for card in cards.get_children():
		card.disable()
		
	if Network.STEAM_ID == GameManager.active_player_id:
		for i in range(player_items.size()):
			if i == (player_items.size() - 1):
				cards.get_child(i).enable(player_items[i])
			else: cards.get_child(i).enable()

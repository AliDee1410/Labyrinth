extends Control

const textures = [
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
]

onready var active_player = $ActivePlayer
onready var cards = $Cards

func _ready():
	GameManager.connect("turn_updated", self, "update_info")

func initialize():
	update_info()

func update_info():
	if GameManager.cur_phase == GameManager.TurnPhases.Start:
		var frames = SpriteFrames.new()
		for texture in textures[GameManager.active_player_index]:
			frames.add_frame("default", texture)
		active_player.frames = frames
		
		var player_items = ItemManager.tile_items[GameManager.active_player_id]
		print(player_items)
		
		for card in cards.get_children():
			card.disable()
		
		for i in range(player_items.size()):
			if i == (player_items.size() - 1):
				cards.get_child(i).enable(player_items[i])
			else: cards.get_child(i).enable()

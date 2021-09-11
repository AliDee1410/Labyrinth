extends Node

const ITEMS = [
	["Circle-Blue", preload("res://Assets/Items/Item-Circle-Blue.png")],
	["Circle-Green", preload("res://Assets/Items/Item-Circle-Green.png")],
	["Circle-Orange", preload("res://Assets/Items/Item-Circle-Orange.png")],
	["Circle-Pink", preload("res://Assets/Items/Item-Circle-Pink.png")],
	["Circle-Red", preload("res://Assets/Items/Item-Circle-Red.png")],
	["Circle-Yellow", preload("res://Assets/Items/Item-Circle-Yellow.png")],
	["Diamond-Blue", preload("res://Assets/Items/Item-Diamond-Blue.png")],
	["Diamond-Green", preload("res://Assets/Items/Item-Diamond-Green.png")],
	["Diamond-Orange", preload("res://Assets/Items/Item-Diamond-Orange.png")],
	["Diamond-Pink", preload("res://Assets/Items/Item-Diamond-Pink.png")],
	["Diamond-Red", preload("res://Assets/Items/Item-Diamond-Red.png")],
	["Diamond-Yellow", preload("res://Assets/Items/Item-Diamond-Yellow.png")],
	["Square-Blue", preload("res://Assets/Items/Item-Square-Blue.png")],
	["Square-Green", preload("res://Assets/Items/Item-Square-Green.png")],
	["Square-Orange", preload("res://Assets/Items/Item-Square-Orange.png")],
	["Square-Pink", preload("res://Assets/Items/Item-Square-Pink.png")],
	["Square-Red", preload("res://Assets/Items/Item-Square-Red.png")],
	["Square-Yellow", preload("res://Assets/Items/Item-Square-Yellow.png")],
	["Triangle-Blue", preload("res://Assets/Items/Item-Triangle-Blue.png")],
	["Triangle-Green", preload("res://Assets/Items/Item-Triangle-Green.png")],
	["Triangle-Orange", preload("res://Assets/Items/Item-Triangle-Orange.png")],
	["Triangle-Pink", preload("res://Assets/Items/Item-Triangle-Pink.png")],
	["Triangle-Red", preload("res://Assets/Items/Item-Triangle-Red.png")],
	["Triangle-Yellow", preload("res://Assets/Items/Item-Triangle-Yellow.png")],
]
const ITEMS_PER_PLAYER = 6

onready var num_players = 2 # TODO: Set to Network.players.size()
var tile_items = [] # List of lists containing 6 items for each player

func initialize(items_in = null, indexes_in = null):
	# Get Items
	if items_in: tile_items = items_in
	else:
		var items = ITEMS.duplicate()
		var tiles_with_items = [0,6,42,48] # These indexes are home tiles (they cannot have items!)
		
		# Player Items
		for i in range(num_players):
			var player_items = []
			for j in range(ITEMS_PER_PLAYER):
				var item = Utils.choose(items)
				var tile = randi() % 49
				if tile in tiles_with_items:
					while tile in tiles_with_items:
						tile = randi() % 49
				tiles_with_items.append(tile)
				player_items.append([item, tile])
				items.erase(item)
			tile_items.append(player_items)
		
		# Other Items
		var other_items = []
		for item in items:
			var tile = randi() % 49
			if tile in tiles_with_items:
				while tile in tiles_with_items:
					tile = randi() % 49
			tiles_with_items.append(tile)
			other_items.append([item, tile])
		tile_items.append(other_items)
	
	# DEBUG: Print Items
	for p in range(num_players):
		print("Player " + str(p+1) + " Items")
		for item in tile_items[p]:
			print(item)
	print("Other Items")
	for item in tile_items[num_players]:
		print(item)
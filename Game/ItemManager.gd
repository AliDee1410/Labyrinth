extends Node

const ITEMS = [
	{"name": "Circle-Blue", "texture": preload("res://Assets/Items/Item-Circle-Blue.png")},
	{"name": "Circle-Green", "texture": preload("res://Assets/Items/Item-Circle-Green.png")},
	{"name": "Circle-Orange", "texture": preload("res://Assets/Items/Item-Circle-Orange.png")},
	{"name": "Circle-Pink", "texture": preload("res://Assets/Items/Item-Circle-Pink.png")},
	{"name": "Circle-Red", "texture": preload("res://Assets/Items/Item-Circle-Red.png")},
	{"name": "Circle-Yellow", "texture": preload("res://Assets/Items/Item-Circle-Yellow.png")},
	{"name": "Diamond-Blue", "texture": preload("res://Assets/Items/Item-Diamond-Blue.png")},
	{"name": "Diamond-Green", "texture": preload("res://Assets/Items/Item-Diamond-Green.png")},
	{"name": "Diamond-Orange", "texture": preload("res://Assets/Items/Item-Diamond-Orange.png")},
	{"name": "Diamond-Pink", "texture": preload("res://Assets/Items/Item-Diamond-Pink.png")},
	{"name": "Diamond-Red", "texture": preload("res://Assets/Items/Item-Diamond-Red.png")},
	{"name": "Diamond-Yellow", "texture": preload("res://Assets/Items/Item-Diamond-Yellow.png")},
	{"name": "Square-Blue", "texture": preload("res://Assets/Items/Item-Square-Blue.png")},
	{"name": "Square-Green", "texture": preload("res://Assets/Items/Item-Square-Green.png")},
	{"name": "Square-Orange", "texture": preload("res://Assets/Items/Item-Square-Orange.png")},
	{"name": "Square-Pink", "texture": preload("res://Assets/Items/Item-Square-Pink.png")},
	{"name": "Square-Red", "texture": preload("res://Assets/Items/Item-Square-Red.png")},
	{"name": "Square-Yellow", "texture": preload("res://Assets/Items/Item-Square-Yellow.png")},
	{"name": "Triangle-Blue", "texture": preload("res://Assets/Items/Item-Triangle-Blue.png")},
	{"name": "Triangle-Green", "texture": preload("res://Assets/Items/Item-Triangle-Green.png")},
	{"name": "Triangle-Orange", "texture": preload("res://Assets/Items/Item-Triangle-Orange.png")},
	{"name": "Triangle-Pink", "texture": preload("res://Assets/Items/Item-Triangle-Pink.png")},
	{"name": "Triangle-Red", "texture": preload("res://Assets/Items/Item-Triangle-Red.png")},
	{"name": "Triangle-Yellow", "texture": preload("res://Assets/Items/Item-Triangle-Yellow.png")},
	
	{"name": "Circle-Yellow-2", "texture": preload("res://Assets/Items/Item-Circle-Yellow.png")},
	{"name": "Diamond-Yellow-2", "texture": preload("res://Assets/Items/Item-Diamond-Yellow.png")},
	{"name": "Square-Yellow-2", "texture": preload("res://Assets/Items/Item-Square-Yellow.png")},
	{"name": "Triangle-Yellow-2", "texture": preload("res://Assets/Items/Item-Triangle-Yellow.png")}
]
const ITEMS_PER_PLAYER = 7

var tile_items = {} # List of lists containing 6 items for each player

func initialize(items_in = null):
	# Get Items
	if items_in: tile_items = items_in
	else:
		# List of poses and indexes already in use
		var item_poses = [Vector2(0,0), Vector2(6,6), Vector2(0,6), Vector2(6,0)]
		var item_indexes = []
		var num_players = Network.LOBBY_MEMBERS.size()
		
		# Player Items
		for player in range(num_players):
			var player_items = []
			for i in range(ITEMS_PER_PLAYER):
				
				var item_index = randi() % ITEMS.size()
				if item_index in item_indexes:
					while item_index in item_indexes:
						item_index = randi() % ITEMS.size()
				item_indexes.append(item_index)
				
				var item_pos = Vector2(randi() % 7, randi() % 7)
				if item_pos in item_poses:
					while item_pos in item_poses:
						item_pos = Vector2(randi() % 7, randi() % 7)
				item_poses.append(item_pos)
				
				player_items.append({"item_index": item_index, "spawn_pos": item_pos})
			tile_items[Network.LOBBY_MEMBERS[player]["steam_id"]] = player_items
		
		# Other Items
		var other_items = []
		for i in range(ITEMS.size() - item_indexes.size()):
			
			var item_index = randi() % ITEMS.size()
			if item_index in item_indexes:
				while item_index in item_indexes:
					item_index = randi() % ITEMS.size()
			item_indexes.append(item_index)
				
			var item_pos = Vector2(randi() % 7, randi() % 7)
			if item_pos in item_poses:
				while item_pos in item_poses:
					item_pos = Vector2(randi() % 7, randi() % 7)
			item_poses.append(item_pos)
			
			other_items.append({"item_index": item_index, "spawn_pos": item_pos})
		tile_items["other_items"] = other_items
		

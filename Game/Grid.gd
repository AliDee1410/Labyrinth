extends TileMap

# Constants & Enums
enum TileTypes { STRAIGHT, CORNER, JUNCTION, IMMOVEABLE, HOME, DISABLED_HOME  }
const rotations = [0,90,180,270]

# Node/Scene References
var tile_scene = preload("res://Game/Tile/Tile.tscn")

# Fields
onready var num_players = 2
var moveable_tiles = [
	0,0,0,0,0,0,0,0,0,0,0,0,
	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
	2,2,2,2,2,2
]
var tiles = []
var tile_rotations = []

func initialize(tiles_in = null):
	if tiles_in: tiles = tiles_in
	else: tiles = create_tiles()
	place_tiles()
	
func create_tiles():
	var tiles_out = []
	for y in range(7):
		var row = []
		for x in range(7):
			var tile = null
			# Home tiles
			if (y == 0 or y == 6) and (x == 0 or x == 6):
				match num_players:
					1, 2:
						if (y == 0 and x == 0) or (y == 6 and x == 6): tile = TileTypes.HOME
						else: tile = TileTypes.DISABLED_HOME
					3:
						if (y == 6 and x == 6): tile = TileTypes.DISABLED_HOME
						else: tile = TileTypes.HOME
						
					4: tile = TileTypes.HOME
			# Immoveable tiles
			if (y == 0 or y == 6) and (x == 2 or x == 4): tile = TileTypes.IMMOVEABLE
			if (y == 2 or y == 4) and (x == 0 or x == 2 or x == 4 or x == 6): tile = TileTypes.IMMOVEABLE
			# Other tiles
			if moveable_tiles.size() > 0 and tile == null:
				tile = Utils.choose(moveable_tiles)
				moveable_tiles.erase(tile)
			row.append(tile)
		tiles_out.append(row)
	print(moveable_tiles)
	return tiles_out

func place_tiles():
	for y in range(7):
		for x in range(7):
			set_cell(x, y, tiles[y][x])

func initialize_tiles(tile_rotations_in = null):
	if tile_rotations_in:
		tile_rotations = tile_rotations_in
	else:
		for i in range(get_child_count()):
			tile_rotations.append(Utils.choose(rotations))
	for i in get_child_count():
		get_child(i).initialize(tile_rotations[i])


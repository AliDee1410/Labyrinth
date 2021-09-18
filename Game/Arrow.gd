extends TextureButton

onready var grid = get_parent().get_parent().get_node("Grid")
export var direction: int # In what direction does the arrow move the tiles
export var line_index: int # Which row/column does this arrow effect

func _ready():
	connect("pressed", self, "on_pressed")

func on_pressed():
	
	# TODO: Sync with other players!
	
	grid.move_tiles(direction, line_index)
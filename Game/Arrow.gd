extends TextureButton

onready var grid = get_parent().get_parent().get_parent().get_node("Board/Grid")
export var direction: int # In what direction does the arrow move the tiles
export var line_index: int # Which row/column does this arrow effect

func _ready():
	visible = false
	connect("pressed", self, "on_pressed")
	GameManager.connect("turn_updated", self, "check_phase")
	
func on_pressed():
	if GameManager.cur_phase == GameManager.TurnPhases.MoveMaze and GameManager.active_player_id == Network.STEAM_ID:
		Network.remote_sync_func(grid, "move_tiles", [direction, line_index])
		Network.remote_sync_func(self, "set_disabled_arrow")
		Network.remote_sync_func(GameManager, "next_phase")

func set_disabled_arrow():
	# Enable all arrows first
	for arrow in get_parent().get_children():
		if arrow.disabled: arrow.disabled = false
	
	# Then disable opposite arrow
	var opp_dir
	match direction:
		0: opp_dir = 2
		1: opp_dir = 3
		2: opp_dir = 0
		3: opp_dir = 1
	for arrow in get_parent().get_children():
		if arrow.direction == opp_dir and arrow.line_index == line_index:
			arrow.disabled = true

func check_phase():
	if GameManager.cur_phase == GameManager.TurnPhases.MoveMaze and GameManager.active_player_id == Network.STEAM_ID:
		visible = true
	elif GameManager.cur_phase == GameManager.TurnPhases.RotateTile and GameManager.active_player_id == Network.STEAM_ID and disabled:
		visible = true
	elif visible: visible = false

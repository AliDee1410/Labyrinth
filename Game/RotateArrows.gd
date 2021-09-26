extends Control

onready var action_tile = get_parent().get_parent().get_node("Board/ActionTile")

func _ready():
	visible = false
	$LeftArrow.connect("pressed", self, "on_left_pressed")
	$RightArrow.connect("pressed", self, "on_right_pressed")
	GameManager.connect("turn_updated", self, "check_phase")

func on_left_pressed():
	var rotation = action_tile.sprite.rotation_degrees
	rotation -= 90
	if rotation == -90: rotation = 270
	rpc("rotate_action_tile", rotation)

func on_right_pressed():
	var rotation = action_tile.sprite.rotation_degrees
	rotation += 90
	if rotation == 360: rotation = 0
	rpc("rotate_action_tile", rotation)

remotesync func rotate_action_tile(rotation):
	action_tile.sprite.rotation_degrees = rotation

func check_phase():
	if GameManager.cur_phase == GameManager.TurnPhases.RotateTile and GameManager.active_player_id == Network.my_player_id:
		visible = true
	elif visible: visible = false
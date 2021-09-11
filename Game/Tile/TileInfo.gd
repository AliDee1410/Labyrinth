extends Node2D

onready var tile = get_parent()

var enabled = false

func _process(delta):
	if enabled: global_position = get_global_mouse_position()

func toggle():
	visible = !visible
	enabled = !enabled

func update():
	pass
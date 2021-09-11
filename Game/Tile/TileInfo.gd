extends Node2D

# Node References
onready var tile = get_parent()
onready var container = $Container

# Fields
var enabled = false

func _process(delta):
	if enabled: global_position = get_global_mouse_position()

func show_info():
	container.frame = get_object_count() - 1
	visible = true
	enabled = true

func hide_info():
	visible = false
	enabled = false

func has_object() -> bool:
	if get_object_count() > 0: return true
	else: return false

func get_object_count() -> int:
	var count = 0
	for object in container.get_children():
		if object.texture != null: count += 1
	return count

func update():
	container.get_child(0).texture = tile.item_sprite.texture
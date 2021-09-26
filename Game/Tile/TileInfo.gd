extends Node2D

# Node References
onready var tile = get_parent()
onready var container = $Container

# Fields
var enabled = false
var objects = []

func _process(delta):
	if enabled: global_position = get_global_mouse_position()

func show_info():
	visible = true
	enabled = true

func hide_info():
	visible = false
	enabled = false

func has_object() -> bool:
	if objects.size() > 0: return true
	else: return false

func update_tile_info():
	objects.clear()
	for sprite in container.get_children():
		sprite.texture = null
		
	if tile.item: objects.append(tile.item[1])
	for player in tile.players.get_children(): objects.append(player.texture)
	for i in range(objects.size()):
		container.get_child(i).texture = objects[i]
		
	container.frame = objects.size() - 1
	if !has_object() and visible: hide_info()
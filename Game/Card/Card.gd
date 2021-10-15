extends Node2D

const textures = {
	"front": preload("res://Assets/Card-Front.png"),
	"back": preload("res://Assets/Card-Back.png")
}

onready var sprite = $Sprite
onready var item_sprite = $ItemSprite

var item = {}

func enable(item_info_in = {}):
	visible = true
	if item_info_in: item = ItemManager.ITEMS[item_info_in["item_index"]]
	update_card()

func disable():
	visible = false
	item = {}
	update_card()

func update_card():
	if item:
		sprite.texture = textures["front"]
		item_sprite.texture = item["texture"]
	else: sprite.texture = textures["back"]

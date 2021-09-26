extends TextureButton

const BUTTON_TEXTURES = {
	"Go": [
		preload("res://Assets/UI/Button-Go-Normal.png"),
		preload("res://Assets/UI/Button-Go-Pressed.png"),
		preload("res://Assets/UI/Button-Go-Hover.png")
		],
	"Done": [
		preload("res://Assets/UI/Button-Done-Normal.png"),
		preload("res://Assets/UI/Button-Done-Pressed.png"),
		preload("res://Assets/UI/Button-Done-Hover.png")
		],
	"Pass": [
		preload("res://Assets/UI/Button-Done-Normal.png"),
		preload("res://Assets/UI/Button-Done-Pressed.png"),
		preload("res://Assets/UI/Button-Done-Hover.png")
		]
}

func _ready():
	connect("pressed", self, "on_pressed")
	GameManager.connect("turn_updated", self, "update_button")

func on_pressed():
	GameManager.rpc("next_phase")

func update_button():
	if GameManager.active_player_id == Network.my_player_id:
		match GameManager.cur_phase:
			GameManager.TurnPhases.Start:
				texture_normal = BUTTON_TEXTURES["Go"][0]
				texture_pressed = BUTTON_TEXTURES["Go"][1]
				texture_hover = BUTTON_TEXTURES["Go"][2]
				visible = true
			GameManager.TurnPhases.RotateTile, GameManager.TurnPhases.MovePlayer:
				texture_normal = BUTTON_TEXTURES["Done"][0]
				texture_pressed = BUTTON_TEXTURES["Done"][1]
				texture_hover = BUTTON_TEXTURES["Done"][2]
				visible = true
			GameManager.TurnPhases.End:
				texture_normal = BUTTON_TEXTURES["Pass"][0]
				texture_pressed = BUTTON_TEXTURES["Pass"][1]
				texture_hover = BUTTON_TEXTURES["Pass"][2]
				visible = true
			GameManager.TurnPhases.MoveMaze, GameManager.TurnPhases.MazeMoving:
				visible = false
	else: visible = false
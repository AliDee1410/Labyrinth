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
		preload("res://Assets/UI/Button-Pass-Normal.png"),
		preload("res://Assets/UI/Button-Pass-Pressed.png"),
		preload("res://Assets/UI/Button-Pass-Hover.png")
		]
}

func _ready():
	connect("pressed", self, "on_pressed")
	GameManager.connect("turn_updated", self, "update_button")

func on_pressed():
	Network.remote_sync_func(GameManager, "next_phase")

func update_button():
	if GameManager.active_player_id == Network.STEAM_ID:
		match GameManager.cur_phase:
			GameManager.TurnPhases.RotateTile, GameManager.TurnPhases.MovePlayer:
				texture_normal = BUTTON_TEXTURES["Done"][0]
				texture_pressed = BUTTON_TEXTURES["Done"][1]
				texture_hover = BUTTON_TEXTURES["Done"][2]
				visible = true
			GameManager.TurnPhases.MoveMaze, GameManager.TurnPhases.MazeMoving, GameManager.TurnPhases.End:
				visible = false
	else: visible = false

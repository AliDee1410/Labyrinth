extends Control

func initialize():
	GameManager.connect("turn_updated", self, "update_label")
	if not get_tree().is_network_server():
		$Button.visible = false
	update_label()

func _on_Button_pressed():
	GameManager.rpc("next_step")

func update_label():
	var text = (str(GameManager.active_player_id) + ": ")
	match GameManager.cur_step:
		GameManager.TurnSteps.Start:
			text += "Start"
		GameManager.TurnSteps.RotateTile:
			text += "Rotate Tile"
		GameManager.TurnSteps.PlaceTile:
			text += "Place Tile"
		GameManager.TurnSteps.MovePlayer:
			text += "Move Player"
		GameManager.TurnSteps.End:
			text += "End"
	print(text)
	$Label.text = text

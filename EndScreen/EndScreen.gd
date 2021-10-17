extends Control

onready var winner = Steam.getFriendPersonaName(Network.WINNER)
onready var winner_label = $CenterContainer/VBoxContainer/WinnerLabel

func _ready():
	winner_label.text = "And the winner is " + winner + "!"
	
func _on_LeaveButton_pressed():
	Network.leave_lobby()
	get_tree().change_scene("res://Play Menu/PlayMenu.tscn")

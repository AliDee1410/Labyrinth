extends ColorRect

onready var resume_button = $CenterContainer/VBoxContainer/Buttons/ResumeButton
onready var leave_button = $CenterContainer/VBoxContainer/Buttons/LeaveButton
onready var quit_button = $CenterContainer/VBoxContainer/Buttons/QuitButton

func _ready():
	visible = false
	resume_button.disabled = false
	leave_button.disabled = false
	quit_button.disabled = false
	
func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			visible = true

func _on_ResumeButton_pressed():
	visible = false
	
func _on_LeaveButton_pressed():
	disable_buttons()
	Network.remote_func(GameManager, "remove_player", [Network.STEAM_ID])
	yield(Utils.create_timer(1), "timeout")
	Network.leave_lobby()
	get_tree().change_scene("res://Play Menu/PlayMenu.tscn")
	
func _on_QuitButton_pressed():
	disable_buttons()
	Network.remote_func(GameManager, "remove_player", [Network.STEAM_ID])
	yield(Utils.create_timer(1), "timeout")
	Network.leave_lobby()
	get_tree().quit()

func disable_buttons():
	resume_button.disabled = true
	leave_button.disabled = true
	quit_button.disabled = true

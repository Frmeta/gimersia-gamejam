extends Node2D


func _ready():
	
	AudioManager.play_music("res://audio/bgmMainMenu.mp3")
	GameManager.load_level()
	if GameManager.farthest_level <= 1:
		$CanvasLayer/VBoxContainer/Control4/ContinueButton.modulate = Color(1.0, 1.0, 1.0, 0.357)
		$CanvasLayer/VBoxContainer/Control4/ContinueButton.disabled = true

func _on_new_game_button_pressed():
	GameManager.new_game()


func _on_continue_button_pressed():
	GameManager.continue_game()

func _on_quit_button_pressed():
	get_tree().quit()

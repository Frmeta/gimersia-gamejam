extends Node2D


func _ready():
	
	AudioManager.play_music("res://audio/bgmMainMenu.mp3")



func _on_new_game_button_pressed():
	GameManager.new_game()


func _on_continue_button_pressed():
	GameManager.continue_game()

func _on_quit_button_pressed():
	get_tree().quit()

extends Node2D


func _ready():
	var scoreText = get_node_or_null("CanvasLayer/Score")
	if scoreText:
		scoreText.text = "Area Reached: " + str(GameManager.level)
	
	AudioManager.play_music("res://audio/bgmMainMenu.mp3")

func _on_play_button_pressed():
	GameManager.play()


func _on_play_button_2_pressed():
	get_tree().quit()

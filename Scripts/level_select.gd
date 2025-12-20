extends Node2D

@export var level_buttons : Array[TextureButton] = []

func _ready():
	for i in range(len(level_buttons)):
		level_buttons[i].connect("pressed", func () : level_button_clicked(i+1))
		if GameManager.farthest_level <= i:
			level_buttons[i].disabled = true
			level_buttons[i].modulate = Color(0.42, 0.42, 0.42, 1.0)
			
	# bg music
	AudioManager.play_music("res://audio/bgmMainMenu.mp3")

func level_button_clicked(level: int):
	GameManager.play_level(level)


func _on_back_button_pressed():
	GameManager.main_menu()

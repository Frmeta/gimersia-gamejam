extends Node2D



func _ready():
	$MapGenerator.generate_level()
	
func _process(_delta):
	if Input.is_key_pressed(KEY_R):
		get_tree().reload_current_scene()

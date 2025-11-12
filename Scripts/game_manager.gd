extends Node2D

var level = 1
var player_health = 4

var map_gen # will be set by MapGenerator
var cam_shake
	
func _process(_delta):
	#if Input.is_key_pressed(KEY_R):
		#get_tree().reload_current_scene()
	pass

func portal_reached():
	next_level()

func next_level():
	level += 1
	get_tree().change_scene_to_file.call_deferred("res://Scenes/level.tscn")
	
func play():
	player_health = 4
	level = 1
	get_tree().change_scene_to_file.call_deferred("res://Scenes/level.tscn")

func player_died():
	AudioManager.stop_music()
	await get_tree().create_timer(1.0).timeout
	AudioManager.play_sfx("res://audio/gameOver.mp3")
	get_tree().change_scene_to_file.call_deferred("res://Scenes/game_over.tscn")

func cam_shake_call():
	if cam_shake:
		GameManager.cam_shake.shake()

extends Node2D

var current_level = 1
var farthest_level = 1
var player_health = 4

var map_gen # will be set by MapGenerator
var cam_shake


var save_path = "user://game_save.dat"
	
func _process(_delta):
	if Input.is_key_pressed(KEY_R) and Input.is_key_pressed(KEY_E) and Input.is_key_pressed(KEY_D):
		#get_tree().reload_current_scene()
		farthest_level = 6
		print("cheat")
		save_level()
	pass
	
	

func new_game():
	current_level = 1
	farthest_level = 1
	save_level()
	get_tree().change_scene_to_file.call_deferred("res://Scenes/level_select.tscn")

func continue_game():
	load_level()
	get_tree().change_scene_to_file.call_deferred("res://Scenes/level_select.tscn")

func play_level(level_to_play:int): # called by buttons at level_select.tscn
	player_health = 4
	current_level = level_to_play
	get_tree().change_scene_to_file.call_deferred("res://Scenes/level.tscn")
	

func next_level():
	AudioManager.play_sfx("res://audio/nextLevel.mp3")
	current_level += 1
	farthest_level = max(current_level, farthest_level)
	save_level()
	if current_level == 7:
		get_tree().change_scene_to_file.call_deferred("res://Scenes/End.tscn")
	else:
		level_select()

func level_select():
	get_tree().change_scene_to_file.call_deferred("res://Scenes/level_select.tscn")
	
func boss_defeated():
	AudioManager.stop_music()
	await get_tree().create_timer(4).timeout
	next_level()
	
func player_died():
	AudioManager.stop_music()
	await get_tree().create_timer(1.5).timeout
	AudioManager.play_sfx("res://audio/gameOver.mp3")
	get_tree().change_scene_to_file.call_deferred("res://Scenes/game_over.tscn")

func cam_shake_call():
	if cam_shake:
		GameManager.cam_shake.shake()

func main_menu():
	get_tree().change_scene_to_file.call_deferred("res://Scenes/main_menu.tscn")

func save_level():
	var save_data = {
		"level": farthest_level
	}
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()
		
func load_level():
	# Loading
	var loaded_data = {}
	var file = FileAccess.open(save_path, FileAccess.READ)
	if file:
		loaded_data = file.get_var()
		file.close()
	farthest_level = loaded_data["level"]

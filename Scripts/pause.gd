extends Control


func _ready():
	visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = not get_tree().paused
		visible = get_tree().paused


func _on_resume_pressed():
	get_tree().paused = false
	visible = get_tree().paused


func _on_home_pressed():
	get_tree().paused = false
	GameManager.level_select()

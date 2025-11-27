extends Node2D

@export var random_rot = true
@export var delay_before_queue_free = 0.0

func _ready():
	$AnimatedSprite2D.play()
	if random_rot:
		rotation_degrees = randf_range(0, 360)


func _on_animated_sprite_2d_animation_finished():
	await get_tree().create_timer(delay_before_queue_free).timeout
	queue_free()

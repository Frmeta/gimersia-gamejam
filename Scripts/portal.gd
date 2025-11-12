extends Area2D


func _ready():
	$AnimatedSprite2D.play("idle")

func _on_body_entered(body):
	if body is Player:
		GameManager.next_level()
		AudioManager.play_sfx("res://audio/nextLevel.mp3")

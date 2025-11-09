extends Area2D

const SPEED = 500.0


func _physics_process(_delta):
	translate(transform.x * SPEED * _delta)

func _on_body_entered(_body):
	queue_free()

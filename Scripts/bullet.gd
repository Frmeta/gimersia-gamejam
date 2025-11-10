extends Area2D

const SPEED = 500.0
const DAMAGE = 1
const KNOCKBACK_POWER = 100

func _physics_process(_delta):
	translate(transform.x * SPEED * _delta)

func _on_body_entered(body):
	if body is Entity:
		body.take_damage(DAMAGE)
		var dir = body.global_position - global_position
		body.take_knockback(dir.normalized() * KNOCKBACK_POWER)
	queue_free()

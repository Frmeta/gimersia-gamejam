extends Area2D

@export var SPEED = 500.0
const DAMAGE = 1
const KNOCKBACK_POWER = 100

signal ready_singal

func _ready():
	ready_singal.emit()
	
func _physics_process(_delta):
	translate(transform.x * SPEED * _delta)

func _on_body_entered(body):
	if body is Entity:
		body.take_damage(DAMAGE)
		var dir = body.global_position - global_position
		body.take_knockback(dir.normalized() * KNOCKBACK_POWER)
	else:
		AudioManager.play_sfx("res://audio/bulletHitWall.wav")
	queue_free()

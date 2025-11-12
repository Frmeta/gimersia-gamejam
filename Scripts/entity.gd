extends CharacterBody2D

class_name Entity

@export var health := 1

# shader
@export var shader : ShaderMaterial
@export var sprites : Array[AnimatedSprite2D]
@export var tintInterval := 0.05
var tintTimer := 0.0


var stun_duration := 0.2
var stun_timer := 0.0

@export var explosion : PackedScene

func _ready():
	#shader = shader.duplicate(true)
	shader = sprites[0].material.duplicate(true)
	for sprite in sprites:
		sprite.material = shader

func _process(delta):
	# tint when take damage
	shader.set_shader_parameter("is_tinted", 1 if tintTimer > 0 else 0)
	tintTimer -= delta

	stun_timer -= delta
	
	#if shader.get_shader_parameter("is_tinted") == 1:
		#print("tint")

func take_damage(damage):
	# sfx
	if self is Player:
		AudioManager.play_sfx("res://audio/playerHit.wav")
	else:
		AudioManager.play_sfx("res://audio/enemyHit.wav")
	
	health -= damage
	tintTimer = tintInterval
	if health <= 0:
		death()
		
func take_knockback(dir : Vector2):
	stun_timer = stun_duration
	velocity = dir
	
func death():
	GameManager.cam_shake_call()
	
	# spawn explosion
	var instantiated_explosion : GPUParticles2D = explosion.instantiate()
	get_tree().current_scene.add_child.call_deferred(instantiated_explosion)
	instantiated_explosion.position = global_position
	instantiated_explosion.emitting = true
	
	queue_free()
	

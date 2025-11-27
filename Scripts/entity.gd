extends CharacterBody2D

class_name Entity

@export var health := 1

# shader
#@export var shader : ShaderMaterial
var shader : ShaderMaterial = preload("res://Shaders/solid.tres")
@export var sprites : Array[AnimatedSprite2D]
var tintInterval := 0.05
var tintTimer := 0.0


var stun_duration := 0.2
var stun_timer := 0.0

@export var explosion : PackedScene

func _enter_tree():
	#shader = shader.duplicate(true)
	shader.set_shader_parameter("is_tinted", 1)
	for sprite in sprites:
		sprite.material = shader

func _ready():
	pass

func _process(delta):
	# tint when take damage
	
	for sprite in sprites:
		sprite.material = shader if tintTimer > 0 else null
		
	#shader.set_shader_parameter("is_tinted", 1 if tintTimer > 0 else 0)
	tintTimer -= delta

	stun_timer -= delta
	
	#if shader.get_shader_parameter("is_tinted") == 1:
		#print("tint")
	
	
	velocity = velocity.clampf(-500, 500)

func take_damage(damage, knockback_dir : Vector2 = Vector2.ZERO):
	# sfx
	if self is Player:
		AudioManager.play_sfx("res://audio/playerHit.wav")
	else:
		AudioManager.play_sfx("res://audio/enemyHit.wav")
	
	health -= damage
	tintTimer = tintInterval
	
	
	stun_timer = stun_duration
	velocity += knockback_dir
	
	
	if health <= 0:
		death()
	
func death():
	GameManager.cam_shake_call()
	
	# spawn explosion
	var instantiated_explosion = explosion.instantiate()
	get_tree().current_scene.add_child.call_deferred(instantiated_explosion)
	instantiated_explosion.position = global_position
	#instantiated_explosion.emitting = true
	
	queue_free()
	

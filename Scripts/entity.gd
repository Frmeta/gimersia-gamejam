extends CharacterBody2D

class_name Entity

@export var health := 1


@export var shader : ShaderMaterial
@export var tintInterval := 0.2
var tintTimer := 0.0



@export var stun_duration = 0.2
var stun_timer := 0.0

func _process(delta):
	# tint when take damage
	tintTimer -= delta
	shader.set_shader_parameter("is_tinted", 1 if tintTimer > 0 else 0)
	if name == "Player" and tintTimer > 0:
		print("putih")
	elif tintTimer > 0:
		print("p")
	stun_timer -= delta

func take_damage(damage):
	health -= damage
	tintTimer = tintInterval
	print(name + " health: " + str(health))
	if health < 0:
		death()
		
func take_knockback(dir : Vector2):
	stun_timer = stun_duration
	velocity = dir
	
func death():
	pass

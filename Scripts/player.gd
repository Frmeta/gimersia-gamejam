extends Entity

class_name Player

@export var healthbar: TextureRect

# --- Variables ---
@export var speed: float = 300.0
@export var jump_velocity: float = -400.0

@export var jump_cut_multiplier: float = 0.5
@export var jump_count: int = 2
var current_jump_count = 2

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var bullet : PackedScene
@export var shootInterval : float = 0.15
var shootTimer : float

@export var parentSprite : Node2D
@export var bodySprite : AnimatedSprite2D
@export var gunSprite : AnimatedSprite2D
@export var gunSpritePivot : Node2D
@export var gunEndpoint : Node2D



var is_gun_facing_right = true
var is_shooting = true
var direction: float = 0

var gunPivotOriginalPos : Vector2 = Vector2.ZERO
var gunKnockback: float = 1

var coyote_jump_duration = 0.2
var coyote_jump_timer = 0.0

var is_prev_on_floor = false


@export var jump_smoke : PackedScene


func _ready():
	#super()._ready()
	gunPivotOriginalPos = gunSpritePivot.position;
	
	health = GameManager.player_health
	healthbar.set_value(health)

func _physics_process(delta: float):
	
	coyote_jump_timer -= delta
	
	# --- Gravity ---
	if not is_on_floor():
		velocity.y += gravity * delta
		is_prev_on_floor = false
	else:
		coyote_jump_timer = coyote_jump_duration
		if not is_prev_on_floor:
			is_prev_on_floor = true
			AudioManager.play_sfx("res://audio/playerLand.wav")
			
	
	if stun_timer < 0:
		# --- Jumping ---
		if Input.is_action_just_pressed("jump") and coyote_jump_timer > 0:
			current_jump_count = 1
			jump()
		elif Input.is_action_just_pressed("jump") and current_jump_count < jump_count:
			current_jump_count += 1
			jump()

		# --- Variable Jump Height ---
		if Input.is_action_just_released("jump") and velocity.y < 0.0:
			velocity.y *= jump_cut_multiplier

		# --- Horizontal Movement ---
		direction = Input.get_axis("left", "right")

		# Apply movement based on the direction.
		if direction:
			# If there is input, set the velocity directly.
			velocity.x = move_toward(velocity.x, direction * speed, speed)
		else:
			# If there is no input, decelerate smoothly.
			velocity.x = move_toward(velocity.x, 0, speed)

	# --- Apply Movement ---
	move_and_slide()
	

func _process(delta):
	super._process(delta)
	var mouse_pos = get_global_mouse_position()
	var diff = mouse_pos - position
	
	
	if cos(diff.angle()) > 0: # pointing right
		is_gun_facing_right = true
		parentSprite.scale.x = 1
		gunSpritePivot.rotation = diff.angle()
	else:
		is_gun_facing_right = false
		parentSprite.scale.x = -1
		gunSpritePivot.rotation =  PI-diff.angle()
		
		
	# shooting
	shootTimer -= delta
	if Input.is_action_pressed("shoot"):
		is_shooting = true
	else:
		is_shooting = false
		
	if Input.is_action_pressed("shoot") and shootTimer < 0:
		shootTimer = shootInterval
		
		AudioManager.play_sfx("res://audio/playerShoot.wav", 1.0, 0.5)
		
		# player pushed back
		#velocity = -diff.normalized() * 200
		#velocity = Vector2(clampf(velocity.x, -400, 400), clampf(velocity.y, -400, 400))
		#move_and_slide()
		
		# spawn bullet
		var instantiated_bullet = bullet.instantiate()
		get_tree().current_scene.add_child.call_deferred(instantiated_bullet)
		instantiated_bullet.position = gunEndpoint.global_position
		instantiated_bullet.rotation = diff.angle()
	
	if shootTimer > shootInterval/2:
		gunSpritePivot.position = gunPivotOriginalPos - diff.normalized() * gunKnockback
	else:
		gunSpritePivot.position = gunPivotOriginalPos
	
	
	# animation
	if direction:
		if direction > 0 == is_gun_facing_right:
			bodySprite.play("run") # run forward
		else:
			bodySprite.play_backwards("run") # run inverse
	elif is_shooting:
		bodySprite.play("shoot") # shooting
	else:
		bodySprite.play("idle") # idle
		

func jump():
	AudioManager.play_sfx("res://audio/playerJump.wav")
	velocity.y = jump_velocity
	
	# spawn jump smoke
	var a = jump_smoke.instantiate()
	get_tree().current_scene.add_child.call_deferred(a)
	a.position = global_position + Vector2.DOWN * 12
		
		
		
func take_damage(damage):
	super(damage)
	
	GameManager.player_health = health
	healthbar.set_value(health)
	
	GameManager.cam_shake_call()



func death():
	super()
	GameManager.cam_shake_call()
	AudioManager.play_sfx("res://audio/playerDied.wav")
	GameManager.player_died()

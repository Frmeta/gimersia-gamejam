extends CharacterBody2D

# --- Variables ---
@export var speed: float = 300.0
@export var jump_velocity: float = -400.0

@export var jump_cut_multiplier: float = 0.5
@export var jump_count: int = 2
var current_jump_count = 2

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var bullet : PackedScene
@export var shootInterval : float = 0.1
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

func _ready():
	gunPivotOriginalPos = gunSpritePivot.position;

func _physics_process(delta: float):
	# --- Gravity ---
	if not is_on_floor():
		velocity.y += gravity * delta

	# --- Jumping ---
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		current_jump_count = 1
	elif Input.is_action_just_pressed("jump") and current_jump_count < jump_count:
		velocity.y = jump_velocity
		current_jump_count -= 1

	# --- Variable Jump Height ---
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= jump_cut_multiplier

	# --- Horizontal Movement ---
	direction = Input.get_axis("left", "right")

	# Apply movement based on the direction.
	if direction:
		# If there is input, set the velocity directly.
		velocity.x = direction * speed
	else:
		# If there is no input, decelerate smoothly.
		velocity.x = move_toward(velocity.x, 0, speed)

	# --- Apply Movement ---
	move_and_slide()
	

func _process(delta):
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
		
		# player pushed back
		#velocity = -diff.normalized() * 200
		#velocity = Vector2(clampf(velocity.x, -400, 400), clampf(velocity.y, -400, 400))
		#move_and_slide()
		
		# spawn bullet
		var instantiated_bullet = bullet.instantiate()
		get_tree().root.add_child(instantiated_bullet)
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
		

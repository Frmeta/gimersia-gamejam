extends Entity

enum State {
	WALK, PREPARE_TO_JUMP, JUMP
}

const SPEED = 30.0
const DAMAGE = 1
const KNOCKBACK_POWER = 200

@onready var groundChecker : Area2D = $AnimatedSprite2D/groundChecker
@onready var wallChecker : Area2D = $AnimatedSprite2D/wallChecker
@onready var playerChecker : Area2D = $AnimatedSprite2D/playerchecker

var is_moving_right = true

var checkInterval = 0.2
var checkTimer = 0

var jump_power = Vector2(200, -250)
var jump_interval = 5.0
var jump_timer = 8.0

var state = State.WALK

#func _ready():
	#super()._ready()


func _physics_process(delta):
	
	# animation
	match state:
		State.WALK:
			$AnimatedSprite2D.play("walk")
		State.PREPARE_TO_JUMP:
			$AnimatedSprite2D.stop()
		State.JUMP:
			$AnimatedSprite2D.play("jump")
		
	
	jump_timer -= delta
	
	if state == State.JUMP and is_on_floor():
		state = State.WALK
	
	# jump to player
	if state == State.WALK and jump_timer < 0 and is_on_floor() and not playerChecker.get_overlapping_bodies().is_empty():

		jump_timer = jump_interval
		state = State.PREPARE_TO_JUMP
		
		await get_tree().create_timer(1.0).timeout
		
		AudioManager.play_sfx("res://audio/enemyMeleeJump.wav")
		state = State.JUMP
		velocity = Vector2(jump_power.x * $AnimatedSprite2D.scale.x, jump_power.y)
	

	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	checkTimer -= delta
	if is_on_floor() and groundChecker.get_overlapping_bodies().is_empty() && checkTimer < 0:
		is_moving_right = !is_moving_right
		checkTimer = checkInterval
	
	if is_on_floor() and !wallChecker.get_overlapping_bodies().is_empty() && checkTimer < 0:
		is_moving_right = !is_moving_right
		checkTimer = checkInterval
	
	if state == State.WALK:
		if is_moving_right:
			velocity.x = move_toward(velocity.x, SPEED, 2*SPEED)
			$AnimatedSprite2D.scale.x = 1
		else:
			velocity.x = move_toward(velocity.x, -SPEED, 2*SPEED)
			$AnimatedSprite2D.scale.x = -1
	elif state == State.PREPARE_TO_JUMP:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		#velocity.x = jump_power.x * $AnimatedSprite2D.scale.x # to maintain velocity
		pass
		
	move_and_slide()

func death():
	super()
	AudioManager.play_sfx("res://audio/enemyDied.wav")

func _on_atk_area_body_entered(body):
	# attack player when touched
	if body is Player:
		body.take_damage(DAMAGE)
		var dir = (body.global_position - global_position) + Vector2.UP * 10
		body.take_knockback(dir.normalized() * KNOCKBACK_POWER)

extends Entity



const SPEED = 30.0
const DAMAGE = 1
const KNOCKBACK_POWER = 200

@onready var groundChecker : Area2D = $AnimatedSprite2D/groundChecker
@onready var wallChecker : Area2D = $AnimatedSprite2D/wallChecker

var is_moving_right = true

var checkInterval = 0.2
var checkTimer = 0;


func _ready():
	$AnimatedSprite2D.play("walk")

func _physics_process(delta):
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
	
	if is_moving_right:
		velocity.x = move_toward(velocity.x, SPEED, 2*SPEED)
		$AnimatedSprite2D.scale.x = 1
	else:
		velocity.x = move_toward(velocity.x, -SPEED, 2*SPEED)
		$AnimatedSprite2D.scale.x = -1
		
	move_and_slide()

func death():
	queue_free()

func _on_atk_area_body_entered(body):
	if body is Player:
		body.take_damage(DAMAGE)
		var dir = (body.global_position - global_position) + Vector2.UP * 10
		body.take_knockback(dir.normalized() * KNOCKBACK_POWER)

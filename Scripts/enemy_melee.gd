extends CharacterBody2D


const SPEED = 30.0

@onready var groundChecker : Area2D = $AnimatedSprite2D/groundChecker

var is_moving_right = true

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	
	if is_moving_right:
		velocity.x = SPEED
	else:
		velocity.x = -SPEED
		
	$AnimatedSprite2D.scale.x = 1 if is_moving_right else -1
	if groundChecker.get_overlapping_bodies().size() == 0:
		print("ho")
		$AnimatedSprite2D.scale.x = -1 if is_moving_right else 1
		if groundChecker.get_overlapping_bodies().size() > 0:
			is_moving_right = !is_moving_right
			print("swap")
		else:
			$AnimatedSprite2D.scale.x = 1 if is_moving_right else -1
			
	

	move_and_slide()

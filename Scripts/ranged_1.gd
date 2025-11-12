extends Entity


const SPEED = 50.0
const DAMAGE = 1
const KNOCKBACK_POWER = 200

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


var target_position: Vector2 = Vector2.ZERO

@export var bullet : PackedScene

@export var shootInterval : float = 3
var shootTimer : float = 5

func _ready():
	#super()._ready()
	animated_sprite.play("idle")
	
	# Set the CharacterBody2D's velocity to be processed by the NavigationAgent2D
	# This is a key step for Godot's built-in path following.
	# The agent will call the 'velocity_computed' function when it has calculated a safe velocity.
	navigation_agent.velocity_computed.connect(_on_velocity_computed)

	# Wait for the NavigationServer to initialize the map
	await get_tree().physics_frame

	# Set an initial target (replace this with your actual target node's position)
	# For a simple test, just set it to a point on the map.

# --- Main Movement Loop ---
func _physics_process(_delta):
	
	# The agent is only allowed to calculate a velocity if it has a target
	if navigation_agent.is_navigation_finished():
		return

	# 1. Get the next point on the calculated path
	var next_path_point: Vector2 = navigation_agent.get_next_path_position()

	# 2. Calculate the desired direction towards that point
	var direction: Vector2 = global_position.direction_to(next_path_point)

	# 3. Calculate the desired velocity
	var desired_velocity: Vector2 = direction * SPEED

	# 4. Feed the desired velocity back to the NavigationAgent2D
	# The agent will process this, apply steering, and avoid other agents/obstacles.
	navigation_agent.set_velocity(desired_velocity)

# --- NavigationAgent Callback ---
# This function is called by the NavigationAgent2D with the final, safe velocity.
func _on_velocity_computed(safe_velocity: Vector2):
	velocity = safe_velocity
	move_and_slide()

# --- Public Function to Set New Target ---
func set_target_position(new_target: Vector2):
	target_position = new_target

	# Crucially, tell the NavigationAgent2D to calculate a new path
	navigation_agent.target_position = target_position

func _process(delta):
	super(delta)
	
	# shooting
	shootTimer -= delta
	
	
	if get_tree().get_first_node_in_group("player") != null:
		var player_pos = get_tree().get_first_node_in_group("player").global_position
		if player_pos.distance_to(global_position) < 100:
			set_target_position(player_pos)
			if shootTimer < 0:
				shootTimer = shootInterval
				
				
				# spawn bullet
				var instantiated_bullet = bullet.instantiate()
				get_tree().current_scene.add_child.call_deferred(instantiated_bullet)
				instantiated_bullet.position = global_position
				
				var diff = target_position - global_position
				instantiated_bullet.rotation = diff.angle()


func _on_atk_area_body_entered(body):
	# attack player when touched
	if body is Player:
		body.take_damage(DAMAGE)
		var dir = (body.global_position - global_position) + Vector2.UP * 10
		body.take_knockback(dir.normalized() * KNOCKBACK_POWER)

func death():
	super()
	AudioManager.play_sfx("res://audio/enemyDied.wav")
	queue_free()

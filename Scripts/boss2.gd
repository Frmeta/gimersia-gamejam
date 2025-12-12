extends Entity

enum State {
	IDLE, WALK, DASH, JUMP, ATK
}

var jump_power = Vector2(800, -400)
var dash_power = Vector2(200, 0)
var atk_power = Vector2(120, 0)
var walk_speed = 100.0

@export var bullet : PackedScene

@onready var bossHealthBar = get_tree().get_first_node_in_group("boss_healthbar")


const DAMAGE = 1
const KNOCKBACK_POWER = 300


var jump_cooldown = 5.0
var dash_cooldown = 5.0
var atk_cooldown = 0.5

var dash_cooldown_timer = 0.0
var atk_cooldown_timer = 4.0
var jump_timer = 5.0


var slowdown_acc = 050

var player
var player_position


var state = State.IDLE

func _ready():
	bossHealthBar.min_value = 0.0
	bossHealthBar.max_value = health
	bossHealthBar.value = health
	bossHealthBar.visible = true
	
	
	state = State.WALK

func _physics_process(delta):
	
	dash_cooldown_timer -= delta
	atk_cooldown_timer -= delta
	jump_timer -= delta
	
	# atk player
	var bodies = $atkArea.get_overlapping_bodies()
	for body in bodies:
		if body is Player:
			var dir = (body.global_position - global_position) + Vector2.UP * 10
			body.take_damage(DAMAGE, dir.normalized() * KNOCKBACK_POWER)
	
	player = get_tree().get_first_node_in_group("player")
	if player:
		player_position = player.global_position
		
		
	# animation
	#match state:
		#State.IDLE:
			#$AnimatedSprite2D.play("idle")
		#State.WALK:
			#$AnimatedSprite2D.play("walk")
		#State.ATK:
			#$AnimatedSprite2D.play("atk")
		#State.DASH:
			#$AnimatedSprite2D.play("dash")
		#State.JUMP:
			#$AnimatedSprite2D.play("jump")
	
	if state == State.DASH or state == State.ATK:
		# atk player
		var bodiess = $AnimatedSprite2D/atkSensor.get_overlapping_bodies()
		for body in bodiess:
			if body is Player:
				var dir = (body.global_position - global_position) + Vector2.UP * 10
				body.take_damage(DAMAGE, dir.normalized() * KNOCKBACK_POWER)
			
	
	# flip_h
	if player:
		if player.global_position.x > global_position.x:
			# hadap kanan
			$AnimatedSprite2D.scale.x = 1
			#velocity.x = max(velocity.x, 0)
		else:
			$AnimatedSprite2D.scale.x = -1
			#velocity.x = min(velocity.x, 0)
	
	if state == State.WALK:
		# move to player
		velocity.x = move_toward(velocity.x, walk_speed * $AnimatedSprite2D.scale.x, walk_speed * 2 * delta)
		if not $AnimatedSprite2D/atkSensor.get_overlapping_bodies().is_empty() && atk_cooldown_timer < 0:
			atk_cooldown_timer = atk_cooldown
			atk()
		elif not $AnimatedSprite2D/dashSensor.get_overlapping_bodies().is_empty() && dash_cooldown_timer < 0:
			dash_cooldown_timer = dash_cooldown
			dash()
		elif jump_timer < 0:
			jump_timer = jump_cooldown + randf_range(0, jump_cooldown)
			jump()
	else:
		velocity.x = move_toward(velocity.x, 0, slowdown_acc * delta)
			
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	move_and_slide()
	
func dash():
	state = State.DASH
	GameManager.cam_shake_call()
	AudioManager.play_sfx("res://audio/bossDash.wav")
	global_position.x += $AnimatedSprite2D.scale.x * 20
	velocity = Vector2(dash_power.x * $AnimatedSprite2D.scale.x, dash_power.y)
	$AnimatedSprite2D.play("dash")
	await $AnimatedSprite2D.animation_finished
	
	state = State.WALK
	$AnimatedSprite2D.play("walk")
	

func atk():
	state = State.ATK
	GameManager.cam_shake_call()
	AudioManager.play_sfx("res://audio/boss2slice.wav")
	velocity = Vector2(atk_power.x * $AnimatedSprite2D.scale.x, atk_power.y)
	$AnimatedSprite2D.play("atk")
	await $AnimatedSprite2D.animation_finished
	$AnimatedSprite2D.play("walk")
	state = State.WALK


func jump():
	state = State.JUMP
	GameManager.cam_shake_call()
	velocity = Vector2(jump_power.x * $AnimatedSprite2D.scale.x, jump_power.y)
	global_position.y -= 0.2
	AudioManager.play_sfx("res://audio/enemyMeleeJump.wav")
	$AnimatedSprite2D.play("jump")
	
	#for i in range(2):
	if get_tree() != null:
		await get_tree().physics_frame
	while not is_on_floor():
		if is_inside_tree() and get_tree() != null:
			await get_tree().physics_frame # Await the next physics frame
	
	
	AudioManager.play_sfx("res://audio/bossLand.wav")
	GameManager.cam_shake_call()
	
	$AnimatedSprite2D.play("walk")
	state = State.WALK

func take_damage(damage, _knockback_dir : Vector2 = Vector2.ZERO):
	super(damage, Vector2.ZERO)
	bossHealthBar.value = health
	

func death():
	bossHealthBar.visible = false
	super()
	AudioManager.play_sfx("res://audio/enemyDied.wav")
	GameManager.boss_defeated()

#func _on_atk_area_body_entered(body):
	## attack player when touched
	#if body is Player:
		#var dir = (body.global_position - global_position) + Vector2.UP * 10
		#body.take_damage(DAMAGE, dir.normalized() * KNOCKBACK_POWER)

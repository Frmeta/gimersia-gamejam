extends Entity

enum State {
	IDLE, DASH, JUMP, SHOOT
}

var jump_power = Vector2(300, -300)
var dash_power = Vector2(300, 0)

@export var bullet : PackedScene

@onready var bossHealthBar = get_tree().get_first_node_in_group("boss_healthbar")


const DAMAGE = 1
const KNOCKBACK_POWER = 300

var idle_interval_min = 1.0
var idle_interval_max = 3.0
var shoot_interval = 0.1
var shoot_count = 3
var shoot_batch = 1

var slowdown_acc = 300

var player_position


var state = State.IDLE

func _ready():
	bossHealthBar.min_value = 0.0
	bossHealthBar.max_value = health
	bossHealthBar.value = health
	bossHealthBar.visible = true
	
	
	idle()

func _physics_process(delta):
	
	# animation
	match state:
		State.IDLE:
			$AnimatedSprite2D.play("idle")
		State.DASH:
			$AnimatedSprite2D.play("idle")
		State.JUMP:
			$AnimatedSprite2D.play("jump")
		State.SHOOT:
			$AnimatedSprite2D.play("shoot")
	
	
	velocity.x = move_toward(velocity.x, 0, slowdown_acc * delta)
			
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	move_and_slide()
	
	# atk player
	var bodies = $atkArea.get_overlapping_bodies()
	for body in bodies:
		if body is Player:
			var dir = (body.global_position - global_position) + Vector2.UP * 10
			body.take_damage(DAMAGE, dir.normalized() * KNOCKBACK_POWER)
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player_position = player.global_position

func idle():
	state = State.IDLE
	await get_tree().create_timer(randf_range(idle_interval_min, idle_interval_max)).timeout
	
	# flip_h
	var player = get_tree().get_first_node_in_group("player")
	if player:
		if player.global_position.x > global_position.x:
			# hadap kanan
			$AnimatedSprite2D.scale.x = 1
		else:
			$AnimatedSprite2D.scale.x = -1
	
	if randi_range(0, 1) == 0:
		shoot()
	
	var a = randi_range(0, 1)
	match a:
		0:
			print("dash")
			dash()
		1:
			jump()
			print("jump")

func dash():
	state = State.DASH
	GameManager.cam_shake_call()
	AudioManager.play_sfx("res://audio/bossDash.wav")
	velocity = Vector2(dash_power.x * $AnimatedSprite2D.scale.x, dash_power.y)
	await get_tree().create_timer(2).timeout
	idle()
	

func shoot():
	state = State.SHOOT
	
	for i in range(shoot_batch):
		for j in range(shoot_count):
			# spawn bullet
			if player_position:
				var instantiated_bullet = bullet.instantiate()
				get_tree().current_scene.add_child.call_deferred(instantiated_bullet)
				instantiated_bullet.position = global_position
				
				var diff = player_position - global_position
				instantiated_bullet.rotation = diff.angle()
	
	
			await get_tree().create_timer(shoot_interval).timeout
		await get_tree().create_timer(shoot_interval*3).timeout
	
	#idle()

func jump():
	state = State.JUMP
	GameManager.cam_shake_call()
	velocity = Vector2(jump_power.x * $AnimatedSprite2D.scale.x, jump_power.y)
	global_position.y -= 0.2
	AudioManager.play_sfx("res://audio/enemyMeleeJump.wav")
	
	#for i in range(2):
		#await get_tree().physics_frame
	while not is_on_floor():
		await get_tree().physics_frame # Await the next physics frame
	
	
	AudioManager.play_sfx("res://audio/bossLand.wav")
	GameManager.cam_shake_call()
	idle()

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

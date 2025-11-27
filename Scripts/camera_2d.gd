# CameraFollow_TimeBased.gd (Attached to Camera2D node)
extends Camera2D

# Export variables for easy tuning
@export var target_node: Node2D # Drag your Player node here
@export var smooth_speed: float = 5.0 # Higher values mean faster, more aggressive follow

# Use _physics_process for smoother camera movement if your player movement is in _physics_process
func _physics_process(delta: float) -> void:
	if not target_node:
		return

	# 1. Define the desired position
	var target_position = target_node.global_position + Vector2.UP * 16
	
	# 2. Calculate the distance left to travel
	var distance_vector = target_position - global_position
	
	# 3. Calculate the interpolation factor based on delta time
	#    The formula 1.0 - exp(-speed * delta) ensures frame-rate independence.
	#    The camera moves most of the remaining distance at the start (fast "growth")
	#    and slows down exponentially as it approaches the target.
	var interpolation_factor = 1.0 - exp(-smooth_speed * delta)
	
	# 4. Apply the interpolation
	position += distance_vector * interpolation_factor

# NOTE: If your player movement uses _process(delta), you should move the
# camera logic to the _process(delta) function instead.


extends Node2D

# --- CONFIGURATION ---
@export var max_offset: Vector2 = Vector2(50.0, 50.0) # Max shake in pixels (X, Y)
@export var max_rotation: float = deg_to_rad(5.0) # Max shake rotation in radians
@export var default_decay: float = 8.0 # Speed at which the shake intensity fades (Higher = faster fade)

# --- PRIVATE VARIABLES ---
var _shake_power: float = 0.0 # Current intensity (0.0 to 1.0)
var _shake_duration: float = 0.0 # Time the shake should last
var _shake_decay: float = 0.0 # Decay rate for the current shake
var _is_shaking: bool = false
var _time_elapsed: float = 0.0

var offset

func _ready():
	GameManager.cam_shake = self

# --- SHAKE FUNCTION ---

## Starts the camera shake effect.
## 'intensity': How strong the shake should be (0.0 to 1.0).
## 'duration': How long the shake should theoretically last before decaying.
## 'decay_rate': How fast the intensity should drop (optional, uses default_decay if 0).
func shake(intensity: float = 0.3, duration: float = 0.5, decay_rate: float = 0.0) -> void:
	# Use the max intensity, but clamp it
	_shake_power = clampf(intensity, 0.0, 1.0)
	_shake_duration = duration
	_shake_decay = decay_rate if decay_rate > 0.0 else default_decay
	_time_elapsed = 0.0
	_is_shaking = true

	# Ensure the camera processes frames to run the shake loop
	set_process(true)


# --- CORE LOGIC: THE EXPONENTIAL DECAY ---

func _process(delta: float) -> void:
	if not _is_shaking:
		return

	_time_elapsed += delta
	
	# 1. Decay the Intensity (The "Growth/Easing Out" Effect)
	# The exponential decay formula: P(t) = P0 * exp(-k * t)
	# This factor smoothly reduces the initial power over time.
	var decay_factor: float = exp(-_shake_decay * _time_elapsed)
	
	# Check if the effect is complete
	if _time_elapsed >= _shake_duration or decay_factor < 0.01:
		_is_shaking = false
		offset = Vector2.ZERO
		rotation = 0.0
		set_process(false) # Stop processing to save performance
		return

	# 2. Calculate final shake influence
	var current_power = _shake_power * decay_factor
	
	# 3. Apply random, decaying offset and rotation
	# 'randf_range(-1.0, 1.0)' ensures random movement in all directions
	offset = Vector2(
		randf_range(-max_offset.x, max_offset.x) * current_power,
		randf_range(-max_offset.y, max_offset.y) * current_power
	)
	rotation = randf_range(-max_rotation, max_rotation) * current_power

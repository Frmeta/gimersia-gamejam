extends Camera2D

# --- Debug Camera Controls ---
#
# HOW TO USE:
# 1. Attach this script to your Camera2D node.
# 2. Make sure the Camera2D has "Enabled" checked (it's "current").
#
# CONTROLS:
# - Move: Arrow Keys or WASD (uses Godot's built-in "ui_up", "ui_down", "ui_left", "ui_right" actions).
# - Pan: Hold the Middle Mouse Button and drag.
# - Zoom:
#   - Use the Mouse Wheel to zoom in and out.
#   - (Optional) Use keyboard keys. To do this:
#     1. Go to Project > Project Settings > Input Map.
#     2. Add a new action named "debug_zoom_in".
#     3. Add a new action named "debug_zoom_out".
#     4. Assign keys to them, e.g., Plus(+) for zoom in, Minus(-) for zoom out.
#
# -----------------------------

@export_group("Movement")
@export var move_speed: float = 400.0

@export_group("Zoom")
@export var enable_mouse_zoom: bool = true
@export var enable_key_zoom: bool = true
# Multiplicative factor for mouse wheel zoom. 1.1 = 10% zoom per tick.
@export var zoom_mouse_factor: float = 1.1
# Additive units per second for keyboard zoom.
@export var zoom_key_speed: float = 0.5
@export var min_zoom: float = 0.1
@export var max_zoom: float = 5.0

@export_group("Pannning")
@export var enable_mouse_pan: bool = true

var is_panning: bool = false


func _unhandled_input(event: InputEvent) -> void:
	
	# --- Mouse Panning (Hold Middle Mouse Button) ---
	if enable_mouse_pan:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_MIDDLE:
				is_panning = event.is_pressed()
				# Consume the event so clicking/dragging the middle mouse
				# button doesn't trigger other game logic (like shooting).
				if is_panning:
					get_viewport().set_input_as_handled()

		if event is InputEventMouseMotion and is_panning:
			# We divide by zoom so the panning speed feels consistent
			# whether zoomed in or out.
			position -= event.relative / zoom
			get_viewport().set_input_as_handled()

	# --- Mouse Wheel Zoom ---
	if enable_mouse_zoom:
		if event is InputEventMouseButton and event.is_pressed():
			var zoom_factor = 1.0
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_factor = zoom_mouse_factor # Zoom out
				get_viewport().set_input_as_handled()
				
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_factor = 1.0 / zoom_mouse_factor # Zoom in
				get_viewport().set_input_as_handled()

			if zoom_factor != 1.0:
				set_zoom_level(zoom * zoom_factor)


func _process(delta: float) -> void:
	
	# --- Keyboard Movement (WASD / Arrow Keys) ---
	# Gets a normalized vector from the four "ui_" input actions.
	var move_direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if move_direction != Vector2.ZERO:
		position += move_direction * move_speed * delta


# Helper function to apply and clamp the zoom level.
func set_zoom_level(new_zoom: Vector2) -> void:
	zoom.x = clampf(new_zoom.x, min_zoom, max_zoom)
	zoom.y = clampf(new_zoom.y, min_zoom, max_zoom)

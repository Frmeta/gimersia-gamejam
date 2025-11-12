extends Node2D

@export var up_corners : Node2D
@export var down_corners : Node2D
@export var left_wall : Node2D
@export var right_wall : Node2D
@export var down_wall : Node2D
@export var up_wall : Node2D
@export var interior_hole_up : Node2D
@export var interior_wall_up : Node2D

var up_corners_t : Array[TileMapLayer]
var down_corners_t : Array[TileMapLayer]
var left_wall_t : Array[TileMapLayer]
var right_wall_t : Array[TileMapLayer]
var down_wall_t : Array[TileMapLayer]
var up_wall_t : Array[TileMapLayer]
var interior_hole_up_t : Array[TileMapLayer]
var interior_wall_up_t : Array[TileMapLayer]

@export var door_t : TileMapLayer

func _ready():
	up_corners_t = get_children_of_type(up_corners)
	down_corners_t = get_children_of_type(down_corners)
	left_wall_t = get_children_of_type(left_wall)
	right_wall_t = get_children_of_type(right_wall)
	down_wall_t = get_children_of_type(down_wall)
	up_wall_t = get_children_of_type(up_wall)
	interior_hole_up_t = get_children_of_type(interior_hole_up)
	interior_wall_up_t = get_children_of_type(interior_wall_up)
	
	position = Vector2(100000, 100000) # supaya ga ganggu map

func generate_room(wall_dirs : Array[MapGenerator.Direction], is_door : bool = false):
	var output := []
	
	output.append_array(up_corners_t.pick_random().get_used_cells())
	output.append_array(down_corners_t.pick_random().get_used_cells())
	
	var wall_up_exists = false
	
	for wall_dir in wall_dirs:
		if wall_dir == MapGenerator.Direction.LEFT:
			output.append_array(left_wall_t.pick_random().get_used_cells())
		if wall_dir == MapGenerator.Direction.RIGHT:
			output.append_array(right_wall_t.pick_random().get_used_cells())
		if wall_dir == MapGenerator.Direction.DOWN:
			output.append_array(down_wall_t.pick_random().get_used_cells())
		if wall_dir == MapGenerator.Direction.UP:
			output.append_array(up_wall_t.pick_random().get_used_cells())
			wall_up_exists = true
	
	
	if is_door:
		output.append_array(door_t.get_used_cells())
	elif not wall_up_exists:
		output.append_array(interior_hole_up_t.pick_random().get_used_cells())
	elif randf() < 1: # TODO: set it to like 0.8 or something
		output.append_array(interior_wall_up_t.pick_random().get_used_cells())
	
		
	return output
	
func get_children_of_type(parent_node: Node) -> Array[TileMapLayer]:
	var children_of_type : Array[TileMapLayer] = []
	for child in parent_node.get_children():
		if child is TileMapLayer:
			children_of_type.append(child)
	return children_of_type

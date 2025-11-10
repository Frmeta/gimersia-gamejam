extends Node2D
class_name MapGenerator

@export var tileMapLayer : TileMapLayer

enum Direction {
	NONE, UP, RIGHT, DOWN, LEFT
}

	
func generate_level():
	
	var room_count := 15
	
	var room_cells := [] # list of list [cell, [directions to previous (can be none at 0,0)]
	var new_rooms := [] # list of list [cell, direction to previous (not none)]
	
	room_cells.append([Vector2i(0, 0), []])
	#new_rooms.append([Vector2i(0, -1), Direction.DOWN])
	new_rooms.append([Vector2i(1, 0), Direction.LEFT])
	#new_rooms.append([Vector2i(0, 1), Direction.UP])
	new_rooms.append([Vector2i(-1, 0), Direction.RIGHT])
	
	
	while room_cells.size() < room_count:
		var a = randi_range(0, new_rooms.size()-1)
		var b = new_rooms[a]
		new_rooms.remove_at(a)
		
		# if it has been explored
		if room_cells.any(func (x): return x[0] == b[0]):
			continue
		
		# if it hasn't been explored
		
		# add to room_cells
		room_cells.append([b[0], [b[1]]])
		
		# update previous
		if b[1] == Direction.DOWN:
			room_cells[room_cells.find_custom(func (x): return x[0] == (b[0] + Vector2i(0, 1)))][1].append(Direction.UP)
		elif b[1] == Direction.LEFT:
			room_cells[room_cells.find_custom(func (x): return x[0] == (b[0] + Vector2i(-1, 0)))][1].append(Direction.RIGHT)
		elif b[1] == Direction.UP:
			room_cells[room_cells.find_custom(func (x): return x[0] == (b[0] + Vector2i(0, -1)))][1].append(Direction.DOWN)
		elif b[1] == Direction.RIGHT:
			room_cells[room_cells.find_custom(func (x): return x[0] == (b[0] + Vector2i(1, 0)))][1].append(Direction.LEFT)
		
		# unlock new rooms
		new_rooms.append([b[0] + Vector2i(0, -1), Direction.DOWN])
		new_rooms.append([b[0] + Vector2i(1, 0), Direction.LEFT])
		new_rooms.append([b[0] + Vector2i(0, 1), Direction.UP])
		new_rooms.append([b[0] + Vector2i(-1, 0), Direction.RIGHT])
	
	var room_size = 14
	
	var cells := []
	var create_room = func(x): # x = [v2i cell pos, list of hole directions]
		var starting_point = Vector2i(x[0][0] * room_size, x[0][1] * room_size) # bottom left
		
		# corner
		#cells.append(starting_point)
		#cells.append(starting_point + Vector2i(room_size-1, 0))
		#cells.append(starting_point + Vector2i(0, room_size-1))
		#cells.append(starting_point + Vector2i(room_size-1, room_size-1))
		
		# simple wall
		var walls : Array[Direction] = [Direction.UP, Direction.DOWN, Direction.RIGHT, Direction.LEFT]
		for dir in x[1]:
			walls.erase(dir)
		
		#for wall in walls:
			#if wall == Direction.UP:
				#for i in range(room_size):
					#cells.append(starting_point + Vector2i(i, 0))
			#elif wall == Direction.DOWN:
				#for i in range(room_size):
					#cells.append(starting_point + Vector2i(i, room_size-1))
			#elif wall == Direction.LEFT:
				#for i in range(room_size):
					#cells.append(starting_point + Vector2i(0, i))
			#elif wall == Direction.RIGHT:
				#for i in range(room_size):
					#cells.append(starting_point + Vector2i(room_size-1, i))
		
		var tmp = MapPatternManager.generate_map(walls)
		for t in tmp:
			cells.append(starting_point+t)
	
	var fill_room = func(x):
		if room_cells.any(func(a) : return a[0] == x):
			return
		var starting_point = Vector2i(x[0] * room_size, x[1] * room_size) # bottom left
		for i in range(room_size):
			for j in range(room_size):
				cells.append(starting_point + Vector2i(i, j))
		
	var border_cells := []
	for room_cell in room_cells:
		create_room.call(room_cell)
		for i in range(3):
			for j in range(3):
				border_cells.append(room_cell[0] + Vector2i(i-1, j-1))
	
	for border_cell in border_cells:
		fill_room.call(border_cell)
		
		
			
	tileMapLayer.set_cells_terrain_connect(cells, 0, 0, false)

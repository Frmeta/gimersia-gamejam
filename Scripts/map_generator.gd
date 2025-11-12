extends Node2D
class_name MapGenerator

@export var tileMapLayer : TileMapLayer
@export var portal_scene : PackedScene

@export var navigation_region : NavigationRegion2D

@export var enemy_melee : PackedScene
@export var enemy_ranged_1 : PackedScene

@export var area_label : Label

enum Direction {
	NONE, UP, RIGHT, DOWN, LEFT
}


var melee_count = 0
var ranged_count = 0
		
func _ready():
	AudioManager.play_music("res://audio/bgmLevel.mp3", 0.7)
	AudioManager.play_sfx("res://audio/areaStart.wav")
	
	area_label.text = "AREA " + str(GameManager.level)
	
	generate_level(GameManager.level)


func generate_level(level : int):
	
	var room_count := 5 + (level-1) * 2
	const room_size = 14
	var enemy_per_room_min = clampi(int(level/2-1), 0, 10)
	var enemy_per_room_max = clampi(level*1, 0, 10)
	
	# generate snake-like maze
	
	var room_cells := [] # list of list [cell, [directions to previous (can be none at 0,0), manhattan dist to player]
	var new_rooms := [] # list of list [cell, direction to previous (not none), manhattan dist to player]

	
	room_cells.append([Vector2i(0, 0), [], 0])
	#new_rooms.append([Vector2i(0, -1), Direction.DOWN])
	new_rooms.append([Vector2i(1, 0), Direction.LEFT, 1])
	#new_rooms.append([Vector2i(0, 1), Direction.UP])
	new_rooms.append([Vector2i(-1, 0), Direction.RIGHT, 1])
	
	while room_cells.size() < room_count:
		var a = randi_range(0, new_rooms.size()-1)
		var b = new_rooms[a]
		new_rooms.remove_at(a)
		
		# if it has been explored
		if room_cells.any(func (x): return x[0] == b[0]):
			continue
		
		# if it hasn't been explored
		
		# add to room_cells
		room_cells.append([b[0], [b[1]], b[2]])
		
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
		new_rooms.append([b[0] + Vector2i(0, -1), Direction.DOWN, b[2]+1])
		new_rooms.append([b[0] + Vector2i(1, 0), Direction.LEFT, b[2]+1])
		new_rooms.append([b[0] + Vector2i(0, 1), Direction.UP, b[2]+1])
		new_rooms.append([b[0] + Vector2i(-1, 0), Direction.RIGHT, b[2]+1])
	
	# find furthest room (manhattan distance)
	var furthest_room : Vector2i = Vector2i.ZERO
	var furthest_dist = 0
	for room_cell in room_cells:
		if room_cell[2] > furthest_dist:
			furthest_dist = room_cell[2]
			furthest_room = room_cell[0]
	
	
	var cells := []
	
	# Helper function
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
		
		var room = MapPatternManager.generate_room(walls, x[0] == furthest_room)
		
		if x[0] == furthest_room:
			print("furthest room: "+ str(furthest_room))
			
			# spawn portal
			var portal = portal_scene.instantiate()
			get_tree().current_scene.add_child.call_deferred(portal)
			portal.global_position = tileMapLayer.map_to_local(starting_point) + Vector2.ONE * room_size*16/2
			
		for r in room:
			cells.append(starting_point + r)
		
		# convolve tmp from (0, room_size) x (0, room_size) until match 3x3 kernel
		const melee_kernel := [[true, true], [false, false]]
		const ranged_kernel := [[false, false], [false, false]]
		
		var melee_poses := []
		var ranged_poses := []
		
		if x[0] != Vector2i(0,0):
			for i in range(room_size-1):
				for j in range(room_size-1):
					
					var cell = starting_point + Vector2i(i, j)
					var is_melee := true
					
					for ii in range(2):
						for jj in range(2):
							if melee_kernel[ii][jj] == (room.find(Vector2i(i+ii, j+jj)) == -1):
								is_melee = false
								break
					if is_melee:
						melee_poses.append(tileMapLayer.map_to_local(cell) + Vector2.ONE*16/2)
					
					
					var is_ranged := true
					for ii in range(2):
						for jj in range(2):
							if ranged_kernel[ii][jj] == (room.find(Vector2i(i+ii, j+jj)) == -1):
								is_ranged = false
								break
					if is_ranged:
						ranged_poses.append(tileMapLayer.map_to_local(cell) + Vector2.ONE*16/2)
		
		#print("melee: " + str(melee_poses.size()) + ", ranged: " + str(ranged_poses.size()))
		
		# Instantiate enemies
		melee_count = 0
		ranged_count = 0
		
		var instantiate_melee = func():
			var a = enemy_melee.instantiate()
			get_tree().current_scene.add_child.call_deferred(a)
			
			var idx = randi_range(0, melee_poses.size()-1)
			a.position = melee_poses[idx]
			melee_poses.remove_at(idx)
			melee_count += 1
		
		var instantiate_ranged = func():
			var a = enemy_ranged_1.instantiate()
			get_tree().current_scene.add_child.call_deferred(a)
			
			var idx = randi_range(0, ranged_poses.size()-1)
			a.position = ranged_poses[idx]
			ranged_poses.remove_at(idx)
			ranged_count += 1
			
		var enemy_count = randi_range(enemy_per_room_min, enemy_per_room_max)
		for i in enemy_count:
			if melee_poses.is_empty():
				if ranged_poses.is_empty():
					break
				else:
					instantiate_ranged.call()
			else:
				if ranged_poses.is_empty():
					instantiate_melee.call()
				else:
					if randf() < 0.5:
						instantiate_ranged.call()
					else:
						instantiate_melee.call()
			
		# print(str(melee_count) + " melee, " + str(ranged_count) + " ranged")
	
	# helper function
	var fill_room = func(x):
		if room_cells.any(func(a) : return a[0] == x):
			return
		var starting_point = Vector2i(x[0] * room_size, x[1] * room_size) # bottom left
		for i in range(room_size):
			for j in range(room_size):
				cells.append(starting_point + Vector2i(i, j))
	
	# call helper functions for room & border
	var border_cells := []
	for room_cell in room_cells:
		create_room.call(room_cell)
		for i in range(3):
			for j in range(3):
				border_cells.append(room_cell[0] + Vector2i(i-1, j-1))
	
	for border_cell in border_cells:
		fill_room.call(border_cell)
	
	if (level-1) % 4 < 2:
		tileMapLayer.set_cells_terrain_connect(cells, 0, 0, false)
	else:
		tileMapLayer.set_cells_terrain_connect(cells, 0, 1, false)
		
	
	# update navigation area
	navigation_region.bake_updated_navmesh()
	

extends NavigationRegion2D







# This function is what you should call from the node that changes the TileMap
func bake_updated_navmesh():
	# Deferring the bake is safest, as it waits until the TileMap is fully processed
	# (i.e., finished changing the collision data) before baking.
	call_deferred("_perform_bake")

func _perform_bake():
	# This method is what re-runs the entire baking process, reading the TileMap's
	# updated collision data and carving the navmesh accordingly.
	# It takes the navigation polygon resource as an argument.
	bake_navigation_polygon()
	
	# Check for success (optional, but good practice)
	if get_navigation_polygon() == null:
		# NOTE: Check the Output panel for any NavigationServer errors!
		print("ERROR: Failed to bake NavigationPolygon. Check source geometry settings.")

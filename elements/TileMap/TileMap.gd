extends TileMap


var astar = AStarGrid2D.new()
var map_rect = Rect2i()


func _ready():
	var tile_size = get_tileset().tile_size
	var tilemap_size = get_used_rect().end - get_used_rect().position
	map_rect = Rect2i(Vector2i(), tilemap_size)
	# Установим настройки A*
	astar.region = map_rect
	astar.cell_size = tile_size
	astar.offset = tile_size * 0.5
	astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()
	
	for i in tilemap_size.x:
		for j in tilemap_size.y:
			var coordinates = Vector2i(i, j)
			var tile_data = get_cell_tile_data(0, coordinates)
			if tile_data and tile_data.get_custom_data('type') != "floor":
				astar.set_point_solid(coordinates)

func is_local_point_walkable(local_position):
	var map_position = local_to_map(local_position)
	if map_rect.has_point(map_position):
		return not astar.is_point_solid(map_position)
	return false

func is_map_point_walkable(map_position):
	if map_rect.has_point(map_position):
		return not astar.is_point_solid(map_position)
	return false
	
# Возвращает массив всех соседних точек в определенном радиусе
func get_points_in_radius(point: Vector2, radius: int) -> PackedVector2Array:
	var points = PackedVector2Array()
	var tile_map_cell = local_to_map(point)
	var opened_cells = Dictionary()
	var cells_to_open = [tile_map_cell]
	for i in range(radius):
		var new_candidates = Array()
		for open_candidate_i in range(cells_to_open.size()):
			var cell_to_open = cells_to_open.pop_back()
			var tile_data = get_cell_tile_data(0, cell_to_open)
			if (tile_data and tile_data.get_custom_data('type') != "floor") or \
			opened_cells.has(cell_to_open) or !is_map_point_walkable(cell_to_open):
				continue
			var neighbour_cells = [
				Vector2(cell_to_open.x - 1, cell_to_open.y),
				Vector2(cell_to_open.x, cell_to_open.y - 1),
				Vector2(cell_to_open.x + 1, cell_to_open.y),
				Vector2(cell_to_open.x, cell_to_open.y + 1)
			]
			new_candidates.append_array(neighbour_cells)
			opened_cells[cell_to_open] = true
			points.append(Vector2i(map_to_local(cell_to_open)))
		cells_to_open = new_candidates
	return points
	

func check_point_in_area(points: PackedVector2Array, pos: Vector2) -> bool:
	for point in points:
		if local_to_map(pos) == local_to_map(point):
			return true
	return false
	

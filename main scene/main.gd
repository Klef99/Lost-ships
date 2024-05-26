extends Node2D

@onready var tilemap = $TileMap
@onready var player = $Player
var move_area_container: Node2D
var is_pressed: bool


func _input(event):
	if event is InputEventMouseButton and event.button_mask == 1:
		var click_position = get_global_mouse_position()
		if tilemap.is_local_point_walkable(click_position):
			if !player.is_moving() and tilemap.local_to_map(click_position) == tilemap.local_to_map(player.global_position):
				clear_moving_area(player.get_avaliable_points())
				is_pressed = !is_pressed
				if is_pressed:
					draw_moving_area(player.get_avaliable_points())
				return
			if is_pressed and tilemap.check_point_in_area(player.get_avaliable_points(), click_position):
				is_pressed = false
				
				#var points = round(Vector2(tilemap.local_to_map(player.global_position))\
				#.distance_to(Vector2(tilemap.local_to_map(click_position))))
				#player.change_point(-points)
				
				player.current_path = tilemap.astar.get_id_path(
					tilemap.local_to_map(player.global_position),
					tilemap.local_to_map(click_position)
			).slice(1)
				#tilemap.get_node("Enemies").get_node("Unit").move_to(click_position+Vector2(5, 5))
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create(player.global_position, click_position)
		var result = space_state.intersect_ray(query)
		print(result)
		if not is_pressed:
			clear_moving_area(player.get_avaliable_points())


# TODO: При отрисовки меняется тайл пола
func draw_moving_area(points):
	for coord in points:
		tilemap.set_cell(-1, tilemap.local_to_map(coord), 0, Vector2i(6,3), 1)
		
func clear_moving_area(points):
	for coord in points:
		tilemap.set_cell(-1, tilemap.local_to_map(coord), -1)

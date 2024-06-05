extends Node2D

@onready var tilemap = $TileMap
@onready var player = $Player
var move_area_container: Node2D
var is_pressed: bool




func _input(event):
	if event is InputEventMouseButton:
		var space_state = get_world_2d().direct_space_state
		# use global coordinates, not local to node
		#var query = PhysicsRayQueryParameters2D.create(player.global_position, event.global_position)
		#var result = space_state.intersect_ray(query)
		#print(result)
		player.attack_enemy()

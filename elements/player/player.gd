extends CharacterBody2D
class_name Player

signal left_clicked

@export var access_door_level = 0
@export var move_points = 2
@export var SPEED = 1
var target_pos: Vector2
@onready var animation = $AnimatedSprite2D
@onready var tilemap = $"../TileMap"

var current_path: Array[Vector2i]
var avaliable_points: PackedVector2Array

# TODO: Починить движение в отрицательных координатах.
# TODO: Починить движение при высокой скорости (> 1).
func _moving():
	if current_path.is_empty():
		animation.play("idle")
		return
	var target_position = tilemap.map_to_local(current_path.front())
	velocity = position.direction_to(target_position) * SPEED
	animation.flip_h = velocity.x < 0
	animation.play("run")
	move_and_collide(velocity)
	if position == target_position or position.distance_to(target_position) < 1:
		current_path.pop_front()

func _physics_process(delta):
	update_avaliable_points()
	_moving()

func _ready():
	position = tilemap.map_to_local(tilemap.local_to_map(position))

func _handle_input_event(viewport: SubViewport, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("left_clicked")

func change_point(amount: int):
	move_points += amount

func update_avaliable_points():
	avaliable_points = tilemap.get_points_in_radius(position, move_points+1)

func get_avaliable_points():
	return avaliable_points
	
func is_moving():
	return !current_path.is_empty()

extends CharacterBody2D


const SPEED = 1
var current_path: Array[Vector2i]
@export var HP = 100
@onready var animation = $AnimatedSprite2D
@onready var tilemap = get_parent().get_parent()
@onready var hpbar = $HealthBar

func _ready():
	position = tilemap.map_to_local(tilemap.local_to_map(position)) # центрируем юнит в тайле
	await get_parent().get_parent().ready
	set_current_pos_solid(true)
	hpbar.value = HP

func _moving():
	if current_path.is_empty():
		animation.play("idle")
		return
	set_current_pos_solid(false)
	var target_position = tilemap.map_to_local(current_path.front())
	velocity = position.direction_to(target_position) * SPEED
	animation.flip_h = velocity.x < 0
	animation.play("run")
	move_and_collide(velocity)
	if position == target_position or position.distance_to(target_position) < 1:
		set_current_pos_solid(true)
		current_path.pop_front()

func move_to(point):
	current_path = tilemap.astar.get_id_path(
						tilemap.local_to_map(global_position),
						tilemap.local_to_map(point)
				).slice(1)

func _physics_process(delta):
	_moving()


func set_current_pos_solid(isSolid):
	var pos_tilemap = tilemap.local_to_map(position)
	var pos_2 = pos_tilemap + Vector2i(0, -1)
	tilemap.astar.set_point_solid(pos_tilemap, isSolid)
	#tilemap.astar.set_point_solid(pos_2)

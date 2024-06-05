extends CharacterBody2D


@export var SPEED = 0.8
@export var HP = 100
@onready var animation = $AnimatedSprite2D
@onready var tilemap = get_parent().get_parent()
@onready var hpbar = $HealthBar
var player: Player
var player_chase = null
signal take_damage(value)



func _ready():
	position = tilemap.map_to_local(tilemap.local_to_map(position)) # центрируем юнит в тайле
	#await get_parent().get_parent().ready
	hpbar.max_value = HP
	update_hpbar()

func _moving():
	if player_chase:
		velocity = position.direction_to(player.position) * SPEED
	else:
		velocity = Vector2(0,0)
	if velocity == Vector2(0,0):
		animation.play("idle")
		return
	animation.flip_h = velocity.x < 0
	animation.play("run")
	move_and_collide(velocity)


func _physics_process(delta):
	_moving()
		
func update_hpbar():
	hpbar.value = HP


func _on_detection_area_body_entered(body):
	if body.get_script().resource_path.get_file() == "player.gd":
		player = body
		player_chase = true


func _on_detection_area_body_exited(body):
	if body.get_script().resource_path.get_file() == "player.gd":
		player = null
		player_chase = false


func _on_take_damage(value):
	HP -= value
	update_hpbar()
	if HP <= 0:
		queue_free()

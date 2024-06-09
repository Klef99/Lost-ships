extends CharacterBody2D


@export var SPEED = 0.8
@export var HP = 100
@onready var animation = $AnimatedSprite2D
@onready var tilemap = get_parent().find_child("TileMap")
@onready var hpbar = $HealthBar
@onready var player = get_tree().get_first_node_in_group("player")


var knockback = Vector2.ZERO
@export var knockback_recovery = 3.5


func _ready():
	#position = tilemap.map_to_local(tilemap.local_to_map(position)) # центрируем юнит в тайле
	#await get_parent().get_parent().ready
	hpbar.max_value = HP
	update_hpbar()

func _moving():
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
	velocity = position.direction_to(player.position) * SPEED
	velocity += knockback
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


func get_damage(value):
	HP -= value
	update_hpbar()
	if HP <= 0:
		queue_free()

extends CharacterBody2D
class_name Player

signal left_clicked

@export var access_door_level = 0
@export var SPEED = 1.2
@onready var animation = $AnimatedSprite2D
@onready var tilemap = $"../TileMap"
@onready var hpbar = Hud.get_node("CanvasLayer").get_node("HPbar")
@export var HP = 100

var enemy_in_range = false
var enemies = Array()
var attack_cooldown = false


func _physics_process(delta):
	get_input()
	_moving()

func _ready():
	position = tilemap.map_to_local(tilemap.local_to_map(position))
	update_hpbar()
	Hud.get_node("CanvasLayer").visible = true

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * SPEED


# TODO: Починить движение в отрицательных координатах.
# TODO: Починить движение при высокой скорости (> 1).
func _moving():
	if velocity == Vector2(0, 0):
		animation.play("idle")
		return
	animation.flip_h = velocity.x < 0
	animation.play("run")
	move_and_collide(velocity)


func _on_hitbox_body_entered(body):
	print(body)
	if body.has_method("attack_player"):
		enemy_in_range = true
		enemies.append(body)


func _on_hitbox_body_exited(body):
	if body.has_method("attack_player"):
		for i in len(enemies):
			if enemies[i] == body:
				enemies.pop_at(i)
		enemy_in_range = len(enemies) != 0
		
func attack_enemy():
	if enemy_in_range and not attack_cooldown:
		for i in range(len(enemies)):
			enemies[i].take_damage.emit(50)
			print(enemies[i], "take 50 dmg")
			attack_cooldown = true
			$"attack cooldown".start()
		
func _on_attack_cooldown_timeout():
	attack_cooldown = false
	
func get_damage(val):
	HP -= val
	update_hpbar()
	if HP <= 0:
		death()
	
func update_hpbar():
	hpbar.value = HP

func death():
	Hud.get_node("CanvasLayer").visible = false
	Hud.get_node("GameUI")._on_level_lost()
	queue_free()

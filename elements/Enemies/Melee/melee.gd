extends CharacterBody2D



@onready var animation = $AnimatedSprite2D
@onready var tilemap = get_parent().find_child("TileMap")
@onready var hpbar = $HealthBar
@onready var snd_hit = $snd_hit
@onready var player = get_tree().get_first_node_in_group("player")
@onready var loot_base = get_tree().get_first_node_in_group("loot")

# Preloads
var death_anim = preload("res://elements/Enemies/ExplosionAnim/explosion.tscn")
var exp_gem = preload("res://elements/Items/ExperienceGem/experience_gem.tscn")


var knockback = Vector2.ZERO

@export var SPEED = 30
@export var HP = 20
@export var knockback_recovery = 3.5
@export var dmg = 5
@export var experience = 4

signal remove_from_array(object)

func _ready():
	hpbar.max_value = HP
	update_hpbar()

func _moving(delta):
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
	velocity = position.direction_to(player.position) * SPEED
	velocity += knockback
	if velocity == Vector2(0,0):
		animation.play("idle")
		return
	move_and_collide(velocity * delta)
	animation.flip_h = velocity.x < 0
	animation.play("run")


func _physics_process(delta):
	_moving(delta)
		
func update_hpbar():
	hpbar.value = HP

func death():
	emit_signal("remove_from_array",self)
	var enemy_death = death_anim.instantiate()
	enemy_death.scale = animation.scale
	enemy_death.global_position = global_position
	get_parent().call_deferred("add_child",enemy_death)
	var new_gem = exp_gem.instantiate()
	new_gem.global_position = global_position
	new_gem.experience = experience
	loot_base.call_deferred("add_child",new_gem)
	queue_free()

func get_damage(value):
	HP -= value
	update_hpbar()
	if HP <= 0:
		death()
	else:
		snd_hit.play()

func _on_hurtbox_hurt(damage, angle, knockback_amount):
	knockback = angle * knockback_amount
	get_damage(damage)

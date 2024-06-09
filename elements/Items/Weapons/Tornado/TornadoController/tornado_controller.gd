extends Node2D


@onready var player = get_tree().get_first_node_in_group("player")
@onready var enemies = player.enemy_close

@onready var tornado = preload("res://elements/Items/Weapons/Tornado/Tornado.tscn")
@onready var tornadoTimer = $TornadoTimer
@onready var tornadoAttackTimer = $TornadoTimer/TornadoAttackTimer

@export var tornado_ammo = 0
@export var tornado_baseammo = 0
@export var tornado_attackspeed = 3
@export var tornado_level = 0


func _ready():
	enemies = player.enemy_close
	attack()


func attack():
	if tornado_level > 0:
		tornadoTimer.wait_time = tornado_attackspeed * (1-player.spell_cooldown)
		#tornadoTimer.wait_time = tornado_attackspeed
		if tornadoTimer.is_stopped():
			tornadoTimer.start()
			
func get_random_target():
	if enemies.size() > 0:
		return enemies.pick_random().global_position
	else:
		return Vector2.UP

func get_enemies(enemies_list):
	enemies = enemies_list

func _on_tornado_timer_timeout():
	tornado_ammo += tornado_baseammo + player.additional_attacks
	tornadoAttackTimer.start()

func _on_tornado_attack_timer_timeout():
	if tornado_ammo > 0:
		var tornado_attack = tornado.instantiate()
		tornado_attack.position = position
		tornado_attack.last_movement = player.last_movement
		tornado_attack.level = tornado_level
		add_child(tornado_attack)
		tornado_ammo -= 1
		if tornado_ammo > 0:
			tornadoAttackTimer.start()
		else:
			tornadoAttackTimer.stop()

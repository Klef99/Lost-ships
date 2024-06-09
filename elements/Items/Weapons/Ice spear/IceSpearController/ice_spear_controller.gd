extends Node2D


@onready var player = get_tree().get_first_node_in_group("player")
@onready var enemies = player.enemy_close

@onready var iceSpear = preload("res://elements/Items/Weapons/Ice spear/ice_spear.tscn")
@onready var iceSpearTimer = $IceSpearTimer
@onready var iceSpearAttackTimer = $IceSpearTimer/IceSpearAttackTimer

@export var icespear_ammo = 0
@export var icespear_baseammo = 1
@export var icespear_attackspeed = 1.5
@export var icespear_level = 1
@export var onEnemy = false


func _ready():
	enemies = player.enemy_close
	attack()

func _on_ice_spear_timer_timeout():
	icespear_ammo += icespear_baseammo + player.additional_attacks
	iceSpearAttackTimer.start()

func _on_ice_spear_attack_timer_timeout():
	if icespear_ammo > 0:
		var icespear_attack = iceSpear.instantiate()
		icespear_attack.position = player.position
		icespear_attack.target = get_random_target()
		if onEnemy:
			icespear_attack.position = get_parent().global_position + Vector2(16,16) * get_parent().position.direction_to(player.global_position)
			icespear_attack.target = player.global_position
		icespear_attack.level = icespear_level
		add_child(icespear_attack)
		icespear_ammo -= 1
		if icespear_ammo > 0:
			iceSpearAttackTimer.start()
		else:
			iceSpearAttackTimer.stop()


func attack():
	if icespear_level > 0:
		iceSpearTimer.wait_time = icespear_attackspeed * (1-player.spell_cooldown)
		#iceSpearTimer.wait_time = icespear_attackspeed
		if iceSpearTimer.is_stopped():
			iceSpearTimer.start()
			
func get_random_target():
	if enemies.size() > 0:
		return enemies.pick_random().global_position
	else:
		return Vector2.UP

func get_enemies(enemies_list):
	enemies = enemies_list

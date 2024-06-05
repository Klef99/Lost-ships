extends "res://elements/Unit/unit.gd"

var player_in_attack_range = false
var attack_cooldown = false
var before_attack_cooldown = false
@export var dmg = 10

func _process(delta):
	if player != null:
		attack_player()

func attack_player():
	if player_in_attack_range and not attack_cooldown and not before_attack_cooldown:
		player.get_damage(dmg)
		attack_cooldown = true
		$attack_cooldown.start()
	if not before_attack_cooldown: # настроить грамматную работу кд
			before_attack_cooldown = true
			$before_attack_cooldown.start()


func _on_hitbox_body_entered(body):
	if body.get_script().resource_path.get_file() == "player.gd":
		player = body
		player_chase = false
		player_in_attack_range = true


func _on_hitbox_body_exited(body):
	if body.get_script().resource_path.get_file() == "player.gd":
		player = body
		player_chase = true
		player_in_attack_range = true


func _on_attack_cooldown_timeout():
	attack_cooldown = false


func _on_before_attack_cooldown_timeout():
	before_attack_cooldown = false

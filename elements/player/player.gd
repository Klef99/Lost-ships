extends CharacterBody2D
class_name Player

signal left_clicked

@export var access_door_level = 0
@export var SPEED = 50
@onready var animation = $AnimatedSprite2D
@onready var tilemap = $"../TileMap"
#HUD
@onready var hpbar = Hud.get_node("CanvasLayer").get_node("HPbar")
@onready var expBar = Hud.get_node("CanvasLayer").get_node("EXPbar")
@onready var lblLevel = Hud.get_node("CanvasLayer").get_node("lbl_level")

@export var HP = 100
@export var maxHP = 100

var last_movement = Vector2.ZERO
var time = 0
#Развитие
var experience = 0
var experience_level = 1
var collected_experience = 0


#UPGRADES
var collected_upgrades = []
var upgrade_options = []
var armor = 0
var speed = 0
var spell_cooldown = 0
var spell_size = 0
var additional_attacks = 0

#Атаки
## Ледяное копьё
@onready var iceSpear = $"Attack/IceSpearController"
## Торнадо
@onready var tornado = $Attack/TornadoController


#Ближайшие враги
var enemy_close = []



func _physics_process(delta):
	get_input()
	_moving(delta)

func _ready():
	position = tilemap.map_to_local(tilemap.local_to_map(position))
	Hud.update_hpbar(HP, maxHP)
	Hud.get_node("CanvasLayer").visible = true
	Hud.player = self
	Hud.adjust_gui_collection("icespear1")
	collected_upgrades.append("icespear1")
	#Hud.levelup()

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	last_movement = input_direction
	velocity = input_direction * SPEED

func _moving(delta):
	if velocity == Vector2(0, 0):
		animation.play("idle")
		return
	animation.flip_h = velocity.x < 0
	animation.play("run")
	move_and_collide(velocity * delta)

func get_damage(val):
	HP -= clamp(val-armor, 1.0, 999.0)
	Hud.update_hpbar(HP, maxHP)
	if HP <= 0:
		death()

func death():
	Hud.get_node("CanvasLayer").visible = false
	Hud.get_node("GameUI")._on_level_lost()
	queue_free()

func _on_hurtbox_hurt(damage, angle, knockback):
	get_damage(damage)

func get_random_target():
	if enemy_close.size() > 0:
		return enemy_close.pick_random().global_position
	else:
		return Vector2.UP

func _on_detection_area_body_entered(body):
	if not enemy_close.has(body):
		enemy_close.append(body)

func _on_detection_area_body_exited(body):
	if enemy_close.has(body):
		enemy_close.erase(body)

func _on_grab_area_area_entered(area):
	if area.is_in_group("loot"):
		area.target = self

func _on_collect_area_area_entered(area):
	if area.is_in_group("loot"):
		var gem_exp = area.collect()
		calculate_experience(gem_exp)

func calculate_experience(gem_exp):
	var exp_required = calculate_experiencecap()
	collected_experience += gem_exp
	if experience + collected_experience >= exp_required: #level up
		collected_experience -= exp_required-experience
		experience_level += 1
		experience = 0
		exp_required = calculate_experiencecap()
		Hud.levelup()
	else:
		experience += collected_experience
		collected_experience = 0
	
	Hud.set_expbar(experience, exp_required)

func calculate_experiencecap():
	var exp_cap = experience_level
	if experience_level < 20:
		exp_cap = experience_level*5
	elif experience_level < 40:
		exp_cap + 95 * (experience_level-19)*8
	else:
		exp_cap = 255 + (experience_level-39)*12
		
	return exp_cap

func upgrade_character(upgrade: String):
	match upgrade:
		"icespear1":
			iceSpear.icespear_level = 1
			iceSpear.icespear_baseammo += 1
		"icespear2":
			iceSpear.icespear_level = 2
			iceSpear.icespear_baseammo += 1
		"icespear3":
			iceSpear.icespear_level = 3
		"icespear4":
			iceSpear.icespear_level = 4
			iceSpear.icespear_baseammo += 2
		"tornado1":
			tornado.tornado_level = 1
			tornado.tornado_baseammo += 1
		"tornado2":
			tornado.tornado_level = 2
			tornado.tornado_baseammo += 1
		"tornado3":
			tornado.tornado_level = 3
			tornado.tornado_attackspeed -= 0.5
		"tornado4":
			tornado.tornado_level = 4
			tornado.tornado_baseammo += 1
		"armor1","armor2","armor3","armor4":
			armor += 1
		"speed1","speed2","speed3","speed4":
			SPEED += 20.0
		"tome1","tome2","tome3","tome4":
			spell_size += 0.10
		"scroll1","scroll2","scroll3","scroll4":
			spell_cooldown += 0.05
		"ring1","ring2":
			additional_attacks += 1
		"food":
			HP += 20
			HP = clamp(HP,0,maxHP)
	Hud.adjust_gui_collection(upgrade)
	attack()
	var option_children = Hud.get_node("CanvasLayer/LevelUp/UpgradeOptions").get_children()
	for i in option_children:
		i.queue_free()
	upgrade_options.clear()
	collected_upgrades.append(upgrade)
	Hud.get_node("CanvasLayer/LevelUp").visible = false
	Hud.get_node("CanvasLayer/LevelUp").position = Vector2(800,50)
	get_tree().paused = false
	calculate_experience(0)

func attack():
	iceSpear.attack()
	tornado.attack()


func change_time(argtime = 0):
	time = argtime
	var get_m = int(time/60.0)
	var get_s = time % 60
	if get_m < 10:
		get_m = str(0,get_m)
	if get_s < 10:
		get_s = str(0,get_s)
	Hud.lblTimer.text = str(get_m,":",get_s)

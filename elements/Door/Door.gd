extends StaticBody2D


@onready var animation = $AnimatedSprite2D
@export var door_level = 1
@onready var tilemap = get_parent()
@onready var tile_pos = tilemap.local_to_map(position)

# Called when the node enters the scene tree for the first time.
func _ready():
	animation.play("idle")
	await owner.ready
	tilemap.astar.set_point_solid(tile_pos)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass

func _on_entered_area_body_entered(body):
	if body.get_script().resource_path.get_file() == "player.gd" and body.access_door_level >= door_level:
		animation.play("open")
		return

func _on_entered_area_body_exited(body):
	if body.get_script().resource_path.get_file() == "player.gd" and body.access_door_level >= door_level:
		animation.play("close")
		return

func _on_animated_sprite_2d_animation_finished():
	if animation.animation == "close":
		$CollisionShape2D.set_deferred("disabled", false)
		tilemap.astar.set_point_solid(tile_pos, true)
		animation.play("idle")
	elif animation.animation == "open":
		$CollisionShape2D.set_deferred("disabled", true)
		tilemap.astar.set_point_solid(tile_pos, false)

extends Area2D
class_name Key

# Called when the node enters the scene tree for the first time.
@export var key_level = 1
@onready var animation = $AnimatedSprite2D
func _ready():
	animation.play("idle")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if body.get_script().resource_path.get_file() == "player.gd":
		hide()
		body.access_door_level = max(body.access_door_level, key_level)
		queue_free()

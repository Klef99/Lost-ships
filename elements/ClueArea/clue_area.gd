extends Area2D


@export var text: String
@onready var label = $Label
# Called when the node enters the scene tree for the first time.
func _ready():
	label.text = text
	label.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if body.get_script().resource_path.get_file() == "player.gd":
		label.show()
		


func _on_body_exited(body):
	if body.get_script().resource_path.get_file() == "player.gd":
		label.hide()
		#queue_free()

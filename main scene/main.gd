extends Node2D

@onready var tilemap = $TileMap
@onready var player = $Player
var move_area_container: Node2D
var is_pressed: bool


func _on_tree_exiting():
	Hud.get_node("CanvasLayer").visible = false

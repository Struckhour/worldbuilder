extends Node

@onready var hud = get_tree().current_scene.get_node("Hud")

var game_over := false


func trigger_game_over() -> void:
	if game_over:
		return

	game_over = true
	hud.show_game_over()
	get_tree().paused = true

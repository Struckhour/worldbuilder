extends Node

@onready var hud = get_tree().current_scene.get_node("Hud")
@onready var dialogue_box = $"../Hud/DialogueBox"

var game_over := false

func _ready() -> void:
	dialogue_box.dialogue_started.connect(_on_dialogue_started)
	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)

func trigger_game_over() -> void:
	if game_over:
		return

	game_over = true
	hud.show_game_over()
	get_tree().paused = true

func _on_dialogue_started() -> void:
	get_tree().paused = true
	dialogue_box.process_mode = Node.PROCESS_MODE_ALWAYS

func _on_dialogue_finished() -> void:
	if game_over:
		return

	get_tree().paused = false

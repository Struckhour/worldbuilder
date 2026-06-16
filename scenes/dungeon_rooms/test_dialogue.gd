extends Area2D

@export var json_path := "./test_text.json"
@export var dialogue_id := "text_0"
@export var pause_game := true

var triggered := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if triggered:
		return

	if not body.is_in_group("player"):
		return

	triggered = true
	set_deferred("monitoring", false)
	var dialogue = get_tree().get_first_node_in_group("dialogue_box")

	if dialogue:
		dialogue.display(json_path, dialogue_id, [], pause_game)

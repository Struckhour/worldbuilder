extends CollisionShape2D


@export var json_path := "./test_text.json"
@export var dialogue_id := "text_0"
@export var pause_game := true

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	
	var dialogue = get_tree().get_first_node_in_group("dialogue_box")
	dialogue.display(json_path, dialogue_id, [], pause_game)

extends Area2D

@export_multiline var dialogue_text := "You should not have come here."
@export var speaker_name := "Mage"

@onready var dialogue_box = $"../../Hud/DialogueBox"

var triggered := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if triggered:
		return

	if not body.is_in_group("player"):
		return

	triggered = true
	dialogue_box.show_dialogue(speaker_name, dialogue_text, null)

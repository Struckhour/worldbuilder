extends Area2D

@export_multiline var dialogue_text := "You should not have come here, my young apprentice. Now you will face your destiny."
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

	var portrait := AtlasTexture.new()
	portrait.atlas = preload("res://assets/gfx/objects.png")
	portrait.region = Rect2(0, 0, 16, 16)

	triggered = true
	dialogue_box.show_dialogue(speaker_name, dialogue_text, portrait)

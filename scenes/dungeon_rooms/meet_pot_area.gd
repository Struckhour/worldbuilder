extends Area2D

@onready var cutscene: Node2D = $"../CutsceneController"

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

	cutscene.start()

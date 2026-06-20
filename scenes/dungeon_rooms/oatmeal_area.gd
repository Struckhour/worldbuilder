extends Area2D

@onready var cutscene: Node2D = $"../OatmealCutsceneController"

var triggered := false


func _ready() -> void:
	add_to_group("interactables")


func interact() -> void:
	if triggered:
		return

	triggered = true
	set_deferred("monitoring", false)

	cutscene.start()

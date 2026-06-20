extends Node2D

@onready var interact_area: Area2D = $OatmealArea
@onready var cutscene: Node2D = $OatmealCutsceneController

var triggered := false

func _ready() -> void:
	interact_area.add_to_group("interactables")
	print("Oatmeal interact area ready")

func interact() -> void:
	print("Oatmeal interacted")
	if triggered:
		return

	triggered = true
	interact_area.set_deferred("monitoring", false)
	cutscene.start()

extends Area2D

@export var song: AudioStream

@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

	audio.stream = song
	audio.stop()

func _on_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return

	if not audio.playing:
		audio.play()

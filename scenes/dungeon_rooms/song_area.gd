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
	var dungeon_manager = get_tree().get_first_node_in_group("dungeon_manager")

	if dungeon_manager and dungeon_manager.has_method("stop_music"):
		dungeon_manager.stop_music()

	if not audio.playing:
		audio.play()

extends Node2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	anim.play("default")

	var frame_count := anim.sprite_frames.get_frame_count("default")
	anim.frame = randi_range(0, frame_count - 1)
	anim.frame_progress = randf()

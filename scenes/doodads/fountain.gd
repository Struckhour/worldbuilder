extends Node2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	scale = Vector2(1.5, 1.5)
	anim.play("default")
	add_to_group("solid_world")

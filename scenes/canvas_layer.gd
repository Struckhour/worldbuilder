extends CanvasLayer

@export var black_time := 1.0
@export var fade_in_time := 4.5
@export var hold_time := 2.0
@export var fade_out_time := 2.5

@onready var root: Control = $ColorRect
@onready var logo: Sprite2D = $ColorRect/Logo

func _ready() -> void:
	root.modulate.a = 1.0
	logo.modulate.a = 0.0

	# Stay black for a moment.
	await get_tree().create_timer(black_time).timeout

	# Fade logo in.
	var tween := create_tween()
	tween.tween_property(logo, "modulate:a", 1.0, fade_in_time)

	await tween.finished
	await get_tree().create_timer(hold_time).timeout

	# Fade entire screen away.
	tween = create_tween()
	tween.tween_property(root, "modulate:a", 0.0, fade_out_time)

	await tween.finished

	visible = false

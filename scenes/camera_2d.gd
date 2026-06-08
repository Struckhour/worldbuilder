extends Camera2D

@export var target: Node2D

var print_timer := 0.0

func _ready() -> void:
	enabled = true
	make_current()
	position_smoothing_enabled = false
	drag_horizontal_enabled = false
	drag_vertical_enabled = false

	print("CAMERA READY")
	print("target = ", target)
	print("is current = ", is_current())
	print("limits = ",
		limit_left, ", ",
		limit_top, ", ",
		limit_right, ", ",
		limit_bottom
	)
	print("zoom = ", zoom)
	print("viewport = ", get_viewport_rect().size)

func _process(delta: float) -> void:
	if not target:
		return

	var viewport_size := get_viewport_rect().size
	var half_view := viewport_size * 0.5 / zoom

	var desired := target.global_position

	var min_x := limit_left + half_view.x
	var max_x := limit_right - half_view.x
	var min_y := limit_top + half_view.y
	var max_y := limit_bottom - half_view.y

	var clamped := Vector2(
		clamp(desired.x, min_x, max_x),
		clamp(desired.y, min_y, max_y)
	)

	global_position = clamped.round()

	print_timer += delta
	if print_timer >= 0.5:
		print_timer = 0.0

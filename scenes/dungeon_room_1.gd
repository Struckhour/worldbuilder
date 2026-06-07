extends Node2D

@onready var camera_bounds_shape: CollisionShape2D = $CameraBounds/CollisionShape2D

func get_camera_bounds() -> Rect2:
	var shape := camera_bounds_shape.shape as RectangleShape2D
	var size := shape.size
	var center := camera_bounds_shape.global_position

	return Rect2(center - size / 2.0, size)

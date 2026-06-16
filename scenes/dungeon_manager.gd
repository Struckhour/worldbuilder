extends Node2D

@onready var current_room_holder: Node2D = $CurrentRoom
@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Camera2D
@onready var fade_layer: CanvasLayer = $FadeLayer

var current_room: Node2D
var transitioning := false

func _ready() -> void:
	add_to_group("dungeon_manager")
	
	fade_layer.get_node("ColorRect").modulate.a = 0.0

	current_room = current_room_holder.get_child(0)
	update_camera_bounds(current_room)

func change_room(target_room_path: String, target_spawn_name: String) -> void:
	if transitioning:
		return

	transitioning = true
	freeze_player(true)

	await fade_out()

	if current_room:
		current_room.queue_free()

	var room_scene := load(target_room_path) as PackedScene
	current_room = room_scene.instantiate()
	current_room_holder.add_child(current_room)

	await get_tree().process_frame

	var spawn := current_room.get_node("SpawnPoints/" + target_spawn_name) as Marker2D
	player.global_position = spawn.global_position
	open_spawn_door(target_spawn_name)
	update_camera_bounds(current_room)

	await fade_in()

	freeze_player(false)
	transitioning = false

func open_spawn_door(spawn_name: String) -> void:
	var door_name := spawn_name.replace("From", "Door")
	var door_path := door_name

	if not current_room.has_node(door_path):
		return

	var door = current_room.get_node(door_path)

	if door.has_method("force_open"):
		door.force_open()
	elif door.has_method("open"):
		door.open()



func update_camera_bounds(room: Node2D) -> void:
	var bounds: Rect2 = room.get_camera_bounds()

	camera.limit_left = int(bounds.position.x)
	camera.limit_top = int(bounds.position.y)
	camera.limit_right = int(bounds.end.x)
	camera.limit_bottom = int(bounds.end.y)

	print("Camera bounds: ",
		camera.limit_left, ", ",
		camera.limit_top, ", ",
		camera.limit_right, ", ",
		camera.limit_bottom
	)

func freeze_player(value: bool) -> void:
	player.set_physics_process(not value)

	if value:
		player.velocity = Vector2.ZERO

func fade_out() -> void:
	var color_rect: ColorRect = fade_layer.get_node("ColorRect")

	var tween := create_tween()
	tween.tween_property(color_rect, "modulate:a", 1.0, 0.25)
	await tween.finished

func fade_in() -> void:
	var color_rect: ColorRect = fade_layer.get_node("ColorRect")

	var tween := create_tween()
	tween.tween_property(color_rect, "modulate:a", 0.0, 0.25)
	await tween.finished

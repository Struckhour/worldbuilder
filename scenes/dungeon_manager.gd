extends Node2D

@onready var current_room_holder: Node2D = $CurrentRoom
@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Camera2D
@onready var fade_layer: CanvasLayer = $FadeLayer
@onready var player_hold_point: Marker2D = $PlayerHoldPoint
@onready var music_player: AudioStreamPlayer = $MusicPlayer
@export var default_music: AudioStream

var current_room: Node2D
var transitioning := false

func _ready() -> void:
	add_to_group("dungeon_manager")
	
	fade_layer.get_node("ColorRect").modulate.a = 0.0

	current_room = current_room_holder.get_child(0)

	# Put player inside starting room too.
	reparent_player_to(current_room)

	update_camera_bounds(current_room)
	if default_music:
		play_music(default_music)

func change_room(target_room_path: String, target_spawn_name: String) -> void:
	if transitioning:
		return

	transitioning = true
	freeze_player(true)

	await fade_out()

	# Move player somewhere safe before freeing old room.
	reparent_player_to(self)
	player.global_position = player_hold_point.global_position
	await get_tree().physics_frame

	if current_room:
		current_room.queue_free()
		current_room = null
		await get_tree().process_frame

	var room_scene := load(target_room_path) as PackedScene

	if room_scene == null:
		push_error("Could not load room: " + target_room_path)
		freeze_player(false)
		transitioning = false
		return

	current_room = room_scene.instantiate()
	current_room_holder.add_child(current_room)

	# Put player inside the new room.
	reparent_player_to(current_room)

	var spawn_path := "SpawnPoints/" + target_spawn_name

	if not current_room.has_node(spawn_path):
		push_error("Missing spawn point: " + spawn_path)
		freeze_player(false)
		transitioning = false
		return

	var spawn := current_room.get_node(spawn_path) as Marker2D
	player.global_position = spawn.global_position

	open_spawn_door(target_spawn_name)
	update_camera_bounds(current_room)

	await get_tree().physics_frame
	await fade_in()

	freeze_player(false)
	transitioning = false


func reparent_player_to(new_parent: Node) -> void:
	var old_global_position := player.global_position

	if player.get_parent():
		player.get_parent().remove_child(player)

	new_parent.add_child(player)
	player.global_position = old_global_position


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



func play_music(song: AudioStream) -> void:
	if music_player.stream == song and music_player.playing:
		return

	music_player.stream = song
	music_player.play()

func stop_music() -> void:
	music_player.stop()

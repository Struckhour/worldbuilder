extends Node2D

@export var closed_texture: Texture2D
@export var open_texture: Texture2D

@export_file("*.tscn") var target_room_path: String
@export var target_spawn_name := "FromSouth"

@export var door_id := ""
@export_enum("open", "closed", "locked") var default_state := "closed"

@onready var sprite: Sprite2D = $Sprite2D
@onready var body_collision: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var interact_area: Area2D = $InteractArea
@onready var transition_area: Area2D = $TransitionArea

var transitioning := false
var is_open := false
var is_locked := false
var armed := false

func _ready() -> void:
	add_to_group("doors")
	interact_area.add_to_group("interactables")
	transition_area.body_entered.connect(_on_body_entered)

	if door_id == "":
		push_warning("Door has no door_id: " + name)
		apply_state(default_state)
	else:
		if not DungeonState.door_states.has(door_id):
			DungeonState.set_door_state(door_id, default_state)

		apply_state(DungeonState.get_door_state(door_id))

	await get_tree().process_frame
	await get_tree().create_timer(0.2).timeout
	armed = true

func interact() -> void:
	if is_locked:
		print("Door is locked.")
		return

	if is_open:
		close()
	else:
		open()

func open() -> void:
	set_state("open")

func close() -> void:
	set_state("closed")

func lock() -> void:
	set_state("locked")

func unlock() -> void:
	set_state("closed")

func force_open() -> void:
	set_state("open")

func set_state(state: String) -> void:
	if door_id != "":
		DungeonState.set_door_state(door_id, state)

	apply_state(state)

func apply_state(state: String) -> void:
	match state:
		"open":
			is_open = true
			is_locked = false
			sprite.region_enabled = false
			sprite.texture = open_texture
			body_collision.set_deferred("disabled", true)

		"closed":
			is_open = false
			is_locked = false
			sprite.region_enabled = false
			sprite.texture = closed_texture
			body_collision.set_deferred("disabled", false)

		"locked":
			is_open = false
			is_locked = true
			sprite.region_enabled = false
			sprite.texture = closed_texture
			body_collision.set_deferred("disabled", false)

func _on_body_entered(body: Node2D) -> void:
	if not armed:
		return

	if not body.is_in_group("player"):
		return

	if not is_open:
		return

	start_transition()

func start_transition() -> void:
	if transitioning:
		return

	transitioning = true

	var dungeon_manager = get_tree().get_first_node_in_group("dungeon_manager")
	if dungeon_manager:
		dungeon_manager.change_room(target_room_path, target_spawn_name)

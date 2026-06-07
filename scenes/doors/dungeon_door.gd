extends Node2D

@export var closed_texture: Texture2D
@export var open_texture: Texture2D
@export var starts_open := false

@onready var sprite: Sprite2D = $Sprite2D
@onready var body_collision: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var interact_area: Area2D = $InteractArea


#@export var target_room_scene: PackedScene
@export_file("*.tscn") var target_room_path: String
@export var target_spawn_name := "FromSouth"

@onready var transition_area: Area2D = $TransitionArea

var transitioning := false
var is_open := false

var armed := false

func _ready() -> void:
	transition_area.body_entered.connect(_on_body_entered)

	await get_tree().process_frame
	await get_tree().create_timer(0.2).timeout
	armed = true

	interact_area.add_to_group("interactables")

	if starts_open:
		open()
	else:
		close()

func interact() -> void:
	if is_open:
		close()
	else:
		open()

func open() -> void:
	is_open = true
	sprite.region_enabled = false
	sprite.texture = open_texture
	body_collision.set_deferred("disabled", true)

func close() -> void:
	is_open = false
	sprite.texture = closed_texture
	sprite.region_enabled = false
	body_collision.set_deferred("disabled", false)


func _on_body_entered(body: Node2D) -> void:
	if not armed:
		return

	if not body.is_in_group("player"):
		return

	if not is_open:
		return

	start_transition()

func force_open() -> void:
	starts_open = true
	open()

func start_transition() -> void:
	if transitioning:
		return

	transitioning = true

	var dungeon_manager = get_tree().get_first_node_in_group("dungeon_manager")
	if dungeon_manager:
		#dungeon_manager.change_room(target_room_scene, target_spawn_name)
		dungeon_manager.change_room(target_room_path, target_spawn_name)

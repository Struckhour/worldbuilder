extends Node2D

@export_multiline var book_text := "The old book opens. Its pages are filled with strange symbols."

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var interact_area: Area2D = $InteractArea
var dialogue_lock := false
var opened := false
var opening := false
@export var portrait_texture: Texture2D

func _ready() -> void:
	interact_area.add_to_group("interactables")
	anim.play("closed")
	anim.animation_finished.connect(_on_animation_finished)

func interact() -> void:
	if opened:
		show_book_dialogue()
		return

	opened = true
	opening = true
	set_world_blocked(true)
	anim.play("open")

func _on_animation_finished() -> void:
	if opening and anim.animation == "open":
		opening = false
		show_book_dialogue()

func show_book_dialogue() -> void:
	if dialogue_lock:
		return

	var dialogue_box = get_tree().get_first_node_in_group("dialogue_box")
	if dialogue_box:
		dialogue_lock = true
		dialogue_box.dialogue_finished.connect(_on_dialogue_finished, CONNECT_ONE_SHOT)
		dialogue_box.show_dialogue("", book_text, portrait_texture)

func _on_dialogue_finished() -> void:
	anim.play_backwards("open")
	opened = false

	await anim.animation_finished

	call_deferred("_unlock_dialogue")

func _unlock_dialogue() -> void:
	await get_tree().create_timer(0.2).timeout
	dialogue_lock = false

func set_world_blocked(value: bool) -> void:
	var dialogue_box = get_tree().get_first_node_in_group("dialogue_box")
	if dialogue_box:
		dialogue_box.blocking_world_interaction = value

extends Node2D

@export var dialogue_json := "./test_text.json"
@export var dialogue_id := "book_0"

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var interact_area: Area2D = $InteractArea

var dialogue_lock := false
var opened := false
var opening := false


func _ready() -> void:
	interact_area.add_to_group("interactables")
	anim.play("closed")
	anim.animation_finished.connect(_on_animation_finished)


func interact() -> void:
	if dialogue_lock or opening:
		return

	if opened:
		show_book_dialogue()
		return

	opened = true
	opening = true
	anim.play("open")


func _on_animation_finished() -> void:
	if opening and anim.animation == "open":
		opening = false
		show_book_dialogue()


func show_book_dialogue() -> void:
	if dialogue_lock:
		return

	var dialogue_box = get_tree().get_first_node_in_group("dialogue_box")

	if dialogue_box == null:
		push_warning("No dialogue_box found.")
		return

	dialogue_lock = true

	await dialogue_box.display(dialogue_json, dialogue_id, [], true)

	anim.play_backwards("open")
	opened = false

	await anim.animation_finished
	await get_tree().create_timer(0.2).timeout

	dialogue_lock = false

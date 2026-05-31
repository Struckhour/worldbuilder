extends Node2D

@export var closed_texture: Texture2D
@export var open_texture: Texture2D
@export var starts_open := false

@onready var sprite: Sprite2D = $Sprite2D
@onready var body_collision: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var interact_area: Area2D = $InteractArea

var is_open := false

func _ready() -> void:
	interact_area.add_to_group("interactables")
	print("closed texture: ", closed_texture)
	print("open texture: ", open_texture)
	print("sprite texture: ", sprite.texture)
	print("sprite visible: ", sprite.visible)
	print("sprite global position: ", sprite.global_position)
	print("sprite z: ", sprite.z_index)
	print("door root: ", global_position)
	print("sprite local: ", sprite.position)
	print("sprite global: ", sprite.global_position)
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

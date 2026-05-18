extends Node2D

const MAX_DIAMONDS := 5
const SPAWN_INTERVAL := 5.0
const DIAMOND_SCENE := preload("res://scenes/enemies/diamond.tscn")

@export var spawn_radius_min := 120.0
@export var spawn_radius_max := 260.0

@onready var player: CharacterBody2D = $"../Player"

var spawn_timer := 0.0


func _process(delta: float) -> void:
	spawn_timer += delta

	if spawn_timer >= SPAWN_INTERVAL:
		spawn_timer = 0.0
		try_spawn_diamond()


func try_spawn_diamond() -> void:
	if get_tree().get_nodes_in_group("diamonds").size() >= MAX_DIAMONDS:
		return

	var angle := randf_range(0.0, TAU)
	var distance := randf_range(spawn_radius_min, spawn_radius_max)

	var spawn_pos := player.global_position + Vector2(
		cos(angle),
		sin(angle)
	) * distance

	var diamond := DIAMOND_SCENE.instantiate()
	diamond.global_position = spawn_pos
	diamond.add_to_group("diamonds")

	get_parent().add_child(diamond)

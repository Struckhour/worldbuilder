extends Node2D

const TILE_SIZE := 16.0

const TREE_SCENES := [
	preload("res://scenes/trees/birch_tree.tscn"),
	preload("res://scenes/trees/blue_tree.tscn"),
	preload("res://scenes/trees/fir_tree.tscn"),
	preload("res://scenes/trees/maple_tree.tscn")
]

const FLAG_SCENE := preload("res://scenes/doodads/waving_flag.tscn")
const FLAG_COUNT := 8
const ALIEN_SCENE := preload("res://scenes/enemies/alien.tscn")
const ALIEN_COUNT := 12
const ALIEN_SPAWN_ATTEMPTS := 200


func _ready() -> void:
	print("TreeGenerator is running")

	randomize()

	for i in range(150):
		var pos := random_tree_position()
		place_random_tree(pos)

	for i in range(FLAG_COUNT):
		var pos := random_tree_position()
		place_flag(pos)
	for i in range(ALIEN_COUNT):
		place_random_alien()

func place_random_alien() -> void:
	for attempt in range(ALIEN_SPAWN_ATTEMPTS):
		var pos := random_tree_position()

		if not position_has_tree(pos):
			var alien := ALIEN_SCENE.instantiate()
			alien.global_position = pos
			get_parent().add_child.call_deferred(alien)
			return

	print("Could not find open spot for alien")

func position_has_tree(pos: Vector2) -> bool:
	var space := get_world_2d().direct_space_state

	var query := PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collide_with_bodies = true
	query.collide_with_areas = false

	var hits := space.intersect_point(query, 8)

	for hit in hits:
		var collider : Node2D = hit.collider

		if collider.is_in_group("trees") or collider.get_parent().is_in_group("trees"):
			return true

	return false

func random_tree_position() -> Vector2:
	var padding_tiles := 2

	var area := GameArea.PLAY_AREA_TILES

	var cell := Vector2i(
		randi_range(area.position.x + padding_tiles, area.end.x - 1 - padding_tiles),
		randi_range(area.position.y + padding_tiles, area.end.y - 1 - padding_tiles)
	)

	return GameArea.tile_to_world(cell)

func place_flag(pos: Vector2) -> void:
	var flag := FLAG_SCENE.instantiate()

	flag.global_position = pos
	var anim := flag.get_node("AnimatedSprite2D")
	anim.play("default")
	get_parent().add_child.call_deferred(flag)

func place_random_tree(pos: Vector2) -> void:
	var tree_scene: PackedScene = TREE_SCENES.pick_random()
	var tree := tree_scene.instantiate()

	tree.global_position = pos

	var scale_factor := randf_range(0.9, 1.1)
	tree.scale = Vector2(scale_factor, scale_factor)
	tree.add_to_group("trees")
	get_parent().add_child.call_deferred(tree)

func place_tree_at_world_position(pos: Vector2) -> void:
	var tree_scene: PackedScene = preload("res://scenes/trees/fir_tree.tscn")
	var tree := tree_scene.instantiate()

	tree.global_position = pos
	tree.add_to_group("trees")

	get_parent().add_child.call_deferred(tree)

	print("Placed tree: ", tree.name, " at ", tree.global_position)
